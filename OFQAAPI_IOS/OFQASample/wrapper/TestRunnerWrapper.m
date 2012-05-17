//
//  TestRunnerWrapper.m
//  OFQAAPI
//
//  Created by lei zhu on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestRunnerWrapper.h"

#import "CaseBuilder.h"
#import "TcmCaseBuilder.h"
#import "FileCaseBuilder.h"
#import "StepHolder.h"
#import "TestRunner.h"
#import "CaseBuilderFactory.h"
#import "TcmCommunicator.h"

#import "TestCaseWrapper.h"

#import "objc/runtime.h"


#import "SampleStepDefinition.h"
#import "CommenStepDefinition.h"
#import "AchievementStepDefinition.h"
#import "LeaderboardStepDefinition.h"
#import "PeopleStepDefinition.h"
#import "ModerationStepDefinition.h"
#import "FriendCodeStepDefinition.h"
#import "IgnorelistStepDefinition.h"
//#import "PaymentStepDefinition.h"


@implementation TestRunnerWrapper

@synthesize runner;
@synthesize caseWrappers;
@synthesize cb;
@synthesize type;

- (id)initWithRawData:(NSData*) rawData builderType:(int) t {
    self = [super init];
    if (self) {
        
        [self setRunner:[[[TestRunner alloc] init] autorelease]];
        
        [self setCaseWrappers:[[[NSMutableArray alloc] init] autorelease]];
        
        NSArray* classArray = [[NSArray alloc] initWithObjects:
                               class_createInstance([CommenStepDefinition class], 0), 
                               class_createInstance([AchievementStepDefinition class], 0),
                               class_createInstance([LeaderboardStepDefinition class], 0), 
                               class_createInstance([PeopleStepDefinition class], 0),
                               class_createInstance([ModerationStepDefinition class], 0),
                               class_createInstance([FriendCodeStepDefinition class], 0),
                               class_createInstance([IgnorelistStepDefinition class], 0),
                               nil];
        
        
//        id p = class_createInstance([CommenStepDefinition class], 0);
//        id p2 = class_createInstance([AchievementStepDefinition class], 0);
//        id p3 = class_createInstance([LeaderboardStepDefinition class], 0);
//        id p5 = class_createInstance([PeopleStepDefinition class], 0);        
//        id p4 = class_createInstance([ModerationStepDefinition class], 0);
////        id p6 = class_createInstance([PaymentStepDefinition class], 0);
//        id p7 = class_createInstance([FriendCodeStepDefinition class], 0);
        
        StepHolder* holder = [[StepHolder alloc] init];
        
        for (id p in classArray) {
            [holder addStepObj:p];
        }
//        
//        [holder addStepObj:p];
//        [holder addStepObj:p2];
//        [holder addStepObj:p3];
//        [holder addStepObj:p5];
//        [holder addStepObj:p4];
//        [holder addStepObj:p7];
//        [holder addStepObj:p6];
        
        [self setCb:[CaseBuilderFactory makeBuilderByType:t 
                                               raw:rawData
                                        stepHolder:holder]];
        [self setType:t];
        
        [holder release];

    }
    return self;
}

- (void) addCaseWrappers:(NSArray*) testCaseWrappers{
    
}

- (NSArray*) getCaseWrappers{
    NSSortDescriptor* sortByCaseId = [NSSortDescriptor sortDescriptorWithKey:@"cId" 
                                                                    ascending:YES];
    [caseWrappers sortUsingDescriptors:[NSArray arrayWithObject:sortByCaseId]];
    return caseWrappers;
}

- (void) executeSelectedCasesWithSubmit:(NSString*) runId 
                                  block:(void(^)(TcmCommunicator* tcmC, NSString* rId, NSArray* cs))block{
    // empty runner first
    [runner emptyCases];
    
    // build runner secretly
    int i=0;
    while (i<caseWrappers.count) {
        TestCaseWrapper* tcw = [caseWrappers objectAtIndex:i];
        if ([tcw isSelected]) {
            TestCase* t = [tcw tc];
            [t setIsExecuted:NO];
            [t setResultComment:@""];
            [runner addCase:t];
            [caseWrappers removeObject:tcw];
        }else{
            i++;
        }
    }
    
    // run cases
    [runner runAllcases];
    
    // submit to tcm if needed
    if ([self type] == [CaseBuilderFactory TCM_BUILDER] && block) {
        TcmCommunicator* tcmComm = [[self cb] tcmComm];
        block(tcmComm, runId, [runner getAllCases]);
    }
       
    // get case result and rebuilt case wrappers
    NSArray* executedCases = [runner getAllCases];
    for (int j=0; j<executedCases.count; j++) {
        TestCase* tc = [executedCases objectAtIndex:j];
        TestCaseWrapper* tcw = [[[TestCaseWrapper alloc] initWithTestCase:tc 
                                                                selected:true
                                                                  result:[tc result]] autorelease]; 
        [caseWrappers addObject:tcw];
        //[tcw release];
    }
}



- (void) emptyCaseWrappers{
    [runner emptyCases];
    [caseWrappers removeAllObjects];
}

- (void) buildRunner:(NSString*) suiteId{
    [self emptyCaseWrappers];
    
    NSArray* tmpCases = [cb buildCasesBySuiteId:suiteId];
    for (int i=0; i<tmpCases.count; i++) {
        
        TestCaseWrapper* tcw = [[TestCaseWrapper alloc] initWithTestCase:[tmpCases objectAtIndex:i]]; 
        [caseWrappers addObject:tcw];
        [tcw release];

    }
}

- (void) markCaseWrappers:(BOOL) isSelected{
    for (int i=0; i<caseWrappers.count; i++) {
        [[caseWrappers objectAtIndex:i] setIsSelected:isSelected];
    }
}


- (void)dealloc{
    [runner release];
    [caseWrappers release];
    [cb release];
    [super dealloc];
}

@end
