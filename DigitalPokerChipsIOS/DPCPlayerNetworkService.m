//
//  DPCPlayerNetworkService.m
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 9/04/14.
//
//

#import <ifaddrs.h>
#import <arpa/inet.h>

#import "DPCPlayerNetworkService.h"
#import "GCDAsyncUdpSocket.h"
#import "GCDAsyncSocket.h"

@interface DPCPlayerNetworkService () {   
    
    int discoverState;
    int connectState;
    
    GCDAsyncUdpSocket* udpSocket;
    NSString* broadcastAddrStr;
    NSTimer *broadcastTimer;
    NSString* playerAnnounceStr;
    
    GCDAsyncSocket* commsSocket;
    NSData* hostBytes;
    NSString* playerConnectString;
    NSString* tableInfoString;
    NSString* playerReconnectString;
    NSTimer *reconnectTimer;
}
@end

@implementation DPCPlayerNetworkService

static const int DISCOVER_STATE_NONE = 0;
static const int DISCOVER_STATE_DISCOVERING = 1;

static const int CONNECT_STATE_FAILED = 0;
static const int CONNECT_STATE_NONE = 1;
static const int CONNECT_STATE_SOCKET_CONNECTING = 2;
static const int CONNECT_STATE_READ_TABLE_INFO = 3;
static const int CONNECT_STATE_READ_ACK = 4;
static const int CONNECT_STATE_CONNECTED = 5;
static const int CONNECT_STATE_LISTENING = 6;

static const NSString* LOG_TAG = @"DPCPlayerNetwork";

