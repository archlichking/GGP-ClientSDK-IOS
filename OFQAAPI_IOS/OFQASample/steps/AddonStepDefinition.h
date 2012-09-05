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

@end
