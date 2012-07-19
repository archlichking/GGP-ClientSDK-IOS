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
#import "GreeJSWebViewControllerTestHelper.h"

#import "GreeJSWebViewController.h"
#import "GreeJSWebViewController+StateCommand.h"

#import <Foundation/Foundation.h>


#pragma mark - GreeJSWebViewController+StateCommandTests

// for mocking

@interface GreeJSWebViewController(ExposePrivateAPIS)
@end

SPEC_BEGIN(GreeJSWebViewControllerTests_StateCommand)

describe(@"GreeJSWebViewController+StateCommand", ^{
  __block GreeJSWebViewController *viewController;
  beforeEach(^{
    [GreeJSWebViewControllerTestHelper setMocksForinit];
    viewController = [[GreeJSWebViewController alloc] init];
  });
  afterEach(^{
    [viewController release];
  });
  
  context(@"call stateCommandReady", ^{
    it(@"should post notification", ^{
      [UIApplication stub:@selector(sharedApplication)];
      [NSNotification stub:@selector(notificationWithName:object:userInfo:)];
      NSNotificationCenter *nc = [NSNotificationCenter nullMockAsDefaultCenter];
      [[nc should] receive:@selector(postNotification:)];
      [viewController stateCommandReady];
    });
  });
});

SPEC_END
