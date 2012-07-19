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
#import "GreeJSGetAppListCommand.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSGetAppListCommandTest)

describe(@"GreeJSGetAppListCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSGetAppListCommand name] should] equal:@"get_app_list"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSGetAppListCommand *command = [[GreeJSGetAppListCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSGetAppListCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should add url which can be opened to a list and pass the list to the callback method", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSArray arrayWithObjects:@"mockURL1", @"mockURL2", nil], @"schemes",
        @"callback", @"callback",
        nil];
    
      UIApplication *application = [UIApplication nullMock];
      [[application stubAndReturn:theValue(YES)] canOpenURL:[NSURL URLWithString:@"mockURL1://"]];
      [[application stubAndReturn:theValue(YES)] canOpenURL:[NSURL URLWithString:@"mockURL2://"]];
      [[UIApplication stubAndReturn:application] sharedApplication];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:@"callback"
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          [NSDictionary dictionaryWithObjectsAndKeys:
            [parameters objectForKey:@"schemes"], @"schemes",
            [parameters objectForKey:@"callback"], @"callback",
            [NSArray arrayWithObjects:@"mockURL1", @"mockURL2", nil], @"result",
            nil], @"result",
          nil]];

      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(handler) andReturn:handler];
      
      GreeJSGetAppListCommand *command = [[GreeJSGetAppListCommand alloc] init];
      command.environment = environment;
      [command execute:parameters];
      [command release];
    });

    it(@"should not add a url which cannot be opened to the list and pass the list to the callback method", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSArray arrayWithObjects:@"mockURL1", @"mockURL2", nil], @"schemes",
        @"callback", @"callback",
        nil];
    
      UIApplication *application = [UIApplication nullMock];
      [[application stubAndReturn:theValue(YES)] canOpenURL:[NSURL URLWithString:@"mockURL1://"]];
      [[application stubAndReturn:theValue(NO)] canOpenURL:[NSURL URLWithString:@"mockURL2://"]];
      [[UIApplication stubAndReturn:application] sharedApplication];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:@"callback"
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          [NSDictionary dictionaryWithObjectsAndKeys:
            [parameters objectForKey:@"schemes"], @"schemes",
            [parameters objectForKey:@"callback"], @"callback",
            [NSArray arrayWithObjects:@"mockURL1", nil], @"result",
            nil], @"result",
          nil]];

      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(handler) andReturn:handler];
      
      GreeJSGetAppListCommand *command = [[GreeJSGetAppListCommand alloc] init];
      command.environment = environment;
      [command execute:parameters];
      [command release];
    });
  });
});

SPEC_END
