//
//  DPCDiscoveredTable.m
//  Digital Poker Chips iOS
//
//  Created by Peter Oliver on 9/04/14.
//
//

#import "DPCDiscoveredTable.h"

@implementation DPCDiscoveredTable

-(id)initWithHostByes:(NSData*)hostBytes name:(NSString*)tableName chipCase:(DPCChipCase*)chipCase {
    if (self=[super init]) {
        _hostBytes=hostBytes;
        _tableName=tableName;
        _chipCase=chipCase;
    }
    return self;
}

@end
