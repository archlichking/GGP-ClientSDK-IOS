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
#import "GreeJSRecordAnalyticsDataCommand.h"
#import "GreePlatform.h"
#import "GreeSettings.h"

#pragma mark - GreeJSRecordAnalyticsDataCommandTest

SPEC_BEGIN(GreeJSRecordAnalyticsDataCommandTest)

describe(@"GreeJSRecordAnalyticsDataCommand",^{
  __block id environment;
  __block id platform;
  
  beforeEach(^{  
    platform = [GreePlatform nullMockAsSharedInstance];
        
    GreeJSHandler* handler = [GreeJSHandler nullMock];    
    environment = [KWMock mockForProtocol:@protocol(GreeJSCommandEnvironment)];
    [environment stub:@selector(handler) andReturn:handler];
  });
  
  afterEach(^{
    environment = nil;
    platform = nil;
  });
  
  it(@"should record an analytics event", ^{
    [[platform should] receive:@selector(addAnalyticsEvent:)];
    
    GreeJSRecordAnalyticsDataCommand *command = [[GreeJSRecordAnalyticsDataCommand alloc] init];
    command.environment = environment;
    [command execute:[NSDictionary dictionaryWithObjectsAndKeys:
      @"pg", @"tp",
      @"xxx", @"nm",
      [NSDictionary dictionaryWithObjectsAndKeys:@"val_1", @"key_1", @"val_2", @"key_2", nil], @"pr",
      @"yyy", @"fr",
      nil]]; 
    [command release];
  });
  
  it(@"should callback the handler", ^{
    GreeJSHandler* handler = [environment handler];
    [[handler should] receive:@selector(callback:params:)];
        
    GreeJSRecordAnalyticsDataCommand *command = [[GreeJSRecordAnalyticsDataCommand alloc] init];
    command.environment = environment;
    [command execute:[NSDictionary dictionaryWithObjectsAndKeys:
      @"pg", @"tp",
      @"xxx", @"nm",
      [NSDictionary dictionaryWithObjectsAndKeys:@"val_1", @"key_1", @"val_2", @"key_2", nil], @"pr",
      @"yyy", @"fr",
      nil]];     [command release];
  });

  it(@"should have a description", ^{
    GreeJSCommand *command = [[GreeJSRecordAnalyticsDataCommand alloc] init];
  
    NSString* checkString = [NSString stringWithFormat:@"<GreeJSRecordAnalyticsDataCommand:%p>",
      command];
      
    [[[command description] should] equal:checkString]; 
    [command release];
  });
  
  
  it(@"should have a name", ^{      
    [[[GreeJSRecordAnalyticsDataCommand name] should] equal:@"record_analytics_data"]; 
  });
});

SPEC_END
