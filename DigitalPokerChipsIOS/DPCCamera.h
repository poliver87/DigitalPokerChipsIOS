//
//  DPCCamera.h
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 4/04/14.
//
//

#import <Foundation/Foundation.h>

#import "DPCCameraPosition.h"
#import "cocos2d.h"

typedef enum
{
    ANIM_NONE,
	ANIM_ZOOMING,
	ANIM_PANNING,
    ANIM_ZOOMING_AND_PANNING,
} CameraAnimationState;

@interface DPCCamera : NSObject {
    CameraAnimationState animationState;
    float x;
    float y;
    float zoom;
}

@property BOOL updateNeeded;

-(void)setToPosition:(DPCCameraPosition*)cameraPosition;
-(void)sendToPosition:(DPCCameraPosition*)destPosition;
-(void)animate:(CCTime)delta;
-(void)updateLayer:(CCNode*)layer;
-(CGPoint)convertScreenToWorld:(CGPoint)screenPoint;

+(float)getScreenTopInWorld:(DPCCameraPosition*)pos;

@end
