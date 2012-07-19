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
#import "GreeScore.h"
#import "GreeLeaderboard.h"
#import "GreePlatform.h"
#import "GreeHTTPClient.h"
#import "GreeURLMockingProtocol.h"
#import "GreeSerializer.h"
#import "GreeTestHelpers.h"
#import "GreeNetworkReachability.h"
#import "GreeWriteCache.h"
#import "GreeSettings.h"
#import "GreeUser+Internal.h"
#import <GameKit/GameKit.h>

static NSString* scoreJsonText = @"{\"id\": \"1\",\"nickname\": \"Kitty\",\"thumbnailUrlHuge\": \"http://gree.jp/img/94783.jpg\",\"rank\": 1,\"score\": \"12938471\"}";

#pragma mark - GreeScoreTests

SPEC_BEGIN(GreeScoreTests)

describe(@"Gree Score", ^{
  __block NSData* onePageData = nil;
  __block GreePlatform* mockedSdk = nil;
  __block GreeAuthorization *authMock;
  
  beforeEach(^{
    mockedSdk = [[GreePlatform nullMockAsSharedInstance] retain];
    StubGreeLocalUser();
    [mockedSdk stub:@selector(httpClient) andReturn:[GreeHTTPClient nullMock]];
    [GreeURLMockingProtocol register];
    onePageData = [[NSString stringWithFormat:@"{\"entry\":[%@, %@, %@, %@, %@], \"hasNext\":\"0\"}", scoreJsonText, scoreJsonText, scoreJsonText, scoreJsonText, scoreJsonText] dataUsingEncoding:NSUTF8StringEncoding];
    authMock = [[GreeAuthorization alloc] init];
    [authMock stub:@selector(isAuthorized) andReturn:theValue(YES)];
    [GreeAuthorization stub:@selector(sharedInstance) andReturn:authMock];
  });
  
  afterEach(^{
    [GreeURLMockingProtocol unregister];
    [mockedSdk release];
    mockedSdk = nil;
    [authMock release];
    authMock = nil;
  });
  
  context(@"when deserializing", ^{
    
    it(@"should deserialize", ^{
      NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockid", @"id",
        @"mocknickname", @"nickname",
        @"mockUrl", @"thumbnailUrlHuge",
        [NSNumber numberWithInt:1], @"rank",
        @"732965937", @"score",
        nil];
      GreeSerializer* serializer = [GreeSerializer deserializerWithDictionary:serialized];
      GreeScore* score = [[GreeScore alloc] initWithGreeSerializer:serializer];
      [[theValue(score.score) should] equal:theValue(732965937)];
      [[theValue(score.rank) should] equal:theValue((1))];
      [score release];      
    });

    it(@"should not crash when given an NSNumber score", ^{
      NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInteger:732965937], @"score",
        nil];
      GreeSerializer* serializer = [GreeSerializer deserializerWithDictionary:serialized];
      GreeScore* score = [[GreeScore alloc] initWithGreeSerializer:serializer];
      [score release];
    });
    
    it(@"should seed score property from score field", ^{
      NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
        @"732965937", @"score",
        nil];
      GreeSerializer* serializer = [GreeSerializer deserializerWithDictionary:serialized];
      GreeScore* score = [[GreeScore alloc] initWithGreeSerializer:serializer];
      [[[score valueForKey:@"formattedScore"] should] equal:@"732965937"];
      [[theValue(score.score) should] equal:theValue(732965937)];
      [score release];
    });
    
    it(@"should seed score property with seconds parsed from score formatted as time", ^{
      NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
        @"13:09:23", @"score",
        nil];
      int64_t seconds = (13*60*60) + (9*60) + 23;
      GreeSerializer* serializer = [GreeSerializer deserializerWithDictionary:serialized];
      GreeScore* score = [[GreeScore alloc] initWithGreeSerializer:serializer];
      [[[score valueForKey:@"formattedScore"] should] equal:@"13:09:23"];
      [[theValue(score.score) should] equal:theValue(seconds)];
      [score release];
    });
    
    it(@"should seed score property with integralScore field when score is not present", ^{
      NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInteger:42], @"integralScore",
        nil];
      GreeSerializer* serializer = [GreeSerializer deserializerWithDictionary:serialized];
      GreeScore* score = [[GreeScore alloc] initWithGreeSerializer:serializer];
      [[score valueForKey:@"formattedScore"] shouldBeNil];
      [[theValue(score.score) should] equal:theValue(42)];
      [score release];      
    });
    
    it(@"should ignore integralScore when score is present", ^{
      NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
        @"42", @"score",
        [NSNumber numberWithInteger:89], @"integralScore",
        nil];
      GreeSerializer* serializer = [GreeSerializer deserializerWithDictionary:serialized];
      [[serializer shouldNot] receive:@selector(int64ForKey:) withArguments:@"integralScore"];
      GreeScore* score = [[GreeScore alloc] initWithGreeSerializer:serializer];
      [[[score valueForKey:@"formattedScore"] should] equal:@"42"];
      [[theValue(score.score) should] equal:theValue(42)];
      [score release];
    });

  });
  
  context(@"when serializing", ^{
    
    it(@"should serialize", ^{
      NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockid", @"id",
        @"mocknickname", @"nickname",
        @"mockUrl", @"thumbnailUrlHuge",
        [NSNumber numberWithInt:1], @"rank",
        [NSNumber numberWithLongLong:732965937], @"integralScore",
        nil];
      GreeSerializer* deserializer = [GreeSerializer deserializerWithDictionary:serialized];
      GreeScore* score = [[GreeScore alloc] initWithGreeSerializer:deserializer];
      GreeSerializer* serializer = [GreeSerializer serializer];
      [score serializeWithGreeSerializer:serializer];
      [[serializer.rootDictionary should] equal:serialized];
      [score release];
    });

    it(@"should write score property as integralScore field", ^{
      GreeScore* score = [[GreeScore alloc] initWithLeaderboard:@"test" score:1234];
      GreeSerializer* serializer = [GreeSerializer serializer];
      [score serializeWithGreeSerializer:serializer];
      [[[serializer.rootDictionary objectForKey:@"integralScore"] should] equal:theValue(1234)];
      [score release];
    });
    
    it(@"should write formattedScore property as score field when present", ^{
      NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
        @"0:0:2", @"score",
        nil];
      GreeSerializer* deserializer = [GreeSerializer deserializerWithDictionary:serialized];
      GreeScore* score = [[GreeScore alloc] initWithGreeSerializer:deserializer];
      GreeSerializer* serializer = [GreeSerializer serializer];
      [score serializeWithGreeSerializer:serializer];
      [[[serializer.rootDictionary objectForKey:@"score"] should] equal:@"0:0:2"];
      [[[serializer.rootDictionary objectForKey:@"integralScore"] should] equal:theValue(2)];
      [score release];
    });
    
    it(@"should not write formattedScore property when not present", ^{
      NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithLongLong:732965937], @"integralScore",
        nil];
      GreeSerializer* deserializer = [GreeSerializer deserializerWithDictionary:serialized];
      GreeScore* score = [[GreeScore alloc] initWithGreeSerializer:deserializer];
      GreeSerializer* serializer = [GreeSerializer serializer];
      [score serializeWithGreeSerializer:serializer];
      [[serializer.rootDictionary objectForKey:@"score"] shouldBeNil];
      [[[serializer.rootDictionary objectForKey:@"integralScore"] should] equal:theValue(732965937)];
      [score release];      
    });

  });
  
  context(@"when formatting score", ^{
    __block GreeScore* score = nil;
    __block GreeLeaderboard* leaderboard = nil;
    
    afterEach(^{
      [score release];
      score = nil;
      [leaderboard release];
      leaderboard = nil;
    });
    
    it(@"should work without a leaderboard", ^{
      score = [[GreeScore alloc] initWithLeaderboard:@"blerp" score:1234];
      [[score formattedScoreWithLeaderboard:nil] shouldNotBeNil];
    });
    
    it(@"should append leaderboard suffix if given", ^{
      score = [[GreeScore alloc] initWithLeaderboard:@"blerp" score:1234];
      leaderboard = [[GreeLeaderboard alloc] init];
      [leaderboard setValue:@"feists" forKey:@"formatSuffix"];
      [[[score formattedScoreWithLeaderboard:leaderboard] should] equal:@"1234 feists"];
    });
    
    it(@"should return formattedScore if present", ^{
      score = [[GreeScore alloc] initWithLeaderboard:@"blerp" score:1234];
      [score setValue:@"1:2:34" forKey:@"formattedScore"];
      [[[score formattedScoreWithLeaderboard:nil] should] equal:@"1:2:34"];
    });
    
    it(@"should format score property if formattedScore isn't set", ^{
      score = [[GreeScore alloc] initWithLeaderboard:@"blerp" score:1234];
      [score setValue:nil forKey:@"formattedScore"];
      [[[score formattedScoreWithLeaderboard:nil] should] equal:@"1234"];
    });

  });

  it(@"should show description", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"mockid", @"id",
                                @"mocknickname", @"nickname",
                                @"mockUrl", @"thumbnailUrlHuge",
                                [NSNumber numberWithInt:1], @"rank",
                                [NSNumber numberWithLongLong:732965937], @"integralScore",
                                @"732965937", @"score",
                                @"mockLeaderboardId", @"leaderboardId",
                                nil];
    GreeSerializer* serializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeScore* score = [[GreeScore alloc] initWithGreeSerializer:serializer];
    NSString* checkString = [NSString stringWithFormat:@"<GreeScore:%p, userId:mockid, score:732965937, formattedScore:732965937, leaderboardId:mockLeaderboardId, rank:1, userNickName:mocknickname, thumbnailUrlHuge:mockUrl>", score];
    [[[score description] should] equal:checkString];
    [score release];
  });

  
  it(@"should download my scores", ^{
    __block id waitObject = nil;
    MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
    mock.data = onePageData;
    [GreeURLMockingProtocol addMock:mock];
    [GreeScore loadMyScoreForLeaderboard:@"mockLeaderboardId" timePeriod:GreeScoreTimePeriodAlltime block:^(GreeScore* score, NSError* error){
      waitObject = [score retain];
    }];
    [[expectFutureValue(waitObject) shouldEventually] beKindOfClass:[GreeScore class]];
    GreeScore* score = (GreeScore*)waitObject;
    [[score.user.userId should] equal:@"1"];
    [[score.user.nickname should] equal:@"Kitty"];
    [[score.user.thumbnailUrlHuge should] equal:[NSURL URLWithString:@"http://gree.jp/img/94783.jpg"]];
    [[theValue(score.score) should] equal:theValue(12938471)];
    [[theValue(score.rank) should] equal:theValue(1)];    
    [[score.leaderboardId should] equal:@"mockLeaderboardId"];
    [waitObject release];
  });

  it(@"should handle failure when downloading my scores", ^{
    __block id waitObject = nil;
    MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
    mock.statusCode = 500;
    [GreeURLMockingProtocol addMock:mock];
    [GreeScore loadMyScoreForLeaderboard:@"mockLeaderboardId" timePeriod:GreeScoreTimePeriodAlltime block:^(GreeScore* score, NSError* error){
      waitObject = [error copy];
    }];
    [[expectFutureValue(waitObject) shouldEventually] beKindOfClass:[NSError class]];
    [waitObject release];
  });
  
  it(@"should handle missing block in my score download", ^{
    //test not dying is enough 
    [GreeScore loadMyScoreForLeaderboard:@"mockLeaderboardId" timePeriod:GreeScoreTimePeriodAlltime block:nil];
  });
  
  it(@"should download all scores", ^{
    __block id waitObject = nil;
    MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
    mock.data = onePageData;
    [GreeURLMockingProtocol addMock:mock];
    [GreeScore loadTopScoresForLeaderboard:@"mockLeaderboardId" timePeriod:GreeScoreTimePeriodAlltime block:^(NSArray* scoreList, NSError* error){
      waitObject = [scoreList retain];
    }];
    [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    [[theValue([waitObject count]) should] equal:theValue(5)];
    GreeScore* score = [waitObject objectAtIndex:0];
    [[score.user.userId should] equal:@"1"];
    [[score.user.nickname should] equal:@"Kitty"];
    [[score.user.thumbnailUrlHuge should] equal:[NSURL URLWithString:@"http://gree.jp/img/94783.jpg"]];
    [[theValue(score.score) should] equal:theValue(12938471)];
    [[theValue(score.rank) should] equal:theValue(1)];    
    [[score.leaderboardId should] equal:@"mockLeaderboardId"];
    [waitObject release];
  });
  
  it(@"should handle failure when downloading all scores", ^{
    __block id waitObject = nil;
    MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
    mock.statusCode = 500;
    [GreeURLMockingProtocol addMock:mock];
    [GreeScore loadTopScoresForLeaderboard:@"mockLeaderboardId" timePeriod:GreeScoreTimePeriodAlltime block:^(NSArray* scoreList, NSError* error){
      waitObject = [error copy];
    }];
    [[expectFutureValue(waitObject) shouldEventually] beKindOfClass:[NSError class]];
    [waitObject release];
  });
  
  it(@"should handle missing block in all score download", ^{
    //test not dying is enough 
    [GreeScore loadTopScoresForLeaderboard:@"mockLeaderboardId" timePeriod:GreeScoreTimePeriodAlltime block:nil];
  });
  
  it(@"should download friends scores", ^{
    __block id waitObject = nil;
    MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
    mock.data = onePageData;
    [GreeURLMockingProtocol addMock:mock];
    [GreeScore loadTopFriendScoresForLeaderboard:@"mockLeaderboardId" timePeriod:GreeScoreTimePeriodAlltime block:^(NSArray* scoreList, NSError* error){
      waitObject = [scoreList retain];
    }];
    [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    [[theValue([waitObject count]) should] equal:theValue(5)];
    GreeScore* score = [waitObject objectAtIndex:0];
    [[score.user.userId should] equal:@"1"];
    [[score.user.nickname should] equal:@"Kitty"];
    [[score.user.thumbnailUrlHuge should] equal:[NSURL URLWithString:@"http://gree.jp/img/94783.jpg"]];
    [[theValue(score.score) should] equal:theValue(12938471)];
    [[theValue(score.rank) should] equal:theValue(1)];    
    [[score.leaderboardId should] equal:@"mockLeaderboardId"];
    [waitObject release];
  });
  
  it(@"should handle failure when downloading friends scores", ^{
    __block id waitObject = nil;
    MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
    mock.statusCode = 500;
    [GreeURLMockingProtocol addMock:mock];
    [GreeScore loadTopFriendScoresForLeaderboard:@"mockLeaderboardId" timePeriod:GreeScoreTimePeriodAlltime block:^(NSArray* scoreList, NSError* error){
      waitObject = [error copy];
    }];
    [[expectFutureValue(waitObject) shouldEventually] beKindOfClass:[NSError class]];
    [waitObject release];
  });
  
  it(@"should handle missing block in friends score download", ^{
    //test not dying is enough 
    [GreeScore loadTopFriendScoresForLeaderboard:@"mockLeaderboardId" timePeriod:GreeScoreTimePeriodAlltime block:nil];
  });
  
  it(@"should exist for score enumerator with default pageSize and startIndex", ^{
    id enumerator = [GreeScore scoreEnumeratorForLeaderboard:@"testLeaderboard" 
                                                         timePeriod:GreeScoreTimePeriodAlltime 
                                                        peopleScope:GreePeopleScopeAll]; 
    [[enumerator should] beNonNil];
  });
  
  context(@"when using time scopes", ^{
    __block id waitObject = nil;
    __block MockedURLResponse* mock = nil;
    beforeEach(^{
      waitObject = nil;
      mock = [[MockedURLResponse alloc] init];
      [GreeURLMockingProtocol addMock:mock];
    });

    it(@"should work with total", ^{
      mock.requestBlock = ^(NSURLRequest* request) {
        NSRange check = [request.URL.absoluteString rangeOfString:@"total"];
        [[theValue(check.location) shouldNot] equal:theValue(NSNotFound)];
        return YES;
      };
      [GreeScore loadTopScoresForLeaderboard:@"mockLeaderboardId" timePeriod:GreeScoreTimePeriodAlltime block:^(NSArray* scoreList, NSError* error){
        waitObject = @"DONE";
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    });
    it(@"should work with weekly", ^{
      mock.requestBlock = ^(NSURLRequest* request) {
        NSRange check = [request.URL.absoluteString rangeOfString:@"weekly"];
        [[theValue(check.location) shouldNot] equal:theValue(NSNotFound)];
        return YES;
      };
      [GreeScore loadTopScoresForLeaderboard:@"mockLeaderboardId" timePeriod:GreeScoreTimePeriodWeekly block:^(NSArray* scoreList, NSError* error){
        waitObject = @"DONE";
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    });
    it(@"should work with daily", ^{
      mock.requestBlock = ^(NSURLRequest* request) {
        NSRange check = [request.URL.absoluteString rangeOfString:@"daily"];
        [[theValue(check.location) shouldNot] equal:theValue(NSNotFound)];
        return YES;
      };
      [GreeScore loadTopScoresForLeaderboard:@"mockLeaderboardId" timePeriod:GreeScoreTimePeriodDaily block:^(NSArray* scoreList, NSError* error){
        waitObject = @"DONE";
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    });
    it(@"should load total with bad value", ^{
      mock.requestBlock = ^(NSURLRequest* request) {
        NSRange check = [request.URL.absoluteString rangeOfString:@"total"];
        [[theValue(check.location) shouldNot] equal:theValue(NSNotFound)];
        return YES;
      };
      [GreeScore loadTopScoresForLeaderboard:@"mockLeaderboardId" timePeriod:777 block:^(NSArray* scoreList, NSError* error){
        waitObject = @"DONE";
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    });

    afterEach(^{
      [mock release];
    });
  });
  
  
  context(@"enumerator", ^{
    __block id enumerator = nil;
    
    beforeEach(^{
      enumerator = [GreeScore scoreEnumeratorForLeaderboard:@"testLeaderboard" 
                                                     timePeriod:GreeScoreTimePeriodAlltime 
                                                    peopleScope:GreePeopleScopeAll];
    });
      
    it(@"should read a page", ^{
      __block id waitObject = nil;
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      mock.data = onePageData;
      [GreeURLMockingProtocol addMock:mock];
      
      [enumerator loadNext:^(NSArray *items, NSError *error) {
        waitObject = [items retain];
      }];
      
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      [[theValue([waitObject count]) should] equal:theValue(5)];
      [[[waitObject objectAtIndex:0] should] beKindOfClass:[GreeScore class]];
      [waitObject release];
    });
    
    it(@"should go back a page", ^{
      __block id waitObject = nil;
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      mock.data = onePageData;
      [GreeURLMockingProtocol addMock:mock];
      [GreeURLMockingProtocol addMock:mock];      
      
      [enumerator loadNext:^(NSArray *items, NSError *error) {
        [enumerator loadPrevious:^(NSArray *items, NSError *error) {
          waitObject = [items retain];
        }];
      }];
      
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      [[theValue([waitObject count]) should] equal:theValue(5)]; 
      [[[waitObject objectAtIndex:0] should] beKindOfClass:[GreeScore class]];
      [waitObject release];
    });
  });
  
  it(@"should fail to initialize when not given a leaderboard", ^{
    GreeScore* score = [[[GreeScore alloc] initWithLeaderboard:@"" score:100] autorelease];
    [score shouldBeNil];
  });
  
  it(@"should set user to localuser when initialized", ^{
    GreeScore* score = [[[GreeScore alloc] initWithLeaderboard:@"testLeaderboard" score:100] autorelease];
    [[score.user should] equal:[GreePlatform sharedInstance].localUser];
  });
  
  it(@"should set rank to unranked when initialized", ^{
    GreeScore* score = [[[GreeScore alloc] initWithLeaderboard:@"testLeaderboard" score:100] autorelease];
    [[theValue(score.rank) should] equal:theValue(GreeScoreUnranked)];
  });

  context(@"when submitting", ^{
    __block GreeScore* score = nil;
    __block GreeWriteCache* writeCacheMock = nil;
    
    beforeEach(^{
      score = [[GreeScore alloc] initWithLeaderboard:@"testLeaderboard" score:100];
      writeCacheMock = [[GreeWriteCache nullMock] retain];
      [mockedSdk stub:@selector(writeCache) andReturn:writeCacheMock];
    });
    
    afterEach(^{
      [score release];
      score = nil;
      [writeCacheMock release];
      writeCacheMock = nil;
    });
    
    it(@"should not crash without block", ^{
      [score submitWithBlock:nil];
    });

    it(@"should write to cache and commit if online", ^{
      [mockedSdk stub:@selector(reachability) andReturn:[GreeNetworkReachability nullMockWithStatus:GreeNetworkReachabilityConnectedViaWiFi]];
      [[writeCacheMock should] receive:@selector(writeObject:) withArguments:score, nil];
      [[writeCacheMock should] receive:@selector(commitAllObjectsOfClass:inCategory:) withArguments:theValue([score class]), [score writeCacheCategory], nil];
      [[writeCacheMock should] receive:@selector(observeWriteCacheOperation:forCompletionWithBlock:)];
      [score submitWithBlock:^{
      }];
    });

    it(@"should write to cache only if offline", ^{
      [mockedSdk stub:@selector(reachability) andReturn:[GreeNetworkReachability nullMockWithStatus:GreeNetworkReachabilityNotConnected]];
      [[writeCacheMock should] receive:@selector(writeObject:) withArguments:score, nil];
      [[writeCacheMock shouldNot] receive:@selector(commitAllObjectsOfClass:inCategory:)];
      [[writeCacheMock should] receive:@selector(observeWriteCacheOperation:forCompletionWithBlock:)];
      [score submitWithBlock:^{
      }];
    });
    
    it(@"should not submit to GameCenter without a valid mapping", ^{
      [[score should] receive:@selector(gameCenterScore) andReturn:nil];
      [score submitWithBlock:nil];
    });

    it(@"should submit to GameCenter with a valid mapping", ^{
      NSDictionary* leaderboardMap = [NSDictionary dictionaryWithObjectsAndKeys:@"gameCenterIdentifier", @"testLeaderboard", nil];
      GreeSettings* settings = [[GreeSettings alloc] init];
      [settings applySettingDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
        leaderboardMap, GreeSettingGameCenterLeaderboardMapping,
        nil]];
      [[GreePlatform sharedInstance] stub:@selector(settings) andReturn:settings];
      
      void(^responseBlock)(NSError*) = Block_copy(^(NSError* error) {
      });
      
      [score setGameCenterResponseBlock:responseBlock];

      GKScore* mock = [GKScore nullMock];
      [[mock should] receive:@selector(reportScoreWithCompletionHandler:) withArguments:responseBlock];
      [score stub:@selector(gameCenterScore) andReturn:mock];

      [score submitWithBlock:nil];
    });
    
  });
  
  it(@"should have a GameCenter object factory method", ^{
    NSDictionary* leaderboardMap = [NSDictionary dictionaryWithObjectsAndKeys:@"gameCenterIdentifier", @"testLeaderboard", nil];
    GreeSettings* settings = [[GreeSettings alloc] init];
    [settings applySettingDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
      leaderboardMap, GreeSettingGameCenterLeaderboardMapping,
      nil]];
    [[GreePlatform sharedInstance] stub:@selector(settings) andReturn:settings];
    
    GreeScore* score = [[[GreeScore alloc] initWithLeaderboard:@"testLeaderboard" score:123] autorelease];
    GKScore* gkScore = [score performSelector:@selector(gameCenterScore)];
    
    [[theValue(gkScore.value) should] equal:theValue(123)];
    [[gkScore.category should] equal:@"gameCenterIdentifier"];
  });

  it(@"should hold 20 scores for each leaderboard", ^{
    [[theValue([GreeScore writeCacheMaxCategorySize]) should] equal:theValue(20)]; 
  });
  
  it(@"should use leaderboard id as write cache category", ^{
    GreeScore* score = [[[GreeScore alloc] initWithLeaderboard:@"testLeaderboard" score:123] autorelease];
    [[[score writeCacheCategory] should] equal:@"testLeaderboard"];
  });
  
  context(@"when committing", ^{
    __block BOOL didFinish = NO;
    __block BOOL didSucceed = NO;
    __block GreeScore* score = nil;
    
    beforeEach(^{
      score = [[GreeScore alloc] initWithLeaderboard:@"testLeaderboard" score:100];
      didFinish = NO;
    });
    
    afterEach(^{
      [score release];
      score = nil;
    });

    it(@"should handle successful commit", ^{
      [GreeURLMockingProtocol addMock:[MockedURLResponse postResponseWithHttpStatus:200]];
      [score writeCacheCommitAndExecuteBlock:^(BOOL commitDidSucceed) {
        didFinish = YES;
        didSucceed = commitDidSucceed;
      }];

      [[expectFutureValue(theValue(didFinish)) shouldEventuallyBeforeTimingOutAfter(1.f)] beYes];
      [[expectFutureValue(theValue(didSucceed)) shouldEventuallyBeforeTimingOutAfter(1.f)] beYes];
    });

    it(@"should handle failed commit", ^{
      didSucceed = YES;
      [GreeURLMockingProtocol addMock:[MockedURLResponse postResponseWithHttpStatus:500]];
      [score writeCacheCommitAndExecuteBlock:^(BOOL commitDidSucceed) {
        didFinish = YES;
        didSucceed = commitDidSucceed;
      }];

      [[expectFutureValue(theValue(didFinish)) shouldEventuallyBeforeTimingOutAfter(1.f)] beYes];
      [[expectFutureValue(theValue(didSucceed)) shouldEventuallyBeforeTimingOutAfter(1.f)] beNo];
    });
    
  });
  
  context(@"when deleting scores", ^{
  
    it(@"should delete without error", ^{
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      [GreeURLMockingProtocol addMock:mock];

      __block id waitObject = nil;
      [GreeScore deleteMyScoreForLeaderboard:@"testLeaderboard" withBlock:^(NSError *error) {
        [error shouldBeNil];
        waitObject = @"DONE";
      }];
      [[expectFutureValue(waitObject) shouldEventually] equal:@"DONE"];
    });
    
    it(@"should clear writeCache when successfully deleting", ^{
      [GreeURLMockingProtocol addMock:[MockedURLResponse deleteResponseWithHttpStatus:200]];

      GreeWriteCache* writeCacheMock = [GreeWriteCache nullMock];
      [mockedSdk stub:@selector(writeCache) andReturn:writeCacheMock];
      [[writeCacheMock should] receive:@selector(deleteAllObjectsOfClass:inCategory:) withArguments:theValue([GreeScore class]), @"testLeaderboard"];
      
      __block id wait = nil;
      [GreeScore deleteMyScoreForLeaderboard:@"testLeaderboard" withBlock:^(NSError* error) {
        wait = @"STOP";
      }];
      [[expectFutureValue(wait) shouldEventually] beNonNil];
    });
    
    it(@"should clear writeCache when deleting fails", ^{
      [GreeURLMockingProtocol addMock:[MockedURLResponse deleteResponseWithHttpStatus:500]];

      GreeWriteCache* writeCacheMock = [GreeWriteCache nullMock];
      [mockedSdk stub:@selector(writeCache) andReturn:writeCacheMock];
      [[writeCacheMock should] receive:@selector(deleteAllObjectsOfClass:inCategory:) withArguments:theValue([GreeScore class]), @"testLeaderboard"];
      
      __block id wait = nil;
      [GreeScore deleteMyScoreForLeaderboard:@"testLeaderboard" withBlock:^(NSError* error) {
        wait = @"STOP";
      }];
      [[expectFutureValue(wait) shouldEventually] beNonNil];
    });

    it(@"should return errors", ^{
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      mock.error = [NSError errorWithDomain:@"fake" code:0 userInfo:nil];
      [GreeURLMockingProtocol addMock:mock];
      
      __block id waitObject = nil;
      [GreeScore deleteMyScoreForLeaderboard:@"testLeaderboard" withBlock:^(NSError *error) {
        [error shouldNotBeNil];
        waitObject = @"DONE";
      }];
      [[expectFutureValue(waitObject) shouldEventually] equal:@"DONE"];
    });
    
    it(@"should handle 401 reauthorization", ^{
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      mock.statusCode = 401;
      [GreeURLMockingProtocol addMock:mock];
      
      GreeAuthorization* mockAuth = [[GreeAuthorization alloc] init];
      [GreeAuthorization stub:@selector(sharedInstance) andReturn:mockAuth];
      id authSwizzle = [GreeAuthorization mockReauthorizeToSucceed];
      
      __block id waitObject = nil;
      [GreeScore deleteMyScoreForLeaderboard:@"testLeaderboard" withBlock:^(NSError *error) {
        [error shouldNotBeNil];
        waitObject = @"DONE";
      }];
      [[expectFutureValue(waitObject) shouldEventually] equal:@"DONE"];
      [GreeTestHelpers restoreExchangedSelectors:&authSwizzle];
      [mockAuth release];
    });

  });
});

SPEC_END
