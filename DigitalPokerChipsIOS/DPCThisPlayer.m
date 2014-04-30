//
//  DPCThisPlayer.m
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 8/04/14.
//
//


#import "DPCThisPlayer.h"
#import "DPCGame.h"
#import "DPCTextFactory.h"
#import "DPCPlayerNetwork.h"
#import "DPCDiscoveredTable.h"
#import "DPCChipCase.h"
#import "DPCChipStack.h"
#import "DPCGameLogic.h"
#import "DPCLogger.h"

NSString *const CONN_NONE=@"CONN_NONE";
NSString *const CONN_IDLE=@"CONN_IDLE";
NSString *const CONN_SEARCHING=@"CONN_SEARCHING";
NSString *const CONN_BUYIN=@"CONN_BUYIN";
NSString *const CONN_CONNECTING=@"CONN_CONNECTING";
NSString *const CONN_CONNECTED=@"CONN_CONNECTED";
NSString *const CONN_SEARCH_HOLDOFF=@"CONN_SEARCH_HOLDOFF";

int const DURATION_SEARCH_HOLDOFF = 2000;

@interface DPCThisPlayer () {
    DPCPlayerNetwork* networkInterface;
    DPCDiscoveredTable* connectingTable;
    CCNode* chips;
    
    int betStake;
    BOOL betEnabled;
    BOOL foldEnabled;
    BOOL checkEnabled;
    BOOL isDealer;
    
    BOOL waitingOnHost;
    
    CGPoint betStackOrigin;
    CGPoint winStackOrigin;
    float limYBetStackTop;
	float limYBetStackBottom;
	float limYBetStackCancel;
    CGPoint joinTokenStart;
    CGPoint joinTokenStop;
    CGPoint dealerButtonOffscreen;
    CGPoint dealerButtonOnscreen;
    int searchHoldoffTimer;
}
@end

@implementation DPCThisPlayer

ccColor3B colors[] = {{255,0,0},
    {0,255,0},
    {0,0,255},
    {0,255,255},
    {255,0,255},
    {255,255,0},
    {255,255,255},
    {0,0,0}};

-(id) initWithWorldLayer:(DPCWorldLayer*)mWL {
    if (self=[super init]) {
        networkInterface=[[DPCPlayerNetwork alloc]init];
        networkInterface.player=self;
        
        betStake=0;
        betEnabled=NO;
        foldEnabled=NO;
        checkEnabled=NO;
        waitingOnHost=NO;
        isDealer=NO;
        
        _nameField = [[UITextField alloc] init];
        _nameField.returnKeyType = UIReturnKeyDone;
        _nameField.delegate = mWL.input;
        [_nameField addTarget:self action:@selector(updatePlayerName) forControlEvents:UIControlEventEditingChanged];
        _nameLabel = [DPCTextLabel node];
        _nameLabel.color=[CCColor colorWithRed:0 green:0 blue:0];
        [mWL addChild:_nameLabel];
        _plaqueRect=[DPCSprite DPCSpriteWithFile:@"button_blue.png"];
        _connectivityStatus=CONN_NONE;
        _wifiEnabled=NO;
        
        _defaultChipNums=[NSArray arrayWithObjects:[NSNumber numberWithInt:10],[NSNumber numberWithInt:4],[NSNumber numberWithInt:10], nil];
        
        _connectionBlob=[DPCSprite DPCSpriteWithFile:@"connection_blob.png"];
        _connectionBlob.opacity=0;
        _connectionBlob.flashVisibleTime=100;
        _connectionBlob.flashInvisibleTime=0;
        _connectionBlob.fadeInSpeed=1;
        _connectionBlob.fadeOutSpeed=3;
        [mWL addChild:_connectionBlob];
        
        _dealerButton=[DPCSprite DPCSpriteWithFile:@"dealer_chip.png"];
        _dealerButton.opacity=0;
        [mWL addChild:_dealerButton];
        
        chips=[CCNode node];
        
        [mWL addChild:chips];
        
        _pickedUpChip=nil;
        _mainStacks=[NSMutableArray array];
        
        DPCChipStack* thisChipStack;
		for (int chip=CHIP_CASE_CHIP_A;chip<CHIP_CASE_CHIP_TYPES;chip++) {
            thisChipStack=[[DPCChipStack alloc]initWithChipNode:chips];
            thisChipStack.maxRenderNum=20;
            int chipNum=[[_defaultChipNums objectAtIndex:chip] intValue];
            [thisChipStack addChipsOfType:chip number:chipNum];
            [_mainStacks addObject:thisChipStack];
		}
        
        _bettingStack=[[DPCChipStack alloc]initWithChipNode:chips];
        _betStack=[[DPCChipStack alloc]initWithChipNode:chips];
        _betStack.maxRenderNum=20;
        _cancellingStack=[[DPCChipStack alloc]initWithChipNode:chips];
        _cancelStack=[[DPCChipStack alloc]initWithChipNode:chips];
        
        _joinToken=[DPCSprite DPCSpriteWithFile:@"join_coin.png"];
        _joinToken.opacity=0;
        [mWL addChild:_joinToken];
        
        _checkButton=[DPCSprite DPCSpriteWithFile:@"table_highlight.png"];
        _checkButton.opacity=0;
        [mWL addChild:_checkButton];
        
        [self updatePlayerName];
    }
    return self;
}

