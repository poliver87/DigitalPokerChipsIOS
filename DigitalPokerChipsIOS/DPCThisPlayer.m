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
#import "DPCMovePrompt.h"
#import "DPCMove.h"

NSString *const CONN_NONE=@"CONN_NONE";
NSString *const CONN_IDLE=@"CONN_IDLE";
NSString *const CONN_SEARCH_HOLDOFF=@"CONN_SEARCH_HOLDOFF";
NSString *const CONN_SEARCHING=@"CONN_SEARCHING";
NSString *const CONN_BUYIN=@"CONN_BUYIN";
NSString *const CONN_CONNECTING=@"CONN_CONNECTING";
NSString *const CONN_CONNECTED=@"CONN_CONNECTED";
NSString *const CONN_POLL_RECONNECT=@"CONN_POLL_RECONNECT";
NSString *const CONN_CONNECTED_NO_WIFI=@"CONN_CONNECTED_NO_WIFI";


int const DURATION_SEARCH_HOLDOFF = 2000;
int const RECONNECT_INTERVAL = 3000;

@interface DPCThisPlayer () {
    
    
    
    DPCPlayerNetwork* networkInterface;
    DPCDiscoveredTable* connectingTable;
    CCNode* chips;
    
    int betStake;
    BOOL betEnabled;
    BOOL foldEnabled;
    BOOL checkEnabled;
    BOOL isDealer;
    DPCMovePrompt* pendingMovePrompt;
    int chipAmount;
    
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
    int reconnectTimer;
}
@end

@implementation DPCThisPlayer

