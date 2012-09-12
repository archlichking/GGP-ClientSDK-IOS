//
//  LoggerStepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 9/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoggerStepDefinition.h"

#import "GreeLogger.h"
#import "GreePlatform.h"

#import "QAAssert.h"

@implementation LoggerStepDefinition


- (NSString*) integerizeLogLevel:(NSString*) level{
    if ([level isEqualToString:@"ERROR"]) {
        return @"0";
    }
    else if([level isEqualToString:@"WARN"]){
        return @"25";
    }
    else if([level isEqualToString:@"INFO"]){
        return @"50";
    }
    else if([level isEqualToString:@"DEBUG"]){
        return @"75";
    }
    else if([level isEqualToString:@"VERBOSE"]){
        return @"100";
    }
    return @"-100";
}

- (void) I_set_the_logging_level_to_PARAM:(NSString*) level{
    [[[GreePlatform sharedInstance] logger] setLevel:[level integerValue]];
}

- (void) debug_logging_level_should_be_PARAM:(NSString*) level{
    [QAAssert assertEqualsExpected:[self integerizeLogLevel:level] 
                            Actual:[NSString stringWithFormat:@"%d", [[[GreePlatform sharedInstance] logger] level]]];
}

@end
