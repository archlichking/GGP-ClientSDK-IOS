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
#import "GreeJSWebViewController+PullToRefresh.h"

#pragma mark - GreeJSWebViewController+PullToRefreshTests

// for mocking

@interface GreeJSWebViewController(ExposePrivateAPIS)
@end

SPEC_BEGIN(GreeJSWebViewControllerTests_PullToRefresh)

describe(@"GreeJSWebViewController+PullToRefresh", ^{
  __block GreeJSWebViewController *viewController;
  beforeEach(^{
    [GreeJSWebViewControllerTestHelper setMocksForinit];
    viewController = [[GreeJSWebViewController alloc] init];
  });
  afterEach(^{
    [viewController release];
  });
  
  context(@"when call startLoading", ^{
    it(@"should set application networkActivityIndicatorVisible YES", ^{
      UIApplication *app = [UIApplication nullMockAsSharedApplication];
      [[[app should] receive] setNetworkActivityIndicatorVisible:YES];
      [viewController startLoading];
    });
  });
});

SPEC_END
