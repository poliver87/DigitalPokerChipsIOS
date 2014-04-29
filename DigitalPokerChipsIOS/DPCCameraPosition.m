//
//  DPCCameraPosition.m
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 4/04/14.
//
//

#import "DPCCameraPosition.h"

@implementation DPCCameraPosition

-(id) initWithTag:(NSString*)tag {
    if(self = [super init]) {
        self.tag=tag;
        self.zoom=1;
    }
    return self;    
}

-(void) setX:(float)x y:(float)y zoom:(float)zoom {
    self.x=x;
    self.y=y;
    self.zoom=zoom;
}

@end
