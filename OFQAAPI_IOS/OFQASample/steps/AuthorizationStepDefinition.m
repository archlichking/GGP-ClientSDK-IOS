//
//  CommenStepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AuthorizationStepDefinition.h"
#import "GreeKeyChain.h"
#import "GreePlatform.h"
#import "GreeUser.h"
#import "GreeAuthorizationPopup.h"

#import "AppDelegate.h"

#import "CredentialStorage.h"
#import "Constant.h"
#import "StringUtil.h"
#import "CommandUtil.h"
#import "QAAssert.h"

// private hacking to update local user
@interface GreePlatform(PrivateUserHacking)
- (void)updateLocalUser:(GreeUser*)user;
- (void)authorizeDidUpdateUserId:(NSString*)userId 
                       withToken:(NSString*)token 
                      withSecret:(NSString*)secret;
@property (nonatomic, retain) GreeUser* localUser;
@end

//
@interface GreeAuthorizationPopup(AuthorizationPopupHacking)
- (void)popupViewWebViewDidFinishLoad:(UIWebView*)aWebView;
@end

@implementation GreeAuthorizationPopup(AuthorizationPopupHacking)
- (void)popupViewWebViewDidFinishLoad:(UIWebView*)aWebView{
    NSLog(@"%@", [aWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"]);
    if (self.didFinishLoadHandlingBlock){
        self.didFinishLoadHandlingBlock(aWebView.request);
    }
    
    [[StepDefinition getOutsideBlockRepo] setObject:self forKey:@"popup"];
    [StepDefinition notifyOutsideStep];
}
@end

@implementation AuthorizationStepDefinition

// step definition : I logged in with email EMAIL and password PWD
- (void) I_logged_in_with_email_PARAM:(NSString*) email
                  _and_password_PARAM:(NSString*) password{
    NSString* tempKey = [NSString stringWithFormat:@"%@&%@", email, password];
    NSDictionary* credentialDic = [[CredentialStorage sharedInstance] getValueForKey:tempKey];
    if (!credentialDic) {
        [QAAssert assertEqualsExpected:tempKey 
                                Actual:nil 
                           WithMessage:@"no credential for current user %@ found in credential storage. make sure you have it configured in credentialConfig.json"];
    }
    
    if ([[GreeKeyChain readWithKey:GreeKeyChainUserIdIdentifier] isEqualToString:[credentialDic objectForKey:CredentialStoredUserid]]) {
        // no need to switch user
        return;
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

// step definition: 
- (void) I_logged_in_via_popup_with_email_PARAM:(NSString*) email
                            _and_password_PARAM:(NSString*) password{
    // this is for login popup
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

// step definition : i logout
- (void) I_logout{
    // this only works for sandbox
    [GreePlatform revokeAuthorizationWithBlock:^(NSError *error) {
        if(!error){
            
        }
    }];
    
    // wait for logout popup
    [StepDefinition waitForOutsideStep];
    
    GreeAuthorizationPopup* popup = [[StepDefinition getOutsideBlockRepo] objectForKey:@"popup"];
    [[self getBlockRepo] setObject:popup 
                            forKey:@"popup"];
    
    // click logout button
    NSString* js = @"stringify(fclass('button large block primary'))";
    
    id resultBlock = ^(NSString* result){
        [[self getBlockRepo] setObject:result forKey:@"logoutButton"];
        [self notifyInStep];
    };
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", executeJavascriptInPopup], @"command",
                                        popup, @"executor",
                                        js, @"jsCommand",
                                        resultBlock, @"jsCallback",
                                        nil];
    
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    
    [self waitForInStep];
    [StepDefinition waitForOutsideStep];
}

- (void) print_user{
    NSLog(@"%@", [[GreePlatform sharedInstance] localUser]);
    [GreeUser loadUserWithId:@"@me" block:^(GreeUser *user, NSError *error) {
        if (!error) {
            NSLog(@"%@", user);
        }
    }];
}
@end
