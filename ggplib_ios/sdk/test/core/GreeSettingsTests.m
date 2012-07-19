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
#import "GreeTestHelpers.h"
#import "GreeSettings.h"

#pragma mark - GreeSettingsTests

SPEC_BEGIN(GreeSettingsTests)

describe(@"GreeSettings", ^{
  __block GreeSettings* settings = nil;  
  __block NSArray* defaults = nil;

  beforeAll(^{    
    defaults = [[NSArray alloc] initWithObjects:
      GreeSettingApplicationUrlScheme,
      GreeSettingInterfaceOrientation,
      GreeSettingEnableLogging,
      GreeSettingSnsAppName,
      GreeSettingUserThumbnailTimeoutInSeconds,
      nil];
  });
  
  afterAll(^{
    [defaults release];
    defaults = nil;

  });
  
  beforeEach(^{
    settings = [[GreeSettings alloc] init];
  });
  
  afterEach(^{
    [settings release];
    settings = nil;
  });
  
  it(@"should have a description", ^{
    NSString* expected = [NSString stringWithFormat:@"<GreeSettings:%p, settings:%@, finalized:NO>", settings, [settings performSelector:@selector(settings)]];
    [[[settings description] should] equal:expected];
  });

  it(@"should initialize with default settings", ^{
    for (NSString* key in defaults) {
      [[theValue([settings settingHasValue:key]) should] beYes];
    }
    
    [[theValue([[settings performSelector:@selector(settings)] count]) should] equal:theValue([defaults count])];
  });
  
  it(@"should support combining settings", ^{
    [[theValue([settings settingHasValue:GreeSettingApplicationUrlScheme]) should] beYes];
    [[theValue([settings settingHasValue:@"FAKESETTING"]) should] beNo];
    [settings applySettingDictionary:[NSDictionary dictionaryWithObject:@"SETTINGVALUE" forKey:@"FAKESETTING"]];
    [[theValue([settings settingHasValue:@"FAKESETTING"]) should] beYes];
  });

  it(@"should support retrieving a generic value", ^{
    [settings applySettingDictionary:[NSDictionary dictionaryWithObject:[NSNull null] forKey:@"FAKESETTING"]];
    [[[settings objectValueForSetting:@"FAKESETTING"] should] beKindOfClass:[NSNull class]];
  });

  it(@"should support retrieving an NSIntenger value", ^{
    [settings applySettingDictionary:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:12345] forKey:@"FAKESETTING"]];
    [[theValue([settings integerValueForSetting:@"FAKESETTING"]) should] equal:theValue(12345)];
  });

  it(@"should support retrieving an NSString value", ^{
    [settings applySettingDictionary:[NSDictionary dictionaryWithObject:@"SETTINGVALUE" forKey:@"FAKESETTING"]];
    [[[settings stringValueForSetting:@"FAKESETTING"] should] equal:@"SETTINGVALUE"];
  });

  it(@"should support retrieving a BOOL value", ^{
    [settings applySettingDictionary:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"FAKESETTING"]];
    [[theValue([settings boolValueForSetting:@"FAKESETTING"]) should] beYes];
  });

  it(@"should correctly load an internal settings file", ^{
    [settings applySettingDictionary:[NSDictionary dictionaryWithObject:@"testInternalSettings" forKey:GreeSettingInternalSettingsFilename]];
    [settings loadInternalSettingsFile];
    [[theValue([settings integerValueForSetting:@"fakeIntegerSetting"]) should] equal:theValue(123)];
    [[theValue([settings boolValueForSetting:@"fakeBoolSetting"]) should] beYes];
    [[[settings stringValueForSetting:@"fakeStringSetting"] should] equal:@"stringValue"];
    [[[settings objectValueForSetting:@"fakeObjectSetting"] should] beKindOfClass:[NSNull class]];
  });
  
  it(@"should not crash applying a nil dictionary", ^{
    [settings applySettingDictionary:nil];
    [[theValue(YES) should] beYes];
  });
  
  it(@"should not allow modification after finalize", ^{
    [settings finalizeSettings];
    [[theBlock(^{
      [settings applySettingDictionary:[NSDictionary dictionary]];
    }) shouldNot] raise];
    [[theBlock(^{
      [settings loadInternalSettingsFile];
    }) shouldNot] raise];
  });
  
  it(@"should compute dependent settings after finalize", ^{
    [[theValue([settings settingHasValue:GreeSettingServerUrlDomain]) should] beNo];
    [[theValue([settings settingHasValue:GreeSettingServerUrlPf]) should] beNo];
    [[theValue([settings settingHasValue:GreeSettingServerUrlOpen]) should] beNo];
    [[theValue([settings settingHasValue:GreeSettingServerUrlId]) should] beNo];
    [[theValue([settings settingHasValue:GreeSettingServerUrlOs]) should] beNo];

    [settings finalizeSettings];

    [[theValue([settings settingHasValue:GreeSettingServerUrlDomain]) should] beYes];
    [[theValue([settings settingHasValue:GreeSettingServerUrlPf]) should] beYes];
    [[theValue([settings settingHasValue:GreeSettingServerUrlOpen]) should] beYes];
    [[theValue([settings settingHasValue:GreeSettingServerUrlId]) should] beYes];
    [[theValue([settings settingHasValue:GreeSettingServerUrlOs]) should] beYes];
  });

  #define ValidateUrl(url, regex) \
  { \
    NSRange range = [url rangeOfString:regex options:NSRegularExpressionSearch]; \
    [[theValue(range.location) shouldNot] equal:theValue(NSNotFound)]; \
  } 

  it(@"should generate correct URLs in production", ^{
    [settings applySettingDictionary:[NSDictionary dictionaryWithObject:GreeDevelopmentModeProduction forKey:GreeSettingDevelopmentMode]];
    [settings finalizeSettings];
    
    [[[settings stringValueForSetting:GreeSettingServerUrlDomain] should] equal:@"gree.net"];

    NSString* regex = @"https://.*\\.gree\\.net";
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlId], regex);
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlPayment], regex);
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlOsWithSSL], regex);
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlHelp], regex);
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlOpen], regex);
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlSnsApi], regex);
    
    regex = @"http://.*\\.gree\\.net";
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlPf], regex);
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlOs], regex);
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlApps], regex);
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlGames], regex);
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlSns], regex);
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlNotice], regex);
  });

  it(@"should generate correct URLs in sandbox", ^{
    [settings applySettingDictionary:[NSDictionary dictionaryWithObject:GreeDevelopmentModeSandbox forKey:GreeSettingDevelopmentMode]];
    [settings finalizeSettings];
    
    [[[settings stringValueForSetting:GreeSettingServerUrlDomain] should] equal:@"gree.net"];

    NSString* regex = @"http://.*-sb\\.gree\\.net";
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlPf], regex);
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlOpen], regex);
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlId], regex);
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlOs], regex);
  });

  it(@"should generate correct URLs in staging", ^{
    [settings applySettingDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
      GreeDevelopmentModeStaging, GreeSettingDevelopmentMode,
      @"test", GreeSettingServerUrlSuffix,
      nil]];
    [settings finalizeSettings];
    
    [[[settings stringValueForSetting:GreeSettingServerUrlDomain] should] equal:@"gree.net"];
    
    NSString* regex = [NSString stringWithFormat:@"http://.*-%@\\.gree\\.net", [settings stringValueForSetting:GreeSettingServerUrlSuffix]];
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlPf], regex);
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlOpen], regex);
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlId], regex);
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlOs], regex);
  });

  it(@"should generate correct URLs in stagingSandbox", ^{
    [settings applySettingDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
      GreeDevelopmentModeStagingSandbox, GreeSettingDevelopmentMode,
      @"test", GreeSettingServerUrlSuffix,
      nil]];
    [settings finalizeSettings];
    
    [[[settings stringValueForSetting:GreeSettingServerUrlDomain] should] equal:@"gree.net"];
    
    NSString* regex = [NSString stringWithFormat:@"http://.*-sb%@\\.gree\\.net", [settings stringValueForSetting:GreeSettingServerUrlSuffix]];
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlPf], regex);
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlOpen], regex);
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlId], regex);
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlOs], regex);
  });
  
  it(@"should generate correct URLs in develop", ^{
    [settings applySettingDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
      GreeDevelopmentModeDevelop, GreeSettingDevelopmentMode,
      @"test", GreeSettingServerUrlSuffix,
      nil]];
    [settings finalizeSettings];
    
    [[[settings stringValueForSetting:GreeSettingServerUrlDomain] should] equal:@"dev.gree-dev.net"];
    
    NSString* regex = [NSString stringWithFormat:@"http://.*-dev-%@\\.dev\\.gree-dev\\.net", [settings stringValueForSetting:GreeSettingServerUrlSuffix]];
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlPf], regex);
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlOpen], regex);
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlId], regex);
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlOs], regex);
  });

  it(@"should generate correct URLs in developSandbox", ^{
    [settings applySettingDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
      GreeDevelopmentModeDevelopSandbox, GreeSettingDevelopmentMode,
      @"test", GreeSettingServerUrlSuffix,
      nil]];
    [settings finalizeSettings];
    
    [[[settings stringValueForSetting:GreeSettingServerUrlDomain] should] equal:@"dev.gree-dev.net"];
    
    NSString* regex = [NSString stringWithFormat:@"http://.*-sb-dev-%@\\.dev\\.gree-dev\\.net", [settings stringValueForSetting:GreeSettingServerUrlSuffix]];
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlPf], regex);
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlOpen], regex);
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlId], regex);
    ValidateUrl([settings stringValueForSetting:GreeSettingServerUrlOs], regex);
  });
  
  it(@"should have correct black list for remote settings", ^{
    NSArray* listOnSpec = [NSArray arrayWithObjects:
                           GreeSettingApplicationId,
                           GreeSettingConsumerKey,
                           GreeSettingConsumerSecret,
                           nil];
    NSArray* anArray = [GreeSettings blackListForRemoteConfig];
    [[anArray should] haveCountOf:[listOnSpec count]];
    [[anArray should] containObjectsInArray:listOnSpec];
  });
  
  it(@"should have correct array for need to support saving to non volatile area", ^{
    NSArray* listOnSpec = [NSArray arrayWithObjects:
                           GreeSettingNotificationEnabled,
                           GreeSettingEnableLogging,
                           GreeSettingWriteLogToFile,
                           GreeSettingLogLevel,
                           GreeSettingEnableLocalNotification,
                           nil];
    NSArray* anArray = [GreeSettings needToSupportSavingToNonVolatileAreaArray];
    [[anArray should] haveCountOf:[listOnSpec count]];
    [[anArray should] containObjectsInArray:listOnSpec];
  });
  
  it(@"should have correct black list for get_config command", ^{
    NSArray* listOnSpec = [NSArray arrayWithObjects:
                           GreeSettingConsumerKey,
                           GreeSettingConsumerSecret,
                           GreeSettingParametersForDeletingCookie,
                           nil];
    NSArray* anArray = [GreeSettings blackListForGetConfig];
    [[anArray should] haveCountOf:[listOnSpec count]];
    [[anArray should] containObjectsInArray:listOnSpec];
  });
  
  it(@"should have correct black list for set_config command", ^{
    NSArray* listOnSpec = [NSArray arrayWithObjects:
                           GreeSettingApplicationId,
                           GreeSettingConsumerKey,
                           GreeSettingConsumerSecret,
                           GreeSettingParametersForDeletingCookie,
                           nil];
    NSArray* anArray = [GreeSettings blackListForSetConfig];
    [[anArray should] haveCountOf:[listOnSpec count]];
    [[anArray should] containObjectsInArray:listOnSpec];
  });
  
  #undef ValidateUrl

});

SPEC_END
