//
//  DPCWorldInput.h
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 8/04/14.
//
//

#import <Foundation/Foundation.h>

@interface DPCWorldInput : NSObject <UITextFieldDelegate>

@property CGPoint lastTouch;

-(BOOL)touchDown:(CGPoint)touchPoint;
-(BOOL)touchUp:(CGPoint)touchPoint;
-(BOOL)touchDragged:(CGPoint)touchPoint;
-(BOOL)fling:(CGPoint)velocity;

@end
