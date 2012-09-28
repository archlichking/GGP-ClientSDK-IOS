//
//  StepExecutionLock.m
//  QAAutoLib
//
//  Created by zhu lei on 9/27/12.
//  Copyright (c) 2012 OFQA. All rights reserved.
//

#import "StepExecutionLock.h"

static StepExecutionLock* cCoreLock = nil;

@implementation StepExecutionLock

@synthesize timeout;

- (id) initWithStepLock{
    if (self) {
        inStepLock = [[NSConditionLock alloc] initWithCondition:0];
        timeout = 10;
        switc = 0;
    }
    return self;
}

+ (StepExecutionLock*) coreLock{
    if (!cCoreLock) {
        cCoreLock = [[StepExecutionLock alloc] initWithStepLock];
    }
    return cCoreLock;
}

- (void) unlockCore:(NSString*) name{
    [inStepLock setName:name];
    switc = 1;
//    NSLog(@"begin unlockCore %@, %i", inStepLock, switc);
    [inStepLock lockWhenCondition:1
                       beforeDate:[NSDate dateWithTimeIntervalSinceNow:timeout]];
    [inStepLock unlockWithCondition:0];
//    NSLog(@"end unlockCore %@", inStepLock);
    
}

- (void) lockCore:(NSString*) name{
    @synchronized(self){
        switc -= 1;
        if (switc == 0) {
            // to avoid some unncessary unlock outside
            [inStepLock setName:name];
//            NSLog(@"beign lockCore %@, %i", inStepLock, switc);
            [inStepLock lock];
            [inStepLock unlockWithCondition:1];
//            NSLog(@"end lockCore %@", inStepLock);
        }else{
            // reset the switc
            switc = 0;
        }
    }
}

@end
