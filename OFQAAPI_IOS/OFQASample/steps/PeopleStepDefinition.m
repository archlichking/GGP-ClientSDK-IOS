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

#import "StringUtil.h"
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

// step definition : I check my friend list first page
- (void) I_check_my_friend_list_first_page{
    GreeUser* user = [GreePlatform sharedInstance].localUser;
        
    if (user) {
        [user loadFriendsWithBlock:^(NSArray *friends, NSError *error) {
            // first 10 friends could only be retrieved this way
            if (!error) {
                [[self getBlockRepo] setObject:friends 
                                        forKey:@"friends"];
            }
            [self notifyInStep];
        }];
        [self waitForInStep];
    }
}

// step definition : i see my info from native cache
- (void) I_see_my_info_from_native_cache{
    GreeUser* user = [GreePlatform sharedInstance].localUser;
    [[self getBlockRepo] setObject:user forKey:@"user"];
}

// step definition : my displayName should be PLAYER_NAME
- (NSString*) my_info_PARAM:(NSString*) key _should_be_PARAM:(NSString*) value{
    GreeUser* user = [[self getBlockRepo] objectForKey:@"user"];
    NSString* result = @"";
    if (user) {
        if ([key isEqualToString:@"displayName"]) {
            [QAAssert assertEqualsExpected:value 
                                    Actual:[user displayName]];
            result = [result stringByAppendingFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@", 
                      key, 
                      value, 
                      [user displayName], 
                      SpliterTcmLine];
        }
        else if([key isEqualToString:@"id"]){
            [QAAssert assertEqualsExpected:value 
                                    Actual:[user userId]];
            result = [result stringByAppendingFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@", 
                      key, 
                      value, 
                      [user userId],
                      SpliterTcmLine];
            
        }
        else if([key isEqualToString:@"userGrade"]){
            [QAAssert assertEqualsExpected:value 
                                    Actual:[NSString stringWithFormat:@"%i", [user userGrade]]];
            result = [result stringByAppendingFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@",
                      key, 
                      value, 
                      [NSString stringWithFormat:@"%i", [user userGrade]],
                      SpliterTcmLine];
        }
        else if([key isEqualToString:@"region"]){
            [QAAssert assertEqualsExpected:value 
                                    Actual:[user region]];
            result = [result stringByAppendingFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@",
                      key, 
                      value, 
                      [user region],
                      SpliterTcmLine];
        }
        else if([key isEqualToString:@"subregion"]){
            [QAAssert assertEqualsExpected:value 
                                    Actual:[user subRegion]];
            result = [result stringByAppendingFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@",
                      key, 
                      value, 
                      [user subRegion],
                      SpliterTcmLine];
        }
        else if([key isEqualToString:@"birthday"]){
            [QAAssert assertEqualsExpected:value 
                                    Actual:[user birthday]];
            result = [result stringByAppendingFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@",
                      key, 
                      value, 
                      [user birthday],
                      SpliterTcmLine];
        }
        else if([key isEqualToString:@"aboutMe"]){
            [QAAssert assertEqualsExpected:value 
                                    Actual:[user aboutMe]];
            result = [result stringByAppendingFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@",
                      key, 
                      value, 
                      [user aboutMe],
                      SpliterTcmLine];
        }
        else if([key isEqualToString:@"language"]){
            [QAAssert assertEqualsExpected:value 
                                    Actual:[user language]];
            result = [result stringByAppendingFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@",
                      key, 
                      value, 
                      [user language],
                      SpliterTcmLine];
        }
        else if([key isEqualToString:@"timezone"]){
            [QAAssert assertEqualsExpected:value 
                                    Actual:[user timeZone]];
            result = [result stringByAppendingFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@",
                      key, 
                      value, 
                      [user timeZone],
                      SpliterTcmLine];
        }
        else if([key isEqualToString:@"bloodType"]){
            [QAAssert assertEqualsExpected:value 
                                    Actual:[user bloodType]];
            result = [result stringByAppendingFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@",
                      key, 
                      value, 
                      [user bloodType],
                      SpliterTcmLine];
        }
        else if([key isEqualToString:@"age"]){
            [QAAssert assertEqualsExpected:value 
                                    Actual:[user age]];
            result = [result stringByAppendingFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@",
                      key, 
                      value, 
                      [user age],
                      SpliterTcmLine];
        }
        else{
            [QAAssert assertEqualsExpected:nil 
                                    Actual:key
                               WithMessage:@"no key matched"];
        }
        return result;
    }
    [QAAssert assertEqualsExpected:value
                            Actual:nil];
    return nil;
    
}

// step definition : I check my friend list
- (void) I_check_my_friend_list{
    GreeUser* user = [GreePlatform sharedInstance].localUser;
    // temperary save for friends list
    NSMutableArray* array = [[[NSMutableArray alloc] init] autorelease];
    
    id<GreeEnumerator> enumerator = nil;
    if (user) {
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
- (NSString*) friend_list_should_be_size_of_PARAMINT:(NSString*) size{
    NSArray* friends = [[self getBlockRepo] objectForKey:@"friends"];
    [QAAssert assertEqualsExpected:size 
                            Actual:[NSString stringWithFormat:@"%i", [friends count]]];
    return @"";
}

// step definition :  friend list should have USER_1
- (NSString*) friend_list_should_have_PARAM:(NSString*) person{
    NSArray* friends = [[self getBlockRepo] objectForKey:@"friends"];
    for (GreeUser* f in friends) {
        if ([[f displayName] isEqualToString:person]) {
            [QAAssert assertEqualsExpected:@"TRUE" 
                                    Actual:@"TRUE"];
             return @"";
        }
    }
    [QAAssert assertEqualsExpected:person
                            Actual:nil
                       WithMessage:@"no person matches"];
    return nil;
    
}

- (NSString*) friend_list_should_not_have_PARAM:(NSString*) person{
    NSArray* friends = [[self getBlockRepo] objectForKey:@"friends"];
    for (GreeUser* f in friends) {
        if ([[f displayName] isEqualToString:person]) {
            [QAAssert assertEqualsExpected:@"FALSE" 
                                    Actual:@"TRUE"
                               WithMessage:@"Friend found!!!"];
            return @"";
        }
    }
    [QAAssert assertEqualsExpected:@"TRUE"
                            Actual:@"TRUE"];
    return nil;
}

// step definition : userid of USER_1 should be USER_ID and grade should be GRADE
- (NSString*) userid_of_PARAM:(NSString*) person
        _should_be_PARAM:(NSString*) userid _and_grade_should_be_PARAMINT:(NSString*) grade{
    NSArray* friends = [[self getBlockRepo] objectForKey:@"friends"];
    for (GreeUser* f in friends) {
        if ([[f displayName] isEqualToString:person]) {
            [QAAssert assertEqualsExpected:userid
                                    Actual:[f userId]];
            [QAAssert assertEqualsExpected:[NSString stringWithFormat:@"%i", [f userGrade]] 
                                    Actual:grade];
             return @"";
        }
    }
    [QAAssert assertEqualsExpected:person
                            Actual:nil
                       WithMessage:@"no person matches"];
    return nil;
}


@end
