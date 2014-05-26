//
//  DPCMove.m
//  DigitalPokerChipsIOS
//
//  Created by Peter Oliver on 22/05/2014.
//  Copyright (c) 2014 Bidjee. All rights reserved.
//

#import "DPCMove.h"

@implementation DPCMove

-(id)initWithMoveType:(int)moveType chipString:(NSString *)chipString {
    if (self=[super init]) {
        _moveType=moveType;
        _chipString=chipString;
    }
    return self;
}

@end
