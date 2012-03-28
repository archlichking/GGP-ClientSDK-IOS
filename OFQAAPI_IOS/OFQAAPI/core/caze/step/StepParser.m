//
//  StepParser.m
//  OFQAAPI
//
//  Created by lei zhu on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StepParser.h"
#import "StepHolder.h"
#import "StepMethod.h"
#import "Step.h"
#import "QALog.h"

@implementation StepParser

@synthesize holder;

- (id)initWithHolder:(StepHolder*) h{
    if (self=[super init])
    {
        [self setHolder:h];
    
    }
    return self;
}

/*
 input rawSteps: shoule be an step string array
 output : should be array of class Steps
 */
- (NSArray*) parseSteps:(NSArray*) rawSteps{
    NSMutableArray* resultArray = [[[NSMutableArray alloc] init] autorelease];
    for (int i=0; i<rawSteps.count; i++) {
        NSString* rawStep = [rawSteps objectAtIndex:i];
        // step 0: get method by rawStep
        StepMethod* mInvo = [holder getMethodByStep:rawStep];
        if(mInvo == nil){
            QALog(@"no defined for step [%@]", rawSteps);
            continue;
        }else{
            // step 1: get class obj from
            id p = [holder getClassObject];
            // step 2: build step
            Step* step = [[Step alloc] init];
            // 2.1 set step ref obj
            [step setRefObj:p];
            // 2.2 set step method invocation
            [step setRefMethodInvocation:[mInvo methodInvo]];
            // 2.3 set step params
            [step setRefMethodParams:[mInvo params]];
            // 2.4 set step command string
            [step setCommand:rawStep];
            // step 3: add step into resultArray
            [resultArray addObject:step];
            [step release];
        }
    }
   
    return resultArray;
}
//
//- (void)dealloc{
//    [holder release];
//    [super dealloc];
//}

@end
