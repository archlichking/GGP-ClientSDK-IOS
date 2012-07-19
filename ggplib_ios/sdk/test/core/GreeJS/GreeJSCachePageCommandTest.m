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
#import "GreeJSCachePageCommand.h"
#import "GreeMatchers.h"
#import "GreeWebAppCache.h"

SPEC_BEGIN(GreeJSCachePageCommandTest)

describe(@"GreeJSCachePageCommandTest",^{
  registerMatchers(@"Gree");

  it(@"should have a name", ^{
    [[[GreeJSCachePageCommand name] should] equal:@"cachePage"]; 
  });
  

  it(@"should have a description", ^{
    GreeJSCachePageCommand *command = [[GreeJSCachePageCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSCachePageCommand:0x[0-9a-f]+, environment:\\(null\\)"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should do nothing without an 'app' parameter", ^{
      NSDictionary *parameters = [NSDictionary dictionary];
      
      GreeJSCachePageCommand *command = [[GreeJSCachePageCommand alloc] init];
      [[command shouldNot] receive:@selector(setResult:)];
      [command execute:parameters];
      [command release];
    });

    it(@"should do nothing without a 'version' parameter", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"name", @"app", nil];
      
      GreeJSCachePageCommand *command = [[GreeJSCachePageCommand alloc] init];
      [[command shouldNot] receive:@selector(setResult:)];
      [command execute:parameters];
      [command release];
    });

    it(@"should update the app cache", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"name", @"app",
        [NSNumber numberWithUnsignedInteger:1], @"version",
        nil];
        
      GreeWebAppCache *appCache = [GreeWebAppCache nullMock];
      [[appCache should] receive:@selector(updateCacheItem:withContent:version:)];
      [GreeWebAppCache stub:@selector(appCacheForName:) andReturn:appCache];
      
      GreeJSCachePageCommand *command = [[GreeJSCachePageCommand alloc] init];
      [[command should] receive:@selector(setResult:)];
      [command execute:parameters];
      [command release];
    });
  });
});

SPEC_END
