//
//  DPCChip.m
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 10/04/14.
//
//

#import "DPCChip.h"
#import "DPCChipCase.h"

@interface DPCChip () {
}
@end

@implementation DPCChip

static float perspectiveGradient=0.012f;
static float Z_Y_OFFSET_RATIO=0.045f;
static float Z_X_OFFSET_RATIO=0.04f;

static int radiusXChip;
static int radiusYChip;

-(id)initWithParent:(CCNode*)parent chipType:(int)chipType x:(float)x y:(float)y z:(float)z {
    if (self=[super init]) {
        _chipType=chipType;
        _imgRotation=(int)(arc4random() % 3);
        NSString* fileName=[NSString stringWithFormat:@"chip_%d_%d.png",_chipType,_imgRotation];
        //[self setTexture:[[CCTextureCache sharedTextureCache] addImage:fileName]];
        [self setTexture:[CCTexture textureWithFile:fileName]];
        [self setTextureRect:CGRectMake(0,0,self.texture.contentSize.width,self.texture.contentSize.height)];
        self.z=z;
        self.position=CGPointMake(x,y);
        self.isTouched=false;
        _pooling=false;
        [parent addChild:self];
    }
    return self;
}

-(void)remove {
    [self removeFromParentAndCleanup:YES];
}

-(BOOL)animateToDest:(float)delta {
    BOOL isAtDest=NO;
    if (fabsf(self.yBeforeZOffset-self.destination.y)<1&&
        fabsf(self.position.x-self.destination.x)<1&&
        fabsf(self.z-self.zDest)<1) {
        isAtDest=true;
        self.position=self.destination;
        self.z=self.zDest;
    } else {
        float timeFactor = delta*9;
        if (self.isTouched) {
            timeFactor*=3;
        }
        timeFactor=MIN(timeFactor,1);
        float newY=(float)(self.yBeforeZOffset-timeFactor*(self.yBeforeZOffset-self.destination.y));
        float newX=(float)(self.position.x-timeFactor*(self.position.x-self.destination.x));
        float newZ=(float)(self.z-timeFactor*(self.z-self.zDest));
        self.position=CGPointMake(newX,newY);
        self.z=newZ;
    }
    return isAtDest;
}

-(BOOL)pointContained:(CGPoint)point {
    BOOL contained=false;
    CGPoint pointInParent=[self.parent convertToNodeSpace:point];
    float deltaTouchX=pointInParent.x-self.position.x;
    float deltaTouchY=pointInParent.y-self.position.y;
    float xDist=fabsf(deltaTouchX)/self.radiusX;
    float yDist=fabsf(deltaTouchY)/self.radiusY;
    float totalDist = (float) (xDist*xDist+yDist*yDist);
    if (totalDist < 1) {
        contained=true;
    }
    return contained;
}

-(void)setDeltaTouchFromTouch:(CGPoint)touch {
    touch=[self.parent convertToNodeSpace:touch];
    float deltaX=touch.x-self.position.x;
    float deltaY=touch.y-self.yBeforeZOffset;
    self.deltaTouch=ccp(deltaX,deltaY);
}

-(void)setPosition:(CGPoint)position {
    self.yBeforeZOffset=position.y;
    float yNew=self.yBeforeZOffset+self.zyOffset;
    float xNew=position.x;
    super.position=CGPointMake(xNew,yNew);
}

-(void)setDestFromTouch:(CGPoint)touch {
    touch=[self.parent convertToNodeSpace:touch];
    self.destination=ccpSub(touch,self.deltaTouch);
}

-(void)setDestToPos {
    self.destination=ccp(self.position.x,self.yBeforeZOffset);
    self.zDest=self.z;
}

-(void)setZ:(float)z {
    [super setZ:z];
    int zInt=(int)roundf(self.z);
    self.zOrder=zInt;
    self.zyOffset=Z_Y_OFFSET_RATIO*radiusYChip*self.z*(1+0.5f*perspectiveGradient*(self.z-1));
    self.radiusX=radiusXChip*(1+z*perspectiveGradient);
    self.radiusY=radiusYChip*(1+z*perspectiveGradient);
}

