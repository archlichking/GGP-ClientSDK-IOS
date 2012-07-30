//
//  GreePlatformStepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GreePlatformStepDefinition.h"

#import "GreePlatform.h"

#import "CredentialStorage.h"
#import "StringUtil.h"
#import "QAAssert.h"

@implementation GreePlatformStepDefinition

+ (NSString*) boolToString:(BOOL) boo{
    if(boo){
        return @"YES";
    }else
        return @"NO";
}

- (void) I_check_basic_platform_info{
    [[self getBlockRepo] setObject:[[GreePlatform sharedInstance] accessToken] 
                            forKey:@"accessToken"];
    [[self getBlockRepo] setObject:[[GreePlatform sharedInstance] accessTokenSecret] 
                            forKey:@"accessTokenSecret"];
    [[self getBlockRepo] setObject:[[GreePlatform sharedInstance] 
                                    localUserId] forKey:@"userid"];
    [[self getBlockRepo] setObject:[GreePlatformStepDefinition boolToString:[GreePlatform isAuthorized]] 
                            forKey:@"isAuthorized"];
    [[self getBlockRepo] setObject:[GreePlatform greeApplicationURLScheme]
                            forKey:@"appUrlSchema"];

}

- (NSString*) platform_info_should_be_correct_to_user_with_email_PARAM:(NSString*) EMAIL 
                                                   _and_password_PARAM:(NSString*) PWD{
    NSString* result = @"";
    NSDictionary* tempDic = [[CredentialStorage sharedInstance] getValueForKey:[NSString stringWithFormat:@"%@&%@", EMAIL, PWD]];
    
    [QAAssert assertEqualsExpected:[tempDic valueForKey:CredentialStoredOauthKey] 
                            Actual:[[self getBlockRepo] objectForKey:@"accessToken"]];
    result = [result stringByAppendingFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@", 
              @"accessToken", 
              [tempDic valueForKey:CredentialStoredOauthKey] , 
              [[self getBlockRepo] objectForKey:@"accessToken"] , 
              SpliterTcmLine];
    
    [QAAssert assertEqualsExpected:[tempDic valueForKey:CredentialStoredOauthSecret] 
                            Actual:[[self getBlockRepo] objectForKey:@"accessTokenSecret"]];
    result = [result stringByAppendingFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@", 
              @"accessTokenSecret", 
              [tempDic valueForKey:CredentialStoredOauthSecret] , 
              [[self getBlockRepo] objectForKey:@"accessTokenSecret"] , 
              SpliterTcmLine];
    
    [QAAssert assertEqualsExpected:@"YES"
                            Actual:[[self getBlockRepo] objectForKey:@"isAuthorized"]];
    result = [result stringByAppendingFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@", 
              @"isAuthorized", 
              @"YES" , 
              [[self getBlockRepo] objectForKey:@"isAuthorized"] , 
              SpliterTcmLine];
    
    [QAAssert assertEqualsExpected:[NSString stringWithFormat:@"greeapp%@", [[CredentialStorage sharedInstance] getValueForKey:CredentialStoredAppId]]
                            Actual:[[self getBlockRepo] objectForKey:@"appUrlSchema"]];
    result = [result stringByAppendingFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@", 
              @"appUrlSchema", 
              [NSString stringWithFormat:@"greeapp%@", [[CredentialStorage sharedInstance] getValueForKey:CredentialStoredAppId]] , 
              [[self getBlockRepo] objectForKey:@"appUrlSchema"] , 
              SpliterTcmLine];
    
    [QAAssert assertEqualsExpected:[tempDic objectForKey:CredentialStoredUserid]
                            Actual:[[self getBlockRepo] objectForKey:@"userid"]];
    result = [result stringByAppendingFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@", 
              @"localUserId", 
              [tempDic objectForKey:CredentialStoredUserid] , 
              [[self getBlockRepo] objectForKey:@"userid"] , 
              SpliterTcmLine];
    
    return result;
}

@end
