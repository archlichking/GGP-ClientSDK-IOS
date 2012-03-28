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

@synthesize cases;

- (id) init{
    if (self = [super init]) {
        NSMutableArray* mt = [[NSMutableArray alloc] init];
        [self setCases:mt];
        [mt release];
    }
    return self;
}

- (void) addCase:(TestCase*) caze{
    [[self cases] addObject:caze];
}
- (void) addCases:(NSArray *) cazes{
    [[self cases] addObjectsFromArray:cazes];
}

- (void) emptyCases{
    [[self cases] removeAllObjects];
}

- (BOOL) hasCase{
    return [[self cases] count] == 0;
}

- (NSArray*) getAllCases{
    return [self cases];
}

- (void) runAllcases{
    for (int i=0; i<cases.count; i++) {
        TestCase* tc = [cases objectAtIndex:i];
        [tc execute];
    }
}

//- (void)dealloc{
//    [cases release];
//    [super dealloc];
//}

@end
