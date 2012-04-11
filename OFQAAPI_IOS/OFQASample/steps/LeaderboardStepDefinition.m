//
//  LeaderboardStepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LeaderboardStepDefinition.h"

#import "QAAssert.h"
#import "QALog.h"
#import "GreeLeaderboard.h"

#import "GreeScore.h"

@implementation LeaderboardStepDefinition

+ (NSString*) BoolToString:(bool) bo{
    if(bo){
        return @"YES";
    }
    else{
        return @"NO";
    }
}

+ (BOOL) StringToBool:(NSString*) str{
    if([str isEqualToString:@"YES"] 
       || [str isEqualToString:@"EXISTS"]){
        return YES;
    }
    else{
        return NO;
    }
}

+ (GreeScoreTimePeriod) StringToPeriod:(NSString*) str{
    GreeScoreTimePeriod k = GreeScoreTimePeriodAlltime;
    if ([str isEqualToString:@"TOTAL"]) {
        k =  GreeScoreTimePeriodAlltime;
    }
    if([str isEqualToString:@"WEEKLY"]){
        k = GreeScoreTimePeriodWeekly;
    }
    if([str isEqualToString:@"DAILY"]){
        k = GreeScoreTimePeriodDaily;
    }
    return k;
}

// step definition : I load list of leaderboard
- (void) I_load_list_of_leaderboard{
//    [self wait];
    [GreeLeaderboard loadLeaderboardsWithBlock:^(NSArray* leaderboards, NSError* error) {
        [[self blockRepo] setObject:leaderboards forKey:@"leaderboards"];
        [self notify];
    }];
}

// step definition : I should have total leaderboards NUMBER
- (void) I_should_have_total_leaderboards_PARAMINT:(NSString*) amount{
    [QAAssert assertEqualsExpected:amount 
                            Actual:[NSString stringWithFormat:@"%i", [[[self blockRepo] objectForKey:@"leaderboards"] count]]];

}

// step definition : I should have leaderboard of name LB_NAME with allowWorseScore NO and secret NO and order asc NO
- (void) I_should_have_leaderboard_of_name_PARAM:(NSString*) ld_name 
                     _with_allowWorseScore_PARAM:(NSString*) aws
                               _and_secret_PARAM:(NSString*) secret
                            _and_order_asc_PARAM:(NSString*) order{
    NSArray* lds = [[self blockRepo] objectForKey:@"leaderboards"];
    for (GreeLeaderboard* ld in lds) {
        if([[ld name] isEqualToString:ld_name]){
            [QAAssert assertEqualsExpected:aws 
                                    Actual:[LeaderboardStepDefinition BoolToString:[ld allowWorseScore]]];
            [QAAssert assertEqualsExpected:secret 
                                    Actual:[LeaderboardStepDefinition BoolToString:[ld isSecret]]];
            [QAAssert assertEqualsExpected:order 
                                    Actual:[LeaderboardStepDefinition BoolToString:[ld sortOrder]]];
            break;
        }
    }
}

// step definition : I make sure my score NOTEXISTS in leaderboard LB_NAME
- (void) I_make_sure_my_score_PARAM:(NSString*) exist
              _in_leaderboard_PARAM:(NSString*) ld_name{
    NSArray* lds = [[self blockRepo] objectForKey:@"leaderboards"];
    for (GreeLeaderboard* ld in lds) {
        if([[ld name] isEqualToString:ld_name]){
            if ([LeaderboardStepDefinition StringToBool:exist]) {
                // need to add score if no score in current leaderboard
                GreeScore* score = [[GreeScore alloc] initWithLeaderboard:[ld identifier] 
                                                                    score:3000];
                [score submit];
                // have to wait for 1 sec since no async callback here to handle
                [NSThread sleepForTimeInterval:2];
                [score release];
            }else{
//                [self wait];
                // need to delete existed score
                [GreeScore deleteMyScoreForLeaderboard:[ld identifier] 
                                             withBlock:^(NSError *error){
                                                 [self notify];
                                             }];
            }
            return;
        }
    }
}

