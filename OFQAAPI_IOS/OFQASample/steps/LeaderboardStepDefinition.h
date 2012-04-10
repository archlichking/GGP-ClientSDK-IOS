//
//  LeaderboardStepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StepDefinition.h"

@interface LeaderboardStepDefinition : StepDefinition{
    
}

- (void) I_load_list_of_leaderboard;
- (void) I_should_have_total_leaderboards_PARAMINT:(NSString*) amount;
- (void) I_should_have_leaderboard_of_name_PARAM:(NSString*) ld_name 
                     _with_allowWorseScore_PARAM:(NSString*) aws
                               _and_secret_PARAM:(NSString*) secret
                            _and_order_asc_PARAM:(NSString*) order;

@end
