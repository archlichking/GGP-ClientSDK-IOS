//
//  IgnorelistStepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StepDefinition.h"


@interface IgnorelistStepDefinition : StepDefinition

- (void) I_make_sure_my_ignore_list_PARAM:(NSString*) contains
                              _user_PARAM:(NSString*) user;

- (void) I_load_my_ignore_list;

- (void) I_load_first_page_of_my_ignore_list;

- (void) my_ignore_list_should_be_size_of_PARAMINT:(NSString*) size;

- (void) my_ignore_list_should_PARAM:(NSString*) isInclude 
                  _user_PARAM:(NSString*) user;

- (void) I_check_user_from_my_ignore_list_with_id_PARAMINT:(NSString*) userid;

- (void) status_of_PARAM:(NSString*) userid _in_my_ignore_list_should_be_PARAM:(NSString*) isInclude;

@end
