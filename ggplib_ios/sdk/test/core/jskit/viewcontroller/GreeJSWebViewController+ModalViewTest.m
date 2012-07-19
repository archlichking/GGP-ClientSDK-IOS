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
#import "GreeJSWebViewController+ModalView.h"

// for mocking
#import "GreeJSInputViewController.h"

#pragma mark - GreeJSWebViewController+ModalViewTests


SPEC_BEGIN(GreeJSWebViewControllerTests_ModalView)

describe(@"GreeJSWebViewController+ModalView", ^{
  __block GreeJSWebViewController *viewController;
  beforeEach(^{
    [GreeJSWebViewControllerTestHelper setMocksForinit];
    viewController = [[GreeJSWebViewController alloc] init];
  });
  afterEach(^{
    [viewController release];
  });

  context(@"when greeJSModalRightButtonFailure", ^{
    it(@"should remove observers and show alert view", ^{
      [[[NSNotificationCenter defaultCenter] should] receive:@selector(removeObserver:name:object:) withCountAtLeast:2];
      NSNotification *notify = [NSNotification mock];
      [notify stub:@selector(userInfo)];
      UIAlertView *av = [UIAlertView mock];
      [av stub:@selector(initWithTitle:message:delegate:cancelButtonTitle:otherButtonTitles:) andReturn:av];
      [[av should] receive:@selector(show)];
      [UIAlertView stub:@selector(alloc) andReturn:av];

      [viewController greeJSModalRightButtonFailure:notify];

      [NSNotificationCenter clearStubs];
    });

    context(@"when input view is shown", ^{
      it(@"should hide indicator", ^{
        [[[NSNotificationCenter defaultCenter] should] receive:@selector(removeObserver:name:object:) withCountAtLeast:2];
        NSNotification *notify = [NSNotification mock];
        [notify stub:@selector(userInfo)];
        UIAlertView *av = [UIAlertView mock];
        [av stub:@selector(initWithTitle:message:delegate:cancelButtonTitle:otherButtonTitles:) andReturn:av];
        [[av should] receive:@selector(show)];
        [UIAlertView stub:@selector(alloc) andReturn:av];

        GreeJSInputViewController *ivc = [GreeJSInputViewController mock];
        viewController.inputViewController = ivc;
        [[ivc should] receive:@selector(hideIndicator)];
        [[[ivc should] receive] setUserInteractionEnabled:YES];

        [viewController greeJSModalRightButtonFailure:notify];

        [NSNotificationCenter clearStubs];
      });
    });

    context(@"when input view is not shown", ^{
      it(@"should hide indicator", ^{
        [[[NSNotificationCenter defaultCenter] should] receive:@selector(removeObserver:name:object:) withCountAtLeast:2];
        NSNotification *notify = [NSNotification mock];
        [notify stub:@selector(userInfo)];
        UIAlertView *av = [UIAlertView mock];
        [av stub:@selector(initWithTitle:message:delegate:cancelButtonTitle:otherButtonTitles:) andReturn:av];
        [[av should] receive:@selector(show)];
        [UIAlertView stub:@selector(alloc) andReturn:av];

        viewController.inputViewController = nil;
        [[[viewController should] receive] displayLoadingIndicator:NO];
        [[viewController should] receive:@selector(navigationItem) withCount:2];
        [[viewController should] receive:@selector(view)];

        [viewController greeJSModalRightButtonFailure:notify];

        [NSNotificationCenter clearStubs];
      });
    });
  });

  context(@"when greeJSModalRightButtonSucceed", ^{
    it(@"should remove observers", ^{
      [[[NSNotificationCenter defaultCenter] should] receive:@selector(removeObserver:name:object:) withCountAtLeast:2];
      NSNotification *notify = [NSNotification mock];

      [viewController greeJSModalRightButtonSucceed:notify];

      [NSNotificationCenter clearStubs];
    });

    context(@"when input view is shown", ^{
      it(@"should hide indicator", ^{
        [[[NSNotificationCenter defaultCenter] should] receive:@selector(removeObserver:name:object:) withCountAtLeast:2];
        NSNotification *notify = [NSNotification mock];

        GreeJSInputViewController *ivc = [GreeJSInputViewController mock];
        viewController.inputViewController = ivc;
        [[ivc should] receive:@selector(hideIndicator)];
        [[[ivc should] receive] setUserInteractionEnabled:YES];

        [viewController greeJSModalRightButtonSucceed:notify];

        [NSNotificationCenter clearStubs];
      });
    });

    context(@"when input view is not shown", ^{
      it(@"should hide indicator", ^{
        GreeJSWebViewController *viewController = [[GreeJSWebViewController alloc] init];
        [[[NSNotificationCenter defaultCenter] should] receive:@selector(removeObserver:name:object:) withCountAtLeast:2];
        NSNotification *notify = [NSNotification mock];

        viewController.inputViewController = nil;
        [[[viewController should] receive] displayLoadingIndicator:NO];
        [[viewController should] receive:@selector(navigationItem) withCount:2];
        [[viewController should] receive:@selector(view)];

        [viewController greeJSModalRightButtonSucceed:notify];

        [NSNotificationCenter clearStubs];
        [viewController release];
      });
    });
  });
});

SPEC_END
