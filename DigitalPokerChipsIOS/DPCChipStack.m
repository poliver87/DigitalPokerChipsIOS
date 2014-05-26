//
//  DPCChipStack.m
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 10/04/14.
//
//

#import "DPCGame.h"
#import "DPCChipStack.h"
#import "DPCChip.h"
#import "DPCWorldLayer.h"

#import "DPCTextFactory.h"

@implementation DPCChipStack

-(id)init {
    return [self initWithChipNode:nil];
}

-(id)initWithChipNode:(CCNode*)node {
    if (self=[super init]) {
        _chipNode=node;
        _stack=[NSMutableArray array];
        self.position=CGPointMake(0,0);
        self.z=0;
        self.velocity=CGPointMake(0,0);
        self.zDest=0;
        _maxRenderNum=100;
        _totalLabel=[DPCTextLabel node];
        _totalLabel.color=[CCColor colorWithRed:0 green:0 blue:0];
        if (node!=nil) {
            [node addChild:_totalLabel];
        }
        _stackScale=1.0f;
    }
    return self;
}

-(void)setStackScale:(float)stackScale {
    _stackScale=stackScale;
    
}

-(void)scaleLabel {
    NSString* tmp=_totalLabel.string;
    _totalLabel.string=@"999999";
    _totalLabel.fontSize=[DPCTextFactory getMaxTextSize:_totalLabel width:[DPCChip getRadiusX]*1.9f height:1.9f*[DPCChip getRadiusY]];
    if (tmp.length>0) {
        _totalLabel.string=tmp;
    } else {
        _totalLabel.string=@"";
    }
}


-(void)updateTotalLabel {
    _totalLabel.string=[NSString stringWithFormat:@"%d",self.value];
    if (self.size>0) {
        _totalLabel.position=[self getTopPosition];
        _totalLabel.zOrder=[self getLastChipRendered].zOrder;
        if (_totalShowing&&_totalLabel.opacity!=1) {
            _totalLabel.opacity=1;
        }
    } else {
        _totalLabel.opacity=0;
    }
}

-(void)setTotalShowing:(BOOL)totalShowing {
    _totalShowing=totalShowing;
    if (totalShowing) {
        _totalLabel.opacity=1;
    } else {
        _totalLabel.opacity=0;
    }
    [self updateTotalLabel];
}

-(int)size {
    return (int)[_stack count];
}

-(void)setOpacity:(CGFloat)opacity {
    [super setOpacity:opacity];
    for (int i=0;i<self.renderSize;i++) {
        [self getChip:i].opacity=opacity;
    }
}

-(int)renderSize {
    return MIN(_maxRenderNum,self.size);
}

-(void)addChip:(DPCChip*)chip {
    [self.stack addObject:chip];
    if (self.size>self.maxRenderNum) {
        chip.opacity=0;
    }
}

-(void)addChipsOfType:(int)chipType number:(int)number {
    int zLast=0;
    if (self.size>0) {
        zLast=[self getLastChip].z;
    }
    for (int i=0;i<number;i++) {
        DPCChip* chip = [[DPCChip alloc] initWithParent:self.chipNode chipType:chipType x:self.position.x y:self.position.y z:zLast+i];
        [self addChip:chip];
        
    }
    [self flashXYZ];
}

-(DPCChip*)getChip:(int)i {
    return [_stack objectAtIndex:i];
}

-(DPCChip*)getLastChip {
    int size=self.size-1;
    return [self getChip:size];
}

-(DPCChip*)getLastChipRendered {
    int lastIndex=self.renderSize-1;
    return [self getChip:lastIndex];
}

-(DPCChip*)takeChip:(int)i {
    DPCChip* chip=[self getChip:i];
    [_stack removeObjectAtIndex:i];
    chip.opacity=1;
    return chip;
}

-(DPCChip*)takeLastChip {
    return [self takeChip:(int)[_stack count]-1];
}

-(void)removeChip:(int)i {
    [[self getChip:i] remove];
    [_stack removeObjectAtIndex:i];
}

