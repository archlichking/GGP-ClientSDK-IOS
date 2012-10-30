//
//  QAAutoFramework.m
//  QAAutoLib
//
//  Created by zhu lei on 9/19/12.
//  Copyright (c) 2012 OFQA. All rights reserved.
//

#import "QAAutoFramework.h"

#import "TestRunner.h"
#import "TestRunner+TcmResultPusher.h"
#import "TestCase.h"
#import "Constant.h"
#import "StepHolder.h"

#import "objc/runtime.h"
#import <mach/mach.h>

#import "CaseBuilderFactory.h"
#import "CaseBuilder.h"

const int SelectAll = 1;
const int SelectFailed = 2;
const int SelectNone = 10;

static QAAutoFramework* sSharedInstance = nil;

@implementation QAAutoFramework

@synthesize currentTestCases;

+ (QAAutoFramework*) sharedInstance{
    return sSharedInstance;
}

+ (QAAutoFramework*) initializeWithSettings:(NSDictionary*) settings{
    if (!sSharedInstance) {
        sSharedInstance = [[QAAutoFramework alloc] initWithData:[settings objectForKey:@"data"]
                                                      buildType:[settings objectForKey:@"type"]
                                                          steps:[settings objectForKey:@"steps"]];
    }
    return sSharedInstance;
}


- (id) initWithData:(NSData*) rawData buildType:(NSString*) buildType steps:(NSArray*) stepDefinitions{
    runner = [[TestRunner alloc] init];
    
    StepHolder* holder = [[StepHolder alloc] init];
    
    for (id p in stepDefinitions) {
        [holder addStepObj:p];
    }
    
    // initialize all private fields
    builder = [CaseBuilderFactory makeBuilderByType:[buildType intValue]
                                      raw:rawData
                               stepHolder:holder];
    [holder release];
    return self;
}

- (void) buildCases:(NSString*) suiteId{
    if (originalTestCases) {
        [originalTestCases release];
    }
    if (currentTestCases) {
        [currentTestCases release];
    }
    originalTestCases = [[NSArray alloc] initWithArray:[builder buildCasesBySuiteId:suiteId]];
    currentTestCases = [[NSMutableArray alloc] init];
    
}

- (void) filterCases:(int) filter{
    NSMutableArray* filteredCases = [[NSMutableArray alloc] initWithArray:currentTestCases];
    [currentTestCases removeAllObjects];
    switch (filter) {
        case SelectAll:
            
            [currentTestCases addObjectsFromArray:originalTestCases];
            break;
        case SelectFailed:
            
            for (TestCase* tc in filteredCases) {
                if ([tc result] == CaseResultFailed) {
                    [currentTestCases addObject:tc];
                }
            }
            
            break;
        case SelectNone:
            break;
        default:
            break;
    }
    [filteredCases release];
}

- (void) runAllCases{
    [runner runCases:currentTestCases];
}

- (void) runCase:(TestCase*) caze{
    [runner runCase:caze];
}

- (void) runCases:(NSArray*) cases{
    if(currentTestCases){
        [currentTestCases removeAllObjects];
    }
    [currentTestCases addObjectsFromArray:cases];
    [runner runCases:currentTestCases];
    
}

- (void) runAllCasesWithTcmSubmit:(NSString*) runId{
    [self runAllCases];
    [runner pushCases:currentTestCases
              toRunId:runId];
}

- (void) submitTcm:(NSString*) runId{
    [runner pushCases:currentTestCases
             toRunId:runId];
}

@end
