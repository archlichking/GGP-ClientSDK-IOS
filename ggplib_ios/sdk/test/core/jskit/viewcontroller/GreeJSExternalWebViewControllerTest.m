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

#import "GreeJSExternalWebViewController.h"

#pragma mark - GreeJSExternalWebViewControllerTests


SPEC_BEGIN(GreeJSExternalWebViewControllerTests)

describe(@"GreeJSExternalWebViewController", ^{
  context(@"when initializing", ^{
    it(@"should initialize with url", ^{
      NSURL *url = [NSURL nullMock];
      UIWebView *webView = [UIWebView nullMock];
      [webView stub:@selector(initWithFrame:) andReturn:nil];
      [UIWebView stub:@selector(alloc) andReturn:webView];
      UIImageView *imageView = [UIImageView nullMock];
      [imageView stub:@selector(initWithImage:) andReturn:imageView];
      [UIImageView stub:@selector(alloc) andReturn:imageView];
      GreeJSExternalAddressBarView *abv = [GreeJSExternalAddressBarView nullMock];
      [GreeJSExternalAddressBarView stub:@selector(alloc) andReturn:abv];
      [abv stub:@selector(initWithFrame:) andReturn:abv];
      GreeJSExternalWebViewController *viewController = [[GreeJSExternalWebViewController alloc] initWithURL:url];
      [viewController release];
    });
  });
});

SPEC_END
