//
//  DPCPlayerNetwork.m
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 9/04/14.
//
//

#import "cocos2d.h"
#import "DPCGame.h"
#import "DPCLogger.h"
#import "DPCPlayerNetwork.h"
#import "DPCPlayerNetworkService.h"
#import "DPCThisPlayer.h"
#import "DPCChipCase.h"
#import "DPCChipStack.h"
#import "DPCPlayerEntry.h"
#import "DPCMovePrompt.h"

NSString *const PLAYER_TAG_PLAYER_NAME_NEG_OPEN = @"<PLAYER_NAME_NEG>";
NSString *const PLAYER_TAG_PLAYER_NAME_NEG_CLOSE = @"<PLAYER_NAME_NEG/>";
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
NSString *const PLAYER_TAG_SEND_BELL_OPEN = @"<BELL_OPEN>";
NSString *const PLAYER_TAG_SEND_BELL_CLOSE = @"<BELL_OPEN/>";

@interface DPCPlayerNetwork () {
	BOOL wifiEnabled;
	BOOL tableConnected;
	BOOL doingHostDiscover;
	NSData* hostBytes;
	NSString* playerName;
	DPCPlayerNetworkService* playerNetworkService;
}

@end

@implementation DPCPlayerNetwork

static const NSString* LOG_TAG=@"DPCPlayerNetwork";

-(id) init {
    if (self=[super init]) {
        playerNetworkService=[[DPCPlayerNetworkService alloc]init];
        playerNetworkService.playerNetwork=self;
        tableConnected=NO;
		doingHostDiscover=NO;
		hostBytes=nil;
		playerName=@"";
        
        [self setWifiEnabled:NO];
    }
    return self;
}

-(void)dealloc {
    _player=nil;
    playerNetworkService=nil;
}

-(void) onStart {
    [DPCLogger log:LOG_TAG msg:@"onStart"];
    if (wifiEnabled&&doingHostDiscover) {
        [self spawnDiscover];
    }
}

-(void) onStop {
    [DPCLogger log:LOG_TAG msg:@"onStop"];
    [playerNetworkService stopDiscover];
    [playerNetworkService stopListen];
    if (tableConnected) {
        [playerNetworkService disconnectCurrentGame];
        [_player notifyConnectionLost];
    }
}

-(void) startRequestGames {
    [DPCLogger log:LOG_TAG msg:@"startRequestGames"];
    if (wifiEnabled&&!doingHostDiscover) {
        [self spawnDiscover];
    }
    doingHostDiscover=YES;
}

-(void) stopRequestGames {
    [DPCLogger log:LOG_TAG msg:@"stopRequestGames"];
    [playerNetworkService stopDiscover];
    doingHostDiscover=NO;
}

-(void) requestInvitation:(NSData*) hostBytes {
    
}

-(void) stopListen {
    [DPCLogger log:LOG_TAG msg:@"stopListen"];
    [playerNetworkService stopListen];
    if (tableConnected) {
        [playerNetworkService disconnectCurrentGame];
    }
}

-(void) spawnDiscover {
    [DPCLogger log:LOG_TAG msg:@"spawnDiscover"];
    NSString* playerAnnounceStr=[NSString stringWithFormat:@"%@%@%@", PLAYER_TAG_PLAYER_NAME_NEG_OPEN,playerName,PLAYER_TAG_PLAYER_NAME_NEG_CLOSE];
    [playerNetworkService startDiscover:playerAnnounceStr];
}

