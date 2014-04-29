//
//  DPCDialogWindow.m
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 10/04/14.
//
//

#import "DPCDialogWindow.h"

@interface DPCDialogWindow () {
    BOOL resizing;
	BOOL moving;
	
    CGPoint posLast;
    float radiusXLast;
    float radiusYLast;
	
	DPCDialog* dialogDest;
}
@end

@implementation DPCDialogWindow

-(id) init {
    if (self=[super init]) {
        resizing=NO;
        moving=NO;
    }
    return self;
}

-(void)animate:(double)delta {
    [super animate:delta];
    if (moving) {
        if (fabsf(self.position.y-self.destination.y)<1&&
            fabsf(self.position.x-self.destination.x)<1) {
            moving=false;
            self.position=self.destination;
            [dialogDest start];
        } else {
            float timeFactor_=delta*9;
            float yNew=(float)(self.position.y-timeFactor_*(self.position.y-self.destination.y));
            float xNew=(float)(self.position.x-timeFactor_*(self.position.x-self.destination.x));
            [self setPosition:CGPointMake(xNew,yNew)];
        }
        if (resizing) {
            if (!moving) {
                resizing=false;
                [self setRadiusX:self.radiusDestination.width radiusY:self.radiusDestination.height];
            } else {
                double distToTravel=ccpLength(ccpSub(self.destination,posLast));
                double distTravelled=ccpLength(ccpSub(self.position,posLast));
                float travelRatio=(float) (distTravelled/distToTravel);
                self.radiusX=(int) (radiusXLast+travelRatio*(self.radiusDestination.width-radiusXLast));
                self.radiusY=(int) (radiusYLast+travelRatio*(self.radiusDestination.height-radiusYLast));
            }
        }
    } else if (resizing) {
        BOOL xDone=false;
        if (self.radiusDestination.width>self.radiusX) {
            self.radiusX=(int)(self.radiusX+delta*6*(self.radiusX))+1;
            if (self.radiusX>=self.radiusDestination.width) {
                xDone=true;
                self.radiusX=self.radiusDestination.width;
            }
        } else {
            if (fabsf(self.radiusX-self.radiusDestination.width)<=1) {
                xDone=true;
                self.radiusX=self.radiusDestination.width;
            } else {
                float timeFactor=delta*9;
                self.radiusX=(int)(self.radiusX-timeFactor*(self.radiusX-self.radiusDestination.width));
            }
        }
        BOOL yDone=false;
        if (self.radiusDestination.height>self.radiusY) {
            self.radiusY=(int)(self.radiusY+delta*6*(self.radiusY))+1;
            if (self.radiusY>=self.radiusDestination.height) {
                yDone=true;
                self.radiusY=self.radiusDestination.height;
            }
        } else {
            if (fabsf(self.radiusY-self.radiusDestination.height)<=1) {
                yDone=true;
                self.radiusY=self.radiusDestination.height;
            } else {
                float timeFactor=delta*9;
                self.radiusY=(int)(self.radiusY-timeFactor*(self.radiusY-self.radiusDestination.height));
            }
        }
        if (xDone&&yDone) {
            resizing=false;
            [dialogDest start];
        }
    }
}

-(void)sendTo:(DPCDialog*)dialogDest_ {
    dialogDest=dialogDest_;
    if (self.position.x!=dialogDest_.position.x||self.position.y!=dialogDest_.position.y) {
        moving=true;
        [self setDest:CGPointMake(dialogDest_.position.x,dialogDest_.position.y)];
        posLast=self.position;
    }
    if (self.radiusX!=dialogDest_.xWindowRadius||self.radiusY!=dialogDest_.yWindowRadius) {
        resizing=true;
        [self setRadiusDest:CGSizeMake(dialogDest_.xWindowRadius,dialogDest_.yWindowRadius)];
        radiusXLast=self.radiusX;
        radiusYLast=self.radiusY;
    }
}

-(void)remove {
    moving=NO;
    resizing=NO;
}

@end
