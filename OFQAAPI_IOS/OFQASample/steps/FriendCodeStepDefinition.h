//
//  FriendCodeStepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StepDefinition.h"

@interface FriendCodeStepDefinition : StepDefinition

- (void) I_make_sure_my_friend_code_is_PARAM:(NSString*) isExist;

- (void) I_request_friend_code_with_expire_time_PARAM:(NSString*) time;

- (void) my_friend_code_length_should_be_PARAMINT:(NSString*) length;

- (void) my_friend_code_expire_time_should_be_PARAM:(NSString*) time; 

- (void) I_load_the_owner_of_friend_code_I_verified;

- (void) the_owner_should_be_user_PARAMINT:(NSString*) userid;

- (void) I_delete_my_friend_code;

- (void) I_verify_my_friend_code;

- (void) I_load_my_friend_code;

- (void) my_friend_code_should_be_deleted;

- (void) my_friend_code_should_be_valid;

- (void) I_load_friends_who_verifies_my_code;

- (NSString*) friend_code_verified_list_should_be_size_of_PARAMINT:(NSString*) size;

- (NSString*) friend_code_verified_list_should_have_PARAM:(NSString*) person;

@end
