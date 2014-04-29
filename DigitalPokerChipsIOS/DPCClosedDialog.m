//
//  DPCClosedDialog.m
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 10/04/14.
//
//

#import "DPCClosedDialog.h"

@implementation DPCClosedDialog

-(id)initWithAttachedWindow:(DPCDialogWindow*)attachedWindow {
    if (self=[super init]) {
        _attachedWindow=attachedWindow;
    }
    return self;
}

-(void)dealloc {
    _attachedWindow=nil;
}

-(void)start {
    [super start]; 
    _attachedWindow.opacity=0;
}

-(void) stop {
    [super stop];
}

@end
