//
//  Constant.m
//  OFQAAPI
//
//  Created by lei zhu on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Constant.h"

int const CaseResultFailed = 5;
int const CaseResultRetested = 4;
int const CaseResultPassed = 1;
int const CaseResultUntested = 0;

NSString* const CommandNotifyLoadPopup = @"loadPopup";
NSString* const CommandNotifyDismissPopup = @"dismissPopup";

@implementation Constant

+ (NSString*) getReadableResult:(int) res{
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
