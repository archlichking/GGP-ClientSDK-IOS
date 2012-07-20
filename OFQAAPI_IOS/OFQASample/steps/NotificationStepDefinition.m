//
//  NotificationStepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NotificationStepDefinition.h"
#import "GreeNotification.h"
#import "GreeNotificationQueue.h"
#import "GreeLocalNotification.h"
#import "GreeSettings.h"

#import "QAAssert.h"

@implementation NotificationStepDefinition

- (void) I_set_notification_with_type_PARAM:(NSString*) type 
                         _and_message_PARAM:(NSString*) message 
                     _and_duration_PARAMINT:(NSString*) period{
    GreeNotificationViewDisplayType displayType = [type isEqualToString:@"default"]?GreeNotificationViewDisplayCloseType:GreeNotificationViewDisplayCloseType;
    
    GreeNotification* notification = [[GreeNotification alloc] initWithMessage:message 
                                                                   displayType:displayType 
                                                                      duration:[period intValue]];
    
    [[self getBlockRepo] setObject:notification forKey:@"notification"];
}

- (void) I_set_notification_queue_with_notification_PARAM:(NSString*) isEnabled 
                              _and_display_position_PARAM:(NSString*) position{
    
    BOOL IsNotificationEnabled = [isEnabled isEqualToString:@"enabled"]?YES:NO;
    GreeNotificationDisplayPosition displayPosition = [position isEqualToString:@"bottom"]?GreeNotificationDisplayBottomPosition:GreeNotificationDisplayTopPosition;
    
    
    NSDictionary* settingsValues = [NSDictionary 
                                    dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:displayPosition], @"notificationPosition",
                                    [NSNumber numberWithBool:IsNotificationEnabled], @"notificationEnabled",
                                    nil];
    GreeSettings* settings = [[GreeSettings alloc] init];
    [settings applySettingDictionary:settingsValues];
    
    GreeNotificationQueue* notificationQueue = [[GreeNotificationQueue alloc] initWithSettings:settings];
    
    [[self getBlockRepo] setObject:notificationQueue forKey:@"notificationQueue"];
    
}

- (void) I_push_notification{
    GreeNotificationQueue* notificationQueue = [[self getBlockRepo] objectForKey:@"notificationQueue"];
    GreeNotification* notification = [[self getBlockRepo] objectForKey:@"notification"];
    
    [notificationQueue addNotification:notification];
}

- (void) notification_queue_should_have_notifications_of_size_PARAMINT:(NSString*) size{
    GreeNotificationQueue* notificationQueue = [[self getBlockRepo] objectForKey:@"notificationQueue"];
    NSArray* notifications =  (NSArray*)[notificationQueue valueForKeyPath:@"notifications"];
    
    [QAAssert assertEqualsExpected:size
                            Actual:[NSString stringWithFormat:@"%i", [notifications count]]];
}

- (void) notification_queue_should_have_notification_with_message_PARAM:(NSString*) message{
    GreeNotificationQueue* notificationQueue = [[self getBlockRepo] objectForKey:@"notificationQueue"];
    NSArray* notifications =  (NSArray*)[notificationQueue valueForKeyPath:@"notifications"];
    for (GreeNotification* notification in notifications) {
        if ([[notification message] isEqualToString:message]) {
            [QAAssert assertEqualsExpected:message
                                    Actual:[notification message]];
            return;
        }
    }
    [QAAssert assertEqualsExpected:message
                            Actual:@"nil"
                       WithMessage:[NSString stringWithFormat:@"notification with message %@ isn't in notification queue", message]];
}
@end
