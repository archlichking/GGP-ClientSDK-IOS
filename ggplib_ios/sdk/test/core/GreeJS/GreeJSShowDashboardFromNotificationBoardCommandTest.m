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
#import "GreeJSShowDashboardFromNotificationBoardCommand.h"
#import "GreeNotificationBoardViewController.h"
#import "UIViewController+GreeAdditions.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSShowDashboardFromNotificationBoardCommandTest)

describe(@"GreeJSShowDashboardFromNotificationBoardCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSShowDashboardFromNotificationBoardCommand name] should] equal:@"show_dashboard_from_notification_board"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSShowDashboardFromNotificationBoardCommand *command = [[GreeJSShowDashboardFromNotificationBoardCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSShowDashboardFromNotificationBoardCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should show the dashboard from the notification board", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockURL://", @"url",
        nil];
      
      GreeJSShowDashboardFromNotificationBoardCommand *command = [[GreeJSShowDashboardFromNotificationBoardCommand alloc] init];
        
      UIViewController *presentingViewController = [UIViewController nullMock];

      GreeNotificationBoardViewController *notificationViewController = [GreeNotificationBoardViewController nullMock];
      [[notificationViewController stubAndReturn:presentingViewController] greePresentingViewController];

      [[[notificationViewController should] receive]
        presentGreeDashboardWithBaseURL:[NSURL URLWithString:@"mockURL://"]
        delegate:presentingViewController
        animated:YES
        completion:nil];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:notificationViewController] viewControllerForCommand:command];
      
      command.environment = environment;
      [command execute:parameters];
      [command release];
    });
  });
});

SPEC_END
