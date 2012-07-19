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
#import "GreeTestHelpers.h"
#import "GreeJSShowDashboardCommand.h"
#import "GreeJSWebViewController.h"
#import "GreeMenuNavController.h"
#import "GreeSettings.h"
#import "GreePlatform.h"
#import "GreeJSHandler.h"
#import "UIViewController+GreeAdditions.h"

#pragma mark - GreeJSShowDashboardCommandTest

SPEC_BEGIN(GreeJSShowDashboardCommandTest)

describe(@"GreeJSShowDashboardCommand",^{  
  context(@"when the URL is not valid", ^{
    __block id environment;
    __block GreeJSHandler *handler;
    __block UIViewController *viewController;
    
    beforeEach(^{
      handler = [GreeJSHandler nullMock];
    
      environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(handler) andReturn:handler];
      
      viewController = [UIViewController nullMock];
      [UIViewController stub:@selector(alloc) andReturn:viewController];
    });
    
    afterEach(^{
      environment = nil;
      handler = nil;
      viewController = nil;
    });
    
    it(@"should callback the handler with an error message if given no URL", ^{
      [[handler should] receive:@selector(callback:params:)];
      [[viewController shouldNot] receive:@selector(presentGreeDashboardWithBaseURL:delegate:animated:completion:)];

      GreeJSShowDashboardCommand *command = [[GreeJSShowDashboardCommand alloc] init];
      [command stub:@selector(viewControllerWithRequiredBaseClass:) andReturn:viewController];
      
      command.environment = environment;
      [[command should] receive:@selector(callback:withErrorMessage:)];
      [command execute:nil];
      [command release];
    });
  
    it(@"should callback the handler with an error message if given an invalid URL", ^{
      [[handler should] receive:@selector(callback:params:)];
      [[viewController shouldNot] receive:@selector(presentGreeDashboardWithBaseURL:delegate:animated:completion:)];
        
      GreeJSShowDashboardCommand *command = [[GreeJSShowDashboardCommand alloc] init];
      [command stub:@selector(viewControllerWithRequiredBaseClass:) andReturn:viewController];
      command.environment = environment;
      [[command should] receive:@selector(callback:withErrorMessage:)];
      [command execute:[NSDictionary dictionaryWithObject:@"###" forKey:@"URL"]];
      [command release];
    });
  });

  it(@"should launch a dashboard when there is a valid URL", ^{
    UIViewController *viewController = [UIViewController nullMock];
    [UIViewController stub:@selector(alloc) andReturn:viewController];
    [[viewController should] receive:@selector(presentGreeDashboardWithBaseURL:delegate:animated:completion:)];
  
    GreeJSShowDashboardCommand *command = [[GreeJSShowDashboardCommand alloc] init];
    [command stub:@selector(viewControllerWithRequiredBaseClass:) andReturn:viewController];
    [command execute:[NSDictionary dictionaryWithObject:@"http://www.google.com" forKey:@"URL"]];
    [command release];
  });
  
  it(@"should have a description", ^{
    GreeJSShowDashboardCommand* command = [[GreeJSShowDashboardCommand alloc] init];
    NSString* checkString = [NSString stringWithFormat:@"<GreeJSShowDashboardCommand:%p>", command];
    [[[command description] should] equal:checkString];
    [command release];
  });
  
  it(@"should have a name", ^{      
    [[[GreeJSShowDashboardCommand name] should] equal:@"show_dashboard"]; 
  });
  
  context(@"when closing the dashboard", ^{
    it(@"should callback when the dashboard button closed", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockURL://", @"URL",
        @"callback", @"callback",
        nil];

      GreeJSShowDashboardCommand *command = [[GreeJSShowDashboardCommand alloc] init];
    
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:@"callback"
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithBool:YES], @"result",
          nil]];
          
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:[UIViewController nullMock]] viewControllerForCommand:command];
      [[environment stubAndReturn:handler] handler];

      command.environment = environment;
    
      command.environment = environment;
      [command execute:parameters];
      [command dashboardCloseButtonPressed:nil];
      [command release];
    });

    it(@"should dismiss the dashboard", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockURL://", @"URL",
        @"callback", @"callback",
        nil];

      GreeJSShowDashboardCommand *command = [[GreeJSShowDashboardCommand alloc] init];
    
      UIViewController *viewController = [UIViewController nullMock];
      [[[viewController should] receive] dismissGreeDashboardAnimated:YES completion:nil];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:viewController] viewControllerForCommand:command];

      command.environment = environment;
      [command execute:parameters];
      [command dashboardCloseButtonPressed:nil];
      [command release];
    });
  });
});

SPEC_END
