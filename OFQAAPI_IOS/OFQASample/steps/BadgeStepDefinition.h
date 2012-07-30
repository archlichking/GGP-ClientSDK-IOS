//
//  BadgeStepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 7/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StepDefinition.h"

@interface BadgeStepDefinition : StepDefinition

- (void) I_update_badge_value_to_latest_one;
- (void) I_update_badge_value_to_latest_one_for_all_application;
- (void) I_reset_badge_value;

- (void) my_social_badge_value_should_be_PARAMINT:(NSString*) amount;
- (void) my_in_game_badge_value_should_be_PARAMINT:(NSString*) amount;

@end
