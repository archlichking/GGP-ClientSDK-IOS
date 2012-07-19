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
#import "GreeAchievement.h"

#import "GreePlatform.h"
#import "GreeHTTPClient.h"
#import "GreeURLMockingProtocol.h"
#import "AFNetworking.h"
#import "GreeError.h"
#import "GreeSerializer.h"
#import "GreeTestHelpers.h"
#import "GreeWriteCache.h"
#import "GreeNetworkReachability.h"
#import "GreeSettings.h"
#import <GameKit/GameKit.h>
#import "GreeUser.h"
#import "GreePlatform+Internal.h"

static NSString* ach1jsontext = @"{ \"id\"  : \"mockid\", \"name\" : \"mockname\", \"description\": \"mockdesc\", \"thumbnail_url\" : \"mockUrl\", \"lock_thumbnail_url\" : \"mockLockUrl\", \"secret\":1, \"status\":1}";
static NSString* ach2jsontext = @"{ \"id2\" : \"mockid\", \"name\" : \"mockname\", \"description\": \"mockdesc\", \"thumbnail_url\" : \"mockUrl\", \"lock_thumbnail_url\" : \"mockLockUrl\", \"secret\":1, \"status\":1}";
static NSString* ach3jsontext = @"{ \"id3\" : \"mockid\", \"name\" : \"mockname\", \"description\": \"mockdesc\", \"thumbnail_url\" : \"mockUrl\", \"lock_thumbnail_url\" : \"mockLockUrl\", \"secret\":1, \"status\":1}";
static NSString* ach4jsontext = @"{ \"id4\" : \"mockid\", \"name\" : \"mockname\", \"description\": \"mockdesc\", \"thumbnail_url\" : \"mockUrl\", \"lock_thumbnail_url\" : \"mockLockUrl\", \"secret\":1, \"status\":1}";
static NSString* ach5jsontext = @"{ \"id5\" : \"mockid\", \"name\" : \"mockname\", \"description\": \"mockdesc\", \"thumbnail_url\" : \"mockUrl\", \"lock_thumbnail_url\" : \"mockLockUrl\", \"secret\":1, \"status\":1}";

SPEC_BEGIN(GreeAchievementTests)

