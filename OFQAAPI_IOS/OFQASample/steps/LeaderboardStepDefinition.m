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
#import "GreeEnumerator.h"
#import "GreeScore.h"
#import "GreeUser.h"

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

+ (GreePeopleScope) StringToScope:(NSString*) str{
    GreePeopleScope ret1 = GreePeopleScopeSelf;
    if ([str isEqualToString:@"FRIENDS"]) {
        ret1 = GreePeopleScopeFriends;
    }else if ([str isEqualToString:@"EVERYONE"]) {
        ret1 = GreePeopleScopeAll;
    }else if ([str isEqualToString:@"MINE"]) {
        ret1 = GreePeopleScopeSelf;
    }
    return ret1;
}

// step definition : I load list of leaderboard
- (void) I_load_list_of_leaderboard{
    [GreeLeaderboard loadLeaderboardsWithBlock:^(NSArray* leaderboards, NSError* error) {
        if(!error) {
            [[self getBlockRepo] setObject:leaderboards forKey:@"leaderboards"];
        }
        [self notifyInStep];
    }];
    
    [self waitForInStep];

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
            return;
        }
    }
    [QAAssert assertEqualsExpected:ld_name
                            Actual:nil
                       WithMessage:@"no leaderboard matches"];
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
                // need to delete existed score
                [GreeScore deleteMyScoreForLeaderboard:[ld identifier] 
                                             withBlock:^(NSError *error){
                                                 [self notifyInStep];
                                             }];
                [self waitForInStep];
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
    NSString* identi = [[[NSString alloc] initWithString:ld_name] autorelease];
    for (GreeLeaderboard* ld in lds) {
        if([[ld name] isEqualToString:ld_name]){
            identi = [ld identifier];
            break;
        }
    }
   
    __block int64_t s = 0;
    [GreeScore loadMyScoreForLeaderboard:identi 
                              timePeriod:GreeScoreTimePeriodAlltime
                                   block:^(GreeScore *score, NSError *error) {
                                       if(!error){
                                           s = [score score];
                                       }
                                       [self notifyInStep];
                                   }];
    // has to wait for async call finished
    [self waitForInStep];
    
    [QAAssert assertEqualsExpected:score 
                            Actual:[NSString stringWithFormat:@"%i", s]];
//    [identi release];
    return;


}
// step definition : my DAILY score ranking of leaderboard LB_NAME should be RANK
- (void) my_PARAM:(NSString*) period _score_ranking_of_leaderboard_PARAM:(NSString*) ld_name _should_be_PARAMINT:(NSString*) rank;{
    NSArray* lds = [[self getBlockRepo] objectForKey:@"leaderboards"];
    for (GreeLeaderboard* ld in lds) {
        if([[ld name] isEqualToString:ld_name]){
            __block int64_t r = 0;
            [GreeScore loadMyScoreForLeaderboard:[ld identifier] 
                                      timePeriod:[LeaderboardStepDefinition StringToPeriod:period]
                                           block:^(GreeScore *score, NSError *error) {
                                               if(!error){
                                                   r = [score rank];
                                               }
                                               [self notifyInStep];
                                           }];
            // has to wait for async call finished
            [self waitForInStep];
            
            [QAAssert assertEqualsExpected:rank 
                                    Actual:[NSString stringWithFormat:@"%i", r]];
            return;
        }
    }
    [QAAssert assertEqualsExpected:ld_name
                            Actual:nil
                       WithMessage:@"no leaderboard matches"];
}


// step definition : I delete my score in leaderboard LB_NAME
- (void) I_delete_my_score_in_leaderboard_PARAM:(NSString*) ld_name{
    // initialized for submit to a non-existed leaderboard
    NSString* identi = [[[NSString alloc] initWithString:ld_name] autorelease];
    NSArray* lds = [[self getBlockRepo] objectForKey:@"leaderboards"];
    for (GreeLeaderboard* ld in lds) {
        if([[ld name] isEqualToString:ld_name]){
            identi = [ld identifier];
            break;
        }
    }
    [GreeScore deleteMyScoreForLeaderboard:identi 
                                 withBlock:^(NSError *error) {
                                     [self notifyInStep];
                                 }];
    [self waitForInStep];
   // [identi release];
    return;
}

