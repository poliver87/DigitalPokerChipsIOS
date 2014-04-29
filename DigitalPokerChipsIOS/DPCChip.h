//
//  DPCChip.h
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 10/04/14.
//
//

#import "DPCSprite.h"

extern int const CHIP_ROTATION_0;
extern int const CHIP_ROTATION_135;
extern int const CHIP_ROTATION_202;
extern int const CHIP_ROTATION_N;

@interface DPCChip : DPCSprite

@property int chipType;
@property int imgRotation;
@property (nonatomic) float zyOffset;
@property float yBeforeZOffset;
@property (nonatomic) BOOL atDest;
@property BOOL pooling;

-(id)initWithParent:(CCNode*)parent chipType:(int)chipType x:(float)x y:(float)y z:(float)z;
-(void)remove;
-(BOOL)animateToDest:(float)delta;
-(void)setXYZToDest;
-(void)setDeltaTouchFromTouch:(CGPoint)touch;

+(int)getProjectedRadiusXForZ:(int)z;
+(int)getProjectedRadiusYForZ:(int)z;
+(int)projectRadius:(int)radius z:(float)z;
+(float)getProjectedDeltaForZ:(float)z;
+(float)getProjectedDeltaForZ:(float)z radiusY:(int)radiusY;
+(DPCChip*)parseChip:(NSString*)chipStr;

+(void)setRadiusX:(int)radiusX;
+(void)setRadiusY:(int)radiusY;
+(int)getRadiusY;
+(int)getRadiusX;
+(float)testOverlap:(float)x1 y1:(float)y1 z1:(float)z1 x2:(float)x2 y2:(float)y2 z2:(float)z2;

@end
