//
//  DPCUIInput.m
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 8/04/14.
//
//

#import "DPCUIInput.h"
#import "cocos2d.h"
#import "DPCUILayer.h"
#import "DPCGame.h"

NSString *const TOUCH_NOTHING = @"TOUCH_NOTHING";
NSString *const TOUCH_HOME = @"TOUCH_HOME";
NSString *const TOUCH_PLAYER = @"TOUCH_PLAYER";
NSString *const TOUCH_PLAYERS_NAME = @"TOUCH_PLAYERS_NAME";
NSString *const TOUCH_BUYIN = @"TOUCH_BUYIN";
NSString *const TOUCH_LEAVE_DIALOG = @"TOUCH_LEAVE_DIALOG";
NSString *const TOUCH_PLAYER_STATE_CHANGE = @"TOUCH_PLAYER_STATE_CHANGE";
NSString *const TOUCH_TABLE_STATUS= @"TOUCH_TABLE_STATUS";

@implementation DPCUIInput

-(id) init {
    if (self=[super init]) {
        touchFocus=[[NSMutableArray alloc] init];
    }
    return self;
}

-(void)backPressed {
    DPCWorldLayer* mWL=[[DPCGame sharedGame] getWorldLayer];
    DPCUILayer* mUIL=[[DPCGame sharedGame] getUILayer];
    if (touchFocus.count>0) {
        if ([[self getLastTouchFocus] isEqualToString:TOUCH_BUYIN]) {
            [mWL.thisPlayer buyinDialogDone:nil];
        } else if ([[self getLastTouchFocus] isEqualToString:TOUCH_PLAYERS_NAME]) {
            [mWL.thisPlayer nameDone];
        } else if ([[self getLastTouchFocus] isEqualToString:TOUCH_LEAVE_DIALOG]) {
            [mWL.thisPlayer leaveDialogDone:NO];
        } else if ([[self getLastTouchFocus] isEqualToString:TOUCH_TABLE_STATUS]) {
            [mUIL closeTableStatusMenu];
        } else {
            [mWL navigateBack];
        }
    } else {
        [mWL navigateBack];
    }
}

-(BOOL)touchDown:(CGPoint)touchPoint {
    DPCWorldLayer* mWL=[[DPCGame sharedGame] getWorldLayer];
    DPCUILayer* mFL=[[DPCGame sharedGame] getUILayer];
    BOOL handled=NO;
    if (mFL.backButton.touchable&&[mFL.backButton pointContained:touchPoint]) {
        handled=YES;
        mFL.backButton.isTouched=YES;
    } else if ([[self getLastTouchFocus] isEqualToString:TOUCH_HOME]) {
        if ([mFL.homeMenu.joinButton pointContained:touchPoint]) {
            handled=YES;
            [mFL.homeMenu.joinButton setIsTouched:YES];
        }
    } else if ([[self getLastTouchFocus] isEqualToString:TOUCH_PLAYERS_NAME]) {
        if (mFL.enterNameDoneButton.touchable&&[mFL.enterNameDoneButton pointContained:touchPoint]) {
            handled=YES;
            mFL.enterNameDoneButton.isTouched=YES;
        }
    } else if ([[self getLastTouchFocus] isEqualToString:TOUCH_BUYIN]) {
        handled=YES;
        if (mFL.buyinDialog.okButton.touchable&&[mFL.buyinDialog.okButton pointContained:touchPoint]) {
            mFL.buyinDialog.okButton.isTouched=YES;
        } else if (mFL.buyinDialog.cancelButton.touchable&&[mFL.buyinDialog.cancelButton pointContained:touchPoint]) {
            mFL.buyinDialog.cancelButton.isTouched=YES;
        } else {
            for (int i=0;i<CHIP_CASE_CHIP_TYPES;i++) {
                DPCSprite* thisUpArrow=[mFL.buyinDialog.upArrows objectAtIndex:i];
                if (thisUpArrow.touchable&&[thisUpArrow pointContained:touchPoint]) {
                    thisUpArrow.isTouched=YES;
                }
                DPCSprite* thisDownArrow=[mFL.buyinDialog.downArrows objectAtIndex:i];
                if (thisDownArrow.touchable&&[thisDownArrow pointContained:touchPoint]) {
                    thisDownArrow.isTouched=YES;
                }
            }
        }
    } else if ([[self getLastTouchFocus] isEqualToString:TOUCH_LEAVE_DIALOG]) {
        handled=YES;
        if (mFL.leaveTableDialog.okButton.touchable&&[mFL.leaveTableDialog.okButton pointContained:touchPoint]) {
            mFL.leaveTableDialog.okButton.isTouched=YES;
        } else if (mFL.leaveTableDialog.cancelButton.touchable&&[mFL.leaveTableDialog.cancelButton pointContained:touchPoint]) {
            mFL.leaveTableDialog.cancelButton.isTouched=YES;
        }
    } else if ([[self getLastTouchFocus] isEqualToString:TOUCH_PLAYER]) {
        if (mFL.foldButton.touchable&&[mFL.foldButton pointContained:touchPoint]) {
            handled=YES;
            mFL.foldButton.isTouched=YES;
        } else if (mFL.tableStatusMenu.handle.touchable&&[mFL.tableStatusMenu.handle pointContained:touchPoint]) {
            handled=YES;
            mFL.tableStatusMenu.handle.isTouched=YES;
        }
    } else if ([[self getLastTouchFocus] isEqualToString:TOUCH_PLAYER_STATE_CHANGE]) {
        handled=YES;
        [mWL.thisPlayer stateChangeACKed];
    } else if ([[self getLastTouchFocus] isEqualToString:TOUCH_TABLE_STATUS]) {
        handled=YES;
        if ([mFL.tableStatusMenu.handle pointContained:touchPoint]||
            [mFL.tableStatusMenu.background pointContained:touchPoint]) {
            if (mFL.tableStatusMenu.handle.touchable&&[mFL.tableStatusMenu.handle pointContained:touchPoint]) {
                handled=YES;
                mFL.tableStatusMenu.handle.isTouched=YES;
            } else if (mFL.tableStatusMenu.leaveButton.touchable&&[mFL.tableStatusMenu.leaveButton pointContained:touchPoint]) {
                handled=YES;
                mFL.tableStatusMenu.leaveButton.isTouched=YES;
            }
        } else {
            [mFL closeTableStatusMenu];
        }
    }
    return handled;
}

