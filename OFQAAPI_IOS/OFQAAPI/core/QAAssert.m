//
//  OFAssert.m
//  OFQAAPI
//
//  Created by lei zhu on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QAAssert.h"
#import "AssertException.h"

@implementation QAAssert


+ (void) assertEqualsExpected:(id)expected 
                       Actual:(id)result{
    if (![expected isEqualToString:result]) {
        [AssertException raise:@"assertEquals failed" 
                        format:@"expected:<%@> but was:<%@>", expected, result];
    }
}

+ (void) assertEqualsExpected:(id)expected 
                       Actual:(id)result 
                  WithMessage:(NSString*) message{
    if (![expected isEqualToString:result]) {
        [AssertException raise:@"assertEquals failed" 
                        format:@"expected:<%@> but was:<%@> with message [%@]", expected, result, message];
    }
}

+ (void) assertNotEqualsExpected:(id)expected 
                          Actual:(id)result{
    if ([expected isEqualToString:result]) {
        [AssertException raise:@"assertEquals failed" 
                        format:@"expected:<%@> but was:<%@>", expected, result];
    }
}

+ (void) assertNotEqualsExpected:(id)expected 
                          Actual:(id)result 
                     WithMessage:(NSString*) message{
    if ([expected isEqualToString:result]) {
        [AssertException raise:@"assertEquals failed" 
                        format:@"expected:<%@> but was:<%@> with message [%@]", expected, result, message];
    }
}

@end
