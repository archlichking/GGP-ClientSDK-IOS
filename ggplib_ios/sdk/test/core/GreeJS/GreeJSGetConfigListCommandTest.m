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
#import "GreeJSGetConfigListCommand.h"
#import "GreeSettings.h"
#import "GreePlatform+Internal.h"
#import "GreeMatchers.h"
#import "GreeTestHelpers.h"

@interface GreeSettings (ExposePrivateMethods)
- (NSMutableDictionary *)settings;
@end

SPEC_BEGIN(GreeJSGetConfigListCommandTest)

describe(@"GreeJSGetAppListCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSGetConfigListCommand name] should] equal:@"get_config_list"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSGetConfigListCommand *command = [[GreeJSGetConfigListCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSGetConfigListCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should callback with the gree settings paramters", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"callback", @"callback", nil];
      
      GreeSettings *settings = [GreeSettings nullMock];
      [[settings stubAndReturn:[NSDictionary dictionaryWithObjectsAndKeys:
        @"mockSetting1", @"mockSetting1",
        @"mockSetting2", @"mockSettings2",
        nil]] settings];
      
      GreePlatform *platform = [GreePlatform nullMockAsSharedInstance];
      [[platform stubAndReturn:settings] settings];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:[parameters objectForKey:@"callback"]
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          [NSDictionary dictionaryWithObjectsAndKeys:
            @"mockSetting1", @"mockSetting1",
            @"mockSetting2", @"mockSettings2",
            nil], @"result",
            nil]];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:handler] handler];
      
      GreeJSGetConfigListCommand *command = [[GreeJSGetConfigListCommand alloc] init];
      command.environment = environment;
      [command execute:parameters];
      [command release];
    });

    it(@"should remove any settings which are blacklisted", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"callback", @"callback", nil];
      
      GreeSettings *settings = [GreeSettings nullMock];
      [[settings stubAndReturn:[NSDictionary dictionaryWithObjectsAndKeys:
        @"mockSetting1", @"mockSetting1",
        @"mockSetting2", @"mockSettings2",
        nil]] settings];
      
      [[GreeSettings stubAndReturn:[NSArray arrayWithObject:@"mockSettings2"]] blackListForGetConfig];
      
      GreePlatform *platform = [GreePlatform nullMockAsSharedInstance];
      [[platform stubAndReturn:settings] settings];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:[parameters objectForKey:@"callback"]
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          [NSDictionary dictionaryWithObjectsAndKeys:
            @"mockSetting1", @"mockSetting1",
            nil], @"result",
            nil]];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:handler] handler];
      
      GreeJSGetConfigListCommand *command = [[GreeJSGetConfigListCommand alloc] init];
      command.environment = environment;
      [command execute:parameters];
      [command release];
    });
  });
});

SPEC_END
