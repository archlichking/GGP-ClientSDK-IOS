//
//  ModerationStepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StepDefinition.h"

@interface ModerationStepDefinition : StepDefinition


- (void) I_make_sure_moderation_server_PARAM:(NSString*) contain 
                                 _text_PARAM:(NSString*) text;

- (void) I_send_to_moderation_server_with_text_PARAM:(NSString*) text;

- (void) status_of_text_PARAM:(NSString*) text in_native_cache_should_be_PARAM:(NSString*) status;

- (void) status_of_text_PARAM:(NSString*) text 
    in_server_should_be_PARAM:(NSString*) status;

@end
