//
//  DPCTextLabel.h
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 16/04/14.
//
//

#import "CCLabelTTF.h"

@interface DPCTextLabel : CCLabelTTF

@property int fadeState;

@property int flashVisibleTime;
@property int flashInvisibleTime;

-(void)fadeIn;
-(void)fadeOut;
-(void)startFlashing;
-(void)stopFlashing;
-(void)animate:(float)delta;

@end
