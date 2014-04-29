//
//  UILayer.m
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 5/04/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "DPCUILayer.h"
#import "DPCHomeMenu.h"
#import "DPCUIInput.h"
#import "DPCTextLabel.h"

#import "DPCGame.h"
@class DPCWorldLayer;
#import "DPCTextFactory.h"
#import "DPCClosedDialog.h"
#import "DPCPlayerEntry.h"

@interface DPCUILayer () {
    DPCClosedDialog* buyinDialogSmall;
    DPCClosedDialog* leaveTableDialogSmall;
    
    BOOL showPlayerPrompt;
    CGPoint posPlayerPromptOffscreen;
    CGPoint posPlayerPromptOnscreen;
}
@end

@implementation DPCUILayer

-(id) init {
    if (self=[super init]) {
        _input=[[DPCUIInput alloc] init];
        
        showPlayerPrompt=NO;
        
        self.userInteractionEnabled=TRUE;
        self.contentSize=[[CCDirector sharedDirector]viewSize];
        
        _playerPrompt= [DPCTextLabel node];
        _playerPrompt.color=[CCColor colorWithCcColor3b:ccWHITE];
        [self addChild:_playerPrompt];
        
        _homeMenu=[DPCHomeMenu node];
        [self addChild:_homeMenu];
        _backButton=[DPCSprite DPCSpriteWithFile:@"back.png"];
        _backButton.touchable=NO;
        _backButton.opacity=0;
        [self addChild:_backButton];
        _enterNameDoneButton=[DPCSprite DPCSpriteWithFile:@"ok_button.png"];
        _enterNameDoneButton.touchable=NO;
        _enterNameDoneButton.opacity=0;
        [self addChild:_enterNameDoneButton];
        _enterName1Label= [DPCTextLabel node];
        _enterName1Label.string=@"Enter Your";
        _enterName1Label.color=[CCColor colorWithCcColor3b:ccWHITE];;
        _enterName1Label.fontName=@"SegoePrint";
        _enterName1Label.opacity=0;
        [self addChild:_enterName1Label];
        _enterName2Label= [DPCTextLabel node];
        _enterName2Label.string=@"Name";
        _enterName2Label.color=[CCColor colorWithCcColor3b:ccWHITE];;
        _enterName2Label.fontName=@"SegoePrint";
        _enterName2Label.opacity=0;
        [self addChild:_enterName2Label];
        
        _searchingLabel= [DPCTextLabel node];
        _searchingLabel.string=@"Searching for Tables";
        _searchingLabel.color=[CCColor colorWithCcColor3b:ccWHITE];;
        _searchingLabel.fontName=@"SegoePrint";
        _searchingLabel.opacity=0;
        [self addChild:_searchingLabel];
        _wifiLabel= [DPCTextLabel node];
        _wifiLabel.string=@"Please Connect to WiFi";
        _wifiLabel.color=[CCColor colorWithCcColor3b:ccWHITE];;
        _wifiLabel.fontName=@"SegoePrint";
        _wifiLabel.opacity=0;
        [self addChild:_wifiLabel];
        _stateChangePrompt= [DPCTextLabel node];
        _stateChangePrompt.color=[CCColor colorWithCcColor3b:ccWHITE];;
        _stateChangePrompt.fontName=@"SegoePrint";
        _stateChangePrompt.opacity=0;
        [self addChild:_stateChangePrompt];
        _waitNextHandLabel= [DPCTextLabel node];
        _waitNextHandLabel.string=@"Please Wait for Next Hand";
        _waitNextHandLabel.color=[CCColor colorWithCcColor3b:ccWHITE];;
        _waitNextHandLabel.fontName=@"SegoePrint";
        _waitNextHandLabel.opacity=0;
        [self addChild:_waitNextHandLabel];
        _reconnect1Label= [DPCTextLabel node];
        _reconnect1Label.string=@"Connection Lost";
        _reconnect1Label.color=[CCColor colorWithCcColor3b:ccWHITE];;
        _reconnect1Label.fontName=@"SegoePrint";
        _reconnect1Label.opacity=0;
        [self addChild:_reconnect1Label];
        _reconnect2Label= [DPCTextLabel node];
        _reconnect2Label.string=@"Attempting Reconnect";
        _reconnect2Label.color=[CCColor colorWithCcColor3b:ccWHITE];;
        _reconnect2Label.fontName=@"SegoePrint";
        _reconnect2Label.opacity=0;
        [self addChild:_reconnect2Label];
        
        _foldButton=[DPCSprite DPCSpriteWithFile:@"fold_button.png"];
        _foldButton.touchable=NO;
        _foldButton.opacity=0;
        [self addChild:_foldButton];
        
        _tableStatusMenu=[DPCTableStatusMenu node];
        [self addChild:_tableStatusMenu];
        
        _dialogWindow=[DPCDialogWindow DPCSpriteWithFile:@"dialog.png"];
        _dialogWindow.opacity=0;
        [self addChild:_dialogWindow];
        
        _buyinDialog=[DPCBuyinDialog node];
        _buyinDialog.opacity=0;
        [self addChild:_buyinDialog];
        buyinDialogSmall=[[DPCClosedDialog alloc] initWithAttachedWindow:_dialogWindow];
        buyinDialogSmall.opacity=0;
        _leaveTableDialog=[DPCLeaveTableDialog node];
        _leaveTableDialog.opacity=0;
        [self addChild:_leaveTableDialog];
        leaveTableDialogSmall=[[DPCClosedDialog alloc] initWithAttachedWindow:_dialogWindow];
        leaveTableDialogSmall.opacity=0;
        
        
    }
    return self;
}

