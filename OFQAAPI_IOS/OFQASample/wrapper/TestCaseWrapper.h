//
//  TestCaseWrapper.h
//  OFQAAPI
//
//  Created by lei zhu on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TestCase;

@interface TestCaseWrapper : NSObject{
    @private
    TestCase* tc;
    int cId;
    BOOL isSelected;
    NSString* result;
    
    
}

@property (retain) TestCase* tc;
@property (assign) BOOL isSelected;
@property (assign) int cId;
@property (copy) NSString* result;

- (id)initWithTestCase:(TestCase*) testCase;
- (id)initWithTestCase:(TestCase*) testCase 
              selected:(BOOL) select 
                result:(int) r;

+ (int) All;
+ (int) Failed;
+ (int) UnAll;

@end
