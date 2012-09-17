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
static NSMutableDictionary* outsideBlockRepo;
static NSConditionLock* outsideStepLock; // this is now only allowed in popup steps
static int OUTSIDETIMEOUT = 10;

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
    @try {
        [inStepLock lockWhenCondition:1
                           beforeDate:[NSDate dateWithTimeIntervalSinceNow:TIMEOUT]];
        [inStepLock unlock];
    }
    @catch (NSException *exception) {
        NSLog(@"=======> exception in inside step unlock %@", exception);
    }
    @catch (NSError *error) {
        NSLog(@"=======> error in inside step unlock %@", error);
    }
    @finally {
        [inStepLock release];
        inStepLock = [[NSConditionLock alloc] initWithCondition:0];
        TIMEOUT = 0;
    }
    
    // reset timeout and condition
    
    
}

- (void) notifyInStep{
    if (!inStepLock) {
        inStepLock = [[NSConditionLock alloc] initWithCondition:0];
    }
    @synchronized (self) {
        [inStepLock lock];
        [inStepLock unlockWithCondition:1];
    }
    
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

+ (NSMutableDictionary*) getOutsideBlockRepo{
    if (!outsideBlockRepo) {
        outsideBlockRepo = [[NSMutableDictionary alloc] init];
    }
    return outsideBlockRepo;
}

+ (void) notifyOutsideStep{
    if (!outsideStepLock) {
        outsideStepLock = [[NSConditionLock alloc] initWithCondition:0];
    }
    @synchronized ([self class]){
        [outsideStepLock lock];
        [outsideStepLock unlockWithCondition:1];
    }
}

+ (void) waitForOutsideStep{
    if (!outsideStepLock) {
        outsideStepLock = [[NSConditionLock alloc] initWithCondition:0];
    }
    @try{
        [outsideStepLock lockWhenCondition:1 
                       beforeDate:[NSDate dateWithTimeIntervalSinceNow:OUTSIDETIMEOUT]];
        [outsideStepLock unlock];
    }
    @catch (NSException* exception) {
        NSLog(@"=======> exception in outside step unlock %@", exception);
    }
    @catch (NSError *error) {
        NSLog(@"=======> error in inside step unlock %@", error);
    }
    @finally {
        // reset timeout and condition
        [outsideStepLock release];
        outsideStepLock = [[NSConditionLock alloc] initWithCondition:0];
    }
    
    
}


@end
