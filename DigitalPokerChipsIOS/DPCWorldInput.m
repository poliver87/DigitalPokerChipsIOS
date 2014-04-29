//
//  DPCWorldInput.m
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 8/04/14.
//
//

#import "DPCWorldInput.h"
#import "DPCGame.h"
#import "DPCWorldLayer.h"
#import "DPCChipCase.h"

@interface DPCWorldInput () {
    
}
@end

@implementation DPCWorldInput

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    DPCWorldLayer* mWL=[[DPCGame sharedGame] getWorldLayer];
    if (textField==mWL.thisPlayer.nameField) {
        [mWL.thisPlayer.nameField resignFirstResponder];
    }
    return YES;
}

-(void)textFieldDidEndEditing: (UITextField *)textField {
    DPCWorldLayer* mWL=[[DPCGame sharedGame] getWorldLayer];
    if(textField == mWL.thisPlayer.nameField) {
        [mWL.thisPlayer nameDone];
    }
}

-(BOOL)touchDown:(CGPoint)touchPoint {
    BOOL handled=YES;
    _lastTouch=touchPoint;
    DPCWorldLayer* mWL=[[DPCGame sharedGame] getWorldLayer];
    if (mWL.cameraDestination==mWL.camPosPlayer) {
        if (mWL.thisPlayer.pickedUpChip==nil&&mWL.thisPlayer.cancellingStack.size==0&&
            mWL.thisPlayer.cancelStack.size==0) {
            for (int chip=0;chip<CHIP_CASE_CHIP_TYPES;chip++) {
                DPCChipStack* thisStack=[mWL.thisPlayer.mainStacks objectAtIndex:chip];
                if (thisStack.size>0) {
                    if ([[thisStack getLastChipRendered] pointContained:touchPoint]) {
                        DPCChipStack* PUCStack=[mWL.thisPlayer.mainStacks objectAtIndex:chip];
                        DPCChip* newPUC=[PUCStack takeLastChip];
                        newPUC.isTouched=YES;
                        [newPUC setDeltaTouchFromTouch:touchPoint];
                        [newPUC setDestToPos];
                        [mWL.thisPlayer setPickedUpChip:newPUC];
                        break;
                    }
                }
            }
            if (mWL.thisPlayer.betStack.size>0&&mWL.thisPlayer.bettingStack.size==0&&mWL.thisPlayer.pickedUpChip==nil) {
                if ([mWL.thisPlayer.betStack pointContained:touchPoint]) {
                    [mWL.thisPlayer.betStack getChip:0].isTouched=true;
                    [[mWL.thisPlayer.betStack getChip:0] setDeltaTouchFromTouch:touchPoint];
                }
            }
        }
        if (mWL.thisPlayer.checkButton.touchable&&[mWL.thisPlayer.checkButton pointContained:touchPoint]) {
            mWL.thisPlayer.checkButton.isTouched=true;
        }
    }
    return handled;
}

-(BOOL)touchUp:(CGPoint)touchPoint {
    BOOL handled=YES;
    DPCWorldLayer* mWL=[[DPCGame sharedGame] getWorldLayer];
    
    if (mWL.thisPlayer.pickedUpChip!=nil&&mWL.thisPlayer.pickedUpChip.isTouched) {
        mWL.thisPlayer.pickedUpChip.isTouched=false;
        [mWL.thisPlayer doPickedUpChipDropped];
    }
    if (mWL.thisPlayer.betStack.size>0&&[mWL.thisPlayer.betStack getChip:0].isTouched) {
        [mWL.thisPlayer.betStack getChip:0].isTouched=false;
    }
    if (mWL.thisPlayer.checkButton.isTouched) {
        mWL.thisPlayer.checkButton.isTouched=NO;
        [mWL.thisPlayer doCheck];
    }
    return handled;
}

-(BOOL)touchDragged:(CGPoint)touchPoint {
    BOOL handled=YES;
    _lastTouch=touchPoint;
    DPCWorldLayer* mWL=[[DPCGame sharedGame] getWorldLayer];
    if (mWL.thisPlayer.pickedUpChip!=nil&&mWL.thisPlayer.pickedUpChip.isTouched) {
        [mWL.thisPlayer.pickedUpChip setDestFromTouch:touchPoint];
    } else if (mWL.thisPlayer.betStack.size>0&&[mWL.thisPlayer.betStack getChip:0].isTouched) {
        [mWL.thisPlayer.betStack setPositionFromTouch:touchPoint];
    }
    if (mWL.thisPlayer.checkButton.isTouched) {
        handled=true;
        if (![mWL.thisPlayer.checkButton pointContained:touchPoint]) {
            mWL.thisPlayer.checkButton.isTouched=false;
        }
    }
    return handled;
}

-(BOOL) fling:(CGPoint)velocity {
    BOOL handled=NO;
    DPCWorldLayer* mWL=[[DPCGame sharedGame] getWorldLayer];
    if (mWL.thisPlayer.pickedUpChip!=nil&&mWL.thisPlayer.pickedUpChip.isTouched) {
        handled=YES;
        mWL.thisPlayer.pickedUpChip.isTouched=false;
        [mWL.thisPlayer doPickedUpChipFlung:velocity];
    } else if (mWL.thisPlayer.betStack.size>0&&[mWL.thisPlayer.betStack getChip:0].isTouched) {
        handled=YES;
        [mWL.thisPlayer.betStack getChip:0].isTouched=NO;
        mWL.thisPlayer.betStack.velocity=ccp(0,velocity.y*0.8f);
    }
    return handled;
}


@end
