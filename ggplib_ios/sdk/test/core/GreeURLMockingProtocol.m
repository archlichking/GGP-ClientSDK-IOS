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
#import "GreeURLMockingProtocol.h"
#import "GreeTestHelpers.h"
#import "AFHTTPRequestOperation.h"

static NSMutableDictionary* sMocks = nil;
NSString* GreeUrlMockErrorDomain = @"com.gree.mocking";
const NSInteger GreeUrlMockMissingMockError = 0;
const NSInteger GreeUrlMockFailedRequestBlock = 1;

static NSInteger sMockSerialNumber = 0;
static NSInteger sRequestSerialNumber = 0;

static BOOL sDebugMode = NO;

@interface GreeHTTPClient (Swizzler)
- (void)swizzleEnqueueHTTPRequestOperation:(GreeAFHTTPRequestOperation *)operation;
@end


@implementation MockedURLResponse
@synthesize data = _data;
@synthesize headers = _headers;
@synthesize statusCode = _statusCode;
@synthesize error = _error;
@synthesize delay = _delay;
@synthesize requestBlock = _requestBlock;

#pragma mark - Object Lifecycle

- (id)init
{
  self = [super init];
  if(self) {
    _statusCode = 200;
  }
  return self;
}

- (void)dealloc
{
  [_data release];
  [_headers release];
  [_error release];
  [_requestBlock release];
  [super dealloc];
}

- (NSString*)description
{
  return [NSString stringWithFormat:@"<%@: %p, code: %d, data: %@, headers: %@, error: %f>", [self class], self, self.statusCode, self.data, self.headers, self.error];
}

#pragma mark - Public Interface

+ (id)getResponseWithHttpStatus:(NSInteger)statusCode
{
  MockedURLResponse* response = [[[MockedURLResponse alloc] init] autorelease];
  response.statusCode = statusCode;
  response.requestBlock = ^(NSURLRequest* request) {
    return [request.HTTPMethod isEqualToString:@"GET"];
  };
  return response;
}

+ (id)postResponseWithHttpStatus:(NSInteger)statusCode
{
  MockedURLResponse* response = [[[MockedURLResponse alloc] init] autorelease];
  response.statusCode = statusCode;
  response.requestBlock = ^(NSURLRequest* request) {
    return [request.HTTPMethod isEqualToString:@"POST"];
  };
  return response;
}

+ (id)putResponseWithHttpStatus:(NSInteger)statusCode
{
  MockedURLResponse* response = [[[MockedURLResponse alloc] init] autorelease];
  response.statusCode = statusCode;
  response.requestBlock = ^(NSURLRequest* request) {
    return [request.HTTPMethod isEqualToString:@"PUT"];
  };
  return response;
}

+ (id)deleteResponseWithHttpStatus:(NSInteger)statusCode
{
  MockedURLResponse* response = [[[MockedURLResponse alloc] init] autorelease];
  response.statusCode = statusCode;
  response.requestBlock = ^(NSURLRequest* request) {
    return [request.HTTPMethod isEqualToString:@"DELETE"];
  };
  return response;
}

@end

@interface NSHTTPURLResponse (SuperSecretApplePrivateStuffDoNotRelease)
- (id) initWithURL:(NSURL*) URL statusCode:(NSInteger) code headerFields:(NSDictionary*)headers requestTime:(NSTimeInterval)delay;
@end

@interface GreeURLMockingProtocol()
- (void)execute;
@end


@implementation GreeURLMockingProtocol

#pragma mark - Public Interface

+ (void)addMock:(MockedURLResponse*)mock
{
  if(sDebugMode) {
    NSLog(@">>>>>>>NSURLMockingProtocol ADD %@ serial %d", mock, sMockSerialNumber);
  }
  [sMocks setObject:mock forKey:[NSString stringWithFormat:@"%d", sMockSerialNumber++]];
}

+ (void)register
{
  if(!sMocks) {
    sMocks = [[NSMutableDictionary alloc] init];
  }
  
  //a (likely bad) test could leave these out of sync
  NSInteger floor = MAX(sMockSerialNumber, sRequestSerialNumber);
  sMockSerialNumber = floor;
  sRequestSerialNumber = floor;
  
  
  
  [GreeTestHelpers exchangeInstanceSelector:@selector(swizzleEnqueueHTTPRequestOperation:) onClass:[GreeHTTPClient class] withSelector:@selector(enqueueHTTPRequestOperation:) onClass:[GreeHTTPClient class]];
  [NSURLProtocol registerClass:[GreeURLMockingProtocol class]];        
}

