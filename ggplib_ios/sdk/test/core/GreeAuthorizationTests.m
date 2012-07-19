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
#import "KiwiMacros.h"
#import "GreeAuthorization.h"
#import "GreeTestHelpers.h"
#import "GreeSettings.h"
#import "GreeURLMockingProtocol.h"
#import "GreeKeyChain.h"
#import "GreeAuthorizationPopup.h"
#import "GreeWebSession.h"
#import "GreeSSO.h"
#import "NSString+GreeAdditions.h"

NSString* const kGreeAuthorizationTestsConsumerKey = @"12345";
NSString* const kGreeAuthorizationTestsConsumerSecret = @"6789";

NSString* const kGreeAuthorizationTestsUserOAuthKey = @"oauth_key";
NSString* const kGreeAuthorizationTestsUserOAuthSecret = @"oauth_secret";

NSString* const kGreeAuthorizationTestsOAuthTokenKey = @"oauth_token";
NSString* const kGreeAuthorizationTestsOAuthTokenValue = @"oauthTokenValue";
NSString* const kGreeAuthorizationTestsOAuthTokenSecretKey = @"oauth_token_secret";
NSString* const kGreeAuthorizationTestsOAuthTokenSecretValue = @"oauthTokenSecretValue";
NSString* const kGreeAuthorizationTestsOAuthTokenUserIdValue = @"userIdValue";

NSString* const kGreeAuthorizationTestsOAuthRequestTokenUrlQuery = @"oauth_token=oauthTokenValue&oauth_token_secret=oauthTokenSecretValue";
NSString* const kGreeAuthorizationTestsOAuthAccessTokenUrlQuery = @"oauth_token=oauthTokenValue&oauth_token_secret=oauthTokenSecretValue&user_id=userIdValue";

NSString* const kGreeAuthorizationTestsUserIdIdentifier = @"UserIdIdentifier";
NSString* const kGreeAuthorizationTestsAccessTokenIdentifier = @"AccessTokenIdentifier";
NSString* const kGreeAuthorizationTestsAccessTokenSecretIdentifier = @"AccessTokenSecretIdentifier";

NSString* const kGreeAuthorizationTestsServerUrlId = @"serverUrlId";
NSString* const kGreeAuthorizationTestsServiceString = @"serviceString";

NSString* const kGreeAuthorizationTestsBlockSuccess = @"success";
NSString* const kGreeAuthorizationTestsBlockFailure = @"fail";



typedef enum {
	AuthorizationStatusInit,
	AuthorizationStatusEnter,
	AuthorizationStatusRequestTokenBeforeGot,
	AuthorizationStatusRequestTokenGot,
	AuthorizationStatusAuthorizationSuccess,
	AuthorizationStatusAccessTokenGot,
} AuthorizationStatus;

typedef enum {
	AuthorizationTypeDefault,
	AuthorizationTypeUpgrade,
	AuthorizationTypeSSOServer,
	AuthorizationTypeSSOLegacyServer,
	AuthorizationTypeLogout,
} AuthorizationType;

typedef void (^GreeAuthorizationUpgradeBlock)(void);
typedef void (^GreeAuthorizationReAuthorizeBlock)(void);

#pragma mark - Category
@interface GreeAuthorization()
+ (GreeAuthorization*)sharedInstance;
- (BOOL)isSavedAccessToken;
- (void)authorizeAction:(NSMutableDictionary*)params;
- (void)openURLAction:(NSURL*)url;

- (void)loadTopPage:(NSMutableDictionary*)params;
- (void)loadEnterPage:(NSMutableDictionary*)params;
- (void)loadAuthorizePage:(NSMutableDictionary*)params;
- (void)loadConfirmUpgradePage:(NSDictionary*)params;
- (void)loadUpgradePage:(NSMutableDictionary*)params;
- (void)loadConfirmReAuthorizePage;
- (void)loadSSOAcceptPage;
- (void)loadLogoutPage;

