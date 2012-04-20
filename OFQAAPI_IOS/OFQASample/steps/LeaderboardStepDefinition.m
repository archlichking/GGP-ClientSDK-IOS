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
    GreeScoreTimePeriod ret = GreeScoreTimePeriodAlltime;
    if ([str isEqualToString:@"TOTAL"]) {
        ret =  GreeScoreTimePeriodAlltime;
    }
    else if([str isEqualToString:@"WEEKLY"]){
        ret =  GreeScoreTimePeriodWeekly;
    }
    else if([str isEqualToString:@"DAILY"]){
        ret = GreeScoreTimePeriodDaily;
    }
    return ret;
}

// step definition : I load list of leaderboard
- (void) I_load_list_of_leaderboard{
    __block int d = 1;
    [GreeLeaderboard loadLeaderboardsWithBlock:^(NSArray* leaderboards, NSError* error) {
        if(!error) {
            [[self getBlockRepo] setObject:leaderboards forKey:@"leaderboards"];
        }
        d = 0;
    }];
    
    while (d != 0) {
        [NSThread sleepForTimeInterval:1];
    }

}

// step definition : I should have total leaderboards NUMBER
- (void) I_should_have_total_leaderboards_PARAMINT:(NSString*) amount{
    [QAAssert assertEqualsExpected:amount 
                            Actual:[NSString stringWithFormat:@"%i", 
                                    [[[self getBlockRepo] objectForKey:@"leaderboards"] count]]];

}

// step definition : I should have leaderboard of name LB_NAME with allowWorseScore NO and secret NO and order asc NO
- (void) I_should_have_leaderboard_of_name_PARAM:(NSString*) ld_name 
                     _with_allowWorseScore_PARAM:(NSString*) aws
                               _and_secret_PARAM:(NSString*) secret
                            _and_order_asc_PARAM:(NSString*) order{
    NSArray* lds = [[self getBlockRepo] objectForKey:@"leaderboards"];
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
    NSArray* lds = [[self getBlockRepo] objectForKey:@"leaderboards"];
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
                 __block int d = 1;
                // need to delete existed score
                [GreeScore deleteMyScoreForLeaderboard:[ld identifier] 
                                             withBlock:^(NSError *error){
                                                 d = 0;
                                             }];
                while (d != 0) {
                    [NSThread sleepForTimeInterval:1];
                }
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
    NSArray* lds = [[self getBlockRepo] objectForKey:@"leaderboards"];
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
    NSArray* lds = [[self getBlockRepo] objectForKey:@"leaderboards"];
    // initialized for submit to a non-existed leaderboard
    NSString* identi = [[NSString alloc] initWithString:ld_name];
    for (GreeLeaderboard* ld in lds) {
        if([[ld name] isEqualToString:ld_name]){
            identi = [ld identifier];
            break;
        }
    }
   
    __block int d = 1;
    __block int64_t s = 0;
    [GreeScore loadMyScoreForLeaderboard:identi 
                              timePeriod:GreeScoreTimePeriodAlltime
                                   block:^(GreeScore *score, NSError *error) {
                                       if(!error){
                                           s = [score score];
                                       }
                                       d = 0;
                                   }];
    // has to wait for async call finished
    while (d == 1) {
        [NSThread sleepForTimeInterval:1];
    }
    
    [QAAssert assertEqualsExpected:score 
                            Actual:[NSString stringWithFormat:@"%i", s]];
    [identi release];
    return;


}

// step definition : my DAILY score ranking of leaderboard LB_NAME should be RANK
- (void) my_PARAM:(NSString*) period _score_ranking_of_leaderboard_PARAM:(NSString*) ld_name _should_be_PARAMINT:(NSString*) rank{
    NSArray* lds = [[self getBlockRepo] objectForKey:@"leaderboards"];
    for (GreeLeaderboard* ld in lds) {
        if([[ld name] isEqualToString:ld_name]){
            __block int d = 1;
            __block int64_t r = 0;
            [GreeScore loadMyScoreForLeaderboard:[ld identifier] 
                                      timePeriod:[LeaderboardStepDefinition StringToPeriod:period]
                                           block:^(GreeScore *score, NSError *error) {
                                               if(!error){
                                                   r = [score rank];
                                               }
                                               d = 0;
                                           }];
            // has to wait for async call finished
            while (d == 1) {
                [NSThread sleepForTimeInterval:1];
            }
            
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
    NSArray* lds = [[self getBlockRepo] objectForKey:@"leaderboards"];
    for (GreeLeaderboard* ld in lds) {
        if([[ld name] isEqualToString:ld_name]){
            identi = [ld identifier];
            break;
        }
    }
    __block int d = 1;
    [GreeScore deleteMyScoreForLeaderboard:identi 
                                 withBlock:^(NSError *error) {
                                     d = 0;
                                 }];
    while (d == 1) {
        [NSThread sleepForTimeInterval:1];
    }
    [identi release];
    return;
}

@end
