//
//  DPCPlayerEntry.m
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 23/04/14.
//
//

#import "DPCPlayerEntry.h"

@implementation DPCPlayerEntry

static int textSize=0;
static int nameXOffset=0;
static int amountXOffset=0;

-(id)initWithHostName:(NSString*)hostName playerName:(NSString*)playerName amount:(int)amount {
    if (self=[super init]) {
        _hostName=hostName;
        _playerName=[DPCTextLabel node];
        _playerName.string=playerName;
        _playerName.color=[CCColor colorWithRed:1 green:1 blue:1];
        _playerName.fontSize=textSize;
        [self addChild:_playerName];
        _amount=amount;
        _amountLabel=[DPCTextLabel node];
        _amountLabel.string=[NSString stringWithFormat:@"%d",amount];
        _amountLabel.color=[CCColor colorWithRed:1 green:1 blue:1];
        _amountLabel.fontSize=textSize;
        [self addChild:_amountLabel];
    }
    return self;
}

-(void)setPosition:(CGPoint)position {
    [super setPosition:position];
    _playerName.position=CGPointMake(nameXOffset,0);
    _amountLabel.position=CGPointMake(amountXOffset,0);
}

-(NSComparisonResult)compare:(DPCPlayerEntry*)otherObject {
    if (self.amount>otherObject.amount) {
        return NSOrderedAscending;
    } else if (self.amount<otherObject.amount) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

+(void)setTextSize:(int)size {
    textSize=size;
}

+(void)setNameXOffset:(float)offset {
    nameXOffset=offset;
}

+(void)setAmountXOffset:(float)offset {
    amountXOffset=offset;
}

@end
