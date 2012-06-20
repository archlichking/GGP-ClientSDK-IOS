//
//  StringUtil.m
//  OFQAAPI
//
//  Created by lei zhu on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StringUtil.h"
#import "CommandUtil.h"
#import "NoCommandMatchException.h"
#import "QALog.h"

NSString* const SpliterFileLine = @"\n";
NSString* const SpliterTcmLine = @"\r\n";

@implementation StringUtil

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
        if ([s hasPrefix:CommandGiven] 
            || [s hasPrefix:CommandWhen] 
            || [s hasPrefix:CommandThen]
            || [s hasPrefix:CommandAnd]
            || [s hasPrefix:CommandBefore]
            || [s hasPrefix:CommandAfter]) {
            i++;
            continue; 
        }else{
            //[unfilteredRawCase removeObjectAtIndex:i];
            // raise NoCommandMatchException directly if line doesnt start with keyword
            QALog(@"[%@] doesnt start with reserved keyword", s);
            [NoCommandMatchException raise:@"line doesnt started with keywords" 
                                    format:@"line doesnt started with keywords"];
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
    // add command to method name
    NSString* s0 = [NSString stringWithFormat:@"%@_%@", @"PARAMSTART:", methodName];
    
    NSString* s1 = [s0 stringByReplacingOccurrencesOfString:@"_" 
                                                 withString:@" "];
    // parse string
    NSString* s2 = [s1 stringByReplacingOccurrencesOfString:@"PARAMSTART:" 
                                                 withString:@"([A-Za-z]+)"];
    // parse number
    NSString* s3 = [s2 stringByReplacingOccurrencesOfString:@"PARAMINT:" 
                                                 withString:@"([-]?\\d+)"];
    // parse string
    NSString* s4 = [s3 stringByReplacingOccurrencesOfString:@"PARAM:" 
                                                 withString:@"(.*)"];
    
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:s4
                                                                           options:NSRegularExpressionCaseInsensitive 
                                                                             error:NULL];
    return regex;
}

@end
