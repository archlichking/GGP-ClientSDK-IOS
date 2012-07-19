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
#import "GreeJSReadConfigurationCommand.h"
#import "GreeWebAppCache.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSReadConfigurationCommandTest)

describe(@"GreeJSReadConfigurationCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSReadConfigurationCommand name] should] equal:@"readConfiguration"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSReadConfigurationCommand *command = [[GreeJSReadConfigurationCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSReadConfigurationCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should do nothing if the app parameter is not set", ^{
      GreeJSReadConfigurationCommand *command = [[GreeJSReadConfigurationCommand alloc] init];
      [[command shouldNot] receive:@selector(setResult:)];
      [command execute:nil];
      [command release];
    });

    it(@"should set the command results to the configuration", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockAppName", @"app",
        nil];
    
      GreeJSReadConfigurationCommand *command = [[GreeJSReadConfigurationCommand alloc] init];
      
      GreeWebAppCache *appCache = [GreeWebAppCache nullMock];
      [[appCache stubAndReturn:[NSURL URLWithString:@"mockURL://"]] baseURL];
      [[appCache stubAndReturn:theValue(1)] versionOfCachedContent];
      [[appCache stubAndReturn:theValue(YES)] synchronized];
      [[GreeWebAppCache stubAndReturn:appCache] appCacheForName:@"mockAppName"];
      
      [[[command should] receive] setResult:[NSDictionary dictionaryWithObjectsAndKeys:
        @"ios", @"platform",
        [[NSURL URLWithString:@"mockURL://"] absoluteString], @"baseURL",
        [NSNumber numberWithLongLong:1], @"cache_version",
        [NSNumber numberWithBool:YES], @"cache_synchronized",
        [NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithBool:YES], @"cache",
          nil], @"supports",
        nil] ];
      [command execute:parameters];
      [command release];
    });

  });
});

SPEC_END
