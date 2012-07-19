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
#import "GreeJSClearCacheCommand.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSClearCacheCommandTest)

describe(@"GreeJSClearCacheCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSClearCacheCommand name] should] equal:@"clearCache"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSClearCacheCommand *command = [[GreeJSClearCacheCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSClearCacheCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  it(@"should execute", ^{
    GreeJSClearCacheCommand *command = [[GreeJSClearCacheCommand alloc] init];
    [command execute:nil];
    [command release];
  });
});

SPEC_END
