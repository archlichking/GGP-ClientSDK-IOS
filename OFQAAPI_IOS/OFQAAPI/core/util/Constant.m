//
//  Constant.m
//  OFQAAPI
//
//  Created by lei zhu on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Constant.h"

@implementation Constant

static int FAILED = 5;
static int RETESTED = 4;
static int PASSED = 1;
static int UNTESTED = 0;

+ (int) FAILED{
    return FAILED;
}

+ (int) RETESTED{
    return RETESTED;
}

+ (int) PASSED{
    return PASSED;
}

+ (int) UNTESTED{
    return UNTESTED;
}

+ (NSString*) getReadableResule:(int) res{
    NSString* ret;
    switch (res) {
        case 5:
            ret = @"failed";
            break;
        case 4:
            ret = @"retested";
            break;
        case 1:
            ret = @"passed";
            break;
        case 0:
            ret = @"untested";
            break;
        default:
            return @"error";
            break;
    }
    return ret;
}

@end