- (void)popupLaunch;
- (void)popupDismiss;
- (void)getGreeUUIDWithParams:(NSMutableDictionary*)params;
- (void)getTokenWithParams:(NSMutableDictionary*)params key:(NSString*)key secret:(NSString*)secret;
- (void)handleOAuthErrorWithResponse:(id)response;
- (BOOL)handleReOpenWithCommand:(NSString*)command params:(NSMutableDictionary*)params;
- (void)getGssidWithCompletionBlock:(void(^)(void))completion;
- (void)getGssidWithCompletionBlock:(void(^)(void))completion forceUpdate:(BOOL)forceUpdate;
- (void)resetStatus;
- (void)resetAccessToken;
- (void)resetCookies;
- (void)addAuthVerifierToHttpClient:(NSMutableDictionary*)params;
- (void)updateAuthorizationStatus:(AuthorizationStatus)status;
- (void)setupAuthorizationType:(AuthorizationType)type;
- (void)removeOfAuthorizationData;

@property (nonatomic, assign) id<GreeAuthorizationDelegate> delegate;
@property (nonatomic, assign) AuthorizationStatus authorizationStatus;
@property (nonatomic, assign) AuthorizationType authorizationType;
@property (nonatomic, retain) GreeHTTPClient* httpClient;
@property (nonatomic, retain) GreeHTTPClient* httpConsumerClient;
@property (nonatomic, retain) NSString* userOAuthKey;
@property (nonatomic, retain) NSString* userOAuthSecret;
@property (nonatomic, retain) GreeAuthorizationPopup* popup;
@property (nonatomic, retain) GreeSSO* greeSSOLegacy;
@property (nonatomic, copy) GreeAuthorizationUpgradeBlock upgradeSuccessBlock;
@property (nonatomic, copy) GreeAuthorizationUpgradeBlock upgradeFailureBlock;
@property (nonatomic, assign) BOOL upgradeComplete;
@property (nonatomic, assign) NSString* configServerUrlOpen;
@property (nonatomic, assign) NSString* configServerUrlOs;
@property (nonatomic, assign) NSString* configServerUrlId;
@property (nonatomic, assign) NSString* configGreeDomain;
@property (nonatomic, assign) NSString* configAppUrlScheme;
@property (nonatomic, assign) NSString* configSelfApplicationId;
@property (nonatomic, assign) NSString* configConsumerSecret;
@property (nonatomic, retain) NSString* deviceJasonWebToken;
@property (nonatomic, retain) NSString* SSOClientApplicationId;
@property (nonatomic, retain) NSString* SSOClientRequestToken;
@property (nonatomic, retain) NSString* SSOClientContext;
@property (nonatomic, retain) NSString* userId;
@property (nonatomic, retain) NSString* greeUUID;
@property (nonatomic, retain) NSString* serviceCode;
@property (nonatomic, retain) GreeNetworkReachability* reachability;
@property (nonatomic) BOOL reachabilityIsSet;
@property (nonatomic) BOOL reachabilityIsWork;
@property (nonatomic) BOOL enableGrade0;
@end

SPEC_BEGIN(GreeAuthorizationTests)

__block GreeAuthorization *greeAuthorization = nil;
__block id<GreeAuthorizationDelegate> authorizationDelegate = nil;
__block id viewOfGreePopupSwizzling = nil;

