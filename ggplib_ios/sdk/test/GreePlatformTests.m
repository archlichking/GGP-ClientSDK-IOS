//
// Copyright 2011 GREE, Inc.
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
#import "GreePlatform+Internal.h"
#import "GreeAnalyticsQueue.h"
#import "NSHTTPCookieStorage+GreeAdditions.h"
#import "GreeSettings.h"
#import "GreeTestHelpers.h"
#import "GreePlatformSettings.h"
#import "GreeHTTPClient.h"
#import "GreeLogger.h"
#import "GreeNotificationQueue.h"
#import "GreeNotificationTypes.h"
#import <GameKit/GameKit.h>
#import "NSString+GreeAdditions.h"
#import "GreeBadgeValues.h"
#import "JSONKit.h"
#import "NSData+GreeAdditions.h"
#import "GreeNotificationBoardViewController.h"
#import "GreeURLMockingProtocol.h"
#import "GreeMatchers.h"
#import "GreeUser.h"

@interface GreePlatform (TestInternal) <GreeAuthorizationDelegate>
- (NSDictionary*)bootstrapSettingsDictionary;
- (void)writeBootstrapSettingsDictionary:(NSDictionary*)bootstrapSettings;
- (void)updateBootstrapSettingsWithAttemptNumber:(NSInteger)attemptNumber statusBlock:(BOOL(^)(BOOL didSucceed))statusBlock;
@end

SPEC_BEGIN(GreePlatformTests)