-(BOOL)touchUp:(CGPoint)touchPoint {
    BOOL handled=false;
    DPCUILayer* mFL=[[DPCGame sharedGame] getUILayer];
    DPCWorldLayer* mWL=[[DPCGame sharedGame] getWorldLayer];
    if (mFL.backButton.isTouched) {
        handled=true;
        mFL.backButton.isTouched=NO;
        [self backPressed];
    }
    if (mFL.foldButton.isTouched) {
        handled=true;
        mFL.foldButton.isTouched=NO;
        [mWL.thisPlayer doFold];
    }
    if (mFL.tableStatusMenu.leaveButton.isTouched) {
        handled=true;
        mFL.tableStatusMenu.leaveButton.isTouched=NO;
        [mFL startLeaveTableDialog:mWL.thisPlayer.tableName];
    }
    if (mFL.tableStatusMenu.handle.isTouched) {
        handled=true;
        mFL.tableStatusMenu.handle.isTouched=NO;
        if (mFL.tableStatusMenu.menuShouldOpen) {
            [mFL openTableStatusMenu];
        } else {
            [mFL closeTableStatusMenu];
        }
    }
    if (mFL.homeMenu.joinButton.isTouched) {
        handled=true;
        [mFL.homeMenu.joinButton setIsTouched:NO];
        [mFL joinSelected];
        
    }
    if (mFL.enterNameDoneButton.isTouched) {
        handled=true;
        [mFL.enterNameDoneButton setIsTouched:NO];
        [mWL.thisPlayer nameDone];
    }
    if (mFL.buyinDialog.okButton.isTouched) {
        handled=true;
        [mFL.buyinDialog.okButton setIsTouched:NO];
        [mWL.thisPlayer buyinDialogDone:mFL.buyinDialog.getStartBuild];
    }
    if (mFL.buyinDialog.cancelButton.isTouched) {
        handled=true;
        [mFL.buyinDialog.cancelButton setIsTouched:NO];
        [mWL.thisPlayer buyinDialogDone:nil];
    }
    if (mFL.leaveTableDialog.okButton.isTouched) {
        handled=true;
        [mFL.leaveTableDialog.okButton setIsTouched:NO];
        [mWL.thisPlayer leaveDialogDone:YES];
    }
    if (mFL.leaveTableDialog.cancelButton.isTouched) {
        handled=true;
        [mFL.leaveTableDialog.cancelButton setIsTouched:NO];
        [mWL.thisPlayer leaveDialogDone:NO];
    }
    for (int i=0;i<CHIP_CASE_CHIP_TYPES;i++) {
        DPCSprite* thisUpArrow=[mFL.buyinDialog.upArrows objectAtIndex:i];
        if (thisUpArrow.isTouched) {
            handled=YES;
            thisUpArrow.isTouched=NO;
            [mFL.buyinDialog amountUp:i];
        }
        DPCSprite* thisDownArrow=[mFL.buyinDialog.downArrows objectAtIndex:i];
        if (thisDownArrow.isTouched) {
            handled=YES;
            thisDownArrow.isTouched=NO;
            [mFL.buyinDialog amountDown:i];
        }
    }
    return handled;
}

