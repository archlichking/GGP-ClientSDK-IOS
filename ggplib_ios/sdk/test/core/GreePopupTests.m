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

#import "GreePopup.h"
#import "GreePopupView.h"
#import "GreePopup+Internal.h"
#import "Kiwi.h"
#import "NSDictionary+GreeAdditions.h"
#import "GreePlatform+Internal.h"
#import "GreeSettings.h"
#import "GreeNSNotification.h"
#import "GreeTestHelpers.h"

NSString* const kGreePopupTestsAction = @"GreePopupTest";
NSString* const kGreePopupTestsSender = @"sender";
NSString* const kGreePopupTestsAppId = @"12345";

#pragma mark - GreePopup (Test)

@interface GreePopup (Test)
- (UIView *)nilView;
@end
@implementation GreePopup (Test)
- (UIView *)nilView
{
  return nil;
}
@end

#pragma mark - GreePopupTests

SPEC_BEGIN(GreePopupTests)

__block id viewOfGreePopupSwizzling = nil;

describe(@"GreePopup", ^{
  __block GreePopup<GreePopupViewDelegate> *popup = nil;
  __block GreePopup *returnPopup = nil;
  
  beforeAll(^{
    viewOfGreePopupSwizzling = [GreeTestHelpers
                                exchangeInstanceSelector:@selector(view)
                                onClass:[GreePopup class]
                                withSelector:@selector(nilView)
                                onClass:[GreePopup class]];
  });

  beforeEach(^{
    popup = [GreePopup popup];
    popup.action = kGreePopupTestsAction;
    [popup stub:@selector(dismissGreePopup)];
  });
  afterEach(^{
    popup.action = nil;
    popup = nil;
  });

	context(@"when initialized", ^{
		it(@"should setup all parameters except the action property", ^{
			[popup shouldNotBeNil];
			[[popup should] beKindOfClass:[GreePopup class]];
			[[popup.action should] equal:kGreePopupTestsAction];
			[popup.parameters shouldBeNil];
			[popup.results shouldBeNil];
		});
	});

	context(@"when initialized", ^{
		it(@"should post GreeNSNotificationKey-DidClose Notification in popupViewDidCancel", ^{
      [[popup should] receive:@selector(dismissGreePopup)];
      id notificationHandler = [[NSNotificationCenter defaultCenter]
                                addObserverForName:GreeNSNotificationKeyDidCloseNotification
                                object:nil
                                queue:[NSOperationQueue mainQueue]
                                usingBlock:^(NSNotification *notification){
                                  returnPopup = (GreePopup *)[notification.object retain];
                                }];
      [popup popupViewDidCancel];
      [[expectFutureValue(returnPopup.action) shouldEventually] equal:popup.action];

      [[NSNotificationCenter defaultCenter] removeObserver:notificationHandler];
      [returnPopup release];
		});
	});

  it(@"should post GreeNSNotificationKey-DidClose Notification in popupViewDidComplete", ^{
    NSString *dictionaryValue = @"first value";
    NSString *dictionaryKey = @"firstKey";
    NSDictionary *testDictionary = [NSDictionary dictionaryWithObject:dictionaryValue forKey:dictionaryKey];

    __block NSDictionary *returnDictionary = nil;
    id notificationHandler = [[NSNotificationCenter defaultCenter]
                              addObserverForName:GreeNSNotificationKeyDidCloseNotification
                              object:nil
                              queue:[NSOperationQueue mainQueue]
                              usingBlock:^(NSNotification *notification){
                                returnDictionary = (NSDictionary *)[notification.userInfo retain];
                              }];
    [[popup should] receive:@selector(dismissGreePopup)];
    [popup popupViewDidComplete:testDictionary];
    [[expectFutureValue([returnDictionary objectForKey:dictionaryKey]) shouldEventually] equal:[testDictionary objectForKey:dictionaryKey]];

    [[NSNotificationCenter defaultCenter] removeObserver:notificationHandler];
    [returnDictionary release];
  });

  it(@"should post GreePopup-WillLaunch Notification", ^{
    id notificationHandler = [[NSNotificationCenter defaultCenter]
                              addObserverForName:GreePopupWillLaunchNotification
                              object:nil
                              queue:[NSOperationQueue mainQueue]
                              usingBlock:^(NSNotification *notification){
                                returnPopup = [[(NSDictionary *)notification.userInfo objectForKey:kGreePopupTestsSender] retain];
                              }];
    [popup popupViewWillLaunch];
    [[expectFutureValue(returnPopup.action) shouldEventually] equal:popup.action];

    [[NSNotificationCenter defaultCenter] removeObserver:notificationHandler];
    [returnPopup release];
  });

  it(@"should post GreePopup-DidLaunch Notification", ^{
    id notificationHandler = [[NSNotificationCenter defaultCenter]
                              addObserverForName:GreePopupDidLaunchNotification
                              object:nil
                              queue:[NSOperationQueue mainQueue]
                              usingBlock:^(NSNotification *notification){
                                returnPopup = [[(NSDictionary *)notification.userInfo objectForKey:kGreePopupTestsSender] retain];
                              }];
    [popup popupViewDidLaunch];
    [[expectFutureValue(returnPopup.action) shouldEventually] equal:popup.action];

    [[NSNotificationCenter defaultCenter] removeObserver:notificationHandler];
    [returnPopup release];
  });

  it(@"should post GreePopup-WillDismiss Notification", ^{
    id notificationHandler = [[NSNotificationCenter defaultCenter]
                              addObserverForName:GreePopupWillDismissNotification
                              object:nil
                              queue:[NSOperationQueue mainQueue]
                              usingBlock:^(NSNotification *notification){
                                returnPopup = [[(NSDictionary *)notification.userInfo objectForKey:kGreePopupTestsSender] retain];
                              }];
    [popup popupViewWillDismiss];
    [[expectFutureValue(returnPopup.action) shouldEventually] equal:popup.action];

    [[NSNotificationCenter defaultCenter] removeObserver:notificationHandler];
    [returnPopup release];
  });

  it(@"should post GreePopup-DidDismiss Notification", ^{
    id notificationHandler = [[NSNotificationCenter defaultCenter]
                              addObserverForName:GreePopupDidDismissNotification
                              object:nil
                              queue:[NSOperationQueue mainQueue]
                              usingBlock:^(NSNotification *notification){
                                returnPopup = [[(NSDictionary *)notification.userInfo objectForKey:kGreePopupTestsSender] retain];
                              }];
    [popup popupViewDidDismiss];
    [[expectFutureValue(returnPopup.action) shouldEventually] equal:popup.action];

    [[NSNotificationCenter defaultCenter] removeObserver:notificationHandler];
    [returnPopup release];
  });

});

