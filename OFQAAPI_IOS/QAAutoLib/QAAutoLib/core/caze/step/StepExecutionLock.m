//
//  StepExecutionLock.m
//  QAAutoLib
//
//  Created by zhu lei on 9/27/12.
//  Copyright (c) 2012 OFQA. All rights reserved.
//

#import "StepExecutionLock.h"

const int InStepType = 1;
const int GlobalType = 100;


static StepExecutionLock* cCoreLock = nil;

@implementation StepExecutionLock

@synthesize timeout;

- (id) initWithStepLock{
    if (self) {
        inStepLock = [[NSConditionLock alloc] initWithCondition:0];
        globalLock = [[NSConditionLock alloc] initWithCondition:0];
        timeout = 10;
        switc = -1;
    }
    return self;
}

+ (StepExecutionLock*) coreLock{
    if (!cCoreLock) {
        cCoreLock = [[StepExecutionLock alloc] initWithStepLock];
    }
    return cCoreLock;
}

- (void) unlockCore:(NSString*) name
               Type:(int) type{
    switc = type;
    switch (type) {
        case InStepType:
            [inStepLock setName:name];
//            NSLog(@"begin unlockCore %@, %i", inStepLock, switc);
            [inStepLock lockWhenCondition:1
                               beforeDate:[NSDate dateWithTimeIntervalSinceNow:timeout]];
            [inStepLock unlockWithCondition:0];
//            NSLog(@"end unlockCore %@", inStepLock);
            break;
        case GlobalType:
            [globalLock setName:name];
//            NSLog(@"begin unlockCore %@, %i", globalLock, switc);
            [globalLock lockWhenCondition:1
                               beforeDate:[NSDate dateWithTimeIntervalSinceNow:timeout]];
            [globalLock unlockWithCondition:0];
//            NSLog(@"end unlockCore %@", globalLock);
            break;
        default:
            break;
    }    
}

- (void) lockCore:(NSString*) name
             Type:(int) type{
    @synchronized(self){
        int swap = switc;
        switc -= 1;
        if (switc == InStepType - 1 || switc == GlobalType - 1) {
            // to avoid some unncessary unlock outside
            switch (type) {
                case InStepType:
                    [inStepLock setName:name];
//                    NSLog(@"beign lockCore %@, %i", inStepLock, switc);
                    [inStepLock lock];
                    [inStepLock unlockWithCondition:1];
//                    NSLog(@"end lockCore %@", inStepLock);
                    break;
                    
                case GlobalType:
                    [globalLock setName:name];
//                    NSLog(@"beign lockCore %@, %i", globalLock, switc);
                    [globalLock lock];
                    [globalLock unlockWithCondition:1];
//                    NSLog(@"end lockCore %@", globalLock);
                    break;
                default:
                    break;
            }
        }else{
            // reset the switc
            switc = swap;
        }
    }
}

@end
