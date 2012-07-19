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
#import "GreeJSNotifyServiceResultCommand.h"
#import "GreePopup+Internal.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSNotifyServiceResultCommandList)

describe(@"GreeJSNotifyServiceResultCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSNotifyServiceResultCommand name] should] equal:@"notify_service_result"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSNotifyServiceResultCommand *command = [[GreeJSNotifyServiceResultCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSNotifyServiceResultCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"while executing", ^{
    it(@"should do nothing without an action parameters", ^{
      GreeJSNotifyServiceResultCommand *command = [[GreeJSNotifyServiceResultCommand alloc] init];
    
      GreePopup *popup = [GreePopup nullMock];
      [[popup shouldNot] receive:@selector(reloadWithParameters:)];
    
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:popup] viewControllerForCommand:command];
      
      command.environment = environment;
      [command execute:nil];
      [command release];
    });
    
    it(@"should reload the popup if the reload action is passed", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"reload", @"action",
        nil];
      
      GreeJSNotifyServiceResultCommand *command = [[GreeJSNotifyServiceResultCommand alloc] init];
    
      GreePopup *popup = [GreePopup nullMock];
      [[[popup should] receive] reloadWithParameters:parameters];
    
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:popup] viewControllerForCommand:command];
      
      command.environment = environment;
      [command execute:parameters];
      [command release];      
    });
  });
});

SPEC_END
