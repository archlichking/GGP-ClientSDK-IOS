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

- (NSMutableDictionary*) getBlockRepo{
    if (!blockRepo) {
        blockRepo = [[NSMutableDictionary alloc] init];
    }
    return blockRepo;
}

@end
