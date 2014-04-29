//
//  DPCSprite.m
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 7/04/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import "DPCSprite.h"

@interface DPCSprite () {
    int waitTimer;
    
    int fadeFadeNone;
    int fadeFadeIn;
    int fadeFadeOut;
    int fadeWaitVisible;
    int fadeWaitInvisible;
}
@end

@implementation DPCSprite


+(id)DPCSpriteWithFile:(NSString*)file {
    DPCSprite* thisSprite=[self spriteWithImageNamed:file];
    [thisSprite initState];
    return thisSprite;
}

-(id)init {
    if (self=[super init]) {
        [self initState];
    }
    return self;
}

-(void)initState {
    fadeFadeNone=0;
    fadeFadeIn=1;
    fadeFadeOut=2;
    fadeWaitVisible=3;
    fadeWaitInvisible=4;
    _fadeState=fadeFadeNone;
    
    _flashVisibleTime=100;
    _flashInvisibleTime=300;
    _fadeInSpeed=2;
    _fadeOutSpeed=5;
    
    _touchAreaMultiplier=1;
}

-(void)setOpacity:(CGFloat)opacity {
    [super setOpacity:opacity];
    if (opacity==0) {
        self.visible=NO;
    } else {
        self.visible=YES;
    }
}

-(void)setRadiusX:(int)radiusX radiusY:(int)radiusY {
    _radiusX=radiusX;
    _radiusY=radiusY;
    self.scaleX=(radiusX*2)/self.contentSize.width;
    self.scaleY=(radiusY*2)/self.contentSize.height;
}

-(void)setRadiusX:(int)radiusX {
    _radiusX=radiusX;
    self.scaleX=(radiusX*2)/self.contentSize.width;
}

-(void)setRadiusY:(int)radiusY {
    _radiusY=radiusY;
    self.scaleY=(radiusY*2)/self.contentSize.height;
}

-(void)setX:(float)x y:(float)y {
    [self setPosition:CGPointMake(x,y)];
}

-(void)setPosition:(CGPoint)position {
    [super setPosition:position];
}

-(void)setDest:(CGPoint)destination {
    _destination=destination;
}

-(void)setDestToPos {
    self.destination=self.position;
    self.zDest=self.z;
}

-(void)setXFromTouch:(CGPoint)touch {
    touch=[self.parent convertToNodeSpace:touch];
    self.position=ccp(touch.x,self.position.y);
}

-(void)setRadiusDest:(CGSize)radiusDest {
    _radiusDestination=radiusDest;
}

-(BOOL)pointContained:(CGPoint)point {
    BOOL contained=NO;
    //int radiusXRotated=(int) (Math.sin(Math.toRadians(rotation))*radiusY+Math.cos(Math.toRadians(rotation))*radiusX);
    //radiusXRotated=(Math.abs(radiusXRotated));
    //int radiusYRotated=(int) (Math.sin(Math.toRadians(rotation))*radiusX+Math.cos(Math.toRadians(rotation))*radiusY);
    //radiusYRotated=(Math.abs(radiusYRotated));
    
    int radiusXRotated=_radiusX*_touchAreaMultiplier;
    int radiusYRotated=_radiusY*_touchAreaMultiplier;
    CGPoint pointInParent=[self.parent convertToNodeSpace:point];
    
    if (fabsf(pointInParent.x-self.position.x)<radiusXRotated*1&&
        (fabsf(pointInParent.y-self.position.y)<radiusYRotated*1)) {
        contained=true;
    }
    return contained;
}

-(void)fadeIn {
    self.fadeState=fadeFadeIn;
}

-(void)fadeOut {
    self.fadeState=fadeFadeOut;
}

-(void)animate:(CCTime)delta {
    if (self.fadeState==fadeFadeIn) {
        
        float deltaOpacity=delta*_fadeInSpeed*1;
        if (self.opacity+deltaOpacity>=1) {
            self.opacity=1;
            self.fadeState=fadeWaitVisible;
            waitTimer=0;
        } else {
            self.opacity=self.opacity+deltaOpacity;
        }
    } else if (self.fadeState==fadeFadeOut) {
        float deltaOpacity=-delta*_fadeOutSpeed*1;
        if (self.opacity+deltaOpacity<=0) {
            self.opacity=0;
            self.fadeState=fadeWaitInvisible;
            waitTimer=0;
        } else {
            self.opacity=self.opacity+deltaOpacity;
        }
    } else if (self.fadeState==fadeWaitVisible) {
        waitTimer+=delta*1000;
        if (waitTimer>_flashVisibleTime) {
            self.fadeState=fadeFadeNone;
        }
    } else if (self.fadeState==fadeWaitInvisible) {
        waitTimer+=delta*1000;
        if (waitTimer>_flashInvisibleTime) {
            self.fadeState=fadeFadeNone;
        }
    }
}

@end
