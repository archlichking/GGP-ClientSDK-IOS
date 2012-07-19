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
#import "GreeAnalyticsHeader.h"

#import "NSDateFormatter+GreeAdditions.h"

static NSString* mockHardwareVersion = @"mockHardware";
static NSString* mockBundleVersion = @"mockBundle";
static NSString* mockSdkVersion = @"mockSdkVersion";
static NSString* mockOsVersion = @"mockOsVersion";
static NSString* mockLocaleCountryCode = @"mockCountryCode";

SPEC_BEGIN(GreeAnalyticsHeaderTests)
describe(@"GreeAnalyticsHeader", ^{
  it(@"should initialize with the designated initializer", ^{  
    GreeAnalyticsHeader* header = [[GreeAnalyticsHeader alloc] initWithHardwareVersion:mockHardwareVersion
      bundleVersion:mockBundleVersion
      sdkVersion:mockSdkVersion
      osVersion:mockOsVersion
      localCountryCode:mockLocaleCountryCode];
                                  
    [[header.hardwareVersion should] equal:mockHardwareVersion];
    [[header.bundleVersion should] equal:mockBundleVersion];
    [[header.sdkVersion should] equal:mockSdkVersion];
    [[header.osVersion should] equal:mockOsVersion];
    [[header.localeCountryCode should] equal:mockLocaleCountryCode];
    [header release];
  });

  it(@"should deserialize", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                mockHardwareVersion, @"hv",
                                mockBundleVersion, @"bv",
                                mockSdkVersion, @"sv",
                                mockOsVersion, @"ov",
                                mockLocaleCountryCode, @"lc",
                                nil];
    
    GreeSerializer* serializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeAnalyticsHeader* header = [[GreeAnalyticsHeader alloc] initWithGreeSerializer:serializer];
    [[header.hardwareVersion should] equal:mockHardwareVersion];
    [[header.bundleVersion should] equal:mockBundleVersion];
    [[header.sdkVersion should] equal:mockSdkVersion];
    [[header.osVersion should] equal:mockOsVersion];
    [[header.localeCountryCode should] equal:mockLocaleCountryCode];
    [header release];
  });
  
  it(@"should serialize", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                mockHardwareVersion, @"hv",
                                mockBundleVersion, @"bv",
                                mockSdkVersion, @"sv",
                                mockOsVersion, @"ov",
                                mockLocaleCountryCode, @"lc",
                                nil];
                                   
    GreeSerializer* deserializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeAnalyticsHeader* header = [[GreeAnalyticsHeader alloc] initWithGreeSerializer:deserializer];
    GreeSerializer* serializer = [GreeSerializer serializer];
    [header serializeWithGreeSerializer:serializer];
    [[serializer.rootDictionary should] equal:serialized];
    [header release];
  });
  
  it(@"should show description", ^{
    GreeAnalyticsHeader* header = [[GreeAnalyticsHeader alloc] initWithHardwareVersion:mockHardwareVersion
      bundleVersion:mockBundleVersion
      sdkVersion:mockSdkVersion
      osVersion:mockOsVersion
      localCountryCode:mockLocaleCountryCode];
      
    NSString* checkString = [NSString stringWithFormat:@"<GreeAnalyticsHeader:%p, hardwareVersion:%@, bundleVersion:%@, sdkVersion:%@, osVersion:%@, localeCountryCode:%@>",
      header,
      mockHardwareVersion,
      mockBundleVersion,
      mockSdkVersion,
      mockOsVersion,
      mockLocaleCountryCode];
      
    [[[header description] should] equal:checkString];
    [header release]; 
  });
});

SPEC_END

