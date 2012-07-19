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
#import "GreeJSDismissModalViewCommand.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSDismissModalViewCommandTest)

describe(@"GreeJSDismissModalViewCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSDismissModalViewCommand name] should] equal:@"dismiss_modal_view"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSDismissModalViewCommand *command = [[GreeJSDismissModalViewCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSDismissModalViewCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should dismiss the modal view controller", ^{
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [[[currentViewController should] receive] dismissModalViewControllerAnimated:YES];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSDismissModalViewCommand *command = [[GreeJSDismissModalViewCommand alloc] init];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });
    
    it(@"should set the beforeWebViewController to nil if the view parameter is specified", ^{
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [[[currentViewController should] receive] setBeforeWebViewController:nil];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSDismissModalViewCommand *command = [[GreeJSDismissModalViewCommand alloc] init];
      command.environment = environment;
      [command execute:[NSDictionary dictionaryWithObjectsAndKeys:@"mockViewName", @"view", nil]];
      [command release];
    });

    it(@"should not set the beforeWebViewController to nil if the view parameter is not specified", ^{
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [[[currentViewController shouldNot] receive] setBeforeWebViewController:nil];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSDismissModalViewCommand *command = [[GreeJSDismissModalViewCommand alloc] init];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });

    it(@"should open a view in the before view controller if it is not nil", ^{
      NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"mockViewName", @"view", nil];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        open:@"mockViewName"
        params:params
        options:[NSDictionary dictionaryWithObjectsAndKeys:@"true", @"force_load_view",nil]];
        
      
      GreeJSWebViewController *beforeWebViewController = [GreeJSWebViewController nullMock];
      [[beforeWebViewController stubAndReturn:handler] handler];
      
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [[currentViewController stubAndReturn:beforeWebViewController] beforeWebViewController];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSDismissModalViewCommand *command = [[GreeJSDismissModalViewCommand alloc] init];
      command.environment = environment;
      [command execute:params];
      [command release];
    });

    it(@"should not open a view in the before view controller if the before view controller is nil", ^{
      NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"mockViewName", @"view", nil];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler shouldNot] receive]
        open:@"mockViewName"
        params:params
        options:[NSDictionary dictionaryWithObjectsAndKeys:@"true", @"force_load_view",nil]];
      
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [[currentViewController stubAndReturn:nil] beforeWebViewController];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSDismissModalViewCommand *command = [[GreeJSDismissModalViewCommand alloc] init];
      command.environment = environment;
      [command execute:params];
      [command release];
    });
  });

});

SPEC_END
