//
//  BadgeStepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 7/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BadgeStepDefinition.h"

#import "GreeBadgeValues.h"
#import "GreeBadgeValues+Internal.h"
#import "GreePlatform.h"

#import "CredentialStorage.h"
#import "StringUtil.h"
#import "QAAssert.h"


@implementation BadgeStepDefinition

// step definition : i update badge value to latest one
- (void) I_update_badge_value_to_latest_one{
    [[GreePlatform sharedInstance] updateBadgeValuesWithBlock:^(GreeBadgeValues *badgeValues) {
        [[self getBlockRepo] setObject:badgeValues forKey:@"badgeValues"];
        [self inStepNotify];
    }];
    [self inStepWait];
}

// step definition : my social badge value should be VALUE
- (void) my_social_badge_value_should_be_PARAMINT:(NSString*) amount{
    GreeBadgeValues *badgeValues = [[self getBlockRepo] objectForKey:@"badgeValues"];
    [QAAssert assertEqualsExpected:[NSString stringWithFormat:@"%i", [badgeValues socialNetworkingServiceBadgeCount]] 
                            Actual:amount];
}

// step definition : my in game badge value should be VALUE
- (void) my_in_game_badge_value_should_be_PARAMINT:(NSString*) amount{
    GreeBadgeValues *badgeValues = [[self getBlockRepo] objectForKey:@"badgeValues"];
    [QAAssert assertEqualsExpected:[NSString stringWithFormat:@"%i", [badgeValues applicationBadgeCount]] 
                            Actual:amount];
}

// step definition : i reset badge value
- (void) I_reset_badge_value{
    [GreeBadgeValues resetBadgeValues];
}

// step definition : i update badge value to latest one for all application
- (void) I_update_badge_value_to_latest_one_for_all_application{
    [GreeBadgeValues loadBadgeValuesForAllApplicationsWithBlock:^(GreeBadgeValues *badgeValues, NSError *error) {
        [[self getBlockRepo] setObject:badgeValues forKey:@"badgeValues"];
        [self inStepNotify];
    }];
    [self inStepWait];
}

@end
