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
#import "GreeJSLoadCachedPageCommand.h"
#import "GreeMatchers.h"

@interface GreeJSLoadCachedPageCommand ()
- (void)setFailedCallbackFunctionName:(NSString*)failedCallbackFunctionName;
@end

SPEC_BEGIN(GreeJSLoadCachedPageCommandTest)

describe(@"GreeJSLoadCachedPageCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSLoadCachedPageCommand name] should] equal:@"loadCachedPage"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSLoadCachedPageCommand *command = [[GreeJSLoadCachedPageCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSLoadCachedPageCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should set the failed callback name to the value of the 'failed' parameter", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockCallbackName", @"failed", nil];
      
      GreeJSLoadCachedPageCommand *command = [[GreeJSLoadCachedPageCommand alloc] init];
      [[[command should] receive] setFailedCallbackFunctionName:@"mockCallbackName"];
      [command execute:parameters];
      [command release];
    });

    it(@"should callback with the correct parameters", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockCallbackName", @"failed", nil];

      GreeJSLoadCachedPageCommand *command = [[GreeJSLoadCachedPageCommand alloc] init];
  
      UIWebView *webView = [UIWebView nullMock];
      [[[webView should] receive] stringByEvaluatingJavaScriptFromString:@"mockCallbackName()"];
  
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:webView] webviewForCommand:command];

      command.environment = environment;
      [command execute:parameters];
      [command release];
    });

    it(@"should not callback if the result is YES", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockCallbackName", @"failed", nil];

      GreeJSLoadCachedPageCommand *command = [[GreeJSLoadCachedPageCommand alloc] init];
  
      UIWebView *webView = [UIWebView nullMock];
      [[[webView shouldNot] receive] stringByEvaluatingJavaScriptFromString:@"mockCallbackName()"];
  
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:webView] webviewForCommand:command];
      
      [[command stubAndReturn:[NSNumber numberWithBool:YES]] result];
      command.environment = environment;      
      [command execute:parameters];
      [command release];
    });

    it(@"should not callback if the length of the callback method is zero", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"", @"failed", nil];

      GreeJSLoadCachedPageCommand *command = [[GreeJSLoadCachedPageCommand alloc] init];
  
      UIWebView *webView = [UIWebView nullMock];
      [[[webView shouldNot] receive] stringByEvaluatingJavaScriptFromString:@"mockCallbackName()"];
  
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:webView] webviewForCommand:command];
      
      [[command stubAndReturn:[NSNumber numberWithBool:NO]] result];
      command.environment = environment;      
      [command execute:parameters];
      [command release];
    });
  });
  
  it(@"should load data into the web view based upon the path", ^{
    GreeJSLoadCachedPageCommand *command = [[GreeJSLoadCachedPageCommand alloc] init];
  
    UIWebView *webView = [UIWebView nullMock];
    [[webView stubAndReturn:@"mockSuffix"] stringByEvaluatingJavaScriptFromString:@"document.location.search+document.location.hash"];
    [[[webView should] receive]
      loadData:[NSData data]
      MIMEType:@"text/html"
      textEncodingName:@"utf-8"
      baseURL:[NSURL URLWithString:@"mockSuffix" relativeToURL:[NSURL fileURLWithPath:@"mockPath"]]];
      
    id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
    [[environment stubAndReturn:webView] webviewForCommand:command];
      
    [[command stubAndReturn:[NSNumber numberWithBool:NO]] result];
    command.environment = environment;
    [command readyToLoadPath:@"mockPath" data:[NSData data]]; 
    [command release];
  });

  context(@"when loading URL from params", ^{
    it(@"should reload the result from parameters", ^{
      GreeJSLoadCachedPageCommand *command = [[GreeJSLoadCachedPageCommand alloc] init];
      [[[command urlToLoadWithParams:[NSDictionary dictionaryWithObjectsAndKeys:
        @"mockURL://", @"url", nil]] should] equal:[NSURL URLWithString:@"mockURL://"]];
      [command release];
    });

    it(@"should load URL from the web view if there are no parameters", ^{
      GreeJSLoadCachedPageCommand *command = [[GreeJSLoadCachedPageCommand alloc] init];
      
      UIWebView *webView = [UIWebView nullMock];
      [[webView stubAndReturn:@"mockURL://"] stringByEvaluatingJavaScriptFromString:@"document.location.href"];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:webView] webviewForCommand:command];
      
      command.environment = environment;

      [[[command urlToLoadWithParams:nil] should] equal:[NSURL URLWithString:@"mockURL://"]];
      [command release];
    });
  });

});

SPEC_END
