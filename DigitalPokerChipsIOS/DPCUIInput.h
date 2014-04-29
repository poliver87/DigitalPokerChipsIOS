//
//  DPCUIInput.h
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 8/04/14.
//
//

#import <Foundation/Foundation.h>

extern NSString *const TOUCH_NOTHING;
extern NSString *const TOUCH_HOME;
extern NSString *const TOUCH_PLAYER;
extern NSString *const TOUCH_PLAYERS_NAME;
extern NSString *const TOUCH_BUYIN;
extern NSString *const TOUCH_LEAVE_DIALOG;
extern NSString *const TOUCH_PLAYER_STATE_CHANGE;
extern NSString *const TOUCH_TABLE_STATUS;

@class DPCUILayer;

@interface DPCUIInput : NSObject {
    NSMutableArray* touchFocus;
}

-(void)backPressed;
-(BOOL)touchDown:(CGPoint)touchPoint;
-(BOOL)touchUp:(CGPoint)touchPoint;
-(BOOL)touchDragged:(CGPoint)touchPoint;
-(void)pushTouchFocus:(NSString*) touchFocus;
-(void)popTouchFocus:(NSString*) touchFocus;
-(NSString*)getLastTouchFocus;

@end
