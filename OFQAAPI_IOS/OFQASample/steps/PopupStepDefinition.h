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

- (void) I_will_open_request_popup;
- (void) I_did_open_request_popup;
- (void) I_will_dismiss_request_popup;
- (void) I_did_dismiss_request_popup;
- (void) I_execute_command_in_request_popup_PARAM:(NSString*) command;

- (void) I_check_request_popup_setting_info;

- (void) popup_will_open_callback_should_be_fired_within_seconds_PARAMINT:(NSString*) seconds;
- (void) popup_did_open_callback_should_be_fired_within_seconds_PARAMINT:(NSString*) seconds;
- (void) popup_will_dismiss_callback_should_be_fired_within_seconds_PARAMINT:(NSString*) second;
- (void) popup_did_dismiss_callback_should_be_fired_within_seconds_PARAMINT:(NSString*) seconds;
- (void) complete_callback_should_work_fine;




- (NSString*) request_popup_info_should_be_correct;

@end
