//
//  DPCDiscoveredTable.h
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 9/04/14.
//
//

#import <Foundation/Foundation.h>

#import "DPCChipCase.h"

@interface DPCDiscoveredTable : NSObject

@property NSData* hostBytes;
@property NSString* tableName;
@property DPCChipCase* chipCase;

-(id)initWithHostByes:(NSData*)hostBytes name:(NSString*)tableName chipCase:(DPCChipCase*)chipCase;

@end
