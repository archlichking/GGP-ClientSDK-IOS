//
//  AchievementStepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 4/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AchievementStepDefinition.h"

#import "QAAssert.h"
#import "QALog.h"
#import "GreeAchievement.h"


@implementation AchievementStepDefinition

+ (NSString*) lockToString:(bool) isunlock{
    if(isunlock){
        return @"UNLOCK";
    }
    else{
        return @"LOCK";
    }
}

+ (BOOL) lockToBool:(NSString*) islock{
    if([islock isEqualToString:@"LOCK"]){
        return YES;
    }
    else{
        return NO;
    }
}

- (id)init{
    if (self=[super init])
    {
        
    }
    return self;
}

// step definition :  I load list of achievement
- (void) I_load_list_of_achievement{
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
        // use actual to store achievement result
        [self setBlockActual:achievements];
    }];
    
    while ([self blockSentinal] == [StepDefinition WAITING]) {
        [NSThread sleepForTimeInterval:1];
    }
}

// step definition :  I should have total NUMBER achievements
- (void) I_should_have_total_achievements_PARAM:(NSString*) amount{
    [QAAssert assertEqualsExpected:amount 
                            Actual:[NSString stringWithFormat:@"%i", [[self blockActual] count]]];
}

// step definition : I should have achievement of name ACH_NAME with status LOCK and score SCORE
- (void) I_should_have_achievement_of_name_PARAM:(NSString*) ach_name 
                                    _with_status_PARAM:(NSString*) status 
                                      _and_score_PARAM:(NSString*) score{
    NSArray* achs = [self blockActual];
    for (GreeAchievement* ach in achs) {
        if([[ach name] isEqualToString:ach_name]){
            [QAAssert assertEqualsExpected:status
                                    Actual:[AchievementStepDefinition lockToString:[ach isUnlocked]]];
            [QAAssert assertEqualsExpected:score
                                    Actual:[NSString stringWithFormat:@"%i", [ach score]]];
            return;
        }
    }
    [QAAssert assertEqualsExpected:ach_name
                            Actual:@"nil"];
}

// step definition :  I make sure status of achievement ACH_NAME is LOCK
- (void) I_make_sure_status_of_achievement_PARAM:(NSString*) ach_name 
                                             _is_PARAM:(NSString*) status{
    NSArray* achs = [self blockActual];
    for (GreeAchievement* ach in achs) {
        if([[ach name] isEqualToString:ach_name]){
            if ([[AchievementStepDefinition lockToString:[ach isUnlocked]] isEqualToString:status]) {
                // do nothing
            }else{
                // reset status of achievement
                if ([ach isUnlocked]) {
                    [ach relock];
                }else{
                    [ach unlock];
                }
            }
            return;
        }
    }
    [QAAssert assertEqualsExpected:ach_name
                            Actual:@"nil"];
}

// step definition : I update status of achievement ACH_NAME to UNLOCK
- (void) I_update_status_of_achievement_PARAM:(NSString*) ach_name 
                                          _to_PARAM:(NSString*) status{
    NSArray* achs = [self blockActual];
    for (GreeAchievement* ach in achs) {
        if([[ach name] isEqualToString:ach_name]){
            if ([AchievementStepDefinition lockToBool:status]) {
                [ach relock];
            }else{
                [ach unlock];
            }
            return;
        }
    }
    [QAAssert assertEqualsExpected:ach_name
                            Actual:@"nil"];
}

// step definition : status of achievement ACH_NAME should be UNLOCK
- (void) status_of_achievement_PARAM:(NSString*) ach_name 
                         _should_be_PARAM:(NSString*) status{
    NSArray* achs = [self blockActual];
    for (GreeAchievement* ach in achs) {
        if([[ach name] isEqualToString:ach_name]){
            [QAAssert assertEqualsExpected:status
                                    Actual:[AchievementStepDefinition lockToString:[ach isUnlocked]]];
            return;
        }
    }
    [QAAssert assertEqualsExpected:ach_name
                            Actual:@"nil"];
}

// step definition : my score should be DECREASED by SCORE
- (void) my_score_should_be_PARAM:(NSString*) increment
                             _by_PARAMINT:(NSString*) time{
    // do nothing
}

@end
