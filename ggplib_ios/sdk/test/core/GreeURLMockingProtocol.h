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
#import <Foundation/Foundation.h>

const NSInteger GreeUrlMockMissingMockError;
const NSInteger GreeUrlMockFailedRequestBlock;
NSString* GreeUrlMockErrorDomain;

@interface MockedURLResponse : NSObject
@property (nonatomic, copy) NSData* data;
@property (nonatomic, copy) NSDictionary* headers;
@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, copy) NSError* error;
@property (nonatomic, assign) NSTimeInterval delay;
@property (nonatomic, copy) BOOL(^requestBlock)(NSURLRequest*request);
+ (id)getResponseWithHttpStatus:(NSInteger)statusCode;
+ (id)postResponseWithHttpStatus:(NSInteger)statusCode;
+ (id)putResponseWithHttpStatus:(NSInteger)statusCode;
+ (id)deleteResponseWithHttpStatus:(NSInteger)statusCode;
@end

/*
 Mocking an HTTP request requires the following steps:
 1) call [GreeURLMockingProtocol register] to allow the HTTP values to be mocked 
 2) When the AFHTTPClient is created, use httpClientPrefix to set the baseURL:
        GreeHTTPClient* client = [[GreeHTTPClient alloc ] initWithBaseURL:[NSURL URLWithString:[GreeURLMockingProtocol httpClientPrefix]]];
 3) create a MockedURLResponse object and give it any desired properties
        the object in data will be returned as is
        the headers will be added after the default header (currently only text/json Content-Type)
        statusCode defaults to 200 so the call will be successful
        if error is defined, then failure will be called with that error
        delay defaults to 0, use this sparingly to avoid long test times
 4) call your HTTP method
 5) call [GreeURLMockingProtocol unregister] when finished
 
 You can configure the return value from the HTTP response by setting properties in the mock object
 To make it easier to see what mocks match with each request, you can use setDebugMode:YES, this resets at the end of each test.
 */

    

@interface GreeURLMockingProtocol : NSURLProtocol
+ (void)addMock:(MockedURLResponse*)mock;
+ (void)register;
+ (void)unregister;
+ (NSString*) httpClientPrefix;
+ (void)setDebugMode:(BOOL)debugMode;
@end
