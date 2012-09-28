//
//  StepExecutionLock.h
//  QAAutoLib
//
//  Created by zhu lei on 9/27/12.
//  Copyright (c) 2012 OFQA. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const int InStepType;
extern const int GlobalType;

@interface StepExecutionLock : NSObject{
    @private
    NSConditionLock* inStepLock;
    NSConditionLock* globalLock;
    int timeout;
    int switc;
}

@property int timeout;

+ (StepExecutionLock*) coreLock;

- (void) unlockCore:(NSString*) name
               Type:(int) type;
- (void) lockCore:(NSString*) name
             Type:(int) type;


@end
