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
#import "GreeEnumerator+Internal.h"
#import "GreePlatform.h"
#import "GreeHTTPClient.h"
#import "GreeURLMockingProtocol.h"
#import "GreeError.h"
#import "GreeTestHelpers.h"
#import "GreeUser.h"

@interface TestEnumerator :GreeEnumeratorBase
@end

@implementation TestEnumerator
- (NSString*)httpRequestPath
{
  return [NSString stringWithFormat:@"testpath/%@", self.guid];
}

- (NSArray*)convertData:(NSArray*)input
{
  return input;
}
@end

@interface TestEnumeratorWithParam : GreeEnumeratorBase
@end

@implementation TestEnumeratorWithParam
- (NSString*)httpRequestPath
{
  return @"testpath2";
}

- (NSArray*)convertData:(NSArray *)input
{
  return input;
}

- (void)updateParams:(NSMutableDictionary *)params
{
  [params setObject:@"HACKEDIN" forKey:@"HACKKEY"];
}
@end


NSString* fakeDataString = @"[ \"a\", \"b\", \"c\", \"d\", \"e\" ]";
NSString* fakeDataStringShort = @"[ \"a\", \"b\" ]";
NSString* fakeDataStringEmpty = @"[]";

NSData* buildData(NSString* content, BOOL hasNext, int totalResults, int pageSize);

NSData* buildData(NSString* content, BOOL hasNext, int totalResults, int pageSize)
{
  NSString* annotatedString = [NSString stringWithFormat:@"{ \"entry\":%@, \"hasNext\":\"%d\",\"totalResults\":\"%d\", \"itemsPerPage\":%d}", content, hasNext, totalResults, pageSize];
  return [annotatedString dataUsingEncoding:NSUTF8StringEncoding];
}

NSData* buildDataWithoutHasNext(NSString* content, int totalResults, int pageSize);

NSData* buildDataWithoutHasNext(NSString* content, int totalResults, int pageSize)
{
  NSString* annotatedString = [NSString stringWithFormat:@"{ \"entry\":%@,\"totalResults\":\"%d\", \"itemsPerPage\":%d}", content, totalResults, pageSize];
  return [annotatedString dataUsingEncoding:NSUTF8StringEncoding];
}


#pragma mark - GreeEnumeratorTests

SPEC_BEGIN(GreeEnumeratorTests)

