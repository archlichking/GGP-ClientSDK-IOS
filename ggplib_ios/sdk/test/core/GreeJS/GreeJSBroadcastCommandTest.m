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
#import "GreeJSWebViewController.h"
#import "GreeDashboardViewController.h"
#import "GreeJSBroadcastCommand.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSBroadcastCommandTest)

describe(@"GreeJSBroadcastCommandTest",^{
  registerMatchers(@"Gree");

  it(@"should have a name", ^{
    [[[GreeJSBroadcastCommand name] should] equal:@"broadcast"]; 
  });
  

  it(@"should have a description", ^{
    GreeJSBroadcastCommand *command = [[GreeJSBroadcastCommand alloc] init];
    NSString *matchString = [NSString stringWithFormat:@"<GreeJSBroadcastCommand:0x[0-9a-f]+, environment:\\(null\\)>"];
    
    [[[command description] should] matchRegExp:matchString]; 
    [command release];
  });
  
  context(@"when executing", ^{
    __block id environment;
    __block UINavigationController *navigationController;
    __block GreeJSWebViewController *webViewController;
    
    beforeEach(^{
      webViewController = [GreeJSWebViewController nullMock];
      navigationController = [UINavigationController nullMock];
    
      environment = [KWMock mockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:webViewController];
    });
    
    afterEach(^{
      environment = nil;
      navigationController = nil;
      webViewController = nil;
    });
    
    it(@"should set the delegate if is not set", ^{
      [webViewController stub:@selector(navigationController) andReturn:navigationController];
  
      UINavigationController *topNavigationController = [UINavigationController nullMock];
      [[topNavigationController should] receive:@selector(delegate) andReturn:[GreeDashboardViewController nullMock]];
      
      UIViewController *beforeViewController = [UIViewController nullMock];
      [beforeViewController stub:@selector(navigationController) andReturn:topNavigationController];
      
      [webViewController stub:@selector(beforeWebViewController) andReturn:beforeViewController];
                
      GreeJSBroadcastCommand *command = [[GreeJSBroadcastCommand alloc] init];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });
    
    it(@"should do nothing if the navigation controller delegate is not a dashboard", ^{
      [navigationController stub:@selector(delegate) andReturn:[UIViewController nullMock]];
      [webViewController stub:@selector(navigationController) andReturn:navigationController];
      
      GreeJSBroadcastCommand *command = [[GreeJSBroadcastCommand alloc] init];
      [[command shouldNot] receive:@selector(broadcast:toAllAscendingViewControllers:)];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });

    it(@"should broadcast to the navigation controller delegate if the navigation controller delegate is a dashboard", ^{
      [navigationController stub:@selector(delegate) andReturn:[GreeDashboardViewController nullMock]];
      [webViewController stub:@selector(navigationController) andReturn:navigationController];
      
      GreeJSBroadcastCommand *command = [[GreeJSBroadcastCommand alloc] init];
      [[command should] receive:@selector(broadcast:toAllAscendingViewControllers:)];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });

    it(@"should not broadcast to the menu view controller if the dashboard's menu navigation controller is not a UINavigationController", ^{
      GreeDashboardViewController *dashboard = [GreeDashboardViewController nullMock];
      [dashboard stub:@selector(menuViewController) andReturn:[UIViewController nullMock]];

      [navigationController stub:@selector(delegate) andReturn:dashboard];
      [webViewController stub:@selector(navigationController) andReturn:navigationController];

      
      GreeJSBroadcastCommand *command = [[GreeJSBroadcastCommand alloc] init];
      [[command should] receive:@selector(broadcast:toAllAscendingViewControllers:) withCount:1];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });
    
    it(@"should broadcast to the front view controller if it is the top", ^{
      GreeDashboardViewController *dashboard = [GreeDashboardViewController nullMock];
            
      UINavigationController *rootViewController = [UINavigationController nullMock];
      [rootViewController stub:@selector(topViewController) andReturn:webViewController];
      
      [dashboard stub:@selector(menuViewController) andReturn:[UINavigationController nullMock]];
      [dashboard stub:@selector(rootViewController) andReturn:rootViewController];

      [navigationController stub:@selector(delegate) andReturn:dashboard];
      [webViewController stub:@selector(navigationController) andReturn:navigationController];
      
      GreeJSBroadcastCommand *command = [[GreeJSBroadcastCommand alloc] init];
      [[command should] receive:@selector(broadcast:toAllAscendingViewControllers:) withCount:2];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });
    
    it(@"should broadcast to the menu view controller if it is the top", ^{
      GreeDashboardViewController *dashboard = [GreeDashboardViewController nullMock];
            
      UINavigationController *rootViewController = [UINavigationController nullMock];
      [rootViewController stub:@selector(topViewController) andReturn:[UIViewController nullMock]];
      
      UINavigationController *menuViewController = [UINavigationController nullMock];
      [menuViewController stub:@selector(topViewController) andReturn:webViewController];
      
      [dashboard stub:@selector(menuViewController) andReturn:menuViewController];
      [dashboard stub:@selector(rootViewController) andReturn:rootViewController];

      [navigationController stub:@selector(delegate) andReturn:dashboard];
      [webViewController stub:@selector(navigationController) andReturn:navigationController];
      
      GreeJSBroadcastCommand *command = [[GreeJSBroadcastCommand alloc] init];
      [[command should] receive:@selector(broadcast:toAllAscendingViewControllers:) withCount:2];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });
  });
});

SPEC_END