-(void)dealloc {
    networkInterface=nil;
    connectingTable=nil;
}

-(void)setWorldWidth:(int)worldWidth height:(int)worldHeight {
    
    [DPCChip setRadiusX:(int) (worldWidth*0.02f)];
    [DPCChip setRadiusY:(int) (worldWidth*0.0196f)];
    
    [_plaqueRect setRadiusX:(int)(worldWidth*0.044f) radiusY:(int)(worldHeight*0.03f)];
    NSString* tmp=_nameLabel.string;
    _nameLabel.string=@"LONGNAME!";
    _nameLabel.fontSize=[DPCTextFactory getMaxTextSize:_nameLabel width:_plaqueRect.radiusX*1.7f height:_plaqueRect.radiusY*1.8f];
    if (tmp.length>0) {
        _nameLabel.string=tmp;
    } else {
        _nameLabel.string=@"";
    }
    for (int i=0;i<CHIP_CASE_CHIP_TYPES;i++) {
        id stack=[_mainStacks objectAtIndex:i];
        DPCChipStack* thisStack=(DPCChipStack*)stack;
        [thisStack scaleLabel];
    }
    
    [_betStack scaleLabel];
    
    [_joinToken setRadiusX:worldHeight*0.0288f radiusY:worldHeight*0.0288f];
    
    [_checkButton setRadiusX:(int)(worldHeight*0.1f) radiusY:(int)(worldHeight*0.04f)];
    
    [_dealerButton setRadiusX:(int)(worldHeight*0.022f) radiusY:(int)(worldHeight*0.022f)];
    [_connectionBlob setRadiusX:(int)(worldHeight*0.08f) radiusY:(int)(worldHeight*0.024f)];
}

-(void)setPositions:(int)worldWidth height:(int)worldHeight {
    DPCWorldLayer* mWL=[[DPCGame sharedGame] getWorldLayer];
    [_plaqueRect setPosition:ccp(worldWidth*0.5f,worldHeight*0.165f)];
    [_nameLabel setPosition:_plaqueRect.position];
    DPCChipStack* thisStack=[_mainStacks objectAtIndex:CHIP_CASE_CHIP_A];
    thisStack.position=ccp(worldWidth*0.445f,worldHeight*0.25f);
    thisStack=[_mainStacks objectAtIndex:CHIP_CASE_CHIP_B];
    thisStack.position=ccp(worldWidth*0.5f,worldHeight*0.25f);
    thisStack=[_mainStacks objectAtIndex:CHIP_CASE_CHIP_C];
    thisStack.position=ccp(worldWidth*0.555f,worldHeight*0.25f);
    limYBetStackTop=[DPCCamera getScreenTopInWorld:mWL.camPosPlayer];
    limYBetStackBottom=thisStack.position.y+[DPCChip getRadiusY]*2.0f;
    limYBetStackCancel=limYBetStackBottom+[DPCChip getRadiusY]*0.2f;
    betStackOrigin=ccp(worldWidth*0.5f,limYBetStackCancel+[DPCChip getRadiusY]);
    _betStack.position=betStackOrigin;
    winStackOrigin=ccp(worldWidth*0.5f,limYBetStackTop+[DPCChip getRadiusY]);
    _joinToken.position=ccp(worldWidth*0.5f,worldHeight*0.4f);
    joinTokenStop=ccp(worldWidth*0.5f,worldHeight*0.5f);
    joinTokenStart=ccp(worldWidth*0.5f,worldHeight*0.38f);
    
    _checkButton.position=ccp(worldWidth*0.5f,worldHeight*0.35f);
    
    dealerButtonOffscreen=ccp(worldWidth*0.405f,worldHeight*0.5f);
    dealerButtonOnscreen=ccp(worldWidth*0.405f,worldHeight*0.25f);
    _dealerButton.position=dealerButtonOffscreen;
    
    _connectionBlob.position=ccp(worldWidth*0.5f,[DPCCamera getScreenTopInWorld:mWL.camPosPlayer]);
}

