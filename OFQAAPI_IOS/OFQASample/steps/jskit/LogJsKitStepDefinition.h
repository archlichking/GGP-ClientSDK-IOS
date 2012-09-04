//
//  LogJsKitStepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseJsKitStepDefinition.h"


@interface LogJsKitStepDefinition : BaseJsKitStepDefinition

- (void) I_launch_jskit_popup;
- (void) I_dismiss_jskit_base_popup;
- (void) I_dismiss_last_opened_popup;
- (void) I_dismiss_last_opened_viewControl;

- (void) I_click_invoke_button_PARAM:(NSString*) type;
- (void) I_need_to_wait_for_test_done_PARAM:(NSString*) type;





// start/ stop log
- (void) I_set_jskit_log_level_to_PARAM:(NSString*) level;
- (void) I_stop_jskit_log_level_with_PARAM:(NSString*) level;

- (NSString*) jskit_log_level_should_be_PARAM:(NSString*) level;

// set/get config
- (void) I_set_jskit_config_with_key_PARAM:(NSString*) jsKey 
                          _and_value_PARAM:(NSString*) jsValue;
- (void) I_get_jskit_config_value_with_key_PARAM:(NSString*) jsKey;

- (void) jskit_config_with_key_PARAM:(NSString*) jsKey 
                    _should_be_PARAM:(NSString*) jsValue;

@end
