//
//  DPCPlayerNetwork.h
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 9/04/14.
//
//

#import <Foundation/Foundation.h>
#import "DPCThisPlayer.h"
#import "DPCDiscoveredTable.h"

extern NSString *const PLAYER_TAG_PLAYER_NAME_NEG_OPEN;
extern NSString *const PLAYER_TAG_PLAYER_NAME_NEG_CLOSE;
extern NSString *const PLAYER_TAG_SUBMIT_MOVE_OPEN;
extern NSString *const PLAYER_TAG_SUBMIT_MOVE_CLOSE;
extern NSString *const PLAYER_TAG_MOVE_OPEN;
extern NSString *const PLAYER_TAG_MOVE_CLOSE;
extern NSString *const PLAYER_TAG_CHIPS_OPEN;
extern NSString *const PLAYER_TAG_CHIPS_CLOSE;
extern NSString *const PLAYER_TAG_AZIMUTH_OPEN;
extern NSString *const PLAYER_TAG_AZIMUTH_CLOSE;
extern NSString *const PLAYER_TAG_NUM_A_OPEN;
extern NSString *const PLAYER_TAG_NUM_A_CLOSE;
extern NSString *const PLAYER_TAG_NUM_B_OPEN;
extern NSString *const PLAYER_TAG_NUM_B_CLOSE;
extern NSString *const PLAYER_TAG_NUM_C_OPEN;
extern NSString *const PLAYER_TAG_NUM_C_CLOSE;
extern NSString *const PLAYER_TAG_GOODBYE;
extern NSString *const PLAYER_TAG_RECONNECT_FAILED;
extern NSString *const PLAYER_TAG_SEND_BELL_OPEN;
extern NSString *const PLAYER_TAG_SEND_BELL_CLOSE;

@interface DPCPlayerNetwork : NSObject

@property DPCThisPlayer* player;

-(void) onStart;
-(void) onStop;
-(void) startRequestGames;
-(void) stopRequestGames;
-(void) requestInvitation:(NSData*) hostBytes;
-(void) setWifiEnabled:(BOOL)en;
-(BOOL) validateTableInfo:(NSString*)msg;
-(BOOL) validateTableACK:(NSString*)ackMsg;
-(void) requestConnect:(DPCDiscoveredTable*)table azimuth:(int)azimuth chipNumbers:(NSArray*)chipNumbers;
-(void) stopListen;
-(void) setName:(NSString*)playerName;
-(void) submitMove:(int)move chipString:(NSString*)chipString;
-(void) leaveTable;
-(void) sendBell:(NSString*) hostName;
-(void) discoverResponseRxd:(NSData*) hostBytes rxMsg:(NSString*)rxMsg;
-(void) notifyGameConnected:(NSString*)msg;
-(void) notifyConnectFailed;
-(void) notifyConnectionLost;
-(void) parseGameMessage:(NSString*)msg;

@end
