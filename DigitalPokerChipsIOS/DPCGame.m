//
//  DPCGame.m
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 1/04/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "Reachability.h"

#import "DPCGame.h"
#import "DPCWorldLayer.h"
#import "DPCUILayer.h"

NSString* DEBUG_LOG_LIFECYCLE_TAG=@"DPCLifecycle";
const NSString* DEBUG_LOG_NETWORK_TAG=@"DPCNetwork";
const NSString* DEBUG_LOG_TABLE_TAG=@"DPCTable";
const NSString* DEBUG_LOG_PLAYER_TAG=@"DPCPlayer";
const NSString* DEBUG_LOG_GAME_MOVES_TAG=@"DPCGameMoves";


@interface DPCGame () {
    DPCWorldLayer* worldLayer;
    DPCUILayer* uiLayer;
    
    float limVelocityFling;
    float limTranslationFling;
    int headingTimer;
}

@end

@implementation DPCGame

typedef enum {
    Z_WORLD_LAYER,
    Z_UI_LAYER,
} ZOrderLayers;

static DPCGame* sharedDPCGame = nil;

+(DPCGame*) sharedGame
{
	NSAssert(sharedDPCGame != nil, @"DPCGame not available!");
	return sharedDPCGame;
}

+(BOOL) sharedGameAvailable {
    return (sharedDPCGame!=nil);
}

-(DPCWorldLayer*) getWorldLayer {
    return worldLayer;
}

-(DPCUILayer*) getUILayer {
    return uiLayer;
}

+(CCScene*) scene {
    sharedDPCGame = [DPCGame node];
    return sharedDPCGame;
}

-(id) init {
    if ((self=[super init])) {
        _azimuth=0;
        self.locationManager = [[CLLocationManager alloc]init];
        if ([CLLocationManager headingAvailable]==NO) {
            self.locationManager=nil;
        } else {
            self.locationManager.headingFilter=kCLHeadingFilterNone;
            self.locationManager.delegate=self;
            [self.locationManager startUpdatingHeading];
        }
        
        _reachability = [Reachability reachabilityForLocalWiFi];
        
        [_reachability startNotifier];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:kReachabilityChangedNotification object:nil];
        _wifiEnabled=NO;
        
        float height=[CCDirector sharedDirector].viewSize.height;
        limVelocityFling=height*0.15f;
        limTranslationFling=height*0.04f;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        pan.delegate = self;
        pan.cancelsTouchesInView=NO;
        
        worldLayer = [DPCWorldLayer node];
        [self addChild:worldLayer z:Z_WORLD_LAYER];
        uiLayer = [DPCUILayer node];
        [self addChild:uiLayer z:Z_UI_LAYER];
        [[[CCDirector sharedDirector] view].superview addGestureRecognizer:pan];
        
        
    }
    return self;
}

-(void)dealloc {
    worldLayer.userInteractionEnabled=NO;
    sharedDPCGame=nil;
    worldLayer=nil;
    uiLayer=nil;
}

-(void) onEnter {
    [super onEnter];
    [worldLayer resize:[[CCDirector sharedDirector] viewSize]];
    [uiLayer resize:[[CCDirector sharedDirector] viewSize]];
    [worldLayer initialiseCamera];
    [self setWifiEnabled:[_reachability isReachableViaWiFi]];
}

-(void)onStart {
    [worldLayer onStart];
}

-(void)onStop {
    [worldLayer onStop];
}

- (void)handlePanGesture:(UIPanGestureRecognizer*)aPanGestureRecognizer {
    CGPoint translation=[aPanGestureRecognizer translationInView:[CCDirector sharedDirector].view];
    CGPoint velocity=[aPanGestureRecognizer velocityInView:[CCDirector sharedDirector].view];
    BOOL handled=NO;
    if (aPanGestureRecognizer.state==UIGestureRecognizerStateEnded) {
        if (ccpLength(translation)>limTranslationFling&&ccpLength(velocity)>limVelocityFling) {
            handled=[worldLayer fling:velocity];
        }
    }
    if (handled) {
        [aPanGestureRecognizer setCancelsTouchesInView:YES];
    } else {
        [aPanGestureRecognizer setCancelsTouchesInView:NO];
    }
}



- (void)reachabilityDidChange:(NSNotification *)notification {
    NSObject *object = [notification object];
    Reachability* reachability=(Reachability*)object;
    [self setWifiEnabled:[reachability isReachableViaWiFi]];
}

-(void)setWifiEnabled:(BOOL)en {
    BOOL switchedOn=(_wifiEnabled==NO&&en==YES);
    BOOL switchedOff=(_wifiEnabled==YES&&en==NO);
    _wifiEnabled=en;
    if (switchedOn) {
        [worldLayer wifiOn];
    } else if (switchedOff) {
        [worldLayer wifiOff];
    }
}

-(void)locationManager:(CLLocationManager*)manager didUpdateHeading:(CLHeading *)newHeading {
    if (CACurrentMediaTime()-headingTimer>0.5f) {
        headingTimer=CACurrentMediaTime();
        self.azimuth=newHeading.magneticHeading;
        UIDeviceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (orientation==UIInterfaceOrientationLandscapeRight) {
            self.azimuth=(self.azimuth-180)>=0?self.azimuth-180:self.azimuth+180;
        }
    }
}

@end
