//
//  LogJsKitStepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JsKitStepDefinition.h"


@interface LogJsKitStepDefinition : JsKitStepDefinition

- (void) I_launch_jskit_popup;
- (void) I_dismiss_jskit_popup;

- (void) I_set_jskit_log_level_to_PARAM:(NSString*) level;



- (NSString*) jskit_log_level_should_be_PARAM:(NSString*) level;

@end
