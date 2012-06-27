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

- (void) I_update_badge_value_to_latest_one;

- (void) my_social_badge_value_should_be_PARAMINT:(NSString*) amount;

- (void) my_in_game_badge_value_should_be_PARAMINT:(NSString*) amount;

@end
