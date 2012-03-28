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
- (void) When_I_try_to_load_out_all_achievements_for_current_user{
    
}
- (void) Then_all_achievements_I_have_should_be_return{
    [self setBlockSentinal:[StepDefinition WAITING]];
    [GreeAchievement loadAchievementsWithBlock:^(NSArray* achievements, NSError* error) {
        if(error) {
            [self setBlockSentinal: [StepDefinition FAILED]];
            [self setBlockActual:[error description]];
            return;
        }
        if(![achievements count]) {
            [self setBlockSentinal:[StepDefinition FAILED]];
            [self setBlockActual:@"no achievement returned"];
            return;
        }
        [self setBlockSentinal:[StepDefinition PASSED]];
        [self setBlockExpected:[NSString stringWithFormat:@"%i", 5]];
        [self setBlockActual:[NSString stringWithFormat:@"%i", [achievements count]]];
    }];
    
    while ([self blockSentinal] == [StepDefinition WAITING]) {
        [NSThread sleepForTimeInterval:1];
    }
    
    [self assertWithBlockSentinal:^(id expected, id result){
        [QAAssert assertEqualsExpected:expected Actual:result];
    }];
}

- (void) When_I_try_to_load_out_all_leaderboards_for_current_user{
    
}

- (void) Then_all_leaderboards_I_have_should_be_return{
    [GreeLeaderboard loadLeaderboardsWithBlock:^(NSArray *leaderboards, NSError *error) {
        if(error) {
            [self setBlockSentinal: [StepDefinition FAILED]];
            [self setBlockActual:[error description]];
            return;
        }
        if(![leaderboards count]) {
            [self setBlockSentinal:[StepDefinition FAILED]];
            [self setBlockActual:@"no leaderboard returned"];
            return;
        }
        [self setBlockSentinal:[StepDefinition PASSED]];
        // set to 3 to make case fail by purpose
        [self setBlockExpected:[NSString stringWithFormat:@"%i", 3]];
        [self setBlockActual:[NSString stringWithFormat:@"%i", [leaderboards count]]];
    }];
    
    while ([self blockSentinal] == [StepDefinition WAITING]) {
        [NSThread sleepForTimeInterval:1];
    }
    
    [self assertWithBlockSentinal:^(id expected, id result){
        [QAAssert assertEqualsExpected:expected Actual:result];
    }];
}

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


@end
