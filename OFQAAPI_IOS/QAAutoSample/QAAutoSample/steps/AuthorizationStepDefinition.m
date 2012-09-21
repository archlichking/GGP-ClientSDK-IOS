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
#import "GreePlatform+Internal.h"
#import "GreeUser.h"
#import "GreeAuthorizationPopup.h"

#import "AppDelegate.h"

#import "CredentialStorage.h"
#import "Constant.h"
#import "StringUtil.h"
#import "CommandUtil.h"
#import "QAAssert.h"
#import "QALog.h"

// private hacking to update local user
@interface GreePlatform(PrivateUserHacking)
- (void)updateLocalUser:(GreeUser*)user;
- (void)authorizeDidUpdateUserId:(NSString*)userId 
                       withToken:(NSString*)token 
                      withSecret:(NSString*)secret;
@property (nonatomic, retain) GreeUser* localUser;
@end

// private hacking to authorization popup
@interface GreeAuthorizationPopup(AuthorizationPopupHacking)
- (void)popupViewWebViewDidFinishLoad:(UIWebView*)aWebView;
@end

@implementation GreeAuthorizationPopup(AuthorizationPopupHacking)
- (void)popupViewWebViewDidFinishLoad:(UIWebView*)aWebView{
//    QALog(@"%@", [aWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"]);
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
    [[self getBlockRepo] setObject:email forKey:@"valie_email"];
    [[self getBlockRepo] setObject:password forKey:@"valie_password"];
    
    if ([[GreeKeyChain readWithKey:GreeKeyChainUserIdIdentifier] isEqualToString:[credentialDic objectForKey:CredentialStoredUserid]]) {
        // no need to switch user
        
        return;
    }
    
    [GreeKeyChain saveWithKey:GreeKeyChainUserIdIdentifier value:[credentialDic objectForKey:CredentialStoredUserid]];
    [GreeKeyChain saveWithKey:GreeKeyChainAccessTokenIdentifier value:[credentialDic objectForKey:CredentialStoredOauthKey]];
    [GreeKeyChain saveWithKey:GreeKeyChainAccessTokenSecretIdentifier value:[credentialDic objectForKey:CredentialStoredOauthSecret]];

    [GreePlatform authorizeNonInteractivelyWithBlock:^(GreeUser *localUser, NSError *error) {
        if (error) {
            
        }
        [self notifyInStep];
    }];
    [self waitForInStep];
}

// step definition: 
- (void) I_logged_in_via_popup_with_email_PARAM:(NSString*) email
                            _and_password_PARAM:(NSString*) password{
    
    [StepDefinition waitForOutsideStep];
    
    GreeAuthorizationPopup* popup = [[StepDefinition getOutsideBlockRepo] objectForKey:@"popup"];
    // email
    NSString* js = @"click(fclass('button block register')[0])";
    
    id resultBlock = ^(NSString* result){
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
    
    // 2. input name/pwd and click log in
    // this is for login popup, and only for sandbox
    popup = [[StepDefinition getOutsideBlockRepo] objectForKey:@"popup"];
    // email
    js = [NSString stringWithFormat:@"setText(fid('mail'), '%@')", email];
    
    resultBlock = ^(NSString* result){
        [self notifyInStep];
    };
    
    userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", executeJavascriptInPopup], @"command",
                                        popup, @"executor",
                                        js, @"jsCommand",
                                        resultBlock, @"jsCallback",
                                        nil];
    
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    
    [self waitForInStep];
    [StepDefinition waitForOutsideStep];
    
    [userinfoDic release];
    
    // pwd
    js = [NSString stringWithFormat:@"setText(fid('user_password'), '%@')", password];
    
    resultBlock = ^(NSString* result){
        [self notifyInStep];
    };
    
    userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", executeJavascriptInPopup], @"command",
                                        popup, @"executor",
                                        js, @"jsCommand",
                                        resultBlock, @"jsCallback",
                                        nil];
    
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    
    [self waitForInStep];
    [StepDefinition waitForOutsideStep];
    
    // login button
    js = @"click(fclass('button large block primary')[0])";
    
    resultBlock = ^(NSString* result){
        [self notifyInStep];
    };
    
    userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
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

