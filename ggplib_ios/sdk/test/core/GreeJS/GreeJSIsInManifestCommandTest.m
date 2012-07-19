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
#import "GreeJSIsInManifestCommand.h"
#import "GreeMatchers.h"
#import "GreeWebAppCache.h"

SPEC_BEGIN(GreeJSIsInManifestCommandTest)

describe(@"GreeJSIsInManifestCommandTest",^{
  registerMatchers(@"Gree");

  it(@"should have a name", ^{
    [[[GreeJSIsInManifestCommand name] should] equal:@"isInManifest"]; 
  });
  

  it(@"should have a description", ^{
    GreeJSIsInManifestCommand *command = [[GreeJSIsInManifestCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSIsInManifestCommand:0x[0-9a-f]+, environment:\\(null\\)"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should do nothing without an 'app' parameter", ^{
      NSDictionary *parameters = [NSDictionary dictionary];
      
      GreeJSIsInManifestCommand *command = [[GreeJSIsInManifestCommand alloc] init];
      [[command shouldNot] receive:@selector(setResult:)];
      [command execute:parameters];
      [command release];
    });

    it(@"should return YES, a URL is in the manifest, if the cache says it is", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"appName", @"app",
        @"fakeURL://", @"url",
        nil];
      
      GreeWebAppCache *appCache = [GreeWebAppCache nullMock];
      [appCache stub:@selector(isURLInManifest:) andReturn:theValue(YES)];
      [GreeWebAppCache stub:@selector(appCacheForName:) andReturn:appCache];
      
      GreeJSIsInManifestCommand *command = [[GreeJSIsInManifestCommand alloc] init];
      [command execute:parameters];
      [[[command.result objectAtIndex:0] should] equal:theValue(YES)];
      [[[command.result objectAtIndex:1] should] equal:[[NSURL URLWithString:@"fakeURL://" relativeToURL:nil] absoluteString]];
      [command release];      
    });
    
    it(@"should return NO, a URL is not in the manifest, if the cache says it is not", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"appName", @"app",
        @"fakeURL://", @"url",
        nil];
      
      GreeWebAppCache *appCache = [GreeWebAppCache nullMock];
      [appCache stub:@selector(isURLInManifest:) andReturn:theValue(NO)];
      [GreeWebAppCache stub:@selector(appCacheForName:) andReturn:appCache];
      
      GreeJSIsInManifestCommand *command = [[GreeJSIsInManifestCommand alloc] init];
      [command execute:parameters];
      [[[command.result objectAtIndex:0] should] equal:theValue(NO)];
      [[[command.result objectAtIndex:1] should] equal:[[NSURL URLWithString:@"fakeURL://" relativeToURL:nil] absoluteString]];
      [command release];      
    });
  });
});

SPEC_END
