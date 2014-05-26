//
//  DPCThisPlayer.h
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 8/04/14.
//
//

#import <Foundation/Foundation.h>

#import "DPCDiscoveredTable.h"
#import "DPCChipStack.h"
#import "DPCTextLabel.h"
#import "DPCMovePrompt.h"

@class CCTextField;
@class DPCWorldLayer;
@class DPCSprite;

extern NSString *const CONN_NONE;
extern NSString *const CONN_IDLE;
extern NSString *const CONN_SEARCH_HOLDOFF;
extern NSString *const CONN_SEARCHING;
extern NSString *const CONN_BUYIN;
extern NSString *const CONN_CONNECTING;
extern NSString *const CONN_CONNECTED;
extern NSString *const CONN_POLL_RECONNECT;
extern NSString *const CONN_CONNECTED_NO_WIFI;

@interface DPCThisPlayer : NSObject

@property NSString* connectivityStatus;
@property BOOL wifiEnabled;
@property BOOL sendingJoinToken;
@property int color;

@property UITextField* nameField;
@property DPCTextLabel* nameLabel;
@property DPCSprite* plaqueRect;
@property NSMutableArray* chipNumbers;
@property NSString* tableName;

@property NSArray* defaultChipNums;

@property (nonatomic) DPCChip* pickedUpChip;
@property NSMutableArray* mainStacks;
@property DPCChipStack* bettingStack;
@property DPCChipStack* betStack;
@property DPCChipStack* cancellingStack;
@property DPCChipStack* cancelStack;
@property DPCSprite* joinToken;
@property DPCSprite* checkButton;
@property DPCSprite* dealerButton;
@property DPCSprite* connectionBlob;

-(id) initWithWorldLayer:(DPCWorldLayer*)mWL;

-(void)setWorldWidth:(int)worldWidth height:(int)worldHeight;
-(void)setPositions:(int)worldWidth height:(int)worldHeight;
-(void)animate:(float)delta;
-(void)collisionDetector;
-(void)notifyLeftNamePosition;
-(void)notifyLeftPlayerPosition;
-(void)notifyAtPlayerPosition;
-(void)notifyAtNamePosition;
-(void)nameDone;
-(BOOL)backPressed;
-(void)updatePlayerName;
-(void)notifyTableFound:(DPCDiscoveredTable*)table connectNow:(BOOL)connectNow;
-(void)buyinDialogDone:(NSMutableArray*)chipNumbers;
-(void)leaveDialogDone:(BOOL)actionCompleted;
-(void)setPickedUpChip:(DPCChip*)newPUC;
-(void)doPickedUpChipDropped;
-(void)doPickedUpChipFlung:(CGPoint)velocity;
-(void)doFold;
-(void)doCheck;
-(void)wifiOn;
-(void)wifiOff;
-(void)onStart;
-(void)onStop;
-(void)notifyConnectResult:(BOOL)result tableName:(NSString*) tableName;
-(void)notifyConnectionLost;
-(void)promptMove:(DPCMovePrompt*)movePrompt;
-(void)stateChangeACKed;
-(void)bellButtonPressed;
-(void)setDealer:(BOOL)dealer;
-(void)doWin:(DPCChipStack*)winStack;
-(void)showConnection;
-(void)hideConnection;
-(void)notifyBootedByHost;
-(void)notifyWaitNextHand;
-(void)syncStatusMenu:(NSMutableArray*)playerList;
-(void)textMessage:(NSString*)message;
-(void)doBell;
-(void)cancelMove;
-(void)enableNudge:(NSString*)hostName;
-(void)disableNudge;
-(void)syncChipsToAmount:(int)newChipAmount;

@end