//
//  DPCDialog.m
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 10/04/14.
//
//

#import "DPCDialog.h"

@implementation DPCDialog

-(void) start {
    self.visible=YES;
}

-(void) stop {}

-(void) setRadiusX:(int)radiusX radiusY:(int)radiusY {
    _xWindowRadius=radiusX;
    _yWindowRadius=radiusY;
}

-(void) setPosition:(CGPoint)position {
    [super setPosition:position];
    //_positionWindow=position;
}

-(void)animate:(float)delta {
    
}

@end