static const NSString* LOG_TAG=@"DPCPlayer";

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
    
    if ([_connectivityStatus isEqualToString:CONN_SEARCH_HOLDOFF]) {
        searchHoldoffTimer+=delta*1000;
        if (searchHoldoffTimer>DURATION_SEARCH_HOLDOFF) {
            [self notifyReadyToSearch];
        }
    } else if ([_connectivityStatus isEqualToString:CONN_POLL_RECONNECT]) {
        reconnectTimer+=delta*1000;
        if (reconnectTimer>=RECONNECT_INTERVAL) {
            [networkInterface requestConnect:connectingTable azimuth:[DPCGame sharedGame].azimuth chipNumbers:nil];
            reconnectTimer=0;
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
    [DPCLogger log:LOG_TAG msg:@"notifyReadyToSearch"];
    DPCUILayer* mUIL=[[DPCGame sharedGame] getUILayer];
    if ([_connectivityStatus isEqualToString:CONN_IDLE]||[_connectivityStatus isEqualToString:CONN_SEARCH_HOLDOFF]) {
        if ([[DPCGame sharedGame].reachability isReachableViaWiFi]) {
            _connectivityStatus=CONN_SEARCHING;
            [mUIL startSearchForGames];
            [networkInterface startRequestGames];
        } else {
            _connectivityStatus=CONN_IDLE;
            [[[DPCGame sharedGame] getUILayer] startWifiPrompt];
        }
        
    }
}

-(void)searchHoldoff {
    [DPCLogger log:LOG_TAG msg:@"searchHoldoff"];
    _connectivityStatus=CONN_SEARCH_HOLDOFF;
    searchHoldoffTimer=0;
}

-(void) startPollReconnect {
    [DPCLogger log:LOG_TAG msg:@"startPollReconnect"];
    _connectivityStatus=CONN_POLL_RECONNECT;
    reconnectTimer=RECONNECT_INTERVAL;
}

-(void) stopSearchForGames {
    [DPCLogger log:LOG_TAG msg:@"stopSearchForGames"];
    _connectivityStatus=CONN_IDLE;
    DPCUILayer* mUIL=[[DPCGame sharedGame] getUILayer];
    [mUIL stopSearchForGames];
    [networkInterface stopRequestGames];
}

-(void)sendJoinToken:(NSMutableArray*) chipNumbers {
    [DPCLogger log:LOG_TAG msg:@"sendJoinToken"];
    _chipNumbers=chipNumbers;
    _sendingJoinToken=YES;
}



-(void)notifyLeftPlayerPosition {
    [DPCLogger log:LOG_TAG msg:@"notifyLeftPlayerPosition"];
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
    [DPCLogger log:LOG_TAG msg:@"notifyAtPlayerPosition"];
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
    chipAmount=[self calculateChipAmount];
}

-(void)notifyAtNamePosition {
    [DPCLogger log:LOG_TAG msg:@"notifyAtNamePosition"];
    UIView *view = [[CCDirector sharedDirector] view];
    [view addSubview:_nameField];
    [_nameField becomeFirstResponder];
    [[[DPCGame sharedGame]getUILayer] startEnterPlayerName];
}

-(void)notifyLeftNamePosition {
    [DPCLogger log:LOG_TAG msg:@"notifyLeftNamePosition"];
    [[[DPCGame sharedGame]getUILayer] stopEnterPlayerName];
}

-(BOOL)backPressed {
    [DPCLogger log:LOG_TAG msg:@"backPressed"];
    BOOL playerFinished=true;
    if ([_connectivityStatus isEqualToString:CONN_NONE]) {
        
    } else if ([_connectivityStatus isEqualToString:CONN_IDLE]) {
        
    } else if ([_connectivityStatus isEqualToString:CONN_SEARCHING]) {
        [self stopSearchForGames];
    } else if ([_connectivityStatus isEqualToString:CONN_SEARCH_HOLDOFF]) {
        ;
    } else if ([_connectivityStatus isEqualToString:CONN_CONNECTING]) {
        playerFinished=false;
    } else if ([_connectivityStatus isEqualToString:CONN_CONNECTED]) {
        [self doLeaveDialog];
        playerFinished=false;
    } else if ([_connectivityStatus isEqualToString:CONN_POLL_RECONNECT]) {
        [self leaveTable];
        playerFinished=false;
    } else if ([_connectivityStatus isEqualToString:CONN_CONNECTED_NO_WIFI]) {
        [self leaveTable];
        playerFinished=false;
    }
    return playerFinished;
}

-(void)updatePlayerName {
    [DPCLogger log:LOG_TAG msg:@"updatePlayerName"];
    if (_nameLabel.contentSize.width<_plaqueRect.radiusX*1.3f) {
        _nameLabel.string=_nameField.text;
    }
}

-(void)nameDone {
    [DPCLogger log:LOG_TAG msg:@"nameDone"];
    [networkInterface setName:_nameField.text];
    [_nameField endEditing:YES];
    [_nameField removeFromSuperview];
    DPCWorldLayer* mWL=[[DPCGame sharedGame] getWorldLayer];
    [mWL sendCameraTo:mWL.camPosPlayer];
}

-(void)notifyTableFound:(DPCDiscoveredTable*)table connectNow:(BOOL)connectNow {
    [DPCLogger log:LOG_TAG msg:@"notifyTableFound"];
    if ([_connectivityStatus isEqualToString:CONN_SEARCHING]) {
        connectingTable=table;
        [self stopSearchForGames];
        [[[DPCGame sharedGame] getWorldLayer].chipCase setValuesFromChipCase:table.chipCase];
        if (!connectNow) {
            _connectivityStatus=CONN_BUYIN;
            [self clearAllStacks];
            [_joinToken fadeIn];
            [_joinToken setPosition:joinTokenStart];
            [[[DPCGame sharedGame] getUILayer] startBuyin:table.tableName];
        } else {
            _connectivityStatus=CONN_CONNECTING;
            [networkInterface requestConnect:connectingTable azimuth:[DPCGame sharedGame].azimuth chipNumbers:nil];
        }
    }
}

-(void)clearAllStacks {
    [DPCLogger log:LOG_TAG msg:@"clearAllStacks"];
    [_mainStacks[CHIP_CASE_CHIP_A] clear];
    [_mainStacks[CHIP_CASE_CHIP_B] clear];
    [_mainStacks[CHIP_CASE_CHIP_C] clear];
    [_betStack clear];
    [_betStack setPosition:ccp(betStackOrigin.x,betStackOrigin.y)];
    [_bettingStack clear];
    [_cancellingStack clear];
    [_cancelStack clear];
    _pickedUpChip=nil;
    chipAmount=0;
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
    [DPCLogger log:LOG_TAG msg:@"notifyTableDisconnected"];
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
    [DPCLogger log:LOG_TAG msg:@"cancelMoveState"];
    [[[DPCGame sharedGame]getUILayer] stateChangeACKed];
    [self.connectionBlob fadeOut];
    _connectionBlob.opacity=0;
    [self disableBet];
    [self disableCheck];
    [self disableFold];
    [[[DPCGame sharedGame]getUILayer] hideTextMessage];
}

-(void)buyinDialogDone:(NSMutableArray*)chipNumbers {
    [DPCLogger log:LOG_TAG msg:@"buyinDialogDone"];
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
    [DPCLogger log:LOG_TAG msg:@"leaveTable"];
    if ([_connectivityStatus isEqualToString:CONN_CONNECTED]||[_connectivityStatus isEqualToString:CONN_POLL_RECONNECT]||
        [_connectivityStatus isEqualToString:CONN_CONNECTED_NO_WIFI]) {
        _connectivityStatus=CONN_IDLE;
        [networkInterface leaveTable];
        [self notifyTableDisconnected];
        [self searchHoldoff];
    }
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
        CCLOG(@"PUC Flung");
        [self addBetChip:_pickedUpChip];
        _pickedUpChip=nil;
    } else {
        CCLOG(@"PUC not Flung");
        [self doPickedUpChipDropped];
    }
}

