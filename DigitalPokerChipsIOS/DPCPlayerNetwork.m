//
//  DPCPlayerNetwork.m
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 9/04/14.
//
//

#import "cocos2d.h"
#import "DPCPlayerNetwork.h"
#import "DPCPlayerNetworkService.h"
#import "DPCThisPlayer.h"
#import "DPCChipCase.h"
#import "DPCChipStack.h"
#import "DPCPlayerEntry.h"

NSString *const PLAYER_TAG_PLAYER_NAME_OPEN = @"<PLAYER_NAME>";
NSString *const PLAYER_TAG_PLAYER_NAME_CLOSE = @"<PLAYER_NAME/>";
NSString *const PLAYER_TAG_PLAYER_NAME_NEG_OPEN = @"<PLAYER_NAME_NEG>";
NSString *const PLAYER_TAG_PLAYER_NAME_NEG_CLOSE = @"<PLAYER_NAME_NEG/>";
NSString *const PLAYER_TAG_SUBMIT_MOVE_OPEN = @"<SUBMIT_MOVE>";
NSString *const PLAYER_TAG_SUBMIT_MOVE_CLOSE = @"<SUBMIT_MOVE/>";
NSString *const PLAYER_TAG_MOVE_OPEN = @"<MOVE>";
NSString *const PLAYER_TAG_MOVE_CLOSE = @"<MOVE/>";
NSString *const PLAYER_TAG_CHIPS_OPEN = @"<CHIPS>";
NSString *const PLAYER_TAG_CHIPS_CLOSE = @"<CHIPS/>";
NSString *const PLAYER_TAG_AZIMUTH_OPEN = @"<AZIMUTH>";
NSString *const PLAYER_TAG_AZIMUTH_CLOSE = @"<AZIMUTH/>";
NSString *const PLAYER_TAG_NUM_A_OPEN = @"<NUM_A>";
NSString *const PLAYER_TAG_NUM_A_CLOSE = @"<NUM_A/>";
NSString *const PLAYER_TAG_NUM_B_OPEN = @"<NUM_B>";
NSString *const PLAYER_TAG_NUM_B_CLOSE = @"<NUM_B/>";
NSString *const PLAYER_TAG_NUM_C_OPEN = @"<NUM_C>";
NSString *const PLAYER_TAG_NUM_C_CLOSE = @"<NUM_C/>";
NSString *const PLAYER_TAG_GOODBYE = @"<GOODBYE/>";
NSString *const PLAYER_TAG_RECONNECT_FAILED = @"<TAG_RECONNECT_FAILED/>";
NSString *const PLAYER_TAG_SETUP_ACK = @"<DPC_SETUP_ACK/>";
NSString *const PLAYER_TAG_CHIPS_ACK = @"<DPC_WIN_ACK/>";
NSString *const PLAYER_TAG_GOODBYE_ACK = @"<DPC_GOODBYE_ACK/>";
NSString *const PLAYER_TAG_SEND_BELL_OPEN = @"<BELL_OPEN>";
NSString *const PLAYER_TAG_SEND_BELL_CLOSE = @"<BELL_OPEN/>";

@interface DPCPlayerNetwork () {
	BOOL wifiEnabled;
	BOOL tableConnected;
	BOOL doingHostDiscover;
	NSData* hostBytes;
	NSString* playerName;
	BOOL doingReconnect;
	NSString* lastCommand;
	NSString* lastReply;
	NSString* game_key;
	DPCPlayerNetworkService* playerNetworkService;
}

@end

@implementation DPCPlayerNetwork

-(id) init {
    if (self=[super init]) {
        playerNetworkService=[[DPCPlayerNetworkService alloc]init];
        playerNetworkService.playerNetwork=self;
        tableConnected=NO;
		doingHostDiscover=NO;
		hostBytes=nil;
		playerName=@"";
		doingReconnect=NO;
        lastReply=nil;
        
        [self setWifiEnabled:YES];
    }
    return self;
}

