//
//  AddonStepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 9/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StepDefinition.h"

@interface AddonStepDefinition : StepDefinition

// string addon
- (void) I_get_hex_string_from_binary_string_PARAM:(NSString*) str;
- (void) hex_string_should_not_be_nil;

- (void) I_get_normalized_string_length_of_string_PARAM:(NSString*) str;
- (void) string_length_should_be_PARAMINT:(NSString*) length;

- (void) I_remove_html_tag_with_string_PARAM:(NSString*) str;
- (void) string_result_should_be_PARAM:(NSString*) str; 

- (void) I_replace_localized_string_PARAM:(NSString*) str 
                          _with_key_PARAM:(NSString*) key 
                         _and_value_PARAM:(NSString*) value;

- (void) I_decode_html_element_entries_with_string_PARAM:(NSString*) str;


// object addon
- (void) I_execute_block_in_NSObject;
- (void) block_should_be_executed;

// image addon
- (void) I_resize_image_with_name_PARAM:(NSString*) n 
                       _to_height_PARAM:(NSString*) h 
                       _and_width_PARAM:(NSString*) w
              _with_rotation_mark_PARAM:(NSString*) r;

- (void) image_should_be_of_height_PARAM:(NSString*) h 
                        _and_width_PARAM:(NSString*) w;

- (void) I_get_base64_string_of_image_PARAM:(NSString*) n;
- (void) base64_string_should_not_be_nil;

- (void) I_get_app_icon_close_to_width_PARAM:(NSString*) w;
- (void) app_icon_width_should_be_PARAM:(NSString*) w;

@end
