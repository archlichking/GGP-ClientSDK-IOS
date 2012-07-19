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
#import "GreeFriendCodes.h"
#import "GreeURLMockingProtocol.h"
#import "GreeTestHelpers.h"
#import "GreeUser.h"
#import "GreeAuthorization.h"
#import "JSONKit.h"
#import "GreeError.h"
#import "GreeMatchers.h"
extern NSString* GreeAFNetworkingErrorDomain;

#pragma mark - GreeFriendCodeTests

SPEC_BEGIN(GreeFriendCodeTests)
describe(@"GreeFriendCode", ^{
  registerMatchers(@"Gree");
  __block GreePlatform* mockedSdk;
  __block GreeAuthorization *authMock;
  beforeEach(^{
    mockedSdk = [[GreePlatform nullMockAsSharedInstance] retain];
    [mockedSdk stub:@selector(httpClient) andReturn:[GreeHTTPClient nullMock]];
    [mockedSdk stub:@selector(localUser) andReturn:[GreeUser nullMock]];
    [GreeURLMockingProtocol register];
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
  context(@"when creating code", ^{
    it(@"should receive codes", ^{
      __block id waitObject= nil;
      MockedURLResponse* mock = [MockedURLResponse postResponseWithHttpStatus:200];
      NSDictionary* codeObject = [NSDictionary dictionaryWithObject:@"fakeCode" forKey:@"code"];
      mock.data = [NSJSONSerialization dataWithJSONObject:[NSDictionary dictionaryWithObject:codeObject forKey:@"entry"] options:0 error:nil];
      mock.requestBlock = ^(NSURLRequest* req) {
        [[req.URL.relativeString should] containString:@"api/rest/friendcode/@me"];
        [[req.HTTPMethod should] equal:@"POST"];
        NSDictionary* body = [NSJSONSerialization JSONObjectWithData:req.HTTPBody options:0x0 error:nil];
        [[body should] beKindOfClass:[NSDictionary class]];
        [[body shouldNot] haveValueForKey:@"expire_time"];
        return YES;
      };
      
      [GreeURLMockingProtocol addMock:mock];
      
      [GreeFriendCodes requestCodeWithBlock:^(NSString *code, NSError *error) {
        [[code should] equal:@"fakeCode"];
        waitObject = @"DONE";
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    });
    
    it(@"should allow expiration time entry", ^{
      __block id waitObject= nil;
      MockedURLResponse* mock = [MockedURLResponse postResponseWithHttpStatus:200];
      mock.requestBlock = ^(NSURLRequest* req) {
        [[req.HTTPMethod should] equal:@"POST"];
        NSData* requestData = req.HTTPBody;
        NSDictionary* body = [NSJSONSerialization JSONObjectWithData:requestData options:0x0 error:nil];
        NSString* expireTimeString = [body objectForKey:@"expire_time"];
        [[expireTimeString should] matchRegExp:@"2013-01-01T00:00:00[-+]0[89]00"];
        return YES;
      };
      
      [GreeURLMockingProtocol addMock:mock];      
      //need to get expire time...
      NSDateFormatter* basicFormat = [[NSDateFormatter alloc] init];
      [basicFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
      NSDate* testDate = [[basicFormat dateFromString:@"2013-01-01 00:00"] retain];
      [basicFormat release];
      
      [GreeFriendCodes requestCodeWithExpireTime:testDate block:^(NSString *code, NSError *error) {
        waitObject = @"DONE";
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    });
    
    it(@"should return errors", ^{
      __block id waitObject= nil;
      MockedURLResponse* mock = [MockedURLResponse postResponseWithHttpStatus:200];
      mock.error = [NSError errorWithDomain:GreeAFNetworkingErrorDomain code:567 userInfo:nil];
      [GreeURLMockingProtocol addMock:mock];      
      
      [GreeFriendCodes requestCodeWithExpireTime:nil block:^(NSString *code, NSError *error) {
        [[error.domain should] equal:GreeErrorDomain];
        waitObject = @"DONE";
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    });
    
    it(@"should return registry errors", ^{
      __block id waitObject= nil;
      MockedURLResponse* mock = [MockedURLResponse postResponseWithHttpStatus:200];
      mock.statusCode = 400;
      [GreeURLMockingProtocol addMock:mock];      
      
      [GreeFriendCodes requestCodeWithExpireTime:nil block:^(NSString *code, NSError *error) {
        [[error.domain should] equal:GreeErrorDomain];
        [[theValue(error.code) should] equal:theValue(GreeFriendCodeAlreadyRegistered)];
        waitObject = @"DONE";
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    });
    it(@"should return missing data error", ^{
      __block id waitObject= nil;
      MockedURLResponse* mock = [MockedURLResponse postResponseWithHttpStatus:200];
      [GreeURLMockingProtocol addMock:mock];      
      
      [GreeFriendCodes requestCodeWithExpireTime:nil block:^(NSString *code, NSError *error) {
        [[error.domain should] equal:GreeErrorDomain];
        [[theValue(error.code) should] equal:theValue(GreeFriendCodeNotFound)];
        waitObject = @"DONE";
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    });
  });
  context(@"when redeeming code", ^{
    it(@"should report success", ^{
      __block id waitObject= nil;
      MockedURLResponse* mock = [MockedURLResponse postResponseWithHttpStatus:200];
      mock.requestBlock = ^(NSURLRequest* req) {
        [[req.URL.absoluteString should] containString:@"api/rest/friendcode/@me/ABCDEF"];
        [[req.HTTPMethod should] equal:@"POST"];
        NSDictionary* body = [NSJSONSerialization JSONObjectWithData:req.HTTPBody options:0x0 error:nil];
        [[body should] beKindOfClass:[NSDictionary class]];
        [[theValue(body.count) should] equal:theValue(0)];
        return YES;
      };
      [GreeURLMockingProtocol addMock:mock];     
      [GreeFriendCodes verifyCode:@"ABCDEF" withBlock:^(NSError* error) {
        [error shouldBeNil];
        waitObject = @"DONE";
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    });
    
    it(@"should report already used", ^{
      __block id waitObject= nil;
      MockedURLResponse* mock = [MockedURLResponse postResponseWithHttpStatus:400];
      [GreeURLMockingProtocol addMock:mock];     
      [GreeFriendCodes verifyCode:@"ABCDEF" withBlock:^(NSError* error) {
        [[theValue(error.code) should] equal:theValue(GreeFriendCodeAlreadyEntered)];
        waitObject = @"DONE";
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    });
    
    it(@"should return error for bad server response", ^{
      __block id waitObject= nil;
      MockedURLResponse* mock = [MockedURLResponse postResponseWithHttpStatus:404];
      [GreeURLMockingProtocol addMock:mock];     
      [GreeFriendCodes verifyCode:@"ABCDEF" withBlock:^(NSError* error) {
        [[theValue(error.code) should] equal:theValue(GreeFriendCodeNotFound)];
        waitObject = @"DONE";
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    });
    
    it(@"should return errors", ^{
      __block id waitObject= nil;
      MockedURLResponse* mock = [MockedURLResponse postResponseWithHttpStatus:200];
      mock.error = [NSError errorWithDomain:GreeAFNetworkingErrorDomain code:567 userInfo:nil];
      [GreeURLMockingProtocol addMock:mock];      
      
      [GreeFriendCodes verifyCode:@"ABC" withBlock:^(NSError *error) {
        [[error.domain should] equal:GreeErrorDomain];
        waitObject = @"DONE";
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    });    
  });
  context(@"when getting code", ^{
    it(@"should return valid code", ^{
      __block id waitObject= nil;
      MockedURLResponse* mock = [MockedURLResponse getResponseWithHttpStatus:200];
      NSDictionary* values = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSDictionary dictionaryWithObjectsAndKeys:
                               @"2012-12-31T00:00:00+0000", @"expire_time",
                               @"ABCDEF", @"code",                              
                               nil], @"entry",
                              nil];
      mock.data = [NSJSONSerialization dataWithJSONObject:values options:0x0 error:nil];
      mock.requestBlock = ^(NSURLRequest* req) {
        [[req.HTTPMethod should] equal:@"GET"];
        [[req.URL.absoluteString should] containString:@"api/rest/friendcode/@me/@self"];
        return YES;
      };
      [GreeURLMockingProtocol addMock:mock];     
      
      [GreeFriendCodes loadCodeWithBlock:^(NSString *code, NSDate *expiration, NSError *error) {
        [[code should] equal:@"ABCDEF"];
        [[expiration should] beKindOfClass:[NSDate class]];
        [error shouldBeNil];
        waitObject = @"DONE";
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    });
    it(@"should error if no code returned", ^{
      __block id waitObject= nil;
      MockedURLResponse* mock = [MockedURLResponse getResponseWithHttpStatus:200];
      NSDictionary* values = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"nothing", @"nogooddata",
                              nil];
      mock.data = [NSJSONSerialization dataWithJSONObject:values options:0x0 error:nil];
      [GreeURLMockingProtocol addMock:mock];     
      
      [GreeFriendCodes loadCodeWithBlock:^(NSString *code, NSDate *expiration, NSError *error) {
        [code shouldBeNil];
        [[error.domain should] equal:GreeErrorDomain];
        [[theValue(error.code) should] equal:theValue(GreeFriendCodeNotFound)];
        waitObject = @"DONE";
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    });
    it(@"should return not found on 404", ^{
      __block id waitObject= nil;
      MockedURLResponse* mock = [MockedURLResponse getResponseWithHttpStatus:404];
      NSDictionary* values = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"nothing", @"nogooddata",
                              nil];
      mock.data = [NSJSONSerialization dataWithJSONObject:values options:0x0 error:nil];
      [GreeURLMockingProtocol addMock:mock];     
      
      [GreeFriendCodes loadCodeWithBlock:^(NSString *code, NSDate *expiration, NSError *error) {
        [code shouldBeNil];
        [[error.domain should] equal:GreeErrorDomain];
        [[theValue(error.code) should] equal:theValue(GreeFriendCodeNotFound)];
        waitObject = @"DONE";
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    });
    it(@"should return errors", ^{
      __block id waitObject= nil;
      MockedURLResponse* mock = [MockedURLResponse postResponseWithHttpStatus:200];
      mock.error = [NSError errorWithDomain:GreeAFNetworkingErrorDomain code:567 userInfo:nil];
      [GreeURLMockingProtocol addMock:mock];      
      
      [GreeFriendCodes loadCodeWithBlock:^(NSString *code, NSDate *expiration, NSError *error) {
        [[error.domain should] equal:GreeErrorDomain];
        waitObject = @"DONE";
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    });    
  });
  context(@"when getting owner", ^{
    it(@"should return user id", ^{
      __block id waitObject= nil;
      MockedURLResponse* mock = [MockedURLResponse getResponseWithHttpStatus:200];
      NSDictionary* values = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSNumber numberWithInt:123], @"id",
                               nil], @"entry",
                              nil];
      mock.data = [NSJSONSerialization dataWithJSONObject:values options:0x0 error:nil];
      mock.requestBlock = ^(NSURLRequest* req) {
        [[req.HTTPMethod should] equal:@"GET"];
        [[req.URL.absoluteString should] containString:@"api/rest/friendcode/@me/@owner"];
        return YES;
      };
      [GreeURLMockingProtocol addMock:mock];     
      
      [GreeFriendCodes loadCodeOwner:^(NSString *userId, NSError *error) {
        [[userId should] equal:@"123"];
        [error shouldBeNil];
        waitObject = @"DONE";
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    });
    it(@"should return not found on 404", ^{
      __block id waitObject= nil;
      MockedURLResponse* mock = [MockedURLResponse getResponseWithHttpStatus:404];
      NSDictionary* values = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"nothing", @"nogooddata",
                              nil];
      mock.data = [NSJSONSerialization dataWithJSONObject:values options:0x0 error:nil];
      [GreeURLMockingProtocol addMock:mock];     
      
      [GreeFriendCodes loadCodeOwner:^(NSString *userId, NSError *error) {
        [userId shouldBeNil];
        [[error.domain should] equal:GreeErrorDomain];
        [[theValue(error.code) should] equal:theValue(GreeFriendCodeNotFound)];
        waitObject = @"DONE";
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    });
    it(@"should return errors", ^{
      __block id waitObject= nil;
      MockedURLResponse* mock = [MockedURLResponse postResponseWithHttpStatus:200];
      mock.error = [NSError errorWithDomain:GreeAFNetworkingErrorDomain code:567 userInfo:nil];
      [GreeURLMockingProtocol addMock:mock];      
      
      [GreeFriendCodes loadCodeOwner:^(NSString *userId, NSError *error) {
        [[error.domain should] equal:GreeErrorDomain];
        waitObject = @"DONE";
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    });    
  });
  
  context(@"when enumerating ids", ^{
    __block id enumerator = nil;
    beforeEach(^{
      enumerator = [GreeFriendCodes loadFriendsWithBlock:nil];
    });
    it(@"should exist", ^{
      [[enumerator should] beNonNil];
    });
    
    it(@"should read a page", ^{
      __block id waitObject = nil;
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      mock.requestBlock = ^(NSURLRequest* req) {
        [[req.HTTPMethod should] equal:@"GET"];
        [[req.URL.absoluteString should] containString:@"/api/rest/friendcode/@me/@friends?"];
        return YES;
      };
      NSDictionary* data = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithInt:2], @"totalResults",
                            [NSNumber numberWithInt:10], @"itemsPerPage",
                            [NSNumber numberWithInt:1], @"startIndex",
                            [NSArray arrayWithObjects:
                             [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:123] forKey:@"id"],
                             [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:456] forKey:@"id"],
                             nil], @"entry",
                            nil];
                            
      mock.data = [NSJSONSerialization dataWithJSONObject:data options:0x0 error:nil];
      [GreeURLMockingProtocol addMock:mock];
      
      [enumerator loadNext:^(NSArray *items, NSError *error) {
        [[theValue([items count]) should] equal:theValue(2)];
        [[items should] containObjects:@"123", @"456", nil];
        waitObject = @"DONE";
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      [waitObject release];
    });
  });
  
  context(@"when deleting code", ^{
    it(@"should return success on 202", ^{
      __block id waitObject= nil;
      MockedURLResponse* mock = [MockedURLResponse deleteResponseWithHttpStatus:202];
      mock.requestBlock = ^(NSURLRequest* req) {
        [[req.HTTPMethod should] equal:@"DELETE"];
        [[req.URL.absoluteString should] containString:@"api/rest/friendcode/@me"];
        return YES;
      };
      [GreeURLMockingProtocol addMock:mock];      
      
      [GreeFriendCodes deleteCodeWithBlock:^(NSError *error) {
        [error shouldBeNil];
        waitObject = @"DONE";
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    });
    it(@"should return error on any other code", ^{
      __block id waitObject= nil;
      MockedURLResponse* mock = [MockedURLResponse deleteResponseWithHttpStatus:200];
      [GreeURLMockingProtocol addMock:mock];      
      
      [GreeFriendCodes deleteCodeWithBlock:^(NSError *error) {
        [[error.domain should] equal:GreeErrorDomain];
        waitObject = @"DONE";
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    });    
    it(@"should return errors", ^{
      __block id waitObject= nil;
      MockedURLResponse* mock = [MockedURLResponse deleteResponseWithHttpStatus:200];
      mock.error = [NSError errorWithDomain:GreeAFNetworkingErrorDomain code:567 userInfo:nil];
      [GreeURLMockingProtocol addMock:mock];      
      
      [GreeFriendCodes deleteCodeWithBlock:^(NSError *error) {
        [[error.domain should] equal:GreeErrorDomain];
        waitObject = @"DONE";
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    });    
  });
  
  
});

SPEC_END