-(void) resize:(CGSize) size {
    float screenWidth=[[CCDirector sharedDirector] viewSize].width;
    float screenHeight=[[CCDirector sharedDirector] viewSize].height;
    [self setDimensions:screenWidth height:screenHeight];
    [self setPositions:screenWidth height:screenHeight];
}

-(void) setDimensions:(float)screenWidth height:(float)screenHeight {
    [_homeMenu setDimensionsScreenWidth:screenWidth height:screenHeight];
    [_backButton setRadiusX:(int)(screenHeight*0.06f) radiusY:(int)(screenHeight*0.06f)];
    [_enterNameDoneButton setRadiusX:(int)(screenHeight*0.08f) radiusY:(int)(screenHeight*0.08f)];
    _enterName1Label.fontSize=[DPCTextFactory getMaxTextSize:_enterName1Label width:(int)(screenWidth*0.28f) height:(int)(screenHeight*0.3f)];
    _enterName2Label.fontSize=_enterName1Label.fontSize;
    _playerPrompt.string=@"Open River Betting";
    _playerPrompt.fontSize=[DPCTextFactory getMaxTextSize:_playerPrompt width:(int)(screenWidth*0.2f) height:(int)(screenHeight*0.04f)];
    _playerPrompt.string=@"";
    _searchingLabel.fontSize=[DPCTextFactory getMaxTextSize:_searchingLabel width:(int)(screenWidth*0.6f) height:(int)(screenHeight*0.2f)];
    _wifiLabel.fontSize=[DPCTextFactory getMaxTextSize:_searchingLabel width:(int)(screenWidth*0.6f) height:(int)(screenHeight*0.2f)];
    _stateChangePrompt.string=@"Open River Betting";
    _stateChangePrompt.fontSize=[DPCTextFactory getMaxTextSize:_stateChangePrompt width:(int)(screenWidth*0.6f) height:(int)(screenHeight*0.2f)];
    _stateChangePrompt.string=@"";
    _waitNextHandLabel.fontSize=[DPCTextFactory getMaxTextSize:_waitNextHandLabel width:(int)(screenWidth*0.6f) height:(int)(screenHeight*0.2f)];
    _reconnect1Label.fontSize=[DPCTextFactory getMaxTextSize:_reconnect1Label width:(int)(screenWidth*0.6f) height:(int)(screenHeight*0.2f)];
    _reconnect2Label.fontSize=_reconnect1Label.fontSize;
    [_foldButton setRadiusX:(int)(screenHeight*0.15f) radiusY:(int)(screenHeight*0.15f)];
    [buyinDialogSmall setRadiusX:1 radiusY:1];
    [_buyinDialog setRadiusX:(int)(screenHeight*0.6f) radiusY:(int)(screenHeight*0.45f)];
    [leaveTableDialogSmall setRadiusX:1 radiusY:1];
    [_leaveTableDialog setRadiusX:(int)(screenHeight*0.6f) radiusY:(int)(screenHeight*0.45f)];
    //[_tableStatusMenu setRadiusX:(int)(screenWidth*0.16f) radiusY:(int)(screenHeight*0.45f)];
    [_tableStatusMenu setDimensions:CGSizeMake(screenWidth,screenHeight)];
}

