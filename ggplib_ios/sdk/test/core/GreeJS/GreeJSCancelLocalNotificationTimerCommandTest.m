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
#import "GreeJSCancelLocalNotificationTimerCommand.h"
#import "GreeLocalNotification.h"
#import "GreeMatchers.h"
#import "GreeTestHelpers.h"

SPEC_BEGIN(GreeJSCancelLocalNotificationTimerCommandTest)

describe(@"GreeJSCancelLocalNotificationTimerCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSCancelLocalNotificationTimerCommand name] should] equal:@"cancel_local_notification_timer"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSCancelLocalNotificationTimerCommand *command = [[GreeJSCancelLocalNotificationTimerCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSCancelLocalNotificationTimerCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should return an error message if the command is cancelled", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"callback", @"callback",
        [NSNumber numberWithInteger:1], @"notifyId",
        nil];
    
      GreeJSCancelLocalNotificationTimerCommand *command = [[GreeJSCancelLocalNotificationTimerCommand alloc] init];
    
      GreeLocalNotification *localNotification = [GreeLocalNotification nullMock];
      [[localNotification stubAndReturn:theValue(NO)] cancelNotification:[NSNumber numberWithInteger:1]];
      
      GreePlatform *platform = [GreePlatform nullMockAsSharedInstance];
      [[platform stubAndReturn:localNotification] localNotification];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:@"callback"
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          @"error", @"result",
          nil]];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:handler] handler];
      
      command.environment = environment;
      [command execute:parameters];
      [command release];
    });
    
    it(@"should return the 'cancelled' result if the command is cancelled", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"callback", @"callback",
        [NSNumber numberWithInteger:1], @"notifyId",
        nil];
    
      GreeJSCancelLocalNotificationTimerCommand *command = [[GreeJSCancelLocalNotificationTimerCommand alloc] init];
    
      GreeLocalNotification *localNotification = [GreeLocalNotification nullMock];
      [[localNotification stubAndReturn:theValue(YES)] cancelNotification:[NSNumber numberWithInteger:1]];
      
      GreePlatform *platform = [GreePlatform nullMockAsSharedInstance];
      [[platform stubAndReturn:localNotification] localNotification];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:@"callback"
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          @"cancelled", @"result",
          nil]];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:handler] handler];
      
      command.environment = environment;
      [command execute:parameters];
      [command release];
    });
  });
});

SPEC_END
