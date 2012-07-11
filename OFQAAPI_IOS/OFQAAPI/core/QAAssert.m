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

+ (void) assertContainsExpected:(id)expected 
                       Contains:(id)result{
    if ([expected rangeOfString:result].length <= 0) {
        [AssertException raise:@"assertIncludes failed" 
                        format:@"expected:<%@> should contain result:<%@>", expected, result];
    }
}

+ (void) assertContainsExpected:(id)expected 
                       Contains:(id)result
                    WithMessage:(NSString*) message{
    if ([expected rangeOfString:result].length <= 0) {
        [AssertException raise:@"assertIncludes failed" 
                        format:@"expected:<%@> should contain result:<%@> with message [%@]", expected, result, message];
    }
}

+ (void) assertNotNil:(id)result{
    if (result == nil) {
        [AssertException raise:@"assertNotNil failed" 
                        format:@"expected:not nil but was:<%@> with message [%@]", result];
    }
}

+ (void) assertNotNil:(id)result 
          WithMessage:(NSString*) message{
    if (result == nil) {
        [AssertException raise:@"assertNotNil failed" 
                        format:@"expected:not nil but was:<%@> with message [%@]", result, message];
    }
}

+ (void) assertNil:(id)result{
    if (result != nil) {
        [AssertException raise:@"assertNil failed" 
                        format:@"expected:nil but was:<%@> with message [%@]", result];
    }
}

+ (void) assertNil:(id)result 
       WithMessage:(NSString*) message{
    if (result != nil) {
        [AssertException raise:@"assertNil failed" 
                        format:@"expected:nil but was:<%@> with message [%@]", result, message];
    }
}

@end
