//
//  FriendCodeStepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 5/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendCodeStepDefinition.h"
#import "GreeFriendCodes.h"
#import "GreeError.h"
#import "QAAssert.h"

@implementation FriendCodeStepDefinition

- (void) I_make_sure_my_friend_code_is_PARAM:(NSString*) isExist{
    if ([isExist isEqualToString:@"NOTEXIST"]) {
        [self I_delete_my_friend_code];
    }else{
        [self I_request_friend_code_with_expire_time_PARAM:@""];
    }
}

+ (NSString*) stringFromDate:(NSDate*) date{
    NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setLocale:[NSLocale systemLocale]];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"];
    return [formatter stringFromDate:date];
}

+ (NSDate*) dateFromString:(NSString*) dateString{
    NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setLocale:[NSLocale systemLocale]];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssZ"];
    return [formatter dateFromString:dateString];
}

- (void) I_request_friend_code_with_expire_time_PARAM:(NSString*) time{
    if ([time isEqualToString:@"NONE"]) {
        [GreeFriendCodes requestCodeWithBlock:^(NSString *code, NSError *error) {
            if(!error){
                [[self getBlockRepo] setObject:code 
                                        forKey:@"code"];
            }
            [self notifyInStep];
        }];
        [self waitForInStep];
    }else{
        NSDate* date = [FriendCodeStepDefinition dateFromString:time];
        [GreeFriendCodes requestCodeWithExpireTime:date 
                                             block:^(NSString *code, NSError *error) {
                                                 if(!error){
                                                     [[self getBlockRepo] setObject:code 
                                                                             forKey:@"code"];
                                                 }
                                                 [self notifyInStep];
                                             }];
        [self waitForInStep];
    }
}

- (void) I_load_my_friend_code{
    [GreeFriendCodes loadCodeWithBlock:^(NSString *code, NSDate *expiration, NSError *error) {
        if(!error){
            [[self getBlockRepo] setObject:code 
                                    forKey:@"code"];
            [[self getBlockRepo] setObject:expiration 
                                    forKey:@"expiretime"];
        }else if(error.code == GreeFriendCodeNotFound){
            // to deal with code not found error
            [[self getBlockRepo] setObject:@"NOTFOUND" 
                                    forKey:@"code"];
            [[self getBlockRepo] setObject:[FriendCodeStepDefinition dateFromString:@"2012-01-01T23:00:00+0000"]
                                    forKey:@"expiretime"];
            
        }
        [self notifyInStep];
    }];
    [self waitForInStep];
}

- (void) I_delete_my_friend_code{
    [GreeFriendCodes deleteCodeWithBlock:^(NSError *error) {
        if(!error){
            
        }
        [self notifyInStep];
    }];
    [self waitForInStep];
}

- (void) my_friend_code_length_should_be_PARAMINT:(NSString*) length{
    NSString* code = [[self getBlockRepo] objectForKey:@"code"];
    [QAAssert assertEqualsExpected:[NSString stringWithFormat:@"%i", [code length]] 
                            Actual:length];
    
}

- (void) my_friend_code_expire_time_should_be_PARAM:(NSString*) time{
    if ([time rangeOfString:@"days"].location != NSNotFound) {
        
    }else{
        //NSDate* date = [[self getBlockRepo] objectForKey:@"date"];
        
    }
}

- (void) I_load_the_owner_of_friend_code_I_verified{
    [GreeFriendCodes loadCodeOwner:^(NSString *userId, NSError *error) {
        if(!error){
            [[self getBlockRepo] setObject:userId 
                                    forKey:@"owner"];
        }
        [self notifyInStep];
    }];
    [self waitForInStep];
}

- (void) the_owner_should_be_user_PARAMINT:(NSString*) userid{
    NSString* user = [[self getBlockRepo] objectForKey:@"owner"];
    [QAAssert assertEqualsExpected:userid 
                            Actual:user];
}

- (void) my_friend_code_should_be_deleted{
    NSString* code = [[self getBlockRepo] objectForKey:@"code"];
    NSDate* date = [[self getBlockRepo] objectForKey:@"expiretime"];
    
    [QAAssert assertEqualsExpected:@"NOTFOUND" 
                            Actual:code];
    [QAAssert assertEqualsExpected:@"2012-01-01T23:00:00+0000"
                            Actual:[FriendCodeStepDefinition stringFromDate:date]];
}

@end
