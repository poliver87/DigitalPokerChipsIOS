//
//  DPCMovePrompt.h
//  DigitalPokerChipsIOS
//
//  Created by Peter Oliver on 22/05/2014.
//  Copyright (c) 2014 Bidjee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPCMovePrompt : NSObject

@property int stake;
@property BOOL foldEnabled;
@property NSString* message;
@property NSString* messageStateChange;

-(id)initWithStake:(int)stake foldEnabled:(BOOL)foldEnabled message:(NSString*)message messageStateChange:(NSString*)messageStateChange;

@end
