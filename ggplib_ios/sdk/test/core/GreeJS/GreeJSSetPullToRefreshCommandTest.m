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
#import "GreeJSSetPullToRefreshEnabledCommand.h"
#import "GreeJSWebViewController+PullToRefresh.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSSetPullToRefreshEnabledCommandTest)

describe(@"GreeJSSetPullToRefreshEnabledCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSSetPullToRefreshEnabledCommand name] should] equal:@"set_pull_to_refresh_enabled"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSSetPullToRefreshEnabledCommand *command = [[GreeJSSetPullToRefreshEnabledCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSSetPullToRefreshEnabledCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should do nothing if the current view controller is not a GreeJSWebViewController", ^{
      UIViewController *currentViewController = [UIViewController nullMock];
      [[currentViewController shouldNot] receive:@selector(setCanPullToRefresh:)];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSSetPullToRefreshEnabledCommand *command = [[GreeJSSetPullToRefreshEnabledCommand alloc] init];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });

    it(@"should set the view controller to refresh if the enabled parameters is YES", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithBool:YES], @"enabled",
        nil];
    
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [[[currentViewController should] receive] setCanPullToRefresh:YES];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSSetPullToRefreshEnabledCommand *command = [[GreeJSSetPullToRefreshEnabledCommand alloc] init];
      command.environment = environment;
      [command execute:parameters];
      [command release];
    });

    it(@"should setCanPullToRefresh to NO if there is not an enabled parameter with a value of YES", ^{
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [[[currentViewController should] receive] setCanPullToRefresh:NO];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSSetPullToRefreshEnabledCommand *command = [[GreeJSSetPullToRefreshEnabledCommand alloc] init];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });
  });
});

SPEC_END
