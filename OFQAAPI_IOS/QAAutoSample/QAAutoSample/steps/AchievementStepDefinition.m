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
#import "StringUtil.h"

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

// step definition :  I load list of achievement
- (void) I_load_list_of_achievement{
    [GreeAchievement loadAchievementsWithBlock:^(NSArray* achievements, NSError* error) {
        if(!error) {
            [[self getBlockRepo] setObject:achievements forKey:@"achievements"];
        }
        [self notifyInStep];
    }];
    
    [self waitForInStep];
}

// step definition :  I should have total NUMBER achievements
- (void) I_should_have_total_achievements_PARAM:(NSString*) amount{
    [QAAssert assertEqualsExpected:amount 
                            Actual:[NSString stringWithFormat:@"%i", [[[self getBlockRepo] objectForKey:@"achievements"] count]]];
}

// step definition : I should have achievement of name ACH_NAME with status LOCK and score SCORE
- (void) I_should_have_achievement_of_name_PARAM:(NSString*) ach_name 
                                    _with_status_PARAM:(NSString*) status 
                                      _and_score_PARAM:(NSString*) score{
    NSArray* achs = [[self getBlockRepo] objectForKey:@"achievements"];
    for (GreeAchievement* ach in achs) {
        if([[ach name] isEqualToString:ach_name]){
            [QAAssert assertEqualsExpected:status
                                    Actual:[AchievementStepDefinition lockToString:[ach isUnlocked]]];
            [QAAssert assertEqualsExpected:score
                                    Actual:[NSString stringWithFormat:@"%i", [ach score]]];
            return;
        }
    }
    [QAAssert assertNil:@"no achievement matches"];
}

// step definition :  I make sure status of achievement ACH_NAME is LOCK
- (void) I_make_sure_status_of_achievement_PARAM:(NSString*) ach_name 
                                             _is_PARAM:(NSString*) status{
    NSArray* achs = [[self getBlockRepo] objectForKey:@"achievements"];
    for (GreeAchievement* ach in achs) {
        if([[ach name] isEqualToString:ach_name]){
            if ([[AchievementStepDefinition lockToString:[ach isUnlocked]] isEqualToString:status]) {
                // do nothing
            }else{
                // reset status of achievement
                if ([ach isUnlocked]) {
                    [ach relockWithBlock:^{
                        [self notifyInStep];
                    }];
                }else{
                    [ach unlockWithBlock:^{
                        [self notifyInStep];
                    }];
                }
                [self waitForInStep];
            }
            return;
        }
    }
    [QAAssert assertNil:@"no achievement matches"];
}

// step definition : I update status of achievement ACH_NAME to UNLOCK
- (void) I_update_status_of_achievement_PARAM:(NSString*) ach_name 
                                          _to_PARAM:(NSString*) status{
    NSArray* achs = [[self getBlockRepo] objectForKey:@"achievements"];
    
    // initialized for submit to a non-existed achievement
    GreeAchievement* ach = [[GreeAchievement alloc] initWithIdentifier:ach_name];
    
    for (GreeAchievement* ac in achs) {
        if([[ac name] isEqualToString:ach_name]){
            [ach release];
            ach = ac;
            break;
        }
    }
    
    if ([AchievementStepDefinition lockToBool:status]) {
        [ach relockWithBlock:^{
            [self notifyInStep];
        }];
    }else{
        [ach unlockWithBlock:^{
            [self notifyInStep];
        }];
    }
    [self waitForInStep];
}

// step definition : status of achievement ACH_NAME should be UNLOCK
- (void) status_of_achievement_PARAM:(NSString*) ach_name 
                         _should_be_PARAM:(NSString*) status{
    NSArray* achs = [[self getBlockRepo] objectForKey:@"achievements"];
    GreeAchievement* ach = [[GreeAchievement alloc] initWithIdentifier:ach_name];
    
    for (GreeAchievement* ac in achs) {
        if([[ac name] isEqualToString:ach_name]){
            [ach release];
            ach = ac;
            break;
        }
    }
    
    [QAAssert assertEqualsExpected:status
                            Actual:[AchievementStepDefinition lockToString:[ach isUnlocked]]];
}

// step definition : my score should be DECREASED by SCORE
- (void) my_score_should_be_PARAM:(NSString*) increment
                             _by_PARAMINT:(NSString*) time{
}

// step definition : i load icon of achievement ACH
- (void) I_load_icon_of_achievement_PARAM:(NSString*) ach_name{
    NSArray* achs = [[self getBlockRepo] objectForKey:@"achievements"];
    [[self getBlockRepo] setObject:@"nil" 
                            forKey:@"achievementIcon"];
    
    for (GreeAchievement* ach in achs) {
        if([[ach name] isEqualToString:ach_name]){
            [ach loadIconWithBlock:^(UIImage *image, NSError *error) {
                if(!error){
                    [[self getBlockRepo] setObject:image 
                                            forKey:@"achievementIcon"]; 
                }
                [self notifyInStep];
            }];
            [self waitForInStep];
            return;
        }
    }
}

