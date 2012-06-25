//
//  CommenStepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommenStepDefinition.h"
#import "GreeKeyChain.h"
#import "GreePlatform.h"
#import "GreeUser.h"


#import "CredentialStorage.h"
#import "QAAssert.h"

// private hacking to update local user
@interface GreePlatform(PrivateUserHacking)
- (void)updateLocalUser:(GreeUser*)user;
- (void)authorizeDidUpdateUserId:(NSString*)userId 
                       withToken:(NSString*)token 
                      withSecret:(NSString*)secret;
@property (nonatomic, retain) GreeUser* localUser;
@end


@implementation CommenStepDefinition

// step definition : I logged in with email EMAIL and password PWD
- (void) I_logged_in_with_email_PARAM:(NSString*) email
                  _and_password_PARAM:(NSString*) password{
    // do nothing here
    //[self notify];
//    return @"";
}

- (void) as_server_automation_PARAM:(NSString*) anything{
    
}

- (void) as_android_automation_PARAM:(NSString*) anything{
    
}

- (void) I_switch_to_user_PARAM:(NSString*) user 
                      _with_password_PARAM:(NSString*) pwd{
    
    
    NSString* tempKey = [NSString stringWithFormat:@"%@&%@", user, pwd];
    NSDictionary* credentialDic = [[CredentialStorage sharedInstance] getValueForKey:tempKey];
    if (!credentialDic) {
        [QAAssert assertEqualsExpected:tempKey 
                                Actual:nil 
                           WithMessage:@"no credential for current user %@ found in credential storage. make sure you have it configured in credentialConfig.json"];
    }
    
    [GreeKeyChain saveWithKey:GreeKeyChainUserIdIdentifier value:[credentialDic objectForKey:CredentialStoredUserid]];
    [GreeKeyChain saveWithKey:GreeKeyChainAccessTokenIdentifier value:[credentialDic objectForKey:CredentialStoredOauthKey]];
    [GreeKeyChain saveWithKey:GreeKeyChainAccessTokenSecretIdentifier value:[credentialDic objectForKey:CredentialStoredOauthSecret]];
        
    [GreeUser loadUserWithId:[credentialDic objectForKey:CredentialStoredUserid] block:^(GreeUser *user, NSError *error) {
        [[GreePlatform sharedInstance] updateLocalUser:user];
        [[GreePlatform sharedInstance] authorizeDidUpdateUserId:[credentialDic objectForKey:CredentialStoredUserid] 
                                                      withToken:[credentialDic objectForKey:CredentialStoredOauthKey] 
                                                     withSecret:[credentialDic objectForKey:CredentialStoredOauthSecret]];
        [self notifyInStep];
    }];
    [self waitForInStep];

    
}

- (void) print_user{
    NSLog(@"%@", [[GreePlatform sharedInstance] localUser]);
    [GreeUser loadUserWithId:@"@me" block:^(GreeUser *user, NSError *error) {
        if (!error) {
            NSLog(@"%@", user);
        }
    }];
}



//- (void) I_change_my_account_to_user_PARAM:(NSString*) user 
//                      _with_password_PARAM:(NSString*) pwd{
//    NSURL* url = [[NSURL alloc] initWithString:@"http://open-sb.gree.net"];
//    GreeHTTPClient* client = [[GreeHTTPClient alloc] initWithBaseURL:url
//                                                                 key:@"3c47b530df23" 
//                                                              secret:@"c6958d092a3db174de86678f31d86d01"];
//    __block NSString* oauth_request_token = nil;
//    __block NSString* oauth_request_secret = nil;
//    
//    // oauth 2 legged request
//    [client setOAuthVerifier:nil];
//    [client setUserToken:nil secret:nil];
//    [client rawRequestWithMethod:@"GET" 
//                            path:@"/oauth/request_token" 
//                      parameters:nil 
//                         success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
//                             NSString* responseBody = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]; 
//                             NSArray *pairs = [responseBody componentsSeparatedByString:@"&"];  
//                             
//                             for (NSString *pair in pairs) {
//                                 NSArray *elements = [pair componentsSeparatedByString:@"="];
//                                 if ([[elements objectAtIndex:0] isEqualToString:@"oauth_token"]) {
//                                     oauth_request_token = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//                                 } else if ([[elements objectAtIndex:0] isEqualToString:@"oauth_token_secret"]) {
//                                     oauth_request_secret = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//                                 } 
//                             }    
//                             [responseBody release];   
//                             [self notifyInStep];
//                         } 
//                         failure:^(GreeAFHTTPRequestOperation *operation, NSError *error) {
//                             [self notifyInStep];
//                         }];
//    [self waitForInStep];
//    
//    // oauth 3 legged request
//    [client setUserToken:oauth_request_token 
//                  secret:oauth_request_secret];
//    [client rawRequestWithMethod:@"GET" 
//                            path:@"/oauth/access_token" 
//                      parameters:nil 
//                         success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
//                             NSString* responseBody = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]; 
//                             NSArray *pairs = [responseBody componentsSeparatedByString:@"&"];  
//                             
//                             for (NSString *pair in pairs) {
//                                 NSArray *elements = [pair componentsSeparatedByString:@"="];
//                                 if ([[elements objectAtIndex:0] isEqualToString:@"oauth_token"]) {
//                                     oauth_request_token = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//                                 } else if ([[elements objectAtIndex:0] isEqualToString:@"oauth_token_secret"]) {
//                                     oauth_request_secret = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//                                 } 
//                             }    
//                             [responseBody release];   
//                             [self notifyInStep];
//                         } 
//                         failure:^(GreeAFHTTPRequestOperation *operation, NSError *error) {
//                             [self notifyInStep];
//                         }];
//    [self waitForInStep];
//    return;
//}

@end
