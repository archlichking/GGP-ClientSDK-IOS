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

// step definition : i set notification with type T and message M and duration D
- (void) I_set_notification_with_type_PARAM:(NSString*) type 
                         _and_message_PARAM:(NSString*) message 
                     _and_duration_PARAMINT:(NSString*) period{
    GreeNotificationViewDisplayType displayType = [type isEqualToString:@"default"]?GreeNotificationViewDisplayCloseType:GreeNotificationViewDisplayCloseType;
    
    GreeNotification* notification = [[GreeNotification alloc] initWithMessage:message 
                                                                   displayType:displayType 
                                                                      duration:[period intValue]];
    
    [[self getBlockRepo] setObject:notification forKey:@"notification"];
}

// step definition : i set notification queue with notification E and display position P
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

// step definition : i push notification
- (void) I_push_notification{
    GreeNotificationQueue* notificationQueue = [[self getBlockRepo] objectForKey:@"notificationQueue"];
    GreeNotification* notification = [[self getBlockRepo] objectForKey:@"notification"];
    
    [notificationQueue addNotification:notification];
}

// step definition : notification queue should have notifications of size S
- (void) notification_queue_should_have_notifications_of_size_PARAMINT:(NSString*) size{
    GreeNotificationQueue* notificationQueue = [[self getBlockRepo] objectForKey:@"notificationQueue"];
    NSArray* notifications = (NSArray*)[notificationQueue valueForKeyPath:@"notifications"];
    
    [QAAssert assertEqualsExpected:size
                            Actual:[NSString stringWithFormat:@"%i", [notifications count]]];
}

// step definition : notification queue should have notification with message M
- (void) notification_queue_should_have_notification_with_message_PARAM:(NSString*) message{
    GreeNotificationQueue* notificationQueue = [[self getBlockRepo] objectForKey:@"notificationQueue"];
    NSArray* notifications =  (NSArray*)[notificationQueue valueForKeyPath:@"notifications"];
    for (GreeNotification* notification in notifications) {
        if ([[notification message] isEqualToString:message]) {
            [QAAssert assertEqualsExpected:message
                                    Actual:[notification message]];
//            [notification release];
//            [notificationQueue release];
            return;
        }
    }
    [QAAssert assertEqualsExpected:message
                            Actual:@"nil"
                       WithMessage:[NSString stringWithFormat:@"notification with message %@ isn't in notification queue", message]];
}

//--- begin --------- local notificaiton
// step definition : i initialize local notification with title T and body B and bartitle BT and interval I and id ID and callbackparam P
- (void) I_initialize_local_notification_with_TITLE_PARAM:(NSString*) title 
                                          _and_BODY_PARAM:(NSString*) body 
                                      _and_BARTITLE_PARAM:(NSString*) bartitle 
                                   _and_INTERVAL_PARAMINT:(NSString*) intv 
                                            _and_ID_PARAM:(NSString*) lnid 
                                 _and_CALLBACKPARAM_PARAM:(NSString*) param{
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * notificationID = [f numberFromString:lnid];
    [f release];
    
    NSDate* now = [NSDate date];
    NSDate* intvDate = [now dateByAddingTimeInterval:[intv intValue]];
        
    NSDictionary* settingsValues = [NSDictionary 
                                    dictionaryWithObjectsAndKeys:
                                    title, @"message",
                                    intvDate, @"interval",
                                    notificationID, @"notifyId",
                                    param, @"callbackParam",
                                    nil];

    [[GreeLocalNotification alloc] registerLocalNotificationWithDictionary:settingsValues];
}

// step definition : I push local notification
- (void) I_push_local_notification{
//    GreeLocalNotification* notification = [[GreePlatform sharedInstance] localNotification];
    
}

//--- end ----------- local notification



@end
