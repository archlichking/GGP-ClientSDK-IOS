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
#import "GreeJSRegisterLocalNotificationTimerCommand.h"
#import "GreeLocalNotification.h"
#import "GreeMatchers.h"
#import "GreeTestHelpers.h"

SPEC_BEGIN(GreeJSRegisterLocalNotificationTimerCommandTest)

describe(@"GreeJSRegisterLocalNotificationTimerCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSRegisterLocalNotificationTimerCommand name] should] equal:@"register_local_notification_timer"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSRegisterLocalNotificationTimerCommand *command = [[GreeJSRegisterLocalNotificationTimerCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSRegisterLocalNotificationTimerCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should return an error result if the notification was not registered", ^{      
      GreeJSRegisterLocalNotificationTimerCommand *command = [[GreeJSRegisterLocalNotificationTimerCommand alloc] init];
      
      GreeLocalNotification *localNotification = [GreeLocalNotification nullMock];
      [localNotification stub:@selector(registerLocalNotificationWithDictionary:) andReturn:theValue(NO)];
      
      GreePlatform *platform = [GreePlatform nullMockAsSharedInstance];
      [[platform stubAndReturn:localNotification] localNotification];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:nil
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          @"error", @"result",
          nil]];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:handler] handler];
      
      command.environment = environment;
      [command execute:nil];
      [command release];
    });

    it(@"should return an registered result if the notification was registered", ^{      
      GreeJSRegisterLocalNotificationTimerCommand *command = [[GreeJSRegisterLocalNotificationTimerCommand alloc] init];
      
      GreeLocalNotification *localNotification = [GreeLocalNotification nullMock];
      [localNotification stub:@selector(registerLocalNotificationWithDictionary:) andReturn:theValue(YES)];
      
      GreePlatform *platform = [GreePlatform nullMockAsSharedInstance];
      [[platform stubAndReturn:localNotification] localNotification];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:nil
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          @"registered", @"result",
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
