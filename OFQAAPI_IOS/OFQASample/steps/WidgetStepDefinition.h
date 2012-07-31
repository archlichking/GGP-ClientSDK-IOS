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

- (void) I_active_widget_with_position_PARAM:(NSString*) position 
                       _and_expandable_PARAM:(NSString*) expandable;

@end