-(void)animate:(float)delta {
    
    if (_connectivityStatus==CONN_SEARCH_HOLDOFF) {
        searchHoldoffTimer+=delta*1000;
        if (searchHoldoffTimer>DURATION_SEARCH_HOLDOFF) {
            [self notifyReadyToSearch];
        }
    }
    [_joinToken animate:delta];
    [_checkButton animate:delta];
    [_connectionBlob animate:delta];
    if (_sendingJoinToken) {
        if (fabsf(_joinToken.position.y-joinTokenStop.y)<2) {
            
        } else {
            float deltaY=delta*4*(_joinToken.position.y-joinTokenStop.y);
            _joinToken.position=ccp(_joinToken.position.x,_joinToken.position.y-deltaY);
        }
    }
    if (isDealer) {
        if (fabsf(_dealerButton.position.y-dealerButtonOnscreen.y)<2) {
            
        } else {
            float deltaY=delta*4*(_dealerButton.position.y-dealerButtonOnscreen.y);
            _dealerButton.position=ccp(_dealerButton.position.x,_dealerButton.position.y-deltaY);
        }
    } else {
        if (fabsf(_dealerButton.position.y-dealerButtonOffscreen.y)<2) {
            
        } else {
            float deltaY=delta*4*(_dealerButton.position.y-dealerButtonOffscreen.y);
            _dealerButton.position=ccp(_dealerButton.position.x,_dealerButton.position.y-deltaY);
        }
    }
    if (_pickedUpChip!=nil) {
        float timeFactor=delta*9;
        if (_pickedUpChip.isTouched) {
            timeFactor*=3;
        }
        timeFactor=MIN(timeFactor, 1);
        float xDelta=timeFactor*(_pickedUpChip.destination.x-_pickedUpChip.position.x);
        float yDelta=timeFactor*(_pickedUpChip.destination.y-_pickedUpChip.yBeforeZOffset);
        double dist=sqrt(xDelta*xDelta+yDelta*yDelta);
        if (dist>[DPCChip getRadiusX]) {
            double scale=[DPCChip getRadiusX]/dist;
            xDelta*=scale;
            yDelta*=scale;
        }
        float yNew=(float)(_pickedUpChip.yBeforeZOffset+yDelta);
        float xNew=(float)(_pickedUpChip.position.x+xDelta);
        _pickedUpChip.z=(float)(_pickedUpChip.z-timeFactor*(_pickedUpChip.z-_pickedUpChip.zDest));
        // detect collision with other stacks
        if (![self updatePUCCollisions:xNew yNew:yNew z:_pickedUpChip.z]) {
            // if no collisions, set to new position
            _pickedUpChip.position=ccp(xNew,yNew);
            // if not touched and at dest, return to stack
            if (!_pickedUpChip.isTouched&&_pickedUpChip.atDest) {
                [_pickedUpChip setXYZToDest];
                DPCChipStack* thisStack=[_mainStacks objectAtIndex:_pickedUpChip.chipType];
                [thisStack addChip:_pickedUpChip];
                [thisStack updateTotalLabel];
                _pickedUpChip=nil;
            }
        }
    }
    for (int i=0;i<_bettingStack.size;i++) {
        if ([[_bettingStack getChip:i] animateToDest:delta]) {
            if (i==0) {
                [_betStack addChip:[_bettingStack takeChip:i]];
                [_betStack updateTotalLabel];
                i--;
            }
        }
        
    }
    if (_cancellingStack.size>0) {
        BOOL allArrived=YES;
        for (int i=0;i<_cancellingStack.size;i++) {
            if (![[_cancellingStack getChip:i] animateToDest:delta]) {
                allArrived=NO;
            }
        }
        if (allArrived) {
            int chipCount[]={0,0,0};            
            while (_cancellingStack.size>0) {
                DPCChip* thisChip=[_cancellingStack takeChip:0];
                DPCChipStack* thisStack=[_mainStacks objectAtIndex:thisChip.chipType];
                float xDest=thisStack.position.x;
                float yDest=thisStack.position.y;
                float zDest=thisStack.renderSize+chipCount[thisChip.chipType];
                [thisChip setDest:ccp(xDest,yDest)];
                thisChip.zDest=zDest;
                [_cancelStack addChip:thisChip];
                chipCount[thisChip.chipType]++;
            }
            
        }
    }
    if (_cancelStack.size>0) {
        BOOL allArrived=YES;
        for (int i=0;i<_cancelStack.size;i++) {
            if (![[_cancelStack getChip:i] animateToDest:delta]) {
                allArrived=NO;
            }
        }
        if (allArrived) {
            while (_cancelStack.size>0) {
                DPCChip* thisChip=[_cancelStack takeChip:0];
                DPCChipStack* thisStack=[_mainStacks objectAtIndex:thisChip.chipType];
                [thisStack addChip:thisChip];
            }
        }
        [self updateMainStackTotals];
    }
    if (_betStack.velocity.y!=0) {
        _betStack.position=ccp(_betStack.position.x,_betStack.position.y+delta*_betStack.velocity.y);
    }
     
}

-(void)collisionDetector {
    if (_betStack.size>0) {
        if (_betStack.position.y>=limYBetStackTop) {
            if ((betEnabled)&&!waitingOnHost&&(_betStack.value>=betStake||[self isAllIn])) {
                if (_betStack.position.y>limYBetStackTop) {
                    [self submitBet];
                }
            } else {
                _betStack.position=ccp(_betStack.position.x,limYBetStackTop);
                _betStack.velocity=ccp(0,0);
            }
        } else if (_betStack.position.y<limYBetStackBottom) {
            _betStack.position=ccp(_betStack.position.x,limYBetStackBottom);
            _betStack.velocity=ccp(0,0);
        }
        if (_betStack.position.y<limYBetStackCancel&&![_betStack getChip:0].isTouched) {
            [self initiateCancelFromStack:_betStack];
            _betStack.position=betStackOrigin;
        }
    }
    if (_sendingJoinToken) {
        if (_joinToken.position.y>=limYBetStackTop) {
            _joinToken.opacity=0;
            _sendingJoinToken=NO;
            _connectivityStatus=CONN_CONNECTING;
            [networkInterface requestConnect:connectingTable azimuth:[DPCGame sharedGame].azimuth chipNumbers:self.chipNumbers];
        }
    }
}

