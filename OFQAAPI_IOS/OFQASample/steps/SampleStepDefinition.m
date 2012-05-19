//
//  SampleStepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SampleStepDefinition.h"
#import "QAAssert.h"

#import "GreeAchievement.h"
#import "GreeLeaderboard.h"
#import "GreePlatform.h"

@implementation SampleStepDefinition


//- (void) When_I_kick{
//    NSLog(@"sample when i kick");
//}
//
//- (void) And_I_dance{
//    NSLog(@"sample and i dance");
//}
//
//- (void) When_I_want_to_PARAM:(NSString*) param1 _and_PARAM:(NSString*) param2{
//    NSLog(@"in When_I_want_to_PARAM_and_PARAM [%@, %@]", param1, param2);
//    [OFAssert assertEqualsExpected:@"40" Actual:@"70"];
//}
//
//- (void) When_I_want_to_say_PARAM:(NSString*) param1{
//    NSLog(@"in When_I_want_to_say_PARAM [%@]", param1);
//}
//
//- (void) Then_I_sleep{
//    NSLog(@"sample then i sleep");
//}
//
- (void) I_try_to_load_out_all_achievements_for_current_user{
    
}
- (void) all_achievements_I_have_should_be_return{
    __block int d =1;
    [GreeAchievement loadAchievementsWithBlock:^(NSArray* achievements, NSError* error) {
        if(!error) {
            [[self getBlockRepo] setObject:achievements forKey:@"achievements"];
        }
        d = 0;
    }];
    
    while (d != 0) {
        [NSThread sleepForTimeInterval:1];
    }
}

- (void) I_try_to_load_out_all_leaderboards_for_current_user{
    
}

- (void) all_leaderboards_I_have_should_be_return{
    __block int d =1;
    [GreeLeaderboard loadLeaderboardsWithBlock:^(NSArray *leaderboards, NSError *error) {
        if(!error) {
            [[self getBlockRepo] setObject:leaderboards forKey:@"leaderboards"];
        }
        d = 0;    
    }];
    while (d != 0) {
        [NSThread sleepForTimeInterval:1];
    }}

//
//- (void) Given_I_want_to_do_another_thing{
//}
//- (void) When_Im_still_alive{
//}
//- (void) Then_I_should_do_this_thing{
//}
//- (void) Then_20_plus_30_should_be_50{
//}
//
//- (void) Given_I_want_to_do_something{
//    ;
//}
//- (void) Then_10_plus_30_should_be_70{
//    [OFAssert assertEqualsExpected:@"40" Actual:@"70"];
//}
//- (void) Then_complex_10_plus_20_should_be_40{
//    [OFAssert assertEqualsExpected:@"30" Actual:@"40"];
//}

- (void) i_get_achievement{
 
}

- (void) i_set_achievement{
    // should do nothing
}

@end
