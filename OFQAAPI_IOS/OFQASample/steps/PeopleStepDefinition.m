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

- (void) I_see_my_info_from_server{
    [self setBlockSentinal:[StepDefinition WAITING]];
    [GreeUser loadUserWithId:@"57574" block:^(GreeUser *user, NSError *error){
        if(error) {
            [self setBlockSentinal: [StepDefinition FAILED]];
            [self setBlockActual:[error description]];
            return;
        }
        [self setBlockSentinal:[StepDefinition PASSED]];
        // use actual to store achievement result
        [self setBlockActual:user];
    }];
    
    while ([self blockSentinal] == [StepDefinition WAITING]) {
        [NSThread sleepForTimeInterval:1];
    }
}

- (void) I_see_my_info_from_native_cache{
    GreeUser* user = [GreePlatform sharedInstance].localUser;
    [self setBlockActual:user];
}

- (void) my_PARAM:(NSString*) key _should_be_PARAM:(NSString*) value{
    GreeUser* user = [self blockActual];
    
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

@end