-(void) spawnConnect:(NSData*)hostBytes_ playerName:(NSString*)playerName_ azimuth:(int)azimuth chipNumbers:(NSArray*)chipNumbers {
    [DPCLogger log:LOG_TAG msg:@"spawnConnect"];
    NSString* playerSetupString=[NSString stringWithFormat:@"%@%@%@",PLAYER_TAG_PLAYER_NAME_NEG_OPEN,playerName_,PLAYER_TAG_PLAYER_NAME_NEG_CLOSE];
    playerSetupString=[NSString stringWithFormat:@"%@%@%d%@",playerSetupString,PLAYER_TAG_AZIMUTH_OPEN,azimuth,PLAYER_TAG_AZIMUTH_CLOSE];
    if (chipNumbers!=nil) {
        int thisChipNumber=[[chipNumbers objectAtIndex:CHIP_CASE_CHIP_A] intValue];
        playerSetupString=[NSString stringWithFormat:@"%@%@%d%@",playerSetupString,PLAYER_TAG_NUM_A_OPEN,thisChipNumber,PLAYER_TAG_NUM_A_CLOSE];
        thisChipNumber=[[chipNumbers objectAtIndex:CHIP_CASE_CHIP_B] intValue];
        playerSetupString=[NSString stringWithFormat:@"%@%@%d%@",playerSetupString,PLAYER_TAG_NUM_B_OPEN,thisChipNumber,PLAYER_TAG_NUM_B_CLOSE];
        thisChipNumber=[[chipNumbers objectAtIndex:CHIP_CASE_CHIP_C] intValue];
        playerSetupString=[NSString stringWithFormat:@"%@%@%d%@",playerSetupString,PLAYER_TAG_NUM_C_OPEN,thisChipNumber,PLAYER_TAG_NUM_C_CLOSE];
    }
    [playerNetworkService playerConnect:hostBytes_ connectString:playerSetupString];
}

-(void) setWifiEnabled:(BOOL)en {
    [DPCLogger log:LOG_TAG msg:@"setWifiEnabled"];
    wifiEnabled=en;
}

-(BOOL) validateTableInfo:(NSString*)msg {
    [DPCLogger log:LOG_TAG msg:@"validateTableInfo"];
    if ([msg rangeOfString:@"<TABLE_NAME>"].location != NSNotFound &&
        [msg rangeOfString:@"<TABLE_NAME/>"].location != NSNotFound ) {
        return YES;
    } else {
        return NO;
    }
}

-(BOOL) validateTableACK:(NSString*)ackMsg {
    [DPCLogger log:LOG_TAG msg:@"validateTableACK"];
    if ([ackMsg rangeOfString:@"<TAG_GAME_ACK/>"].location != NSNotFound) {
        return YES;
    } else {
        return NO;
    }
}

-(void) requestConnect:(DPCDiscoveredTable*)table azimuth:(int)azimuth chipNumbers:(NSArray*)chipNumbers {
    [DPCLogger log:LOG_TAG msg:@"requestConnect"];
    if (wifiEnabled) {
        hostBytes=table.hostBytes;
        [self spawnConnect:hostBytes playerName:playerName azimuth:azimuth chipNumbers:chipNumbers];
    } else {
        [_player notifyConnectResult:NO tableName:@""];
    }
}

-(void) setName:(NSString*)playerName_ {
    [DPCLogger log:LOG_TAG msg:@"setName"];
    playerName=playerName_;
}

-(void) submitMove:(int)move chipString:(NSString*)chipString {
    [DPCLogger log:LOG_TAG msg:@"submitMove"];
    if (wifiEnabled) {
        NSString* msg=@"<SUBMIT_MOVE>";
        msg=[NSString stringWithFormat:@"%@%@%d%@",msg,@"<MOVE>",move,@"<MOVE/>"];
        msg=[NSString stringWithFormat:@"%@%@%@%@",msg,@"<CHIPS>",chipString,@"<CHIPS/>"];
        msg=[NSString stringWithFormat:@"%@%@",msg,@"<SUBMIT_MOVE/>"];
        [playerNetworkService sendToHost:msg];
    }
}

-(void) leaveTable {
    [DPCLogger log:LOG_TAG msg:@"leaveTable"];
    if (wifiEnabled) {
        tableConnected=false;
        [playerNetworkService leaveTable:@"<GOODBYE/>"];
    }
}

-(void) sendBell:(NSString*) hostName {
    NSString* msg=[NSString stringWithFormat:@"%@%@%@", @"<BELL_OPEN>",hostName,@"<BELL_OPEN/>"];
    [playerNetworkService sendToHost:msg];
}

-(void) discoverResponseRxd:(NSData *)hostBytes_ rxMsg:(NSString *)rxMsg {
    [DPCLogger log:LOG_TAG msg:@"discoverResponseRxd"];
    if ([rxMsg rangeOfString:@"<TABLE_NAME>"].location != NSNotFound &&
        [rxMsg rangeOfString:@"<VAL_C/>"].location != NSNotFound ) {
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
        
        BOOL connectNow=[rxMsg rangeOfString:@"<TAG_CONNECT_NOW/>"].location!=NSNotFound;
        
        if (_player!=nil) {
            DPCDiscoveredTable *discoveredTable=[[DPCDiscoveredTable alloc] initWithHostByes:hostBytes_ name:tableName chipCase:chipCase];
            [_player notifyTableFound:discoveredTable connectNow:connectNow];
        }
    }
    
}