// step definition : i cancel load icon of achievement ACH
- (void) I_cancel_load_icon_of_achievement_PARAM:(NSString*) ach_name{
    NSArray* achs = [[self getBlockRepo] objectForKey:@"achievements"];
    [[self getBlockRepo] setObject:@"nil" 
                            forKey:@"achievementIcon"];
    
    for (GreeAchievement* ach in achs) {
        if([[ach name] isEqualToString:ach_name]){
            [ach loadIconWithBlock:^(UIImage *image, NSError *error) {
                if(!error){
                    [[self getBlockRepo] setObject:image 
                                            forKey:@"achievementIcon"]; 
                }
                [self notifyInStep];
            }];
            [ach cancelIconLoad];
            [self waitForInStep];
            return;
        }
    }
}

// step definition : achievement icon of ACH should be STATUS
- (NSString*) achievement_icon_of_PARAM:(NSString*) ach_name 
                  _should_be_PARAM:(NSString*) status{
    id icon = [[self getBlockRepo] objectForKey:@"achievementIcon"];
    
    if ([status isEqualToString:@"null"]) {
        [QAAssert assertEqualsExpected:@"nil" Actual:[NSString stringWithFormat:@"%@", icon]];
    }else{
        [QAAssert assertNotEqualsExpected:@"nil" Actual:[NSString stringWithFormat:@"%@", icon]];
    }
    
    return [NSString stringWithFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@",
            @"leaderboard icon", 
            status, 
            icon,
            SpliterTcmLine];
}

// step definition : i check basic info of achievement ACH
- (void) I_check_basic_info_of_achievement_PARAM:(NSString*) ach_name{
    GreeAchievement* ach = [[GreeAchievement alloc] initWithIdentifier:ach_name];
    NSArray* achs = [[self getBlockRepo] objectForKey:@"achievements"];
    
    for (GreeAchievement* ac in achs) {
        if([[ac name] isEqualToString:ach_name]){
            ach = ac;
            break;
        }
    }
    
    [[self getBlockRepo] setObject:ach forKey:ach_name];
}

// step definition : info INFO of achievement ACH should be RES
- (NSString*) info_PARAM:(NSString*) info 
   _of_achievement_PARAM:(NSString*) ach_name 
        _should_be_PARAM:(NSString*) res{
    GreeAchievement* ach = [[self getBlockRepo] objectForKey:ach_name];
    NSString* result = @"";
    if ([info isEqualToString:@"identifier"]) {
        [QAAssert assertEqualsExpected:res Actual:[ach identifier]];
        result = [NSString stringWithFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@",
                @"achievement identifier", 
                res, 
                [ach identifier],
                SpliterTcmLine];
    }
    else if ([info isEqualToString:@"name"]) {
        [QAAssert assertEqualsExpected:res Actual:[ach name]];
        result = [NSString stringWithFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@",
                @"achievement name", 
                res, 
                [ach name],
                SpliterTcmLine];
    }
    else if ([info isEqualToString:@"descriptionText"]) {
        [QAAssert assertEqualsExpected:res Actual:[ach descriptionText]];
        result = [NSString stringWithFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@",
                @"achievement descriptionText", 
                res, 
                [ach descriptionText],
                SpliterTcmLine];
    }
    else if ([info isEqualToString:@"isSecret"]) {
        [QAAssert assertEqualsExpected:res Actual:[ach isSecret]?@"YES":@"NO"];
        result = [NSString stringWithFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@",
                @"achievement isSecret", 
                res, 
                [ach isSecret]?@"YES":@"NO",
                SpliterTcmLine];
    }
    else if ([info isEqualToString:@"score"]) {
        [QAAssert assertEqualsExpected:res Actual:[NSString stringWithFormat:@"%i", [ach score]]];
        result = [NSString stringWithFormat:@"[%@] checked, expected (%@) ==> actual (%i) %@",
                @"achievement score", 
                res, 
                [ach score],
                SpliterTcmLine];
    }
    else if ([info isEqualToString:@"isUnlocked"]) {
        [QAAssert assertEqualsExpected:res Actual:[ach isUnlocked]?@"YES":@"NO"];
        result = [NSString stringWithFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@",
                @"achievement isUnlocked", 
                res, 
                [ach isUnlocked]?@"YES":@"NO",
                SpliterTcmLine];
    }
    else if ([info isEqualToString:@"descriptionString"]) {
        [QAAssert assertEqualsExpected:res Actual:[ach description]];
        result = [NSString stringWithFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@",
                @"achievement descriptionString", 
                res, 
                [ach description],
                SpliterTcmLine];
    }
    else {
        [QAAssert assertNil:@"no info matches"];
    }
    return result;
}
@end
