//
//  IgnorelistStepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StepDefinition.h"

@interface IgnorelistStepDefinition : StepDefinition{
    
}


- (void) I_make_sure_my_ignore_list_PARAM:(NSString*) contains
                              _user_PARAM:(NSString*) user;

- (void) I_load_my_ignore_list;

- (void) my_ignore_list_should_be_size_of_PARAMINT:(NSString*) size;

- (void) my_ignore_list_PARAM:(NSString*) isInclude 
                  _user_PARAM:(NSString*) user;

@end
