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
#import "GreeAnalyticsHeader.h"
#import "GreeAnalyticsChunk.h"
#import "NSDateFormatter+GreeAdditions.h"

@interface GreeAnalyticsChunk (CategoryToRemoveComplierWarnings)
-(id)item;
@end

static NSString* mockType = @"tp";
static NSString* mockName = @"xxx";
static NSString* mockFrom = @"yyy";
static NSString* mockIssuedTime = @"2012-01-02 02:34:56";

#define mockParameters [NSDictionary dictionaryWithObjectsAndKeys:@"zzz", @"mockData",nil]

static NSString* mockHardwareVersion = @"mockHardware";
static NSString* mockBundleVersion = @"mockBundle";
static NSString* mockSdkVersion = @"mockSdkVersion";
static NSString* mockOsVersion = @"mockOsVersion";
static NSString* mockLocaleCountryCode = @"mockCountryCode";

#define mockHeaderDictionary [NSDictionary dictionaryWithObjectsAndKeys: \
                                       mockHardwareVersion, @"hv", \
                                       mockBundleVersion, @"bv", \
                                       mockSdkVersion, @"sv", \
                                       mockOsVersion, @"ov", \
                                       mockLocaleCountryCode, @"lc", \
                                       nil]
                                       
#define mockEventDictionary [NSDictionary dictionaryWithObjectsAndKeys: \
                                      mockType, @"tp", \
                                      mockName, @"nm", \
                                      mockFrom, @"fr", \
                                      mockIssuedTime, @"tm", \
                                      mockParameters, @"pr", \
                                      nil]


SPEC_BEGIN(GreeAnalyticsChunkTests)
describe(@"GreeAnalyticsChunk", ^{
  it(@"should initialize with the designated initializer", ^{  
    GreeAnalyticsEvent* event1 = [GreeAnalyticsEvent eventWithType:mockType name:mockName from:mockFrom parameters:mockParameters];
    GreeAnalyticsEvent* event2 = [GreeAnalyticsEvent eventWithType:mockType name:mockName from:mockFrom parameters:mockParameters];
    GreeAnalyticsHeader* header = [[GreeAnalyticsHeader alloc] initWithHardwareVersion:mockHardwareVersion
      bundleVersion:mockBundleVersion
      sdkVersion:mockSdkVersion
      osVersion:mockOsVersion
      localCountryCode:mockLocaleCountryCode];
      
    GreeAnalyticsChunk *chunk = [[GreeAnalyticsChunk alloc] initWithHeader:header body:[NSArray arrayWithObjects:event1, event2, nil]];
                                                                
    [[chunk.header should] equal:header];
    [[[chunk.body objectAtIndex:0] should] equal:event1];
    [[[chunk.body objectAtIndex:1] should] equal:event2];

    [header release];
    [chunk release];
  });

  it(@"should deserialize", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                 mockHeaderDictionary, @"h",
                                 [NSArray arrayWithObject:mockEventDictionary], @"b",
                                 nil];
    
    GreeSerializer* serializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeAnalyticsChunk* chunk = [[GreeAnalyticsChunk alloc] initWithGreeSerializer:serializer];
    
    [[chunk.header.hardwareVersion should] equal:mockHardwareVersion];
    [[chunk.header.bundleVersion should] equal:mockBundleVersion];
    [[chunk.header.sdkVersion should] equal:mockSdkVersion];
    [[chunk.header.osVersion should] equal:mockOsVersion];
    [[chunk.header.localeCountryCode should] equal:mockLocaleCountryCode];
    
    [[[chunk.body should] have:1] item];

    GreeAnalyticsEvent *event = [chunk.body objectAtIndex:0];
    [[event.type should] equal:mockType];
    [[event.name should] equal:mockName];
    [[event.from should] equal:mockFrom];
    [[event.issuedTime should] equal:[[NSDateFormatter greeUTCDateFormatter] dateFromString:mockIssuedTime]];
    [[event.parameters should] equal:mockParameters];
    
    [chunk release];
  });
  
  it(@"should serialize", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                 mockHeaderDictionary, @"h",
                                 [NSArray arrayWithObject:mockEventDictionary], @"b",
                                 nil];
                                   
    GreeSerializer* deserializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeAnalyticsChunk* chunk = [[GreeAnalyticsChunk alloc] initWithGreeSerializer:deserializer];
    GreeSerializer* serializer = [GreeSerializer serializer];
    [chunk serializeWithGreeSerializer:serializer];
    [[serializer.rootDictionary should] equal:serialized];
    [chunk release];
  });
  
  it(@"should show description", ^{
    GreeAnalyticsEvent* event1 = [GreeAnalyticsEvent eventWithType:mockType name:mockName from:mockFrom parameters:mockParameters];
    GreeAnalyticsEvent* event2 = [GreeAnalyticsEvent eventWithType:mockType name:mockName from:mockFrom parameters:mockParameters];
    GreeAnalyticsHeader* header = [[GreeAnalyticsHeader alloc] initWithHardwareVersion:mockHardwareVersion
      bundleVersion:mockBundleVersion
      sdkVersion:mockSdkVersion
      osVersion:mockOsVersion
      localCountryCode:mockLocaleCountryCode];
      
    GreeAnalyticsChunk *chunk = [[GreeAnalyticsChunk alloc] initWithHeader:header body:[NSArray arrayWithObjects:event1, event2, nil]];
      
    NSString* checkString = [NSString stringWithFormat:@"<GreeAnalyticsChunk:%p, header:{ %@ }, bodyItemsCount:2>",
      chunk,
      [header description]];
      
    [[[chunk description] should] equal:checkString];
    [header release]; 
    [chunk release];
  });
});

SPEC_END

