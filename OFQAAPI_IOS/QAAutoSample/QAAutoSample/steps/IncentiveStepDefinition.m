//
//  IncentiveStepDefinition.m
//  QAAutoSample
//
//  Created by zhu lei on 10/18/12.
//  Copyright (c) 2012 OFQA. All rights reserved.
//

#import "IncentiveStepDefinition.h"

#import "GreeIncentive.h"

#import "CredentialStorage.h"
#import "QAAssert.h"

@implementation IncentiveStepDefinition

- (void) I_initialize_incentive_with_incentive_type_PARAM:(NSString*) type
                                             _and_message_PARAM:(NSString*) msg{
    GreeIncentiveType t = GreeIncentiveTypeInvite;
    if ([type isEqualToString:@"request"]) {
        t = GreeIncentiveTypeRequest;
    }
    
    NSDictionary *payload = [NSDictionary dictionaryWithObject:msg
                                                        forKey:@"message"];
    
    GreeIncentive* incentive = [[GreeIncentive alloc] initWithType:t
                                                 payloadDictionary:payload];
    
    [[self getBlockRepo] setObject:incentive
                            forKey:@"incentive"];
}

- (void) I_send_incentive_to_user_of_email_PARAM:(NSString*) emails{
    [[self getBlockRepo] removeObjectForKey:@"targetNumber"];
    GreeIncentive* incentive = [[self getBlockRepo] objectForKey:@"incentive"];
    
    NSArray* uemails = [emails componentsSeparatedByString:@","];
    NSMutableArray* users = [[NSMutableArray alloc] init];
    
    for (NSString* mail in uemails) {
        NSString* userid = [[[CredentialStorage sharedInstance] getValueForKey:[NSString stringWithFormat:@"%@&123456", mail]] valueForKey:CredentialStoredUserid];
        [users addObject:userid];
    }
    
    [incentive postIncentiveToUsers:users
                              block:^(NSString *numberOfTargets, NSError *error) {
                                  if (!error) {
                                      [[self getBlockRepo] setValue:numberOfTargets
                                                             forKey:@"targetNumber"];
                                  }
                                  
                                  [self inStepNotify];
                              }];
    [self inStepWait];
    [users release];
}

- (void) incentive_target_should_be_PARAMINT:(NSString*) target{
    NSString* targets = [[self getBlockRepo] valueForKey:@"targetNumber"];
    
    [QAAssert assertEqualsExpected:target Actual:targets];
}

- (void) I_mark_incentive_as_processed{
    GreeIncentive* incentive = [[self getBlockRepo] objectForKey:@"incentive"];
    [incentive completeWithBlock:^(NSError *error) {
        if(!error){
            
        }
        [self inStepNotify];
    }];
    [self inStepWait];
}
- (void) I_query_unprocessed_incentives_of_type_PARAM:(NSString*) type{
    [[self getBlockRepo] removeObjectForKey:@"incentives"];
    GreeIncentiveType t = GreeIncentiveTypeInvite;
    if ([type isEqualToString:@"request"]) {
        t = GreeIncentiveTypeRequest;
    }

    [GreeIncentive loadUnprocessedIncentivesOfType:t
                                         withBlock:^(NSArray *incentives, NSError *error) {
                                             if(!error && incentives){
                                                 [[self getBlockRepo] setObject:incentives forKey:@"incentives"];
                                             }
                                             [self inStepNotify];
                                         }];
    [self inStepWait];
}

- (void) unprocessed_incentive_number_should_be_PARAMINT:(NSString*) amount{
    NSArray* a = [[self getBlockRepo] objectForKey:@"incentives"];
    [QAAssert assertEqualsExpected:amount
                            Actual:[NSString stringWithFormat:@"%i", [a count]]];
    
}

- (void) unprocessed_incentives_should_include_incentive_of_message_PARAM:(NSString*) msg{
    bool has = false;
    NSArray* a = [[self getBlockRepo] objectForKey:@"incentives"];
    for (GreeIncentive* incentive in a) {
        if([[[incentive payloadDictionary] objectForKey:@"message"] isEqualToString:msg]){
            has = true;
            break;
        }
    }
    [QAAssert assertEqualsExpected:@"1"
                            Actual:[NSString stringWithFormat:@"%i", has]];
}

@end