describe(@"Gree Achievements", ^{
  __block NSData* longList = nil;
  __block GreePlatform* mockedSdk = nil;
  __block GreeAuthorization *authMock;
  
  beforeAll(^{
    longList = [[[NSString stringWithFormat:@"{ \"entry\":[ %@, %@, %@, %@, %@ ] }", ach1jsontext, ach2jsontext, ach3jsontext, ach4jsontext, ach5jsontext] dataUsingEncoding:NSUTF8StringEncoding] retain];
  });
  
  afterAll(^{
    [longList release];
    longList = nil;
  });

  beforeEach(^{
    mockedSdk = [[GreePlatform nullMockAsSharedInstance] retain];
    [mockedSdk stub:@selector(httpClient) andReturn:[GreeHTTPClient nullMock]];
    [mockedSdk stub:@selector(localUser) andReturn:[GreeUser nullMock]];
    [GreeURLMockingProtocol register];
    authMock = [GreeAuthorization nullMock];
    [authMock stub:@selector(isAuthorized) andReturn:theValue(YES)];
    [GreeAuthorization stub:@selector(sharedInstance) andReturn:authMock];
  });
  
  afterEach(^{
    [GreeURLMockingProtocol unregister];
    [mockedSdk release];
    mockedSdk = nil;
    authMock = nil;
  });
  
  it(@"should deserialize", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"mockid", @"id",
                                @"mockname", @"name",
                                @"mockdesc", @"description",
                                @"mockurl", @"thumbnail_url",
                                @"mocklockurl", @"lock_thumbnail_url",
                                [NSNumber numberWithBool:YES], @"secret",
                                [NSNumber numberWithBool:YES], @"status",
                                nil];
    
    GreeSerializer* serializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeAchievement* ach = [[GreeAchievement alloc] initWithGreeSerializer:serializer];
    [[ach.identifier should] equal:@"mockid"];
    [[ach.name should] equal:@"mockname"];
    [[ach.descriptionText should] equal:@"mockdesc"];
    [[[ach performSelector:@selector(iconUrl)] should] equal:[NSURL URLWithString:@"mockurl"]];
    [[[ach performSelector:@selector(lockedIconUrl)] should] equal:[NSURL URLWithString:@"mocklockurl"]];
    [[theValue(ach.isSecret) should] beTrue];
    [[theValue(ach.isUnlocked) should] beFalse];
    [ach release];
  });
  
  it(@"should show description", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"mockid", @"id",
                                @"mockname", @"name",
                                @"mockdesc", @"description",
                                @"mockurl", @"thumbnail_url",
                                @"mocklockurl", @"lock_thumbnail_url",
                                [NSNumber numberWithBool:YES], @"secret",
                                [NSNumber numberWithBool:YES], @"status",
                                nil];
    
    GreeSerializer* serializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeAchievement* ach = [[GreeAchievement alloc] initWithGreeSerializer:serializer];
    //the address is variable
    NSString* checkString = [NSString stringWithFormat:@"<GreeAchievement:%p, identifer:mockid, name:mockname, description:mockdesc, iconUrl:mockurl, lockedIconUrl:mocklockurl, isSecret:YES, isUnlocked:NO score:0>", ach];
    [[[ach description] should] equal:checkString]; 
    [ach release];
  });
  
  it(@"should serialize", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"mockid", @"id",
                                @"mockname", @"name",
                                @"mockdesc", @"description",
                                @"mockurl", @"thumbnail_url",
                                @"mocklockurl", @"lock_thumbnail_url",
                                [NSNumber numberWithBool:YES], @"secret",
                                [NSNumber numberWithBool:YES], @"status",
                                [NSNumber numberWithInt:10], @"score",
                                nil];
    
    GreeSerializer* deserializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeAchievement* ach = [[GreeAchievement alloc] initWithGreeSerializer:deserializer];
    GreeSerializer* serializer = [GreeSerializer serializer];
    [ach serializeWithGreeSerializer:serializer];
    [[serializer.rootDictionary should] equal:serialized];
  });
  
  it(@"should have a designated initializer", ^{
    GreeAchievement* achievement = [[GreeAchievement alloc] initWithIdentifier:@"testIdentifier"];
    [[achievement.identifier should] equal:@"testIdentifier"];
    [achievement.name shouldBeNil];
    [achievement.descriptionText shouldBeNil];
    [[theValue(achievement.isSecret) should] beNo];
    [[theValue(achievement.isUnlocked) should] beNo];
    [[theValue(achievement.score) should] equal:theValue(0)];
    [achievement release];
  });
  
  it(@"should download achievements", ^{
    __block id waitObject = nil;
    MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
    mock.data = longList;
    [GreeURLMockingProtocol addMock:mock];
    [GreeAchievement loadAchievementsWithBlock:^(NSArray*achievements, NSError*error) {
      waitObject = [achievements retain];
    }];
    [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    GreeAchievement* ach = [waitObject objectAtIndex:0];
    [[ach.identifier should] equal:@"mockid"];
    [[ach.name should] equal:@"mockname"];
    [[ach.descriptionText should] equal:@"mockdesc"];
    [[[ach performSelector:@selector(iconUrl)] should] equal:[NSURL URLWithString:@"mockUrl"]];
    [[[ach performSelector:@selector(lockedIconUrl)] should] equal:[NSURL URLWithString:@"mockLockUrl"]];
    [[theValue(ach.isSecret) should] beTrue];
    [[theValue(ach.isUnlocked) should] beFalse];
    [waitObject release];
  });  
  
  it(@"should handle failure when downloading achievements", ^{
    __block id waitObject = nil;
    MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
    mock.statusCode = 500;  //server flaked
    [GreeURLMockingProtocol addMock:mock];
    
    [GreeAchievement loadAchievementsWithBlock:^(NSArray *achievements, NSError*error) {
      waitObject = [error copy];
    }];
    [[expectFutureValue(waitObject) shouldEventually] beKindOfClass:[NSError class]];
    [waitObject release];
  });
  
  it(@"should handle missing block in achievement download", ^{
    [GreeAchievement loadAchievementsWithBlock:nil];
    //just not dying is a sufficient test
  });
  
  context(@"with a mock achievement", ^{
    __block GreeAchievement* mockAchievement = nil;
    
    beforeEach(^{
      NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"mockid", @"id",
                                  @"mockname", @"name",
                                  @"mockdesc", @"description",
                                  @"mockurl", @"thumbnail_url",
                                  @"mocklockurl", @"lock_thumbnail_url",
                                  [NSNumber numberWithBool:YES], @"secret",
                                  [NSNumber numberWithBool:NO], @"status",
                                  [NSNumber numberWithInt:10], @"score",
                                  nil];
      
      GreeSerializer* deserializer = [GreeSerializer deserializerWithDictionary:serialized];
      mockAchievement = [[GreeAchievement alloc] initWithGreeSerializer:deserializer];

      NSURL* baseURL = [NSURL URLWithString:[GreeURLMockingProtocol httpClientPrefix]];
      [mockAchievement setValue:[NSURL URLWithString:@"iconload" relativeToURL:baseURL] forKeyPath:@"iconUrl"];
      [mockAchievement setValue:[NSURL URLWithString:@"lockediconload" relativeToURL:baseURL] forKeyPath:@"lockedIconUrl"];
    });
    
    afterEach(^{
      [mockAchievement release];
      mockAchievement = nil;
    });

    it(@"should download icons", ^{
      __block id waitObject = nil;
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      UIImage* blankImage = [[UIImage alloc] init];
      mock.data = UIImagePNGRepresentation(blankImage);
      [GreeURLMockingProtocol addMock:mock];

      [mockAchievement loadIconWithBlock:^(UIImage *image, NSError *error) {
        waitObject = [image retain];
      }];
      [[expectFutureValue(waitObject) shouldEventually] beKindOfClass:[UIImage class]];
      [waitObject release];
    });

    it(@"should handle failure when downloading icon", ^{
      __block id waitObject = nil;
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      mock.statusCode = 500;  //server flaked
      [GreeURLMockingProtocol addMock:mock];
      
      [mockAchievement loadIconWithBlock:^(UIImage *image, NSError *error) {
        waitObject = [error copy];
      }];
      [[expectFutureValue(waitObject) shouldEventually] beKindOfClass:[NSError class]];
      [waitObject release];
    });
    
    it(@"should handle missing block in icon download", ^{
      [mockAchievement loadIconWithBlock:nil];
    });

    it(@"should handle cancelled icon download", ^{
      __block id waitObject = nil;
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      UIImage* blankImage = [[UIImage alloc] init];
      mock.data = UIImagePNGRepresentation(blankImage);
      mock.delay = .1f;
      [GreeURLMockingProtocol addMock:mock];
      
      [mockAchievement loadIconWithBlock:^(UIImage* image, NSError* error) {
        waitObject = [image retain];
      }];

      [mockAchievement cancelIconLoad];
      
      [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:mock.delay + .01f]];
      [waitObject shouldBeNil];
    });

    it(@"should handle cancelled icon download when there is no download in progress", ^{
      [mockAchievement cancelIconLoad];
    });

    it(@"should download locked icons", ^{
      __block id waitObject = nil;
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      UIImage* blankImage = [[UIImage alloc] init];
      mock.data = UIImagePNGRepresentation(blankImage);
      [GreeURLMockingProtocol addMock:mock];
      
      [mockAchievement setValue:[NSNumber numberWithBool:NO] forKey:@"isUnlocked"];
      
      [mockAchievement loadIconWithBlock:^(UIImage *image, NSError *error) {
        waitObject = [image retain];
      }];
      [[expectFutureValue(waitObject) shouldEventually] beKindOfClass:[UIImage class]];
      [waitObject release];
    });

    it(@"should handle failure when downloading locked icon", ^{
      __block id waitObject = nil;
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      mock.statusCode = 500;  //server flaked
      [GreeURLMockingProtocol addMock:mock];
      
      [mockAchievement setValue:[NSNumber numberWithBool:NO] forKey:@"isUnlocked"];
      
      [mockAchievement loadIconWithBlock:^(UIImage *image, NSError *error) {
        waitObject = [error copy];
      }];
      [[expectFutureValue(waitObject) shouldEventually] beKindOfClass:[NSError class]];
      [waitObject release];
    });

  });
  
  context(@"enumerator", ^{
    __block id enumerator = nil; 
    beforeEach(^{
      enumerator = [GreeAchievement loadAchievementsWithBlock:nil];
    });
    
    it(@"should exist", ^{
      [[enumerator should] beNonNil];
    });
    
    it(@"should read a page", ^{
      __block id waitObject = nil;
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      mock.data = longList;
      [GreeURLMockingProtocol addMock:mock];
      
      [enumerator loadNext:^(NSArray *items, NSError *error) {
        waitObject = [items retain];
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      [[theValue([waitObject count]) should] equal:theValue(5)];
      [[[waitObject objectAtIndex:0] should] beKindOfClass:[GreeAchievement class]];
      [waitObject release];
    });
    
    it(@"should go back a page", ^{
      __block id waitObject = nil;
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      mock.data = longList;
      [GreeURLMockingProtocol addMock:mock];
      [GreeURLMockingProtocol addMock:mock];
      
      [enumerator loadNext:^(NSArray *items, NSError *error) {
        [enumerator loadPrevious:^(NSArray *items, NSError *error) {
          waitObject = [items retain];
        }];
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      [[theValue([waitObject count]) should] equal:theValue(5)];
      [[[waitObject objectAtIndex:3] should] beKindOfClass:[GreeAchievement class]];
      [waitObject release];
    });
  });
  
  context(@"when dealing with the write cache", ^{
    __block GreeAchievement* testAchievement = nil;
    __block GreeWriteCache* writeCacheMock = nil;

    beforeEach(^{
      testAchievement = [[GreeAchievement alloc] init];
      [testAchievement setValue:@"TESTID" forKeyPath:@"identifier"];
      writeCacheMock = [[GreeWriteCache nullMock] retain];
      [mockedSdk stub:@selector(writeCache) andReturn:writeCacheMock];
    });
    
    afterEach(^{
      [testAchievement release];
      testAchievement = nil;
      [writeCacheMock release];
      writeCacheMock = nil;
    });
    
    it(@"should provide it's identifier as it's write cache category", ^{
      [[[testAchievement writeCacheCategory] should] equal:testAchievement.identifier];
    });
    
    it(@"should have a max write cache category size of 1", ^{
      [[theValue([GreeAchievement writeCacheMaxCategorySize]) should] equal:theValue(1)];
    });
    
    it(@"should not crash when unlocked with nil block", ^{
      [testAchievement unlockWithBlock:nil];
    });

    it(@"should not crash when relocked with nil block", ^{
      [testAchievement relockWithBlock:nil];
    });

    it(@"should submit to writecache when unlocking", ^{
      [[writeCacheMock should] receive:@selector(writeObject:) withArguments:testAchievement, nil];
      [testAchievement unlockWithBlock:nil];
      [[theValue(testAchievement.isUnlocked) should] beYes];
    });
    
    it(@"should submit to writecache when relocking", ^{
      [testAchievement unlockWithBlock:nil];
      [[theValue(testAchievement.isUnlocked) should] beYes];

      [[writeCacheMock should] receive:@selector(writeObject:) withArguments:testAchievement, nil];
      [testAchievement relockWithBlock:nil];
      [[theValue(testAchievement.isUnlocked) should] beNo];
    });
    
    it(@"should attempt to commit the writecache if online", ^{
      [mockedSdk stub:@selector(reachability) andReturn:[GreeNetworkReachability nullMockWithStatus:GreeNetworkReachabilityConnectedViaWiFi]];
      [[writeCacheMock should] receive:@selector(commitAllObjectsOfClass:inCategory:) withCount:2 arguments:theValue([testAchievement class]), [testAchievement writeCacheCategory], nil];
      [testAchievement unlockWithBlock:nil];
      [testAchievement relockWithBlock:nil];
    });
    
    it(@"should not attempt to commit the writecache if offline", ^{
      [mockedSdk stub:@selector(reachability) andReturn:[GreeNetworkReachability nullMockWithStatus:GreeNetworkReachabilityNotConnected]];
      [[writeCacheMock shouldNot] receive:@selector(commitAllObjectsOfClass:inCategory:)];
      [testAchievement unlockWithBlock:nil];
      [testAchievement relockWithBlock:nil];
    });

  });
  
  it(@"should not unlock on GameCenter without a valid mapping", ^{
    GreeAchievement* testAchievement = [[[GreeAchievement alloc] init] autorelease];
    [testAchievement setValue:@"TESTID" forKeyPath:@"identifier"];
    [[testAchievement should] receive:@selector(gameCenterAchievement) andReturn:nil];
    [testAchievement unlockWithBlock:nil];
  });

  it(@"should submit to GameCenter with a valid mapping", ^{
    GreeAchievement* testAchievement = [[[GreeAchievement alloc] init] autorelease];
    [testAchievement setValue:@"TESTID" forKeyPath:@"identifier"];

    NSDictionary* achievementMap = [NSDictionary dictionaryWithObjectsAndKeys:@"gameCenterIdentifier", @"testAchievement", nil];
    GreeSettings* settings = [[GreeSettings alloc] init];
    [settings applySettingDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
      achievementMap, GreeSettingGameCenterAchievementMapping,
      nil]];
    [[GreePlatform sharedInstance] stub:@selector(settings) andReturn:settings];
    
    void(^responseBlock)(NSError*) = Block_copy(^(NSError* error) {
    });
    
    [testAchievement setGameCenterResponseBlock:responseBlock];

    GKAchievement* mock = [GKAchievement nullMock];
    [[mock should] receive:@selector(reportAchievementWithCompletionHandler:) withArguments:responseBlock];
    [testAchievement stub:@selector(gameCenterAchievement) andReturn:mock];
    
    [testAchievement unlockWithBlock:nil];
  });
  
  it(@"should have a GameCenter object factory method", ^{
    GreeAchievement* testAchievement = [[[GreeAchievement alloc] init] autorelease];
    [testAchievement setValue:@"TESTID" forKeyPath:@"identifier"];

    NSDictionary* achievementMap = [NSDictionary dictionaryWithObjectsAndKeys:@"gameCenterIdentifier", @"TESTID", nil];
    GreeSettings* settings = [[GreeSettings alloc] init];
    [settings applySettingDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
      achievementMap, GreeSettingGameCenterAchievementMapping,
      nil]];
    [[GreePlatform sharedInstance] stub:@selector(settings) andReturn:settings];
    
    GKAchievement* gkAchievement = [testAchievement performSelector:@selector(gameCenterAchievement)];
    [gkAchievement shouldNotBeNil];
    [[theValue(gkAchievement.percentComplete) should] equal:theValue(100.)];
    [[gkAchievement.identifier should] equal:@"gameCenterIdentifier"];
  });
  
  context(@"when committing", ^{
    __block BOOL didFinish = NO;
    __block BOOL didSucceed = NO;
    __block GreeAchievement* testAchievement = nil;
    
    beforeEach(^{
      testAchievement = [[GreeAchievement alloc] init];
      [testAchievement setValue:@"TESTID" forKeyPath:@"identifier"];
      didFinish = NO;
    });
    
    afterEach(^{
      [testAchievement release];
      testAchievement = nil;
    });

    it(@"should handle a successful unlock", ^{
      [testAchievement unlockWithBlock:nil];
      [GreeURLMockingProtocol addMock:[MockedURLResponse postResponseWithHttpStatus:200]];
      [testAchievement writeCacheCommitAndExecuteBlock:^(BOOL commitDidSucceed) {
        didFinish = YES;
        didSucceed = commitDidSucceed;
      }];
      
      [[expectFutureValue(theValue(didFinish)) shouldEventuallyBeforeTimingOutAfter(1.f)] beYes];
      [[expectFutureValue(theValue(didSucceed)) shouldEventuallyBeforeTimingOutAfter(1.f)] beYes];
    });
    
    it(@"should handle a failed unlock", ^{
      didSucceed = YES;
      [testAchievement unlockWithBlock:nil];
      [GreeURLMockingProtocol addMock:[MockedURLResponse postResponseWithHttpStatus:500]];
      [testAchievement writeCacheCommitAndExecuteBlock:^(BOOL commitDidSucceed) {
        didFinish = YES;
        didSucceed = commitDidSucceed;
      }];
      
      [[expectFutureValue(theValue(didFinish)) shouldEventuallyBeforeTimingOutAfter(1.f)] beYes];
      [[expectFutureValue(theValue(didSucceed)) shouldEventuallyBeforeTimingOutAfter(1.f)] beNo];
    });

    it(@"should handle a successful relock", ^{
      [testAchievement relockWithBlock:nil];
      [GreeURLMockingProtocol addMock:[MockedURLResponse deleteResponseWithHttpStatus:200]];
      [testAchievement writeCacheCommitAndExecuteBlock:^(BOOL commitDidSucceed) {
        didFinish = YES;
        didSucceed = commitDidSucceed;
      }];
      
      [[expectFutureValue(theValue(didFinish)) shouldEventuallyBeforeTimingOutAfter(1.f)] beYes];
      [[expectFutureValue(theValue(didSucceed)) shouldEventuallyBeforeTimingOutAfter(1.f)] beYes];
    });
    
    it(@"should handle a failed relock", ^{
      didSucceed = YES;
      [testAchievement relockWithBlock:nil];
      [GreeURLMockingProtocol addMock:[MockedURLResponse deleteResponseWithHttpStatus:500]];
      [testAchievement writeCacheCommitAndExecuteBlock:^(BOOL commitDidSucceed) {
        didFinish = YES;
        didSucceed = commitDidSucceed;
      }];
      
      [[expectFutureValue(theValue(didFinish)) shouldEventuallyBeforeTimingOutAfter(1.f)] beYes];
      [[expectFutureValue(theValue(didSucceed)) shouldEventuallyBeforeTimingOutAfter(1.f)] beNo];
    });

  });
  
});

SPEC_END

