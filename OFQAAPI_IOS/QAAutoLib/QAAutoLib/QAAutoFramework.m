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
    originalTestCases = [builder buildCasesBySuiteId:suiteId];
    currentTestCases = [[NSMutableArray alloc] init];
    
}

- (void) filterCases:(int) filter{
    NSMutableArray* filteredCases = [currentTestCases retain];
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

- (void) runCases{
    [runner runCases:currentTestCases];
}

- (void) runCases:(NSArray*) cases{
    if(currentTestCases){
        [currentTestCases release];
    }
    currentTestCases = [NSMutableArray arrayWithArray:cases];
    [runner runCases:currentTestCases];
    
}

- (void) runCases:(NSArray *)cases
    withTcmSubmit:(NSString*) runId
withNotificationBlock:(void(^)(NSDictionary* params))block{
    if (cases) {
        currentTestCases = [NSMutableArray arrayWithArray:cases];
    }
        // case running
    for (TestCase* tc in currentTestCases) {
        [runner runCase:tc];
    }
    
    // case submitting
    for (TestCase* tc in currentTestCases){
        [runner pushCase:tc
                 toRunId:runId];
        // update ui
    }
}

- (void) runCasesWithTcmSubmit:(NSString*) runId{
    [self runCases];
    [runner pushCases:currentTestCases
              toRunId:runId];
}

@end
