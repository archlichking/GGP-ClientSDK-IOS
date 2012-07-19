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
#import "GreeJSWebViewController+StateCommand.h"
#import "GreeJSWebViewController+Photo.h"
#import "GreeJSWebViewController+ModalView.h"
#import "GreeJSWebViewController+SubNavigation.h"
#import "GreeJSWebViewControllerPool.h"
#import "GreeJSCommandEnvironment.h"
#import "GreeJSWebViewMessageEvent.h"
#import "GreeJSSubnavigationView.h"
#import "GreeJSSubnavigationMenuView.h"
#import "GreeJSPullToRefreshHeaderView.h"
#import "GreeJSLoadingIndicatorView.h"
#import "GreeJSPullToRefreshHeaderView.h"
#import "GreeNotificationBoardViewController.h"

#import "GreeSettings.h"
#import "GreePlatform+Internal.h"
#import "GreeHTTPClient.h"
#import "GreeWebSessionRegenerator.h"
#import "NSString+GreeAdditions.h"
#import "UIWebView+GreeAdditions.h"
#import "NSBundle+GreeAdditions.h"
#import "UIImage+GreeAdditions.h"
#import "GreeLogger.h"
#import "NSURL+GreeAdditions.h" 

#pragma mark - GreeJSWebViewControllerTests

@interface GreeJSWebViewController(ExposePrivateAPIS)
@property(assign) BOOL isProton;
@property(assign) BOOL isDragging;
@property(assign) BOOL isPullLoading;
@property(nonatomic, retain) NSTimer *pullToRefreshTimeoutTimer;
@property(readonly) UIView *pullToRefreshBackground;
@property(readonly) GreeJSPullToRefreshHeaderView *pullToRefreshHeader;
@property(nonatomic, readwrite, retain) GreeJSSubnavigationView* subNavigationView;
@property(nonatomic, assign) BOOL connectionFailureContentsLoading;
@property(nonatomic, readwrite, assign) BOOL deadlyProtonErrorOccured;
@property(nonatomic, retain) NSSet *previousOrientations;

- (void)adjustWebViewContentInset;
- (void)onBackButtonPressed;
- (void)messageEventNotification:(NSNotification*)notification;
- (void)showHTTPErrorMessage:(NSError*)anError;
- (BOOL)shouldHandleRequest:(NSURLRequest*)request;
- (BOOL)handleSchemeItmsApps:(NSURLRequest*)request;

// +modalView
- (void)greeJSPresentModalNavigationController:(GreeJSModalNavigationController *)navigationController
                                      animated:(BOOL)animated;
@end

SPEC_BEGIN(GreeJSWebViewControllerTests)

describe(@"GreeJSWebViewController", ^{
  beforeEach(^{
    [GreeJSWebViewControllerTestHelper setMocksForinit];
  });
  
  context(@"when initializing", ^{
    it(@"should initialize", ^{
      GreeJSWebViewController *viewController = [[GreeJSWebViewController alloc] init];
      [viewController shouldNotBeNil];
      [viewController release];
    });
    
    it(@"should set the correct values", ^{
      GreeJSWebViewController *viewController = [[GreeJSWebViewController alloc] init];
      [viewController.subNavigationView shouldNotBeNil];
      [[theValue([viewController subnavigationMenuIsDisplayed]) should] beTrue];
      
      // viewController.webView should not be nil
      // but mock doesn't works fine
      
      [viewController.loadingIndicatorView shouldNotBeNil];
      [viewController.pullToRefreshHeader shouldNotBeNil];
      [viewController.pullToRefreshBackground shouldNotBeNil];
      [[theValue(viewController.canPullToRefresh) should] beYes];
      [viewController.modalRightButtonCallback shouldBeNil];
      [viewController.modalRightButtonCallbackInfo shouldBeNil];
      [viewController release];
    });
    
    it(@"should add observers", ^{
      [[[NSNotificationCenter defaultCenter] should] receive:@selector(addObserver:selector:name:object:) withCountAtLeast:3];
      GreeJSWebViewController *viewController = [[GreeJSWebViewController alloc] init];
      [NSNotificationCenter clearStubs];
      [viewController release];
    });
  });
  
  context(@"normally", ^{
    __block GreeJSWebViewController *viewController;
    beforeEach(^{
      [GreeJSWebViewControllerTestHelper setMocksForinit];
      viewController = [[GreeJSWebViewController alloc] init];
    });
    afterEach(^{
      [viewController release];
    });
    
    context(@"when view will appear", ^{
      context(@"when nextViewController is not nil", ^{
        it(@"should set nextViewController nil", ^{ 
          viewController.nextWebViewController = [GreeJSWebViewController mock];
          BOOL someBool = true;
          [viewController viewWillAppear:someBool];
          [viewController.nextWebViewController shouldBeNil];
        });
      });
      
      context(@"when nextViewController is nil", ^{
        it(@"should do nothing but call super methods", ^{
          viewController.nextWebViewController = nil;
          BOOL someBool = true;
          [viewController viewWillAppear:someBool];
          [viewController.nextWebViewController shouldBeNil];
        });
      });
    });
    
    context(@"when call shouldAutorotateToInterfaceOrientation:", ^{
      context(@"when manually rotate", ^{
        it(@"should return GreePlatform interfaceOrientation value and an arg equality", ^{
          GreePlatform *platform = [GreePlatform nullMockAsSharedInstance];
          [[platform should] receive:@selector(manuallyRotate) andReturn:theValue(YES)];
          
          // some diffrent values
          UIInterfaceOrientation arg = UIInterfaceOrientationPortrait;
          [[platform should] receive:@selector(interfaceOrientation) andReturn:theValue(UIInterfaceOrientationLandscapeLeft)];
          
          [[theValue([viewController shouldAutorotateToInterfaceOrientation:arg]) should] beNo];
        });
      });
      
      context(@"when not manually rotate", ^{
        it(@"should return YES", ^{
          GreePlatform *platform = [GreePlatform nullMockAsSharedInstance];
          [[platform should] receive:@selector(manuallyRotate) andReturn:theValue(NO)];
          
          // some value
          UIInterfaceOrientation arg = UIInterfaceOrientationPortrait;
          
          [[platform shouldNot] receive:@selector(interfaceOrientation)];
          
          [[theValue([viewController shouldAutorotateToInterfaceOrientation:arg]) should] beYes];
        });
      });
    });
  });
});

SPEC_END
