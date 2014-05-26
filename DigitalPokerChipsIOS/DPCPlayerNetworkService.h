//
//  DPCPlayerNetworkService.h
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 9/04/14.
//
//

#import <Foundation/Foundation.h>

#import "DPCPlayerNetwork.h"
#import "GCDAsyncUdpSocket.h"
#import "GCDAsyncSocket.h"

@interface DPCPlayerNetworkService : NSObject <GCDAsyncUdpSocketDelegate,GCDAsyncSocketDelegate>

@property () DPCPlayerNetwork* playerNetwork;

-(void) stopDiscover;
-(void) startDiscover:(NSString*)playerAnnounceStr;
-(void) playerConnect:(NSData*)hostBytes connectString:(NSString*)connectString;
-(void) startListen;
-(void) stopListen;
-(void) sendToHost:(NSString*)msg;
-(void) leaveTable:(NSString*)msg;
-(void) disconnectCurrentGame;

@end
