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
#import "GreeTestHelpers.h"
#import "GreeJSFlushAnalyticsDataCommand.h"
#import "GreePlatform.h"
#import "GreeSettings.h"

#pragma mark - GreeJSFlushAnalyticsDataCommandTest

SPEC_BEGIN(GreeJSFlushAnalyticsDataCommandTest)

describe(@"GreeJSFlushAnalyticsDataCommand",^{
  it(@"should have a description", ^{
    GreeJSCommand *command = [[GreeJSFlushAnalyticsDataCommand alloc] init];
  
    NSString* checkString = [NSString stringWithFormat:@"<GreeJSFlushAnalyticsDataCommand:%p>",
      command];
      
    [[[command description] should] equal:checkString]; 
    [command release];
  });
  
  it(@"should have a name", ^{      
    [[[GreeJSFlushAnalyticsDataCommand name] should] equal:@"flush_analytics_data"]; 
  });
  
  context(@"when executing", ^{
    it(@"should callback with an error message if there was an error", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"callback", @"callback",
        nil];
    
      GreeJSFlushAnalyticsDataCommand *command = [[GreeJSFlushAnalyticsDataCommand alloc] init];
      
      KWMock *platform = [KWMock nullMockForClass:[GreePlatform class]];
      KWCaptureSpy *blockSpy = [platform captureArgument:@selector(flushAnalyticsQueueWithBlock:) atIndex:0];
      [[GreePlatform stubAndReturn:platform] sharedInstance];

      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:@"callback"
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithBool:NO], @"result",
          @"mockDescription", @"error",
          nil]];
          
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:handler] handler];
      
      command.environment = environment;
      [command execute:parameters];
      
      void (^block)(NSError *error) = blockSpy.argument;
      
      NSError *error = [NSError
        errorWithDomain:@"mockDomain"
        code:1
        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
          @"mockDescription", NSLocalizedDescriptionKey,
          nil]];
      
      block(error);
      [command release];
    });
    
    it(@"should callback with YES as the result if there was no error", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"callback", @"callback",
        nil];
    
      GreeJSFlushAnalyticsDataCommand *command = [[GreeJSFlushAnalyticsDataCommand alloc] init];
      
      KWMock *platform = [KWMock nullMockForClass:[GreePlatform class]];
      KWCaptureSpy *blockSpy = [platform captureArgument:@selector(flushAnalyticsQueueWithBlock:) atIndex:0];
      [[GreePlatform stubAndReturn:platform] sharedInstance];

      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:@"callback"
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithBool:YES], @"result",
          nil]];
          
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:handler] handler];
      
      command.environment = environment;
      [command execute:parameters];
      
      void (^block)(NSError *error) = blockSpy.argument;
      
      block(nil);
      [command release];
    });
  });
});

SPEC_END
