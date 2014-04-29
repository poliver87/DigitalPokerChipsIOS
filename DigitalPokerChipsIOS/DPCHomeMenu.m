//
//  DPCHomeMenu.m
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 5/04/14.
//
//

#import "DPCHomeMenu.h"
#import "DPCSprite.h"
#import "DPCTextFactory.h"
#import "DPCTextLabel.h"

@interface DPCHomeMenu () {
    
    CGPoint posLogoOffscreen;
    CGPoint posLogoOnscreen;
    CGPoint posMenuCentreOffscreen;
    CGPoint posMenuCentreOnscreen;
    
    float yButtonPitch;
}
@end

@implementation DPCHomeMenu


-(id) init {
    if (self=[super init]) {
        animationState=STATE_NONE;
        _logoDPC=[DPCSprite DPCSpriteWithFile:@"logo_dpc.png"];
        _logoDPC.opacity=0;
        [self addChild:_logoDPC];
        _joinButton=[DPCSprite DPCSpriteWithFile:@"button_blue.png"];
        [self addChild:_joinButton];
        _joinButtonLabel=[DPCTextLabel node];
        [_joinButtonLabel setFontName:@"StoneSansSemiBooldItalic"];
        [_joinButtonLabel setString:@"Join a Table"];
        _joinButtonLabel.color=[CCColor colorWithRed:1 green:1 blue:1];
        
        [self addChild:_joinButtonLabel];
    }
    return self;
}

-(void) dealloc {
    _logoDPC=nil;
    _joinButton=nil;
}


-(void) setDimensionsScreenWidth:(int)screenWidth height:(int)screenHeight {
    [_logoDPC setRadiusX:(int)(screenHeight*0.36f) radiusY:(int)(screenHeight*0.12f)];
    int radiusXButton=(int)(screenHeight*0.3f);
    int radiusYButton=(int)(screenHeight*0.065f);
    float xPercentLabel=0.75f;
    float yPercentLabel=0.75f;
    [_joinButton setRadiusX:radiusXButton radiusY:radiusYButton];
    yButtonPitch=_joinButton.radiusY*2.2f;
    _joinButtonLabel.fontSize=[DPCTextFactory getMaxTextSize:_joinButtonLabel width:_joinButton.radiusX*1.5f height:_joinButton.radiusY*1.5f];
}

-(void) setPositionsScreenLeft:(float)screenLeft top:(float)screenTop right:(float)screenRight bottom:(float)screenBottom {
    
    posLogoOffscreen=CGPointMake(screenLeft+_logoDPC.radiusX*1.1f,screenTop+_logoDPC.radiusY*3.0f);
    posLogoOnscreen=CGPointMake(screenLeft+_logoDPC.radiusX*1.1f,screenTop-_logoDPC.radiusY*1.2f);
    posMenuCentreOffscreen=CGPointMake(screenLeft-_joinButton.radiusX*1.1f,(screenTop+screenBottom)*0.45f);
    posMenuCentreOnscreen=CGPointMake(screenLeft+_joinButton.radiusX*0.9f,(screenTop+screenBottom)*0.45f);
}

-(void) update:(CCTime)delta {
    delta=MIN(delta,0.1);
    
    if (animationState==STATE_SHOW_LOGO) {
        if (fabsf(_logoDPC.position.x-_logoDPC.destination.x)>2||
            fabsf(_logoDPC.position.y-_logoDPC.destination.y)>2) {
            float deltaX=9*delta*(_logoDPC.destination.x-_logoDPC.position.x);
            float deltaY=9*delta*(_logoDPC.destination.y-_logoDPC.position.y);
            CGPoint newPos=ccp(_logoDPC.position.x+deltaX,_logoDPC.position.y+deltaY);
            _logoDPC.position=newPos;
        } else {
            animationState=STATE_SHOW_MENU;
        }
    } else if (animationState==STATE_SHOW_MENU) {
        BOOL opened=true;
        if (fabsf(_joinButton.position.x-_joinButton.destination.x)>2||
            fabsf(_joinButton.position.y-_joinButton.destination.y)>2) {
            float deltaX=9*delta*(_joinButton.destination.x-_joinButton.position.x);
            float deltaY=9*delta*(_joinButton.destination.y-_joinButton.position.y);
            [_joinButton setX:_joinButton.position.x+deltaX y:_joinButton.position.y+deltaY];
            _joinButtonLabel.position=_joinButton.position;
            opened=false;
        }
        if (opened) {
            animationState=STATE_OPENED;
        }
    } else if (animationState==STATE_CLOSING) {
        BOOL closed=true;
        if (fabsf(_logoDPC.position.x-posLogoOffscreen.x)>2||
            fabsf(_logoDPC.position.y-posLogoOffscreen.y)>2) {
            float deltaX=9*delta*(posLogoOffscreen.x-_logoDPC.position.x);
            float deltaY=9*delta*(posLogoOffscreen.y-_logoDPC.position.y);
            CGPoint newPos=ccp(_logoDPC.position.x+deltaX,_logoDPC.position.y+deltaY);
            _logoDPC.position=newPos;
            closed=false;
        }
        if (fabsf(_joinButton.position.x-_joinButton.destination.x)>2||
            fabsf(_joinButton.position.y-_joinButton.destination.y)>2) {
            float deltaX=9*delta*(_joinButton.destination.x-_joinButton.position.x);
            float deltaY=9*delta*(_joinButton.destination.y-_joinButton.position.y);
            [_joinButton setX:_joinButton.position.x+deltaX y:_joinButton.position.y+deltaY];
            _joinButtonLabel.position=_joinButton.position;
            closed=false;
        }
        if (closed) {
            [self notifyClosed];
            animationState=STATE_CLOSED;
        }
    }
     
}

-(void) open:(BOOL) tablesPresent {
    animationState=STATE_SHOW_LOGO;
    _logoDPC.opacity=1;
    [_logoDPC setPosition:posLogoOffscreen];
    [_logoDPC setDest:posLogoOnscreen];
    int numButtons=1;
    int buttonIndex=0;
    float yTopButton=posMenuCentreOnscreen.y+yButtonPitch*0.5f*(numButtons-1);
    _joinButton.opacity=1;
    [_joinButton setX:posMenuCentreOffscreen.x y:yTopButton-yButtonPitch*buttonIndex];
    [_joinButton setDest:posMenuCentreOnscreen];
    
    _joinButtonLabel.position=_joinButton.position;
    _joinButton.touchable=YES;
}

-(void) close {
    animationState=STATE_CLOSING;
    [_logoDPC setDest:posLogoOffscreen];
    [_joinButton setDest:posMenuCentreOffscreen];
    [_joinButton setTouchable:NO];
}

-(void) notifyClosed {
    _joinButton.opacity=0;
    _logoDPC.opacity=0;
}

@end
