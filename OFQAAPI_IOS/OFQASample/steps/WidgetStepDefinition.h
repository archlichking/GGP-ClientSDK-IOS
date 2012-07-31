//
//  WidgetStepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 7/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StepDefinition.h"

@interface WidgetStepDefinition : StepDefinition

- (void) I_active_default_widget;
- (void) I_hide_widget;

- (void) widget_position_should_be_PARAM:(NSString*) value;
- (void) widget_expandable_should_be_PARAM:(NSString*) value;

- (void) I_set_widget_position_to_PARAM:(NSString*) position;

@end
