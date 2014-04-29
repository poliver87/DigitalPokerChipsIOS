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

@interface DPCGame : CCScene <UIGestureRecognizerDelegate,CLLocationManagerDelegate> {
    
}

@property (strong,nonatomic) Reachability* reachability;
@property (nonatomic) BOOL wifiEnabled;
@property (nonatomic) CLLocationManager* locationManager;
@property int azimuth;

+(CCScene*) scene;
+(DPCGame*) sharedGame;
-(DPCWorldLayer*) getWorldLayer;
-(DPCUILayer*) getUILayer;

@end
