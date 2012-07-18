//
//  CommenStepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 4/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StepDefinition.h"

@interface CommenStepDefinition : StepDefinition{
    
}

- (void) I_logged_in_with_email_PARAM:(NSString*) email
                  _and_password_PARAM:(NSString*) password;

- (void) as_server_automation_PARAM:(NSString*) anything;

- (void) as_android_automation_PARAM:(NSString*) anything;

- (void) I_switch_to_user_PARAM:(NSString*) user 
           _with_password_PARAM:(NSString*) pwd;

- (void) print_user;

- (void) I_logout;

@end
