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
#import "GreeJSSeeMoreCommand.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSSeeMoreCommandTest)

describe(@"GreeJSSeeMoreCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSSeeMoreCommand name] should] equal:@"see_more"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSSeeMoreCommand *command = [[GreeJSSeeMoreCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSSeeMoreCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should append items using a javascript interface", ^{
      UIWebView *webView = [UIWebView nullMock];
      [[[webView should] receive] stringByEvaluatingJavaScriptFromString:@"appendItem(mockItem)"];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(webviewForCommand:) andReturn:webView];
      
      GreeJSSeeMoreCommand *command = [[GreeJSSeeMoreCommand alloc] init];
      command.nextData = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSArray arrayWithObject:@"mockItem"], @"items", nil];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });

    it(@"should callback with the correct parameters", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"callback", @"callback",
        nil];
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:@"callback"
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithInt:1], @"offset",
          [NSNumber numberWithInt:2], @"limit",
          @"mockHasNext", @"hasNext",
          nil]];
    
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(handler) andReturn:handler];
      
      GreeJSSeeMoreCommand *command = [[GreeJSSeeMoreCommand alloc] init];
      command.nextData = [NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithInt:1], @"offset",
          [NSNumber numberWithInt:2], @"limit",
          @"mockHasNext", @"hasNext",
          nil];
      command.environment = environment;
      [command execute:parameters];
      [command release];
    });
  });
});

SPEC_END
