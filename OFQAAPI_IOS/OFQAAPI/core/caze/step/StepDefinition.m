//
//  StepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StepDefinition.h"
#import "QAAssert.h"
#import "QALog.h"
#import "AssertException.h"

@implementation StepDefinition

static int FAILED = 1;
static int WAITING = 0;
static int PASSED = 2;

+ (int) WAITING{
    return WAITING;
}

+ (int) FAILED{
    return FAILED;
}

+ (int) PASSED{
    return PASSED;
}


@synthesize blockSentinal;
@synthesize blockActual;
@synthesize blockExpected;

- (void) assertWithBlockSentinal:(void(^)(id expected, id result))block{
    switch ([self blockSentinal]) {
        case 1:
            [AssertException raise:@"assert failed" 
                            format:@"message would be []", [self blockActual]];
            break;
        case 2:
            block([self blockExpected], [self blockActual]);        
            break;
        default:
            break;
    }
}

@end
