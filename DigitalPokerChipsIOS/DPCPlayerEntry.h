//
//  DPCPlayerEntry.h
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 23/04/14.
//
//

#import <Foundation/Foundation.h>
#import "DPCTextLabel.h"

@interface DPCPlayerEntry : CCNode

@property NSString* hostName;
@property int amount;
@property DPCTextLabel* playerName;
@property DPCTextLabel* amountLabel;

-(id)initWithHostName:(NSString*)hostName playerName:(NSString*)playerName amount:(int)amount;
-(NSComparisonResult)compare:(DPCPlayerEntry*)otherObject;

+(void)setTextSize:(int)size;
+(void)setNameXOffset:(float)offset;
+(void)setAmountXOffset:(float)offset;

@end