#pragma mark - GreeInvitePopup

NSMutableURLRequest*(^makeLoadRequest)(GreePopup *, NSString*) = ^(GreePopup *popup, NSString* appId){
  NSString *endPoint = @"endPoint";
  [GreePlatform stub:@selector(sharedInstance) andReturn:[GreePlatform nullMock]];
  GreeSettings* settings = [GreeSettings nullMock];
  [settings stub:@selector(stringValueForSetting:) andReturn:endPoint];
  if ([appId length] > 0) {
    [settings stub:@selector(objectValueForSetting:) andReturn:appId];
  }
  [[GreePlatform sharedInstance] stub:@selector(settings) andReturn:settings];

  NSString *anUrlString = [NSString stringWithFormat:@"%@/?mode=ggp&act=%@", endPoint, popup.action];
  NSMutableURLRequest *aRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:anUrlString]];

  NSDictionary *bodyDictionary = ([appId length] > 0)
  ?[NSDictionary dictionaryWithObject:appId forKey:@"app_id"]
  :[NSMutableDictionary dictionary];

  [aRequest setHTTPBody:[[bodyDictionary greeBuildQueryString] dataUsingEncoding:NSUTF8StringEncoding]];
  [aRequest setHTTPMethod:@"POST"];
  return aRequest;
};

describe(@"GreeInvitePopup", ^{

  __block GreeInvitePopup *popup = nil;

  beforeEach(^{
    popup = [GreeInvitePopup popup];
    [popup stub:@selector(loadRequest:)];
  });
  afterEach(^{
    popup = nil;
  });

	context(@"when initialized", ^{
		it(@"should setup all parameters except the action property", ^{
			[popup shouldNotBeNil];
			[[popup should] beKindOfClass:[GreeInvitePopup class]];
			[[popup.action should] equal:GreePopupInviteAction];
			[popup.parameters shouldBeNil];
			[popup.results shouldBeNil];
		});
	});

  context(@"when loading", ^{
    it(@"should receive loadRequest:", ^{
      [[[popup should] receive] loadRequest:makeLoadRequest(popup, nil)];
      [popup load];
    });
  });

});

#pragma mark - GreeSharePopup

describe(@"GreeSharePopup", ^{

  __block GreeSharePopup *popup = nil;

  beforeEach(^{
    popup = [GreeSharePopup popup];
    [popup stub:@selector(loadRequest:)];
  });
  afterEach(^{
    popup = nil;
  });

  context(@"when initialized", ^{
		it(@"should setup all parameters except the action property", ^{
			[popup shouldNotBeNil];
			[[popup should] beKindOfClass:[GreeSharePopup class]];
			[[popup.action should] equal:GreePopupShareAction];
			[popup.parameters shouldBeNil];
			[popup.results shouldBeNil];
    });
  });

  context(@"when loading", ^{
    it(@"should receive loadRequest:", ^{
      [[[popup should] receive] loadRequest:makeLoadRequest(popup, nil)];
      [popup load];
    });
  });

});

#pragma mark - GreeRequestServicePopup

describe(@"GreeRequestServicePopup", ^{
  __block GreeRequestServicePopup *popup = nil;

  beforeEach(^{
    popup = [GreeRequestServicePopup popup];
    [popup stub:@selector(loadRequest:)];
  });
  afterEach(^{
    popup = nil;
  });

  context(@"when initialized", ^{
		it(@"should setup all parameters except the action property", ^{
      popup = [GreeRequestServicePopup popup];
			[popup shouldNotBeNil];
			[[popup should] beKindOfClass:[GreeRequestServicePopup class]];
			[[popup.action should] equal:GreePopupRequestServiceAction];
			[popup.parameters shouldBeNil];
			[popup.results shouldBeNil];
    });

  });

  context(@"when loading", ^{
    it(@"should receive loadRequest:", ^{
      [[[popup should] receive] loadRequest:makeLoadRequest(popup, kGreePopupTestsAppId)];
      [popup load];
    });
  });
});

describe(@"restore", ^{
  it(@"restore Swizzling", ^{
    [GreeTestHelpers restoreExchangedSelectors:&viewOfGreePopupSwizzling];
  });
});

SPEC_END