-(BOOL) updatePUCCollisions:(float)xNew yNew:(float)yNew z:(float)z {
    BOOL collisionOccured=NO;
    DPCWorldLayer* mWL=[[DPCGame sharedGame] getWorldLayer];
    for (int chipType=CHIP_CASE_CHIP_A;chipType<CHIP_CASE_CHIP_TYPES;chipType++) {
        DPCChipStack* thisStack=[_mainStacks objectAtIndex:chipType];
        DPCChipStack* mPUCStack=[_mainStacks objectAtIndex:_pickedUpChip.chipType];
        float xTestChip=thisStack.position.x;
        float yTestChip=thisStack.position.y;
        float zTestChip=0;
        if (thisStack.size>0) {
            int testChipIndex=(int) MIN(thisStack.renderSize-1,_pickedUpChip.z);
            zTestChip=[thisStack getChip:testChipIndex].z;
        }
        // check for overlap
        float yOverlap=[DPCChip testOverlap:(float)xNew y1:(float)yNew z1:(float)z x2:(float)xTestChip y2:(float)yTestChip z2:(float)zTestChip];
        if (yOverlap!=0) {
            // make change if available
            if (_pickedUpChip.isTouched&&(_pickedUpChip.chipType!=chipType)) {
                int valPUC=[mWL.chipCase getValueForChipType:_pickedUpChip.chipType];
                int valThisChip=[mWL.chipCase getValueForChipType:chipType];
                int numNeeded = valThisChip/valPUC-1;
                if (mPUCStack.size>=numNeeded) {
                    collisionOccured=YES;
                    int numToGain=MAX(1,valPUC/valThisChip);
                    int numToLose=MAX(0,valThisChip/valPUC-1);
                    [thisStack addChipsOfType:chipType number:numToGain];
                    [mPUCStack removeChipsOfType:_pickedUpChip.chipType number:numToLose];
                    [_pickedUpChip remove];
                    _pickedUpChip=nil;
                    [[OALSimpleAudio sharedInstance] playEffect:@"change.wav"];
                    [self updateMainStackTotals];
                    break;
                }
            }
            if (_pickedUpChip!=nil) {
                if (thisStack.renderSize-1>=z) {
                    collisionOccured=YES;
                    // constrain to boundary if change isn't available
                    yNew-=yOverlap;
                    _pickedUpChip.position=ccp(xNew,yNew);
                    // if constrained and touched, drop chip if no longer touched
                    if (_pickedUpChip.isTouched) {                        
                        if (![_pickedUpChip pointContained:mWL.input.lastTouch]) {
                            _pickedUpChip.isTouched=NO;
                            [self doPickedUpChipDropped];
                            break;
                        }
                    }
                }
            }
        }
    }
    return collisionOccured;
}

-(void) updateMainStackTotals {
    for (int i=0;i<_mainStacks.count;i++) {
        [((DPCChipStack*)[_mainStacks objectAtIndex:i]) updateTotalLabel];
    }
}

-(BOOL)isAllIn {
    BOOL allIn=YES;
    for (int i=0;i<CHIP_CASE_CHIP_TYPES;i++) {
        if (((DPCChipStack*)[_mainStacks objectAtIndex:i]).size>0) {
            allIn=NO;
            break;
        }
    }
    return allIn;
}

-(void) notifyReadyToSearch {
    DPCUILayer* mUIL=[[DPCGame sharedGame] getUILayer];
    if ([_connectivityStatus isEqualToString:CONN_IDLE]||[_connectivityStatus isEqualToString:CONN_SEARCH_HOLDOFF]) {
        _connectivityStatus=CONN_SEARCHING;
        [mUIL startSearchForGames];
        [networkInterface startRequestGames];
    }
}

-(void)searchHoldoff {
    _connectivityStatus=CONN_SEARCH_HOLDOFF;
    searchHoldoffTimer=0;
}

-(void) stopSearchForGames {
    _connectivityStatus=CONN_IDLE;
    DPCUILayer* mUIL=[[DPCGame sharedGame] getUILayer];
    [mUIL stopSearchForGames];
    [networkInterface stopRequestGames];
}

-(void)sendJoinToken:(NSMutableArray*) chipNumbers {
    _chipNumbers=chipNumbers;
    _sendingJoinToken=YES;
}



-(void)notifyLeftPlayerPosition {
    DPCUILayer* mUIL=[[DPCGame sharedGame] getUILayer];
    [mUIL notifyLeftPlayerPosition];
    [mUIL stopWifiPrompt];
    _connectivityStatus=CONN_NONE;
    _betStack.totalShowing=NO;
    for (int i=0;i<_mainStacks.count;i++) {
        ((DPCChipStack*)[_mainStacks objectAtIndex:i]).totalShowing=NO;
    }
    _dealerButton.opacity=0;
}

-(void)notifyAtPlayerPosition {
    DPCUILayer* mUIL=[[DPCGame sharedGame] getUILayer];
    DPCWorldLayer* mWL=[[DPCGame sharedGame] getWorldLayer];
    [mUIL notifyAtPlayerPosition];
    if (_nameField.text.length==0) {
        [mWL sendCameraTo:mWL.camPosPlayersName];
    } else if ([_connectivityStatus isEqualToString:CONN_NONE]) {
        _connectivityStatus=CONN_IDLE;
        //plaque.setTouchable(true);
        if ([[DPCGame sharedGame].reachability isReachableViaWiFi]) {
            [self notifyReadyToSearch];
        } else {
            [self wifiOff];
        }
        _betStack.totalShowing=YES;
        for (int i=0;i<_mainStacks.count;i++) {
            ((DPCChipStack*)[_mainStacks objectAtIndex:i]).totalShowing=YES;
        }
    }
}

