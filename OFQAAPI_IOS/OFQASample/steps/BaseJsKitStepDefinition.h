//
//  JsKitStepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 8/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StepDefinition.h"

@interface BaseJsKitStepDefinition : StepDefinition

- (void) I_launch_jskit_popup;
- (void) I_dismiss_jskit_popup;

- (void) step_sleep:(NSTimeInterval) interval;

- (void) invoke_in_jskit_popup_with_full_command:(NSString*) command;
- (void) invoke_in_jskit_popup_with_element:(NSString*) element 
                               _and_command:(NSString*) command 
                                 _and_value:(NSString*) value;

@end
