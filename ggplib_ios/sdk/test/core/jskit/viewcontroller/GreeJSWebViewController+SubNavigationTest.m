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
#import "GreeJSWebViewController+SubNavigation.h"

#pragma mark - GreeJSWebViewController+SubNavigationTests

@interface GreeJSWebViewController(ExposePrivateAPIS)
  @property(nonatomic, readwrite, retain) GreeJSSubnavigationView* subNavigationView;
@end

SPEC_BEGIN(GreeJSWebViewControllerTests_SubNavigation)

describe(@"GreeJSWebViewController+SubNavigation", ^{
  __block GreeJSWebViewController *viewController;
  beforeEach(^{
    [GreeJSWebViewControllerTestHelper setMocksForinit];
    viewController = [[GreeJSWebViewController alloc] init];
  });
  afterEach(^{
    [viewController release];
  });
  
  context(@"when configure subnavigation Menu", ^{
    it(@"should configure self.subNavigationView", ^{
      NSDictionary *params = [NSDictionary mock];
      [[viewController.subNavigationView should] receive:@selector(configureSubnavigationMenuWithParams:)];
      [viewController configureSubnavigationMenuWithParams:params];
    });
  });
  
  context(@"on SubnavigationMenuButton tap", ^{
    it(@"should call handler callback", ^{
      GreeJSSubnavigationIconView *button = [GreeJSSubnavigationIconView mock];
      [[button should] receive:@selector(callback)];
      [[button should] receive:@selector(callbackParams)];
      [[button should] receive:@selector(tag)];
      [[viewController.handler should] receive:@selector(callback:params:)];
      [viewController onSubnavigationMenuButtonIconTap:button];
    });
  });
});

SPEC_END