-(void)notifyAtNamePosition {
    UIView *view = [[CCDirector sharedDirector] view];
    [view addSubview:_nameField];
    [_nameField becomeFirstResponder];
    [[[DPCGame sharedGame]getUILayer] startEnterPlayerName];
}

-(void)notifyLeftNamePosition {
    [[[DPCGame sharedGame]getUILayer] stopEnterPlayerName];
}

-(BOOL)backPressed {
    BOOL playerFinished=true;
    if (_connectivityStatus==CONN_NONE) {
        
    } else if (_connectivityStatus==CONN_IDLE) {
        
    } else if (_connectivityStatus==CONN_SEARCHING) {
        [self stopSearchForGames];
    } else if (_connectivityStatus==CONN_SEARCH_HOLDOFF) {
        ;
    } else if (_connectivityStatus==CONN_CONNECTING) {
        // playerFinished=false;
    } else if (_connectivityStatus==CONN_CONNECTED) {
        [self doLeaveDialog];
        playerFinished=false;
    }
    return playerFinished;
}

-(void)updatePlayerName {
    if (_nameLabel.contentSize.width<_plaqueRect.radiusX*1.3f) {
        _nameLabel.string=_nameField.text;
        [networkInterface setName:_nameLabel.string];
    }
}

-(void)nameDone {
    [_nameField endEditing:YES];
    [_nameField removeFromSuperview];
    DPCWorldLayer* mWL=[[DPCGame sharedGame] getWorldLayer];
    [mWL sendCameraTo:mWL.camPosPlayer];
}

-(void)notifyTableFound:(DPCDiscoveredTable*)table loadedGame:(BOOL)loadedGame {
    if ([_connectivityStatus isEqualToString:CONN_SEARCHING]) {
        _connectivityStatus=CONN_BUYIN;
        connectingTable=table;
        [self stopSearchForGames];
        [self clearAllStacks];
        [[[DPCGame sharedGame] getWorldLayer].chipCase setValuesFromChipCase:table.chipCase];
        [_joinToken fadeIn];
        [_joinToken setPosition:joinTokenStart];
        [[[DPCGame sharedGame] getUILayer] startBuyin:table.tableName loadedGame:loadedGame];
    }
    [DPCLogger log:DEBUG_LOG_PLAYER_TAG msg:@"table found"];
}

-(void)clearAllStacks {
    [_mainStacks[CHIP_CASE_CHIP_A] clear];
    [_mainStacks[CHIP_CASE_CHIP_B] clear];
    [_mainStacks[CHIP_CASE_CHIP_C] clear];
    [_betStack clear];
    [_betStack setPosition:ccp(betStackOrigin.x,betStackOrigin.y)];
    [_bettingStack clear];
    [_cancellingStack clear];
    [_cancelStack clear];
    _pickedUpChip=nil;
}

-(void) enableBet {
    betEnabled=YES;
}
-(void) disableBet {
    betEnabled=NO;
}
-(void) enableCheck {
    checkEnabled=YES;
    [_checkButton fadeIn];
    _checkButton.touchable=YES;
}
-(void) disableCheck {
    checkEnabled=NO;
    [_checkButton fadeOut];
    _checkButton.touchable=NO;
}
-(void) enableFold {
    foldEnabled=YES;
    [[[DPCGame sharedGame] getUILayer].foldButton fadeIn];
    [[DPCGame sharedGame] getUILayer].foldButton.touchable=YES;
}
-(void) disableFold {
    foldEnabled=NO;
    [[[DPCGame sharedGame] getUILayer].foldButton fadeOut];
    [[DPCGame sharedGame] getUILayer].foldButton.touchable=NO;
}

-(void)notifyTableDisconnected {
    [self cancelMoveState];
    [self setDealer:false];
    waitingOnHost=false;
    DPCUILayer* mUIL=[[DPCGame sharedGame]getUILayer];
    [mUIL.reconnect1Label fadeOut];
    mUIL.reconnect1Label.opacity=0;
    [mUIL.reconnect2Label fadeOut];
    mUIL.reconnect2Label.opacity=0;
    [mUIL removeTableStatusMenu];
    [mUIL stopWaitNextHand];
}

-(void)cancelMoveState {
    [[[DPCGame sharedGame]getUILayer] stateChangeACKed];
    [self.connectionBlob fadeOut];
    _connectionBlob.opacity=0;
    [self disableBet];
    [self disableCheck];
    [self disableFold];
    [[[DPCGame sharedGame]getUILayer] hideTextMessage];
}

-(void)buyinDialogDone:(NSMutableArray*)chipNumbers {
    [[[DPCGame sharedGame] getUILayer] stopBuyin];
    if (chipNumbers!=nil) {
        [self sendJoinToken:chipNumbers];
    } else {
        [_joinToken fadeOut];
        _joinToken.opacity=0;
        [self searchHoldoff];
    }
}

-(void)doLeaveDialog {
    [[[DPCGame sharedGame]getUILayer] startLeaveTableDialog:self.tableName];
}

-(void)leaveDialogDone:(BOOL)actionCompleted {
    [[[DPCGame sharedGame]getUILayer] stopLeaveTableDialog];
    if (actionCompleted) {
        [self leaveTable];
    }
}