-(void)dealloc {
    _player=nil;
    playerNetworkService=nil;
}

-(void) onStart {
    
}

-(void) onStop {
    
}

-(void) startRequestGames {
    if (wifiEnabled&&!doingHostDiscover) {
        [self spawnDiscover];
    }
    doingHostDiscover=YES;
}

-(void) stopRequestGames {
    [playerNetworkService stopDiscover];
    doingHostDiscover=NO;
}

-(void) requestInvitation:(NSData*) hostBytes {
    
}

-(void) spawnDiscover {
    CCLOG(@"PlayerNetwork - spawnDiscover()");
    NSString* playerAnnounceStr=[NSString stringWithFormat:@"%@%@%@", PLAYER_TAG_PLAYER_NAME_NEG_OPEN,playerName,PLAYER_TAG_PLAYER_NAME_NEG_CLOSE];
    [playerNetworkService startDiscover:playerAnnounceStr];
}

-(void) spawnConnect:(NSData*)hostBytes_ playerName:(NSString*)playerName_ azimuth:(int)azimuth chipNumbers:(NSArray*)chipNumbers {
     CCLOG(@"PlayerNetwork - spawnConnect()");
    NSString* playerSetupString=[NSString stringWithFormat:@"%@%@%@",PLAYER_TAG_PLAYER_NAME_NEG_OPEN,playerName_,PLAYER_TAG_PLAYER_NAME_NEG_CLOSE];
    playerSetupString=[NSString stringWithFormat:@"%@%@%d%@",playerSetupString,PLAYER_TAG_AZIMUTH_OPEN,azimuth,PLAYER_TAG_AZIMUTH_CLOSE];
    int thisChipNumber=[[chipNumbers objectAtIndex:CHIP_CASE_CHIP_A] intValue];
    playerSetupString=[NSString stringWithFormat:@"%@%@%d%@",playerSetupString,PLAYER_TAG_NUM_A_OPEN,thisChipNumber,PLAYER_TAG_NUM_A_CLOSE];
    thisChipNumber=[[chipNumbers objectAtIndex:CHIP_CASE_CHIP_B] intValue];
    playerSetupString=[NSString stringWithFormat:@"%@%@%d%@",playerSetupString,PLAYER_TAG_NUM_B_OPEN,thisChipNumber,PLAYER_TAG_NUM_B_CLOSE];
    thisChipNumber=[[chipNumbers objectAtIndex:CHIP_CASE_CHIP_C] intValue];
    playerSetupString=[NSString stringWithFormat:@"%@%@%d%@",playerSetupString,PLAYER_TAG_NUM_C_OPEN,thisChipNumber,PLAYER_TAG_NUM_C_CLOSE];
    [playerNetworkService playerConnect:hostBytes_ connectString:playerSetupString];
}

-(void) spawnReconnect {
    CCLOG(@"PlayerNetwork - spawnReconnect()");
    NSString* reconnectMsg=[NSString stringWithFormat:@"%@%@%@",@"<GAME_KEY>",game_key,@"<GAME_KEY/>"];
    [playerNetworkService startReconnect:hostBytes reconnectString:reconnectMsg];
}

-(void) setWifiEnabled:(BOOL)en {
    wifiEnabled=en;
    if (wifiEnabled) {
        if (doingHostDiscover) {
            [self spawnDiscover];
        }
    } else {
        if (doingHostDiscover) {
            [playerNetworkService stopDiscover];
        }
    }
}

-(BOOL) validateTableInfo:(NSString*)msg { 
    if ([msg rangeOfString:@"<TABLE_NAME>"].location != NSNotFound &&
        [msg rangeOfString:@"<TABLE_NAME/>"].location != NSNotFound ) {
        return YES;
    } else {
        return NO;
    }
}

-(BOOL) validateReconnectTableInfo:(NSString*)msg {
    if ([msg rangeOfString:@"<RECONNECT_TABLE_NAME>"].location != NSNotFound &&
        [msg rangeOfString:@"<RECONNECT_TABLE_NAME/>"].location != NSNotFound ) {
        return YES;
    } else {
        return NO;
    }
}

