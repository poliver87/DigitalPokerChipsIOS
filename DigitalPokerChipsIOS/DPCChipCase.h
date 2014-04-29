//
//  DPCChipCase.h
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 9/04/14.
//
//

#import <Foundation/Foundation.h>

extern int const CHIP_CASE_CHIP_A;
extern int const CHIP_CASE_CHIP_B;
extern int const CHIP_CASE_CHIP_C;
extern int const CHIP_CASE_CHIP_TYPES;

@interface DPCChipCase : NSObject

@property NSMutableArray* values;

+(id)chipCase;

-(void)setValue:(int)value chipType:(int)chipType;
-(int)getValueForChipType:(int)chipType;
-(void)setValuesFromChipCase:(DPCChipCase*)chipCase;

@end
