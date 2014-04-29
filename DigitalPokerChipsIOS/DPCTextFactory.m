//
//  DPCTextFactory.m
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 8/04/14.
//
//

#import "DPCTextFactory.h"

@implementation DPCTextFactory

+(int)getMaxTextSize:(CCLabelTTF*)label width:(int)width height:(int)height {
    int textSize=1;
    for (;textSize<100;textSize++) {
        label.fontSize=textSize;
        if (label.contentSize.width>width||
            label.contentSize.height>height) {
            break;
        }
    }
    textSize--;
    return textSize;
}

@end
