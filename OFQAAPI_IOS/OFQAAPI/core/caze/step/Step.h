//
//  Step.h
//  OFQAAPI
//
//  Created by lei zhu on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class StepResult;

@interface Step : NSObject{
    @private
    NSString* command;
    id refObj;
    NSInvocation* refMethodInvocation;
    NSArray* refMethodParams;
    BOOL w;
}

@property (copy) NSString* command;
@property (retain) id refObj;
@property (retain) NSInvocation* refMethodInvocation;
@property (retain) NSArray* refMethodParams;

- (StepResult*) invoke;

@end
