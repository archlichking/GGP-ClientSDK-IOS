//
//  StepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StepDefinition.h"
#import "QAAssert.h"
#import "QALog.h"
#import "AssertException.h"
#import "Constant.h"

@implementation StepDefinition

- (NSMutableDictionary*) getBlockRepo{
    if (!blockRepo) {
        blockRepo = [[NSMutableDictionary alloc] init];
    }
    return blockRepo;
}


- (void) waitForInStep{
    if (!inStepLock) {
        inStepLock = [[NSConditionLock alloc] initWithCondition:0];
    }
    if(!TIMEOUT || TIMEOUT == 0){
        TIMEOUT = 5;
    }
    [inStepLock lockWhenCondition:1 
                       beforeDate:[NSDate dateWithTimeIntervalSinceNow:TIMEOUT]];
    [inStepLock unlock];
    // reset timeout and condition
    [inStepLock release];
    inStepLock = [[NSConditionLock alloc] initWithCondition:0];
    TIMEOUT = 0;
    
}

- (void) notifyInStep{
    [inStepLock lock];
    [inStepLock unlockWithCondition:1];
    
}

-(void) setTimeout:(int) timeout{
    TIMEOUT = timeout;
}

- (void) notifyMainUIWithCommand:(NSString*) command 
                          object:(id) obj{
    [[NSNotificationCenter defaultCenter] postNotificationName:command 
                                                        object:nil
                                                      userInfo:obj];
}

@end
