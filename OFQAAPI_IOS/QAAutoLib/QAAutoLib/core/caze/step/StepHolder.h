//
//  StepHolder.h
//  OFQAAPI
//
//  Created by lei zhu on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class StepMethod;

@interface StepHolder : NSObject{
    @private
    /*
     unique ->
     key: "class"
     value: class object
     set ->
     key: string step command (regexp to be)
     value: NSInvocation object
     */
    NSMutableArray* stepCages;
}

@property (retain) NSMutableArray* stepCages;

+ (StepHolder*) instance:(id) c;

- (id) addStepObj:(id) c;

- (StepMethod*) getMethodByStep:(NSString*) stepString;


@end
