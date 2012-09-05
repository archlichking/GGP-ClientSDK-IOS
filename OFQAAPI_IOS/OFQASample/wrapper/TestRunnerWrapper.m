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
#import "Constant.h"

#import "objc/runtime.h"
#import <mach/mach.h>


#import "SampleStepDefinition.h"
#import "AuthorizationStepDefinition.h"
#import "AchievementStepDefinition.h"
#import "LeaderboardStepDefinition.h"
#import "PeopleStepDefinition.h"
#import "ModerationStepDefinition.h"
#import "FriendCodeStepDefinition.h"
#import "IgnorelistStepDefinition.h"
#import "NetworkStepDefinition.h"
#import "GreePlatformStepDefinition.h"
#import "PaymentStepDefinition.h"
#import "PopupStepDefinition.h"
#import "NotificationStepDefinition.h"
#import "BadgeStepDefinition.h"
#import "WidgetStepDefinition.h"
#import "LogJsKitStepDefinition.h"
#import "LoggerStepDefinition.h"
#import "AddonStepDefinition.h"

#import "QALog.h"


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
        
        NSArray* classArray = [[[NSArray alloc] initWithObjects:
                                class_createInstance([AuthorizationStepDefinition class], 0), 
                                class_createInstance([AchievementStepDefinition class], 0),
                                class_createInstance([LeaderboardStepDefinition class], 0), 
                                class_createInstance([PeopleStepDefinition class], 0),
                                class_createInstance([ModerationStepDefinition class], 0),
                                class_createInstance([FriendCodeStepDefinition class], 0),
                                class_createInstance([IgnorelistStepDefinition class], 0),
                                class_createInstance([NetworkStepDefinition class], 0),
                                class_createInstance([GreePlatformStepDefinition class], 0),
                                class_createInstance([PaymentStepDefinition class], 0),
                                class_createInstance([PopupStepDefinition class], 0),
                                class_createInstance([NotificationStepDefinition class], 0),
                                class_createInstance([BadgeStepDefinition class], 0),
                                class_createInstance([WidgetStepDefinition class], 0),
                                class_createInstance([LogJsKitStepDefinition class], 0),
                                 class_createInstance([LoggerStepDefinition class], 0),
                                class_createInstance([AddonStepDefinition class], 0),
//                                 class_createInstance([SampleStepDefinition class], 0),
                               nil] autorelease];

        StepHolder* holder = [[StepHolder alloc] init];
        
        for (id p in classArray) {
            [holder addStepObj:p];
        }
        
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

- (NSMutableArray*) getCaseWrappers{
    NSSortDescriptor* sortByCaseId = [NSSortDescriptor sortDescriptorWithKey:@"cId" 
                                                                    ascending:YES];
    [caseWrappers sortUsingDescriptors:[NSArray arrayWithObject:sortByCaseId]];
    return caseWrappers;
}

- (void) executeSelectedCasesWithSubmit:(NSString*) runId 
                                  block:(void(^)(NSArray* objs))block{
    // empty runner first
    [runner emptyCases];
    
    int alreadyDoneNumber = 0;
    NSString* doing = @"";
    NSString* mem = @"";
    
    
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
    
    int all = [[runner getAllCases] count];
    // run cases
    //[runner runAllcases];
    
    struct task_basic_info info;
    // used for memory inspect
    mach_msg_type_number_t size = sizeof(info);
    
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    unsigned long baseMem = 1l;
    
    if( kerr == KERN_SUCCESS ) {
        baseMem = info.resident_size;
    }
    
    for (int i=0; i<all; i++) {
        TestCase* tc = [[runner getAllCases] objectAtIndex:i];
        [tc execute];
        alreadyDoneNumber ++;
        
        doing = [NSString stringWithFormat:@"executing %d/%d", alreadyDoneNumber, all];
        
        kerr = task_info(mach_task_self(),
                                       TASK_BASIC_INFO,
                                       (task_info_t)&info,
                                       &size);
        if( kerr == KERN_SUCCESS ) {
            mem = [NSString stringWithFormat:@"mem usage(MB):%0.3f, INC by:%0.2f", 
                   (float)info.resident_size/(1024*1024), 
                   (float)(info.resident_size-baseMem)*100/baseMem];
        }
        
        block([[[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%0.1f", (float)alreadyDoneNumber/all], 
                doing, 
                mem,
                nil] autorelease]);
    }
    
    alreadyDoneNumber = 0.;
    // submit to tcm if needed
    if ([self type] == [CaseBuilderFactory TCM_BUILDER] && block) {
        TcmCommunicator* tcmComm = [[self cb] tcmComm];
        
       
        for (int i=0; i<all; i++) {
            TestCase* tc = [[runner getAllCases] objectAtIndex:i];
            [tcmComm postCasesResultByRunId:runId AndCase:tc];
            alreadyDoneNumber ++;
            doing = [NSString stringWithFormat:@"submitting %d/%d", alreadyDoneNumber, all];
            
            kerr = task_info(mach_task_self(),
                                           TASK_BASIC_INFO,
                                           (task_info_t)&info,
                                           &size);
            if( kerr == KERN_SUCCESS ) {
                mem = [NSString stringWithFormat:@"mem usage(MB):%0.3f, INC by:%0.2f", 
                       (float)info.resident_size/(1024*1024), 
                       (float)(info.resident_size-baseMem)*100/baseMem];
            }
            block([[[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%0.1f", (float)alreadyDoneNumber/all], 
                    doing, 
                    mem, 
                    nil] autorelease]);
        }    
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
    
    kerr = task_info(mach_task_self(),
                               TASK_BASIC_INFO,
                               (task_info_t)&info,
                               &size);
    if( kerr == KERN_SUCCESS ) {
        QALog(@"total memory usage(MB) : %0.3f, increased by : %0.2f", 
               (float)info.resident_size/(1024*1024), 
               (float)(info.resident_size-baseMem)*100/baseMem);
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

- (void) markCaseWrappers:(int) selectType{
    switch (selectType) {
        case 1:
            // select all
            for (int i=0; i<caseWrappers.count; i++) {
                [[caseWrappers objectAtIndex:i] setIsSelected:true];
            }
            break;
        case 2:
            // select failed
            for (int i=0; i<caseWrappers.count; i++) {
                TestCaseWrapper* tcw = [caseWrappers objectAtIndex:i];
                if ([[tcw result] isEqualToString:[Constant getReadableResult:CaseResultFailed]]) {
                    [[caseWrappers objectAtIndex:i] setIsSelected:true];
                }else {
                     [[caseWrappers objectAtIndex:i] setIsSelected:false];
                }
            }
            break;
        case 10:
            // unselect all
            for (int i=0; i<caseWrappers.count; i++) {
                [[caseWrappers objectAtIndex:i] setIsSelected:false];
            }
            break;
        default:
            break;
    }
    
}


- (void)dealloc{
    [runner release];
    [caseWrappers release];
    [cb release];
    [super dealloc];
}

@end
