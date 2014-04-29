//
//  DPCDialogWindow.h
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 10/04/14.
//
//

#import "DPCSprite.h"
#import "DPCDialog.h"

@interface DPCDialogWindow : DPCSprite

-(void)animate:(double)delta;
-(void)sendTo:(DPCDialog*)dialogDest;
-(void)remove;

@end