describe(@"GreeAuthorizationTests (private)", ^{
  beforeAll(^{
    viewOfGreePopupSwizzling = [GreeTestHelpers
                                exchangeInstanceSelector:@selector(view)
                                onClass:[GreePopup class]
                                withSelector:@selector(nilView)
                                onClass:[GreePopup class]];
  });

  context(@"when doing didDismissBlock (popupLaunch)", ^{
    beforeEach(^{
      authorizationDelegate = [KWMock nullMockForProtocol:@protocol(GreeAuthorizationDelegate)];
      [GreeHTTPClient stub:@selector(userAgentString) andReturn:@"UserAgent"];
      GreeSettings *settings = [GreeSettings nullMock];
      [settings stub:@selector(stringValueForSetting:) andReturn:kGreeAuthorizationTestsServerUrlId withArguments:GreeSettingServerUrlId];
      greeAuthorization = [[[GreeAuthorization alloc]
                           initWithConsumerKey:kGreeAuthorizationTestsConsumerKey
                           consumerSecret:kGreeAuthorizationTestsConsumerSecret
                           settings:settings
                           delegate:authorizationDelegate] autorelease];
      [greeAuthorization popupLaunch];
    });
    afterEach(^{
      authorizationDelegate = nil;
      greeAuthorization = nil;
    });

    context(@"case:Upgrade", ^{
      it(@"should do upgradeComplete block normally", ^{
        [greeAuthorization setAuthorizationStatus:AuthorizationStatusAccessTokenGot];
        [greeAuthorization setAuthorizationType:AuthorizationTypeUpgrade];
        greeAuthorization.upgradeComplete = YES;

        __block NSString *blockExecutionCheck = nil;
        greeAuthorization.upgradeSuccessBlock = ^{
          blockExecutionCheck = kGreeAuthorizationTestsBlockSuccess;
        };

        [[[(NSObject *)greeAuthorization.delegate should] receive] authorizeDidFinishWithLogin:NO];

        greeAuthorization.popup.didDismissBlock(nil);

        [[expectFutureValue(blockExecutionCheck) shouldEventually] equal:kGreeAuthorizationTestsBlockSuccess];
        [[theValue([greeAuthorization authorizationStatus]) should] equal:theValue(AuthorizationStatusAccessTokenGot)];
      });
      it(@"should do upgradeComplete block normally", ^{
        [greeAuthorization setAuthorizationStatus:AuthorizationStatusAccessTokenGot];
        [greeAuthorization setAuthorizationType:AuthorizationTypeUpgrade];
        greeAuthorization.upgradeComplete = NO;

        __block NSString *blockExecutionCheck = nil;
        greeAuthorization.upgradeFailureBlock = ^{
          blockExecutionCheck = kGreeAuthorizationTestsBlockFailure;
        };

        greeAuthorization.popup.didDismissBlock(nil);

        [[expectFutureValue(blockExecutionCheck) shouldEventually] equal:kGreeAuthorizationTestsBlockFailure];
      });
    });

    context(@"case:SSOLegacyServer", ^{
      it(@"should post DidCloseSSOPopup normally", ^{
        [greeAuthorization setAuthorizationStatus:AuthorizationStatusAccessTokenGot];
        [greeAuthorization setAuthorizationType:AuthorizationTypeUpgrade];

        greeAuthorization.popup.didDismissBlock(nil);

        [[theValue([greeAuthorization authorizationStatus]) should] equal:theValue(AuthorizationStatusAccessTokenGot)];
      });
    });

  });
});

