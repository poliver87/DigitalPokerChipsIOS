//
//  DPCSprite.h
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 7/04/14.
//  Copyright 2014 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface DPCSprite : CCSprite {
}


@property (nonatomic) int radiusX;
@property (nonatomic) int radiusY;
@property () CGPoint destination;
@property (readonly) CGSize radiusDestination;
@property CGPoint velocity;
@property () BOOL touchable;
@property float touchAreaMultiplier;
@property BOOL isTouched;
@property (nonatomic) CGPoint deltaTouch;
@property float z;
@property float zDest;
@property int fadeState;
@property int flashVisibleTime;
@property int flashInvisibleTime;
@property int fadeInSpeed;
@property int fadeOutSpeed;

+(id)DPCSpriteWithFile:(NSString*)file;
-(void)setRadiusX:(int)radiusX radiusY:(int)radiusY;
-(void)setX:(float)x y:(float)y;
-(void)setPosition:(CGPoint)position;
-(void)setPositionFromTouch:(CGPoint)touch;
-(void)setXFromTouch:(CGPoint)touch;
-(void)setDestFromTouch:(CGPoint)touch;
-(void)setDest:(CGPoint)destination;
-(void)setDestToPos;
-(void)setDeltaTouchFromTouch:(CGPoint)touch;
-(void)setRadiusDest:(CGSize)radiusDest;
-(BOOL)pointContained:(CGPoint)point;
-(void)fadeIn;
-(void)fadeOut;
-(void)animate:(double)delta;


@end
