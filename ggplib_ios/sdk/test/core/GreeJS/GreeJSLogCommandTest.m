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
#import "GreeJSLogCommand.h"
#import "GreeMatchers.h"
#import "GreeWebAppCacheLog.h"

SPEC_BEGIN(GreeJSLogCommandTest)

describe(@"GreeJSLogCommandTest",^{
  registerMatchers(@"Gree");

  it(@"should have a name", ^{
    [[[GreeJSLogCommand name] should] equal:@"log"]; 
  });
  

  it(@"should have a description", ^{
    GreeJSLogCommand *command = [[GreeJSLogCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSLogCommand:0x[0-9a-f]+, environment:\\(null\\)"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should write the text to the web cache log", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"mockText", @"text",nil];
      
      [GreeWebAppCacheLog stub:@selector(log:)];
      [[GreeWebAppCacheLog should] receive:@selector(log:)];
      
      GreeJSLogCommand *command = [[GreeJSLogCommand alloc] init];
      [command execute:parameters];
      [command release];
    });
  });
});

SPEC_END
