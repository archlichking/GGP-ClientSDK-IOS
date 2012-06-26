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
//    [[self getBlockRepo] setObject:[[GreePlatform sharedInstance] accessToken] 
//                            forKey:@"accessToken"];
//    [[self getBlockRepo] setObject:[[GreePlatform sharedInstance] accessTokenSecret] 
//                            forKey:@"accessTokenSecret"];
    [[self getBlockRepo] setObject:[GreePlatformStepDefinition boolToString:[GreePlatform isAuthorized]] 
                            forKey:@"isAuthorized"];
}

- (NSString*) platform_info_should_be_correct{
    NSString* result = @"";
//    [QAAssert assertEqualsExpected:[[CredentialStorage sharedInstance] getValueForKey:CredentialStoredOauthKey] 
//                            Actual:[[self getBlockRepo] objectForKey:@"accessToken"]];
//    result = [result stringByAppendingFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@", 
//              @"accessToken", 
//              [[CredentialStorage sharedInstance] getValueForKey:CredentialStoredOauthKey] , 
//              [[self getBlockRepo] objectForKey:@"accessToken"] , 
//              SpliterTcmLine];
//    
//    [QAAssert assertEqualsExpected:[[CredentialStorage sharedInstance] getValueForKey:CredentialStoredOauthSecret] 
//                            Actual:[[self getBlockRepo] objectForKey:@"accessTokenSecret"]];
//    result = [result stringByAppendingFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@", 
//              @"accessTokenSecret", 
//              [[CredentialStorage sharedInstance] getValueForKey:CredentialStoredOauthSecret] , 
//              [[self getBlockRepo] objectForKey:@"accessTokenSecret"] , 
//              SpliterTcmLine];
    
    [QAAssert assertEqualsExpected:@"YES"
                            Actual:[[self getBlockRepo] objectForKey:@"isAuthorized"]];
    result = [result stringByAppendingFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@", 
              @"isAuthorized", 
              @"YES" , 
              [[self getBlockRepo] objectForKey:@"isAuthorized"] , 
              SpliterTcmLine];
    
    return result;
}

@end
