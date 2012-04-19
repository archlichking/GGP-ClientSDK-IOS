//
//  PeopleStepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StepDefinition.h"

@interface PeopleStepDefinition : StepDefinition

- (void) I_see_my_info_from_server;

- (void) I_see_my_info_from_native_cache;

- (void) my_PARAM:(NSString*) key _should_be_PARAM:(NSString*) value;

@end
