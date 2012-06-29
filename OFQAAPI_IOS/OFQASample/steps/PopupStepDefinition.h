//
//  PopupStepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StepDefinition.h"

@interface PopupStepDefinition : StepDefinition

- (void) I_open_request_popup;
- (void) I_close_request_popup;
- (void) I_execute_command_in_request_popup_PARAM:(NSString*) command;



@end
