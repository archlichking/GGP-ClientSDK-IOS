//
//  QAAutoFramework.h
//  QAAutoLib
//
//  Created by zhu lei on 9/19/12.
//  Copyright (c) 2012 OFQA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TestCase;
@class TestRunner;
@class CaseBuilder;

extern const int SelectAll;
extern const int SelectFailed;
extern const int SelectNone;

@interface QAAutoFramework : NSObject{
    @private
    NSArray* originalTestCases;
    NSMutableArray* currentTestCases;
    TestRunner* runner;
    CaseBuilder* builder;
}

@property (copy) NSMutableArray* currentTestCases;

+ (QAAutoFramework*) sharedInstance;
+ (QAAutoFramework*) initializeWithSettings:(NSDictionary*) settings;

- (void) buildCases:(NSString*) suiteId;
- (void) filterCases:(int) filter;

- (void) runAllCases;
- (void) runCases:(NSArray*) cases;
- (void) runCase:(TestCase*) caze;
- (void) runAllCasesWithTcmSubmit:(NSString*) runId;
@end