-(id) init {
    if (self=[super init]) {
        udpSocket=[[GCDAsyncUdpSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        commsSocket=[[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        discoverState=DISCOVER_STATE_NONE;
        connectState=CONNECT_STATE_NONE;
    };
    return self;
}

-(void) dealloc {
    _playerNetwork=nil;
}

-(void) stopDiscover {
    discoverState=DISCOVER_STATE_NONE;
    [broadcastTimer invalidate];
    [udpSocket setDelegate:nil];
    //[udpSocket pauseReceiving];
    [udpSocket close];
}

-(void) startDiscover:(NSString*)playerAnnounceStr_ {
    playerAnnounceStr=playerAnnounceStr_;
    struct ifaddrs *ifa = NULL,*ifList;
    getifaddrs(&ifList);
    struct sockaddr *sa=NULL;
    for (ifa=ifList;ifa!=NULL;ifa=ifa->ifa_next) {
        if (strcmp(ifa->ifa_name,"en0")==0||sa==NULL) {
            sa=ifa->ifa_dstaddr;
        }
    }
    struct sockaddr_in *sin = (struct sockaddr_in*)sa;
    char *ip=inet_ntoa(sin->sin_addr);
    broadcastAddrStr=[NSString stringWithUTF8String:ip];
    NSError *error=nil;
    [udpSocket setDelegate:self];
    [udpSocket bindToPort:11112 error:&error];
    if (error==nil) {
        [udpSocket beginReceiving:&error];
        if (error==nil) {
            [udpSocket enableBroadcast:YES error:&error];
            if (error==nil) {
                discoverState=DISCOVER_STATE_DISCOVERING;
                broadcastTimer=[NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(findTables:) userInfo:nil repeats:YES];
                [broadcastTimer fire];
            }
        }
    }
    
}

-(void)findTables:(NSTimer*)theTimer {
    if (discoverState==DISCOVER_STATE_DISCOVERING) {
        NSData *data=[playerAnnounceStr dataUsingEncoding:NSUTF8StringEncoding];
        [udpSocket sendData:data toHost:broadcastAddrStr port:11111 withTimeout:2 tag:0];
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext {
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (discoverState==DISCOVER_STATE_DISCOVERING) {
        [_playerNetwork discoverResponseRxd:address rxMsg:msg];
    }
}


-(void) playerConnect:(NSData *)hostBytes_ connectString:(NSString *)connectString {
    hostBytes=hostBytes_;
    playerConnectString=[NSString stringWithFormat:@"%@\n",connectString];
    [commsSocket setDelegate:self];
    NSError *error=nil;
    connectState=CONNECT_STATE_SOCKET_CONNECTING;
    [commsSocket connectToHost:[GCDAsyncSocket hostFromAddress:hostBytes_] onPort:11113 error:&error];
    if (error!=nil) {
        [self connectFailed];
    }
}

-(void)stopListen {
    connectState=CONNECT_STATE_NONE;
}

-(void)startListen {
    connectState=CONNECT_STATE_LISTENING;
}

-(void)socket:(GCDAsyncSocket*)sender didConnectToHost:(NSString *)host port:(uint16_t)port {
    if ([host isEqualToString:[GCDAsyncSocket hostFromAddress:hostBytes]]) {
        if (connectState==CONNECT_STATE_SOCKET_CONNECTING) {
            connectState=CONNECT_STATE_READ_TABLE_INFO;
            [commsSocket readDataToData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:3 tag:1];
        }
    }
}

-(void)socket:(GCDAsyncSocket*)sender didReadData:(NSData *)data withTag:(long)tag {
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSUInteger newlineLocation=[msg rangeOfString:@"\n"].location;
    if (newlineLocation!=NSNotFound) {
        msg=[msg substringToIndex:newlineLocation];
        if (connectState==CONNECT_STATE_READ_TABLE_INFO) {
            if ([_playerNetwork validateTableInfo:msg]) {
                tableInfoString=msg;
                [commsSocket writeData:[playerConnectString dataUsingEncoding:NSUTF8StringEncoding] withTimeout:5 tag:1];
                [commsSocket readDataToData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:5 tag:1];
                connectState=CONNECT_STATE_READ_ACK;
            } else if ([msg rangeOfString:@"<DPC_CONNECTION_UNSUCCESSFUL/>"].location!=NSNotFound) {
                [self connectFailed];
            }
        } else if (connectState==CONNECT_STATE_READ_ACK) {
            if ([_playerNetwork validateTableACK:msg]) {
                connectState=CONNECT_STATE_CONNECTED;
                [commsSocket readDataToData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:8 tag:1];
                [_playerNetwork notifyGameConnected:[NSString stringWithFormat:@"%@%@",tableInfoString,msg]];
            } else if ([msg rangeOfString:@"<DPC_CONNECTION_UNSUCCESSFUL/>"].location!=NSNotFound) {
                [self connectFailed];
            }
        } else if (connectState==CONNECT_STATE_LISTENING) {
            [_playerNetwork parseGameMessage:msg];
            [commsSocket readDataToData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:8 tag:1];
        } else {
            [commsSocket readDataToData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:5 tag:1];
        }
    } else {
        [commsSocket readDataToData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:5 tag:1];
    }
}

-(void) sendToHost:(NSString*) msg {
    msg=[NSString stringWithFormat:@"%@\n",msg];
    [commsSocket writeData:[msg dataUsingEncoding:NSUTF8StringEncoding] withTimeout:5 tag:1];
}

-(void) leaveTable:(NSString*)msg {
    [self sendToHost:msg];
    [self stopListen];
    [self disconnectCurrentGame];
}

-(void) disconnectCurrentGame {
    if (commsSocket!=nil) {
        [commsSocket setDelegate:nil];
        [commsSocket disconnect];
    }
}

-(NSTimeInterval)socket:(GCDAsyncSocket*)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length {
    if (connectState==CONNECT_STATE_NONE||
        connectState==CONNECT_STATE_SOCKET_CONNECTING||
        connectState==CONNECT_STATE_READ_TABLE_INFO||
        connectState==CONNECT_STATE_READ_ACK) {
        [self connectFailed];
    } else if (connectState==CONNECT_STATE_CONNECTED||
               connectState==CONNECT_STATE_LISTENING) {
        [self disconnectCurrentGame];
        [_playerNetwork notifyConnectionLost];
    }
    return 0;
}

-(void)socketDidDisconnect:(GCDAsyncSocket*)sock withError:(NSError*)error {
    if (connectState==CONNECT_STATE_SOCKET_CONNECTING||
        connectState==CONNECT_STATE_READ_TABLE_INFO||
        connectState==CONNECT_STATE_READ_ACK) {
        [self connectFailed];
    } else if (connectState==CONNECT_STATE_CONNECTED||
               connectState==CONNECT_STATE_LISTENING) {
        [self disconnectCurrentGame];
        [_playerNetwork notifyConnectionLost];
    }
}

-(void)connectFailed {
    if (connectState==CONNECT_STATE_READ_TABLE_INFO||
        connectState==CONNECT_STATE_READ_ACK||
        connectState==CONNECT_STATE_CONNECTED) {
        [self sendToHost:@"<GOODBYE/>"];
    }
    connectState=CONNECT_STATE_FAILED;
    [self disconnectCurrentGame];
    [_playerNetwork notifyConnectFailed];
}

@end

