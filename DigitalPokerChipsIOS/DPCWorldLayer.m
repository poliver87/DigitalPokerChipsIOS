//
//  WorldLayer.m
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 1/04/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "DPCGame.h"
#import "DPCWorldLayer.h"
#import "DPCCamera.h"
#import "DPCCameraPosition.h"
#import "DPCLogger.h"

@interface DPCWorldLayer () {
    
}
@end

@implementation DPCWorldLayer



-(id) init {
    if ((self=[super init])) {
        _mCamera = [[DPCCamera alloc] init];
        
        CCSprite *background_lb = [CCSprite spriteWithImageNamed:@"background_lb.png"];
        CCSprite *background_lt = [CCSprite spriteWithImageNamed:@"background_lt.png"];
        CCSprite *background_mb = [CCSprite spriteWithImageNamed:@"background_mb.png"];
        CCSprite *background_mt = [CCSprite spriteWithImageNamed:@"background_mt.png"];
        CCSprite *background_rb = [CCSprite spriteWithImageNamed:@"background_rb.png"];
        CCSprite *background_rt = [CCSprite spriteWithImageNamed:@"background_rt.png"];
        [self addChild: background_lb];
        [self addChild: background_lt];
        [self addChild: background_mb];
        [self addChild: background_mt];
        [self addChild: background_rb];
        [self addChild: background_rt];
        CGPoint halfTileDim=ccp(0.5f*background_lb.contentSize.width,0.5f*background_lb.contentSize.height);
        background_lb.position=halfTileDim;
        background_lt.position=CGPointMake(halfTileDim.x,halfTileDim.y*3);
        background_mb.position=CGPointMake(halfTileDim.x*3,halfTileDim.y);
        background_mt.position=CGPointMake(halfTileDim.x*3,halfTileDim.y*3);
        background_rb.position=CGPointMake(halfTileDim.x*5,halfTileDim.y);
        background_rt.position=CGPointMake(halfTileDim.x*5,halfTileDim.y*3);
        
        _worldWidth = 3*background_lb.contentSize.width;
        _worldHeight = 2*background_lb.contentSize.height;
        
        _input=[[DPCWorldInput alloc] init];
        
        [DPCChip setRadiusX:(int) (_worldWidth*0.02f)];
        [DPCChip setRadiusY:(int) (_worldWidth*0.0196f)];
        
        _chipCase=[DPCChipCase chipCase];
        [_chipCase setValue:25 chipType:CHIP_CASE_CHIP_A];
        [_chipCase setValue:100 chipType:CHIP_CASE_CHIP_B];
        [_chipCase setValue:200 chipType:CHIP_CASE_CHIP_C];
        
        _thisPlayer=[[DPCThisPlayer alloc] initWithWorldLayer:self];
        
        self.contentSize=CGSizeMake(_worldWidth,_worldHeight);
        self.userInteractionEnabled=YES;
        
    }
    return self;
}

-(NSString*)description {
    return @"DPCWorldLayer";
}

-(void) initialiseCamera {
    [self sendCameraTo:_camPosHome];
    [_mCamera setToPosition:_cameraDestination];
    [_mCamera updateLayer:self];
}

-(void)resize:(CGSize)size {
    CGSize screenSize = [[CCDirector sharedDirector] viewSize];
    CCLOG(@"width: %f",screenSize.width);
    CCLOG(@"height: %f",screenSize.height);
    [self setWorldWidth:_worldWidth height:_worldHeight];
    [self setPositions:_worldWidth height:_worldHeight];
}

-(void)setWorldWidth:(int)worldWidth height:(int)worldHeight {
    [_thisPlayer setWorldWidth:worldWidth height:worldHeight];
}

-(void)setPositions:(int)worldWidth height:(int)worldHeight {
    CGSize screenSize = [[CCDirector sharedDirector] viewSize];
    float scaleZoomedOut = screenSize.height/_worldHeight;
    CCLOG(@"scaleZoomedOut: %f",scaleZoomedOut);
    float scaleZoomedIn=scaleZoomedOut*3.5;
    
    _camPosHome = [[DPCCameraPosition alloc] initWithTag:@"Home"];
    [_camPosHome setX:worldWidth*0.5f y:worldHeight*0.5f zoom:scaleZoomedOut];
    _camPosPlayer = [[DPCCameraPosition alloc] initWithTag:@"Player"];
    [_camPosPlayer setX:worldWidth*0.5f y:worldHeight*0.315f zoom:scaleZoomedIn];
    _camPosTable = [[DPCCameraPosition alloc] initWithTag:@"Table"];
    [_camPosTable setX:worldWidth*0.5f y:worldHeight*0.5f zoom:scaleZoomedIn];
    _camPosPlayersName = [[DPCCameraPosition alloc] initWithTag:@"Player's Name"];
    [_camPosPlayersName setX:worldWidth*0.5f y:worldHeight*0.12f zoom:scaleZoomedIn];
    _camPosTableName = [[DPCCameraPosition alloc] initWithTag:@"Table Name"];
    [_camPosTableName setX:worldWidth*0.5f y:worldHeight*0.44f zoom:scaleZoomedIn];
    _camPosChipCase = [[DPCCameraPosition alloc] initWithTag:@"Chip Case"];
    [_camPosChipCase setX:worldWidth*0.5f y:worldHeight*0.75f zoom:scaleZoomedIn];
    
    [_thisPlayer setPositions:worldWidth height:worldHeight];
}

