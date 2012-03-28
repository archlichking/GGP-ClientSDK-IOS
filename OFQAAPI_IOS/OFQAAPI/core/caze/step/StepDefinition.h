//
//  StepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StepDefinition : NSObject{
    @protected
    __block int blockSentinal;
    __block id blockExpected;
    __block id blockActual;
}

@property int blockSentinal;
@property (retain) id blockActual;
@property (retain) id blockExpected;


+ (int) WAITING;
+ (int) FAILED;
+ (int) PASSED;

- (void) assertWithBlockSentinal:(void(^)(id expected, id result))block;

@end
