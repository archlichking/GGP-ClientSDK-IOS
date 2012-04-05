//
//  SampleStepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StepDefinition.h"

@interface SampleStepDefinition : StepDefinition{
    
}

//- (void) When_I_kick;
//- (void) And_I_dance;
//- (void) Then_I_sleep;
//
//- (void) When_I_want_to_PARAM:(NSString*) param1 _and_PARAM:(NSString*) param2;
//- (void) When_I_want_to_say_PARAM:(NSString*) param1;
//- (void) Given_I_want_to_do_another_thing;
//- (void) When_Im_still_alive;
//- (void) Then_I_should_do_this_thing;
//- (void) Then_20_plus_30_should_be_50;
//
//- (void) Given_I_want_to_do_something;
//- (void) Then_10_plus_30_should_be_70;
//- (void) Then_complex_10_plus_20_should_be_40;

// for case 11684
- (void) I_try_to_load_out_all_achievements_for_current_user;
- (void) all_achievements_I_have_should_be_return;

// for case 11671
- (void) I_try_to_load_out_all_leaderboards_for_current_user;
- (void) all_leaderboards_I_have_should_be_return;

@end