-(void) notifyGameConnected:(NSString*)msg {
    [DPCLogger log:LOG_TAG msg:@"notifyGameConnected"];
    int startIndex=(int)[msg rangeOfString:@"<TABLE_NAME>"].location+(int)[@"<TABLE_NAME>" length];
    int len=(int)[msg rangeOfString:@"<TABLE_NAME/>"].location-startIndex;
    NSString* tableName=[msg substringWithRange:NSMakeRange(startIndex,len)];
    tableConnected=YES;
    [_player notifyConnectResult:YES tableName:tableName];
    [playerNetworkService startListen];
}

-(void) notifyConnectFailed {
    [DPCLogger log:LOG_TAG msg:@"notifyConnectFailed"];
    [_player notifyConnectResult:NO tableName:@""];
}

-(void) notifyConnectionLost {
    [DPCLogger log:LOG_TAG msg:@"notifyConnectionLost"];
    [_player notifyConnectionLost];
}

-(void) parseGameMessage:(NSString*)msg {
    [DPCLogger log:LOG_TAG msg:[NSString stringWithFormat:@"parseGameMessage: %@",msg]];
    if (!tableConnected) {
        // throw message away
    } else if ([msg rangeOfString:@"<COLOR>"].location != NSNotFound &&
        [msg rangeOfString:@"<COLOR/>"].location != NSNotFound ) {
        int startIndex=(int)[msg rangeOfString:@"<COLOR>"].location+(int)[@"<COLOR>" length];
        int len=(int)[msg rangeOfString:@"<COLOR/>"].location-startIndex;
        int color=[[msg substringWithRange:NSMakeRange(startIndex,len)] intValue];
        _player.color=color;
    } else if ([msg rangeOfString:@"<STATUS_MENU_UPDATE>"].location != NSNotFound &&
               [msg rangeOfString:@"<STATUS_MENU_UPDATE/>"].location != NSNotFound ) {
        int startIndex=(int)[msg rangeOfString:@"<STATUS_MENU_UPDATE>"].location+(int)[@"<STATUS_MENU_UPDATE>" length];
        int len=(int)[msg rangeOfString:@"<STATUS_MENU_UPDATE/>"].location-startIndex;
        NSString* statusMenuMsg=[msg substringWithRange:NSMakeRange(startIndex,len)];
        NSMutableArray* playerList=[NSMutableArray array];
        NSString* buffer=statusMenuMsg;
        while ([buffer rangeOfString:@"<PLAYER_NAME>"].location != NSNotFound &&
               [buffer rangeOfString:@"<AMOUNT/>"].location != NSNotFound) {
            int startIndex=(int)[buffer rangeOfString:@"<PLAYER_NAME>"].location+(int)[@"<PLAYER_NAME>" length];
            int len=(int)[buffer rangeOfString:@"<PLAYER_NAME/>"].location-startIndex;
            NSString* playerName_=[buffer substringWithRange:NSMakeRange(startIndex,len)];
            startIndex=(int)[buffer rangeOfString:@"<AMOUNT>"].location+(int)[@"<AMOUNT>" length];
            len=(int)[buffer rangeOfString:@"<AMOUNT/>"].location-startIndex;
            int amount=[[buffer substringWithRange:NSMakeRange(startIndex,len)] intValue];
            DPCPlayerEntry *thisEntry=[[DPCPlayerEntry alloc] initWithPlayerName:playerName_ amount:amount];
            [playerList addObject:thisEntry];
            int endIndex=(int)[buffer rangeOfString:@"<AMOUNT/>"].location+(int)[@"<AMOUNT/>" length];
            if (buffer.length>endIndex) {
                buffer=[buffer substringFromIndex:(endIndex)];
            } else {
                buffer=@"";
            }
        }
        [_player syncStatusMenu:playerList];
    }  else if ([msg rangeOfString:@"<TAG_WAIT_NEXT_HAND/>"].location != NSNotFound ) {
        [_player notifyWaitNextHand];
    } else if ([msg rangeOfString:@"<YOUR_BET>"].location != NSNotFound &&
               [msg rangeOfString:@"<YOUR_BET/>"].location != NSNotFound ) {
        
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
        
        DPCMovePrompt* thisMovePrompt=[[DPCMovePrompt alloc] initWithStake:betStake foldEnabled:foldEnabled message:message messageStateChange:messageStateChange];
        
        startIndex=(int)[msg rangeOfString:@"<TAG_SYNC_CHIPS_WITH_MOVE>"].location+(int)[@"<TAG_SYNC_CHIPS_WITH_MOVE>" length];
        len=(int)[msg rangeOfString:@"<TAG_SYNC_CHIPS_WITH_MOVE/>"].location-startIndex;
        int chipAmount=[[msg substringWithRange:NSMakeRange(startIndex,len)] intValue];
        [_player syncChipsToAmount:chipAmount];
        [_player promptMove:thisMovePrompt];
    } else if ([msg rangeOfString:@"<TAG_SYNC_CHIPS>"].location != NSNotFound &&
               [msg rangeOfString:@"<TAG_SYNC_CHIPS/>"].location != NSNotFound ) {
        int startIndex=(int)[msg rangeOfString:@"<TAG_SYNC_CHIPS>"].location+(int)[@"<TAG_SYNC_CHIPS>" length];
        int len=(int)[msg rangeOfString:@"<TAG_SYNC_CHIPS/>"].location-startIndex;
        int chipAmount=[[msg substringWithRange:NSMakeRange(startIndex,len)] intValue];
        [_player syncChipsToAmount:chipAmount];
    } else if ([msg rangeOfString:@"<WIN>"].location != NSNotFound &&
                [msg rangeOfString:@"<WIN/>"].location != NSNotFound ) {
        int startIndex=(int)[msg rangeOfString:@"<WIN>"].location+(int)[@"<WIN>" length];
        int len=(int)[msg rangeOfString:@"<WIN/>"].location-startIndex;
        NSString* chipString=[msg substringWithRange:NSMakeRange(startIndex,len)];
        [_player doWin:[DPCChipStack parseStack:chipString]];
    } else if ([msg rangeOfString:@"<DPC_DEALER/>"].location != NSNotFound ) {
        [_player setDealer:YES];
    }  else if ([msg rangeOfString:@"<DPC_RECALL_DEALER/>"].location != NSNotFound ) {
        [_player setDealer:NO];
    } else if ([msg rangeOfString:@"<SHOW_CONNECTION/>"].location != NSNotFound ) {
        [_player showConnection];
    }  else if ([msg rangeOfString:@"<HIDE_CONNECTION/>"].location != NSNotFound ) {
        [_player hideConnection];
    } else if ([msg rangeOfString:@"<GOODBYE/>"].location != NSNotFound ) {
        [self leaveTable];
        [_player notifyBootedByHost];
    } else if ([msg rangeOfString:@"<TEXT_MESSAGE>"].location != NSNotFound &&
               [msg rangeOfString:@"<TEXT_MESSAGE/>"].location != NSNotFound ) {
        int startIndex=(int)[msg rangeOfString:@"<TEXT_MESSAGE>"].location+(int)[@"<TEXT_MESSAGE>" length];
        int len=(int)[msg rangeOfString:@"<TEXT_MESSAGE/>"].location-startIndex;
        NSString* textMessage=[msg substringWithRange:NSMakeRange(startIndex,len)];
        [_player textMessage:textMessage];
    } else if ([msg rangeOfString:@"<SENDING_BELL/>"].location != NSNotFound) {
        [_player doBell];
    } else if ([msg rangeOfString:@"<TAG_CANCEL_MOVE/>"].location != NSNotFound) {
        [_player cancelMove];
    } else if ([msg rangeOfString:@"<ENABLE_NUDGE>"].location != NSNotFound &&
               [msg rangeOfString:@"<ENABLE_NUDGE/>"].location != NSNotFound ) {
        int startIndex=(int)[msg rangeOfString:@"<ENABLE_NUDGE>"].location+(int)[@"<ENABLE_NUDGE>" length];
        int len=(int)[msg rangeOfString:@"<ENABLE_NUDGE/>"].location-startIndex;
        NSString* name=[msg substringWithRange:NSMakeRange(startIndex,len)];
        [_player enableNudge:name];
    } else if ([msg rangeOfString:@"<DISABLE_NUDGE/>"].location != NSNotFound) {
        [_player disableNudge];
    }
}

@end