// step definition: i switch to user U with password P
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
        
    [GreePlatform authorizeWithBlock:^(GreeUser *localUser, NSError *error) {
        [self notifyInStep];
    }];
    [self waitForInStep];
    
}

// step definition: i replace my token with invalid value
- (void) I_replace_my_token_with_invalid_value{
    // do a little tricky thing here
    [GreeKeyChain saveWithKey:GreeKeyChainUserIdIdentifier value:@"ererer"];
    [GreeKeyChain saveWithKey:GreeKeyChainAccessTokenIdentifier value:@"ererer"];
    
    
}

// step definition: i recover my token with correct value
- (void) I_recover_my_token_with_correct_value{
    [self I_switch_to_user_PARAM:[[self getBlockRepo] objectForKey:@"valie_email"]
            _with_password_PARAM:[[self getBlockRepo] objectForKey:@"valie_password"]];
}

// step definition: i do a reauthorization
- (void) I_do_a_reauthorization{
    [GreePlatform authorizeWithBlock:^(GreeUser *localUser, NSError *error) {
        
    }];
    
    [StepDefinition waitForOutsideStep];
    
    
}

- (void) authorization_failed_confirm_popup_should_display_well{
    GreeAuthorizationPopup* popup = [[StepDefinition getOutsideBlockRepo] objectForKey:@"popup"];
    [QAAssert assertNotNil:popup];
//    // click logout button
//    NSString* js = @"click(fclass('button large block per80')[0])";
//    
//    id resultBlock = ^(NSString* result){
//        [self notifyInStep];
//    };
//    
//    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
//                                        [NSString stringWithFormat:@"%i", executeJavascriptInPopup], @"command",
//                                        popup, @"executor",
//                                        js, @"jsCommand",
//                                        resultBlock, @"jsCallback",
//                                        nil];
//    
//    [self notifyMainUIWithCommand:CommandDispatchCommand 
//                           object:userinfoDic];
//    
//    [self waitForInStep];
//    [StepDefinition waitForOutsideStep];
    [[StepDefinition getOutsideBlockRepo] removeObjectForKey:@"popup"];
}

// step definition: i tend to logout
- (void) I_tend_to_logout{
    [GreePlatform revokeAuthorizationWithBlock:^(NSError *error) {
    }];
    [StepDefinition waitForOutsideStep];
}
// step definition: logout confirm popup should display well
- (void) logout_confirm_popup_should_display_well{
    GreeAuthorizationPopup* popup = [[StepDefinition getOutsideBlockRepo] objectForKey:@"popup"];
    [QAAssert assertNotNil:popup];
}

// step definition : i logout
- (void) I_logout{
    // this only works for sandbox
    [GreePlatform revokeAuthorizationWithBlock:^(NSError *error) {
    }];
    
    // wait for logout popup
    [StepDefinition waitForOutsideStep];
    
    GreeAuthorizationPopup* popup = [[StepDefinition getOutsideBlockRepo] objectForKey:@"popup"];
    
    // click logout button
    NSString* js = @"click(fclass('button large block primary')[0])";
    
    id resultBlock = ^(NSString* result){
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

// step definition : i logout without popup
- (void) I_logout_without_popup{
    [GreePlatform revokeAuthorizationNonInteractivelyWithBlock:^(NSError *error) {
        if (error) {
            
        }
        [self notifyInStep];
    }];
    [self waitForInStep];
}

// step definition : i should logout
- (void) I_should_logout{
    GreeUser* u = [[GreePlatform sharedInstance] localUser];
    [QAAssert assertNil:u];
}

- (void) I_dismiss_authorization_popup{
    GreeAuthorizationPopup* popup = [[StepDefinition getOutsideBlockRepo] objectForKey:@"popup"];
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", dismissPopup], @"command",
                                        popup, @"executor", 
                                        nil];
    
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    [StepDefinition waitForOutsideStep];
    
}

- (void) as_server_automation_PARAM:(NSString*) anything{
}

- (void) as_android_automation_PARAM:(NSString*) anything{
}

- (void) print_user{
    QALog(@"%@", [[GreePlatform sharedInstance] localUser]);
    [GreeUser loadUserWithId:@"@me" block:^(GreeUser *user, NSError *error) {
        if (!error) {
            QALog(@"%@", user);
        }
    }];
}
@end
