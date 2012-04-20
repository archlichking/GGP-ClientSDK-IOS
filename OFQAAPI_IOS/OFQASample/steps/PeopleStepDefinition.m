//
//  PeopleStepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PeopleStepDefinition.h"

#import "GreeUser.h"
#import "GreePlatform.h"

#import "QAAssert.h"

@implementation PeopleStepDefinition

// step definition : i see my info from server
- (void) I_see_my_info_from_server{
     __block int d = 1;
    [GreeUser loadUserWithId:@"57574" block:^(GreeUser *user, NSError *error){
        if(!error) {
           // use actual to store achievement result
            [[self getBlockRepo] setObject:user forKey:@"user"];
        }
        d = 0;
    }];
    
    while (d != 0) {
        [NSThread sleepForTimeInterval:1];
    }
}

// step definition : i see my info from native cache
- (void) I_see_my_info_from_native_cache{
    GreeUser* user = [GreePlatform sharedInstance].localUser;
    [[self getBlockRepo] setObject:user forKey:@"user"];
}

// step definition : my displayName should be PLAYER_NAME
- (void) my_PARAM:(NSString*) key _should_be_PARAM:(NSString*) value{
    GreeUser* user = [[self getBlockRepo] objectForKey:@"user"];
    
    if (user) {
        if ([key isEqualToString:@"displayName"]) {
            [QAAssert assertEqualsExpected:value 
                                    Actual:[user displayName]];
        }
        else if([key isEqualToString:@"id"]){
            [QAAssert assertEqualsExpected:value 
                                    Actual:[user userId]];
            
        }
        else if([key isEqualToString:@"userGrade"]){
            [QAAssert assertEqualsExpected:value 
                                    Actual:[NSString stringWithFormat:@"%i", [user userGrade]]];
            
        }
        else if([key isEqualToString:@"region"]){
            [QAAssert assertEqualsExpected:value 
                                    Actual:[user region]];
            
        }
        return;
    }
    [QAAssert assertEqualsExpected:value
                            Actual:nil];
    
}

// step definition : I check my friend list
- (void) I_check_my_friend_list{
    GreeUser* user = [[self getBlockRepo] objectForKey:@"user"];
    if (user) {
         __block int d = 1;
        [user loadFriendsWithBlock:^(NSArray *friends, NSError *error) {
            if(!error){
                [[self getBlockRepo] setObject:friends forKey:@"friends"];
            }
            d = 0;
        }];
        while (d != 0) {
            [NSThread sleepForTimeInterval:1];
        }
    }
}

@end