// step definition : I add score to leaderboard LB_NAME with score SCORE
- (void) I_add_score_to_leaderboard_PARAM:(NSString*) ld_name
                     _with_score_PARAMINT:(NSString*) score{
    // initialized for submit to a non-existed leaderboard
    NSString* identi = [[NSString alloc] initWithString:ld_name];
    NSArray* lds = [[self blockRepo] objectForKey:@"leaderboards"];
    for (GreeLeaderboard* ld in lds) {
        if([[ld name] isEqualToString:ld_name]){
            identi = [ld identifier];
            break;
        }
    }
    // for submit to a non-existed leaderboard
    GreeScore* s = [[GreeScore alloc] initWithLeaderboard:identi 
                                                    score:[score integerValue]];
    [s submit];
    // have to wait for 1 sec since no async callback here to handle
    [NSThread sleepForTimeInterval:2];
    [s release];
    return;
}

// step definition : my score SCORE should be updated in leaderboard LB_NAME
- (void) my_score_PARAMINT:(NSString*) score _should_be_updated_in_leaderboard_PARAM:(NSString*) ld_name{
    NSArray* lds = [[self blockRepo] objectForKey:@"leaderboards"];
    // initialized for submit to a non-existed leaderboard
    NSString* identi = [[NSString alloc] initWithString:ld_name];
    for (GreeLeaderboard* ld in lds) {
        if([[ld name] isEqualToString:ld_name]){
            identi = [ld identifier];
            break;
        }
    }
   
//    [self wait];
    __block int64_t s = -1;
    [GreeScore loadMyScoreForLeaderboard:identi 
                              timePeriod:GreeScoreTimePeriodAlltime
                                   block:^(GreeScore *score, NSError *error) {
                                       if(!error){
                                           s = [score score];
                                       }
                                       [self notify];
                                   }];
    [QAAssert assertEqualsExpected:score 
                            Actual:[NSString stringWithFormat:@"%i", s]];
    [identi release];
    return;


}

// step definition : my DAILY score ranking of leaderboard LB_NAME should be RANK
- (void) my_PARAM:(NSString*) period _score_ranking_of_leaderboard_PARAM:(NSString*) ld_name _should_be_PARAMINT:(NSString*) rank{
    NSArray* lds = [[self blockRepo] objectForKey:@"leaderboards"];
    for (GreeLeaderboard* ld in lds) {
        if([[ld name] isEqualToString:ld_name]){
//            [self wait];
            __block int64_t r = -1;
            [GreeScore loadMyScoreForLeaderboard:[ld identifier] 
                                      timePeriod:[LeaderboardStepDefinition StringToPeriod:period]
                                           block:^(GreeScore *score, NSError *error) {
                                               if(!error){
                                                   r = [score rank];
                                               }
                                               [self notify];
                                           }];
                        
            [QAAssert assertEqualsExpected:rank 
                                    Actual:[NSString stringWithFormat:@"%i", r]];
            return;
        }
    }
}

// step definition : I delete my score in leaderboard LB_NAME
- (void) I_delete_my_score_in_leaderboard_PARAM:(NSString*) ld_name{
    // initialized for submit to a non-existed leaderboard
    NSString* identi = [[NSString alloc] initWithString:ld_name];
    NSArray* lds = [[self blockRepo] objectForKey:@"leaderboards"];
    for (GreeLeaderboard* ld in lds) {
        if([[ld name] isEqualToString:ld_name]){
            identi = [ld identifier];
            break;
        }
    }
//    [self wait];
    [GreeScore deleteMyScoreForLeaderboard:identi 
                                 withBlock:^(NSError *error) {
                                     [self notify];
                                 }];
    [identi release];
    return;
}

@end