// step definition : I load score list of EVERYONE section for leaderboard LB_NAME for period PERIOD
- (void) I_load_score_list_of_PARAM:(NSString*) scope 
     _section_for_leaderboard_PARAM:(NSString*) ld_name 
                  _for_period_PARAM:(NSString*) period{
    NSArray* lds = [[self getBlockRepo] objectForKey:@"leaderboards"];
    __block NSMutableArray* array = [[[NSMutableArray alloc] init] autorelease];
    for (GreeLeaderboard* ld in lds) {
        if([[ld name] isEqualToString:ld_name]){
            
            id<GreeEnumerator> enumerator = nil;
            enumerator = [GreeScore scoreEnumeratorForLeaderboard:[ld identifier] 
                                                       timePeriod:[LeaderboardStepDefinition StringToPeriod:period]
                                                      peopleScope:[LeaderboardStepDefinition StringToScope:scope]];
            // in case of size of array is less than 10
            
            [enumerator loadNext:^(NSArray *items, NSError *error) {
                if(!error){
                    [array addObjectsFromArray:items];
                }
                [self notifyInStep];
            }];
                    
            [self waitForInStep];
            while ([enumerator canLoadNext]) {
                
                [enumerator loadNext:^(NSArray *items, NSError *error) {
                    if(!error){
                        [array addObjectsFromArray:items];
                    }
                    [self notifyInStep];
                }];
                [self waitForInStep];
            }
            break;
        }
    }
    [[self getBlockRepo] setObject:array forKey:@"scores"];
}

// step definition : list should have score SCORE of player P_NAME with rank RANK
- (void) list_should_have_score_PARAMINT:(NSString*) score 
                        _of_player_PARAM:(NSString*) p_name 
                     _with_rank_PARAMINT:(NSString*) rank{
    NSArray* srcs = [[self getBlockRepo] objectForKey:@"scores"];
    for(GreeScore* gs in srcs){
        if ([[[gs user] nickname] isEqual:p_name]) {
            [QAAssert assertEqualsExpected:rank
                                    Actual:[NSString stringWithFormat:@"%i", [gs rank]]];
            [QAAssert assertEqualsExpected:score 
                                    Actual:[NSString stringWithFormat:@"%i", [gs score]]];
            return;
        }
    }
    [QAAssert assertEqualsExpected:p_name
                            Actual:nil
                       WithMessage:@"no player score matches"];
}

// step definition : I load top MARK score list for leaderboard LB_NAME for period PERIOD
- (void) I_load_top_score_list_for_leaderboard_PARAM:(NSString*) ld_name _for_period_PARAM:(NSString*) period{
    NSArray* lds = [[self getBlockRepo] objectForKey:@"leaderboards"];
    __block NSMutableArray* array = [[[NSMutableArray alloc] init] autorelease];
    for (GreeLeaderboard* ld in lds) {
        if([[ld name] isEqualToString:ld_name]){
            id<GreeEnumerator> enumerator = nil;
            // in case of size of array is less than 10
            
            enumerator = [GreeScore loadTopScoresForLeaderboard:[ld identifier]
                                                     timePeriod:[LeaderboardStepDefinition StringToPeriod:period] 
                                                          block:^(NSArray *scoreList, NSError *error) {
                                                              if(!error){
                                                                  [array addObjectsFromArray:scoreList];
                                                              }
                                                              [self notifyInStep];
                                                          }];
            [self waitForInStep];
            while ([enumerator canLoadNext]) {
               
                [enumerator loadNext:^(NSArray *items, NSError *error) {
                    if(!error){
                        [array addObjectsFromArray:items];
                    }
                    [self notifyInStep];
                }];
                [self waitForInStep];
            }
            break;
        }
    }
    [[self getBlockRepo] setObject:array forKey:@"scores"];
}

// step definition : I load top MARK score list for leaderboard LB_NAME for period PERIOD
- (void) I_load_top_friend_score_list_for_leaderboard_PARAM:(NSString*) ld_name _for_period_PARAM:(NSString*) period{
    NSArray* lds = [[self getBlockRepo] objectForKey:@"leaderboards"];
    __block NSMutableArray* array = [[[NSMutableArray alloc] init] autorelease];
    for (GreeLeaderboard* ld in lds) {
        if([[ld name] isEqualToString:ld_name]){
            id<GreeEnumerator> enumerator = nil;
            // in case of size of array is less than 10
            enumerator = [GreeScore loadTopFriendScoresForLeaderboard:[ld identifier]
                                                     timePeriod:[LeaderboardStepDefinition StringToPeriod:period] 
                                                          block:^(NSArray *scoreList, NSError *error) {
                                                              if(!error){
                                                                  [array addObjectsFromArray:scoreList];
                                                              }
                                                              [self notifyInStep];
                                                          }];
            [self waitForInStep];
            while ([enumerator canLoadNext]) {
                [enumerator loadNext:^(NSArray *items, NSError *error) {
                    if(!error){
                        [array addObjectsFromArray:items];
                    }
                    [self notifyInStep];
                }];
                [self waitForInStep];
            }
            break;
        }
    }
    [[self getBlockRepo] setObject:array forKey:@"scores"];
}

@end