-(void)update:(CCTime) delta {
    [_mCamera animate:delta];
    if (_mCamera.updateNeeded) {
        [_mCamera updateLayer:self];
    }
    [_thisPlayer animate:(float)delta];
    [_thisPlayer collisionDetector];
}

    //////////////////// Navigation Control ////////////////////
-(void) sendCameraTo:(DPCCameraPosition*) camPos {
    [self cameraLeftPosition:_cameraDestination];
    CCLOG(@"Camera sent to %@",camPos.tag);
    _cameraDestination=camPos;
    [_mCamera sendToPosition:camPos];
    if (_cameraDestination==_camPosHome) {
        [[[DPCGame sharedGame] getUILayer] startHome];
    }
}

-(void) cameraLeftPosition:(DPCCameraPosition*) camPos {
    BOOL validPosition=NO;
    if (camPos==_camPosHome) {
        [[[DPCGame sharedGame] getUILayer] stopHome];
        validPosition=YES;
    } else if (camPos==_camPosPlayersName) {
        [_thisPlayer notifyLeftNamePosition];
        validPosition=YES;
    } else if (camPos==_camPosPlayer) {
        [_thisPlayer notifyLeftPlayerPosition];
        validPosition=YES;
    } else if (camPos==_camPosTableName) {
        //table.notifyLeftTableNamePosition();
        validPosition=YES;
    } else if (camPos==_camPosChipCase) {
        //table.notifyLeftChipCasePosition();
        validPosition=YES;
    } else if (camPos==_camPosTable) {
        //table.notifyLeftTablePosition();
        validPosition=YES;
    }
}

-(void) cameraAtDestination {
    if (_cameraDestination==_camPosHome) {
        ;
    } else if (_cameraDestination==_camPosPlayer) {
        [_thisPlayer notifyAtPlayerPosition];
    } else if (_cameraDestination==_camPosPlayersName) {
        [_thisPlayer notifyAtNamePosition];
    } else if (_cameraDestination==_camPosTable) {
        //table.notifyAtTablePosition();
    } else if (_cameraDestination==_camPosTableName) {
        //table.notifyAtTableNamePosition();
    } else if (_cameraDestination==_camPosChipCase) {
        //table.notifyAtChipCasePosition();
    } else {
        //
    }
    CCLOG(@"Camera at %@",_cameraDestination.tag);
}

-(void) navigateBack {
    if (_cameraDestination==_camPosHome) {        
        //game.exitApp();
    } else if (_cameraDestination==_camPosPlayersName) {
        ;
    } else if (_cameraDestination==_camPosPlayer) {
        if ([_thisPlayer backPressed]) {
            [self sendCameraTo:_camPosHome];
        }
    } else if (_cameraDestination==_camPosTableName) {
        [self sendCameraTo:_camPosHome];
    } else if (_cameraDestination==_camPosChipCase) {
        [self sendCameraTo:_camPosTableName];
    } else if (_cameraDestination==_camPosTable) {
        //table.backPressed();
    } else {
        //
    }
}

-(void) wifiOn {
    [_thisPlayer wifiOn];
}

-(void) wifiOff {
    [_thisPlayer wifiOff];
}

-(void)onStart {
    [_thisPlayer onStart];
}

-(void)onStop {
    [_thisPlayer onStop];
}

-(void)touchBegan:(UITouch*)touch withEvent:(UIEvent*)event {
    CGPoint touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    CCLOG(@" ");
    CCLOG(@"World touch began");
    [_input touchDown:touchPoint];
}

-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    [_input touchDragged:touchPoint];
}

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    CCLOG(@"World touch ended");
    [_input touchUp:touchPoint];
}

-(BOOL)fling:(CGPoint)velocity {
    velocity = ccp(velocity.x,-1*velocity.y);
    CCLOG(@"World fling");
    return [_input fling:velocity];
}

@end