-(void)leaveTable {
    if (_connectivityStatus==CONN_CONNECTED) {
        [networkInterface leaveTable];
        [self notifyTableDisconnected];
        [self searchHoldoff];
    }
    [DPCLogger log:DEBUG_LOG_PLAYER_TAG msg:@"leaveTable"];
}

-(void) setPickedUpChip:(DPCChip*)newPUC {
    DPCChipStack* thisStack=[_mainStacks objectAtIndex:newPUC.chipType];
    if (newPUC.z>thisStack.maxRenderNum) {
        newPUC.z=thisStack.maxRenderNum;
    }
    [newPUC setDestToPos];
    int zBetStackTop=_betStack.renderSize+_bettingStack.size;
    if (zBetStackTop>newPUC.zDest) {
        newPUC.zDest=zBetStackTop;
    }
    _pickedUpChip=newPUC;
    [self updateMainStackTotals];
}

-(void) doPickedUpChipDropped {
    BOOL isBet=YES;
    float xPUC=_pickedUpChip.position.x;
    float yPUC=_pickedUpChip.position.y;
    float radiusXPUC=_pickedUpChip.radiusX;
    float radiusYPUC=_pickedUpChip.radiusY;
    float left=((DPCChipStack*)[_mainStacks objectAtIndex:CHIP_CASE_CHIP_A]).position.x;
    float right=((DPCChipStack*)[_mainStacks objectAtIndex:CHIP_CASE_CHIP_C]).position.x;
    float bottom=limYBetStackBottom;
    
    if (xPUC<left||xPUC>right||yPUC<bottom) {
        isBet=NO;
    } else {
        // check if over stacks
        for (int chipType=0;chipType<CHIP_CASE_CHIP_TYPES;chipType++) {
            DPCChipStack* thisStack=[_mainStacks objectAtIndex:chipType];
            if (thisStack.renderSize<=_pickedUpChip.z&&thisStack.size>0) {
                DPCChip* chip=[thisStack getLastChipRendered];
                float x=chip.position.x;
                float y=chip.yBeforeZOffset;
                int radiusX=chip.radiusX;
                int radiusY=chip.radiusY;
                if (fabsf(xPUC-x)<radiusXPUC+radiusX) {
                    float dx1=fabsf(xPUC-x)*radiusX/(radiusX+radiusXPUC);
                    float dy1=(float) (sqrt(((radiusX*radiusX-dx1*dx1)*radiusY*radiusY)/(radiusX*radiusX)));
                    float dy2=dy1*(radiusYPUC/radiusY);
                    float dy=dy1+dy2;
                    if (yPUC>=y-dy&&yPUC<=y+dy) {
                        isBet=NO;
                    }
                }
            }
        }
    }
    
    if (isBet) {
        [self addBetChip:_pickedUpChip];
        _pickedUpChip=nil;
    } else {
        DPCChipStack* thisStack=[_mainStacks objectAtIndex:_pickedUpChip.chipType];
        float xDest=thisStack.position.x;
        float yDest=thisStack.position.y;
        float zDest=thisStack.renderSize+_cancellingStack.size+_cancelStack.size;
        [_pickedUpChip setDest:ccp(xDest,yDest)];
        _pickedUpChip.zDest=zDest;
    }
}

-(void)doPickedUpChipFlung:(CGPoint)velocity {
    
    BOOL flung=YES;
    
    float flingAngle=atan2f(velocity.y,velocity.x);
    flingAngle=flingAngle * 180.0f / M_PI;
    CCLOG(@"flingAngle: %d",(int)flingAngle);
    CGPoint toBetStackVec=ccpSub([_betStack getTopPosition],_pickedUpChip.position);
    float toBetStackAngle=atan2f(toBetStackVec.y,toBetStackVec.x);
    toBetStackAngle=toBetStackAngle * 180.0f / M_PI;
    CCLOG(@"toBetStackAngle: %d",(int)toBetStackAngle);
    float deltaAngle=fabsf(toBetStackAngle-flingAngle);
    deltaAngle=deltaAngle>180?360-deltaAngle:deltaAngle;
    CCLOG(@"deltaAngle: %d",(int)deltaAngle);
    if (deltaAngle>30) {
        flung=NO;
    }
    
    float left=((DPCChipStack*)[_mainStacks objectAtIndex:CHIP_CASE_CHIP_A]).position.x+[DPCChip getRadiusX]*0.3f;
    float right=((DPCChipStack*)[_mainStacks objectAtIndex:CHIP_CASE_CHIP_C]).position.x-[DPCChip getRadiusX]*0.3f;
    float bottom=((DPCChipStack*)[_mainStacks objectAtIndex:CHIP_CASE_CHIP_B]).position.y+[DPCChip getRadiusY]*0.3f;
    if (_pickedUpChip.position.x<left||
        _pickedUpChip.position.x>right||
        _pickedUpChip.position.y<bottom) {
        flung=NO;
    }
    
    if (flung) {
        [self addBetChip:_pickedUpChip];
        _pickedUpChip=nil;
    } else {
        [self doPickedUpChipDropped];
    }
}

-(void)addBetChip:(DPCChip*) chip {
    int numTop=MIN(_betStack.size+_bettingStack.size,_betStack.maxRenderNum);
    [chip setDest:ccp(_betStack.position.x,_betStack.position.y)];
    chip.zDest=numTop;
    [_bettingStack addChip:chip];
    [_checkButton fadeOut];
    _checkButton.touchable=NO;
    //mWL.game.mFL.foldButton.fadeOut();
    //mWL.game.mFL.foldButton.setTouchable(false);
}

