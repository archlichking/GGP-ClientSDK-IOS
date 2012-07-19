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
#import "GreeJSSetValueCommand.h"
#import "GreeJSGetValueCommand.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSGetValueCommandTest)

describe(@"GreeJSGetValueCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSGetValueCommand name] should] equal:@"get_value"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSGetValueCommand *command = [[GreeJSGetValueCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSGetValueCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should callback with the value stored in the NSUserDefaults", ^{
      GreeJSGetValueCommand *command = [[GreeJSGetValueCommand alloc] init];
      
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"callback", @"callback",
        @"mockKey", kGreeJSSetValueParamsKey,
        nil];
    
      [[GreeJSSetValueCommand stubAndReturn:@"mockKeyPath"] userDefaultsPathForKey:@"mockKey"];
    
      NSUserDefaults *userDefaults = [NSUserDefaults nullMock];
      [[userDefaults stubAndReturn:@"mockReturnValue"] objectForKey:@"mockKeyPath"];
      [[NSUserDefaults stubAndReturn:userDefaults] standardUserDefaults];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:@"callback"
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          @"callback", @"callback",
          @"mockKey", kGreeJSSetValueParamsKey,
          @"mockReturnValue", kGreeJSSetValueParamsValue,
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
