//
//  DPCBuyinDialog.m
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 10/04/14.
//
//

#import "DPCGame.h"
#import "DPCBuyinDialog.h"
#import "DPCTextFactory.h"

@implementation DPCBuyinDialog

static const NSString* TITLE_STRING=@"Would you like to join";
static const int DEFAULT_CHIP_AMOUNTS[]={8,4,2};

-(id)init {
    if (self=[super init]) {
        _titleLabel=[DPCTextLabel node];
        [self addChild:_titleLabel];
        _instrLabel=[DPCTextLabel node];
        _instrLabel.string=@"Set Buy-In Amount:";
        [self addChild:_instrLabel];
        _totalLabel=[DPCTextLabel node];
        _totalLabel.string=@"Total Buy-In:";
        [self addChild:_totalLabel];
        _totalNumberLabel=[DPCTextLabel node];
        [self addChild:_totalNumberLabel];
        _okButton=[DPCSprite DPCSpriteWithFile:@"ok_button.png"];
        [self addChild:_okButton];
        _cancelButton=[DPCSprite DPCSpriteWithFile:@"cancel_button.png"];
        [self addChild:_cancelButton];
        
        _upArrows=[NSMutableArray array];
        _downArrows=[NSMutableArray array];
        _chipStacks=[NSMutableArray array];
        _chipNodes=[NSMutableArray array];
        for (int i=0;i<CHIP_CASE_CHIP_TYPES;i++) {
            DPCSprite* thisUpArrow=[DPCSprite DPCSpriteWithFile:@"arrow.png"];
            thisUpArrow.touchable=NO;
            thisUpArrow.touchAreaMultiplier=2;
            [self addChild:thisUpArrow];
            [_upArrows addObject:thisUpArrow];
            DPCSprite* thisDownArrow=[DPCSprite DPCSpriteWithFile:@"arrow.png"];
            thisDownArrow.touchable=NO;
            thisDownArrow.touchAreaMultiplier=2;
            thisDownArrow.flipY=YES;
            [self addChild:thisDownArrow];
            [_downArrows addObject:thisDownArrow];
            CCNode* chipNode=[CCNode node];
            [_chipNodes addObject:chipNode];
            DPCChipStack* thisStack=[[DPCChipStack alloc]initWithChipNode:chipNode];
            thisStack.maxRenderNum=12;
            [thisStack addChipsOfType:i number:DEFAULT_CHIP_AMOUNTS[i]];
            [_chipStacks addObject:thisStack];
            [self addChild:chipNode];
        }
    }
    return self;
}

-(void) setRadiusX:(int)radiusX radiusY:(int)radiusY {
    [super setRadiusX:radiusX radiusY:radiusY];
    _titleLabel.string=[NSString stringWithFormat:@"%@ LONGNAME!?",TITLE_STRING];
    _titleLabel.fontSize=[DPCTextFactory getMaxTextSize:_titleLabel width:(int)(radiusX*1.7f) height:(int)(radiusY*0.4f)];
    _titleLabel.string=@"";
    _instrLabel.fontSize=[DPCTextFactory getMaxTextSize:_instrLabel width:(int)(radiusX*1.4f) height:(int)(radiusY*0.2f)];
    _totalLabel.fontSize=[DPCTextFactory getMaxTextSize:_totalLabel width:(int)(radiusX*0.8f) height:(int)(radiusY*0.2f)];
    _totalNumberLabel.fontSize=_totalLabel.fontSize;
    [_okButton setRadiusX:radiusY*0.15f radiusY:radiusY*0.15f];
    [_cancelButton setRadiusX:radiusY*0.15f radiusY:radiusY*0.15f];
    
    for (int i=0;i<CHIP_CASE_CHIP_TYPES;i++) {
        [((DPCSprite*)[_upArrows objectAtIndex:i]) setRadiusX:radiusY*0.12f radiusY:radiusY*0.12f];
        [((DPCSprite*)[_downArrows objectAtIndex:i]) setRadiusX:radiusY*0.12f radiusY:radiusY*0.12f];
        CCNode* thisChipNode=[_chipNodes objectAtIndex:i];
        thisChipNode.scale=(radiusY*0.25f)/[DPCChip getRadiusY];
    }
}