-(void) initiateCancelFromStack:(DPCChipStack*) stack {
    NSMutableArray* chipCount=[NSMutableArray array];
    NSMutableArray* xs=[NSMutableArray array];
    NSMutableArray* ys=[NSMutableArray array];
    NSMutableArray* zs=[NSMutableArray array];
    
    for (int i=0;i<CHIP_CASE_CHIP_TYPES;i++) {
        [chipCount addObject:[NSNumber numberWithInt:0]];
        DPCChipStack* thisStack=[_mainStacks objectAtIndex:i];
        [xs addObject:[NSNumber numberWithFloat:thisStack.position.x]];
        float thisY;
        if (thisStack.size>0) {
            thisY=thisStack.position.y+[thisStack getLastChipRendered].radiusY*2;
        } else {
            thisY=thisStack.position.y+[DPCChip getRadiusY]*2;
        }
        [ys addObject:[NSNumber numberWithFloat:thisY]];
        [zs addObject:[NSNumber numberWithFloat:thisStack.renderSize]];
    }
    
    while (stack.size>0) {
        DPCChip* thisChip=[stack takeChip:0];
        float xDest=[xs[thisChip.chipType] floatValue];
        float yDest=[ys[thisChip.chipType] floatValue];
        float zDest=[zs[thisChip.chipType] floatValue]+[chipCount[thisChip.chipType] intValue];
        [thisChip setDest:ccp(xDest,yDest)];
        thisChip.zDest=zDest;
        chipCount[thisChip.chipType]=@([chipCount[thisChip.chipType] intValue]+1);
        [_cancellingStack addChip:thisChip];
    }
    [stack updateTotalLabel];
    
    if (checkEnabled) {
        [_checkButton fadeIn];
        _checkButton.touchable=YES;
    }
}

-(void) doFold {
    if (!waitingOnHost) {
        [[OALSimpleAudio sharedInstance] playEffect:@"fold.wav"];
        [networkInterface submitMove:MOVE_FOLD chipString:@""];
        [self disableBet];
        [self disableCheck];
        [self disableFold];
        [self.connectionBlob fadeOut];
        [[[DPCGame sharedGame] getUILayer] hideTextMessage];
    }
}

-(void) doCheck {
    if (!waitingOnHost) {
        [[OALSimpleAudio sharedInstance] playEffect:@"check.wav"];
        [networkInterface submitMove:MOVE_CHECK chipString:@""];
        [self disableBet];
        [self disableCheck];
        [self disableFold];
        [self.connectionBlob fadeOut];
        [[[DPCGame sharedGame]getUILayer] hideTextMessage];
    }
}

-(void) wifiOn {
    DPCUILayer* mUIL=[[DPCGame sharedGame] getUILayer];
    if (_connectivityStatus==CONN_IDLE) {
        [mUIL stopWifiPrompt];
        [self notifyReadyToSearch];
    } else if (_connectivityStatus==CONN_CONNECTED) {
        [mUIL stopWifiPrompt];
    }
    [networkInterface setWifiEnabled:YES];
}

-(void) wifiOff {
    DPCUILayer* mUIL=[[DPCGame sharedGame] getUILayer];
    if (_connectivityStatus==CONN_IDLE) {
        [mUIL startWifiPrompt];
    } else if (_connectivityStatus==CONN_SEARCHING) {
        [self stopSearchForGames];
        [mUIL startWifiPrompt];
    } else if (_connectivityStatus==CONN_CONNECTED) {
        [mUIL startWifiPrompt];
    }
    [networkInterface setWifiEnabled:NO];
}

-(void)onStart {
    [networkInterface onStart];
}

-(void)onStop {
    [networkInterface onStop];
}

-(void) notifyConnectResult:(BOOL)result tableName:(NSString*) tableName {
    if (result) {
        _connectivityStatus=CONN_CONNECTED;
        _tableName=tableName;
        _plaqueRect.touchable=NO;
        [DPCLogger log:DEBUG_LOG_PLAYER_TAG msg:@"connect attempt success"];
    } else {
        _connectivityStatus=CONN_IDLE;
        [self searchHoldoff];
        [[[DPCGame sharedGame]getUILayer] stopBuyin];
        [DPCLogger log:DEBUG_LOG_PLAYER_TAG msg:@"connect attempt failed"];
    }
    connectingTable=nil;
}

-(void)notifyConnectionLost {
    waitingOnHost=true;
    [self cancelMoveState];
    [[[DPCGame sharedGame] getUILayer] startReconnect];
    [DPCLogger log:DEBUG_LOG_PLAYER_TAG msg:@"connectionn lost"];
}

-(void)notifyReconnected {
    waitingOnHost=NO;
    [[[DPCGame sharedGame] getUILayer] stopReconnect];
    [DPCLogger log:DEBUG_LOG_PLAYER_TAG msg:@"reconnected"];
}

-(void) submitBet {
    int move;
    if (![self isAllIn]) {
        move=MOVE_BET;
    } else {
        move=MOVE_ALL_IN;
    }
    [networkInterface submitMove:move chipString:[_betStack description]];
     [_betStack clear];
     _betStack.position=betStackOrigin;
     [self disableBet];
     [self disableCheck];
     [self disableFold];
     [[[DPCGame sharedGame]getUILayer] hideTextMessage];
     [_connectionBlob fadeOut];
}