-(void)addBetChip:(DPCChip*) chip {
    int numTop=MIN(_betStack.size+_bettingStack.size,_betStack.maxRenderNum);
    [chip setDest:ccp(_betStack.position.x,_betStack.position.y)];
    CCLOG(@"sent PUC to (%d,%d)",(int)chip.destination.x,(int)chip.destination.y);
    chip.zDest=numTop;
    [_bettingStack addChip:chip];
    [_checkButton fadeOut];
    _checkButton.touchable=NO;
    DPCUILayer* mUIL=[[DPCGame sharedGame]getUILayer];
    [mUIL.foldButton fadeOut];
    mUIL.foldButton.touchable=NO;
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
    [stack clear];
    [stack updateTotalLabel];
    
    if (foldEnabled) {
        DPCUILayer* mUIL=[[DPCGame sharedGame]getUILayer];
        [mUIL.foldButton fadeIn];
        mUIL.foldButton.touchable=YES;
    }
    if (checkEnabled) {
        [_checkButton fadeIn];
        _checkButton.touchable=YES;
    }
}

-(void) doFold {
    if (!waitingOnHost) {
        [[OALSimpleAudio sharedInstance] playEffect:@"fold.wav"];
        DPCMove* thisMove=[[DPCMove alloc]initWithMoveType:MOVE_FOLD chipString:@""];
        [self sendMove:thisMove];
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
        DPCMove* thisMove=[[DPCMove alloc]initWithMoveType:MOVE_CHECK chipString:@""];
        [self sendMove:thisMove];
        [self disableBet];
        [self disableCheck];
        [self disableFold];
        [self.connectionBlob fadeOut];
        [[[DPCGame sharedGame]getUILayer] hideTextMessage];
    }
}

-(void)sendMove:(DPCMove*)move {
    [networkInterface submitMove:move.moveType chipString:move.chipString];
}

-(void) wifiOn {
    [DPCLogger log:LOG_TAG msg:@"wifiOn"];
    [networkInterface setWifiEnabled:YES];
    DPCUILayer* mUIL=[[DPCGame sharedGame] getUILayer];
    if ([_connectivityStatus isEqualToString:CONN_IDLE]) {
        [mUIL stopWifiPrompt];
        [self notifyReadyToSearch];
    } else if ([_connectivityStatus isEqualToString:CONN_CONNECTED_NO_WIFI]) {
        [mUIL stopWifiPrompt];
        [mUIL startReconnect];
        [self startPollReconnect];
    }
}

-(void) wifiOff {
    [DPCLogger log:LOG_TAG msg:@"wifiOff"];
    DPCUILayer* mUIL=[[DPCGame sharedGame] getUILayer];
    [networkInterface setWifiEnabled:NO];
    if ([_connectivityStatus isEqualToString:CONN_IDLE]) {
        [mUIL startWifiPrompt];
    } else if ([_connectivityStatus isEqualToString:CONN_SEARCH_HOLDOFF]) {
        [mUIL startWifiPrompt];
    } else if ([_connectivityStatus isEqualToString:CONN_SEARCHING]) {
        [self stopSearchForGames];
        [mUIL startWifiPrompt];
    } else if ([_connectivityStatus isEqualToString:CONN_BUYIN]) {
        [self cancelBuyin];
        [mUIL startWifiPrompt];
    } else if ([_connectivityStatus isEqualToString:CONN_CONNECTING]) {
        _connectivityStatus=CONN_IDLE;
        [networkInterface stopListen];
        [mUIL startWifiPrompt];
    } else if ([_connectivityStatus isEqualToString:CONN_CONNECTED]) {
        _connectivityStatus=CONN_CONNECTED_NO_WIFI;
        [networkInterface stopListen];
        waitingOnHost=true;
        [self cancelMoveState];
        [mUIL startWifiPrompt];
    } else if ([_connectivityStatus isEqualToString:CONN_POLL_RECONNECT]) {
        _connectivityStatus=CONN_CONNECTED_NO_WIFI;
        [mUIL stopReconnect];
        [mUIL startWifiPrompt];
    }
}