-(void) setPosition:(CGPoint)position {
    [super setPosition:position];
    [_titleLabel setPosition:ccp(0,self.yWindowRadius*0.86f)];
    [_instrLabel setPosition:ccp(0,self.yWindowRadius*0.7f)];
    [_totalLabel setPosition:ccp(-1*self.xWindowRadius*0.3f,-1*self.yWindowRadius*0.8f)];
    [_totalNumberLabel setPosition:ccp(self.xWindowRadius*0.3f,_totalLabel.position.y)];
    [_okButton setPosition:ccp(self.xWindowRadius*0.78f,-self.yWindowRadius*0.78f)];
    [_cancelButton setPosition:ccp(-self.xWindowRadius*0.78f,-self.yWindowRadius*0.78f)];
    float xValueSpacing=self.xWindowRadius*0.5f;
    float xValueStart=self.positionWindow.x-xValueSpacing;
    for (int i=0;i<CHIP_CASE_CHIP_TYPES;i++) {
        
        [((DPCSprite*)[_upArrows objectAtIndex:i]) setPosition:ccp(xValueStart+i*xValueSpacing,self.positionWindow.y+self.yWindowRadius*0.5f)];
        [((DPCSprite*)[_downArrows objectAtIndex:i]) setPosition:ccp(xValueStart+i*xValueSpacing,self.positionWindow.y-self.yWindowRadius*0.5f)];
        CCNode* thisChipNode=[_chipNodes objectAtIndex:i];
        [thisChipNode setPosition:ccp(xValueStart+i*xValueSpacing,self.positionWindow.y-self.yWindowRadius*0.13f)];
        DPCChipStack* thisStack=[_chipStacks objectAtIndex:i];
        thisStack.z=0;
    }
}

-(void)setOpacity:(CGFloat)opacity {
    [super setOpacity:opacity];
    _titleLabel.opacity=opacity;
    _instrLabel.opacity=opacity;
    _totalLabel.opacity=opacity;
    _totalNumberLabel.opacity=opacity;
    _okButton.opacity=opacity;
    _cancelButton.opacity=opacity;
    for (int i=0;i<CHIP_CASE_CHIP_TYPES;i++) {
        DPCChipStack* thisStack=[_chipStacks objectAtIndex:i];
        thisStack.opacity=opacity;
        DPCSprite* thisUpArrow=[_upArrows objectAtIndex:i];
        thisUpArrow.opacity=opacity;
        DPCSprite* thisDownArrow=[_downArrows objectAtIndex:i];
        thisDownArrow.opacity=opacity;
    }
}

-(void)start {
    [super start];
    [_titleLabel fadeIn];
    [_okButton fadeIn];
    _okButton.touchable=YES;
    [_cancelButton fadeIn];
    _cancelButton.touchable=YES;
    [_instrLabel fadeIn];
    [_totalLabel fadeIn];
    [_totalNumberLabel fadeIn];
    for (int i=0;i<CHIP_CASE_CHIP_TYPES;i++) {
        DPCChipStack* thisStack=[_chipStacks objectAtIndex:i];
        [thisStack fadeIn];
        thisStack.totalShowing=YES;
        [thisStack.totalLabel fadeIn];
        DPCSprite* thisUpArrow=[_upArrows objectAtIndex:i];
        [thisUpArrow fadeIn];
        thisUpArrow.touchable=YES;
        DPCSprite* thisDownArrow=[_downArrows objectAtIndex:i];
        [thisDownArrow fadeIn];
        thisDownArrow.touchable=YES;
    }
    [self updateBuyinTotal];
}

