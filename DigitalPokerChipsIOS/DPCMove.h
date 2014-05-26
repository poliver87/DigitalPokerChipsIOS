//
//  DPCMove.h
//  DigitalPokerChipsIOS
//
//  Created by Peter Oliver on 22/05/2014.
//  Copyright (c) 2014 Bidjee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPCMove : NSObject

@property int moveType;
@property NSString* chipString;

-(id)initWithMoveType:(int)moveType chipString:(NSString*)chipString;

@end
