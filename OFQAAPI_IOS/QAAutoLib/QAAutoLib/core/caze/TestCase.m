//
//  TestCase.m
//  OFQAAPI
//
//  Created by lei zhu on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestCase.h"
#import "Step.h"
#import "StringUtil.h"
#import "StepResult.h"
#import "Constant.h"
#import "QALog.h"

@implementation TestCase

@synthesize caseId;
@synthesize title;
@synthesize steps;
@synthesize result;
@synthesize resultComment;
@synthesize isExecuted;

- (id)initWithId:(NSString*) cId 
           title:(NSString*) cTitle 
           steps:(NSArray*) cSteps{
    if (self = [super init]) {
        [self setCaseId:cId];
        [self setTitle:cTitle];
        [self setSteps:cSteps];
        [self setResult:CaseResultPassed];
        [self setResultComment:@""];
        [self setIsExecuted:false];
    }
    return self;
}

- (id)initWithId:(NSString*) cId 
           title:(NSString*) cTitle{
    if (self = [super init]) {
        [self setCaseId:cId];
        [self setTitle:cTitle];
        [self setResult:CaseResultPassed];
        [self setResultComment:@""];
        [self setIsExecuted:false];
    }
    return self;
}

- (void) execute{
    self.result = CaseResultPassed;
    QALog(@"============= launching case of [id: %@, title: %@] =============", [self caseId], [self title]);
    if ([[[self title] lowercaseString] rangeOfString:@"android only"].length > 0) {
        // case that doesnt support IOS SDK
        self.result = CaseResultBlocked;
        [self setResultComment: @"Not an IOS SDK case, skipped"];
    }else if(steps.count == 0){
        //current platform but without steps
        [self setResult:CaseResultRetested];
        [self setResultComment: @"No Step Found for this case, maybe a parse error, need retested"];
        QALog(@"No Step Found for this case, maybe a parse error, need retested");
    }else{
        //finally can be executed
        for (int i=0;i<[self steps].count;i++) {
            Step* s = [[self steps] objectAtIndex:i];
            StepResult* r = [s invoke];
            // merge results with or operation
            self.result = self.result | [r result];
            if (![[r comment] isEqualToString:@""]) {
                // step invocation error occurs
                [self setResultComment:[resultComment stringByAppendingFormat:@"%@ %@", [r comment], SpliterFileLine]];
            }
        }
        
        // needs to invoke specific step to release things
        
    }
    
    [self setResultComment:resultComment];
    [self setIsExecuted:true];
}

- (void)dealloc{
    [caseId release];
    [title release];
    [steps release];
    [resultComment release];
    [super dealloc];
}

@end
