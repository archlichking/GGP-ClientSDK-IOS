//
//  AnnouncementStepDefinition.h
//  QAAutoSample
//
//  Created by zhu lei on 11/19/12.
//  Copyright (c) 2012 OFQA. All rights reserved.
//

#import "StepDefinition.h"

@interface VGAnnouncementStepDefinition : StepDefinition

- (void) developer_uses_SDK_to_load_vgs_announcements;
- (void) vgs_announcement_amount_should_be_PARAMINT:(NSString*) size;
- (void) vgs_announcement_should_include_title_PARAM:(NSString*) title
                                     _and_body_PARAM:(NSString*) body;

- (void) developer_uses_SDK_to_check_basic_info_of_announcement_with_title_PARAM:(NSString*) title;
- (void) info_PARAM:(NSString*) info _of_announcement_PARAM:(NSString*) title
   _should_be_PARAM:(NSString*) content;


@end
