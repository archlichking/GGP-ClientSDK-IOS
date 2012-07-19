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
#import "GreeDashboard.h"
#import "GreeDashboardLauncher.h"
#import "GreeSettings.h"
#import "GreePlatform+Internal.h"
#import "GreeJSWebViewController.h"
#import "GreeMenuNavController.h"
#import "GreeDashboardViewController.h"
#import "GreePlatform.h"
#import "GreeHTTPClient.h"

#pragma mark - GreeDashboardLauncherTests

@interface GreeDashboardLauncher (ExposePrivateMethods)
- (void)dismissDashboard;
- (NSURL*)URLFromMenuViewController:(UIViewController*)viewController;
@end

SPEC_BEGIN(GreeDashboardLauncherTests)
describe(@"GreeDashboardLauncher", ^{
  __block GreePlatform *platform = nil;

  beforeEach(^{    
    GreeSettings* settings = [GreeSettings nullMock];
    [settings stub:@selector(stringValueForSetting:) andReturn:@"appname"];
    platform = [GreePlatform nullMock];
    [platform stub:@selector(settings) andReturn:settings];
    [GreePlatform stub:@selector(presentViewController:animated:completion:)];
    [GreePlatform stub:@selector(dismissViewController:animated:completion:)];
    [GreePlatform stub:@selector(sharedInstance) andReturn:platform];
  });
  
  afterEach(^{    
    platform = nil;
  });

  it(@"should initialize to the default values", ^{
    GreeDashboardLauncher *launcher = [[GreeDashboardLauncher alloc] init];
    [launcher shouldNotBeNil];
    [launcher.completion shouldBeNil];
    [launcher release];
  }); 

  it(@"should show a description", ^{
    GreeDashboardLauncher *launcher = [[GreeDashboardLauncher alloc] init];
    NSString *checkString = [NSString stringWithFormat:@"<GreeDashboardLauncher:%p, showingViewController:NO completionIsSet:NO>",
      launcher
    ];
    
    [[[launcher description] should] equal:checkString];  
    [launcher release];
  });
  
  context(@"presenting a dashboard", ^{
   __block void (^completion)(id results);
    beforeEach(^{
      [GreeJSWebViewController stub:@selector(alloc)];
      [GreeMenuNavController stub:@selector(alloc) andReturn:[GreeMenuNavController nullMock]];
            
      UIApplication *application = [UIApplication nullMock];
      [application stub:@selector(keyWindow) andReturn:[UIWindow nullMock]];
      [UIApplication stub:@selector(sharedApplication) andReturn:application];
      
      GreeDashboardViewController *dashboard = [GreeDashboardViewController nullMock];
      [dashboard stub:@selector(view)];
      [dashboard stub:@selector(initWithBaseURL:) andReturn:dashboard];
      [GreeDashboardViewController stub:@selector(alloc) andReturn:dashboard];
      
      completion = ^(id results){};
    });

    it(@"should launch the dashboard based on the path", ^{
      [[GreePlatform should] receive:@selector(presentViewController:animated:completion:)];
      GreeDashboardLauncher *launcher = [[GreeDashboardLauncher alloc] init];
    
      [launcher launchDashboardWithPath:@"hello" completion:completion];    
      [[launcher.completion should] beIdenticalTo:completion];
      [launcher release];
    });
    
    it(@"should launch the dashboard if the path is nil", ^{
      [[GreePlatform should] receive:@selector(presentViewController:animated:completion:)];
      GreeDashboardLauncher *launcher = [[GreeDashboardLauncher alloc] init];

      [launcher launchDashboardWithPath:nil completion:completion];    
      [[launcher.completion should] beIdenticalTo:completion];
      
      [launcher release];
    });

    it(@"should launch a view controller based on a url", ^{
      [[GreePlatform should] receive:@selector(presentViewController:animated:completion:)];
      GreeDashboardLauncher *launcher = [[GreeDashboardLauncher alloc] init];

      [launcher launchDashboardWithBaseURL:[NSURL URLWithString:@"http://www.google.com"] completion:completion];    
      [[launcher.completion should] beIdenticalTo:completion];
      
      [launcher release];
    });
        
    it(@"should not launch the dashboard if the base url is nil", ^{  
      [[GreePlatform shouldNot] receive:@selector(presentViewController:animated:completion:)];
      GreeDashboardLauncher *launcher = [[GreeDashboardLauncher alloc] init];
     
      [launcher launchDashboardWithBaseURL:nil completion:completion];
    
      [launcher release];
    });
    
    it(@"should not launch the dashboard if the dashboard is already launched", ^{     
      [[GreePlatform should] receive:@selector(presentViewController:animated:completion:) withCount:1];
      GreeDashboardLauncher *launcher = [[GreeDashboardLauncher alloc] init];
   
      [launcher launchDashboardWithPath:@"hello" completion:completion];
      [launcher launchDashboardWithPath:@"hello" completion:completion];
      
      [launcher release];
    });
    
    it(@"should add an analytics event when the dashboard is launched", ^{
      GreeDashboardLauncher *launcher = [[GreeDashboardLauncher alloc] init];

      [[platform should] receive:@selector(addAnalyticsEvent:)];

      [launcher launchDashboardWithBaseURL:[NSURL URLWithString:@"http://www.google.com"] completion:completion];
        
      [launcher release];
    });
  });

  context(@"presenting a dashboard", ^{      
    __block GreePlatform* platform;
    beforeEach(^{
      GreeSettings* settings = [GreeSettings nullMock];
      settings = [GreeSettings nullMock];
      platform = [GreePlatform nullMock];
      [platform stub:@selector(settings) andReturn:settings];
      [GreePlatform stub:@selector(sharedInstance) andReturn:platform];      
    });    
    afterEach(^{    
      platform = nil;
    });
    
    it(@"should launch the dashboard based on the path", ^{
      
      GreeDashboardLauncher *launcher = [[GreeDashboardLauncher alloc] init];      
      NSDictionary* parameters = nil;
      NSString* result = nil;

      NSString* app_id = @"3968";
      [platform.settings stub:@selector(objectValueForSetting:) andReturn:[NSString stringWithFormat:@"%@", app_id]];

      NSString* domain = @"http://apps-dev-ggp-qa.dev.gree-dev.net";
      [platform.settings stub:@selector(stringValueForSetting:) andReturn:[NSString stringWithFormat:@"%@", domain]];

      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeTop, GreeDashboardMode                                  
                    , nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/", domain]];

      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeTop, GreeDashboardMode,                                 
                    app_id, GreeDashboardAppId                                 
                    , nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/?app_id=%@", domain, app_id]];
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeTop, GreeDashboardMode,                                 
                    @"1111", GreeDashboardUserId                                 
                    , nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/?user_id=1111", domain]];

      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeTop, GreeDashboardMode,                                 
                    app_id, GreeDashboardAppId,
                    @"1111", GreeDashboardUserId,
                    nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/?app_id=%@&user_id=1111", domain, app_id]];

      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeTop, GreeDashboardMode,                                 
                    @"", GreeDashboardAppId,
                    @"", GreeDashboardUserId,
                    nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/", domain]];
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeRankingList, GreeDashboardMode,                                 
                    nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/leaderboard/list", domain]];

      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeRankingList, GreeDashboardMode,                                 
                    app_id, GreeDashboardAppId                                 
                    , nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/leaderboard/list?app_id=%@", domain, app_id]];

      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeRankingList, GreeDashboardMode,                                 
                    @"1111", GreeDashboardUserId                                 
                    , nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/leaderboard/list?user_id=1111", domain]];

      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeRankingList, GreeDashboardMode,                                 
                    app_id, GreeDashboardAppId,
                    @"1111", GreeDashboardUserId,
                    nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/leaderboard/list?app_id=%@&user_id=1111", domain, app_id]];

      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeRankingList, GreeDashboardMode,                                 
                    @"", GreeDashboardAppId,
                    @"", GreeDashboardUserId,
                    nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/leaderboard/list", domain]];
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeRankingDetails, GreeDashboardMode,                                 
                    nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/", domain]];
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeRankingDetails, GreeDashboardMode,                                 
                    app_id, GreeDashboardAppId                                 
                    , nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/?app_id=%@", domain, app_id]];
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeRankingDetails, GreeDashboardMode,                                 
                    @"1111", GreeDashboardUserId                                 
                    , nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/?user_id=1111", domain]];
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeRankingDetails, GreeDashboardMode,                                 
                    app_id, GreeDashboardAppId,
                    @"1111", GreeDashboardUserId,
                    nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/?app_id=%@&user_id=1111", domain, app_id]];
    
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeRankingDetails, GreeDashboardMode,                                 
                    @"", GreeDashboardAppId,
                    @"", GreeDashboardUserId,
                    nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/", domain]];

      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeRankingDetails, GreeDashboardMode,                                 
                    @"", GreeDashboardAppId,
                    @"", GreeDashboardUserId,
                    @"2222", GreeDashboardLeaderboardId,
                    nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/leaderboard/view?leaderboard_id=2222", domain]];
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeRankingDetails, GreeDashboardMode,                                 
                    app_id, GreeDashboardAppId,
                    @"", GreeDashboardUserId,
                    @"2222", GreeDashboardLeaderboardId,
                    nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/leaderboard/view?app_id=%@&leaderboard_id=2222", domain, app_id]];
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeRankingDetails, GreeDashboardMode,                                 
                    app_id, GreeDashboardAppId,
                    @"1111", GreeDashboardUserId,
                    @"2222", GreeDashboardLeaderboardId,
                    nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/leaderboard/view?app_id=%@&user_id=1111&leaderboard_id=2222", domain, app_id]];
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeAchievementList, GreeDashboardMode,                                 
                    nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/achievement/list", domain]];
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeAchievementList, GreeDashboardMode,                                 
                    app_id, GreeDashboardAppId                                 
                    , nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/achievement/list?app_id=%@", domain, app_id]];
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeAchievementList, GreeDashboardMode,                                 
                    @"1111", GreeDashboardUserId                                 
                    , nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/achievement/list?user_id=1111", domain]];
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeAchievementList, GreeDashboardMode,                                 
                    app_id, GreeDashboardAppId,
                    @"1111", GreeDashboardUserId,
                    nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/achievement/list?app_id=%@&user_id=1111", domain, app_id]];
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeAchievementList, GreeDashboardMode,                                 
                    @"", GreeDashboardAppId,
                    @"", GreeDashboardUserId,
                    nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/achievement/list", domain]];
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeUsersList, GreeDashboardMode,                                 
                    nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/users", domain]];
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeUsersList, GreeDashboardMode,                                 
                    app_id, GreeDashboardAppId                                 
                    , nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/users?app_id=%@", domain, app_id]];
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeUsersList, GreeDashboardMode,                                 
                    @"1111", GreeDashboardUserId                                 
                    , nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/users", domain]];
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeUsersList, GreeDashboardMode,                                 
                    @"3968", GreeDashboardAppId,
                    @"1111", GreeDashboardUserId,
                    nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/users?app_id=%@", domain, app_id]];
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeUsersList, GreeDashboardMode,                                 
                    @"", GreeDashboardAppId,
                    @"", GreeDashboardUserId,
                    nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/users", domain]];
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    @"", GreeDashboardMode                                  
                    , nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/", domain]];
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    @"http://www.google.co.jp", GreeDashboardMode,                                 
                    app_id, GreeDashboardAppId                                 
                    , nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:@"http://www.google.co.jp"];
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    app_id, GreeDashboardAppId                                 
                    , nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/?app_id=%@", domain, app_id]];
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeTop, GreeDashboardMode,                                 
                    app_id, GreeDashboardAppId,
                    @"1111", GreeDashboardUserId,
                    nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/?app_id=%@&user_id=1111", domain, app_id]];
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeTop, GreeDashboardMode,                                 
                    @"", GreeDashboardAppId,
                    @"", GreeDashboardUserId,
                    nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/", domain]];
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                  GreeDashboardModeAppSetting, GreeDashboardMode                                  
                                  , nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/app/info/setting/view/%@", domain, app_id]];          
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeAppSetting, GreeDashboardMode,                                 
                    app_id, GreeDashboardAppId                                 
                    , nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/app/info/setting/view/%@", domain, app_id]];          
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeAppSetting, GreeDashboardMode,                                 
                    @"1111", GreeDashboardUserId                                 
                    , nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/app/info/setting/view/%@", domain, app_id]];          
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeAppSetting, GreeDashboardMode,                                 
                    app_id, GreeDashboardAppId,
                    @"1111", GreeDashboardUserId,
                    nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/app/info/setting/view/%@", domain, app_id]];          
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeAppSetting, GreeDashboardMode,                                 
                    @"", GreeDashboardAppId,
                    @"", GreeDashboardUserId,
                    nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/app/info/setting/view/%@", domain, app_id]];          
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeAppSetting, GreeDashboardMode,                                 
                    @"5555", GreeDashboardAppId,
                    @"", GreeDashboardUserId,
                    nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/gd/app/info/setting/view/%@", domain, app_id]];          
      
      domain = @"http://pf-dev-ggp-qa.dev.gree-dev.net";
      [platform.settings stub:@selector(stringValueForSetting:) andReturn:[NSString stringWithFormat:@"%@", domain]];
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeUsersInvites, GreeDashboardMode,                                 
                    nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/?mode=ggp&act=service_invite&view=dashboard&app_id=%@", domain, app_id]];          
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeUsersInvites, GreeDashboardMode,                                 
                    app_id, GreeDashboardAppId                                 
                    , nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/?mode=ggp&act=service_invite&view=dashboard&app_id=%@", domain, app_id]];          
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeUsersInvites, GreeDashboardMode,                                 
                    @"1111", GreeDashboardUserId                                 
                    , nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/?mode=ggp&act=service_invite&view=dashboard&app_id=%@", domain, app_id]];          
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeUsersInvites, GreeDashboardMode,                                 
                    app_id, GreeDashboardAppId,
                    @"1111", GreeDashboardUserId,
                    nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/?mode=ggp&act=service_invite&view=dashboard&app_id=%@", domain, app_id]];          
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeUsersInvites, GreeDashboardMode,                                 
                    @"", GreeDashboardAppId,
                    @"", GreeDashboardUserId,
                    nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/?mode=ggp&act=service_invite&view=dashboard&app_id=%@", domain, app_id]];          
      
      parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                    GreeDashboardModeUsersInvites, GreeDashboardMode,                                 
                    @"5555", GreeDashboardAppId,
                    @"", GreeDashboardUserId,
                    nil];
      result = [launcher performSelector:@selector(dashboardURLStringWithParameters:) withObject:parameters];
      [[result should] equal:[NSString stringWithFormat:@"%@/?mode=ggp&act=service_invite&view=dashboard&app_id=%@", domain, app_id]];          

      [launcher release];
    });
    
  });

  
  context(@"regarding the callback block", ^{
    beforeEach(^{
      GreeDashboardViewController *dashboardViewController = [GreeDashboardViewController nullMock];
      [dashboardViewController stub:@selector(rootViewController) andReturn:[UINavigationController nullMock]];
      [GreeDashboardViewController stub:@selector(alloc) andReturn:dashboardViewController];
    });
  
    it(@"should execute the callback block when dismissed", ^{
      __block BOOL ranBlock = NO;
      
      void (^completion)() = ^{
        ranBlock = YES;
      };
    
      GreeDashboardLauncher *launcher = [[GreeDashboardLauncher alloc] init];
    
      [launcher launchDashboardWithBaseURL:[NSURL nullMock] completion:completion];
      [launcher dismissDashboard];
      [[theValue(ranBlock) shouldEventually] beYes];
      [launcher release];
    });
  
    it(@"should do nothing (not crash) when the callback block is nil", ^{
      GreeDashboardLauncher *launcher = [[GreeDashboardLauncher alloc] init];
    
      [launcher launchDashboardWithBaseURL:[NSURL nullMock] completion:nil];
      [launcher dismissDashboard];
    
      [launcher release];
    });
  });
  
  context(@"regarding analytics", ^{
    beforeEach(^{
      NSURL *URL = [NSURL nullMock];
      [URL stub:@selector(absoluteString) andReturn:@"mockURL://"];
  
      NSURLRequest *request = [NSURLRequest nullMock];
      [request stub:@selector(URL) andReturn:URL];
  
      UIWebView *webView = [UIWebView nullMock];
      [webView stub:@selector(request) andReturn:request];
      [webView stub:@selector(stringByEvaluatingJavaScriptFromString:) andReturn:@"mockURL://"];

      GreeJSWebViewController *webViewController = [GreeJSWebViewController nullMock];
      [webViewController stub:@selector(webView) andReturn:webView];
  
      UINavigationController *navigationController = [UINavigationController nullMock];
      [navigationController stub:@selector(visibleViewController) andReturn:webViewController];

      GreeDashboardViewController *dashboardViewController = [GreeDashboardViewController nullMock];
      [dashboardViewController stub:@selector(rootViewController) andReturn:navigationController];
      [dashboardViewController stub:@selector(initWithBaseURL:) andReturn:dashboardViewController];

      [GreeDashboardViewController stub:@selector(alloc) andReturn:dashboardViewController];
    });
    
    it(@"should add an analytics event when the dashboard is dismissed", ^{  
      GreeDashboardLauncher *launcher = [[GreeDashboardLauncher alloc] init];
     
      [launcher launchDashboardWithBaseURL:[NSURL nullMock] completion:nil];
        
      [[platform should] receive:@selector(addAnalyticsEvent:)];
      [launcher dismissDashboard];
      [launcher release];
    });
  
    it(@"should add an analytics event when the dashboard changes to the universal menu", ^{
      GreeDashboardLauncher *launcher = [[GreeDashboardLauncher alloc] init];

      [[platform should] receive:@selector(addAnalyticsEvent:)];
      [launcher launchDashboardWithBaseURL:[NSURL nullMock] completion:nil];

      [[NSNotificationCenter defaultCenter]
        postNotificationName:GreeDashboardDidShowUniversalMenuNotification
        object:[launcher.currentDashboard performSelector:@selector(rootViewController)]];
      [launcher release];
    });

    it(@"should be able to find the url from a dashboard", ^{
      GreeDashboardViewController *dashboard = [[GreeDashboardViewController alloc] initWithBaseURL:nil];
      
      NSString *mockDashboardURL = [[GreeDashboardLauncher URLFromMenuViewController:dashboard.rootViewController] absoluteString];
    
      [[mockDashboardURL should] equal:@"mockURL://"];
    });
  });
});

SPEC_END
