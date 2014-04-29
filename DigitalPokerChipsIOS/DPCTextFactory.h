//
//  DPCTextFactory.h
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 8/04/14.
//
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"

@interface DPCTextFactory : NSObject

+(int)getMaxTextSize:(CCLabelTTF*)label width:(int)width height:(int)height;

@end
