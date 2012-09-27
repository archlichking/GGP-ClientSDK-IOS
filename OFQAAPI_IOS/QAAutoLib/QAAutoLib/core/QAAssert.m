//
//  OFAssert.m
//  OFQAAPI
//
//  Created by lei zhu on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QAAssert.h"
#import "AssertException.h"

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>


@implementation QAAssert

+ (void) failWithException:(NSException*) e{
    [AssertException raise:[e name]
                    format:@"%@", [e reason]];
}

+ (void) assertEqualsExpected:(id)expected 
                       Actual:(id)result{
    assertThat(result, equalTo(expected));
}

+ (void) assertNotEqualsExpected:(id)expected 
                          Actual:(id)result{
    assertThat(result, isNot(equalTo(expected)));
}

+ (void) assertContainsExpected:(id)expected 
                       Contains:(id)result{
    assertThat(result, containsString(expected));
}

+ (void) assertNotNil:(id)result{
    assertThat(result, isNot(nilValue()));
}

+ (void) assertNil:(id)result{
    assertThat(result, nilValue());
}

@end
