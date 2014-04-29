//
//  DPCHomeMenu.h
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 5/04/14.
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "DPCSprite.h"
#import "DPCTextLabel.h"

typedef enum {
    STATE_NONE,
    STATE_CLOSED,
    STATE_SHOW_LOGO,
    STATE_SHOW_MENU,
    STATE_OPENED,
    STATE_CLOSING,
} HomeAnimationState;

@interface DPCHomeMenu : CCNode {
    HomeAnimationState animationState;
}

@property DPCSprite* joinButton;
@property DPCSprite* logoDPC;
@property DPCTextLabel* joinButtonLabel;

-(void) setDimensionsScreenWidth:(int)screenWidth height:(int)screenHeight;
-(void) setPositionsScreenLeft:(float)screenLeft top:(float)screenTop right:(float)screenRight bottom:(float)screenBottom;
-(void) open:(BOOL) tablesPresent;
-(void) close;
-(void) notifyClosed;

@end
