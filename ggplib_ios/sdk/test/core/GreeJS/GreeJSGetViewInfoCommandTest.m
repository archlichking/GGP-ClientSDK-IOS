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
#import "GreeJSGetViewInfoCommand.h"
#import "GreePopup.h"
#import "GreeNotificationBoardViewController.h"
#import "GreeJSWebViewController.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSGetViewInfoCommandTest)

describe(@"GreeJSGetAppListCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSGetViewInfoCommand name] should] equal:@"get_view_info"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSGetViewInfoCommand *command = [[GreeJSGetViewInfoCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSGetViewInfoCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should report to the callback method that the environment's view controller is a popup, if it is", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"callback", @"callback",
        nil];
    
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:@"callback"
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          [NSDictionary dictionaryWithObjectsAndKeys:
            [parameters objectForKey:@"callback"], @"callback",
            @"popup", @"view",
            nil], @"result",
          nil]];

      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(handler) andReturn:handler];
      [environment stub:@selector(viewControllerForCommand:) andReturn:[GreePopup nullMock]];
      
      GreeJSGetViewInfoCommand *command = [[GreeJSGetViewInfoCommand alloc] init];
      command.environment = environment;
      [command execute:parameters];
      [command release];
    });
    
    it(@"should report to the callback method that the environment's view controller is a notification board, if it is", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"callback", @"callback",
        nil];
    
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:@"callback"
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          [NSDictionary dictionaryWithObjectsAndKeys:
            [parameters objectForKey:@"callback"], @"callback",
            @"notificationboard", @"view",
            nil], @"result",
          nil]];

      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(handler) andReturn:handler];
      [environment stub:@selector(viewControllerForCommand:) andReturn:[GreeNotificationBoardViewController nullMock]];
      
      GreeJSGetViewInfoCommand *command = [[GreeJSGetViewInfoCommand alloc] init];
      command.environment = environment;
      [command execute:parameters];
      [command release];
    });
    
    it(@"should report to the callback method that the environment's view controller is a dashboard, if it is a GreeJSWebViewController", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"callback", @"callback",
        nil];
    
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:@"callback"
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          [NSDictionary dictionaryWithObjectsAndKeys:
            [parameters objectForKey:@"callback"], @"callback",
            @"dashboard", @"view",
            nil], @"result",
          nil]];

      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(handler) andReturn:handler];
      [environment stub:@selector(viewControllerForCommand:) andReturn:[GreeJSWebViewController nullMock]];
      
      GreeJSGetViewInfoCommand *command = [[GreeJSGetViewInfoCommand alloc] init];
      command.environment = environment;
      [command execute:parameters];
      [command release];
    });
    
    it(@"should report to the callback method that the environment's view controller is a view controller, if it is none of the above", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"callback", @"callback",
        nil];
    
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:@"callback"
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          [NSDictionary dictionaryWithObjectsAndKeys:
            [parameters objectForKey:@"callback"], @"callback",
            @"viewcontroller", @"view",
            nil], @"result",
          nil]];

      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(handler) andReturn:handler];
      [environment stub:@selector(viewControllerForCommand:) andReturn:[UIViewController nullMock]];
      
      GreeJSGetViewInfoCommand *command = [[GreeJSGetViewInfoCommand alloc] init];
      command.environment = environment;
      [command execute:parameters];
      [command release];
    });
  });
});

SPEC_END
