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
        [self setResult:[Constant PASSED]];
        [self setResultComment:@""];
        [self setIsExecuted:false];
    }
    return self;
}

- (void) execute{
    QALog(@"launching case with [id: %@, title: %@]", [self caseId], [self title]);
    if(steps.count == 0){
        //no steps
        [self setResult:[Constant RETESTED]];
        [self setResultComment: @"No Step Found for this case, maybe a parse error, need retested"];
        QALog(@"No Step Found for this case, maybe a parse error, need retested");
    }else{
        for (int i=0;i<[self steps].count;i++) {
            Step* s = [[self steps] objectAtIndex:i];
            StepResult* r = [s invoke];
            // merge results with or operation
            result = result | [r result];
            if (![[r comment] isEqualToString:@""]) {
                // step invocation error occurs
                [self setResultComment:[resultComment stringByAppendingFormat:@"%@ %@", [r comment], [StringUtil FILE_LINE_SPLITER]]];
            }
        }
    }
    [self setResultComment:resultComment];
    [self setIsExecuted:true];
    QALog(@"=======================");
}

//- (void)dealloc{
//    [caseId release];
//    [title release];
//    [steps release];
//    [resultComment release];
//    [super dealloc];
//}

@end
