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
#import "GreeJSGetConfigCommand.h"
#import "GreePlatform+Internal.h"
#import "GreeSettings.h"
#import "GreeTestHelpers.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSGetConfigCommandList)

describe(@"GreeJSGetConfigCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSGetConfigCommand name] should] equal:@"get_config"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSGetConfigCommand *command = [[GreeJSGetConfigCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSGetConfigCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should callback with the value of the key", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"callback", @"callback",
        @"mockKey", @"key",
        nil];
      
      GreeSettings *settings = [GreeSettings nullMock];
      [[settings stubAndReturn:@"mockValue"] stringValueForSetting:@"mockKey"];
      
      GreePlatform *platform = [GreePlatform nullMockAsSharedInstance];
      [[platform stubAndReturn:settings] settings];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:[parameters objectForKey:@"callback"]
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          @"mockValue", @"result",
          nil]];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:handler] handler];
      
      GreeJSGetConfigCommand *command = [[GreeJSGetConfigCommand alloc] init];
      command.environment = environment;
      [command execute:parameters];
      [command release];
    }); 

    it(@"should callback with nothing if the key is on the blacklist", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"callback", @"callback",
        @"mockKey", @"key",
        nil];
      
      GreeSettings *settings = [GreeSettings nullMock];
      [[settings stubAndReturn:@"mockValue"] stringValueForSetting:@"mockKey"];
      [[GreeSettings stubAndReturn:[NSArray arrayWithObject:@"mockKey"]] blackListForGetConfig];
      
      GreePlatform *platform = [GreePlatform nullMockAsSharedInstance];
      [[platform stubAndReturn:settings] settings];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:[parameters objectForKey:@"callback"]
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          [NSDictionary dictionary], @"result",
          nil]];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:handler] handler];
      
      GreeJSGetConfigCommand *command = [[GreeJSGetConfigCommand alloc] init];
      command.environment = environment;
      [command execute:parameters];
      [command release];
    });
  });
});

SPEC_END
