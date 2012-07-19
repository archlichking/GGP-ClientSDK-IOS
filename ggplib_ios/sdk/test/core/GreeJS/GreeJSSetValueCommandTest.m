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
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSSetValueCommandTest)

describe(@"GreeJSSetValueCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSSetValueCommand name] should] equal:@"set_value"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSSetValueCommand *command = [[GreeJSSetValueCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSSetValueCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should set the value of the NSUserDefault for the given keypath", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockKey", kGreeJSSetValueParamsKey,
        @"mockValue", kGreeJSSetValueParamsValue,
        nil];
    
      NSUserDefaults *userDefaults = [NSUserDefaults nullMock];
      [[[userDefaults should] receive]
        setObject:@"mockValue"
        forKey:[GreeJSSetValueCommand userDefaultsPathForKey:@"mockKey"]];
      [[NSUserDefaults stubAndReturn:userDefaults] standardUserDefaults];
      
      GreeJSSetValueCommand *command = [[GreeJSSetValueCommand alloc] init];
      [command execute:parameters];
      [command release];
    });
  });
});

SPEC_END
