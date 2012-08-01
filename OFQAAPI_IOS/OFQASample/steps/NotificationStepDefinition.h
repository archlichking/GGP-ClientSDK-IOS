//
//  NotificationStepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StepDefinition.h"

@interface NotificationStepDefinition : StepDefinition

//--- begin -------- notification
- (void) I_set_notification_with_type_PARAM:(NSString*) type 
                         _and_message_PARAM:(NSString*) message 
                     _and_duration_PARAMINT:(NSString*) period;

- (void) I_set_notification_queue_with_notification_PARAM:(NSString*) isEnabled 
                              _and_display_position_PARAM:(NSString*) position;

- (void) I_push_notification;

- (void) notification_queue_should_have_notifications_of_size_PARAMINT:(NSString*) size;
- (void) notification_queue_should_have_notification_with_message_PARAM:(NSString*) message;

//--- end ----------- notification
//--- begin --------- local notificaiton

- (void) I_initialize_local_notification_with_TITLE_PARAM:(NSString*) title 
                                          _and_BODY_PARAM:(NSString*) body 
                                      _and_BARTITLE_PARAM:(NSString*) bartitle 
                                   _and_INTERVAL_PARAMINT:(NSString*) intv 
                                            _and_ID_PARAM:(NSString*) lnid 
                                 _and_CALLBACKPARAM_PARAM:(NSString*) param;

- (void) I_push_local_notification;

//--- end ----------- local notification

@end
