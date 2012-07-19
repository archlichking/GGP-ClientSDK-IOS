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
#import "GreeURLMockingProtocol.h"
#import "GreeWebSession.h"
#import "GreeError+Internal.h"
#import "NSHTTPCookieStorage+GreeAdditions.h"
#import "GreePlatform+Internal.h"
#import "GreeHTTPClient.h"
#import "GreeSettings.h"

#pragma mark - GreeWebSessionTests

SPEC_BEGIN(GreeWebSessionTests)

describe(@"GreeWebSession", ^{
  
  beforeEach(^{
    [GreeURLMockingProtocol register];
    id settings = [GreeSettings nullMock];
    [settings stub:@selector(stringValueForSetting:) andReturn:GreeDevelopmentModeProduction withArguments:GreeSettingDevelopmentMode];
    [settings stub:@selector(stringValueForSetting:) andReturn:@"test.gree.net" withArguments:GreeSettingServerUrlDomain];
    id platform = [GreePlatform nullMockAsSharedInstance];
    [platform stub:@selector(httpClient) andReturn:[GreeHTTPClient nullMock]];
    [platform stub:@selector(settings) andReturn:settings];
  });
  
  afterEach(^{
    [GreeURLMockingProtocol unregister];
  });

  it(@"should invoke block with nil upon successful regeneration", ^{
    __block BOOL finished = NO;
    MockedURLResponse* response = [MockedURLResponse getResponseWithHttpStatus:200];
    response.data = [@"{ \"entry\" : { \"gssid\" : \"DERP\" } }" dataUsingEncoding:NSUTF8StringEncoding];
    [GreeURLMockingProtocol addMock:response];
    [GreeWebSession regenerateWebSessionWithBlock:^(NSError* error) {
      [error shouldBeNil];
      [[[NSHTTPCookieStorage greeGetCookieValueWithName:@"gssid" domain:@"test.gree.net"] should] equal:@"DERP"];
      finished = YES;
    }];
    [[expectFutureValue(theValue(finished)) shouldEventuallyBeforeTimingOutAfter(1.f)] beYes];
  });

  it(@"should use correct cookie name in sandbox mode", ^{
    [[[GreePlatform sharedInstance] settings] stub:@selector(stringValueForSetting:) andReturn:GreeDevelopmentModeSandbox withArguments:GreeSettingDevelopmentMode];

    __block BOOL finished = NO;
    MockedURLResponse* response = [MockedURLResponse getResponseWithHttpStatus:200];
    response.data = [@"{ \"entry\" : { \"gssid\" : \"DERP\" } }" dataUsingEncoding:NSUTF8StringEncoding];
    [GreeURLMockingProtocol addMock:response];
    [GreeWebSession regenerateWebSessionWithBlock:^(NSError* error) {
      [error shouldBeNil];
      [[[NSHTTPCookieStorage greeGetCookieValueWithName:@"gssid_smsandbox" domain:@"test.gree.net"] should] equal:@"DERP"];
      finished = YES;
    }];
    [[expectFutureValue(theValue(finished)) shouldEventuallyBeforeTimingOutAfter(1.f)] beYes];

    [[[GreePlatform sharedInstance] settings] stub:@selector(stringValueForSetting:) andReturn:GreeDevelopmentModeProduction withArguments:GreeSettingDevelopmentMode];
  });

  it(@"should invoke block with error upon failed regeneration", ^{
    __block BOOL finished = NO;
    MockedURLResponse* response = [MockedURLResponse getResponseWithHttpStatus:404];
    response.error = [NSError errorWithDomain:@"testDomain" code:0 userInfo:nil];
    [GreeURLMockingProtocol addMock:response];
    [GreeWebSession regenerateWebSessionWithBlock:^(NSError* error) {
      [error shouldNotBeNil];
      [[theValue([error code]) should] equal:theValue(0)];
      [[[error domain] should] equal:@"testDomain"];
      finished = YES;
    }];
    [[expectFutureValue(theValue(finished)) shouldEventuallyBeforeTimingOutAfter(1.f)] beYes];
  });

  it(@"should invoke block with correct error code if response succeeds but is malformed", ^{
    __block BOOL finished = NO;
    [GreeURLMockingProtocol addMock:[MockedURLResponse getResponseWithHttpStatus:200]];
    [GreeWebSession regenerateWebSessionWithBlock:^(NSError* error) {
      [error shouldNotBeNil];
      [[theValue([error code]) should] equal:theValue(GreeErrorCodeWebSessionResponseUnrecognized)];
      [[[error domain] should] equal:GreeErrorDomain];
      finished = YES;
    }];
    [[expectFutureValue(theValue(finished)) shouldEventuallyBeforeTimingOutAfter(1.f)] beYes];
  });

  context(@"while observing", ^{
    __block id handle = nil;
    __block NSString* sawChange = nil;

    beforeEach(^{
      sawChange = nil;
      handle = [GreeWebSession observeWebSessionChangesWithBlock:^{
        sawChange = @"observer";
      }];

      MockedURLResponse* response = [MockedURLResponse getResponseWithHttpStatus:200];
      response.data = [@"{ \"entry\" : { \"gssid\" : \"DERP\" } }" dataUsingEncoding:NSUTF8StringEncoding];
      [GreeURLMockingProtocol addMock:response];
    });
    
    afterEach(^{
      [GreeWebSession stopObservingWebSessionChanges:handle];
      handle = nil;
    });
    
    it(@"should observe a change", ^{
      [GreeWebSession regenerateWebSessionWithBlock:nil];
      [[expectFutureValue(sawChange) shouldEventuallyBeforeTimingOutAfter(1.f)] equal:@"observer"];
    });
    
    it(@"should not observe a change after stop", ^{
      [GreeWebSession stopObservingWebSessionChanges:handle];
      handle = nil;

      [GreeWebSession regenerateWebSessionWithBlock:^(NSError* error) {
        if (!sawChange) {
          sawChange = @"finished";
        }
      }];

      [[expectFutureValue(sawChange) shouldEventuallyBeforeTimingOutAfter(1.f)] equal:@"finished"];
    });
  });

  it(@"should gracefully handle observe with nil", ^{
    id handle = [GreeWebSession observeWebSessionChangesWithBlock:nil];
    [handle shouldBeNil];
  });

  it(@"should gracefully handle stop observing with nil", ^{
    [GreeWebSession stopObservingWebSessionChanges:nil];
    [[theValue(YES) should] beYes];
  });
  
});

SPEC_END
