//
//  DPCLeaveTableDialog.h
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 19/04/14.
//
//

#import "DPCDialog.h"
#import "DPCTextLabel.h"

@interface DPCLeaveTableDialog : DPCDialog

@property DPCTextLabel* titleLabel;
@property DPCSprite* okButton;
@property DPCSprite* cancelButton;

-(void)setTableName:(NSString*)tableName;

@end
