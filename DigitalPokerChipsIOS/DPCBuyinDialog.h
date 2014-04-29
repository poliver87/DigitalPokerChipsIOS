//
//  DPCBuyinDialog.h
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 10/04/14.
//
//

#import "DPCDialog.h"
#import "DPCTextLabel.h"

@interface DPCBuyinDialog : DPCDialog

@property BOOL loadedGame;

@property DPCTextLabel* titleLabel;
@property DPCTextLabel* instrLabel;
@property DPCTextLabel* totalLabel;
@property DPCTextLabel* totalNumberLabel;
@property DPCSprite* okButton;
@property DPCSprite* cancelButton;
@property NSMutableArray* upArrows;
@property NSMutableArray* downArrows;
@property NSMutableArray* chipStacks;
@property NSMutableArray* chipNodes;

-(void)setTableName:(NSString*)tableName;
-(void)setLoadedGame:(BOOL)loadedGame;

-(void)amountUp:(int) stackIndex;
-(void)amountDown:(int)stackIndex;
-(NSMutableArray*)getStartBuild;

@end
