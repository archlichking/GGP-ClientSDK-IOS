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
#import "GreeJSSnsApiRequestCommand.h"
#import "GreePlatform+Internal.h"
#import "GreeSettings.h"
#import "GreeHTTPClient.h"
#import "GreeURLMockingProtocol.h"
#import "AFHTTPRequestOperation.h"
#import "GreeMatchers.h"
#import "GreeTestHelpers.h"

SPEC_BEGIN(GreeJSSnsApiRequestCommandTest)

describe(@"GreeJSSnsApiRequestCommand",^{  
  registerMatchers(@"Gree");
  
  it(@"should have a name", ^{
    [[[GreeJSSnsApiRequestCommand name] should] equal:@"snsapi_request"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSSnsApiRequestCommand *command = [[GreeJSSnsApiRequestCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSSnsApiRequestCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should call back with success if the operation is a success", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"success", @"success", nil];
    
      GreeJSSnsApiRequestCommand *command = [[GreeJSSnsApiRequestCommand alloc] init];
      
      KWMock *client = [KWMock nullMockForClass:[GreeHTTPClient class]];
      KWCaptureSpy *successSpy = [client captureArgument:@selector(performRequest:parameters:success:failure:) atIndex:2];
      
      GreePlatform* platform = [GreePlatform nullMockAsSharedInstance];
      [[platform stubAndReturn:client] httpClient];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:@"success"
        params:nil];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:handler] handler];
      
      command.environment = environment;
      [command execute:parameters];
      
      void(^success)(GreeAFHTTPRequestOperation* operation, id responseObject) = successSpy.argument;
      success(nil, nil);
      
      [command release];
    });
    
    it(@"should call back with failure if the operation is a failure", ^{
          NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"failure", @"failure", nil];
    
      GreeJSSnsApiRequestCommand *command = [[GreeJSSnsApiRequestCommand alloc] init];
      
      KWMock *client = [KWMock nullMockForClass:[GreeHTTPClient class]];
      KWCaptureSpy *failureSpy = [client captureArgument:@selector(performRequest:parameters:success:failure:) atIndex:3];
      
      GreePlatform* platform = [GreePlatform nullMockAsSharedInstance];
      [[platform stubAndReturn:client] httpClient];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:@"failure"
        arguments:[NSArray arrayWithObjects:
          @"400", @"mockDescription", nil]];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:handler] handler];
      
      command.environment = environment;
      [command execute:parameters];
      
      void(^failure)(GreeAFHTTPRequestOperation* operation, id responseObject) = failureSpy.argument;
      
      NSURLResponse *response = [NSURLResponse nullMock];
      [[response stubAndReturn:theValue(400)] statusCode];
      
      GreeAFHTTPRequestOperation *operation = [GreeAFHTTPRequestOperation nullMock];
      [[operation stubAndReturn:response] response];
      
      NSError *error = [NSError
        errorWithDomain:@"mockDomain"
        code:1
        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
          @"mockDescription", NSLocalizedDescriptionKey,
          nil]];
      
      failure(operation, error);
      
      [command release];
    });    
  });
});

SPEC_END
