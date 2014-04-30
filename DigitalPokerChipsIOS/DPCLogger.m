//
//  DPCLogger.m
//  DigitalPokerChipsIOS
//
//  Created by Peter Oliver on 1/05/2014.
//  Copyright (c) 2014 Bidjee. All rights reserved.
//

#import "DPCLogger.h"

@implementation DPCLogger

+(void)log:(NSString*)tag msg:(NSString*)msg {
    NSString* logMsg=[NSString stringWithFormat:@"%@ - %@",tag,msg];
    NSLog(logMsg);
    [self appendFile:tag msg:msg];
}

+(void)appendFile:(NSString*)tag msg:(NSString*)msg {
    msg=[NSString stringWithFormat:@"%@: %@%@",[self getTimeStamp],msg,@"\n"];
    NSData *dataToWrite = [[NSString stringWithString:msg] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *docsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileName=[NSString stringWithFormat:@"%@.txt",tag];
    NSString *path = [docsDirectory stringByAppendingPathComponent:fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success=NO;
    if (![fileManager fileExistsAtPath:path]) {
        success=[[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
        [dataToWrite writeToFile:path atomically:YES];
    } else {
        NSFileHandle *myHandle = [NSFileHandle fileHandleForWritingAtPath:path];
        [myHandle seekToEndOfFile];
        [myHandle writeData:dataToWrite];
    }
    
    
    
}

+(NSString*)getTimeStamp {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm:ss a"];
    return [formatter stringFromDate:[NSDate date]];
}


@end
