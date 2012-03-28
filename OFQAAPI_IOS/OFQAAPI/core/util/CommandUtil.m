//
//  CommandUtil.m
//  OFQAAPI
//
//  Created by lei zhu on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommandUtil.h"

@implementation CommandUtil

static NSString* GIVEN_FILTER = @"Given";
static NSString* WHEN_FILTER = @"When";
static NSString* THEN_FILTER = @"Then";
static NSString* AND_FILTER = @"And";

+ (NSString*) GIVEN_FILTER{
    return GIVEN_FILTER;
}
+ (NSString*) WHEN_FILTER{
    return WHEN_FILTER;
}
+ (NSString*) THEN_FILTER{
    return THEN_FILTER;
}
+ (NSString*) AND_FILTER{
    return AND_FILTER;
}

@end
