//
//  DPCCameraPosition.h
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 4/04/14.
//
//

#import <Foundation/Foundation.h>

@interface DPCCameraPosition : NSObject {
    
}

-(id)initWithTag:(NSString*)tag;
-(void)setX:(float)x y:(float)y zoom:(float)zoom;

@property float x;
@property float y;
@property float zoom;
@property NSString *tag;

@end
