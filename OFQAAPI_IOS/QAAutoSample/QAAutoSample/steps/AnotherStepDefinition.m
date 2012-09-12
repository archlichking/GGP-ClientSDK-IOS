//
//  AnotherStepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AnotherStepDefinition.h"
#import "OFAssert.h"

@implementation AnotherStepDefinition

- (void) Given_I_want_to_do_something{
}

- (void) Then_10_plus_30_should_be_70{
    [OFAssert assertEqualsExpected:@"40" Actual:@"70"];
}

- (void) Then_complex_10_plus_20_should_be_40{
    [OFAssert assertEqualsExpected:@"30" Actual:@"40"];
}


@end
