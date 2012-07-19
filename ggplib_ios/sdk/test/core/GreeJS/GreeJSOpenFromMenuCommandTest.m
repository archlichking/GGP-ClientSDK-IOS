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
#import "GreeJSOpenFromMenuCommand.h"
#import "GreeJSWebViewController.h"
#import "GreeMenuNavController.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSOpenFromMenuCommandTest)

describe(@"GreeJSOpenFromMenuCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSOpenFromMenuCommand name] should] equal:@"open_from_menu"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSOpenFromMenuCommand *command = [[GreeJSOpenFromMenuCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSOpenFromMenuCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should load a request in the top view controller", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockURL://", @"url", nil];
        
      UIWebView *webView = [UIWebView nullMock];
      [[[webView should] receive] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"mockURL://"]]];
      
      GreeJSWebViewController *topViewController = [GreeJSWebViewController nullMock];
      [topViewController stub:@selector(webView) andReturn:webView];
      
      UINavigationController *rootViewController = [UINavigationController nullMock];
      [rootViewController stub:@selector(topViewController) andReturn:topViewController];
      
      GreeMenuNavController *menuController = [GreeMenuNavController nullMock];
      [menuController stub:@selector(rootViewController) andReturn:rootViewController];
      
      UINavigationController *navigationController = [UINavigationController nullMock];
      [navigationController stub:@selector(delegate) andReturn:menuController];
      
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [currentViewController stub:@selector(navigationController) andReturn:navigationController];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSOpenFromMenuCommand *command = [[GreeJSOpenFromMenuCommand alloc] init];
      command.environment = environment;
      [command execute:parameters];
      [command release];
    });
  });
});

SPEC_END