-(BOOL) validateTableACK:(NSString*)ackMsg {
    if ([ackMsg rangeOfString:@"<GAME_KEY>"].location != NSNotFound &&
        [ackMsg rangeOfString:@"<GAME_KEY/>"].location != NSNotFound ) {
        return YES;
    } else {
        return NO;
    }
}

-(BOOL) validateReconnectACK:(NSString*)ackMsg {
    if ([ackMsg rangeOfString:@"<RECONNECT_SUCCESSFUL/>"].location != NSNotFound) {
        return YES;
    } else {
        return NO;
    }
}


-(void) notifyReconnected {
    [_player notifyReconnected];
    doingReconnect=false;
    [self setName:playerName];
}

-(void) requestConnect:(DPCDiscoveredTable*)table azimuth:(int)azimuth chipNumbers:(NSArray*)chipNumbers {
    
    if (wifiEnabled) {
        hostBytes=table.hostBytes;
        [self spawnConnect:hostBytes playerName:playerName azimuth:azimuth chipNumbers:chipNumbers];
    }
}

-(void)startReconnect {
    if (tableConnected) {
        [_player notifyConnectionLost];
        doingReconnect=YES;
        [self spawnReconnect];
    }
}

-(void) setName:(NSString*)playerName_ {
    playerName=playerName_;
    if (tableConnected) {
        if (!doingReconnect) {
            NSString* msg=[NSString stringWithFormat:@"%@%@%@", PLAYER_TAG_PLAYER_NAME_OPEN,playerName,PLAYER_TAG_PLAYER_NAME_CLOSE];
            [playerNetworkService sendToHost:msg];
        }
    }
}

-(void) submitMove:(int)move chipString:(NSString*)chipString {
    if (wifiEnabled&&!doingReconnect) {
        NSString* msg=@"<SUBMIT_MOVE>";
        msg=[NSString stringWithFormat:@"%@%@%d%@",msg,@"<MOVE>",move,@"<MOVE/>"];
        msg=[NSString stringWithFormat:@"%@%@%@%@",msg,@"<CHIPS>",chipString,@"<CHIPS/>"];
        msg=[NSString stringWithFormat:@"%@%@",msg,@"<SUBMIT_MOVE/>"];
        [playerNetworkService sendToHost:msg];
        lastReply=msg;
    }
}

-(void) leaveTable {
    if (wifiEnabled) {
        tableConnected=false;
        doingReconnect=false;
        [playerNetworkService leaveTable:@"<GOODBYE/>"];
    }
}

-(void) sendBell:(NSString*) hostName {
    NSString* msg=[NSString stringWithFormat:@"%@%@%@", @"<BELL_OPEN>",hostName,@"<BELL_OPEN/>"];
    [playerNetworkService sendToHost:msg];
}

