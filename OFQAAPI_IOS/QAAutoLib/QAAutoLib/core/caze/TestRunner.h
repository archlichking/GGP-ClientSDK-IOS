//
//  TestRunner.h
//  OFQAAPI
//
//  Created by lei zhu on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TestCase;

@interface TestRunner : NSObject{
    @private
    NSMutableArray* cases;
}

@property (retain) NSMutableArray* cases;


- (void) addCase:(TestCase*) caze;
- (void) addCases:(NSArray *) cazes;

- (void) emptyCases;
- (BOOL) hasCase;
- (NSArray*) getAllCases;
- (void) runAllcases;
@end
