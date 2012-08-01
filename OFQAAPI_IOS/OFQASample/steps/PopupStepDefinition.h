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

// invite popup
- (void) I_initialize_invite_popup_with_message_PARAM:(NSString*) msg 
                              _and_callback_url_PARAM:(NSString*) cbUrl
                                     _and_users_PARAM:(NSString*) userids;
- (void) I_check_invite_popup_setting_info_PARAM:(NSString*) info;
- (NSString*) invite_popup_info_PARAM:(NSString*) info 
                      _should_be_PARAM:(NSString*) value;

// share popup
- (void) I_initialize_share_popup_with_text_PARAM:(NSString*) text;
- (void) I_check_share_popup_setting_info_PARAM:(NSString*) info;
- (NSString*) share_popup_info_PARAM:(NSString*) info 
                     _should_be_PARAM:(NSString*) value;

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

// payment popup
- (void) I_add_payment_item_with_ID_PARAM:(NSString*) pid 
                          _and_NAME_PARAM:(NSString*) name 
                     _and_UNITPRICE_PARAM:(NSString*) price 
                      _and_QUANTITY_PARAM:(NSString*) quality 
                      _and_IMAGEURL_PARAM:(NSString*) imageurl 
                   _and_DESCRIPTION_PARAM:(NSString*) description;

- (void) I_did_open_payment_request_popup;
- (void) I_check_payment_request_popup_info_PARAM:(NSString*) info;
- (NSString*) payment_request_popup_info_PARAM:(NSString*) info
                         _should_be_PARAM:(NSString*) value;

// deposit popup
- (void) I_did_open_deposit_popup;
- (void) I_check_deposit_popup_info_PARAM:(NSString*) info;
- (NSString*) deposit_popup_info_PARAM:(NSString*) info
                      _should_be_PARAM:(NSString*) value;

// deposit IAP history popup
- (void) I_did_open_deposit_history_popup;
- (void) I_check_deposit_history_popup_info_PARAM:(NSString*) info;
- (NSString*) deposit_history_popup_info_PARAM:(NSString*) info
                              _should_be_PARAM:(NSString*) value;


// -----------------
- (void) I_test_jskit;

- (void) I_load_popup;
@end