-(void) notifyTableFound:(NSData*) dHostBytes rxMsg:(NSString*)rxMsg {
    
    int startIndex=(int)[rxMsg rangeOfString:@"<TABLE_NAME>"].location+(int)[@"<TABLE_NAME>" length];
    int len=(int)[rxMsg rangeOfString:@"<TABLE_NAME/>"].location-startIndex;
    NSString* tableName=[rxMsg substringWithRange:NSMakeRange(startIndex,len)];
    
    DPCChipCase* chipCase=[DPCChipCase chipCase];
    
    startIndex=(int)[rxMsg rangeOfString:@"<VAL_A>"].location+(int)[@"<VAL_A>" length];
    len=(int)[rxMsg rangeOfString:@"<VAL_A/>"].location-startIndex;
    [chipCase setValue:[rxMsg substringWithRange:NSMakeRange(startIndex,len)].intValue chipType:CHIP_CASE_CHIP_A];
    startIndex=(int)[rxMsg rangeOfString:@"<VAL_B>"].location+(int)[@"<VAL_B>" length];
    len=(int)[rxMsg rangeOfString:@"<VAL_B/>"].location-startIndex;
    [chipCase setValue:[rxMsg substringWithRange:NSMakeRange(startIndex,len)].intValue chipType:CHIP_CASE_CHIP_B];
    startIndex=(int)[rxMsg rangeOfString:@"<VAL_C>"].location+(int)[@"<VAL_C>" length];
    len=(int)[rxMsg rangeOfString:@"<VAL_C/>"].location-startIndex;
    [chipCase setValue:[rxMsg substringWithRange:NSMakeRange(startIndex,len)].intValue chipType:CHIP_CASE_CHIP_C];
    
    BOOL loadedGame=[rxMsg rangeOfString:@"<TAG_LOADED_GAME/>"].location!=NSNotFound;
    
    if (_player!=nil) {
        DPCDiscoveredTable *discoveredTable=[[DPCDiscoveredTable alloc] initWithHostByes:dHostBytes name:tableName chipCase:chipCase];
        [_player notifyTableFound:discoveredTable loadedGame:loadedGame];
    }
    
}

-(void) notifyGameConnected:(NSString*)msg {
    
    
    int startIndex=(int)[msg rangeOfString:@"<TABLE_NAME>"].location+(int)[@"<TABLE_NAME>" length];
    int len=(int)[msg rangeOfString:@"<TABLE_NAME/>"].location-startIndex;
    NSString* tableName=[msg substringWithRange:NSMakeRange(startIndex,len)];
    
    startIndex=(int)[msg rangeOfString:@"<GAME_KEY>"].location+(int)[@"<GAME_KEY>" length];
    len=(int)[msg rangeOfString:@"<GAME_KEY/>"].location-startIndex;
    game_key=[msg substringWithRange:NSMakeRange(startIndex,len)];
    tableConnected=YES;
    
    [_player notifyConnectResult:YES tableName:tableName];
    
}

-(void) notifyConnectFailed {
    [_player notifyConnectResult:NO tableName:@""];
}

