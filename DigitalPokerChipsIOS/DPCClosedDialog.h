//
//  DPCClosedDialog.h
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 10/04/14.
//
//

#import "DPCDialog.h"
#import "DPCDialogWindow.h"

@interface DPCClosedDialog : DPCDialog

@property DPCDialogWindow* attachedWindow;

-(id)initWithAttachedWindow:(DPCDialogWindow*)attachedWindow;

@end