-(BOOL)touchDragged:(CGPoint)touchPoint {
    BOOL handled=false;
    DPCUILayer* mFL=[[DPCGame sharedGame] getUILayer];
    if (mFL.backButton.isTouched) {
        handled=true;
        if (![mFL.backButton pointContained:touchPoint]) {
            mFL.backButton.isTouched=false;
        }
    }
    if (mFL.enterNameDoneButton.isTouched) {
        handled=true;
        if (![mFL.enterNameDoneButton pointContained:touchPoint]) {
            mFL.enterNameDoneButton.isTouched=false;
        }
    }
    if (mFL.foldButton.isTouched) {
        handled=true;
        if (![mFL.foldButton pointContained:touchPoint]) {
            mFL.foldButton.isTouched=false;
        }
    }
    if (mFL.tableStatusMenu.handle.isTouched) {
        handled=true;
        [mFL.tableStatusMenu touchDragged:touchPoint];
        if (![mFL.tableStatusMenu.handle pointContained:touchPoint]) {
            mFL.tableStatusMenu.handle.isTouched=false;
            if ([mFL.tableStatusMenu menuShouldOpen]) {
                [mFL openTableStatusMenu];
            } else {
                [mFL closeTableStatusMenu];
            }
        }
    }
    if (mFL.tableStatusMenu.leaveButton.isTouched) {
        handled=true;
        if (![mFL.tableStatusMenu.leaveButton pointContained:touchPoint]) {
            mFL.tableStatusMenu.leaveButton.isTouched=false;
        }
    }
    if (mFL.homeMenu.joinButton.isTouched) {
        handled=true;
        if (![mFL.homeMenu.joinButton pointContained:touchPoint]) {
            mFL.homeMenu.joinButton.isTouched=false;
        }
    }
    if (mFL.buyinDialog.okButton.isTouched) {
        handled=true;
        if (![mFL.buyinDialog.okButton pointContained:touchPoint]) {
            mFL.buyinDialog.okButton.isTouched=false;
        }
    }
    if (mFL.buyinDialog.cancelButton.isTouched) {
        handled=true;
        if (![mFL.buyinDialog.cancelButton pointContained:touchPoint]) {
            mFL.buyinDialog.cancelButton.isTouched=false;
        }
    }
    if (mFL.leaveTableDialog.okButton.isTouched) {
        handled=true;
        if (![mFL.leaveTableDialog.okButton pointContained:touchPoint]) {
            mFL.leaveTableDialog.okButton.isTouched=false;
        }
    }
    if (mFL.leaveTableDialog.cancelButton.isTouched) {
        handled=true;
        if (![mFL.leaveTableDialog.cancelButton pointContained:touchPoint]) {
            mFL.leaveTableDialog.cancelButton.isTouched=false;
        }
    }
    for (int i=0;i<CHIP_CASE_CHIP_TYPES;i++) {
        DPCSprite* thisUpArrow=[mFL.buyinDialog.upArrows objectAtIndex:i];
        if (thisUpArrow.isTouched&&![thisUpArrow pointContained:touchPoint]) {
            handled=YES;
            thisUpArrow.isTouched=NO;
        }
        DPCSprite* thisDownArrow=[mFL.buyinDialog.downArrows objectAtIndex:i];
        if (thisDownArrow.isTouched&&![thisDownArrow pointContained:touchPoint]) {
            handled=YES;
            thisDownArrow.isTouched=NO;
        }
    }
    return handled;
}

-(void)pushTouchFocus:(NSString*) focus {
    if (![[self getLastTouchFocus] isEqualToString:focus]) {
        [touchFocus addObject:focus];
    }
    //CCLOG("Pushed touch focus %@",focus);
}

-(void)popTouchFocus:(NSString*) focus {
    
    if ([[self getLastTouchFocus] isEqualToString:focus]) {
        [touchFocus removeLastObject];
        CCLOG(@"Popped touch focus %@",focus);
    } else {
        CCLOG(@"Error poppoing focus %@",focus);
    }
}

-(NSString*)getLastTouchFocus {
    if (touchFocus.count>0) {
        return [touchFocus lastObject];
    } else {
        return @"";
    }
}

@end
