//
//  WorldLayer.h
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 1/04/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "DPCCameraPosition.h"
#import "DPCThisPlayer.h"
#import "DPCWorldInput.h"
#import "DPCCamera.h"
#import "DPCChipCase.h"

@interface DPCWorldLayer : CCNode {
}

@property DPCWorldInput* input;

@property DPCCamera* mCamera;

@property int worldWidth;
@property int worldHeight;

@property DPCCameraPosition *cameraDestination;
@property DPCCameraPosition *camPosHome;
@property DPCCameraPosition *camPosPlayer;
@property DPCCameraPosition *camPosTable;
@property DPCCameraPosition *camPosPlayersName;
@property DPCCameraPosition *camPosTableName;
@property DPCCameraPosition *camPosChipCase;

@property DPCChipCase* chipCase;
@property DPCThisPlayer* thisPlayer;

-(void)resize:(CGSize)size;
-(void)initialiseCamera;

-(void) sendCameraTo:(DPCCameraPosition*) camPos;
-(void) cameraAtDestination;
-(void) navigateBack;

-(void)wifiOn;
-(void)wifiOff;
-(void)onStart;
-(void)onStop;

-(BOOL) fling:(CGPoint)velocity;

@end
