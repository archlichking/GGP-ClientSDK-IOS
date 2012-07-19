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

#import "GreeJSWebViewControllerTestHelper.h"

#import "Kiwi.h"
#import "GreeTestHelpers.h"

#import "GreeJSWebViewController.h"
#import "GreeJSWebViewController+PullToRefresh.h"
#import "GreeJSWebViewController+StateCommand.h"
#import "GreeJSWebViewController+Photo.h"
#import "GreeJSWebViewController+ModalView.h"
#import "GreeJSWebViewController+SubNavigation.h"
#import "GreeJSWebViewControllerPool.h"
#import "GreeJSHandler.h"
#import "GreeJSCommandEnvironment.h"
#import "GreeJSWebViewMessageEvent.h"
#import "GreeJSSubnavigationView.h"
#import "GreeJSSubnavigationMenuView.h"
#import "GreeJSPullToRefreshHeaderView.h"
#import "GreeJSLoadingIndicatorView.h"
#import "GreeJSPullToRefreshHeaderView.h"
#import "GreeNotificationBoardViewController.h"
#import "GreeJSInputViewController.h"

static UIWebView *webView;
static GreeJSHandler *handler;
static GreeJSSubnavigationView *subNav;
static GreeJSLoadingIndicatorView *liView;
static GreeJSPullToRefreshHeaderView *header;

@implementation GreeJSWebViewControllerTestHelper
+ (void)setMocksForinit
{
  webView = [UIWebView nullMock];
  [webView stub:@selector(initWithFrame:) andReturn:nil];
  [UIWebView stub:@selector(alloc) andReturn:webView];
  
  handler = [GreeJSHandler nullMock];
  [handler stub:@selector(init) andReturn:handler];
  [GreeJSHandler stub:@selector(alloc) andReturn:handler];
  
  subNav = [GreeJSSubnavigationView nullMock];
  [subNav stub:@selector(initWithDelegate:) andReturn:subNav];
  [subNav stub:@selector(autorelease) andReturn:subNav];
  [GreeJSSubnavigationView stub:@selector(alloc) andReturn:subNav];
  
  liView = [GreeJSLoadingIndicatorView nullMock];
  [liView stub:@selector(initWithLoadingIndicatorType:) andReturn:liView];
  [GreeJSLoadingIndicatorView stub:@selector(alloc) andReturn:liView];
  
  header = [GreeJSPullToRefreshHeaderView nullMock];
  [webView stub:@selector(init) andReturn:header];
  [GreeJSPullToRefreshHeaderView stub:@selector(alloc) andReturn:header];  
}
@end
