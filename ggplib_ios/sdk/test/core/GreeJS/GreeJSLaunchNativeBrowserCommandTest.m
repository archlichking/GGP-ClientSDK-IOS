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
#import "GreeJSLaunchNativeBrowserCommand.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSLaunchNativeBrowserCommandTest)

describe(@"GreeJSLaunchNativeBrowserCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSLaunchNativeBrowserCommand name] should] equal:@"launch_native_browser"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSLaunchNativeBrowserCommand *command = [[GreeJSLaunchNativeBrowserCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSLaunchNativeBrowserCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should callback with an error if no URL is provided", ^{
      UIApplication *application = [UIApplication nullMock];
      [[application shouldNot] receive:@selector(openURL:)];
      [UIApplication stub:@selector(sharedApplication) andReturn:application];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:@"callback"
        params:[NSDictionary dictionaryWithObjectsAndKeys:@"-1", @"result", @"No URL Provided", @"error", nil]];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(handler) andReturn:handler];
      
      GreeJSLaunchNativeBrowserCommand *command = [[GreeJSLaunchNativeBrowserCommand alloc] init];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });
    
    it(@"should callback with an error if an invalid URL is provided", ^{
      UIApplication *application = [UIApplication nullMock];
      [[application shouldNot] receive:@selector(openURL:)];
      [UIApplication stub:@selector(sharedApplication) andReturn:application];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:@"callback"
        params:[NSDictionary dictionaryWithObjectsAndKeys:@"-1", @"result", @"Invalid URL Provided", @"error", nil]];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(handler) andReturn:handler];
      
      GreeJSLaunchNativeBrowserCommand *command = [[GreeJSLaunchNativeBrowserCommand alloc] init];
      command.environment = environment;
      [command execute:[NSDictionary dictionaryWithObject:@"###" forKey:@"URL"]];
      [command release];
    });

    it(@"should callback with an error if UIApplication can not open the URL", ^{
      UIApplication *application = [UIApplication nullMock];
      [[application shouldNot] receive:@selector(openURL:)];
      [[application stubAndReturn:theValue(NO)] canOpenURL:[NSURL URLWithString:@"mockURL://"]];
      [UIApplication stub:@selector(sharedApplication) andReturn:application];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:@"callback"
        params:[NSDictionary dictionaryWithObjectsAndKeys:@"-1", @"result", @"UIApplication could not open the URL", @"error", nil]];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(handler) andReturn:handler];
      
      GreeJSLaunchNativeBrowserCommand *command = [[GreeJSLaunchNativeBrowserCommand alloc] init];
      command.environment = environment;
      [command execute:[NSDictionary dictionaryWithObjectsAndKeys:@"mockURL://", @"URL", nil]];
      [command release];
    });

    it(@"should open the URL", ^{
      UIApplication *application = [UIApplication nullMock];
      [[application should] receive:@selector(openURL:)];
      [[application stubAndReturn:theValue(YES)] canOpenURL:[NSURL URLWithString:@"mockURL://"]];
      [UIApplication stub:@selector(sharedApplication) andReturn:application];
      
      GreeJSLaunchNativeBrowserCommand *command = [[GreeJSLaunchNativeBrowserCommand alloc] init];
      [command execute:[NSDictionary dictionaryWithObjectsAndKeys:@"mockURL://", @"URL", nil]];
      [command release];
    });
  });
});

SPEC_END
