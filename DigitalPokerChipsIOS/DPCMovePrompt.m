//
//  DPCMovePrompt.m
//  DigitalPokerChipsIOS
//
//  Created by Peter Oliver on 22/05/2014.
//  Copyright (c) 2014 Bidjee. All rights reserved.
//

#import "DPCMovePrompt.h"

@implementation DPCMovePrompt

-(id) initWithStake:(int)stake foldEnabled:(BOOL)foldEnabled message:(NSString *)message messageStateChange:(NSString *)messageStateChange {
    if (self=[super init]) {
        _stake=stake;
        _foldEnabled=foldEnabled;
        _message=message;
        _messageStateChange=messageStateChange;
    }
    return self;
}

@end