describe(@"GreeAuthorizationTests (private)", ^{
  context(@"when getTokenWithParams", ^{

    beforeEach(^{
      [GreeURLMockingProtocol register];
      authorizationDelegate = [KWMock nullMockForProtocol:@protocol(GreeAuthorizationDelegate)];
      [GreeHTTPClient stub:@selector(userAgentString) andReturn:@"UserAgent"];
      GreeSettings *settings = [GreeSettings nullMock];
      [settings stub:@selector(stringValueForSetting:) andReturn:kGreeAuthorizationTestsServerUrlId withArguments:GreeSettingServerUrlId];
      greeAuthorization = [[[GreeAuthorization alloc]
                           initWithConsumerKey:kGreeAuthorizationTestsConsumerKey
                           consumerSecret:kGreeAuthorizationTestsConsumerSecret
                           settings:settings
                           delegate:authorizationDelegate] autorelease];
      greeAuthorization.httpClient = [[[GreeHTTPClient alloc ]
                                       initWithBaseURL:[NSURL URLWithString:[GreeURLMockingProtocol httpClientPrefix]]
                                       key:kGreeAuthorizationTestsConsumerKey
                                       secret:kGreeAuthorizationTestsConsumerSecret] autorelease];

      [greeAuthorization.popup.popupView stub:@selector(request)
        andReturn:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://previous"]]];
    });

    afterEach(^{
      [GreeURLMockingProtocol unregister];
      authorizationDelegate = nil;
      greeAuthorization = nil;
    });

    it(@"should do the requestToken process normally", ^{
      MockedURLResponse *mockResponse = [[MockedURLResponse new] autorelease];
      mockResponse.data = [kGreeAuthorizationTestsOAuthRequestTokenUrlQuery dataUsingEncoding:NSUTF8StringEncoding];
      [GreeURLMockingProtocol addMock:mockResponse];

      [[[greeAuthorization.httpClient should] receive] setUserToken:nil secret:nil];

      [greeAuthorization getTokenWithParams:[NSMutableDictionary dictionary] key:nil secret:nil];

      [[expectFutureValue(greeAuthorization.userOAuthKey) shouldEventually] equal:kGreeAuthorizationTestsOAuthTokenValue];
      [[expectFutureValue(greeAuthorization.userOAuthSecret) shouldEventually] equal:kGreeAuthorizationTestsOAuthTokenSecretValue];

      [[expectFutureValue([NSNumber numberWithInt:greeAuthorization.authorizationStatus]) shouldEventually]
       equal:[NSNumber numberWithInt:AuthorizationStatusRequestTokenGot]];
      [[[GreeKeyChain readWithKey:GreeKeyChainRequestTokenPairs] shouldEventually]
       equal:[NSString stringWithFormat:@"%@=%@", kGreeAuthorizationTestsOAuthTokenValue, kGreeAuthorizationTestsOAuthTokenSecretValue]];
    });

    it(@"should do the accessToken process normally", ^{
      MockedURLResponse *mockResponse = [[MockedURLResponse new] autorelease];
      mockResponse.data = [kGreeAuthorizationTestsOAuthAccessTokenUrlQuery dataUsingEncoding:NSUTF8StringEncoding];
      [GreeURLMockingProtocol addMock:mockResponse];

      [[[greeAuthorization.httpClient should] receive]
       setUserToken:kGreeAuthorizationTestsOAuthTokenValue secret:kGreeAuthorizationTestsOAuthTokenSecretValue];

      [greeAuthorization getTokenWithParams:[NSMutableDictionary dictionary]
        key:kGreeAuthorizationTestsOAuthTokenValue
        secret:kGreeAuthorizationTestsOAuthTokenSecretValue];

      [[expectFutureValue(greeAuthorization.userOAuthKey) shouldEventually] equal:kGreeAuthorizationTestsOAuthTokenValue];
      [[expectFutureValue(greeAuthorization.userOAuthSecret) shouldEventually] equal:kGreeAuthorizationTestsOAuthTokenSecretValue];
      [[expectFutureValue([NSNumber numberWithInt:greeAuthorization.authorizationStatus]) shouldEventually]
       equal:[NSNumber numberWithInt:AuthorizationStatusAccessTokenGot]];
      [[GreeKeyChain readWithKey:GreeKeyChainRequestTokenPairs] shouldBeNil];
    });
  });
});

describe(@"restore", ^{
  it(@"restore Swizzling", ^{
    [GreeTestHelpers restoreExchangedSelectors:&viewOfGreePopupSwizzling];
  });
});

describe(@"GreeAuthorizationTests", ^{

  beforeEach(^{
    authorizationDelegate = [KWMock nullMockForProtocol:@protocol(GreeAuthorizationDelegate)];
    [GreeHTTPClient stub:@selector(userAgentString) andReturn:@"UserAgent"];
    GreeSettings *settings = [GreeSettings nullMock];
    [settings stub:@selector(stringValueForSetting:) andReturn:kGreeAuthorizationTestsServerUrlId withArguments:GreeSettingServerUrlId];
    greeAuthorization = [[[GreeAuthorization alloc]
                          initWithConsumerKey:kGreeAuthorizationTestsConsumerKey
                          consumerSecret:kGreeAuthorizationTestsConsumerSecret
                          settings:settings
                          delegate:authorizationDelegate] autorelease];
    GreeAuthorization *popup = [GreeAuthorizationPopup nullMock];
    [GreeAuthorizationPopup stub:@selector(popup) andReturn:popup];
    [greeAuthorization stub:@selector(popup) andReturn:popup];
  });
  afterEach(^{
    authorizationDelegate = nil;
    greeAuthorization = nil;
  });

  context(@"when authorizeAction", ^{
    beforeEach(^{
      [greeAuthorization stub:@selector(popupLaunch)];
      [greeAuthorization stub:@selector(popupDismiss)];
      greeAuthorization.greeUUID = @"uuid";
    });
    afterEach(^{
      greeAuthorization.greeUUID = nil;
    });
    it(@"should do StatusInit process normally", ^{
      NSMutableDictionary *param = [NSMutableDictionary dictionaryWithObject:@"value" forKey:@"key"];
      [[[greeAuthorization should] receive] loadTopPage:param];

      [greeAuthorization setAuthorizationStatus:AuthorizationStatusInit];
      [greeAuthorization authorizeAction:param];
    });

    it(@"should do StatusEnter process normally", ^{
      [[greeAuthorization should] receive:@selector(loadEnterPage:)];

      [greeAuthorization setAuthorizationStatus:AuthorizationStatusEnter];
      [greeAuthorization authorizeAction:[NSMutableDictionary dictionary]];
    });

    it(@"should do RequestTokenBeforeGot process normally", ^{
      greeAuthorization.userOAuthKey = kGreeAuthorizationTestsUserOAuthKey;
      greeAuthorization.userOAuthSecret = kGreeAuthorizationTestsUserOAuthSecret;
      [[[greeAuthorization should] receive] getTokenWithParams:[NSDictionary dictionary] key:nil secret:nil];

      [greeAuthorization setAuthorizationStatus:AuthorizationStatusRequestTokenBeforeGot];
      [greeAuthorization authorizeAction:[NSMutableDictionary dictionary]];
    });

    it(@"should do RequestTokenGot process normally", ^{
      [[greeAuthorization should] receive:@selector(loadAuthorizePage:)];

      [greeAuthorization setAuthorizationStatus:AuthorizationStatusRequestTokenGot];
      [greeAuthorization authorizeAction:[NSMutableDictionary dictionary]];
    });

    it(@"should do AuthorizationSuccess process normally", ^{
      greeAuthorization.userOAuthKey = kGreeAuthorizationTestsUserOAuthKey;
      greeAuthorization.userOAuthSecret = kGreeAuthorizationTestsUserOAuthSecret;
      [[[greeAuthorization should] receive] getTokenWithParams:[NSDictionary dictionary]
        key:kGreeAuthorizationTestsUserOAuthKey
        secret:kGreeAuthorizationTestsUserOAuthSecret];

      [greeAuthorization setAuthorizationStatus:AuthorizationStatusAuthorizationSuccess];
      [greeAuthorization authorizeAction:[NSMutableDictionary dictionary]];
    });

    it(@"should do the AccessTokenGot and Upgrade process normally", ^{
      [greeAuthorization setAuthorizationStatus:AuthorizationStatusAccessTokenGot];
      [greeAuthorization setAuthorizationType:AuthorizationTypeUpgrade];
      [greeAuthorization authorizeAction:[NSMutableDictionary dictionary]];
      [[theValue(greeAuthorization.upgradeComplete) should] equal:theValue(YES)];
    });

  });

  context(@"when initalizing", ^{
    it(@"should initialize normally", ^{
      [greeAuthorization shouldNotBeNil];
      [[greeAuthorization should] beKindOfClass:[GreeAuthorization class]];
    });

    it(@"should share Instance normally", ^{
      GreePlatform *platform = [GreePlatform nullMockAsSharedInstance];
      [platform stub:@selector(authorization) andReturn:[GreeAuthorization nullMock]];

      [[GreeAuthorization sharedInstance] shouldNotBeNil];
      [[[GreeAuthorization sharedInstance] should] beKindOfClass:[GreeAuthorization class]];
    });
  });

  it(@"should authorize normally", ^{
    [[GreeKeyChain stubAndReturn:kGreeAuthorizationTestsUserIdIdentifier] readWithKey:GreeKeyChainUserIdIdentifier];
    [[GreeKeyChain stubAndReturn:kGreeAuthorizationTestsAccessTokenIdentifier] readWithKey:GreeKeyChainAccessTokenIdentifier];
    [[GreeKeyChain stubAndReturn:kGreeAuthorizationTestsAccessTokenSecretIdentifier] readWithKey:GreeKeyChainAccessTokenSecretIdentifier];

    [greeAuthorization authorize];
    [[theValue([greeAuthorization authorizationStatus]) should] equal:theValue(AuthorizationStatusAccessTokenGot)];
  });

  it(@"should revoke normally", ^{
    [[GreeKeyChain stubAndReturn:kGreeAuthorizationTestsUserIdIdentifier] readWithKey:GreeKeyChainUserIdIdentifier];
    [[GreeKeyChain stubAndReturn:kGreeAuthorizationTestsAccessTokenIdentifier] readWithKey:GreeKeyChainAccessTokenIdentifier];
    [[GreeKeyChain stubAndReturn:kGreeAuthorizationTestsAccessTokenSecretIdentifier] readWithKey:GreeKeyChainAccessTokenSecretIdentifier];

    [[greeAuthorization should] receive:@selector(resetStatus)];
    [[greeAuthorization shouldEventually] receive:@selector(loadLogoutPage)];
    [greeAuthorization revoke];

    [[theValue(greeAuthorization.authorizationStatus) should] equal:theValue(AuthorizationStatusAccessTokenGot)];
    [[theValue(greeAuthorization.authorizationType) should] equal:theValue(AuthorizationTypeLogout)];
  });

  it(@"should reAuthorize normally", ^{
    [[greeAuthorization should]receive:@selector(resetStatus)];
    [[(NSObject *)greeAuthorization.delegate should] receive:@selector(revokeDidFinish)];
    [[greeAuthorization shouldEventually] receive:@selector(loadConfirmReAuthorizePage)];

    NSString* urlString = [NSString stringWithFormat:@"%@/?action=confirm_reauthorize", kGreeAuthorizationTestsServerUrlId];
    NSURLRequest* aRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [[[greeAuthorization.popup should] receive] loadRequest:aRequest];

    [greeAuthorization reAuthorize];
    [[theValue(greeAuthorization.authorizationStatus) should] equal:theValue(AuthorizationStatusInit)];
    [[theValue(greeAuthorization.authorizationType) should] equal:theValue(AuthorizationTypeDefault)];
  });

  context(@"when upgrading", ^{

    it(@"should upgrade and fail", ^{
      __block NSString *wait = nil;

      [greeAuthorization upgradeWithParams:nil successBlock:^{wait = @"success";} failureBlock:^{wait = @"failure";}];
      [[expectFutureValue(wait) shouldEventually] equal:@"failure"];
    });

    it(@"should upgrade normally", ^{

      __block NSString *wait = nil;

      [greeAuthorization stub:@selector(userId) andReturn:kGreeAuthorizationTestsUserIdIdentifier];
      [greeAuthorization stub:@selector(accessTokenData) andReturn:kGreeAuthorizationTestsAccessTokenIdentifier];
      [greeAuthorization stub:@selector(accessTokenSecretData) andReturn:kGreeAuthorizationTestsAccessTokenSecretIdentifier];

      [[greeAuthorization should]receive:@selector(resetStatus)];

      [greeAuthorization upgradeWithParams:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"target_grade"]
                              successBlock:^{wait = @"success";}
                              failureBlock:^{wait = @"failure";}];

      [[GreeWebSession shouldEventually] receive:@selector(regenerateWebSessionWithBlock:)];

      [[theValue(greeAuthorization.authorizationStatus) should] equal:theValue(AuthorizationStatusAccessTokenGot)];
      [[theValue(greeAuthorization.authorizationType) should] equal:theValue(AuthorizationTypeUpgrade)];
    });
  });

  context(@"when openning URL Action", ^{
    it(@"should handle OpenURL and do nothing", ^{
      [[theValue([greeAuthorization handleOpenURL:[NSURL URLWithString:@"test"]]) should] equal:theValue(YES)];
    });

    context(@"case: reopen", ^{
      it(@"should handle OpenURL for having finished sign-up normally", ^{
        [[[greeAuthorization should] receive] authorizeAction:[NSMutableDictionary dictionaryWithObject:@"1" forKey:@"test"]];
        [greeAuthorization handleOpenURL:[NSURL URLWithString:@"test://reopen?test=1"]];
        [[theValue(greeAuthorization.authorizationStatus) should] equal:theValue(AuthorizationStatusRequestTokenBeforeGot)];
      });

      it(@"should handle OpenURL for having finished upgrade normally", ^{
        [greeAuthorization stub:@selector(accessTokenData) andReturn:kGreeAuthorizationTestsAccessTokenIdentifier];
        [greeAuthorization stub:@selector(accessTokenSecretData) andReturn:kGreeAuthorizationTestsAccessTokenSecretIdentifier];
        [greeAuthorization setupAuthorizationType:AuthorizationTypeUpgrade];

        [[greeAuthorization should] receive:@selector(popupDismiss)];

        [greeAuthorization handleOpenURL:[NSURL URLWithString:@"test://reopen?result=succeeded"]];


        [[theValue(greeAuthorization.authorizationType) should] equal:theValue(AuthorizationTypeUpgrade)];
        [[theValue(greeAuthorization.upgradeComplete) should] equal:theValue(YES)];
      });
    });

    context(@"case: get-accesstoken", ^{
      it(@"should handle OpneUrl for getting accesstoken (denied case) normally", ^{
        [[greeAuthorization should] receive:@selector(resetStatus)];
        [[[greeAuthorization should] receive] authorizeAction:nil];
        [greeAuthorization handleOpenURL:[NSURL URLWithString:@"test://get-accesstoken?denied=1"]];
      });

      it(@"should handle OpneUrl for getting accesstoken (allowed case) normally", ^{
        NSURL *url = [NSURL URLWithString:@"test://get-accesstoken?oauth_verifier=verifier"];
        greeAuthorization.popup = [GreeAuthorizationPopup nullMock];
        [[[greeAuthorization should] receive] authorizeAction:[[url query] greeDictionaryFromQueryString]];
        [[[greeAuthorization should] receive]
          addAuthVerifierToHttpClient:[NSMutableDictionary dictionaryWithObject:@"verifier" forKey:@"oauth_verifier"]];
        [greeAuthorization handleOpenURL:url];
        [[theValue(greeAuthorization.authorizationStatus) should] equal:theValue(AuthorizationStatusAuthorizationSuccess)];
      });

    });

    context(@"case: SSO Server", ^{
      it(@"should do SSO by oauth normally", ^{
        [greeAuthorization stub:@selector(accessTokenData) andReturn:kGreeAuthorizationTestsAccessTokenIdentifier];
        [greeAuthorization stub:@selector(accessTokenSecretData) andReturn:kGreeAuthorizationTestsAccessTokenSecretIdentifier];

        [[greeAuthorization shouldEventually] receive:@selector(loadAuthorizePage:)];

        [greeAuthorization handleOpenURL:[NSURL URLWithString:@"test://authorize/request?oauth_token=token12345&app_id=12345&context=context12345"]];

        [[expectFutureValue([NSNumber numberWithInt:greeAuthorization.authorizationType]) shouldEventually]
          equal:[NSNumber numberWithInt:AuthorizationTypeSSOServer]];
        [[expectFutureValue([NSNumber numberWithInt:greeAuthorization.authorizationStatus]) shouldEventually]
          equal:[NSNumber numberWithInt:AuthorizationStatusAccessTokenGot]];

        [[expectFutureValue(greeAuthorization.SSOClientApplicationId) shouldEventually] equal:@"12345"];
        [[expectFutureValue(greeAuthorization.SSOClientContext) shouldEventually] equal:@"context12345"];
        [[expectFutureValue(greeAuthorization.SSOClientRequestToken) shouldEventually] equal:@"token12345"];

      });

      it(@"should do SSO by oauth, but not login", ^{
        [[greeAuthorization shouldEventually] receive:@selector(resetStatus)];
        [[greeAuthorization shouldEventually] receive:@selector(resetAccessToken)];

        [[greeAuthorization shouldEventually] receive:@selector(authorizeAction:)];
        [greeAuthorization handleOpenURL:[NSURL URLWithString:@"test://authorize/request?oauth_token=token12345&app_id=12345&context=context12345"]];

        [[expectFutureValue([NSNumber numberWithInt:greeAuthorization.authorizationStatus]) shouldEventually]
         equal:[NSNumber numberWithInt:AuthorizationStatusRequestTokenBeforeGot]];
      });

      it(@"should do SSO by session normally", ^{
        [greeAuthorization stub:@selector(accessTokenData) andReturn:kGreeAuthorizationTestsAccessTokenIdentifier];
        [greeAuthorization stub:@selector(accessTokenSecretData) andReturn:kGreeAuthorizationTestsAccessTokenSecretIdentifier];

        [[greeAuthorization shouldEventually] receive:@selector(loadSSOAcceptPage)];
        [greeAuthorization handleOpenURL:[NSURL URLWithString:@"test://authorize/request?app_id=12345&context=context12345"]];

        [[expectFutureValue([NSNumber numberWithInt:greeAuthorization.authorizationType]) shouldEventually]
         equal:[NSNumber numberWithInt:AuthorizationTypeSSOLegacyServer]];

      });

      it(@"should do SSO by session, but not login", ^{
        [[greeAuthorization shouldEventually] receive:@selector(resetStatus)];
        [[greeAuthorization shouldEventually] receive:@selector(resetAccessToken)];
        [[[greeAuthorization shouldEventually] receive]
         authorizeAction:[NSMutableDictionary dictionaryWithObject:kSelfId forKey:@"target"]];

        [greeAuthorization handleOpenURL:[NSURL URLWithString:@"test://authorize/request?app_id=12345&context=context12345"]];

        [[expectFutureValue([NSNumber numberWithInt:greeAuthorization.authorizationStatus]) shouldEventually]
         equal:[NSNumber numberWithInt:AuthorizationStatusRequestTokenBeforeGot]];
      });
    });

    it(@"should handle OpneUrl for SSO Client", ^{
      greeAuthorization.popup = [GreeAuthorizationPopup nullMock];
      greeAuthorization.greeSSOLegacy = [GreeSSO nullMock];

      [[greeAuthorization shouldEventually] receive:@selector(resetStatus)];
      [[greeAuthorization shouldEventually] receive:@selector(resetAccessToken)];

      [[[greeAuthorization shouldEventually] receive]
       authorizeAction:[NSMutableDictionary dictionaryWithObject:kSelfId forKey:@"target"]];

      [[[greeAuthorization.greeSSOLegacy should] receive]
        setDecryptGssIdWithEncryptedGssId:@"keyValue"];

      [greeAuthorization handleOpenURL:[NSURL URLWithString:@"test://sso?key=keyValue"]];

      [[expectFutureValue([NSNumber numberWithInt:greeAuthorization.authorizationStatus]) shouldEventually]
       equal:[NSNumber numberWithInt:AuthorizationStatusRequestTokenBeforeGot]];
    });
  });

  context(@"when handle BeforeAuthorize", ^{
    it(@"should handle the fail process normally", ^{
      [greeAuthorization stub:@selector(accessTokenData) andReturn:kGreeAuthorizationTestsAccessTokenIdentifier];
      [greeAuthorization stub:@selector(accessTokenSecretData) andReturn:kGreeAuthorizationTestsAccessTokenSecretIdentifier];

      [[theValue([greeAuthorization handleBeforeAuthorize:@"dummy"]) should] equal:theValue(NO)];
    });

    it(@"should handle Before Authorize normally", ^{
      [[[greeAuthorization should] receive]
       authorizeAction:[NSMutableDictionary dictionaryWithObject:kGreeAuthorizationTestsServiceString forKey:@"service_code"]];

      [greeAuthorization handleBeforeAuthorize:kGreeAuthorizationTestsServiceString];
      [[greeAuthorization.serviceCode should] equal:kGreeAuthorizationTestsServiceString];
    });
  });

  it(@"should check authorized normally", ^{
    [[theValue([greeAuthorization isAuthorized]) should] equal:theValue(NO)];
    [greeAuthorization stub:@selector(accessTokenData) andReturn:kGreeAuthorizationTestsAccessTokenIdentifier];
    [[theValue([greeAuthorization isAuthorized]) should] equal:theValue(NO)];
    [greeAuthorization stub:@selector(accessTokenSecretData) andReturn:kGreeAuthorizationTestsAccessTokenSecretIdentifier];
    [[theValue([greeAuthorization isAuthorized]) should] equal:theValue(YES)];
  });

});

SPEC_END
