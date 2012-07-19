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
#import "GreeJSGetAppInfoCommand.h"
#import "GreeSettings.h"
#import "GreePlatform.h"
#import "GreeMatchers.h"
#import "GreeTestHelpers.h"

SPEC_BEGIN(GreeJSGetAppInfoCommandTest)

describe(@"GreeJSGetAppInfoCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSGetAppInfoCommand name] should] equal:@"get_app_info"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSGetAppInfoCommand *command = [[GreeJSGetAppInfoCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSGetAppInfoCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should callback", ^{
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[handler should] receive:@selector(callback:params:)];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(handler) andReturn:handler];
      
      GreeJSGetAppInfoCommand *command = [[GreeJSGetAppInfoCommand alloc] init];
      command.environment = environment;
      [command execute:nil];
      [command release];
      
    });
  });
});

SPEC_END