-(void) setupChips:(DPCChipStack*) setupStack color:(int) color {
    [self clearAllStacks];
    for (int i=0;i<CHIP_CASE_CHIP_TYPES;i++) {
        DPCChipStack* thisStack=[_mainStacks objectAtIndex:i];
        thisStack.opacity=1;
    }
    self.betStack.opacity=1;
    self.bettingStack.opacity=1;
    self.cancellingStack.opacity=1;
    self.cancelStack.opacity=1;
    self.bettingStack.opacity=1;
    [self doWin:setupStack];
    self.connectionBlob.color=[CCColor colorWithCcColor3b:colors[color]];
    DPCUILayer* mUIL=[[DPCGame sharedGame]getUILayer];
    [mUIL showTableStatusMenu:_tableName];
    [mUIL stopWaitNextHand];
}

-(void) doWin:(DPCChipStack*) winStack {
    int chipCount[]={0,0,0};
    for (int i=0;i<winStack.size;i++) {
        DPCChip* thisChip=[winStack getChip:i];
        DPCChipStack* thisChipStack=[_mainStacks objectAtIndex:thisChip.chipType];
        thisChip.position=winStackOrigin;
        float xDest=thisChipStack.position.x;
        float yDest=thisChipStack.position.y+[DPCChip getRadiusY]*2;
        float zDest=thisChipStack.renderSize+chipCount[thisChip.chipType];
        [thisChip setDest:ccp(xDest,yDest)];
        thisChip.zDest=zDest;
        thisChip.z=zDest;
        chipCount[thisChip.chipType]++;
        [chips addChild:thisChip];
        [_cancellingStack addChip:thisChip];
    }
    if (_pickedUpChip!=nil) {
        DPCChipStack* thisStack=[_mainStacks objectAtIndex:_pickedUpChip.chipType];
        float newZ=thisStack.renderSize+_cancellingStack.size;
        if (newZ>_pickedUpChip.z) {
            _pickedUpChip.zDest=newZ;
        }
    }
}

-(void) promptMove:(int)stake foldEnabled:(BOOL)foldEnabled_ message:(NSString*) message {
    if (foldEnabled_) {
        [self enableFold];
    }
    if (stake==0) {
        [self enableCheck];
        if (_betStack.size>0) {
            _checkButton.touchable=NO;
            [_checkButton fadeOut];
        }
    }
    [self enableBet];
    betStake=stake;
    [[OALSimpleAudio sharedInstance] playEffect:@"bell.wav"];
    [self textMessage:message];
    [_connectionBlob fadeIn];
}

-(void) promptStateChange:(NSString*)messageStateChange stake:(int)stake foldEnabled:(BOOL)foldEnabled_ message:(NSString*) message {
    DPCUILayer* mUIL=[[DPCGame sharedGame]getUILayer] ;
    [mUIL promptStateChange:messageStateChange];
    betStake=stake;
    foldEnabled=foldEnabled_;
    mUIL.playerPrompt.string=message;
}

-(void) stateChangeACKed {
     DPCUILayer* mUIL=[[DPCGame sharedGame]getUILayer] ;
    [mUIL stateChangeACKed];
    [self promptMove:betStake foldEnabled:foldEnabled message:mUIL.playerPrompt.string];
}

-(void)bellButtonPressed {
    NSString* hostName=[[DPCGame sharedGame]getUILayer].tableStatusMenu.nudgeHostName;
    [networkInterface sendBell:hostName];
}

-(void) textMessage:(NSString*) message {
    if ([message length]==0) {
        [[[DPCGame sharedGame] getUILayer] hideTextMessage];
    } else {
        [[[DPCGame sharedGame] getUILayer] showTextMessage:message];
    }
}

-(void) setDealer:(BOOL)isDealer_ {
    isDealer=isDealer_;
    if (isDealer) {
        _dealerButton.opacity=1;
    }
}

-(void) showConnection {
    [_connectionBlob fadeIn];
}

-(void) hideConnection {
    [_connectionBlob fadeOut];
}

-(void)notifyBootedByHost {
    if (_connectivityStatus==CONN_CONNECTED) {
        _connectivityStatus=CONN_IDLE;
        [self notifyTableDisconnected];
        [self notifyReadyToSearch];
    }
    [DPCLogger log:DEBUG_LOG_PLAYER_TAG msg:@"booted by host"];
}

-(void) notifyWaitNextHand {
    [[[DPCGame sharedGame]getUILayer] startWaitNextHand];
}

-(void)syncStatusMenu:(NSMutableArray *)playerList {
    [[[DPCGame sharedGame]getUILayer].tableStatusMenu syncStatusMenu:playerList];
}

-(void)doBell {
    [[OALSimpleAudio sharedInstance] playEffect:@"bell.wav"];
}

-(void)cancelMove {
    [self cancelMoveState];
}

-(void)enableNudge:(NSString*)hostName {
    [[[DPCGame sharedGame]getUILayer].tableStatusMenu enableNudge:hostName];
}

-(void)disableNudge {
    [[[DPCGame sharedGame]getUILayer].tableStatusMenu disableNudge];
}

@end
