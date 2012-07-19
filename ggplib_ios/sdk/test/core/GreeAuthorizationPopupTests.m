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
#import "GreeAuthorizationPopup.h"
#import "GreeTestHelpers.h"

SPEC_BEGIN(GreeAuthorizationPopupTests)

__block id viewOfgreePopupSwizzling = nil;

describe(@"GreeAuthorizationPopupTests", ^{

  __block GreeAuthorizationPopup *popup = nil;

  beforeAll(^{
    viewOfgreePopupSwizzling = [GreeTestHelpers
                              exchangeInstanceSelector:@selector(view)
                              onClass:[GreePopup class]
                              withSelector:@selector(nilView)
                              onClass:[GreePopup class]];
  });

  beforeEach(^{
    popup = [GreeAuthorizationPopup popup];
    [popup stub:@selector(loadHTMLString:baseURL:)];
  });
  afterEach(^{
    popup = nil;
  });

  context(@"when initialized", ^{

    it(@"should setup all parameters except the action property", ^{
      popup = [GreeAuthorizationPopup popup];
      [popup shouldNotBeNil];
      [[popup should] beKindOfClass:[GreeAuthorizationPopup class]];
      [popup.parameters shouldBeNil];
      [popup.results shouldBeNil];
    });

  });

  context(@"when loading", ^{
    it(@"should load ErrorPage On NotWebAccess", ^{
      popup.lastRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://dummy"]];
      [popup stub:@selector(loadHTMLString:baseURL:)];
      [NSURL stub:@selector(fileURLWithPath:)];

      [[[popup should] receive] loadHTMLString:nil baseURL:nil];
      [popup loadErrorPageOnNotWebAccess:nil];
    });
  });

  context(@"when loading", ^{
    it(@"should load ErrorPage On OAuthError", ^{
      popup.lastRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://dummy"]];
      [popup stub:@selector(loadHTMLString:baseURL:)];
      [NSURL stub:@selector(fileURLWithPath:)];

      [[[popup should] receive] loadHTMLString:nil baseURL:nil];
      [popup loadErrorPageOnNotWebAccess:nil];
    });
  });

});

describe(@"restore", ^{
  it(@"restore Swizzling", ^{
    [GreeTestHelpers restoreExchangedSelectors:&viewOfgreePopupSwizzling];
  });
});

SPEC_END
