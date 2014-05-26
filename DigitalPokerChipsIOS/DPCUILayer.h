//
//  UILayer.h
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 5/04/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "DPCUIInput.h"
#import "DPCHomeMenu.h"
#import "DPCDialogWindow.h"
#import "DPCBuyinDialog.h"
#import "DPCLeaveTableDialog.h"
#import "DPCTextLabel.h"
#import "DPCTableStatusMenu.h"

@interface DPCUILayer : CCNode {
    
}

@property DPCUIInput* input;
@property DPCHomeMenu* homeMenu;

@property DPCSprite* backButton;
@property DPCSprite* enterNameDoneButton;
@property DPCTextLabel* enterName1Label;
@property DPCTextLabel* enterName2Label;
@property DPCTextLabel* searchingLabel;
@property DPCTextLabel* wifiLabel;
@property DPCTextLabel* stateChangePrompt;
@property DPCTextLabel* waitNextHandLabel;
@property DPCTextLabel* reconnect1Label;
@property DPCTextLabel* reconnect2Label;

@property DPCSprite* foldButton;

@property DPCTextLabel* playerPrompt;

@property DPCDialogWindow* dialogWindow;

@property DPCBuyinDialog* buyinDialog;
@property DPCLeaveTableDialog* leaveTableDialog;

@property DPCTableStatusMenu* tableStatusMenu;

-(void) resize:(CGSize)size;
-(void) startHome;
-(void) stopHome;
-(void) joinSelected;
-(void) notifyAtPlayerPosition;
-(void) notifyLeftPlayerPosition;
-(void)startEnterPlayerName;
-(void)stopEnterPlayerName;
-(void) startSearchForGames;
-(void) stopSearchForGames;
-(void) startBuyin:(NSString*)tableName;
-(void) stopBuyin;
-(void) startLeaveTableDialog:(NSString*)tableName;
-(void) stopLeaveTableDialog;
-(void)startWifiPrompt;
-(void)stopWifiPrompt;
-(void)hideTextMessage;
-(void)showTextMessage:(NSString*)message;
-(void)promptStateChange:(NSString*) messageStateChange;
-(void)stateChangeACKed;
-(void)startWaitNextHand;
-(void)stopWaitNextHand;
-(void)startReconnect;
-(void)stopReconnect;
-(void)showTableStatusMenu:(NSString*)tableName;
-(void)openTableStatusMenu;
-(void)closeTableStatusMenu;
-(void)removeTableStatusMenu;

@end
