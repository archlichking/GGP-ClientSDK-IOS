//
//  CommenStepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StepDefinition.h"

@interface AuthorizationStepDefinition : StepDefinition{
    
}
// common
- (void) I_logged_in_with_email_PARAM:(NSString*) email
                  _and_password_PARAM:(NSString*) password;

- (void) I_logged_in_via_popup_with_email_PARAM:(NSString*) email
                  _and_password_PARAM:(NSString*) password;

- (void) I_switch_to_user_PARAM:(NSString*) user 
           _with_password_PARAM:(NSString*) pwd;

// login popup
- (void) I_replace_my_token_with_invalid_value;
- (void) I_recover_my_token_with_correct_value;
- (void) I_do_a_reauthorization;
- (void) authorization_failed_confirm_popup_should_display_well;


- (void) I_logout;
- (void) I_logout_without_popup;
- (void) I_should_logout;


// tend to logout 
- (void) I_tend_to_logout;
- (void) I_dismiss_authorization_popup;

- (void) logout_confirm_popup_should_display_well;





- (void) print_user;
- (void) as_server_automation_PARAM:(NSString*) anything;
- (void) as_android_automation_PARAM:(NSString*) anything;


@end
