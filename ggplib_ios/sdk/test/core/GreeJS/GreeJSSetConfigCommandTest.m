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
#import "GreeJSSetConfigCommand.h"
#import "GreeSettings.h"
#import "GreePlatform+Internal.h"
#import "GreeMatchers.h"
#import "GreeTestHelpers.h"

SPEC_BEGIN(GreeJSSetConfigCommandTest)

describe(@"GreeJSSetConfigCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSSetConfigCommand name] should] equal:@"set_config"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSSetConfigCommand *command = [[GreeJSSetConfigCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSSetConfigCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should not do anything if the key is nil", ^{
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[handler shouldNot] receive:@selector(callback:params:)];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:handler] handler];
      
      GreeJSSetConfigCommand *command = [[GreeJSSetConfigCommand alloc] init];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });

    it(@"should not do anything if the key is on the blacklist", ^{
      NSArray *mockBlackList = [NSArray nullMock];
      [[mockBlackList stubAndReturn:theValue(YES)] containsObject:@"mockKey"];    
      [[GreeSettings stubAndReturn:mockBlackList] blackListForSetConfig];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[handler shouldNot] receive:@selector(callback:params:)];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:handler] handler];
      
      GreeJSSetConfigCommand *command = [[GreeJSSetConfigCommand alloc] init];
      command.environment = environment;
      [command execute:[NSDictionary dictionaryWithObjectsAndKeys:@"mockKey", @"key", nil]];
      [command release];
    });

    it(@"should callback with an empty dictionary if the value is nil", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"callback", @"callback",
        @"mockKey", @"key",
        nil];
      
      NSArray *mockBlackList = [NSArray nullMock];
      [[mockBlackList stubAndReturn:theValue(NO)] containsObject:@"mockKey"];    
      [[GreeSettings stubAndReturn:mockBlackList] blackListForSetConfig];
      
      GreeSettings *settings = [GreeSettings nullMock];
      [[settings stubAndReturn:[NSDictionary dictionary]] stringValueForSetting:@"mockKey"];
      
      GreePlatform *platform = [GreePlatform nullMockAsSharedInstance];
      [[platform stubAndReturn:settings] settings];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:[parameters objectForKey:@"callback"]
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          [NSDictionary dictionaryWithObjectsAndKeys:
            [NSDictionary dictionary], @"mockKey",
            nil], @"result",
          nil]];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:handler] handler];
      
      GreeJSSetConfigCommand *command = [[GreeJSSetConfigCommand alloc] init];
      command.environment = environment;
      [command execute:parameters];
      [command release];      
    });
    
    it(@"should callback with the value of the callback parameters", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"callback", @"callback",
        @"mockValue", @"value",
        @"mockKey", @"key",
        nil];
      
      NSArray *mockBlackList = [NSArray nullMock];
      [[mockBlackList stubAndReturn:theValue(NO)] containsObject:@"mockKey"];    
      [[GreeSettings stubAndReturn:mockBlackList] blackListForSetConfig];
      
      GreeSettings *settings = [GreeSettings nullMock];
      [[settings stubAndReturn:@"mockValue"] stringValueForSetting:@"mockKey"];
      
      GreePlatform *platform = [GreePlatform nullMockAsSharedInstance];
      [[platform stubAndReturn:settings] settings];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:[parameters objectForKey:@"callback"]
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          [NSDictionary dictionaryWithObjectsAndKeys:
            @"mockValue", @"mockKey",
            nil], @"result",
          nil]];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:handler] handler];
      
      GreeJSSetConfigCommand *command = [[GreeJSSetConfigCommand alloc] init];
      command.environment = environment;
      [command execute:parameters];
      [command release];      
    });
  });
});

SPEC_END
