//
//  QAAutoFramework.m
//  QAAutoLib
//
//  Created by zhu lei on 9/19/12.
//  Copyright (c) 2012 OFQA. All rights reserved.
//

#import "QAAutoFramework.h"

#import "TestRunner.h"
#import "StepHolder.h"

#import "CaseBuilderFactory.h"
#import "CaseBuilder.h"

static QAAutoFramework* sSharedInstance = nil;

@implementation QAAutoFramework

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
    runner = [[[TestRunner alloc] init] autorelease];
    
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
    originalTestCases = [builder buildCasesBySuiteId:suiteId == nil?@"178":suiteId];
    
}

@end
