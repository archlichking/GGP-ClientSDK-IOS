//
//  AnnouncementStepDefinition.h
//  QAAutoSample
//
//  Created by zhu lei on 11/19/12.
//  Copyright (c) 2012 OFQA. All rights reserved.
//

#import "StepDefinition.h"

@interface VGAnnouncementStepDefinition : StepDefinition

- (void) I_load_vgs_announcement;
- (void) vgs_announcement_amount_should_be_PARAMINT:(NSString*) size;
- (void) vgs_announcement_should_include_title_PARAM:(NSString*) title
                                     _and_body_PARAM:(NSString*) body;


@end
