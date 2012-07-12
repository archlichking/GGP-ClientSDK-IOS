//
//  PeopleStepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StepDefinition.h"

@interface PeopleStepDefinition : StepDefinition

- (void) I_see_my_info_from_server;

- (void) I_see_my_info_from_native_cache;

- (NSString*) my_info_PARAM:(NSString*) key _should_be_PARAM:(NSString*) value;

- (void) I_load_my_friend_list;

- (void) I_load_friend_list_of_user_PARAM:(NSString*) guid;

- (void) I_load_first_page_of_my_friend_list;

- (void) I_set_friend_enumerator_size_to_PARAMINT:(NSString*) size;

- (void) I_load_one_page_of_friend_list;

- (NSString*) friend_list_should_be_size_of_PARAMINT:(NSString*) size;

- (NSString*) friend_list_should_have_PARAM:(NSString*) person;

- (NSString*) friend_list_should_not_have_PARAM:(NSString*) person;

- (NSString*) userid_of_PARAM:(NSString*) person
        _should_be_PARAM:(NSString*) userid _and_grade_should_be_PARAMINT:(NSString*) grade;

- (void) I_load_my_image_with_size_PARAM:(NSString*) size;

- (void) I_cancel_load_my_image_with_size_PARAM:(NSString*) size;

- (NSString*) my_image_should_be_null;

- (NSString*) my_image_should_be_in_height_PARAMINT:(NSString*) height 
                                _and_width_PARAMINT:(NSString*) width;

@end