-(void) setPositions:(float)screenWidth height:(float)screenHeight {
    [_homeMenu setPositionsScreenLeft:0 top:screenHeight right:screenWidth bottom:0];
    [_backButton setPosition:CGPointMake(0.0f+_backButton.radiusX*1.2f,0.0f+_backButton.radiusY*1.2f)];
    [_enterNameDoneButton setPosition:ccp(screenWidth*0.85f,screenHeight*0.66f)];
    [_enterName1Label setPosition:ccp(screenWidth*0.16f,screenHeight*0.70f)];
    [_enterName2Label setPosition:ccp(screenWidth*0.16f,screenHeight*0.62f)];
    posPlayerPromptOffscreen=ccp(screenWidth*0.8f,screenHeight*1.1f);
    posPlayerPromptOnscreen=ccp(screenWidth*0.8f,screenHeight*0.95f);
    [_searchingLabel setPosition:CGPointMake(screenWidth*0.5f,screenHeight*0.7f)];
    [_wifiLabel setPosition:CGPointMake(screenWidth*0.5f,screenHeight*0.7f)];
    [_stateChangePrompt setPosition:CGPointMake(screenWidth*0.5f,screenHeight*0.7f)];
    [_waitNextHandLabel setPosition:CGPointMake(screenWidth*0.5f,screenHeight*0.7f)];
    [_reconnect1Label setPosition:CGPointMake(screenWidth*0.5f,screenHeight*0.8f)];
    [_reconnect2Label setPosition:CGPointMake(screenWidth*0.5f,screenHeight*0.7f)];
    [_foldButton setPosition:CGPointMake(screenWidth*0.1f,screenHeight*0.76f)];
    
    [buyinDialogSmall setPosition:CGPointMake(screenWidth*0.5f,screenHeight*0.95f)];
    [_buyinDialog setPosition:CGPointMake(screenWidth*0.5f,screenHeight*0.5f)];
    [leaveTableDialogSmall setPosition:CGPointMake(screenWidth*0.5f,screenHeight*0.95f)];
    [_leaveTableDialog setPosition:CGPointMake(screenWidth*0.5f,screenHeight*0.5f)];
    [_tableStatusMenu setPositions:CGSizeMake(screenWidth,screenHeight)];
}

-(void) update:(CCTime)delta {
    
    [_dialogWindow animate:delta];
    [_buyinDialog animate:delta];
    [_leaveTableDialog animate:delta];
    [_backButton animate:delta];
    [_enterNameDoneButton animate:delta];
    [_enterName1Label animate:delta];
    [_enterName2Label animate:delta];
    [_foldButton animate:delta];
    [_searchingLabel animate:delta];
    [_wifiLabel animate:delta];
    [_stateChangePrompt animate:delta];
    [_waitNextHandLabel animate:delta];
    [_reconnect1Label animate:delta];
    [_reconnect2Label animate:delta];
    [_tableStatusMenu animate:delta];
    if (showPlayerPrompt) {
        if (fabsf(_playerPrompt.position.y-posPlayerPromptOnscreen.y)>1) {
            float deltaY=9*delta*(posPlayerPromptOnscreen.y-_playerPrompt.position.y);
            _playerPrompt.position=ccp(_playerPrompt.position.x,_playerPrompt.position.y+deltaY);
        }
    } else {
        if (_playerPrompt.position.y<posPlayerPromptOffscreen.y) {
            float deltaY=90*delta;
            _playerPrompt.position=ccp(_playerPrompt.position.x,_playerPrompt.position.y+deltaY);
        } else {
            _playerPrompt.opacity=0;
        }
    }
     
}

//////////////////// Instructions from World ////////////////////

-(void) startHome {
    BOOL savedTablesPresent=false;
    [_input pushTouchFocus:TOUCH_HOME];
    [_homeMenu open:savedTablesPresent];
    [_backButton fadeOut];
    [_backButton setTouchable:NO];
}

-(void) stopHome {
    [_input popTouchFocus:TOUCH_HOME];
    [_homeMenu close];
    [_backButton fadeIn];
    [_backButton setTouchable:YES];
}

-(void) joinSelected {
    DPCWorldLayer* worldLayer=[[DPCGame sharedGame] getWorldLayer];
    [worldLayer sendCameraTo:worldLayer.camPosPlayer];
}

-(void) notifyAtPlayerPosition {
    [_input pushTouchFocus:TOUCH_PLAYER];
}

-(void) notifyLeftPlayerPosition {
    [_input popTouchFocus:TOUCH_PLAYER];
}

-(void)startWifiPrompt {
    _wifiLabel.opacity=0;
    [_wifiLabel startFlashing];
}

-(void)stopWifiPrompt {
    [_wifiLabel fadeOut];
    _wifiLabel.opacity=0;
}

-(void)startEnterPlayerName {
    [_enterName1Label fadeIn];
    [_enterName2Label fadeIn];
    [_enterNameDoneButton fadeIn];
    _enterNameDoneButton.touchable=YES;
    [_input pushTouchFocus:TOUCH_PLAYERS_NAME];
}

