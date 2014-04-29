//
//  DPCDialog.h
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 10/04/14.
//
//

#import "DPCSprite.h"

@interface DPCDialog : DPCSprite

@property CGPoint positionWindow;
@property float xWindowRadius;
@property float yWindowRadius;

-(void) start;
-(void) stop;
-(void) disappear;
-(void) setRadiusX:(int)radiusX radiusY:(int)radiusY;
-(void) setPosition:(CGPoint)position;
-(void) animate:(float)delta;

@end
