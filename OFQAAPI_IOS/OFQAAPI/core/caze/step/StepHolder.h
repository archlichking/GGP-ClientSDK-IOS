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
    NSMutableDictionary* stepCage;
}

@property (retain) NSMutableDictionary* stepCage;

+ (StepHolder*) instance:(id) c;

- (id) initWithStepObj:(id) c;

- (id) getClassObject;
- (StepMethod*) getMethodByStep:(NSString*) stepString;


@end
