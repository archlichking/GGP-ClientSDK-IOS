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
#import "GreeLeaderboard.h"

#import "GreePlatform.h"
#import "GreeHTTPClient.h"
#import "GreeURLMockingProtocol.h"
#import "AFNetworking.h"
#import "GreeError.h"
#import "GreeSerializer.h"
#import "JSONKit.h"
#import "GreeTestHelpers.h"
#import "GreeUser.h"

SPEC_BEGIN(GreeLeaderboardTests)

describe(@"Gree leaderboards", ^{
  __block NSData* shortList = nil;
  __block NSData* longList = nil;
  __block GreeAuthorization *authMock;
  
  beforeAll(^{
    NSMutableDictionary* baseLeaderboard = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            @"mockid", @"id",
                                            @"mockname", @"name",
                                            [NSNumber numberWithInt:1], @"format",
                                            @"mocksuffix", @"format_suffix",
                                            [NSNumber numberWithInt:1], @"format_decimal",
                                            @"mockurl", @"thumbnail_url",
                                            [NSNumber numberWithInt:1], @"sort",
                                            [NSNumber numberWithBool:YES], @"allow_worse_score",
                                            [NSNumber numberWithBool:YES], @"secret",
                                            [NSNumber numberWithBool:YES], @"status",
                                            nil];
    NSMutableArray* dataArray = [NSMutableArray array];
    [dataArray addObject:[[baseLeaderboard copy] autorelease]];
    [baseLeaderboard setObject:@"id2" forKey:@"id"];
    [dataArray addObject:[[baseLeaderboard copy] autorelease]];
    [baseLeaderboard setObject:@"id3" forKey:@"id"];
    [dataArray addObject:[[baseLeaderboard copy] autorelease]];
    
    shortList = [[[NSDictionary dictionaryWithObject:dataArray forKey:@"entry"] greeJSONData] retain];
    
    [baseLeaderboard setObject:@"id4" forKey:@"id"];
    [dataArray addObject:[[baseLeaderboard copy] autorelease]];
    [baseLeaderboard setObject:@"id5" forKey:@"id"];
    [dataArray addObject:[[baseLeaderboard copy] autorelease]];
    
    longList = [[[NSDictionary dictionaryWithObject:dataArray forKey:@"entry"] greeJSONData] retain];
  });

  afterAll(^{
    [shortList release];
    [longList release];
  });

  beforeEach(^{
    GreePlatform* sdk = [GreePlatform nullMockAsSharedInstance];
    [sdk stub:@selector(httpClient) andReturn:[GreeHTTPClient nullMock]];
    [sdk stub:@selector(localUser) andReturn:[GreeUser nullMock]];
    [GreeURLMockingProtocol register];
    authMock = [[GreeAuthorization alloc] init];
    [authMock stub:@selector(isAuthorized) andReturn:theValue(YES)];
    [GreeAuthorization stub:@selector(sharedInstance) andReturn:authMock];
  });

  afterEach(^{
    [GreeURLMockingProtocol unregister];
    [authMock release];
  });
  
  it(@"should deserialize", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"mockid", @"id",
                                @"mockname", @"name",
                                [NSNumber numberWithInt:1], @"format",
                                @"mocksuffix", @"format_suffix",
                                [NSNumber numberWithInt:1], @"format_decimal",
                                @"mockurl", @"thumbnail_url",
                                [NSNumber numberWithInt:1], @"sort",
                                [NSNumber numberWithBool:YES], @"allow_worse_score",
                                [NSNumber numberWithBool:YES], @"secret",
                                [NSNumber numberWithBool:YES], @"status",
                                nil];
    GreeSerializer* serializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeLeaderboard* board = [[[GreeLeaderboard alloc] initWithGreeSerializer:serializer] autorelease];
    [[board.identifier should] equal:@"mockid"];
    [[board.name should] equal:@"mockname"];
    [[[board performSelector:@selector(iconUrl)] should] equal:[NSURL URLWithString:@"mockurl"]];
    [[theValue(board.format) should] equal:theValue(1)];
    [[board.formatSuffix should] equal:@"mocksuffix"];
    [[theValue(board.formatDecimal) should] equal:theValue(1)];
    [[theValue(board.sortOrder) should] equal:theValue(1)];
    [[theValue(board.allowWorseScore) should] beTrue];
    [[theValue(board.isSecret) should] beTrue];
    [[[board valueForKey:@"status"] should] equal:[NSNumber numberWithBool:YES]];
  });
  
  it(@"should show description", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"mockid", @"id",
                                @"mockname", @"name",
                                [NSNumber numberWithInt:2], @"format",
                                @"mocksuffix", @"format_suffix",
                                [NSNumber numberWithInt:1], @"format_decimal",
                                @"mockurl", @"thumbnail_url",
                                [NSNumber numberWithInt:1], @"sort",
                                [NSNumber numberWithBool:YES], @"allow_worse_score",
                                [NSNumber numberWithBool:YES], @"secret",
                                [NSNumber numberWithBool:YES], @"status",
                                nil];
    GreeSerializer* serializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeLeaderboard* board = [[[GreeLeaderboard alloc] initWithGreeSerializer:serializer] autorelease];
    NSString* checkString = [NSString stringWithFormat:@"<GreeLeaderboard:%p, identifier:mockid, name:mockname, format:2[Time], formatSuffix:mocksuffix, formatDecimal:1, iconUrl:mockurl, sortOrder:1[Ascending], allowWorseScore:YES, isSecret:YES>", board];
    [[[board description] should] equal:checkString];
  });  
  
  it(@"should serialize", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"mockid", @"id",
                                @"mockname", @"name",
                                [NSNumber numberWithInt:1], @"format",
                                @"mocksuffix", @"format_suffix",
                                [NSNumber numberWithInt:1], @"format_decimal",
                                @"mockurl", @"thumbnail_url",
                                [NSNumber numberWithInt:1], @"sort",
                                [NSNumber numberWithBool:YES], @"allow_worse_score",
                                [NSNumber numberWithBool:YES], @"secret",
                                [NSNumber numberWithBool:YES], @"status",
                                nil];
    GreeSerializer* deserializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeLeaderboard* board = [[[GreeLeaderboard alloc] initWithGreeSerializer:deserializer] autorelease];
    GreeSerializer* serializer = [GreeSerializer serializer];
    [board serializeWithGreeSerializer:serializer];
    [[serializer.rootDictionary should] equal:serialized];
  });
  
  context(@"when downloading leaderboards", ^{
    it(@"should download", ^{
      __block id waitObject = nil;
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      mock.data = longList;
      [GreeURLMockingProtocol addMock:mock];
      
      [GreeLeaderboard loadLeaderboardsWithBlock:^(NSArray *leaderboards, NSError *error) {
        waitObject = [leaderboards retain];
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      GreeLeaderboard* board = [waitObject objectAtIndex:0];
      [[board.identifier should] equal:@"mockid"];
      [[board.name should] equal:@"mockname"];
      [[[board performSelector:@selector(iconUrl)] should] equal:[NSURL URLWithString:@"mockurl"]];
      [[theValue(board.sortOrder) should] equal:theValue(1)];
      [[theValue(board.isSecret) should] beTrue];
      [waitObject release];
    });
    
    it(@"should handle failure", ^{
      __block id waitObject = nil;
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      mock.statusCode = 500;  //server flaked
      [GreeURLMockingProtocol addMock:mock];
      
      [GreeLeaderboard loadLeaderboardsWithBlock:^(NSArray *leaderboards, NSError *error) {
        waitObject = [error copy];
      }];
      [[expectFutureValue(waitObject) shouldEventually] beKindOfClass:[NSError class]];
      [waitObject release];
    });
    
    it(@"should handle missing block", ^{
      [GreeLeaderboard loadLeaderboardsWithBlock:nil];
      //not dying is a sufficient test
    });
  });
  
  context(@"when downloading icon", ^{
    __block GreeLeaderboard* board;
    
    beforeEach(^{
      NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"mockid", @"id",
                                  @"mockname", @"name",
                                  [NSNumber numberWithInt:1], @"format",
                                  @"mocksuffix", @"format_suffix",
                                  [NSNumber numberWithInt:1], @"format_decimal",
                                  [[GreeURLMockingProtocol httpClientPrefix] stringByAppendingString:@"/icon_url"], @"thumbnail_url",
                                  [NSNumber numberWithInt:1], @"sort",
                                  [NSNumber numberWithBool:YES], @"allow_worse_score",
                                  [NSNumber numberWithBool:YES], @"secret",
                                  [NSNumber numberWithBool:YES], @"status",
                                  nil];
      GreeSerializer* serializer = [GreeSerializer deserializerWithDictionary:serialized];
      board = [[GreeLeaderboard alloc] initWithGreeSerializer:serializer];
    });
    
    afterEach(^{
      [board release];
    });
    
    it(@"should download icon", ^{
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      UIImage* blankImage = [[UIImage alloc] init];
      mock.data = UIImagePNGRepresentation(blankImage);
      [GreeURLMockingProtocol addMock:mock];
      
      __block id waitObject = nil;
      [board loadIconWithBlock:^(UIImage *image, NSError *error) {
        waitObject = [image retain];
      }];
      [[expectFutureValue(waitObject) shouldEventually] beKindOfClass:[UIImage class]];
      [waitObject release];
    });
    
    it(@"should handle cancellation", ^{
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      UIImage* blankImage = [[UIImage alloc] init];
      mock.data = UIImagePNGRepresentation(blankImage);
      mock.delay = .1f;
      [GreeURLMockingProtocol addMock:mock];
      
      __block id waitObject = nil;
      [board loadIconWithBlock:^(UIImage* image, NSError* error) {
        waitObject = [image retain];
      }];
      [board cancelIconLoad];

      [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:mock.delay + .01f]];
      [waitObject shouldBeNil];
    });

    it(@"should handle superfluous cancellation", ^{
      [board cancelIconLoad];
    });

    it(@"should handle failure", ^{
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      mock.statusCode = 500;  //server flaked
      [GreeURLMockingProtocol addMock:mock];
      
      __block id waitObject = nil;
      [board loadIconWithBlock:^(UIImage *image, NSError *error) {
        waitObject = [error copy];
      }];
      [[expectFutureValue(waitObject) shouldEventually] beKindOfClass:[NSError class]];
      [waitObject release];
    });
    
    it(@"should handle missing block", ^{
      [board loadIconWithBlock:nil];
    });
    
  });
  
  context(@"when using enumerator", ^{
    __block id enumerator = nil;
    beforeEach(^{
      enumerator = [[GreeLeaderboard loadLeaderboardsWithBlock:nil] retain];
    });
    afterEach(^{
      [enumerator release];
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
      [[[waitObject objectAtIndex:0] should] beKindOfClass:[GreeLeaderboard class]];
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
      [[[waitObject objectAtIndex:0] should] beKindOfClass:[GreeLeaderboard class]];
      [waitObject release];
    });
    
    it(@"should go back a page with partial data", ^{
      __block id waitObject = nil;
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      mock.data = longList;
      MockedURLResponse* shortmock = [[MockedURLResponse new] autorelease];
      shortmock.data = shortList;
      
      [GreeURLMockingProtocol addMock:mock];
      [GreeURLMockingProtocol addMock:shortmock];
      [GreeURLMockingProtocol addMock:mock];
      
      [enumerator loadNext:^(NSArray *items, NSError *error) {
        [enumerator loadNext:^(NSArray *items, NSError *error) {
          [enumerator loadPrevious:^(NSArray *items, NSError *error) {
            waitObject = [items retain];
          }];
        }];
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      [[theValue([waitObject count]) should] equal:theValue(5)];
      [[[waitObject objectAtIndex:0] should] beKindOfClass:[GreeLeaderboard class]];
      [waitObject release];
    });
  });
  
});
SPEC_END
