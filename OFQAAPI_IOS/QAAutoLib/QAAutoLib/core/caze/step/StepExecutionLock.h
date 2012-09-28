//
//  StepExecutionLock.h
//  QAAutoLib
//
//  Created by zhu lei on 9/27/12.
//  Copyright (c) 2012 OFQA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StepExecutionLock : NSObject{
    @private
    NSConditionLock* inStepLock;
    int timeout;
    int switc;
}

@property int timeout;

+ (StepExecutionLock*) coreLock;

- (void) unlockCore:(NSString*) name;
- (void) lockCore:(NSString*) name;


@end
