//
//  GreePlatformStepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StepDefinition.h"

@interface GreePlatformStepDefinition : StepDefinition

- (void) I_check_basic_platform_info;

- (NSString*) platform_info_should_be_correct_to_user_with_email_PARAM:(NSString*) EMAIL 
                                                   _and_password_PARAM:(NSString*) PWD;

- (void) my_sdk_build_should_be_PARAM:(NSString*) build;
- (void) my_sdk_version_should_be_PARAM:(NSString*) version;


- (void) I_rotate_screen;

- (void) I_sign_request_to_url_PARAM:(NSString*) url 
     _with_url_params_with_key_PARAM:(NSString*) key 
                    _and_value_PARAM:(NSString*) value;

- (void) I_sign_request_to_url_PARAM:(NSString*) url 
     _with_extra_params_with_key_PARAM:(NSString*) key 
                    _and_value_PARAM:(NSString*) value;

- (void) signed_request_query_params_with_key_PARAM:(NSString*) key
                                   _should_be_PARAM:(NSString*) value;

@end
