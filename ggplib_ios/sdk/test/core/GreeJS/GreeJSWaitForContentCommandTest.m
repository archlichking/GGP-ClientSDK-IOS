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
#import "GreeJSWaitForContentCommand.h"
#import "GreeWebAppCache.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSWaitForContentCommandTest)

describe(@"GreeJSWaitForContentCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSWaitForContentCommand name] should] equal:@"waitForContent"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSWaitForContentCommand *command = [[GreeJSWaitForContentCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSWaitForContentCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  it(@"should set the URL to load to the value in the url parameter, relative to the appCache url", ^{
    GreeJSWaitForContentCommand *command = [[GreeJSWaitForContentCommand alloc] init];
    command.appName = @"mockAppName";
  
    GreeWebAppCache *appCache = [GreeWebAppCache nullMock];
    [[appCache stubAndReturn:[NSURL URLWithString:@"mockURL://"]] baseURL];
    [[GreeWebAppCache stubAndReturn:appCache] appCacheForName:@"mockAppName"];
      
    [[[command urlToLoadWithParams:[NSDictionary dictionaryWithObjectsAndKeys:
      @"mockComponent", @"url",
      nil]] should] equal:[NSURL URLWithString:@"mockComponent" relativeToURL:[NSURL URLWithString:@"mockURL://"]]];
    [command release];
  });
});

SPEC_END
