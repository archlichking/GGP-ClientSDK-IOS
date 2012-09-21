//
//  TestRunner.h
//  OFQAAPI
//
//  Created by lei zhu on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TestCase;

@interface TestRunner : NSObject

- (void) runCases:(NSArray*) runningCases;
- (void) runCase:(TestCase*) t;
@end
