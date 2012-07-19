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
#import "GreeJSLoadURLCommand.h"
#import "GreeMatchers.h"
#import "GreePopup.h"

SPEC_BEGIN(GreeJSLoadURLCommandTest)

describe(@"GreeJSLoadURLCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSLoadURLCommand name] should] equal:@"load_url"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSLoadURLCommand *command = [[GreeJSLoadURLCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSLoadURLCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should callback with NO if the URL scheme is not http or https", ^{
      GreeJSLoadURLCommand *command = [[GreeJSLoadURLCommand alloc] init];
      [[[command should] receive] setResult:[NSNumber numberWithBool:NO]];
      
      [command execute:[NSDictionary dictionaryWithObjectsAndKeys:
        @"mockURL://", @"url",
        nil]];
      [command release];
    });

    it(@"should callback with YES if the URL scheme is http", ^{
      GreeJSLoadURLCommand *command = [[GreeJSLoadURLCommand alloc] init];
      [[[command should] receive] setResult:[NSNumber numberWithBool:YES]];
      
      [command execute:[NSDictionary dictionaryWithObjectsAndKeys:
        @"http://", @"url",
        nil]];
      [command release];
    });

    it(@"should callback with YES if the URL scheme is https", ^{
      GreeJSLoadURLCommand *command = [[GreeJSLoadURLCommand alloc] init];
      [[[command should] receive] setResult:[NSNumber numberWithBool:YES]];
      
      [command execute:[NSDictionary dictionaryWithObjectsAndKeys:
        @"https://", @"url",
        nil]];
      [command release];
    });

    it(@"should reload the webview if the view controller is a popup and the current url is an error", ^{
      GreeJSLoadURLCommand *command = [[GreeJSLoadURLCommand alloc] init];

      UIWebView *webView = [UIWebView nullMock];
      [[webView stubAndReturn:@"about://error/"] stringByEvaluatingJavaScriptFromString:@"document.URL"];
      [[[webView should] receive] reload];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:webView] webviewForCommand:command];
      [[environment stubAndReturn:[GreePopup nullMock]] viewControllerForCommand:command];
      
      command.environment = environment;
      [command execute:[NSDictionary dictionaryWithObjectsAndKeys:
        @"http://", @"url",
        nil]];
      [command release];
    });

    it(@"should not reload the webview if the view controller is not a popup", ^{
      GreeJSLoadURLCommand *command = [[GreeJSLoadURLCommand alloc] init];

      UIWebView *webView = [UIWebView nullMock];
      [[webView stubAndReturn:@"about://error/"] stringByEvaluatingJavaScriptFromString:@"document.URL"];
      [[[webView shouldNot] receive] reload];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:webView] webviewForCommand:command];
      [[environment stubAndReturn:[UIViewController nullMock]] viewControllerForCommand:command];
      
      command.environment = environment;
      [command execute:[NSDictionary dictionaryWithObjectsAndKeys:
        @"http://", @"url",
        nil]];
      [command release];
    });

    it(@"should not reload the webview if the current url in the popup is not about://error/", ^{
      GreeJSLoadURLCommand *command = [[GreeJSLoadURLCommand alloc] init];

      UIWebView *webView = [UIWebView nullMock];
      [[webView stubAndReturn:@"mockURL://"] stringByEvaluatingJavaScriptFromString:@"document.URL"];
      [[[webView shouldNot] receive] reload];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:webView] webviewForCommand:command];
      [[environment stubAndReturn:[GreePopup nullMock]] viewControllerForCommand:command];
      
      command.environment = environment;
      [command execute:[NSDictionary dictionaryWithObjectsAndKeys:
        @"http://", @"url",
        nil]];
      [command release];
    });
    
    it(@"otherwise, it should load a request with the URL", ^{
      GreeJSLoadURLCommand *command = [[GreeJSLoadURLCommand alloc] init];

      UIWebView *webView = [UIWebView nullMock];
      [[webView stubAndReturn:@"mockURL://"] stringByEvaluatingJavaScriptFromString:@"document.URL"];
      [[[webView should] receive] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.example.com"]]];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:webView] webviewForCommand:command];
      [[environment stubAndReturn:[GreePopup nullMock]] viewControllerForCommand:command];
      
      command.environment = environment;
      [command execute:[NSDictionary dictionaryWithObjectsAndKeys:
        @"http://www.example.com", @"url",
        nil]];
      [command release];
    });
  });
});

SPEC_END
