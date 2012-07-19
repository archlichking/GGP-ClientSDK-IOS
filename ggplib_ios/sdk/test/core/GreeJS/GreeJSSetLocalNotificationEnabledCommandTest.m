//
// Copyright 2012 GREE, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Kiwi.h"
#import "GreeJSSetLocalNotificationEnabledCommand.h"
#import "GreeLocalNotification.h"
#import "GreeMatchers.h"
#import "GreeTestHelpers.h"

SPEC_BEGIN(GreeJSSetLocalNotificationEnabledCommandTest)

describe(@"GreeJSSetLocalNotificationEnabledCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSSetLocalNotificationEnabledCommand name] should] equal:@"set_local_notification_enabled"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSSetLocalNotificationEnabledCommand *command = [[GreeJSSetLocalNotificationEnabledCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSSetLocalNotificationEnabledCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should enable local notifications if the enabled parameter is yes", ^{
      GreeJSSetLocalNotificationEnabledCommand *command = [[GreeJSSetLocalNotificationEnabledCommand alloc] init];
      
      GreeLocalNotification *localNotification = [GreeLocalNotification nullMock];
      [[[localNotification should] receive] setLocalNotificationsEnabled:YES];
      
      GreePlatform *platform = [GreePlatform nullMockAsSharedInstance];
      [[platform stubAndReturn:localNotification] localNotification];
      
      [command execute:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"enabled"]];
      [command release];
    });

    it(@"should return a true string if notifications are enabled", ^{
      GreeJSSetLocalNotificationEnabledCommand *command = [[GreeJSSetLocalNotificationEnabledCommand alloc] init];
      
      GreeLocalNotification *localNotification = [GreeLocalNotification nullMock];
      [[[localNotification should] receive] setLocalNotificationsEnabled:NO];
      
      GreePlatform *platform = [GreePlatform nullMockAsSharedInstance];
      [[platform stubAndReturn:localNotification] localNotification];
      
      [command execute:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"enabled"]];
      [command release];
    });
  });
});

SPEC_END