-(void)stop {
    [super stop];
    [_titleLabel fadeOut];
    [_instrLabel fadeOut];
    [_totalLabel fadeOut];
    [_totalNumberLabel fadeOut];
    [_okButton fadeOut];
    _okButton.touchable=NO;
    [_cancelButton fadeOut];
    _cancelButton.touchable=NO;
    for (int i=0;i<CHIP_CASE_CHIP_TYPES;i++) {
        DPCChipStack* thisStack=[_chipStacks objectAtIndex:i];
        [thisStack fadeOut];
        thisStack.totalShowing=NO;
        [thisStack.totalLabel fadeOut];
        DPCSprite* thisUpArrow=[_upArrows objectAtIndex:i];
        [thisUpArrow fadeOut];
        thisUpArrow.touchable=NO;
        DPCSprite* thisDownArrow=[_downArrows objectAtIndex:i];
        [thisDownArrow fadeOut];
        thisDownArrow.touchable=NO;
    }
}

-(void)disappear {
    _titleLabel.opacity=0;
    _instrLabel.opacity=0;
    _totalLabel.opacity=0;
    _totalNumberLabel.opacity=0;
    _okButton.opacity=0;
    _okButton.touchable=NO;
    _cancelButton.opacity=0;
    _cancelButton.touchable=NO;
    for (int i=0;i<CHIP_CASE_CHIP_TYPES;i++) {
        DPCChipStack* thisStack=[_chipStacks objectAtIndex:i];
        thisStack.opacity=0;
        DPCSprite* thisUpArrow=[_upArrows objectAtIndex:i];
        thisUpArrow.touchable=NO;
        thisUpArrow.opacity=0;
        DPCSprite* thisDownArrow=[_downArrows objectAtIndex:i];
        thisDownArrow.touchable=NO;
        thisUpArrow.opacity=0;
    }
}

-(void) setTableName:(NSString*)tableName {
    _titleLabel.string=[NSString stringWithFormat:@"%@ %@?",TITLE_STRING,tableName];
}

-(void)animate:(float)delta {
    [super animate:delta];
    [_titleLabel animate:delta];
    [_instrLabel animate:delta];
    [_totalLabel animate:delta];
    [_totalNumberLabel animate:delta];
    [_okButton animate:delta];
    [_cancelButton animate:delta];
    for (int i=0;i<CHIP_CASE_CHIP_TYPES;i++) {
        DPCChipStack* thisStack=[_chipStacks objectAtIndex:i];
        [thisStack animate:delta];
        DPCSprite* thisUpArrow=[_upArrows objectAtIndex:i];
        [thisUpArrow animate:delta];
        DPCSprite* thisDownArrow=[_downArrows objectAtIndex:i];
        [thisDownArrow animate:delta];
    }
}

-(void)amountUp:(int) chipIndex {
    DPCChipStack* thisStack=[_chipStacks objectAtIndex:chipIndex];
    [thisStack addChipsOfType:chipIndex number:1];
    [thisStack updateTotalLabel];
    [self updateBuyinTotal];
}

-(void) amountDown:(int) chipIndex {
    DPCChipStack* thisStack=[_chipStacks objectAtIndex:chipIndex];
    if (thisStack.size>0&&self.totalChips>1) {
        [thisStack removeChip:thisStack.size-1];
        [thisStack updateTotalLabel];
        [self updateBuyinTotal];
    }
}

-(int)totalChips {
    int total=0;
    for (int i=0;i<CHIP_CASE_CHIP_TYPES;i++) {
        DPCChipStack* thisStack=[_chipStacks objectAtIndex:i];
        total+=thisStack.size;
    }
    return total;
}

-(NSMutableArray*)getStartBuild {
    NSMutableArray* build=[NSMutableArray array];
    for (int i=0;i<CHIP_CASE_CHIP_TYPES;i++) {
        DPCChipStack* thisStack=[_chipStacks objectAtIndex:i];
        [build addObject:[NSNumber numberWithInt:thisStack.size]];
    }
    return build;
}

-(void) updateBuyinTotal {
    int buyinTotal=0;
    for (int chip=0;chip<CHIP_CASE_CHIP_TYPES;chip++) {
        DPCChipStack* thisStack=[_chipStacks objectAtIndex:chip];
        buyinTotal+=thisStack.value;
    }
    _totalNumberLabel.string=[NSString stringWithFormat:@"%d",buyinTotal];
}

@end
