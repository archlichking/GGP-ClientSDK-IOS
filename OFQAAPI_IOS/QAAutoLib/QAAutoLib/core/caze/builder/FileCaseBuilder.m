//
//  FileCaseBuilder.m
//  OFQAAPI
//
//  Created by lei zhu on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FileCaseBuilder.h"
#import "StringUtil.h"
#import "CommandUtil.h"
#import "StepParser.h"
#import "TestCase.h"
#import "NoSuchStepException.h"
#import "NoCommandMatchException.h"
#import "Constant.h"
#import "QALog.h"

@implementation FileCaseBuilder

@synthesize caseRaw;
@synthesize stepParser;


/*
 case should be a string like
 
 Scenario: first test
 Given I was young
 When I played glass ball
 When I won
 Then I need to tell my mom
 */
- (id)initWithRawValue:(NSData*)rawCaze  
                holder:(StepHolder*) holder{
    if (self = [super init]) {
        StepParser* sp = [[StepParser alloc] initWithHolder:holder];
        [self setStepParser: sp];
        NSString* raw = [[NSString alloc] initWithData:rawCaze 
                                              encoding:NSUTF8StringEncoding];
        [self setCaseRaw:raw];
        [sp release];
        [raw release];
    }
    return self;
}

- (TestCase*) buildCaseBySuiteId:(NSString*) suiteId 
                          caseId:(NSString*) caseId{
    return [self buildFromDebugFile];
}

- (TestCase*) buildFromDebugFile{
    NSArray* rawCase = [StringUtil splitStepsFrom:[self caseRaw] 
                                               by:SpliterFileLine];
    
        // transfer String[] to Step[]
    
    
    TestCase* tc = [[TestCase alloc] initWithId:@"1"
                                           title:@"debug case from debugCase.txt"];
    
    @try {
        NSArray* rawSteps = [StringUtil extractStepsFrom:rawCase];

        NSArray* solidSteps = [stepParser parseSteps:rawSteps];
        // build test case object
        [tc setSteps:solidSteps];
        
    }
    @catch (NoCommandMatchException* exception) {
        QALog(@"one step doesnt begin with keyword for case [%@]", [rawCase valueForKey:@"title"]);
        [tc setIsExecuted:true];
        [tc setResult:CaseResultFailed];
        [tc setResultComment:@"probably one or two step is not started with keywords"];
    }
    @catch (NoSuchStepException *exception) {
        // no step found in
        QALog(@"no full steps defined for case [%@]", [rawCase valueForKey:@"title"]);
        [tc setIsExecuted:true];
        [tc setResult:CaseResultFailed];
        [tc setResultComment:@"probably one or two step is not defined"];
    }
    
    return tc;
}

- (NSArray*) buildCasesBySuiteId:(NSString*) suiteId{
    TestCase* tc = [self buildFromDebugFile];
    NSArray* suite = [[[NSArray alloc] initWithObjects:tc, nil] autorelease];
    return suite;
}

//- (void)dealloc{
//    [caseRaw release];
//    [stepParser release];
//    [super dealloc];
//}

@end