+ (void)unregister
{
  sDebugMode = NO;  //reset this at the end of each test so it doesn't "bleed" through
  [sMocks removeAllObjects];
  [GreeTestHelpers exchangeInstanceSelector:@selector(swizzleEnqueueHTTPRequestOperation:) onClass:[GreeHTTPClient class] withSelector:@selector(enqueueHTTPRequestOperation:) onClass:[GreeHTTPClient class]];
  
  [NSURLProtocol unregisterClass:[GreeURLMockingProtocol class]];
}

+ (NSString*) httpClientPrefix
{
  return @"http://test.gree.net";
}

+ (void)setDebugMode:(BOOL)debugMode
{
  sDebugMode = debugMode;
}


#pragma mark - Internal Methods

- (void)execute
{
  //if this is canceled already, we don't want it to do anything....
  id client = [self client];
  if(sDebugMode) {
    NSLog(@">>>>>>>NSURLMockingProtocol EXECUTE %@ serial %@", self.request, [self.request valueForHTTPHeaderField:@"X-GREE-MOCK-SERIAL"]);
  }
  MockedURLResponse* mock = [sMocks objectForKey:[self.request valueForHTTPHeaderField:@"X-GREE-MOCK-SERIAL"]];
  if(!mock) {
    [client URLProtocol:self didFailWithError:[NSError errorWithDomain:GreeUrlMockErrorDomain 
                                                                  code:GreeUrlMockMissingMockError
                                                              userInfo:[NSDictionary dictionaryWithObject:@"Failed to find a mock during execution" forKey:@"blah"]]];
    
  } else {
    if(mock.error) {
      [client URLProtocol:self didFailWithError:mock.error];
    } else {            
      if(mock.requestBlock && !mock.requestBlock(self.request)) {
        [client URLProtocol:self didFailWithError:[NSError errorWithDomain:GreeUrlMockErrorDomain code:GreeUrlMockFailedRequestBlock userInfo:nil]];
      } else {
        NSMutableDictionary* responseHeaders = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                @"application/json", @"Content-Type",
                                                nil];
        [responseHeaders addEntriesFromDictionary:mock.headers];
        NSHTTPURLResponse* response = [[NSHTTPURLResponse alloc] initWithURL:[[self request] URL] statusCode:mock.statusCode headerFields:responseHeaders requestTime:0];
        [client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [client URLProtocol:self didLoadData:mock.data];
        [client URLProtocolDidFinishLoading:self];
      }
    }    
  }
}

#pragma mark - NSURLProtocol

+ (NSURLRequest*)canonicalRequestForRequest:(NSURLRequest *)request
{
  return request;
}


+ (BOOL)canInitWithRequest:(NSURLRequest *)request
{
  return [[[request URL] absoluteString] hasPrefix:[self httpClientPrefix]];
}


- (void)startLoading
{
  id client = [self client];
  if(sDebugMode) {
    NSLog(@">>>>>>>NSURLMockingProtocol LOAD %@ serial %@", self.request, [self.request valueForHTTPHeaderField:@"X-GREE-MOCK-SERIAL"]);
  }
  MockedURLResponse* mock = [sMocks objectForKey:[self.request valueForHTTPHeaderField:@"X-GREE-MOCK-SERIAL"]];
  if(mock) {
    [self performSelector:@selector(execute) withObject:nil afterDelay:mock.delay];
  }
  else {
    [client URLProtocol:self didFailWithError:[NSError errorWithDomain:GreeUrlMockErrorDomain 
                                                                  code:GreeUrlMockMissingMockError
                                                              userInfo:[NSDictionary dictionaryWithObject:@"Failed to find a mock" forKey:@"blah"]]];
  }
}

- (void)stopLoading
{
  //abort any outstanding selectors
  [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

@end

@implementation GreeHTTPClient (Swizzler)
- (void)swizzleEnqueueHTTPRequestOperation:(GreeAFHTTPRequestOperation *)operation
{
  if([operation.request isMemberOfClass:[NSMutableURLRequest class]]) {
    NSMutableURLRequest* request = (NSMutableURLRequest*)operation.request;
    if(sDebugMode) {
      NSLog(@">>>>>>>NSURLMockingProtocol ENQUEUE request %@ serial %d", request, sRequestSerialNumber);
    }
    [request setValue:[NSString stringWithFormat:@"%d", sRequestSerialNumber++] forHTTPHeaderField:@"X-GREE-MOCK-SERIAL"];
  } else {
    [NSException raise:@"BOOM" format:@"URLRequests must be mutable"];
  }  
  [self swizzleEnqueueHTTPRequestOperation:operation]; //which is the original
}



@end

