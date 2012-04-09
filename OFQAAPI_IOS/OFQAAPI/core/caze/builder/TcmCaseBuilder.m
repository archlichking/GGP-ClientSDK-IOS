//
//  TcmCaseBuilder.m
//  OFQAAPI
//
//  Created by lei zhu on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TcmCaseBuilder.h"
#import "TcmCommunicator.h"
#import "SBJson.h"
#import "StringUtil.h"
#import "StepParser.h"
#import "QALog.h"
#import "Constant.h"

#import "NoSuchStepException.h"

@implementation TcmCaseBuilder

@synthesize tcmComm;
@synthesize jsonParser;
@synthesize stepParser;

- (id)initWithRawValue:(NSData*)rawCaze
                holder:(StepHolder*) holder{
    if (self = [super init]) {
        StepParser* sp = [[StepParser alloc] initWithHolder:holder];
        [self setStepParser:sp];
        // rawCase should be NSData* containing settings.json content
        SBJsonParser* sb = [[SBJsonParser alloc] init];
        [self setJsonParser: sb];
        NSDictionary* tempSettings = [jsonParser objectWithData:rawCaze];
        
        TcmCommunicator* tm = [[TcmCommunicator alloc] initWithKey:[tempSettings valueForKey:@"tcmKey"]
                                                          submitUrl:[tempSettings valueForKey:@"tcmSubmitUrl"] 
                                                       retrievalUrl:[tempSettings valueForKey:@"tcmRetrievalUrl"]];
        
        [self setTcmComm:tm];
        
        [sb release];
        [sp release];
        [tm release];
    }
    return self;
}

- (TestCase*) buildCaseBySuiteId:(NSString*) suiteId caseId:(NSString*) caseId{
    return nil;
}

- (NSArray*) buildCasesBySuiteId:(NSString*) suiteId{
    NSMutableArray* resultCases = [[[NSMutableArray alloc] init] autorelease];
    
    NSData* rawResult = [tcmComm requestCasesBySuiteId:suiteId];
    // get rid of first line of return data
    
    
    NSString *rawJsonString = [[[[NSString alloc] initWithData:rawResult 
                                                     encoding:NSUTF8StringEncoding] autorelease] substringFromIndex:1];
    
    NSDictionary* caseJsonString = [jsonParser objectWithString:rawJsonString];
    


    // get cases string as array from result json
    
    NSArray* rawCases =[caseJsonString valueForKey:@"cases"];
    
    
    for (int i=0; i<rawCases.count; i++) {
        NSDictionary* rawCase = [rawCases objectAtIndex:i];
        
        NSArray* rawStepsJson = [StringUtil splitStepsFrom:[rawCase valueForKey:@"custom_steps"] 
                                                    by:[StringUtil TCM_LINE_SPLITER]];
        
        // clean raw steps within filters "when", "then", "given"
        NSArray* rawSteps = [StringUtil extractStepsFrom:rawStepsJson];
        NSString* tid= [[rawCase valueForKey:@"id"] stringValue];
        TestCase* tc = [[TestCase alloc] initWithId:tid 
                                              title: [rawCase valueForKey:@"title"]];
        @try {
            NSArray* solidSteps = [stepParser parseSteps:rawSteps];
            // build test case object
            [tc setSteps:solidSteps];
            
        }
        @catch (NoSuchStepException *exception) {
            // no step found in
            QALog(@"no full steps defined for case [%@]", [rawCase valueForKey:@"title"]);
            [tc setIsExecuted:true];
            [tc setResult:[Constant FAILED]];
            [tc setResultComment:@"probably one or two step is not defined"];
            continue;
        }
        @finally {
            [resultCases addObject:tc];
            [tc release];
        }
    }
    
    
    
    return resultCases;
}

//- (void)dealloc{
//    [tcmComm release];
//    [jsonParser release];
//    [stepParser release];
//    [super dealloc];
//}

@end
