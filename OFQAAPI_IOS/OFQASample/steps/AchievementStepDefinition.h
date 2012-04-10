//
//  AchievementStepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StepDefinition.h"

@interface AchievementStepDefinition : StepDefinition{
}

- (void) I_load_list_of_achievement;
- (void) I_should_have_total_achievements_PARAM:(NSString*) amount;
- (void) I_should_have_achievement_of_name_PARAM:(NSString*) ach_name 
                                    _with_status_PARAM:(NSString*) status 
                                      _and_score_PARAM:(NSString*) score;

- (void) I_make_sure_status_of_achievement_PARAM:(NSString*) ach_name 
                                                   _is_PARAM:(NSString*) status;

- (void) I_update_status_of_achievement_PARAM:(NSString*) ach_name 
                                          _to_PARAM:(NSString*) status;

- (void) status_of_achievement_PARAM:(NSString*) ach_name 
                         _should_be_PARAM:(NSString*) status;

- (void) my_score_should_be_PARAM:(NSString*) increment
                             _by_PARAMINT:(NSString*) time;


@end
