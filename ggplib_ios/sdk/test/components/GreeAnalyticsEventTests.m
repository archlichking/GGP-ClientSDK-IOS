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
#import "GreeAnalyticsEvent.h"

#import "NSDateFormatter+GreeAdditions.h"

static NSString* mockType = @"tp";
static NSString* mockName = @"xxx";
static NSString* mockFrom = @"yyy";
static NSString* mockIssuedTime = @"2012-01-02 02:34:56";

#define mockParameters [NSDictionary dictionaryWithObjectsAndKeys:@"zzz", @"mockData",nil]

@interface GreeAnalyticsEvent (ExposePrivateAPIs)
- (id)initWithType:(NSString *)type
  name:(NSString *)name
  from:(NSString *)from
  issuedTime:(NSDate*)issuedTime
  parameters:(NSDictionary *)parameters;
@end

SPEC_BEGIN(GreeAnalyticsEventTests)
describe(@"GreeAnalyticsEvent", ^{
  it(@"should initialize with the designated initializer", ^{
    NSDate *now = [NSDate date];
  
    GreeAnalyticsEvent* event = [[GreeAnalyticsEvent alloc] initWithType:mockType
                                  name:mockName
                                  from:mockFrom
                                  issuedTime:now
                                  parameters:mockParameters];
                                  
    [[event.type should] equal:mockType];
    [[event.name should] equal:mockName];
    [[event.from should] equal:mockFrom];
    [[event.issuedTime should] equal:now];
    [[event.parameters should] equal:mockParameters];
    [event release];
  });
  
  it(@"should initialize with convenience initializer", ^{  
    GreeAnalyticsEvent* event = [GreeAnalyticsEvent eventWithType:mockType name:mockName from:mockFrom parameters:mockParameters];
                                  
    [[event.type should] equal:mockType];
    [[event.name should] equal:mockName];
    [[event.from should] equal:mockFrom];
    [[theValue(fabs([event.issuedTime timeIntervalSinceNow])) should] beLessThan:theValue(1.0)];
    [[event.parameters should] equal:mockParameters];
  });

  it(@"should initialize a polling event with a convenience initializer", ^{
    GreeAnalyticsEvent* event = [GreeAnalyticsEvent pollingEvent];

    [[event.type should] equal:@"act"];
    [[event.name should] equal:@"active"];
    [[event.from should] equal:@""];
    [[theValue(fabs([event.issuedTime timeIntervalSinceNow])) should] beLessThan:theValue(1.0)];
    [event.parameters shouldBeNil];
  });

  it(@"should deserialize", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                mockType, @"tp",
                                mockName, @"nm",
                                mockFrom, @"fr",
                                mockIssuedTime, @"tm",
                                mockParameters, @"pr",
                                nil];
    
    GreeSerializer* serializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeAnalyticsEvent* event = [[GreeAnalyticsEvent alloc] initWithGreeSerializer:serializer];
    [[event.type should] equal:mockType];
    [[event.name should] equal:mockName];
    [[event.from should] equal:mockFrom];
    [[event.issuedTime should] equal:[[NSDateFormatter greeUTCDateFormatter] dateFromString:mockIssuedTime]];
    [[event.parameters should] equal:mockParameters];
    [event release];
  });
  
  it(@"should serialize", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                mockType, @"tp",
                                mockName, @"nm",
                                mockFrom, @"fr",
                                mockIssuedTime, @"tm",
                                mockParameters, @"pr",
                                nil];
                                   
    GreeSerializer* deserializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeAnalyticsEvent* event = [[GreeAnalyticsEvent alloc] initWithGreeSerializer:deserializer];
    GreeSerializer* serializer = [GreeSerializer serializer];
    [event serializeWithGreeSerializer:serializer];
    [[serializer.rootDictionary should] equal:serialized];
  });
  
  it(@"should show description", ^{
    GreeAnalyticsEvent *event = [GreeAnalyticsEvent eventWithType:mockType name:mockName from:mockFrom parameters:mockParameters];

    NSString* checkString = [NSString stringWithFormat:@"<GreeAnalyticsEvent:%p, type:%@, name:%@, from:%@, issuedTime:%@, parameters:%@>",
      event,
      mockType,
      mockName,
      mockFrom,
      [[NSDateFormatter greeUTCDateFormatter] stringFromDate:event.issuedTime],
      [mockParameters description]];
      
    [[[event description] should] equal:checkString]; 
  });
});

SPEC_END

