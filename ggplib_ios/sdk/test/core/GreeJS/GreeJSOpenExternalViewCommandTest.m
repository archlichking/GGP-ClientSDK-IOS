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
#import "GreeJSOpenExternalViewCommand.h"
#import "GreeJSWebViewController.h"
#import "GreeJSExternalWebViewController.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSOpenExternalViewCommandTest)

describe(@"GreeJSOpenExternalViewCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSOpenExternalViewCommand name] should] equal:@"open_external_view"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSOpenExternalViewCommand *command = [[GreeJSOpenExternalViewCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSOpenExternalViewCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"while executing", ^{
    it(@"should initialize a new external web view controller with a url", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockURL://", @"url",
        nil];

      GreeJSOpenExternalViewCommand *command = [[GreeJSOpenExternalViewCommand alloc] init];    
      
      GreeJSExternalWebViewController *externalWebViewController = [GreeJSExternalWebViewController nullMock];
      [[[externalWebViewController should] receive] initWithURL:[NSURL URLWithString:@"mockURL://"]];
      [[GreeJSExternalWebViewController stubAndReturn:externalWebViewController] alloc];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:[GreeJSWebViewController nullMock]] viewControllerForCommand:command];
      
      command.environment = environment;
      [command execute:parameters];
      [command release];
    });

    it(@"should push the external view controller", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockURL://", @"url",
        nil];

      GreeJSOpenExternalViewCommand *command = [[GreeJSOpenExternalViewCommand alloc] init];    
      
      GreeJSExternalWebViewController *externalWebViewController = [GreeJSExternalWebViewController nullMock];
      [[GreeJSExternalWebViewController stubAndReturn:externalWebViewController] alloc];
      [[externalWebViewController stubAndReturn:externalWebViewController] initWithURL:[NSURL URLWithString:@"mockURL://"]];

      
      UINavigationController *navigationController = [UINavigationController nullMock];
      [[[navigationController should] receive] pushViewController:externalWebViewController animated:YES];
      
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [[currentViewController stubAndReturn:navigationController] navigationController];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:currentViewController] viewControllerForCommand:command];
      
      command.environment = environment;
      [command execute:parameters];
      [command release];
    });
    
  });
});

SPEC_END