-(void)stopEnterPlayerName {
    [_enterName1Label fadeOut];
    [_enterName2Label fadeOut];
    [_enterNameDoneButton fadeOut];
    _enterNameDoneButton.touchable=NO;
    [_input popTouchFocus:TOUCH_PLAYERS_NAME];
}

-(void) startSearchForGames {
    
    _searchingLabel.opacity=0;
    [_searchingLabel startFlashing];
    //searchingAnimation.ping();
    //searchingAnimation.setTouchable(true);
}

-(void) stopSearchForGames {
    //searchingAnimation.stop();
    //searchingAnimation.setTouchable(false);
    [_searchingLabel fadeOut];
    _searchingLabel.opacity=0;
}

-(void) startBuyin:(NSString*)tableName loadedGame:(BOOL)loadedGame {
    _dialogWindow.opacity=1;
    [_dialogWindow setPosition:buyinDialogSmall.position];
    [_dialogWindow setRadiusX:buyinDialogSmall.xWindowRadius radiusY:buyinDialogSmall.yWindowRadius];
    [_dialogWindow sendTo:_buyinDialog];
    [_buyinDialog disappear];
    [_buyinDialog setTableName:tableName];
    [_buyinDialog setLoadedGame:loadedGame];
    
    [_input pushTouchFocus:TOUCH_BUYIN];
}

-(void) stopBuyin {
    [_dialogWindow remove];
    [_dialogWindow fadeOut];
    [_buyinDialog stop];
    [_input popTouchFocus:TOUCH_BUYIN];
}

-(void) startLeaveTableDialog:(NSString*)tableName {
    _dialogWindow.opacity=1;
    [_dialogWindow setPosition:leaveTableDialogSmall.position];
    [_dialogWindow setRadiusX:leaveTableDialogSmall.xWindowRadius radiusY:leaveTableDialogSmall.yWindowRadius];
    [_dialogWindow sendTo:_leaveTableDialog];
    [_leaveTableDialog disappear];
    [_leaveTableDialog setTableName:tableName];
    
    [_input pushTouchFocus:TOUCH_LEAVE_DIALOG];
}

-(void) stopLeaveTableDialog {
    [_dialogWindow remove];
    [_dialogWindow fadeOut];
    [_leaveTableDialog stop];
    [_input popTouchFocus:TOUCH_LEAVE_DIALOG];
}

-(void)hideTextMessage {
    showPlayerPrompt=NO;
    
}


-(void)showTextMessage:(NSString*)message {
    _playerPrompt.position=posPlayerPromptOffscreen;
    _playerPrompt.string=message;
     _playerPrompt.opacity=1;
     showPlayerPrompt=YES;
}

-(void)promptStateChange:(NSString*) messageStateChange {
    _stateChangePrompt.string=messageStateChange;
    [_stateChangePrompt fadeIn];
    [_input pushTouchFocus:TOUCH_PLAYER_STATE_CHANGE];
}

-(void)stateChangeACKed {
    [_input popTouchFocus:TOUCH_PLAYER_STATE_CHANGE];
    _stateChangePrompt.string=@"";
    [_stateChangePrompt fadeOut];
}

-(void)startWaitNextHand {
    [_waitNextHandLabel startFlashing];
}

-(void)stopWaitNextHand {
    [_waitNextHandLabel fadeOut];
}

-(void) startReconnect {
    [_reconnect1Label fadeIn];
    [_reconnect2Label startFlashing];
}

-(void) stopReconnect {
    [_reconnect1Label fadeOut];
    [_reconnect2Label fadeOut];
}

-(void)showTableStatusMenu:(NSString *)tableName {
    _tableStatusMenu.tableName.string=tableName;
    [_tableStatusMenu show];
}

-(void)openTableStatusMenu {
    [_input pushTouchFocus:TOUCH_TABLE_STATUS];
    [_tableStatusMenu open];
}

-(void)closeTableStatusMenu {
    [_input popTouchFocus:TOUCH_TABLE_STATUS];
    [_tableStatusMenu close];
}

-(void)removeTableStatusMenu {
    [self closeTableStatusMenu];
    [self.tableStatusMenu remove];
}

-(BOOL)ccTouchBegan:(UITouch*)touch withEvent:(UIEvent*)event {
    CGPoint touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    CCLOG(@"touchPoint - x: %d y: %d",(int)touchPoint.x,(int)touchPoint.y);
    return [_input touchDown:touchPoint];
}

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    CCLOG(@"touchPoint - x: %d y: %d",(int)touchPoint.x,(int)touchPoint.y);
    if (![_input touchDown:touchPoint]) {
        [super touchBegan:touch withEvent:event];
    }
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    [_input touchDragged:touchPoint];
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    [_input touchUp:touchPoint];
}



@end
