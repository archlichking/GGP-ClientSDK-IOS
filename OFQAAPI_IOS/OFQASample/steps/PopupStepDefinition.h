//
//  PopupStepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StepDefinition.h"

extern NSString* const JsBaseCommand;

@interface PopupStepDefinition : StepDefinition

// request popup
- (void) I_initialize_request_popup_with_title_PARAM:(NSString*) title 
                                          _and_body_PARAM:(NSString*) body;
- (void) I_check_request_popup_setting_info_PARAM:(NSString*) info;
- (NSString*) request_popup_info_PARAM:(NSString*) info 
                      _should_be_PARAM:(NSString*) value;

//

// common popup 
- (void) I_will_open_popup;
- (void) I_did_open_popup;
- (void) I_will_dismiss_popup;
- (void) I_did_dismiss_popup;
- (void) I_execute_js_command_in_popup_PARAM:(NSString*) command;


- (void) popup_will_open_callback_should_be_fired_within_seconds_PARAMINT:(NSString*) seconds;
- (void) popup_did_open_callback_should_be_fired_within_seconds_PARAMINT:(NSString*) seconds;
- (void) popup_will_dismiss_callback_should_be_fired_within_seconds_PARAMINT:(NSString*) second;
- (void) popup_did_dismiss_callback_should_be_fired_within_seconds_PARAMINT:(NSString*) seconds;
- (void) popup_complete_callback_should_be_fired_within_seconds_PARAMINT:(NSString*) seconds;



@end