-(void)setZyOffset:(float)zyOffset {
    _zyOffset=zyOffset;
    self.position=CGPointMake(self.position.x,self.yBeforeZOffset);
}

-(BOOL)atDest {
    if (fabsf(self.yBeforeZOffset-self.destination.y)<1&&
        fabsf(self.position.x-self.destination.x)<1&&
       fabsf(self.z-self.zDest)<1) {
        return YES;
    } else {
        return NO;
    }
}

-(void)setXYZToDest {
    self.position=self.destination;
    self.z=self.zDest;
}

+(int)getProjectedRadiusXForZ:(int)z {
    return (int) (radiusXChip*(1+z*perspectiveGradient));
}

+(int)getProjectedRadiusYForZ:(int)z {
    return (int) (radiusYChip*(1+z*perspectiveGradient));
}

+(int)projectRadius:(int)radius z:(float)z {
    return (int) (radius*(1+z*perspectiveGradient));
}

+(float)getProjectedDeltaForZ:(float)z {
    return Z_Y_OFFSET_RATIO*radiusYChip*z*(1+0.5f*perspectiveGradient*(z-1));
}

+(float)getProjectedDeltaForZ:(float)z radiusY:(int)radiusY {
    return Z_Y_OFFSET_RATIO*radiusY*z*(1+0.5f*perspectiveGradient*(z-1));
}

-(NSString*)description {
    NSString* str;
    if (self.chipType==CHIP_CASE_CHIP_A) {
        str=@"A";
    } else if (self.chipType==CHIP_CASE_CHIP_B) {
        str=@"B";
    } else if (self.chipType==CHIP_CASE_CHIP_C) {
        str=@"C";
    }
    str=[NSString stringWithFormat:@"%@%d",str,self.imgRotation];
    return str;
}

+(DPCChip*)parseChip:(NSString*)chipStr {
    DPCChip* chip;
    char c=[chipStr characterAtIndex:0];
    if (c=='A') {
        chip=[[DPCChip alloc] initWithParent:nil chipType:CHIP_CASE_CHIP_A x:0 y:0 z:0];
    } else if (c=='B') {
        chip=[[DPCChip alloc] initWithParent:nil chipType:CHIP_CASE_CHIP_B x:0 y:0 z:0];
    } else if (c=='C') {
        chip=[[DPCChip alloc] initWithParent:nil chipType:CHIP_CASE_CHIP_C x:0 y:0 z:0];
    }
    chip.imgRotation=[chipStr substringFromIndex:1].intValue;
    return chip;
}

+(void)setRadiusX:(int)radiusX {
    radiusXChip=radiusX;
}

+(void)setRadiusY:(int)radiusY {
    radiusYChip=radiusY;
}

+(int)getRadiusY {
    return radiusYChip;
}

+(int)getRadiusX {
    return radiusXChip;
}

+(float) testOverlap:(float)x1 y1:(float)y1 z1:(float)z1 x2:(float)x2 y2:(float)y2 z2:(float)z2 {
    float yOverlap=0;
    
    y1+=[DPCChip getProjectedDeltaForZ:z1];
    y2+=[DPCChip getProjectedDeltaForZ:z2];
    float radiusX1=[DPCChip getProjectedRadiusXForZ:z1];
    float radiusY1=[DPCChip getProjectedRadiusYForZ:z1];
    float radiusX2=[DPCChip getProjectedRadiusXForZ:z2];
    float radiusY2=[DPCChip getProjectedRadiusYForZ:z2]*(1-Z_Y_OFFSET_RATIO);
    if (fabsf(x1-x2)<radiusX1+radiusX2) {
        float dxR1=fabsf(x1-x2)*radiusX2/(radiusX1+radiusX2);
        float dyR1=(float) (sqrt(((radiusX2*radiusX2-dxR1*dxR1)*radiusY2*radiusY2)/(radiusX2*radiusX2)));
        float dyR2=dyR1*(radiusY1/radiusY2);
        float dyR=dyR1+dyR2;
        float dy12=fabsf(y1-y2);
        if (dy12<=dyR) {
            yOverlap=(y1<y2)?dyR-dy12:dy12-dyR;
        }
    }
    return yOverlap;
}

@end
