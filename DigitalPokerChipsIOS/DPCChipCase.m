//
//  DPCChipCase.m
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 9/04/14.
//
//

#import "DPCChipCase.h"

int const CHIP_CASE_CHIP_A=0;
int const CHIP_CASE_CHIP_B=1;
int const CHIP_CASE_CHIP_C=2;
int const CHIP_CASE_CHIP_TYPES=3;

@implementation DPCChipCase

+(id)chipCase {
    DPCChipCase* newChipCase=[[DPCChipCase alloc] init];
    newChipCase.values=[NSMutableArray array];
    for (int i=0;i<CHIP_CASE_CHIP_TYPES;i++) {
        [newChipCase.values addObject:[NSNumber numberWithInt:1]];
    }
    return newChipCase;
}

-(void)setValue:(int)value chipType:(int)chipType {
    [_values setObject:[NSNumber numberWithInt:value] atIndexedSubscript:chipType];
}

-(int)getValueForChipType:(int)chipType {
    return [[_values objectAtIndex:chipType] intValue];
}

-(void)setValuesFromChipCase:(DPCChipCase*)chipCase {
    for (int i=0;i<_values.count&&i<chipCase.values.count;i++) {
        [self setValue:[chipCase.values[i] intValue] chipType:i];
    }
}

@end
