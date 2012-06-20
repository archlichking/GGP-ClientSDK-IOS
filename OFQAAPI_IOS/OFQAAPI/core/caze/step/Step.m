//
//  Step.m
//  OFQAAPI
//
//  Created by lei zhu on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Step.h"
#import "Constant.h"
#import "StepResult.h"
#import "AssertException.h"
#import "QALog.h"

@implementation Step

@synthesize command;
@synthesize refObj;
@synthesize refMethodInvocation;
@synthesize refMethodParams;

- (id)init{
    if (self=[super init]){
        [self setCommand:nil];
        [self setRefObj:nil];
        [self setRefMethodParams:nil];
        [self setRefMethodInvocation:nil];
        
        // add notification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(notify:)
                                                     name:@"notify" 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(wait:)
                                                     name:@"wait" 
                                                   object:nil];
        
    }
    return self;
}

- (StepResult*) invoke{
    // set wait mark for notification
    int result = CaseResultFailed;
    NSString* resultComment = @"";
    @try {
        // step 0: set target
        [[self refMethodInvocation] setTarget:[[self refObj] retain]];
        // step 1: set params
        for (int i=0; i<[self refMethodParams].count; i++) {
            NSString* param = [[self refMethodParams] objectAtIndex:i];
            [[self refMethodInvocation] setArgument:&param
                                            atIndex:i+2];
        }
        // step 2: set mInvocation
        [[self refMethodInvocation] retainArguments];
        // step 3: invoke 
        QALog(@"invoking [%@]", [self command]);
        [[self refMethodInvocation] invoke];
        // step 4: set result
        NSString* returnType = [NSString stringWithCString:[[[self refMethodInvocation] methodSignature] methodReturnType] 
                                                  encoding:NSUTF8StringEncoding];
        if (![returnType isEqualToString:@"v"]) {
            // has return value
            [[self refMethodInvocation] getReturnValue:&resultComment];
        }
        result = CaseResultPassed;
    }
    @catch (AssertException *exception) {
        resultComment = [resultComment stringByAppendingFormat:@"%@ ==> %@", [self command], [exception reason]];
        QALog(@"oooooops, [%@]", resultComment);
    }
    @catch (NSException* exception) {
        resultComment = [resultComment stringByAppendingFormat:@"%@ ==> %@", [self command], [exception reason]];
        QALog(@"oooooops, [%@]", resultComment);
    }
    @finally {
        return [[StepResult alloc] initWithResult:result 
                                          comment:resultComment];
    }
    
    
}

- (void)dealloc{
    [command release];
    [refObj release];
    [refMethodParams release];
    [refMethodInvocation release];
    [super dealloc];
}

@end
