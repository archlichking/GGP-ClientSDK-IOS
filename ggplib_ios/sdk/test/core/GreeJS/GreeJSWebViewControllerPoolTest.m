//
// Copyright 2012 GREE International, Inc.
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
#import "GreeJSWebViewControllerPool.h"
#import "GreeJSWebViewController.h"

#pragma mark - GreeJSWebViewControllerPoolTest

@interface GreeJSTestWebViewController : GreeJSWebViewController
@end
@implementation GreeJSTestWebViewController
@end

SPEC_BEGIN(GreeJSWebViewControllerPoolTest)

describe(@"GreeJSWebViewControllerPoolTest",^{
  __block GreeJSWebViewController *controllerMock;
  __block GreeJSTestWebViewController *testControllerMock;

  beforeEach(^{
    controllerMock = [GreeJSWebViewController nullMock];
    testControllerMock = [GreeJSTestWebViewController nullMock];
    [GreeJSWebViewController stub:@selector(alloc) andReturn:controllerMock];
    [GreeJSTestWebViewController stub:@selector(alloc) andReturn:testControllerMock];
  });
  
  it(@"should be able to provide next webview controller", ^{
    GreeJSWebViewController *instance = [[GreeJSWebViewControllerPool sharedInstance] take];
    [instance shouldNotBeNil];
    [[instance should] beKindOfClass:[GreeJSWebViewController class]];
  });
  
  it(@"should be able to change base class for webview controller instance", ^{
    GreeJSWebViewControllerPool *pool = [GreeJSWebViewControllerPool sharedInstance];
    pool.baseClass = [GreeJSTestWebViewController class];
    id instance = [pool take];
    [instance shouldNotBeNil];
    [[instance should] beKindOfClass:[GreeJSTestWebViewController class]];
  });
  
  it(@"should return new controller instance when obtaining", ^{
    GreeJSWebViewController *instance1 = [[GreeJSWebViewControllerPool sharedInstance] take];
    GreeJSWebViewController *instance2 = [[GreeJSWebViewControllerPool sharedInstance] take];
    [instance1 shouldNotBeNil];
    [instance2 shouldNotBeNil];
    [[instance1 shouldNot] equal:instance2];
  });

});

SPEC_END