describe(@"GreeEnumerator", ^{
  NSData* fakeData = buildData(fakeDataString, NO, 5, 5);
  NSData* fakeDataEmpty = buildData(fakeDataStringEmpty, NO, 5, 5);
  __block GreeAuthorization *authMock;
 
  beforeEach(^{
    GreePlatform* mockedSdk = [GreePlatform nullMockAsSharedInstance];
    [mockedSdk stub:@selector(httpClient) andReturn:[GreeHTTPClient nullMock]];
    [mockedSdk stub:@selector(localUser) andReturn:[GreeUser nullMock]];
    [GreeURLMockingProtocol register];
    authMock = [[GreeAuthorization alloc] init];
    [authMock stub:@selector(isAuthorized) andReturn:theValue(YES)];
    [GreeAuthorization stub:@selector(sharedInstance) andReturn:authMock];
  });
  
  afterEach(^{
    [GreeURLMockingProtocol unregister];
    [authMock release];
  });
  
  context(@"when not subclassed", ^{
    __block GreeEnumeratorBase* badEnumerator = nil;
    
    beforeEach(^{
      badEnumerator = [[GreeEnumeratorBase alloc] initWithStartIndex:0 pageSize:3];
    });
    afterEach(^{
      [badEnumerator release];
    });

    it(@"should raise when converting data", ^{
      [[badEnumerator should] raiseWhenSent:@selector(convertData:)];
    });
    
    it(@"should raise when trying to load next page", ^{
      [[badEnumerator should] raiseWhenSent:@selector(loadNext:)];
    });
    
    it(@"should raise when trying to load previous page", ^{
      [[badEnumerator should] raiseWhenSent:@selector(loadPrevious:)];
    });
  });
          
  context(@"when subclassed", ^{
    it(@"should initialize properly", ^{
      TestEnumerator* enumerator = [[TestEnumerator alloc] initWithStartIndex:5 pageSize:12];
      [[theValue(enumerator.startIndex) should] equal:theValue(5)];
      [[theValue(enumerator.pageSize) should] equal:theValue(12)];
      NSString* expectedDesc = [NSString stringWithFormat:@"<TestEnumerator:%p startIndex:5 pageSize:12>", enumerator];
      [[[enumerator description] should] equal:expectedDesc];
    });
    
    
    context(@"when loading without setting pageSize", ^{
      __block TestEnumerator* enumerator;
      __block id response;
      beforeEach(^{
        response = nil;
        enumerator = [[TestEnumerator alloc] initWithStartIndex:1 pageSize:0];
      });
      afterEach(^{
        [response release];
        [enumerator release];
      });
      
      it(@"should set page size to loaded size", ^{
        MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
        mock.data = fakeData;
        [GreeURLMockingProtocol addMock:mock];
        
        [enumerator loadNext:^(NSArray *items, NSError *error) {
          response = [items retain];
        }];
        [[expectFutureValue(response) shouldEventually] beNonNil];
        [[theValue(enumerator.pageSize) should] equal:theValue(5)];
      });
    });
    
    context(@"when loading", ^{
      __block TestEnumerator* enumerator;
      __block id response;
      beforeEach(^{
        response = nil;
        enumerator = [[TestEnumerator alloc] initWithStartIndex:1 pageSize:5];
      });
      afterEach(^{
        [response release];
        [enumerator release];
      });
      it(@"should find data", ^{
        MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
        mock.data = fakeData;
        [GreeURLMockingProtocol addMock:mock];
        
        [enumerator loadNext:^(NSArray *items, NSError *error) {
          response = [items retain];
        }];
        [[expectFutureValue(response) shouldEventually] haveCountOf:5];
      });
      
      it(@"should update start index when full response", ^{
        MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
        mock.data = fakeData;
        [GreeURLMockingProtocol addMock:mock];
        
        [enumerator loadNext:^(NSArray *items, NSError *error) {
          response = [items retain];
        }];
        [[expectFutureValue(response) shouldEventually] beNonNil];
        [[theValue(enumerator.startIndex) should] equal:theValue(6)];
      });
      
      it(@"should update start index when partial response", ^{
        MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
        NSData* fakeDataShort = buildData(fakeDataStringShort, NO, 2, 5);
        mock.data = fakeDataShort;
        [GreeURLMockingProtocol addMock:mock];
        
        [enumerator loadNext:^(NSArray *items, NSError *error) {
          response = [items retain];
        }];
        [[expectFutureValue(response) shouldEventually] beNonNil];
        [[theValue(enumerator.startIndex) should] equal:theValue(6)];
      });
      
      it(@"should not update start index if error", ^{
        MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
        mock.error = [NSError errorWithDomain:@"mock" code:0 userInfo:nil];
        mock.data = fakeData;
        [GreeURLMockingProtocol addMock:mock];
        
        [enumerator loadNext:^(NSArray *items, NSError *error) {
          response = [error retain];
        }];
        [[expectFutureValue(response) shouldEventually] beNonNil];
        [[theValue(enumerator.startIndex) should] equal:theValue(1)];
      });

      it(@"should page backwards", ^{  
        NSData* fakeData = buildDataWithoutHasNext(fakeDataString, 7, 5);
        NSData* fakeDataShort = buildDataWithoutHasNext(fakeDataStringShort, 7, 5);

        MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
        mock.data = fakeData;
        MockedURLResponse* mockShort = [[MockedURLResponse new] autorelease];
        mockShort.data = fakeDataShort;
        [GreeURLMockingProtocol addMock:mock];
        [GreeURLMockingProtocol addMock:mockShort];
        [GreeURLMockingProtocol addMock:mock];
        
        [enumerator loadNext:^(NSArray *items, NSError *error) {
          [enumerator loadNext:^(NSArray *items, NSError *error) {
            [enumerator loadPrevious:^(NSArray *items, NSError *error) {
              response = @"signal";
            }];
          }];
        }];
        [[expectFutureValue(response) shouldEventually] beNonNil];
        [[theValue(enumerator.startIndex) should] equal:theValue(6)];  //that is, it loaded 5, backed up to 1 and loaded 5 again
      });
      
      it(@"should page backwards without overrun", ^{
        MockedURLResponse* mockShort = [[MockedURLResponse new] autorelease];
        NSData* fakeShort = buildDataWithoutHasNext(fakeDataStringShort, 2, 5);
        mockShort.data = fakeShort;
        [GreeURLMockingProtocol addMock:mockShort];
        [GreeURLMockingProtocol addMock:mockShort];
        
        [enumerator loadNext:^(NSArray *items, NSError *error) {
          [enumerator loadPrevious:^(NSArray *items, NSError *error) {
            response = @"signal";
          }];
        }];
        [[expectFutureValue(response) shouldEventually] beNonNil];
        [[theValue(enumerator.startIndex) should] equal:theValue(6)];  //that is, it loaded 2, backed up to 1 and loaded 2
      });
      
      it(@"should handle unexpected result type", ^{
        __block id returnedObject = nil;
        MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
        mock.data = [NSData dataWithBytes:@"NOTJSON" length:7];
        [GreeURLMockingProtocol addMock:mock];
        
        [enumerator loadNext:^(NSArray *items, NSError *error) {
          [[error.domain should] equal:GreeErrorDomain];
          [[theValue(error.code) should] equal:theValue(GreeErrorCodeBadDataFromServer)]; 
          returnedObject = items;
          response = @"signal";
        }];
        [[expectFutureValue(response) shouldEventually] beNonNil];
        [returnedObject shouldBeNil];
      });
      
      it(@"should handle unexpected non-array result type", ^{
        __block id returnedObject = nil;
        NSString* badDataString = @"{\"entry\":\"a string\"}";
        MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
        mock.data = [badDataString dataUsingEncoding:NSUTF8StringEncoding];
        [GreeURLMockingProtocol addMock:mock];
        
        [enumerator loadNext:^(NSArray *items, NSError *error) {
          [[error.domain should] equal:GreeErrorDomain];
          [[theValue(error.code) should] equal:theValue(GreeErrorCodeBadDataFromServer)]; 
          returnedObject = items;
          response = @"signal";
        }];
        [[expectFutureValue(response) shouldEventually] beNonNil];
        [returnedObject shouldBeNil];
      });
      
      
      it(@"should handle missing block in loadNext", ^{
        [enumerator loadNext:nil];
      });
      
      it(@"should handle missing block in loadPrevious", ^{
        [enumerator loadPrevious:nil];
      });
      
      it(@"should page properly regardless of loaded data size", ^{
        __block id returnedObject = nil;
        MockedURLResponse* mockShort = [[MockedURLResponse new] autorelease];
        NSData* fakeDataShort = buildDataWithoutHasNext(fakeDataStringShort, YES, 5);
        mockShort.data = fakeDataShort;
        [GreeURLMockingProtocol addMock:mockShort];
        [GreeURLMockingProtocol addMock:mockShort];
        [GreeURLMockingProtocol addMock:mockShort];

        [enumerator loadNext:^(NSArray *items, NSError *error) {
          [[theValue(enumerator.startIndex) should] equal:theValue(6)];
          [enumerator loadNext:^(NSArray *items, NSError *error) {
            [[theValue(enumerator.startIndex) should] equal:theValue(11)];
            [enumerator loadPrevious:^(NSArray *items, NSError *error) {
              [[theValue(enumerator.startIndex) should] equal:theValue(6)];
              returnedObject = @"DONE";
            }];
          }];
        }];
        [[expectFutureValue(returnedObject) shouldEventually] beNonNil];
      });
      
      it(@"should return NO for canLoadPrevious when we are already on the first page", ^{
        MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
        mock.data = fakeData;
        [GreeURLMockingProtocol addMock:mock];
        
        __block id canLoadPrevious = nil;
        [enumerator loadNext:^(NSArray *items, NSError *error) {
          canLoadPrevious = [NSNumber numberWithBool:[enumerator canLoadPrevious]];
        }];
        
        [[expectFutureValue(canLoadPrevious) shouldEventually] beNonNil];
        NSLog(@"%d, %d", enumerator.startIndex, enumerator.enumeratorStartIndex);
        [[theValue([canLoadPrevious boolValue]) should] beFalse];
        
      });
      
      it(@"should return YES for canLoadPrevious when we are on the second page", ^{
        MockedURLResponse* mock1 = [[MockedURLResponse new] autorelease];
        NSData* fakeDataPage1 = buildDataWithoutHasNext(fakeDataString, 7, 5);
        mock1.data = fakeDataPage1;
        [GreeURLMockingProtocol addMock:mock1];
        
        MockedURLResponse* mock2 = [[MockedURLResponse new] autorelease];
        NSData* fakeDataPage2 = buildDataWithoutHasNext(fakeDataString, 2, 5);
        mock2.data = fakeDataPage2;
        [GreeURLMockingProtocol addMock:mock2];
        
        __block id canLoadPrevious = nil;
        [enumerator loadNext:^(NSArray *items, NSError *error) {
          [enumerator loadNext:^(NSArray *items, NSError *error) {
            canLoadPrevious = [NSNumber numberWithBool:[enumerator canLoadPrevious]];
          }];
        }];
        [[expectFutureValue(canLoadPrevious) shouldEventually] beNonNil];
        [[theValue([canLoadPrevious boolValue]) should] beTrue];
      });
      
      it(@"should return NO for canLoadNext when we are on the last page with partial data", ^{
        NSData* fakeData = buildData(fakeDataString, YES, 7, 5);
        NSData* fakeDataShort = buildData(fakeDataStringShort, NO, 7, 5);
        
        MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
        mock.data = fakeData;
        MockedURLResponse* mockShort = [[MockedURLResponse new] autorelease];
        mockShort.data = fakeDataShort;

        [GreeURLMockingProtocol addMock:mock];
        [GreeURLMockingProtocol addMock:mockShort];
        
        __block id canLoadNext = nil;
        [enumerator loadNext:^(NSArray *items, NSError *error) {
          [enumerator loadNext:^(NSArray *items, NSError *error) {
            canLoadNext = [NSNumber numberWithBool:[enumerator canLoadNext]];
          }];
        }];
        [[expectFutureValue(canLoadNext) shouldEventually] beNonNil];
        [[theValue([canLoadNext boolValue]) should] beFalse];
      });
      
      it(@"should return NO for canLoadNext when we are already on an empty page", ^{
        MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
        mock.data = fakeData;
        MockedURLResponse* mockEmpty = [[MockedURLResponse new] autorelease];
        mockEmpty.data = fakeDataEmpty;
        [GreeURLMockingProtocol addMock:mock];
        [GreeURLMockingProtocol addMock:mockEmpty];
        
        __block id canLoadNext = nil;
        [enumerator loadNext:^(NSArray *items, NSError *error) {
          [enumerator loadNext:^(NSArray *items, NSError *error) {
            canLoadNext = [NSNumber numberWithBool:[enumerator canLoadNext]];
          }];
        }];
        [[expectFutureValue(canLoadNext) shouldEventually] beNonNil];
        [[theValue([canLoadNext boolValue]) should] beFalse];
      });
      
      context(@"when handling 401", ^{
        //most of these tests are bogus these days.  The reauthorization and resend was disabled
        //If you are not logged in, the enumerator short-circuits to GreeError code 102.
        __block GreeAuthorization *authMock;
        beforeEach(^{
          authMock = [[GreeAuthorization alloc] init];
          [GreeAuthorization stub:@selector(sharedInstance) andReturn:authMock];
        });
        afterEach(^{
          [authMock release];
        });
        it(@"should retry", ^{
          id authSwizzle = [GreeAuthorization mockReauthorizeToSucceed];
          __block id finished = nil;
          [enumerator loadNext:^(NSArray *items, NSError *error) {
            [error shouldNotBeNil];
            finished = @"DONE";
          }];
          [[expectFutureValue(finished) shouldEventually] beNonNil];
          [GreeTestHelpers restoreExchangedSelectors:&authSwizzle];
        });
      });
      
      context(@"when no user is defined", ^{
        beforeEach(^{
          [[GreePlatform sharedInstance] stub:@selector(localUser)andReturn:nil];  //that is, set up so there is no user
        });
        it(@"should return no user error", ^{
          __block id done = nil;
          [enumerator loadNext:^(NSArray *items, NSError *error) {
            [[theValue(error.code) should] equal:theValue(GreeErrorCodeUserRequired)];
            done = @"DONE";
          }];
          [done shouldBeNil]; //make sure the block doesn't fire too soon
          [[expectFutureValue(done) shouldEventually] beNonNil];
        });
      });
      
      context(@"when authorization has not be done", ^{
        beforeEach(^{
          [[GreeAuthorization sharedInstance] stub:@selector(isAuthorized)andReturn:theValue(NO)];
        });
        it(@"should return not authorization error", ^{
          __block id done = nil;
          [enumerator loadNext:^(NSArray *items, NSError *error) {
            [[theValue(error.code) should] equal:theValue(GreeErrorCodeNotAuthorized)];
            done = @"DONE";
          }];
          [done shouldBeNil]; //make sure the block doesn't fire too soon
          [[expectFutureValue(done) shouldEventually] beNonNil];
        });
      });
      
    });    
  });
  
  context(@"when using subclass with parameter modification", ^{
    it(@"should add a param", ^{
      __block id waitObject;
      TestEnumeratorWithParam* enumerator = [[[TestEnumeratorWithParam alloc] initWithStartIndex:1 pageSize:0] autorelease];
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      mock.data = fakeData;
      mock.requestBlock = ^(NSURLRequest* request) {
        NSString* urlString = [request.URL absoluteString];
        NSRange range = [urlString rangeOfString:@"HACKKEY=HACKEDIN"];
        [[theValue(range.location) shouldNot] equal:theValue(NSNotFound)];
        return NO;
      };
      [GreeURLMockingProtocol addMock:mock];
      [enumerator loadNext:^(NSArray *items, NSError *error) {
        waitObject = @"fin";
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    });
  });
  
  context(@"when using advanced methods", ^{
    it(@"should allow setting startIndex", ^{
      TestEnumerator* enumerator = [[[TestEnumerator alloc] initWithStartIndex:1 pageSize:0] autorelease];
      [enumerator setStartIndex:52];
      [[theValue(enumerator.startIndex) should] equal:theValue(52)];
    });
    
    it(@"should allow setting pageSize", ^{
      TestEnumerator* enumerator = [[[TestEnumerator alloc] initWithStartIndex:1 pageSize:0] autorelease];
      [enumerator setPageSize:12];
      [[theValue(enumerator.pageSize) should] equal:theValue(12)];
    });
    it(@"should default guid to me", ^{
      TestEnumerator* enumerator = [[[TestEnumerator alloc] initWithStartIndex:1 pageSize:0] autorelease];
      [[enumerator.guid should] equal:@"me"];
    });
    it(@"should allow setting guid", ^{
      TestEnumerator* enumerator = [[[TestEnumerator alloc] initWithStartIndex:1 pageSize:0] autorelease];
      [enumerator setGuid:@"hello"];
      [[enumerator.guid should] equal:@"hello"];
    });
    it(@"should reset guid when nil set", ^{
      TestEnumerator* enumerator = [[[TestEnumerator alloc] initWithStartIndex:1 pageSize:0] autorelease];
      [enumerator setGuid:@"hello"];
      [enumerator setGuid:nil];
      [[enumerator.guid should] equal:@"me"];
    });
    it(@"should use these values", ^{
      __block id waitObject;
      TestEnumerator* enumerator = [[[TestEnumerator alloc] initWithStartIndex:1 pageSize:0] autorelease];
      [enumerator setStartIndex:52];
      [enumerator setPageSize:12];
      [enumerator setGuid:@"hello"];
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      mock.data = fakeData;
      mock.requestBlock = ^(NSURLRequest* request) {
        NSString* urlString = [request.URL absoluteString];
        NSRange range = [urlString rangeOfString:@"testpath/hello"];
        [[theValue(range.location) shouldNot] equal:theValue(NSNotFound)];
        range = [urlString rangeOfString:@"count=12"];
        [[theValue(range.location) shouldNot] equal:theValue(NSNotFound)];
        range = [urlString rangeOfString:@"startIndex=52"];
        return YES;
      };
      [GreeURLMockingProtocol addMock:mock];
      [enumerator loadNext:^(NSArray *items, NSError *error) {
        waitObject = @"fin";
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    });
  });
});

SPEC_END
