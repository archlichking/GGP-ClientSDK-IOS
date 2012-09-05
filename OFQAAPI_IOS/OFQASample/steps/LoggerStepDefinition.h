//
//  LoggerStepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 9/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StepDefinition.h"

@interface LoggerStepDefinition : StepDefinition

- (void) I_set_the_logging_level_to_PARAM:(NSString*) level;
- (void) debug_logging_level_should_be_PARAM:(NSString*) level; 


@end
