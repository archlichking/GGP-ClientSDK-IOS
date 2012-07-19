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
#import "GreeJSGetLocalNotificationEnabledCommand.h"
#import "GreeLocalNotification.h"
#import "GreeMatchers.h"
#import "GreeTestHelpers.h"

SPEC_BEGIN(GreeJSGetLocalNotificationEnabledCommandTest)

describe(@"GreeJSGetLocalNotificationEnabledCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSGetLocalNotificationEnabledCommand name] should] equal:@"get_local_notification_enabled"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSGetLocalNotificationEnabledCommand *command = [[GreeJSGetLocalNotificationEnabledCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSGetLocalNotificationEnabledCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should return a false string if notifications are not enabled", ^{
      GreeJSGetLocalNotificationEnabledCommand *command = [[GreeJSGetLocalNotificationEnabledCommand alloc] init];
      
      GreeLocalNotification *localNotification = [GreeLocalNotification nullMock];
      [[localNotification stubAndReturn:theValue(NO)] localNotificationsEnabled];
      
      GreePlatform *platform = [GreePlatform nullMockAsSharedInstance];
      [[platform stubAndReturn:localNotification] localNotification];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:nil
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          @"false", @"enabled",
          nil]];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:handler] handler];
      
      command.environment = environment;
      [command execute:nil];
      [command release];
    });

    it(@"should return a true string if notifications are enabled", ^{
      GreeJSGetLocalNotificationEnabledCommand *command = [[GreeJSGetLocalNotificationEnabledCommand alloc] init];
      
      GreeLocalNotification *localNotification = [GreeLocalNotification nullMock];
      [[localNotification stubAndReturn:theValue(YES)] localNotificationsEnabled];
      
      GreePlatform *platform = [GreePlatform nullMockAsSharedInstance];
      [[platform stubAndReturn:localNotification] localNotification];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:nil
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          @"true", @"enabled",
          nil]];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:handler] handler];
      
      command.environment = environment;
      [command execute:nil];
      [command release];
    });
  });
});

SPEC_END
