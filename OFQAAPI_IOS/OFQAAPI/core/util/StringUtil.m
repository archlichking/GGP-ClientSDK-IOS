//
//  StringUtil.m
//  OFQAAPI
//
//  Created by lei zhu on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StringUtil.h"
#import "CommandUtil.h"

@implementation StringUtil

static NSString* FILE_LINE_SPLITER = @"\n";
static NSString* TCM_LINE_SPLITER = @"\r\n";

+ (NSString*) FILE_LINE_SPLITER{
    return FILE_LINE_SPLITER;
}
+ (NSString*) TCM_LINE_SPLITER{
    return TCM_LINE_SPLITER;
}

+ (NSArray*) splitStepsFrom:(NSString*) raw
                         by:(NSString*) spliter{
    if ((NSNull*) raw == [NSNull null] 
        || raw == nil  
        || [raw length] == 0) {
        // no step returns, return an empty nsarray
        return [[[NSArray alloc] init] autorelease];
    }else{
        return [raw componentsSeparatedByString:spliter];
        
    }
}

+ (NSArray*) extractStepsFrom:(NSArray*) rawCase{
    NSMutableArray* unfilteredRawCase = [[[NSMutableArray alloc] initWithArray:rawCase] autorelease];
    int i = 0;
    while(i<unfilteredRawCase.count) {
        NSString* s = [unfilteredRawCase objectAtIndex:i];
        if ([s hasPrefix:[CommandUtil GIVEN_FILTER]] 
            || [s hasPrefix:[CommandUtil WHEN_FILTER]] 
            || [s hasPrefix:[CommandUtil THEN_FILTER]]
            || [s hasPrefix:[CommandUtil AND_FILTER]]) {
            i++;
            continue; 
        }else{
            [unfilteredRawCase removeObjectAtIndex:i];
        }
    }
    
    return unfilteredRawCase;
}

+ (NSString*) methodNameToCommand:(NSString*) methodName{
    NSString* s = [methodName stringByReplacingOccurrencesOfString:@"_" 
                                                        withString:@" "];
    return s;
}

+ (NSRegularExpression*) methodNameToRegexp:(NSString*) methodName{
    NSString* s0 = [NSString stringWithFormat:@"%@_%@", @"PARAM:", methodName];
    
    NSString* s1 = [s0 stringByReplacingOccurrencesOfString:@"_" 
                                                        withString:@" "];
    NSString* s2 = [s1 stringByReplacingOccurrencesOfString:@"PARAM:" 
                                                 withString:@"(.*)"];
    
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:s2 
                                                                           options:NSRegularExpressionCaseInsensitive 
                                                                             error:NULL];
    return regex;
}

@end