-(BOOL)removeChipsOfType:(int)chipType number:(int)number {
    BOOL actionCompleted=false;
    int lastIndex=(int)[_stack count]-1;
    for (int i=lastIndex;i>=0&&number>0;i--) {
        if ([self getChip:i].chipType==chipType) {
            [self removeChip:i];
            number--;
        }
    }
    if (number==0) {
        actionCompleted=true;
    }
    return actionCompleted;
}

-(void)clear {
    for (int i=self.size-1;i>=0;i--) {
        [self removeChip:i];
    }
    self.velocity=ccp(0,0);
    self.totalLabel.opacity=0;
}

-(void)setPosition:(CGPoint)position {
    [super setPosition:position];
    for (int i=0;i<self.size;i++) {
        [self getChip:i].position=position;
    }
    _totalLabel.position=[self getTopPosition];
}

-(void)setPositionFromTouch:(CGPoint)touch {
    if (self.size>0) {
        touch=[[self getChip:0].parent convertToNodeSpace:touch];
        CGPoint newPos=ccpSub(touch,[self getChip:0].deltaTouch);
        [self setPosition:ccp(self.position.x,newPos.y)];
    }
}

-(void)setZ:(float)z {
    [super setZ:z];
    for (int i=0;i<self.size;i++) {
        [self getChip:i].z=z+i;
    }
    _totalLabel.position=[self getTopPosition];
}

-(void)flashXYZ {
    CGPoint posStack=self.position;
    self.position=posStack;
    float zStack=self.z;
    self.z=zStack;
}

-(CGPoint)getTopPosition {
    float topY=self.position.y;
    int numTop=self.renderSize+self.z;
    topY+=[DPCChip getProjectedDeltaForZ:numTop ];
    return ccp(self.position.x,topY);
}

-(BOOL) pointContained:(CGPoint)point {
    BOOL isContained=NO;
    if (self.size>0) {
        if ([[self getLastChipRendered] pointContained:point]) {
            isContained=YES;
        }
        if ([[self getChip:0] pointContained:point]) {
            isContained=YES;
        }
        CGPoint pointInParent=[[self getChip:0].parent convertToNodeSpace:point];
        CCLOG(@"point in parent x: %d y %d",(int)pointInParent.x,(int)pointInParent.y);
        CCLOG(@"self x: %d y %d",(int)self.position.x,(int)self.position.y);
        CCLOG(@"last chip yBeforeZOffset: %d",(int)[self getLastChipRendered].yBeforeZOffset);
        if (fabsf(pointInParent.x-self.position.x)<[self getLastChipRendered].radiusX&&
            pointInParent.y>=self.position.y&&pointInParent.y<=[self getLastChipRendered].yBeforeZOffset) {
            isContained=YES;
        }
    }
    return isContained;
}

+(DPCChipStack*)parseStack:(NSString*)str {
    DPCChipStack* stack=[[DPCChipStack alloc]init];
    for (int i=0;i<str.length;i+=2) {
        NSString* thisChipStr=[str substringWithRange:NSMakeRange(i,2)];
        [stack addChip:[DPCChip parseChip:thisChipStr]];
    }
    return stack;
}

-(int)value {
    int value=0;
    DPCWorldLayer* mWL=[[DPCGame sharedGame] getWorldLayer];
    for (int i=0;i<self.size;i++) {
        if (![self getChip:i].pooling) {
            value+=[mWL.chipCase getValueForChipType:[self getChip:i].chipType];
        }
    }
    return value;
}

-(void)buildStackFrom:(NSArray*)build {
    for (int chip=CHIP_CASE_CHIP_TYPES-1;chip>=0;chip--) {
        [self addChipsOfType:chip number:[[build objectAtIndex:chip] intValue]];
    }
}

-(NSString*)description {
    NSString* str=@"";
    for (int i=0;i<self.size;i++) {
        NSString* thisChipString=[[self getChip:i] description];
        str=[NSString stringWithFormat:@"%@%@",str,thisChipString];
    }
    return str;
}

@end
