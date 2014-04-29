//
//  DPCTextLabel.m
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 16/04/14.
//
//

#import "DPCTextLabel.h"

@interface DPCTextLabel () {
    int waitTimer;
    int fadeFadeNone;
    int fadeFadeIn;
    int fadeFadeOut;
    int fadeWaitVisible;
    int fadeWaitInvisible;
    
    BOOL flashing;
}
@end

@implementation DPCTextLabel

-(id)init {
    if (self=[super init]) {
        fadeFadeNone=0;
        fadeFadeIn=1;
        fadeFadeOut=2;
        fadeWaitVisible=3;
        fadeWaitInvisible=4;
        _fadeState=fadeFadeNone;
        
        _flashVisibleTime=100;
        _flashInvisibleTime=300;
        
        flashing=NO;
    }
    return self;
}

-(void)setOpacity:(CGFloat)opacity {
    [super setOpacity:opacity];
    if (opacity==0) {
        self.visible=NO;
    } else {
        self.visible=YES;
    }
}

-(void)fadeIn {
    self.fadeState=fadeFadeIn;
    flashing=NO;
}

-(void)fadeOut {
    self.fadeState=fadeFadeOut;
    flashing=NO;
}

-(void)startFlashing {
    flashing=YES;
    if (_fadeState==fadeFadeNone) {
        _fadeState=fadeFadeIn;
    }
}

-(void)stopFlashing {
    flashing=NO;
    _fadeState=fadeFadeNone;
}

-(void)animate:(float)delta {
    if (self.fadeState==fadeFadeIn) {
        
        float deltaOpacity=delta*2*1;
        if (self.opacity+deltaOpacity>=1) {
            self.opacity=1;
            self.fadeState=fadeWaitVisible;
            waitTimer=0;
        } else {
            self.opacity=self.opacity+deltaOpacity;
        }
    } else if (self.fadeState==fadeFadeOut) {
        float deltaOpacity=-delta*5*1;
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
            if (flashing) {
                self.fadeState=fadeFadeOut;
            } else {
                self.fadeState=fadeFadeNone;
            }
            
        }
    } else if (self.fadeState==fadeWaitInvisible) {
        waitTimer+=delta*1000;
        if (waitTimer>_flashInvisibleTime) {
            if (flashing) {
                self.fadeState=fadeFadeIn;
            } else {
                self.fadeState=fadeFadeNone;
            }
        }
    }
} 

@end
