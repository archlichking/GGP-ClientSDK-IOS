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
#import "GreeJSLaunchServiceCommand.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSLaunchServiceCommandTest)

describe(@"GreeJSLaunchServiceCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSLaunchServiceCommand name] should] equal:@"launch_service"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSLaunchServiceCommand *command = [[GreeJSLaunchServiceCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSLaunchServiceCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"when the target is self it should load the url its environment's web view", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSDictionary dictionaryWithObjectsAndKeys:@"mockURL://", @"URL", nil], @"params",
        @"self", @"target",
        nil];
      
      UIWebView *webView = [UIWebView nullMock];
      [[[webView should] receive] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"mockURL://"]]];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(webviewForCommand:) andReturn:webView];
      
      GreeJSLaunchServiceCommand *command = [[GreeJSLaunchServiceCommand alloc] init];
      command.environment = environment;
      [command execute:parameters];
      [command release];
    }); 

    it(@"should open the URL with UIApplication if the target is not self", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSDictionary dictionaryWithObjectsAndKeys:@"mockURL://", @"URL", nil], @"params",
        nil];
      
      UIApplication *application = [UIApplication nullMock];
      [[application should] receive:@selector(openURL:)];
      [[UIApplication stubAndReturn:application] sharedApplication];
      
      GreeJSLaunchServiceCommand *command = [[GreeJSLaunchServiceCommand alloc] init];
      [command execute:parameters];
      [command release];
    }); 
  });
});

SPEC_END