-(void) parseGameMessage:(NSString*)msg {
    CCLOG(@"DPCPlayerNetwork - parseGameMessage: %@",msg);
    BOOL resendReply=NO;
    if ([msg rangeOfString:@"<RESEND>"].location != NSNotFound &&
        [msg rangeOfString:@"<RESEND/>"].location != NSNotFound ) {
        int startIndex=(int)[msg rangeOfString:@"<RESEND>"].location+(int)[@"<RESEND>" length];
        int len=(int)[msg rangeOfString:@"<RESEND/>"].location-startIndex;
        msg=[msg substringWithRange:NSMakeRange(startIndex,len)];
        if ([msg isEqualToString:lastCommand]&&(lastReply!=nil)) {
            resendReply=YES;
        }
    }
    if ([msg rangeOfString:@"<SETUP_INFO>"].location != NSNotFound &&
        [msg rangeOfString:@"<SETUP_INFO/>"].location != NSNotFound ) {
        [playerNetworkService sendToHost:@"<DPC_SETUP_ACK/>"];
        if (!resendReply) {
            [self setLastCommand:msg];
            
            int startIndex=(int)[msg rangeOfString:@"<COLOR>"].location+(int)[@"<COLOR>" length];
            int len=(int)[msg rangeOfString:@"<COLOR/>"].location-startIndex;
            int color=[[msg substringWithRange:NSMakeRange(startIndex,len)] intValue];
            
            startIndex=(int)[msg rangeOfString:@"<WIN>"].location+(int)[@"<WIN>" length];
            len=(int)[msg rangeOfString:@"<WIN/>"].location-startIndex;
            NSString* setupString=[msg substringWithRange:NSMakeRange(startIndex,len)];
            [_player setupChips:[DPCChipStack parseStack:setupString] color:color];
        }
    } else if ([msg rangeOfString:@"<YOUR_BET>"].location != NSNotFound &&
         [msg rangeOfString:@"<YOUR_BET/>"].location != NSNotFound ) {
        if (resendReply) {
            [self resendLast];
        } else {
            [self setLastCommand:msg];
            
            int startIndex=(int)[msg rangeOfString:@"<STAKE>"].location+(int)[@"<STAKE>" length];
            int len=(int)[msg rangeOfString:@"<STAKE/>"].location-startIndex;
            int betStake=[[msg substringWithRange:NSMakeRange(startIndex,len)] intValue];
            
            startIndex=(int)[msg rangeOfString:@"<FOLD_ENABLED>"].location+(int)[@"<FOLD_ENABLED>" length];
            len=(int)[msg rangeOfString:@"<FOLD_ENABLED/>"].location-startIndex;
            BOOL foldEnabled=[[msg substringWithRange:NSMakeRange(startIndex,len)] boolValue];
            
            startIndex=(int)[msg rangeOfString:@"<MESSAGE>"].location+(int)[@"<MESSAGE>" length];
            len=(int)[msg rangeOfString:@"<MESSAGE/>"].location-startIndex;
            NSString* message=[msg substringWithRange:NSMakeRange(startIndex,len)];
            
            startIndex=(int)[msg rangeOfString:@"<MESSAGE_STATE_CHANGE>"].location+(int)[@"<MESSAGE_STATE_CHANGE>" length];
            len=(int)[msg rangeOfString:@"<MESSAGE_STATE_CHANGE/>"].location-startIndex;
            NSString* messageStateChange=[msg substringWithRange:NSMakeRange(startIndex,len)];
            
            if ([messageStateChange length]==0) {
                [_player promptMove:betStake foldEnabled:foldEnabled message:message];
            } else {
                [_player promptStateChange:messageStateChange stake:betStake foldEnabled:foldEnabled message:message];
            }
        }
    } else if ([msg rangeOfString:@"<DPC_DEALER/>"].location != NSNotFound ) {
        [_player setDealer:YES];
    }  else if ([msg rangeOfString:@"<DPC_RECALL_DEALER/>"].location != NSNotFound ) {
        [_player setDealer:NO];
    }  else if ([msg rangeOfString:@"<WIN>"].location != NSNotFound &&
                [msg rangeOfString:@"<WIN/>"].location != NSNotFound ) {
        [playerNetworkService sendToHost:@"<DPC_WIN_ACK/>"];
        if (!resendReply) {
            [self setLastCommand:msg];
            int startIndex=(int)[msg rangeOfString:@"<WIN>"].location+(int)[@"<WIN>" length];
            int len=(int)[msg rangeOfString:@"<WIN/>"].location-startIndex;
            NSString* chipString=[msg substringWithRange:NSMakeRange(startIndex,len)];
            [_player doWin:[DPCChipStack parseStack:chipString]];
        }
    } else if ([msg rangeOfString:@"<SHOW_CONNECTION/>"].location != NSNotFound ) {
        [_player showConnection];
    }  else if ([msg rangeOfString:@"<HIDE_CONNECTION/>"].location != NSNotFound ) {
        [_player hideConnection];
    }  else if ([msg rangeOfString:@"<TAG_WAIT_NEXT_HAND/>"].location != NSNotFound ) {
        [_player notifyWaitNextHand];
    } else if ([msg rangeOfString:@"<GOODBYE/>"].location != NSNotFound ) {
        [playerNetworkService sendToHost:@"<DPC_GOODBYE_ACK/>"];
        if (!resendReply) {
            [self setLastCommand:msg];
            [self leaveTable];
            [_player notifyBootedByHost];
        }
    } else if ([msg rangeOfString:@"<TEXT_MESSAGE>"].location != NSNotFound &&
               [msg rangeOfString:@"<TEXT_MESSAGE/>"].location != NSNotFound ) {
        int startIndex=(int)[msg rangeOfString:@"<TEXT_MESSAGE>"].location+(int)[@"<TEXT_MESSAGE>" length];
        int len=(int)[msg rangeOfString:@"<TEXT_MESSAGE/>"].location-startIndex;
        NSString* textMessage=[msg substringWithRange:NSMakeRange(startIndex,len)];
        [_player textMessage:textMessage];
    } else if ([msg rangeOfString:@"<STATUS_MENU_UPDATE>"].location != NSNotFound &&
               [msg rangeOfString:@"<STATUS_MENU_UPDATE/>"].location != NSNotFound ) {
        int startIndex=(int)[msg rangeOfString:@"<STATUS_MENU_UPDATE>"].location+(int)[@"<STATUS_MENU_UPDATE>" length];
        int len=(int)[msg rangeOfString:@"<STATUS_MENU_UPDATE/>"].location-startIndex;
        NSString* statusMenuMsg=[msg substringWithRange:NSMakeRange(startIndex,len)];
        NSMutableArray* playerList=[NSMutableArray array];
        NSString* buffer=statusMenuMsg;
        while ([buffer rangeOfString:@"<HOST_NAME>"].location != NSNotFound &&
               [buffer rangeOfString:@"<AMOUNT/>"].location != NSNotFound) {
            startIndex=(int)[buffer rangeOfString:@"<HOST_NAME>"].location+(int)[@"<HOST_NAME>" length];
            len=(int)[buffer rangeOfString:@"<HOST_NAME/>"].location-startIndex;
            NSString* hostName=[buffer substringWithRange:NSMakeRange(startIndex,len)];
            startIndex=(int)[buffer rangeOfString:@"<PLAYER_NAME>"].location+(int)[@"<PLAYER_NAME>" length];
            len=(int)[buffer rangeOfString:@"<PLAYER_NAME/>"].location-startIndex;
            NSString* playerName_=[buffer substringWithRange:NSMakeRange(startIndex,len)];
            startIndex=(int)[buffer rangeOfString:@"<AMOUNT>"].location+(int)[@"<AMOUNT>" length];
            len=(int)[buffer rangeOfString:@"<AMOUNT/>"].location-startIndex;
            int amount=[[buffer substringWithRange:NSMakeRange(startIndex,len)] intValue];
            DPCPlayerEntry *thisEntry=[[DPCPlayerEntry alloc] initWithHostName:hostName playerName:playerName_ amount:amount];
            [playerList addObject:thisEntry];
            int endIndex=(int)[buffer rangeOfString:@"<AMOUNT/>"].location+(int)[@"<AMOUNT/>" length];
            if (buffer.length>endIndex) {
                buffer=[buffer substringFromIndex:(endIndex)];
            } else {
                buffer=@"";
            }
        }
        [_player syncStatusMenu:playerList];
    } else if ([msg rangeOfString:@"<SENDING_BELL/>"].location != NSNotFound) {
        [_player doBell];
    } else if ([msg rangeOfString:@"<TAG_CANCEL_MOVE/>"].location != NSNotFound) {
        [_player cancelMove];
    } else if ([msg rangeOfString:@"<ENABLE_NUDGE>"].location != NSNotFound &&
               [msg rangeOfString:@"<ENABLE_NUDGE/>"].location != NSNotFound ) {
        int startIndex=(int)[msg rangeOfString:@"<ENABLE_NUDGE>"].location+(int)[@"<ENABLE_NUDGE>" length];
        int len=(int)[msg rangeOfString:@"<ENABLE_NUDGE/>"].location-startIndex;
        NSString* hostName=[msg substringWithRange:NSMakeRange(startIndex,len)];
        [_player enableNudge:hostName];
    } else if ([msg rangeOfString:@"<DISABLE_NUDGE/>"].location != NSNotFound) {
        [_player disableNudge];
    }
}

-(void) setLastCommand:(NSString*)lastCommand_ {
    lastCommand=lastCommand_;
    lastReply=nil;
}

-(void) resendLast {
    [playerNetworkService sendToHost:lastReply];
}

@end