-(void)onStart {
    [DPCLogger log:LOG_TAG msg:@"onStart"];
    [networkInterface onStart];
}

-(void)onStop {
    [DPCLogger log:LOG_TAG msg:@"onStop"];
    [networkInterface onStop];
}

-(void) notifyConnectResult:(BOOL)result tableName:(NSString*) tableName {
    [DPCLogger log:LOG_TAG msg:@"notifyConnectResult"];
    if (result) {
        _connectivityStatus=CONN_CONNECTED;
        _tableName=tableName;
        _plaqueRect.touchable=NO;
        DPCUILayer* mUIL=[[DPCGame sharedGame]getUILayer];
        [mUIL stopReconnect];
        [mUIL showTableStatusMenu:tableName];
        waitingOnHost=false;
    } else {
        if ([_connectivityStatus isEqualToString:CONN_CONNECTING]) {
            [self cancelBuyin];
        }
    }
}

-(void)notifyConnectionLost {
    [DPCLogger log:LOG_TAG msg:@"notifyConnectionLost"];
    if ([_connectivityStatus isEqualToString:CONN_CONNECTED]) {
        waitingOnHost=true;
        [self cancelMoveState];
        [[[DPCGame sharedGame] getUILayer] startReconnect];
        [self startPollReconnect];
    }
}

-(void) submitBet {
    [DPCLogger log:LOG_TAG msg:@"submitBet"];
    int moveType;
    if (![self isAllIn]) {
        moveType=MOVE_BET;
    } else {
        moveType=MOVE_ALL_IN;
    }
    DPCMove* thisMove=[[DPCMove alloc] initWithMoveType:moveType chipString:[_betStack description]];
    [self sendMove:thisMove];
    chipAmount-=_betStack.value;
    [_betStack clear];
    _betStack.position=betStackOrigin;
    [self disableBet];
    [self disableCheck];
    [self disableFold];
    [[[DPCGame sharedGame]getUILayer] hideTextMessage];
    [_connectionBlob fadeOut];
}

-(void) doWin:(DPCChipStack*) winStack {
    [DPCLogger log:LOG_TAG msg:@"doWin"];
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
    chipAmount+=_cancellingStack.value;
    if (_pickedUpChip!=nil) {
        DPCChipStack* thisStack=[_mainStacks objectAtIndex:_pickedUpChip.chipType];
        float newZ=thisStack.renderSize+_cancellingStack.size;
        if (newZ>_pickedUpChip.z) {
            _pickedUpChip.zDest=newZ;
        }
    }
    [[[DPCGame sharedGame]getUILayer] stopWaitNextHand];
}

-(void) promptMove:(DPCMovePrompt*)movePrompt {
    [DPCLogger log:LOG_TAG msg:@"promptMove"];
    if (movePrompt.messageStateChange.length==0) {
        if (movePrompt.foldEnabled) {
            [self enableFold];
        }
        if (movePrompt.stake==0) {
            [self enableCheck];
            if (_betStack.size>0) {
                _checkButton.touchable=NO;
                [_checkButton fadeOut];
            }
        }
        [self enableBet];
        betStake=movePrompt.stake;
        [[OALSimpleAudio sharedInstance] playEffect:@"bell.wav"];
        [self textMessage:movePrompt.message];
        [_connectionBlob fadeIn];
    } else {
        [[[DPCGame sharedGame] getUILayer] promptStateChange:movePrompt.messageStateChange];
        movePrompt.messageStateChange=@"";
        pendingMovePrompt=movePrompt;
    }
}

