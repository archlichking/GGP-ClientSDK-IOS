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
#import "GreeDashboardViewController.h"
#import "GreeDashboardViewControllerLaunchMode.h"
#import "GreePlatform.h"
#import "GreeSettings.h"

#pragma mark - GreeDashboardViewControllerTests

SPEC_BEGIN(GreeDashboardViewControllerTests)
describe(@"GreeDashboardViewController", ^{
  context(@"regarding initialization", ^{
    it(@"should initialize with a base URL", ^{
      GreeDashboardViewController *dashboard = [[GreeDashboardViewController alloc] initWithBaseURL:[NSURL URLWithString:@"mockURL://"]];
      [dashboard shouldNotBeNil];
      [[dashboard.baseURL should] equal:[NSURL URLWithString:@"mockURL://"]];
      [dashboard release];
    });
    
    it(@"should initial with a path", ^{
      NSString* app_id = @"3968";
      NSString* appDomain = @"http://apps-dev-ggp-qa.dev.gree-dev.net";
    
      GreeSettings *settings = [[[GreeSettings alloc] init] autorelease];
      [settings applySettingDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
        app_id, GreeSettingApplicationId,
        appDomain, GreeSettingServerUrlApps, nil]];

      GreePlatform *platform = [GreePlatform nullMock];
      [platform stub:@selector(settings) andReturn:settings];
      [GreePlatform stub:@selector(sharedInstance) andReturn:platform]; 
    
      GreeDashboardViewController *dashboard = [[GreeDashboardViewController alloc] initWithPath:nil];
      [dashboard shouldNotBeNil];
      
      NSString *gameDashboardPath = [NSString stringWithFormat:@"gd?app_id=%@", app_id];
      NSURL *URL = [NSURL URLWithString:gameDashboardPath relativeToURL:[NSURL URLWithString:appDomain]];
      [[dashboard.baseURL should] equal:URL];
      [dashboard release];
    });
  });

  it(@"should parse the parameters", ^{  
    NSString* app_id = @"3968";
    NSString* appDomain = @"http://apps-dev-ggp-qa.dev.gree-dev.net";
    NSString *pfDomain = @"http://pf-dev-ggp-qa.dev.gree-dev.net";
    
    GreeSettings *settings = [[[GreeSettings alloc] init] autorelease];
    [settings applySettingDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
      app_id, GreeSettingApplicationId,
      appDomain, GreeSettingServerUrlApps,
      pfDomain, GreeSettingServerUrlPf, nil]];

    GreePlatform *platform = [GreePlatform nullMock];
    [platform stub:@selector(settings) andReturn:settings];
    [GreePlatform stub:@selector(sharedInstance) andReturn:platform]; 
  
    NSDictionary* parameters = nil;
    NSString* result = nil;

    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeTop, GreeDashboardMode, nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/", appDomain]];

    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeTop, GreeDashboardMode,                                 
      app_id, GreeDashboardAppId, nil];
    
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/?app_id=%@", appDomain, app_id]];
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeTop, GreeDashboardMode,                                 
      @"1111", GreeDashboardUserId, nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/?user_id=1111", appDomain]];

    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeTop, GreeDashboardMode,                                 
      app_id, GreeDashboardAppId,
      @"1111", GreeDashboardUserId, nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/?app_id=%@&user_id=1111", appDomain, app_id]];

    parameters = [NSDictionary dictionaryWithObjectsAndKeys:
      GreeDashboardModeTop, GreeDashboardMode,                                 
      @"", GreeDashboardAppId,
      @"", GreeDashboardUserId,
      nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/", appDomain]];
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeRankingList, GreeDashboardMode, nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/leaderboard/list", appDomain]];

    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeRankingList, GreeDashboardMode,                                 
      app_id, GreeDashboardAppId, nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/leaderboard/list?app_id=%@", appDomain, app_id]];

    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeRankingList, GreeDashboardMode,                                 
      @"1111", GreeDashboardUserId, nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/leaderboard/list?user_id=1111", appDomain]];

    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeRankingList, GreeDashboardMode,                                 
      app_id, GreeDashboardAppId,
      @"1111", GreeDashboardUserId,nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/leaderboard/list?app_id=%@&user_id=1111", appDomain, app_id]];

    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeRankingList, GreeDashboardMode,                                 
      @"", GreeDashboardAppId,
      @"", GreeDashboardUserId,nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/leaderboard/list", appDomain]];
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeRankingDetails, GreeDashboardMode, nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/", appDomain]];
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeRankingDetails, GreeDashboardMode,                                 
      app_id, GreeDashboardAppId, nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/?app_id=%@", appDomain, app_id]];
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeRankingDetails, GreeDashboardMode,                                 
      @"1111", GreeDashboardUserId, nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/?user_id=1111", appDomain]];
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeRankingDetails, GreeDashboardMode,                                 
      app_id, GreeDashboardAppId,
      @"1111", GreeDashboardUserId, nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/?app_id=%@&user_id=1111", appDomain, app_id]];
    
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeRankingDetails, GreeDashboardMode,                                 
      @"", GreeDashboardAppId,
      @"", GreeDashboardUserId,nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/", appDomain]];

    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeRankingDetails, GreeDashboardMode,                                 
      @"", GreeDashboardAppId,
      @"", GreeDashboardUserId,
      @"2222", GreeDashboardLeaderboardId, nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/leaderboard/view?leaderboard_id=2222", appDomain]];
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeRankingDetails, GreeDashboardMode,                                 
      app_id, GreeDashboardAppId,
      @"", GreeDashboardUserId,
      @"2222", GreeDashboardLeaderboardId,nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/leaderboard/view?app_id=%@&leaderboard_id=2222", appDomain, app_id]];
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeRankingDetails, GreeDashboardMode,                                 
      app_id, GreeDashboardAppId,
      @"1111", GreeDashboardUserId,
      @"2222", GreeDashboardLeaderboardId,nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/leaderboard/view?app_id=%@&user_id=1111&leaderboard_id=2222", appDomain, app_id]];
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeAchievementList, GreeDashboardMode, nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/achievement/list", appDomain]];
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeAchievementList, GreeDashboardMode,                                 
      app_id, GreeDashboardAppId, nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/achievement/list?app_id=%@", appDomain, app_id]];
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:
      GreeDashboardModeAchievementList, GreeDashboardMode,                                 
      @"1111", GreeDashboardUserId, nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/achievement/list?user_id=1111", appDomain]];
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeAchievementList, GreeDashboardMode,                                 
      app_id, GreeDashboardAppId,
      @"1111", GreeDashboardUserId, nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/achievement/list?app_id=%@&user_id=1111", appDomain, app_id]];
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeAchievementList, GreeDashboardMode,                                 
      @"", GreeDashboardAppId,
      @"", GreeDashboardUserId,nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/achievement/list", appDomain]];
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeUsersList, GreeDashboardMode, nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/users", appDomain]];
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeUsersList, GreeDashboardMode,                                 
      app_id, GreeDashboardAppId, nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/users?app_id=%@", appDomain, app_id]];
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeUsersList, GreeDashboardMode,                                 
      @"1111", GreeDashboardUserId, nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/users", appDomain]];
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeUsersList, GreeDashboardMode,                                 
      @"3968", GreeDashboardAppId,
      @"1111", GreeDashboardUserId, nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/users?app_id=%@", appDomain, app_id]];
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeUsersList, GreeDashboardMode,                                 
      @"", GreeDashboardAppId,
      @"", GreeDashboardUserId, nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/users", appDomain]];
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:
      @"", GreeDashboardMode, nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/", appDomain]];
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"http://www.google.co.jp", GreeDashboardMode,                                 
      app_id, GreeDashboardAppId, nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:@"http://www.google.co.jp"];
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:
      app_id, GreeDashboardAppId, nil];
    result =  [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/?app_id=%@", appDomain, app_id]];
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeTop, GreeDashboardMode,                                 
      app_id, GreeDashboardAppId,
      @"1111", GreeDashboardUserId, nil];
    result =  [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/?app_id=%@&user_id=1111", appDomain, app_id]];
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeTop, GreeDashboardMode,                                 
      @"", GreeDashboardAppId,
      @"", GreeDashboardUserId, nil];
    result =  [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/", appDomain]];
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys: GreeDashboardModeAppSetting, GreeDashboardMode, nil];
    result =  [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/app/info/setting/view/%@", appDomain, app_id]];          
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeAppSetting, GreeDashboardMode,                                 
      app_id, GreeDashboardAppId, nil];
    result =  [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/app/info/setting/view/%@", appDomain, app_id]];          
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeAppSetting, GreeDashboardMode,                                 
      @"1111", GreeDashboardUserId, nil];
    result =  [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/app/info/setting/view/%@", appDomain, app_id]];          
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeAppSetting, GreeDashboardMode,                                 
      app_id, GreeDashboardAppId,
      @"1111", GreeDashboardUserId, nil];
    result = [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/app/info/setting/view/%@", appDomain, app_id]];          
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeAppSetting, GreeDashboardMode,                                 
      @"", GreeDashboardAppId,
      @"", GreeDashboardUserId, nil];
    result =  [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/app/info/setting/view/%@", appDomain, app_id]];          
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeAppSetting, GreeDashboardMode,                                 
      @"5555", GreeDashboardAppId,
      @"", GreeDashboardUserId, nil];
    result =  [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/gd/app/info/setting/view/%@", appDomain, app_id]];          
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeUsersInvites, GreeDashboardMode, nil];
    result =  [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/?mode=ggp&act=service_invite&view=dashboard&app_id=%@", pfDomain, app_id]];          
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeUsersInvites, GreeDashboardMode,                                 
      app_id, GreeDashboardAppId, nil];
    result =  [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/?mode=ggp&act=service_invite&view=dashboard&app_id=%@", pfDomain, app_id]];          
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeUsersInvites, GreeDashboardMode,                                 
      @"1111", GreeDashboardUserId, nil];
    result =  [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/?mode=ggp&act=service_invite&view=dashboard&app_id=%@", pfDomain, app_id]];          
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeUsersInvites, GreeDashboardMode,                                 
      app_id, GreeDashboardAppId,
      @"1111", GreeDashboardUserId, nil];
    result =  [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/?mode=ggp&act=service_invite&view=dashboard&app_id=%@", pfDomain, app_id]];          
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeUsersInvites, GreeDashboardMode,                                 
      @"", GreeDashboardAppId,
      @"", GreeDashboardUserId, nil];
    result =  [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/?mode=ggp&act=service_invite&view=dashboard&app_id=%@", pfDomain, app_id]];          
      
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:GreeDashboardModeUsersInvites, GreeDashboardMode,                                 
      @"5555", GreeDashboardAppId,
      @"", GreeDashboardUserId, nil];
    result =  [[GreeDashboardViewController dashboardURLWithParameters:parameters] absoluteString];
    [[result should] equal:[NSString stringWithFormat:@"%@/?mode=ggp&act=service_invite&view=dashboard&app_id=%@", pfDomain, app_id]];          
  });
});

SPEC_END
