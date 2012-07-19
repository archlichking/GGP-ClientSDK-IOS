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
#import "GreeHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "GreeURLMockingProtocol.h"
#import "GreeError+Internal.h"
#import "GreeTestHelpers.h"
#import "AFImageRequestOperation.h"
#import "GreeMatchers.h"

registerMatcher(containSubstring)
////note that, for reasons yet unknown, Kiwi crashes if you try to pass a variable into this method
#define registerSubstringMatcher(substring) \
defineMatcher(@"containSubstring", ^(KWUserDefinedMatcherBuilder* builder) {\
  [builder match:^(id subject) {\
    return (BOOL)(((NSRange) [subject rangeOfString:substring]).location != NSNotFound);\
  }];\
});

@interface GreeAuthorization (TestClass)
- (void)greeExecuteFailureBlockWithparams:(NSDictionary*)params successBlock:(void(^)(void))successBlock failureBlock:(void(^)(void))failureBlock;
@end

@implementation GreeAuthorization (TestClass)
- (void)greeExecuteFailureBlockWithparams:(NSDictionary*)params successBlock:(void(^)(void))successBlock failureBlock:(void(^)(void))failureBlock
{
  failureBlock();
}
@end


SPEC_BEGIN(GreeHTTPClientSpec)
describe(@"Gree HTTP Client", ^{
  __block GreeHTTPClient* client;
//  __block OAConsumer* consumer;
//  __block id<OASignatureProviding, NSObject> signer;
  static NSString* fixedNonce = @"THIS-IS-A-FIXED-NONCE";
  static NSString* fixedTimestamp = @"10000000";
  static NSString* fixedOauthClientKey = @"TESTCLIENTKEY";
  static NSString* fixedOauthClientSecret = @"TESTCLIENTSECRET";
  static NSString* fixedOauthUserKey = @"TESTUSERKEY";
  static NSString* fixedOauthUserSecret = @"TESTUSERSECRET";
  
  registerMatchers(@"Gree");

  beforeEach(^{
    [GreeHTTPClient stub:@selector(userAgentString) andReturn:@"Duuuhh"];
    client = [[GreeHTTPClient alloc ] 
      initWithBaseURL:[NSURL URLWithString:[GreeURLMockingProtocol httpClientPrefix]] 
      key:fixedOauthClientKey 
      secret:fixedOauthClientSecret];
  });
  
  afterEach(^{
    [client release];
    client = nil;    
  });
  
  it(@"should point to the GREE server", ^{
    [[client.baseURL should] equal:[NSURL URLWithString:@"http://test.gree.net"]];
  });
  
  it(@"should add proper JSON Accept header", ^{
    [[[client defaultValueForHeader:@"Accept"] should] equal:@"application/json"];
  });
  
  it(@"should use json operations", ^{
    NSURLRequest* request = [client requestWithMethod:@"GET" path:@"test" parameters:nil];
    GreeAFHTTPRequestOperation* op = [client HTTPRequestOperationWithRequest:request success:nil failure:nil];
    [[op should] beMemberOfClass:[GreeAFJSONRequestOperation class]];
  });        
  
  it(@"should allow non-JSON operations", ^{
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://test.gree.net"]];
    GreeAFHTTPRequestOperation* op = [client HTTPRequestOperationWithRequest:request success:nil failure:nil];
    [[op shouldNot] beMemberOfClass:[GreeAFJSONRequestOperation class]];
  });
  
  context(@"when mocked", ^{
    beforeEach(^{
      [GreeURLMockingProtocol register];
    });
    
    afterEach(^{
      [GreeURLMockingProtocol unregister];
    });
    
    context(@"download image and cancel", ^{
      __block MockedURLResponse* mock = nil;
      __block UIImage* blankImage = nil;
      __block NSURL* mockImageUrl = nil;
      
      beforeEach(^{
        blankImage = [[UIImage alloc] init];
        mock = [MockedURLResponse new];
        NSURL* baseURL = [NSURL URLWithString:[GreeURLMockingProtocol httpClientPrefix]];
        mockImageUrl = [[NSURL URLWithString:@"achievementIcon" relativeToURL:baseURL] retain];
      });
      
      afterEach(^{
        [blankImage release];
        [mock release];
        [mockImageUrl release];
      });
      
      it(@"should handle missing block in downloading image", ^{
        [client downloadImageAtUrl:mockImageUrl withBlock:nil];
      });
      
      it(@"should download image successfully", ^{
        __block id waitObject = nil;
        mock.data = UIImagePNGRepresentation(blankImage);
        [GreeURLMockingProtocol addMock:mock]; 
        [client downloadImageAtUrl:mockImageUrl withBlock:^(UIImage *image, NSError *error) {
          waitObject = [image retain];
        }];
        [[expectFutureValue(waitObject) shouldEventually] beKindOfClass:[UIImage class]];
        [waitObject release];
      });
      
      it(@"should handle failure when downloading failure happened", ^{
        __block id waitObject = nil;
        mock.statusCode = 500;
        [GreeURLMockingProtocol addMock:mock]; 
        [client downloadImageAtUrl:mockImageUrl withBlock:^(UIImage *image, NSError *error) {
          waitObject = [error copy];
          [[[error domain] should] equal:GreeErrorDomain];
          [[theValue([error code]) should] beLessThan:theValue(GreeErrorCodeReservedBase)];
        }];
        [[expectFutureValue(waitObject) shouldEventually] beKindOfClass:[NSError class]];
        [waitObject release];
      });
      
      it(@"should cancel request operation", ^{
        __block id waitObject = nil;
        MockedURLResponse* cancelMock = [[MockedURLResponse alloc] init];
        [GreeURLMockingProtocol addMock:cancelMock];
          
        MockedURLResponse* mock = [[MockedURLResponse alloc] init];
        mock.requestBlock = ^(NSURLRequest* req) {
          NSRange range = [req.URL.absoluteString rangeOfString:@"GOOD"];
          [[theValue(range.location) shouldNot] equal:theValue(NSNotFound)];  //thereby showing it's the second one.
          return YES;
        };
        [GreeURLMockingProtocol addMock:mock];
          
        id op = [client downloadImageAtUrl:mockImageUrl withBlock:^(UIImage *image, NSError *error) {
          //it should not come to this point, because the operation is canceled.
          waitObject = @"FAILED";
        }];
                  
        [client cancelWithHandle:op];
        [client getPath:@"GOOD" parameters:nil success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
          waitObject = @"GOOD";
        } failure:^(GreeAFHTTPRequestOperation *operation, NSError* error) {
          waitObject = error;
        }];
        [[expectFutureValue(waitObject) shouldEventually] equal:@"GOOD"];
        [mock release];
      });   
      
      it(@"should not cancel if URL's don't match", ^{
        __block id waitObject = nil;
        MockedURLResponse* mock = [[MockedURLResponse alloc] init];
        MockedURLResponse* mock2 = [[MockedURLResponse alloc] init];
        [GreeURLMockingProtocol addMock:mock];
        [GreeURLMockingProtocol addMock:mock2];
        [mock release];
        [mock2 release];
        
        GreeAFImageRequestOperation* mockOperation = [GreeAFImageRequestOperation alloc];   //no init! 
        [GreeAFImageRequestOperation stub:@selector(alloc) andReturn:mockOperation];  //we want the operations to be the very same object
        id handle = [[client downloadImageAtUrl:mockImageUrl withBlock:^(UIImage *image, NSError *error) {
          waitObject = @"STEP1";
        }] retain];
        [[expectFutureValue(waitObject) shouldEventually] equal:@"STEP1"];
        //so, the first operation is done
        NSURL* baseURL = [NSURL URLWithString:[GreeURLMockingProtocol httpClientPrefix]];
        NSURL* mockImageUrl2 = [NSURL URLWithString:@"achievementIcon2" relativeToURL:baseURL];
        id handle2 = [[client downloadImageAtUrl:mockImageUrl2 withBlock:nil] retain];
        [[mockOperation shouldNot] receive:@selector(cancel)];
        [client cancelWithHandle:handle];      //cancel with the old handle, this should match id but fail URL so not cancel the new request
                                               //note that the second operation isn't set up properly, so we can't test that it really goes.
        [handle release];
        [handle2 release];
          
        //cleanup
        [client getPath:@"GOOD" parameters:nil success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
            waitObject = @"GOOD";
        } failure:^(GreeAFHTTPRequestOperation *operation, NSError* error) {
            waitObject = error;
        }];
        [[expectFutureValue(waitObject) shouldEventually] equal:@"GOOD"];
      });
  
    });
    
    
    it(@"should allow mocking", ^{            
      __block NSString* waitObject = nil;
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      [GreeURLMockingProtocol addMock:mock];
      
      [client getPath:@"check" parameters:nil success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
        waitObject = @"YES";
      } failure:^(GreeAFHTTPRequestOperation *operation, NSError *error) {
        waitObject = @"NO";
      }];       
      [[expectFutureValue(waitObject) shouldEventually] equal:@"YES"];
    });
    it(@"should return mocked Json data", ^{
      __block id returnObject = nil;
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      static const char* sReturnData = "[ \"a\" ]";
      mock.data = [NSData dataWithBytes:sReturnData length:strlen(sReturnData)];
      [GreeURLMockingProtocol addMock:mock];
      
      [client getPath:@"check" parameters:nil success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
        returnObject = responseObject;
      } failure:nil];       
      [[expectFutureValue(returnObject) shouldEventually] equal:[NSArray arrayWithObject:@"a"]];
    });
    
    it(@"should allow setting mock headers", ^{
      __block id waitObject = nil;
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      mock.headers = [NSDictionary dictionaryWithObject:@"check" forKey:@"test-header"];
      [GreeURLMockingProtocol addMock:mock];
      
      [client getPath:@"check" parameters:nil success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)[operation response];
        waitObject = [[httpResponse allHeaderFields] retain];
      } failure:^(GreeAFHTTPRequestOperation *operation, NSError *error) {
        waitObject = @"NO";
      }];       
      [[expectFutureValue(waitObject) shouldEventually] haveValue:@"check" forKey:@"test-header"];
      [waitObject release];
    });
    
    it(@"should allow mocking status code errors", ^{            
      __block NSString* waitObject = nil;
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      mock.statusCode = 401;  //forbidden
      [GreeURLMockingProtocol addMock:mock];
      
      [client getPath:@"check" parameters:nil success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
        waitObject = @"NO";
      } failure:^(GreeAFHTTPRequestOperation *operation, NSError *error) {
        waitObject = @"YES";
      }];       
      [[expectFutureValue(waitObject) shouldEventually] equal:@"YES"];
    });
    
    it(@"should allow mocking error object", ^{            
      __block NSString* waitObject = nil;
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      mock.error = [NSError errorWithDomain:@"testDomain" code:0 userInfo:nil];
      [GreeURLMockingProtocol addMock:mock];
      
      [client getPath:@"check" parameters:nil success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
        waitObject = @"NO";
      } failure:^(GreeAFHTTPRequestOperation *operation, NSError *error) {
        waitObject = @"YES";
      }];       
      [[expectFutureValue(waitObject) shouldEventually] equal:@"YES"];
    });

    it(@"should support mock request verification",^{
      __block NSString* waitObject = nil;
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      NSString* checkString = [NSString stringWithString:@"CHECK"];  //so it will be a heap object
      mock.requestBlock = ^(NSURLRequest* request) {
        [[checkString should] equal:@"CHECK"];
        return YES;
      };
      [GreeURLMockingProtocol addMock:mock];
      
      [client getPath:@"check" parameters:nil success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
        waitObject = @"OK";
      } failure:^(GreeAFHTTPRequestOperation *operation, NSError *error) {
        waitObject = @"FAILED";
      }];       
      [[expectFutureValue(waitObject) shouldEventually] equal:@"OK"];
    });

    it(@"should support mock request verification failure",^{
      __block NSString* waitObject = nil;
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      mock.requestBlock = ^(NSURLRequest* request) {
        return NO;
      };
      [GreeURLMockingProtocol addMock:mock];
      
      [client getPath:@"check" parameters:nil success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
        waitObject = @"NO";
      } failure:^(GreeAFHTTPRequestOperation *operation, NSError *error) {
        [[error.domain should] equal:GreeUrlMockErrorDomain];
        waitObject = @"YES";
      }];       
      [[expectFutureValue(waitObject) shouldEventually] equal:@"YES"];
    });
    
    it(@"should error if mock is missing", ^{
      __block id waitObject = nil;
      [client getPath:@"check" parameters:nil success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
        waitObject = @"NOTAFAILURE";
        //nothing
      } failure:^(GreeAFHTTPRequestOperation *operation, NSError *error) {
        waitObject = [error retain];
      }];                   
      [[expectFutureValue(waitObject) shouldEventually] beKindOfClass:[NSError class]];            
      [waitObject release];
    });
    
    it(@"should allow mocking delays", ^{
      __block id waitObject = nil;
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      mock.delay = 0.2;
      [GreeURLMockingProtocol addMock:mock];   
      [client getPath:@"check" parameters:nil success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
        waitObject = @"GOOD";
      } failure:nil];
      [[expectFutureValue(waitObject) shouldEventuallyBeforeTimingOutAfter(1)] beNonNil];
      [waitObject release];            
    });
        
    it(@"should allow streamed downloads", ^{
      __block id waitObject = nil;
      
      unsigned char streamBuffer[10];
      memset(streamBuffer, 0, 10);  //for safety sake
      static const char *mockDataBytes = "ABCDEFG";
      NSData* mockData = [NSData dataWithBytes:mockDataBytes length:strlen(mockDataBytes)];
      
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      mock.data = mockData;
      [GreeURLMockingProtocol addMock:mock];
      
      NSMutableURLRequest* req = [client requestWithMethod:@"GET" path:@"dummy" parameters:nil];
      [req setValue:@"text/text" forHTTPHeaderField:@"Accept"];  //we don't want JSON for this operation
      GreeAFHTTPRequestOperation* op = [client HTTPRequestOperationWithRequest:req success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
        waitObject = @"DONE";
      } failure:nil];
      op.outputStream = [NSOutputStream outputStreamToBuffer:streamBuffer capacity:10];
      [client enqueueHTTPRequestOperation:op];
      
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      NSData* bufferData = [NSData dataWithBytes:streamBuffer length:strlen((char*)streamBuffer)];
      [[theObject(&bufferData) should] equal:mockData];
    });
    
    it(@"should allow concurrent operations", ^{
      MockedURLResponse* mock1 = [[MockedURLResponse new] autorelease];
      mock1.delay = 0.1;
      MockedURLResponse* mock2 = [[MockedURLResponse new] autorelease];
      mock2.delay = 0.1;
      [GreeURLMockingProtocol addMock:mock1];
      [GreeURLMockingProtocol addMock:mock2];
      
      [client setMaxConcurrentOperations:2];
      [client getPath:@"op1" parameters:nil success:nil failure:nil];
      [client getPath:@"op2" parameters:nil success:nil failure:nil];
      [client getPath:@"op3" parameters:nil success:nil failure:nil];
      //needed to give the operation queue time to start up
      [NSThread sleepForTimeInterval:0.05];
      NSLog(@"We are running %d", [client activeRequestCount]);
      [[theValue([client activeRequestCount])should] equal:2 withDelta:0];
    });
    
    it(@"should allow raw requests", ^{
      __block id waitObject = nil;
      
      unsigned char streamBuffer[10];
      memset(streamBuffer, 0, 10);  //for safety sake
      static const char *mockDataBytes = "ABCDEFG";
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      mock.data = [NSData dataWithBytes:mockDataBytes length:strlen(mockDataBytes)];
      [GreeURLMockingProtocol addMock:mock];
      
      [client rawRequestWithMethod:@"GET" path:[GreeURLMockingProtocol httpClientPrefix] parameters:nil success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
        waitObject = responseObject;
      } failure:nil];
      
      [[expectFutureValue(waitObject) shouldEventually] equal:[NSData dataWithBytes:mockDataBytes length:strlen(mockDataBytes)]];
    });    
    
    it(@"should allow encoded DELETE request", ^{
      __block id waitObject = nil;
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      [GreeURLMockingProtocol addMock:mock];
      
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"first", @"key1",
                                  @"second", @"key2",
                                  @"𝄞", @"clef",
                                  nil];
      [client encodedDeletePath:@"path/to/delete" parameters:parameters success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
        //make sure the request was created correctly
        NSString* urlString = operation.request.URL.absoluteString;
        //I want a substring search so badly... parameter ordering is not fixed
        [[theValue([urlString rangeOfString:@"key2=second"].location) shouldNot] equal:theValue(NSNotFound)];
        [[theValue([urlString rangeOfString:@"clef=%F0%9D%84%9E"].location) shouldNot] equal:theValue(NSNotFound)];
        [operation.request.HTTPBody shouldBeNil];
        [[[operation.request valueForHTTPHeaderField:@"Authorization"] should] beNonNil];  //proving it was signed
        
        waitObject = @"YES";
      } failure:^(GreeAFHTTPRequestOperation *operation, NSError *error) {
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    });
    
    it(@"should allow explicitly 2 legged requests", ^{
      __block id waitObject = nil;
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      [GreeURLMockingProtocol addMock:mock];
      
      [client setUserToken:@"key" secret:@"secret"];

      [client performTwoLeggedRequestWithMethod:@"GET" path:@"path/to/get" parameters:nil success:^(GreeAFHTTPRequestOperation* operation, id response) {
        NSString* url = operation.request.URL.absoluteString;
        [[url shouldNot] containString:@"oauth_token"];
        [[[operation.request valueForHTTPHeaderField:@"Authorization"] should] beNonNil];  //proving it was signed
        waitObject = @"YES";
      } failure:^(GreeAFHTTPRequestOperation* operation, NSError* error) {
      }];
      
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];      
    });

    context(@"when error that should be handled occure", ^{
      __block id waitObject;
      __block GreeAuthorization *authMock;
      beforeEach(^{
        waitObject = nil;
        authMock = [[GreeAuthorization alloc] init];
        [authMock stub:@selector(reAuthorize) andReturn:nil];        
        [GreeAuthorization stub:@selector(sharedInstance) andReturn:authMock];
      });
      afterEach(^{
        [authMock release];
        [waitObject release];
      });
      it(@"should not call authorization method without no json", ^{
        MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
        mock.statusCode = 401;
        [GreeURLMockingProtocol addMock:mock];   

        [[authMock shouldNot] receive:@selector(reAuthorize)];      
        
        [client getPath:@"check" parameters:nil success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
        } failure:^(GreeAFHTTPRequestOperation *operation, NSError *error) {
          waitObject = [error retain];
        }];
        [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      });
      it(@"should not call reAuthorize", ^{
        MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
        mock.statusCode = 401;
        NSString* responseString = @"{\"code\":1002,\"__error\":[0,2]}";
        mock.data = [responseString  dataUsingEncoding:NSUTF8StringEncoding];
        [GreeURLMockingProtocol addMock:mock];   
        
        [[authMock shouldNot] receive:@selector(reAuthorize)];      
        
        [client getPath:@"check" parameters:nil success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
        } failure:^(GreeAFHTTPRequestOperation *operation, NSError *error) {
          waitObject = [error retain];
        }];
        [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      });
      it(@"should call reAuthorize", ^{
        MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
        mock.statusCode = 401;
        NSString* responseString = @"{\"code\":1002,\"__error\":[1,2]}";
        mock.data = [responseString  dataUsingEncoding:NSUTF8StringEncoding];
        [GreeURLMockingProtocol addMock:mock];   
        
        [[authMock should] receive:@selector(reAuthorize)];      
        
        [client getPath:@"check" parameters:nil success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
        } failure:^(GreeAFHTTPRequestOperation *operation, NSError *error) {
          waitObject = [error retain];
        }];
        [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      });
      it(@"should not call upgradeWithParams", ^{
        MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
        mock.statusCode = 403;
        NSString* responseString = @"{\"code\":1003,\"__error\":[0,2]}";
        mock.data = [responseString  dataUsingEncoding:NSUTF8StringEncoding];
        [GreeURLMockingProtocol addMock:mock];   
        
        [[authMock shouldNot] receive:@selector(upgradeWithParams:successBlock:failureBlock:)];      
        
        [client getPath:@"check" parameters:nil success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
        } failure:^(GreeAFHTTPRequestOperation *operation, NSError *error) {
          waitObject = [error retain];
        }];
        [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      });
      it(@"should call upgradeWithParams", ^{
        
        [GreeTestHelpers
         exchangeInstanceSelector:@selector(upgradeWithParams:successBlock:failureBlock:)
         onClass:[GreeAuthorization class]
         withSelector:@selector(greeExecuteFailureBlockWithparams:successBlock:failureBlock:)
         onClass:[GreeAuthorization class]];
        
        MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
        mock.statusCode = 403;
        NSString* responseString = @"{\"code\":1003,\"__error\":[1,2]}";
        mock.data = [responseString  dataUsingEncoding:NSUTF8StringEncoding];
        [GreeURLMockingProtocol addMock:mock];   
        
        [[authMock should] receive:@selector(upgradeWithParams:successBlock:failureBlock:)];      
        
        [client getPath:@"check" parameters:nil success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
        } failure:^(GreeAFHTTPRequestOperation *operation, NSError *error) {
          waitObject = [error retain];
        }];
        [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      });      
      it(@"should not call authorization method without no json using performRequest", ^{
        MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
        mock.statusCode = 401;
        [GreeURLMockingProtocol addMock:mock];   
        
        [[authMock shouldNot] receive:@selector(reAuthorize)];
        
        NSURL* checkURL = [NSURL URLWithString:[GreeURLMockingProtocol httpClientPrefix]];
        NSMutableURLRequest* request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"external" relativeToURL:checkURL]] autorelease];
        [client performRequest:request parameters:nil success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
        } failure:^(GreeAFHTTPRequestOperation *operation, NSError *error) {
          waitObject = [error retain];
        }];
        [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      });
      it(@"should not call reAuthorize using performRequest", ^{
        MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
        mock.statusCode = 401;
        NSString* responseString = @"{\"code\":1002,\"__error\":[0,2]}";
        mock.data = [responseString  dataUsingEncoding:NSUTF8StringEncoding];
        [GreeURLMockingProtocol addMock:mock];   
        
        [[authMock shouldNot] receive:@selector(reAuthorize)];      
        
        NSURL* checkURL = [NSURL URLWithString:[GreeURLMockingProtocol httpClientPrefix]];
        NSMutableURLRequest* request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"external" relativeToURL:checkURL]] autorelease];
        [client performRequest:request parameters:nil success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
        } failure:^(GreeAFHTTPRequestOperation *operation, NSError *error) {
          waitObject = [error retain];
        }];
        [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      });
      it(@"should call reAuthorize using performRequest", ^{
        MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
        mock.statusCode = 401;
        NSString* responseString = @"{\"code\":1002,\"__error\":[1,2]}";
        mock.data = [responseString  dataUsingEncoding:NSUTF8StringEncoding];
        [GreeURLMockingProtocol addMock:mock];   
        
        [[authMock should] receive:@selector(reAuthorize)];      
        
        NSURL* checkURL = [NSURL URLWithString:[GreeURLMockingProtocol httpClientPrefix]];
        NSMutableURLRequest* request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"external" relativeToURL:checkURL]] autorelease];
        [client performRequest:request parameters:nil success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
        } failure:^(GreeAFHTTPRequestOperation *operation, NSError *error) {
          waitObject = [error retain];
        }];
        [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      });
      it(@"should not call upgradeWithParams using performRequest", ^{
        MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
        mock.statusCode = 403;
        NSString* responseString = @"{\"code\":1003,\"__error\":[0,2]}";
        mock.data = [responseString  dataUsingEncoding:NSUTF8StringEncoding];
        [GreeURLMockingProtocol addMock:mock];   
        
        [[authMock shouldNot] receive:@selector(upgradeWithParams:successBlock:failureBlock:)];      
        
        NSURL* checkURL = [NSURL URLWithString:[GreeURLMockingProtocol httpClientPrefix]];
        NSMutableURLRequest* request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"external" relativeToURL:checkURL]] autorelease];
        [client performRequest:request parameters:nil success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
        } failure:^(GreeAFHTTPRequestOperation *operation, NSError *error) {
          waitObject = [error retain];
        }];
        [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      });
      it(@"should call upgradeWithParams using performRequest", ^{
        
        [GreeTestHelpers
         exchangeInstanceSelector:@selector(upgradeWithParams:successBlock:failureBlock:)
         onClass:[GreeAuthorization class]
         withSelector:@selector(greeExecuteFailureBlockWithparams:successBlock:failureBlock:)
         onClass:[GreeAuthorization class]];
        
        MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
        mock.statusCode = 403;
        NSString* responseString = @"{\"code\":1003,\"__error\":[1,2]}";
        mock.data = [responseString  dataUsingEncoding:NSUTF8StringEncoding];
        [GreeURLMockingProtocol addMock:mock];   
        
        [[authMock should] receive:@selector(upgradeWithParams:successBlock:failureBlock:)];      
        
        NSURL* checkURL = [NSURL URLWithString:[GreeURLMockingProtocol httpClientPrefix]];
        NSMutableURLRequest* request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"external" relativeToURL:checkURL]] autorelease];
        [client performRequest:request parameters:nil success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
        } failure:^(GreeAFHTTPRequestOperation *operation, NSError *error) {
          waitObject = [error retain];
        }];
        [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      });      
    });

    context(@"when using OAuth", ^{      
      beforeEach(^{
        [client setValue:fixedTimestamp forKeyPath:@"testTimestamp"];
        [client setValue:fixedNonce forKeyPath:@"testNonce"];
      });
      
      it(@"should allow external requests", ^{
        MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
        [GreeURLMockingProtocol addMock:mock];
        
        __block id waitObject = nil;
        NSURL* checkURL = [NSURL URLWithString:[GreeURLMockingProtocol httpClientPrefix]];
        NSMutableURLRequest* request = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"external" relativeToURL:checkURL]] autorelease];
        [client performRequest:request parameters:nil success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
          [[[operation.request valueForHTTPHeaderField:@"Authorization"] should] beNonNil];  //proving it was signed
          waitObject = @"signal";
        } failure:^(GreeAFHTTPRequestOperation *operation, NSError *error) {
        }];
        [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      });
      
      context(@"without a token", ^{
        it(@"should calculate signature", ^{
          id greeRequest = [client requestWithMethod:@"GET" path:@"hello" parameters:nil];
          registerSubstringMatcher(@"OSHOhgrOxaOhDkUghSjiIBQuNEU");  //these values were determined by comparison with the OAuthConsumer library
          [[[greeRequest valueForHTTPHeaderField:@"Authorization"] should] containSubstring];
          
          //compare the headers and see what's going on
        });
        
        it(@"should calculate signature with parameters", ^{
          
          
          id greeRequest = [client requestWithMethod:@"GET" path:@"hello" parameters:[NSDictionary dictionaryWithObject:@"value@#&$*^" forKey:@"param1"]];
          registerSubstringMatcher(@"y8zVMyHqrRZCt73jcR03DB3");
          [[[greeRequest valueForHTTPHeaderField:@"Authorization"] should] containSubstring];
        });
        
        it(@"should say it has no token", ^{
          [[theValue([client hasUserToken]) should] beFalse];
        });
      });
      
      
      context(@"with a token", ^{
        beforeEach(^{
          [client setUserToken:fixedOauthUserKey secret:fixedOauthUserSecret];
        });
        
        afterEach(^{
          [client setUserToken:nil secret:nil];
        });
        
        it(@"should say it has a token", ^{
          [[theValue([client hasUserToken]) should] beTrue];
        });
        
        it(@"should calculate signature", ^{
          id greeRequest = [client requestWithMethod:@"GET" path:@"hello" parameters:nil];
          registerSubstringMatcher(@"JEwpMvPxxopGEI9I0noLqskNuIY");
          [[[greeRequest valueForHTTPHeaderField:@"Authorization"] should] containSubstring];
        });
        
        it(@"should calculate signature with parameters", ^{

          id greeRequest = [client requestWithMethod:@"GET" path:@"hello" parameters:[NSDictionary dictionaryWithObject:@"value@#&$*^" forKey:@"param1"]];
          registerSubstringMatcher(@"QEyM7r5jrc9uCeYmtS9YLh7Fcac");
          [[[greeRequest valueForHTTPHeaderField:@"Authorization"] should] containSubstring];
        });
      });
    });

    it(@"should convert status code errors to Gree errors", ^{
      __block NSString* waitObject = nil;
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      NSDictionary* errorInfoDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           @"VAL", @"KEY",
                                           @"OriginalDesc", NSLocalizedDescriptionKey,
                                           nil];
      mock.error = [NSError errorWithDomain:GreeAFNetworkingErrorDomain code:20 userInfo:errorInfoDictionary];
      [GreeURLMockingProtocol addMock:mock];
      
      [client getPath:@"check" parameters:nil success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
      } failure:^(GreeAFHTTPRequestOperation *operation, NSError *error) {
        error = [GreeError convertToGreeError:error];
        [[error.domain should] equal:GreeErrorDomain];
        [[theValue(error.code) should] equal:theValue(GreeErrorCodeNetworkError)];
        [[error.userInfo should] haveValue:@"VAL" forKey:@"KEY"];
        [[error.userInfo should] haveValueForKey:NSLocalizedDescriptionKey];
        [[error.userInfo should] haveValue:@"OriginalDesc" forKey:@"AFNetworkingErrorDescription"];
        waitObject = @"FAIL";
      }];       
      [[expectFutureValue(waitObject) shouldEventually] equal:@"FAIL"];
    });
    
    it(@"should consider 404 an error", ^{
      __block NSString* waitObject = nil;
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      mock.statusCode = 404;
      [GreeURLMockingProtocol addMock:mock];
      
      [client getPath:@"check" parameters:nil success:^(GreeAFHTTPRequestOperation *operation, id responseObject) {
        waitObject = @"GOOD";
      } failure:^(GreeAFHTTPRequestOperation *operation, NSError *error) {
        waitObject = @"FAIL";
      }];       
      [[expectFutureValue(waitObject) shouldEventually] equal:@"FAIL"];
    });
  });
});

SPEC_END
