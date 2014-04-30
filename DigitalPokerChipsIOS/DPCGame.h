//
//  DPCGame.h
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 1/04/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "cocos2d.h"
#import "Reachability.h"
#import "DPCWorldLayer.h"
#import "DPCUILayer.h"

extern NSString* DEBUG_LOG_LIFECYCLE_TAG;
extern const NSString* DEBUG_LOG_NETWORK_TAG;
extern const NSString* DEBUG_LOG_TABLE_TAG;
extern const NSString* DEBUG_LOG_PLAYER_TAG;
extern const NSString* DEBUG_LOG_GAME_MOVES_TAG;

@interface DPCGame : CCScene <UIGestureRecognizerDelegate,CLLocationManagerDelegate> {
    
}

@property (strong,nonatomic) Reachability* reachability;
@property (nonatomic) BOOL wifiEnabled;
@property (nonatomic) CLLocationManager* locationManager;
@property int azimuth;

+(CCScene*) scene;
+(DPCGame*) sharedGame;
+(BOOL) sharedGameAvailable;
-(DPCWorldLayer*) getWorldLayer;
-(DPCUILayer*) getUILayer;
-(void)onStart;
-(void)onStop;

@end
