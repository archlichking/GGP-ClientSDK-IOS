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

@end
