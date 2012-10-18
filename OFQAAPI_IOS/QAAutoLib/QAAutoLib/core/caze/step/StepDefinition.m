//
//  StepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StepDefinition.h"

#import "StepExecutionLock.h"
#import "QAAssert.h"
#import "QALog.h"
#import "AssertException.h"
#import "Constant.h"

@implementation StepDefinition
static NSMutableDictionary* outsideBlockRepo;

- (NSMutableDictionary*) getBlockRepo{
    if (!blockRepo) {
        blockRepo = [[NSMutableDictionary alloc] init];
    }
    return blockRepo;
}



- (void) inStepWait{
    [[StepExecutionLock coreLock] unlockCore:[NSString stringWithFormat:@"in step notify %@", [self description]]
                                        Type:InStepType];
}

- (void) inStepNotify{
    [[StepExecutionLock coreLock] lockCore:[NSString stringWithFormat:@"in step notify %@", [self description]]
                                      Type:InStepType];
}

-(void) setTimeout:(int) timeout{
    [[StepExecutionLock coreLock] setTimeout:timeout];
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

+ (void) globalNotify{
//    if (!outsideStepLock) {
//        outsideStepLock = [[NSConditionLock alloc] initWithCondition:0];
//    }
//    @synchronized ([self class]){
//        [outsideStepLock lock];
//        [outsideStepLock unlockWithCondition:1];
//    }
    [[StepExecutionLock coreLock] lockCore:[NSString stringWithFormat:@"global notify %@", [self description]]
                                      Type:GlobalType];

}

+ (void) globalWait{
//    if (!outsideStepLock) {
//        outsideStepLock = [[NSConditionLock alloc] initWithCondition:0];
//    }
//    @try{
//        [outsideStepLock lockWhenCondition:1 
//                       beforeDate:[NSDate dateWithTimeIntervalSinceNow:OUTSIDETIMEOUT]];
//        [outsideStepLock unlock];
//    }
//    @catch (NSException* exception) {
//        QALog(@"[WAIT ERROR] outside step unlock %@", exception);
//    }
//    @catch (NSError *error) {
//        QALog(@"[WAIT ERROR] inside step unlock %@", error);
//    }
//    @finally {
//        // reset timeout and condition
//        [outsideStepLock release];
//        outsideStepLock = [[NSConditionLock alloc] initWithCondition:0];
//    }
    [[StepExecutionLock coreLock] unlockCore:[NSString stringWithFormat:@"global wait %@", [self description]]
                                        Type:GlobalType];
}
@end