describe(@"GreePlatform", ^{
  registerMatchers(@"Gree");

  it(@"should have a version of 3.1.0", ^{
    [[[GreePlatform version] should] equal:@"3.1.0"];
  });
  
  context(@"when initialized", ^{
    __block id urlCache = nil;

    beforeEach(^{
      [GreeWidget stub:@selector(alloc)];
      [GreeHTTPClient stub:@selector(userAgentString) andReturn:@"UserAgent"];
      [NSBundle stub:@selector(greePlatformCoreBundle) andReturn:[NSBundle mainBundle]];
      [GreeAnalyticsQueue stub:@selector(alloc) andReturn:[GreeAnalyticsQueue nullMock]];
      [GreeNetworkReachability stub:@selector(alloc) andReturn:[GreeNetworkReachability nullMockWithStatus:GreeNetworkReachabilityUnknown]];
    });
    
    afterEach(^{
      [urlCache release];
      urlCache = nil;
    });

    context(@"with no settings", ^{

      beforeEach(^{
        [GreePlatform initializeWithApplicationId:@"123" consumerKey:@"testkey" consumerSecret:@"testsecret" settings:nil delegate:nil];
      });
      
      afterEach(^{
        [GreePlatform shutdown];
      });

      it(@"should have a singleton value", ^{
        [[[GreePlatform sharedInstance] should] beNonNil];
      });
      
      it(@"should create the http client", ^{
        GreeHTTPClient* client = [GreePlatform sharedInstance].httpClient;
        [[client should] beNonNil];
        [[[client valueForKeyPath:@"clientOAuthKey"] should] equal:@"testkey"];
        [[[client valueForKeyPath:@"clientOAuthSecret"] should] equal:@"testsecret"];
      });
      
      context(@"signing requests", ^{
        it(@"should sign plain", ^{
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://example.com/testSig"]];
        [[GreePlatform sharedInstance] signRequest:request parameters:nil];
        [[request.allHTTPHeaderFields should] haveValueForKey:@"Authorization"];
          [[request.URL.absoluteString should] containString:@"opensocial_viewer_id"];
          [[request.URL.absoluteString should] containString:@"opensocial_owner_id"];
          [[request.URL.absoluteString should] containString:@"opensocial_app_id"];
          [[request.URL.absoluteString should] matchRegExp:@"testSig\?.[a-z_]+"];
      });
      
        it(@"should add parameters", ^{
          NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://example.com/testSig?a=b"]];
          [[GreePlatform sharedInstance] signRequest:request parameters:[NSDictionary dictionaryWithObject:@"b" forKey:@"a"]];
          [[request.allHTTPHeaderFields should] haveValueForKey:@"Authorization"];
          [[request.URL.absoluteString should] containString:@"opensocial_viewer_id"];
          [[request.URL.absoluteString should] containString:@"opensocial_owner_id"];
          [[request.URL.absoluteString should] containString:@"opensocial_app_id"];
          [[request.URL.absoluteString should] matchRegExp:@"a=b&[a-z_]+="];
        });
      });
      
      
      
      it(@"should establish reachability", ^{
        [[[GreePlatform sharedInstance] reachability] shouldNotBeNil];
      });
      
      it(@"should create settings", ^{
        [[[GreePlatform sharedInstance] settings] shouldNotBeNil];
      });
      
      it(@"should set Cookie", ^{      
        NSString* appId = [[GreePlatform sharedInstance].settings stringValueForSetting:GreeSettingApplicationId];
        NSString* applicationUrlscheme = [[GreePlatform sharedInstance].settings stringValueForSetting:GreeSettingApplicationUrlScheme];
        NSString* greeDomainString = [[GreePlatform sharedInstance].settings stringValueForSetting:GreeSettingServerUrlDomain];
        
        NSString* URLScheme = [NSString stringWithFormat:@"%@%@", applicationUrlscheme, appId];
        NSString* URLSchemeCookie = [NSHTTPCookieStorage greeGetCookieValueWithName:@"URLScheme" domain:greeDomainString];
        NSString* uatype = [NSHTTPCookieStorage greeGetCookieValueWithName:@"uatype" domain:greeDomainString];       
        NSString* appVersion = [GreePlatform paddedAppVersion];
        NSString* appVersionCookie = [NSHTTPCookieStorage greeGetCookieValueWithName:@"appVersion" domain:greeDomainString];      
        NSString* iosSDKVersion = [GreePlatform version]; 
        NSString* iosSDKVersionCookie = [NSHTTPCookieStorage greeGetCookieValueWithName:@"iosSDKVersion" domain:greeDomainString]; 
        
        [[URLSchemeCookie should] equal:URLScheme];
        [[uatype should] equal:@"iphone-app"];
        [[appVersionCookie should] equal:appVersion];
        [[iosSDKVersionCookie should] equal:iosSDKVersion];
      });

    });
    
    it(@"should apply settings", ^{
      NSDictionary* settings = [NSDictionary dictionaryWithObject:@"testValue" forKey:@"testKey"];
      [GreePlatform initializeWithApplicationId:@"123" consumerKey:@"testkey" consumerSecret:@"testsecret" settings:settings delegate:nil];
      [[[[[GreePlatform sharedInstance] settings] objectValueForSetting:@"testKey"] should] equal:@"testValue"];
      [GreePlatform shutdown];
    });
    
    context(@"GameCenter", ^{
      __block GKLocalPlayer* mock = nil;
      beforeEach(^{
        mock = [[GKLocalPlayer nullMock] retain];
        [GKLocalPlayer stub:@selector(localPlayer) andReturn:mock];
      });
      afterEach(^{
        [mock release];
      });
      it(@"should not initiate if no settings", ^{
        [[mock shouldNot] receive:@selector(authenticateWithCompletionHandler:)];
        [GreePlatform initializeWithApplicationId:@"123" consumerKey:@"testkey" consumerSecret:@"testsecret" settings:nil delegate:nil];
        [[GreePlatform sharedInstance] stub:@selector(httpClient) andReturn:[GreeHTTPClient nullMock]];
        
        [[GreePlatform sharedInstance] authorizeDidFinishWithLogin:YES];
        [GreePlatform shutdown];
      });
      it(@"should initiate if settings exist", ^{
        [[mock should] receive:@selector(authenticateWithCompletionHandler:)];
        NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSDictionary dictionaryWithObjectsAndKeys:@"gameCenterId", @"greeId", nil], GreeSettingGameCenterAchievementMapping,
                                  [NSDictionary dictionaryWithObjectsAndKeys:@"gameCenterId", @"greeId", nil], GreeSettingGameCenterLeaderboardMapping,
                                  nil];
        [GreePlatform initializeWithApplicationId:@"123" consumerKey:@"testkey" consumerSecret:@"testsecret" settings:settings delegate:nil];
        [[GreePlatform sharedInstance] stub:@selector(httpClient) andReturn:[GreeHTTPClient nullMock]];
        
        [[GreePlatform sharedInstance] authorizeDidFinishWithLogin:YES];
        [GreePlatform shutdown];
      });
    });
    
    context(@"when given a login", ^{
      beforeEach(^{
        [GreePlatform initializeWithApplicationId:@"123" consumerKey:@"testkey" consumerSecret:@"testsecret" settings:nil delegate:nil];
        [[GreePlatform sharedInstance] stub:@selector(httpClient) andReturn:[GreeHTTPClient nullMock]];
        [GreeURLMockingProtocol register];

        [[GreeAuthorization sharedInstance] stub:@selector(accessTokenData) andReturn:@"faketoken"];
      });      
      
      afterEach(^{
        [GreeURLMockingProtocol unregister];
        [GreePlatform shutdown];
      });
      
      context(@"and valid user", ^{
        __block id waitObject;
        beforeEach(^{
          waitObject = nil;
          MockedURLResponse* mock = [[[MockedURLResponse alloc] init] autorelease];
          mock.data = [@"{ \"entry\": { \"id\" : \"mockId\" } }" dataUsingEncoding:NSUTF8StringEncoding];
          mock.requestBlock = ^(NSURLRequest*req){
            waitObject = @"DONE";
            return YES;
          };
          [GreeURLMockingProtocol addMock:mock];
          
          [[GreePlatform sharedInstance] authorizeDidUpdateUserId:@"fakeuserid" withToken:@"faketoken" withSecret:@"fakesecret"];
          [[GreePlatform sharedInstance] authorizeDidFinishWithLogin:YES];
          [[expectFutureValue(waitObject) shouldEventually] beNonNil];
        });
        it(@"should have a user", ^{
          [[GreePlatform sharedInstance].localUser shouldNotBeNil];
        });
        
        it(@"should have a user id", ^{
          [[GreePlatform sharedInstance].localUserId shouldNotBeNil];
        });
        
        it(@"should create a write cache", ^{
          [[GreePlatform sharedInstance].writeCache shouldNotBeNil];
        });

        it(@"should sign with user", ^{
          NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://example.com/testSig"]];
          [[GreePlatform sharedInstance] signRequest:request parameters:nil];
          [[request.URL.absoluteString should] containString:@"opensocial_viewer_id=fakeuserid"];
          [[request.URL.absoluteString should] containString:@"opensocial_owner_id=fakeuserid"];
        });

      });
      
      context(@"and invalid user", ^{
        beforeEach(^{
          //fake a user
          [[GreePlatform sharedInstance] setValue:[NSObject nullMock] forKey:@"localUser"];
          [[GreePlatform sharedInstance] setValue:[NSObject nullMock] forKey:@"writeCache"];
          
          [[GreePlatform sharedInstance] authorizeDidFinishWithLogin:YES];
        });
        it(@"should clear user", ^{
          [[[GreePlatform sharedInstance] localUser] shouldBeNil];
        });      
        it(@"should clear cache", ^{
          [[[GreePlatform sharedInstance] writeCache] shouldBeNil];
        });      
      });
      context(@"and no token", ^{
        beforeEach(^{
          //fake a user
          [[GreePlatform sharedInstance] setValue:[NSObject nullMock] forKey:@"localUser"];
          [[GreePlatform sharedInstance] setValue:[NSObject nullMock] forKey:@"writeCache"];
          [[GreeAuthorization sharedInstance] stub:@selector(accessTokenData) andReturn:nil];
          
          [[GreePlatform sharedInstance] authorizeDidFinishWithLogin:YES];
        });
        it(@"should clear user", ^{
          [[[GreePlatform sharedInstance] localUser] shouldBeNil];
        });      
        it(@"should clear cache", ^{
          [[[GreePlatform sharedInstance] writeCache] shouldBeNil];
        });      
      });
    });
    
    it(@"should clear user/writecache on logout", ^{
      //fake a user
      [[GreePlatform sharedInstance] setValue:[NSObject nullMock] forKey:@"localUser"];
      [[GreePlatform sharedInstance] setValue:[NSObject nullMock] forKey:@"writeCache"];
      [[GreePlatform sharedInstance] revokeDidFinish];
      [[[GreePlatform sharedInstance] localUser] shouldBeNil];
      [[[GreePlatform sharedInstance] writeCache] shouldBeNil];
      
      
    });
    
    //it corrects later.
    pending_(@"regarding the logger", ^{
      
      beforeAll(^{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GreeSettings"];
      });
      
      afterEach(^{
        [GreePlatform shutdown];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GreeSettings"];
      });

      it(@"should enable logging by default", ^{
        [GreePlatform initializeWithApplicationId:@"123" consumerKey:@"testkey" consumerSecret:@"testsecret" settings:nil delegate:nil];
        [[theValue([[[GreePlatform sharedInstance] settings] boolValueForSetting:GreeSettingEnableLogging]) should] beYes];
      });

      it(@"should create a logger if logging is enabled", ^{
        [GreePlatform initializeWithApplicationId:@"123" consumerKey:@"testkey" consumerSecret:@"testsecret" settings:nil delegate:nil];
        [[[GreePlatform sharedInstance] logger] shouldNotBeNil];
      });

      it(@"should not create a logger if logging is disabled", ^{
        NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithBool:NO], GreeSettingEnableLogging,
          nil];
        [GreePlatform initializeWithApplicationId:@"123" consumerKey:@"testkey" consumerSecret:@"testsecret" settings:settings delegate:nil];
        [[[GreePlatform sharedInstance] logger] shouldBeNil];
      });
      
      it(@"should set logLevel to public and not include file/line info in production", ^{
        NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
          GreeDevelopmentModeProduction, GreeSettingDevelopmentMode,
          nil];
        [GreePlatform initializeWithApplicationId:@"123" consumerKey:@"testkey" consumerSecret:@"testsecret" settings:settings delegate:nil];
        [[theValue([[GreePlatform sharedInstance] logger].level) should] equal:theValue(GreeLogLevelPublic)];
        [[theValue([[GreePlatform sharedInstance] logger].includeFileLineInfo) should] beNo];
      });

      it(@"should set logLevel to warn by default when not in production", ^{
        NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
          GreeDevelopmentModeSandbox, GreeSettingDevelopmentMode,
          nil];
        [GreePlatform initializeWithApplicationId:@"123" consumerKey:@"testkey" consumerSecret:@"testsecret" settings:settings delegate:nil];
        [[theValue([[GreePlatform sharedInstance] logger].level) should] equal:theValue(GreeLogLevelWarn)];
        [[theValue([[GreePlatform sharedInstance] logger].includeFileLineInfo) should] beYes];
      });

      it(@"should set logLevel as desired", ^{
        NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithInteger:876], GreeSettingLogLevel,
          nil];
        [GreePlatform initializeWithApplicationId:@"123" consumerKey:@"testkey" consumerSecret:@"testsecret" settings:settings delegate:nil];
        [[theValue([[GreePlatform sharedInstance] logger].level) should] equal:theValue(876)];
      });
      
      it(@"should not write to file by default", ^{
        [GreePlatform initializeWithApplicationId:@"123" consumerKey:@"testkey" consumerSecret:@"testsecret" settings:nil delegate:nil];
        [[theValue([[GreePlatform sharedInstance] logger].logToFile) should] beNo];
      });
      
      it(@"should setup a handle when true", ^{
        //don't write the actual filepath
        [[NSFileManager defaultManager] stub:@selector(createDirectoryAtPath:withIntermediateDirectories:attributes:error:)];
        [[NSFileManager defaultManager] stub:@selector(createFileAtPath:contents:attributes:)];
        
        //which means we need to fake the actual logging handle
        NSFileHandle* mockHandle = [NSFileHandle nullMock];
        [NSFileHandle stub:@selector(fileHandleForWritingAtPath:) andReturn:mockHandle];

        NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithBool:YES], GreeSettingWriteLogToFile,
                                  nil];
        [GreePlatform initializeWithApplicationId:@"123" consumerKey:@"testkey" consumerSecret:@"testsecret" settings:settings delegate:nil];
        [[theValue([[GreePlatform sharedInstance] logger].logToFile) should] beYes];
        [[[[GreePlatform sharedInstance] logger] valueForKey:@"logHandle"] shouldNotBeNil];
      });
    });
    
    context(@"when registering remote notifications", ^{
      beforeEach(^{
        [GreePlatform initializeWithApplicationId:@"123" consumerKey:@"testkey" consumerSecret:@"testsecret" settings:nil delegate:nil];
        [[GreePlatform sharedInstance] stub:@selector(httpClient) andReturn:[GreeHTTPClient nullMock]];
        [[GreePlatform sharedInstance] stub:@selector(localUserId) andReturn:[NSString nullMock]];
        
        [GreeURLMockingProtocol register];
      });
      
      afterEach(^{
        [GreeURLMockingProtocol unregister];
        [GreePlatform shutdown];
      });
      
      it(@"should work", ^{
        MockedURLResponse* response = [[[MockedURLResponse alloc] init] autorelease];
        [GreeURLMockingProtocol addMock:response];

        __block id returnValue = nil;
        [GreePlatform postDeviceToken:[NSData data] block:^(NSError *error) {
          returnValue = @"DONE";
        }];
        [[expectFutureValue(returnValue) shouldEventually] beNonNil];
      });
      it(@"should handle errors", ^{
        MockedURLResponse* response = [[[MockedURLResponse alloc] init] autorelease];
        response.statusCode = 500;
        [GreeURLMockingProtocol addMock:response];

        __block id returnValue = nil;
        [GreePlatform postDeviceToken:[NSData data] block:^(NSError *error) {
          returnValue = error;
        }];
        [[expectFutureValue(returnValue) shouldEventually] beNonNil];
      });
    });
    
    context(@"when creating notifications", ^{      
      it(@"should succeed", ^{
        [GreePlatform initializeWithApplicationId:@"123" consumerKey:@"testkey" consumerSecret:@"testsecret" settings:nil delegate:nil];
        GreeNotificationQueue* mockQueue = [GreeNotificationQueue nullMock];
        NSDictionary* mockNotificationData = [NSDictionary dictionary];
        [[mockQueue should] receive:@selector(handleRemoteNotification:) withArguments:mockNotificationData];
        [[GreePlatform sharedInstance] stub:@selector(rawNotificationQueue) andReturn:mockQueue];
        // [adill] stubbing localUser becuse remote notifications are ignored when there is no localUser
        [[GreePlatform sharedInstance] stub:@selector(localUser) andReturn:[GreeUser nullMock]];
        [[GreePlatform sharedInstance] stub:@selector(localUserId) andReturn:[NSString nullMock]];
        
        [GreePlatform handleRemoteNotification:mockNotificationData application:[UIApplication sharedApplication]];
        [GreePlatform shutdown];
      });

      it(@"should not launch the notification board if not requested", ^{
        [GreePlatform initializeWithApplicationId:@"123" consumerKey:@"testkey" consumerSecret:@"testsecret" settings:nil delegate:nil];
        GreeNotificationQueue* mockQueue = [GreeNotificationQueue nullMock];
        NSDictionary* mockNotificationData = [NSDictionary dictionary];
        [[GreePlatform sharedInstance] stub:@selector(rawNotificationQueue) andReturn:mockQueue];
        GreeNotificationBoardViewController *mockViewController = [GreeNotificationBoardViewController nullMock];
        [GreeNotificationBoardViewController stub:@selector(alloc) andReturn:mockViewController];
        [[mockViewController shouldNot] receive:@selector(initWithGameNotificationURL:block:)];

        [GreePlatform handleRemoteNotification:mockNotificationData application:[UIApplication sharedApplication]];
        [GreePlatform shutdown];
      });

      it(@"should load badge values if the setting is yes", ^{
        [[GreeBadgeValues should] receive:@selector(loadBadgeValuesForCurrentApplicationWithBlock:)];
      
        NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithBool:YES], GreeSettingUpdateBadgeValuesAfterRemoteNotification,
          nil];
          
        [GreePlatform initializeWithApplicationId:@"123" consumerKey:@"testkey" consumerSecret:@"testsecret" settings:settings delegate:nil];
        GreeNotificationQueue* mockQueue = [GreeNotificationQueue nullMock];
        NSDictionary* mockNotificationData = [NSDictionary dictionary];
        [[GreePlatform sharedInstance] stub:@selector(rawNotificationQueue) andReturn:mockQueue];
        // [adill] stubbing localUser becuse remote notifications are ignored when there is no localUser
        [[GreePlatform sharedInstance] stub:@selector(localUser) andReturn:[GreeUser nullMock]];
        [[GreePlatform sharedInstance] stub:@selector(localUserId) andReturn:[NSString nullMock]];
      
        [GreePlatform handleRemoteNotification:mockNotificationData application:[UIApplication sharedApplication]];
        [GreePlatform shutdown];
      });

      it(@"should not load badge values if the setting is no", ^{
        [[GreeBadgeValues shouldNot] receive:@selector(loadBadgeValuesForCurrentApplicationWithBlock:)];

        NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithBool:NO], GreeSettingUpdateBadgeValuesAfterRemoteNotification,
          nil];
          
        [GreePlatform initializeWithApplicationId:@"123" consumerKey:@"testkey" consumerSecret:@"testsecret" settings:settings delegate:nil];
        GreeNotificationQueue* mockQueue = [GreeNotificationQueue nullMock];
        NSDictionary* mockNotificationData = [NSDictionary dictionary];
        [[GreePlatform sharedInstance] stub:@selector(rawNotificationQueue) andReturn:mockQueue];
      
        [GreePlatform handleRemoteNotification:mockNotificationData application:[UIApplication sharedApplication]];
        [GreePlatform shutdown];
      });
    });
      
    context(@"when loading the badge values", ^{
      beforeEach(^{
        [GreePlatform initializeWithApplicationId:@"123" consumerKey:@"testkey" consumerSecret:@"testsecret" settings:nil delegate:nil];
        [[GreePlatform sharedInstance] stub:@selector(httpClient) andReturn:[GreeHTTPClient nullMock]];
        [GreeURLMockingProtocol register];
      });
    
      afterEach(^{
        [GreeURLMockingProtocol unregister];
        [GreePlatform shutdown];
      });
    
      it(@"should default to zero", ^{      
        [[theValue([[[GreePlatform sharedInstance] badgeValues] socialNetworkingServiceBadgeCount]) should] equal:theValue(0)];
        [[theValue([[[GreePlatform sharedInstance] badgeValues] applicationBadgeCount]) should] equal:theValue(0)];
      });
    
      it(@"should store the new values", ^{
        MockedURLResponse* response = [[[MockedURLResponse alloc] init] autorelease];
        response.data = [@"{ \"entry\": { \"sns\":1, \"app\":1 } }" dataUsingEncoding:NSUTF8StringEncoding];
        [GreeURLMockingProtocol addMock:response];
        __block id returnValue = nil;

        [[GreePlatform sharedInstance] updateBadgeValuesWithBlock:^(GreeBadgeValues *badgeValues) {
          returnValue = @"DONE";
        }];
      
        [[expectFutureValue(returnValue) shouldEventually] beNonNil];
      
        [[theValue([[[GreePlatform sharedInstance] badgeValues] socialNetworkingServiceBadgeCount]) should] equal:theValue(1)];
        [[theValue([[[GreePlatform sharedInstance] badgeValues] applicationBadgeCount]) should] equal:theValue(1)];
      });
      
      it(@"should pass the new values through the block parameter", ^{
        MockedURLResponse* response = [[[MockedURLResponse alloc] init] autorelease];
        response.data = [@"{ \"entry\": { \"sns\":1, \"app\":1 } }" dataUsingEncoding:NSUTF8StringEncoding];
        [GreeURLMockingProtocol addMock:response];
        __block GreeBadgeValues *returnValue = nil;

        [[GreePlatform sharedInstance] updateBadgeValuesWithBlock:^(GreeBadgeValues *badgeValues) {
          returnValue = [badgeValues retain];
        }];
      
        [[expectFutureValue(returnValue) shouldEventually] beNonNil];
      
        [[theValue(returnValue.socialNetworkingServiceBadgeCount) should] equal:theValue(1)];
        [[theValue(returnValue.applicationBadgeCount) should] equal:theValue(1)];
        
        [returnValue release];
      });
      
      it(@"should pass the new values through the block parameter", ^{
        MockedURLResponse* response = [[[MockedURLResponse alloc] init] autorelease];
        response.data = [@"{ \"entry\": { \"sns\":1, \"app\":1 } }" dataUsingEncoding:NSUTF8StringEncoding];
        [GreeURLMockingProtocol addMock:response];
        __block GreeBadgeValues *returnValue = nil;

        [[GreePlatform sharedInstance] updateBadgeValuesWithBlock:^(GreeBadgeValues *badgeValues) {
          returnValue = [badgeValues retain];
        }];
      
        [[expectFutureValue(returnValue) shouldEventually] beNonNil];
      
        [[theValue(returnValue.socialNetworkingServiceBadgeCount) should] equal:theValue(1)];
        [[theValue(returnValue.applicationBadgeCount) should] equal:theValue(1)];
        
        [returnValue release];
      });
      
      it(@"should return the current badge values if there is a network error", ^{
        MockedURLResponse* response = [[[MockedURLResponse alloc] init] autorelease];
        response.statusCode = 500;
        [GreeURLMockingProtocol addMock:response];
        __block GreeBadgeValues *returnValue = nil;

        [[GreePlatform sharedInstance] updateBadgeValuesWithBlock:^(GreeBadgeValues *badgeValues) {
          returnValue = [badgeValues retain];
        }];
      
        [[expectFutureValue(returnValue) shouldEventually] beNonNil];
      
        [[theValue(returnValue.socialNetworkingServiceBadgeCount) should] equal:theValue(0)];
        [[theValue(returnValue.applicationBadgeCount) should] equal:theValue(0)];
        
        [returnValue release];
      });

    });

    context(@"when updating bootstrap settings", ^{
      __block id sentinel = nil;
      
      beforeEach(^{
        [GreeURLMockingProtocol register];
        [GreeNetworkReachability stub:@selector(alloc) andReturn:[GreeNetworkReachability nullMockWithStatus:GreeNetworkReachabilityConnectedViaWiFi]];
        [GreePlatform initializeWithApplicationId:@"123" consumerKey:@"123" consumerSecret:@"123" settings:nil delegate:nil];
        [[GreePlatform sharedInstance] stub:@selector(httpsClient) andReturn:[GreeHTTPClient nullMock]];
        sentinel = nil;
      });
      
      afterEach(^{
        [[[GreePlatform sharedInstance] shouldEventuallyBeforeTimingOutAfter(10.f)] receive:@selector(dealloc)];
        [GreePlatform shutdown];
        [GreeURLMockingProtocol unregister];
      });

      it(@"should use correct path", ^{
        MockedURLResponse* response = [MockedURLResponse getResponseWithHttpStatus:200];
        response.requestBlock = ^(NSURLRequest* request) {
          [[request.HTTPMethod should] equal:@"GET"];
          [[[request.URL absoluteString] should] containString:@"api/rest/sdkbootstrap/123/ios"];
          return YES;
        };
        [GreeURLMockingProtocol addMock:response];
        [[GreePlatform sharedInstance] updateBootstrapSettingsWithAttemptNumber:1 statusBlock:^BOOL(BOOL didSucceed) {
          sentinel = @"YES";
          return NO;
        }];
        [[expectFutureValue(sentinel) shouldEventually] beNonNil];
      });

      it(@"should use correct path if user have logged in", ^{
        MockedURLResponse* response = [MockedURLResponse getResponseWithHttpStatus:200];
        response.requestBlock = ^(NSURLRequest* request) {
          [[request.HTTPMethod should] equal:@"GET"];
          [[[request.URL absoluteString] should] containString:@"api/rest/sdkbootstrap/123/ios/12345"];
          return YES;
        };
        [GreeURLMockingProtocol addMock:response];
        [[GreePlatform sharedInstance] stub:@selector(localUserId) andReturn:@"12345"];
        [[GreePlatform sharedInstance] updateBootstrapSettingsWithAttemptNumber:1 statusBlock:^BOOL(BOOL didSucceed) {
          sentinel = @"YES";
          return NO;
        }];
        [[expectFutureValue(sentinel) shouldEventually] beNonNil];
      });

      it(@"should explicitly use 2 legged OAuth", ^{
        MockedURLResponse* response = [MockedURLResponse getResponseWithHttpStatus:200];
        [GreeURLMockingProtocol addMock:response];
        [[[[GreePlatform sharedInstance] httpsClient] should] receive:@selector(performTwoLeggedRequestWithMethod:path:parameters:success:failure:)];
        [[GreePlatform sharedInstance] updateBootstrapSettingsWithAttemptNumber:1 statusBlock:^BOOL(BOOL didSucceed) {
          sentinel = @"YES";
          return NO;
        }];
        [[expectFutureValue(sentinel) shouldEventually] beNonNil];
      });

      it(@"should call writeBootstrapSettings upon success", ^{
        MockedURLResponse* response = [MockedURLResponse getResponseWithHttpStatus:200];
        response.data = [@"{ \"entry\" : { \"settings\" : { \"test\" : 123 } } }" dataUsingEncoding:NSUTF8StringEncoding];
        [GreeURLMockingProtocol addMock:response];

        GreePlatform* platform = [GreePlatform sharedInstance];
        [platform stub:@selector(writeBootstrapSettingsDictionary:)];
        [[platform shouldEventuallyBeforeTimingOutAfter(2.f)] receive:@selector(writeBootstrapSettingsDictionary:)];
        [platform updateBootstrapSettingsWithAttemptNumber:1 statusBlock:^BOOL(BOOL didSucceed) {
          [[theValue(didSucceed) should] beYes];
          sentinel = @"YES";
          return NO;
        }];
        [[expectFutureValue(sentinel) shouldEventually] beNonNil];
      });

      it(@"should fail and not call writeBootstrapSettings upon empty data", ^{
        MockedURLResponse* response = [MockedURLResponse getResponseWithHttpStatus:200];
        response.data = [@"{}" dataUsingEncoding:NSUTF8StringEncoding];
        [GreeURLMockingProtocol addMock:response];

        GreePlatform* platform = [GreePlatform sharedInstance];
        [platform stub:@selector(writeBootstrapSettingsDictionary:)];
        [[platform shouldNot] receive:@selector(writeBootstrapSettingsDictionary:)];
        [platform updateBootstrapSettingsWithAttemptNumber:1 statusBlock:^BOOL(BOOL didSucceed) {
          [[theValue(didSucceed) should] beNo];
          sentinel = @"YES";
          return NO;
        }];
        [[expectFutureValue(sentinel) shouldEventually] beNonNil];
      });

      it(@"should not call writeBootstrapSettings upon failure", ^{
        MockedURLResponse* response = [MockedURLResponse getResponseWithHttpStatus:500];
        [GreeURLMockingProtocol addMock:response];

        GreePlatform* platform = [GreePlatform sharedInstance];
        [platform stub:@selector(writeBootstrapSettingsDictionary:)];
        [[platform shouldNot] receive:@selector(writeBootstrapSettingsDictionary:)];
        [platform updateBootstrapSettingsWithAttemptNumber:1 statusBlock:^BOOL(BOOL didSucceed) {
          [[theValue(didSucceed) should] beNo];
          sentinel = @"YES";
          return NO;
        }];
        [[expectFutureValue(sentinel) shouldEventually] beNonNil];
      });
      
    });

  });
  
  context(@"when reading/writing bootstrap settings", ^{
    __block GreePlatform* platform = nil;

    beforeEach(^{
      GreeSettings* settings = [[GreeSettings alloc] init];
      [settings applySettingDictionary:[NSDictionary dictionaryWithObject:@"secret" forKey:GreeSettingConsumerSecret]];
      [settings finalizeSettings];
      platform = [[GreePlatform alloc] init];
      [platform stub:@selector(settings) andReturn:settings];
      [settings release];
    });
    
    afterEach(^{
      [platform release];
      platform = nil;
    });
    
    it(@"should read from bootstrapSettings cached file", ^{
      NSData* mockedData = [NSData nullMock];
      [NSData stub:@selector(alloc) andReturn:mockedData];
      [[mockedData should] receive:@selector(initWithContentsOfFile:) withArguments:[NSString greeCachePathForRelativePath:@"bootstrapSettings"]];
      [platform bootstrapSettingsDictionary];
    });
    
    it(@"should not read settings if hashes do not match", ^{
      NSData* mockedData = [NSData nullMock];
      [mockedData stub:@selector(greeHashWithKey:) andReturn:@"correcthash"];
      [NSData stub:@selector(alloc) andReturn:mockedData];
      
      [[mockedData shouldNot] receive:@selector(greeObjectFromJSONData)];
      
      [[NSUserDefaults standardUserDefaults] 
        stub:@selector(stringForKey:) 
        andReturn:@"wronghash" 
        withArguments:@"GreeBootstrapSettings"];

      [[[NSUserDefaults standardUserDefaults] should] 
        receive:@selector(stringForKey:) 
        withArguments:@"GreeBootstrapSettings"];

      [[platform bootstrapSettingsDictionary] shouldBeNil];
    });

    it(@"should not update hash if write fails", ^{
      NSDictionary* settings = [NSDictionary dictionaryWithObject:@"foo" forKey:@"bar"];
      NSData* data = [@"{ \"foo\" : \"bar\" }" dataUsingEncoding:NSUTF8StringEncoding];
      [NSClassFromString(@"GreeJKSerializer") stub:@selector(serializeObject:options:encodeOption:block:delegate:selector:error:) andReturn:data];
      [data stub:@selector(writeToFile:options:error:) andReturn:theValue(NO)];
      [[[NSUserDefaults standardUserDefaults] shouldNot] receive:@selector(setObject:forKey:)];
      [platform writeBootstrapSettingsDictionary:settings];
    });
    
    it(@"should update hash if write succeeds", ^{
      NSDictionary* settings = [NSDictionary dictionaryWithObject:@"foo" forKey:@"bar"];
      NSData* data = [@"{ \"foo\" : \"bar\" }" dataUsingEncoding:NSUTF8StringEncoding];
      [data stub:@selector(writeToFile:options:error:) andReturn:theValue(YES)];
      [[[NSUserDefaults standardUserDefaults] should] receive:@selector(setObject:forKey:)];
      [[NSUserDefaults standardUserDefaults] stub:@selector(setObject:forKey:)];
      [platform writeBootstrapSettingsDictionary:settings];
    });
    
  });
    
});

SPEC_END
