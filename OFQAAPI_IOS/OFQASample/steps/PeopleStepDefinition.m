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
    
    [GreeUser loadUserWithId:[[GreePlatform sharedInstance].localUser userId] 
                       block:^(GreeUser *user, NSError *error){
        if(!error) {
           // use actual to store achievement result
            [[self getBlockRepo] setObject:user forKey:@"user"];
        }
        [self notifyInStep];
    }];
    
    [self waitForInStep];
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
        else if([key isEqualToString:@"subregion"]){
            [QAAssert assertEqualsExpected:value 
                                    Actual:[user subRegion]];
            
        }
        else if([key isEqualToString:@"birthday"]){
            [QAAssert assertEqualsExpected:value 
                                    Actual:[user birthday]];
            
        }
        else if([key isEqualToString:@"aboutMe"]){
            [QAAssert assertEqualsExpected:value 
                                    Actual:[user aboutMe]];
            
        }
        else if([key isEqualToString:@"language"]){
            [QAAssert assertEqualsExpected:value 
                                    Actual:[user language]];
            
        }
        else if([key isEqualToString:@"timezone"]){
            [QAAssert assertEqualsExpected:value 
                                    Actual:[user timeZone]];
            
        }
        else if([key isEqualToString:@"bloodType"]){
            [QAAssert assertEqualsExpected:value 
                                    Actual:[user bloodType]];
            
        }
        else if([key isEqualToString:@"age"]){
            [QAAssert assertEqualsExpected:value 
                                    Actual:[user age]];
            
        }
        else{
            [QAAssert assertEqualsExpected:nil 
                                    Actual:key
                               WithMessage:@"no key matched"];
        }
        return;
    }
    [QAAssert assertEqualsExpected:value
                            Actual:nil];
    
}

// step definition : I check my friend list
- (void) I_check_my_friend_list{
    GreeUser* user = [GreePlatform sharedInstance].localUser;
    // temperary save for friends list
    NSMutableArray* array = [[[NSMutableArray alloc] init] autorelease];
    
    id<GreeEnumerator> enumerator = nil;
    if (user) {
        [self setTimeout:1];
        enumerator = [user loadFriendsWithBlock:^(NSArray *friends, NSError *error) {
            // first 10 friends could only be retrieved this way
            if (!error) {
                [array addObjectsFromArray:friends];
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
    }
    [[self getBlockRepo] setObject:array forKey:@"friends"];
}

// step definition : friend list should be size of NUMBER
- (void) friend_list_should_be_size_of_PARAMINT:(NSString*) size{
    NSArray* friends = [[self getBlockRepo] objectForKey:@"friends"];
    [QAAssert assertEqualsExpected:size 
                            Actual:[NSString stringWithFormat:@"%i", [friends count]]];
}

// step definition :  friend list should have USER_1
- (void) friend_list_should_have_PARAM:(NSString*) person{
    NSArray* friends = [[self getBlockRepo] objectForKey:@"friends"];
    for (GreeUser* f in friends) {
        if ([[f displayName] isEqualToString:person]) {
            [QAAssert assertEqualsExpected:@"TRUE" 
                                    Actual:@"TRUE"];
            return;
        }
    }
    [QAAssert assertEqualsExpected:person
                            Actual:nil
                       WithMessage:@"no person matches"];
    
}

// step definition : userid of USER_1 should be USER_ID and grade should be GRADE
- (void) userid_of_PARAM:(NSString*) person
        _should_be_PARAM:(NSString*) userid _and_grade_should_be_PARAMINT:(NSString*) grade{
    NSArray* friends = [[self getBlockRepo] objectForKey:@"friends"];
    for (GreeUser* f in friends) {
        if ([[f displayName] isEqualToString:person]) {
            [QAAssert assertEqualsExpected:userid
                                    Actual:[f userId]];
            [QAAssert assertEqualsExpected:[NSString stringWithFormat:@"%i", [f userGrade]] 
                                    Actual:grade];
            return;
        }
    }
    [QAAssert assertEqualsExpected:person
                            Actual:nil
                       WithMessage:@"no person matches"];
}


@end
