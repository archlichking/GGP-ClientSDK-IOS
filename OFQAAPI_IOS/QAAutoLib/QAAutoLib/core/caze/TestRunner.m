//
//  TestRunner.m
//  OFQAAPI
//
//  Created by lei zhu on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestRunner.h"
#import "TestCase.h"

@implementation TestRunner

- (id) init{
    if (self = [super init]) {
    }
    return self;
}

- (void) runCases:(NSArray*) runningCases{
    for (int i=0; i<runningCases.count; i++) {
        TestCase* tc = [runningCases objectAtIndex:i];
        [tc execute];
    }
}

- (void) runCase:(TestCase*) tc{
    [tc execute];
}

//- (void)dealloc{
//    [cases release];
//    [super dealloc];
//}

@end
