//
//  DPCChipStack.h
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 10/04/14.
//
//

#import "DPCSprite.h"
#import "DPCChip.h"
#import "DPCTextLabel.h"

@interface DPCChipStack : DPCSprite

@property NSMutableArray* stack;
@property (nonatomic) int size;
@property (nonatomic) int renderSize;
@property int maxRenderNum;
@property DPCTextLabel* totalLabel;
@property (nonatomic) int value;
@property (nonatomic) BOOL totalShowing;
@property (nonatomic) CCNode* chipNode;

@property (nonatomic) float stackScale;

-(id)initWithChipNode:(CCNode*)node;
-(void)scaleLabel;
-(void)updateTotalLabel;
-(void)addChip:(DPCChip*)chip;
-(void)addChipsOfType:(int)chipType number:(int)number;
-(DPCChip*)getChip:(int)i;
-(DPCChip*)getLastChip;
-(DPCChip*)getLastChipRendered;
-(DPCChip*)takeChip:(int)i;
-(DPCChip*)takeLastChip;
-(void)removeChip:(int)i;
-(BOOL)removeChipsOfType:(int)chipType number:(int)number;
-(void)clear;
-(void)flashXYZ;
-(CGPoint)getTopPosition;
+(DPCChipStack*)parseStack:(NSString*)str;

@end
