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
    }else if (position == GreeWidgetPositionTopRight) {
        return @"top right";
    }else if (position == GreeWidgetPositionMiddleRight) {
        return @"middle right";
    }else if (position == GreeWidgetPositionBottomRight) {
        return @"bottom right";
    }else{
        return @"nothing";
    }
}

- (GreeWidgetPosition) stringToPosition:(NSString*) position{
    if ([position isEqualToString:@"top left"]) {
        return GreeWidgetPositionTopLeft;
    }else if ([position isEqualToString:@"middle left"]) {
        return GreeWidgetPositionMiddleLeft;
    }else if ([position isEqualToString:@"bottom left"]) {
        return GreeWidgetPositionBottomLeft;
    }else if ([position isEqualToString:@"top right"]) {
        return GreeWidgetPositionTopRight;
    }else if ([position isEqualToString:@"middle right"]) {
        return GreeWidgetPositionMiddleRight;
    }else if ([position isEqualToString:@"bottom right"]) {
        return GreeWidgetPositionBottomRight;
    }else{
        return -100;
    }
}

// step definition : i activate default widget
- (void) I_active_default_widget{
    id resultBlock = ^(GreeWidget* widget){
        [[self getBlockRepo] setObject:widget forKey:@"widget"];
        [self notifyInStep];
    };
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", getWidget], @"command",
                                        [NSString stringWithFormat:@"%i", GreeWidgetPositionBottomLeft], @"position",
                                        [NSString stringWithFormat:@"%i", NO], @"expandable",
                                        resultBlock, @"cmdCallback",
                                        nil];
    
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    [self waitForInStep];
}

// step definition : i activate widget with position P and expandable E
- (void) I_active_widget_with_position_PARAM:(NSString*) position 
                       _and_expandable_PARAM:(NSString*) expandable{
    id resultBlock = ^(GreeWidget* widget){
        [[self getBlockRepo] setObject:widget forKey:@"widget"];
        [self notifyInStep];
    };
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", getWidget], @"command",
                                        [NSString stringWithFormat:@"%i", [self stringToPosition:position]], @"position",
                                        [NSString stringWithFormat:@"%i", [expandable isEqualToString:@"YES"]?YES:NO], @"expandable",
                                        resultBlock, @"cmdCallback",
                                        nil];
    
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    [self waitForInStep];
}

// step definition : i hide widget
- (void) I_hide_widget{
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", hideWidget], @"command",
                                        nil];
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    [StepDefinition waitForOutsideStep];
}

// step definition : widget position should be P
- (void) widget_position_should_be_PARAM:(NSString*) value{
    GreeWidget* widget = [[self getBlockRepo] objectForKey:@"widget"];
    [QAAssert assertEqualsExpected:value Actual:[self positionToString:[widget position]]];
}

// step definition : widget expandable should be E
- (void) widget_expandable_should_be_PARAM:(NSString*) value{
    GreeWidget* widget = [[self getBlockRepo] objectForKey:@"widget"];
    
    [QAAssert assertEqualsExpected:value 
                            Actual:[widget expandable]?@"YES":@"NO"];
}

// step definition : i set widget position to P
- (void) I_set_widget_position_to_PARAM:(NSString*) position{
    GreeWidget* widget = [[self getBlockRepo] objectForKey:@"widget"];
    [widget setPosition:GreeWidgetPositionTopRight];
}

// step definition : i take screenshot
- (void) I_take_screenshot{
    [[self getBlockRepo] removeObjectForKey:@"screenshot"];
    GreeWidget* widget = [[self getBlockRepo] objectForKey:@"widget"];
    
    id resultBlock = ^(UIImage* shot){
        [[self getBlockRepo] setObject:shot forKey:@"screenshot"];
        [self notifyInStep];
    };
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", screenShotWidget], @"command",
                                        widget, @"widget",
                                        resultBlock, @"cmdCallback",
                                        nil];
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    [self waitForInStep];
}

// step definition : 
- (void) screenshot_should_be_correct{
//    UIImage* shot = [[self getBlockRepo] objectForKey:@"screenshot"];
}

@end
