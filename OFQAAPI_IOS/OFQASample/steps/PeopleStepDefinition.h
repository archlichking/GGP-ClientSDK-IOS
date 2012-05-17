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

- (void) my_info_PARAM:(NSString*) key _should_be_PARAM:(NSString*) value;

- (void) I_check_my_friend_list;

- (void) I_check_my_friend_list_first_page;

- (void) friend_list_should_be_size_of_PARAMINT:(NSString*) size;

- (void) friend_list_should_have_PARAM:(NSString*) person;

- (void) friend_list_should_not_have_PARAM:(NSString*) person;

- (void) userid_of_PARAM:(NSString*) person
        _should_be_PARAM:(NSString*) userid _and_grade_should_be_PARAMINT:(NSString*) grade;

@end
