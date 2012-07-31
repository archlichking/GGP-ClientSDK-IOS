//
//  WidgetStepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 7/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WidgetStepDefinition.h"

#import "Constant.h"
#import "StringUtil.h"
#import "CommandUtil.h"
#import "QAAssert.h"

#import "GreeWidget.h"
#import "GreeSettings.h"

@interface GreeWidget()
- (id)initWithSettings:(GreeSettings*)settings;
@end

@implementation WidgetStepDefinition

- (NSString*) positionToString:(GreeWidgetPosition) position{
    if (position == GreeWidgetPositionTopLeft) {
        return @"top left";
    }else if (position == GreeWidgetPositionMiddleLeft) {
        return @"middle left";
    }else if (position == GreeWidgetPositionBottomLeft) {
        return @"bottom left";
    }else if (position == GreeWidgetPositionTopLeft) {
        return @"top right";
    }else if (position == GreeWidgetPositionMiddleRight) {
        return @"middle right";
    }else if (position == GreeWidgetPositionBottomRight) {
        return @"bottom right";
    }else{
        return @"nothing";
    }
}

- (void) I_active_default_widget{
    id resultBlock = ^(GreeWidget* widget){
        [[self getBlockRepo] setObject:widget forKey:@"widget"];
        [self notifyInStep];
    };
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", getWidget], @"command",
                                        resultBlock, @"cmdCallback",
                                        nil];
    
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    [self waitForInStep];
}

- (void) I_hide_widget{
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", hideWidget], @"command",
                                        nil];
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    [StepDefinition waitForOutsideStep];
}

- (void) widget_position_should_be_PARAM:(NSString*) value{
    GreeWidget* widget = [[self getBlockRepo] objectForKey:@"widget"];
    [QAAssert assertEqualsExpected:value Actual:[self positionToString:[widget position]]];
}

- (void) widget_expandable_should_be_PARAM:(NSString*) value{
    GreeWidget* widget = [[self getBlockRepo] objectForKey:@"widget"];
    
    [QAAssert assertEqualsExpected:value 
                            Actual:[widget expandable]?@"YES":@"NO"];
}

- (void) I_set_widget_position_to_PARAM:(NSString*) position{
    GreeWidget* widget = [[self getBlockRepo] objectForKey:@"widget"];
    [widget setPosition:GreeWidgetPositionTopRight];
}

@end