-(void) stateChangeACKed {
    [DPCLogger log:LOG_TAG msg:@"stateChangeACKed"];
     DPCUILayer* mUIL=[[DPCGame sharedGame]getUILayer] ;
    [mUIL stateChangeACKed];
    [self promptMove:pendingMovePrompt];
}

-(void)bellButtonPressed {
    NSString* name=[[DPCGame sharedGame]getUILayer].tableStatusMenu.nudgeName;
    [networkInterface sendBell:name];
}

-(void) textMessage:(NSString*) message {
    [DPCLogger log:LOG_TAG msg:@"textMessage"];
    if ([message length]==0) {
        [[[DPCGame sharedGame] getUILayer] hideTextMessage];
    } else {
        [[[DPCGame sharedGame] getUILayer] showTextMessage:message];
    }
}

-(void) setDealer:(BOOL)isDealer_ {
    [DPCLogger log:LOG_TAG msg:@"setDealer"];
    isDealer=isDealer_;
    if (isDealer) {
        _dealerButton.opacity=1;
    }
}

-(void) showConnection {
    [DPCLogger log:LOG_TAG msg:@"showConnection"];
    [_connectionBlob fadeIn];
}

-(void) hideConnection {
    [DPCLogger log:LOG_TAG msg:@"hideConnection"];
    [_connectionBlob fadeOut];
}

-(void)notifyBootedByHost {
    [DPCLogger log:LOG_TAG msg:@"notifyBootedByHost"];
    if ([_connectivityStatus isEqualToString:CONN_CONNECTED]) {
        _connectivityStatus=CONN_IDLE;
        [self notifyTableDisconnected];
        [self notifyReadyToSearch];
    }
}

-(void) notifyWaitNextHand {
    [DPCLogger log:LOG_TAG msg:@"notifyWaitNextHand"];
    [[[DPCGame sharedGame]getUILayer] startWaitNextHand];
}

-(void)syncStatusMenu:(NSMutableArray *)playerList {
    [DPCLogger log:LOG_TAG msg:@"syncStatusMenu"];
    [[[DPCGame sharedGame]getUILayer].tableStatusMenu syncStatusMenu:playerList];
}

-(void)doBell {
    [[OALSimpleAudio sharedInstance] playEffect:@"bell.wav"];
}

-(void)cancelMove {
    [DPCLogger log:LOG_TAG msg:@"cancelMove"];
    [self cancelMoveState];
}

-(void)enableNudge:(NSString*)name {
    [[[DPCGame sharedGame]getUILayer].tableStatusMenu enableNudge:name];
}

-(void)disableNudge {
    [[[DPCGame sharedGame]getUILayer].tableStatusMenu disableNudge];
}

-(void)syncChipsToAmount:(int)newChipAmount {
    [DPCLogger log:LOG_TAG msg:@"syncChipsToAmount"];
    int difference=newChipAmount-chipAmount;
    if (difference>0) {
        DPCChipStack* syncStack=[[DPCChipStack alloc]init];
        NSArray* simplestBuild=[[[DPCGame sharedGame] getWorldLayer].chipCase calculateSimplestBuild:difference];
        [syncStack buildStackFrom:simplestBuild];
        [self doWin:syncStack];
    } else if (difference<0) {
        [self clearAllStacks];
        DPCChipStack* syncStack=[[DPCChipStack alloc]init];
        NSArray* simplestBuild=[[[DPCGame sharedGame] getWorldLayer].chipCase calculateSimplestBuild:newChipAmount];
        [syncStack buildStackFrom:simplestBuild];
        [self doWin:syncStack];
    }
}

-(int)calculateChipAmount {
    [DPCLogger log:LOG_TAG msg:@"calculateChipAmount"];
    int amount=0;
    for (int i=0;i<CHIP_CASE_CHIP_TYPES;i++) {
        DPCChipStack* thisStack=[_mainStacks objectAtIndex:i];
        amount+=thisStack.value;
    }
    amount+=_bettingStack.value;
    amount+=_betStack.value;
    amount+=_cancellingStack.value;
    amount+=_cancelStack.value;
    return amount;
}

-(void) cancelBuyin {
    [DPCLogger log:LOG_TAG msg:@"cancelBuyin"];
    [_joinToken fadeOut];
    _connectivityStatus=CONN_IDLE;
    [self searchHoldoff];
    [[[DPCGame sharedGame] getUILayer] stopBuyin];
}

@end
