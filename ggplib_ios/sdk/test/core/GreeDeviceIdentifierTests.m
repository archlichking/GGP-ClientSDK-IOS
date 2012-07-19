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

#import <Security/Security.h>
#import "Kiwi.h"
#import "GreeDeviceIdentifier.h"

@interface MPOAuth : NSObject
+ (NSMutableDictionary*) _getKeychainFindQuery:(NSString*)inName;
+ (void)addToKeychainUsingName:(NSString *)inName andValue:(NSString *)inValue;
+ (void)removeValueFromKeychainUsingName:(NSString *)inName;
@end

@implementation MPOAuth
+ (NSMutableDictionary*) _getKeychainFindQuery:(NSString*)inName
{
	NSString *serverName = @"api.openfeint.com";
	NSString *securityDomain = @"api.openfeint.com";
	NSMutableDictionary *findQuery = [NSMutableDictionary dictionaryWithObjectsAndKeys:	
                                    (id)kSecClassInternetPassword,					kSecClass,
                                    securityDomain,									kSecAttrSecurityDomain,
                                    serverName,										kSecAttrServer,
                                    inName,											kSecAttrAccount,
                                    kSecAttrAuthenticationTypeDefault,				kSecAttrAuthenticationType,
                                    [NSNumber numberWithUnsignedLongLong:'oaut'],	kSecAttrType,
                                    nil
                                    ];

	return findQuery;
}

+ (void)addToKeychainUsingName:(NSString *)inName andValue:(NSString *)inValue
{
	[self removeValueFromKeychainUsingName:inName];
  
	if(inValue == nil)
    {
		return;
    }
	
	NSMutableDictionary* addQuery = [self _getKeychainFindQuery:inName];
  [addQuery setObject:[inValue dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecValueData];	
	int statusCode = SecItemAdd((CFDictionaryRef)addQuery, NULL);
	if (statusCode != noErr)
		NSLog(@"Failed adding %@ to keychain", inName);
}

+ (void)removeValueFromKeychainUsingName:(NSString *)inName
{	
	NSString *serverName = @"api.openfeint.com";
	NSString *securityDomain = @"api.openfeint.com";
	NSMutableDictionary *searchDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:(id)kSecClassInternetPassword, (id)kSecClass,
                                           securityDomain, (id)kSecAttrSecurityDomain,
                                           serverName, (id)kSecAttrServer,
                                           inName, (id)kSecAttrAccount,
                                           nil];
	SecItemDelete((CFDictionaryRef)searchDictionary);
}

@end

@interface OFUser : NSObject<NSCoding>
@property (nonatomic, retain) NSString* userId;
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;
@end

@implementation OFUser
@synthesize userId;
- (id)initWithCoder:(NSCoder *)aDecoder
{
  self = [super init];
  if (self != nil) {
    userId = [[aDecoder decodeObjectForKey:@"resourceId"] retain];
  }  
  return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:userId forKey:@"resourceId"];
}
- (void)dealloc
{
  [userId release]; userId = nil;
  [super dealloc];
}
@end

@interface OpenFeint : NSObject
+ (void)setClientApplicationId:(NSString*)clientApplicationId;
+ (NSString*)clientApplicationId;
+ (void)setLocalUser:(id)user;
+ (id)localUser;
@end

@implementation OpenFeint

+ (void)setClientApplicationId:(NSString*)clientApplicationId
{
  [[NSUserDefaults standardUserDefaults] setObject:clientApplicationId forKey:@"OpenFeintSettingClientApplicationId"];
}

+ (NSString*)clientApplicationId
{
  return [[NSUserDefaults standardUserDefaults] stringForKey:@"OpenFeintSettingClientApplicationId"];
}

+ (void)setLocalUser:(id)user
{
	NSData* encoded = [NSKeyedArchiver archivedDataWithRootObject:user];
	[[NSUserDefaults standardUserDefaults] setObject:encoded forKey:@"OpenFeintUserOptionLocalUser"];
}

+ (id)localUser
{
  NSData* encoded = [[NSUserDefaults standardUserDefaults] objectForKey:@"OpenFeintUserOptionLocalUser"];
  id localUser = [NSKeyedUnarchiver unarchiveObjectWithData:encoded];
	return localUser;
}

@end


SPEC_BEGIN(GreeDeviceIdentifierSpec)

describe(@"GreeDeviceIdentifierSpec", ^{

  beforeEach(^{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"OpenFeintUserOptionLocalUser"];
  });
  
  it(@"should get UDID", ^{
    [[GreeDeviceIdentifier uniqueDeviceId] shouldNotBeNil];
  });
  
  it(@"should get mac address", ^{
    [[GreeDeviceIdentifier macAddress] shouldNotBeNil];
  });
  
  it(@"should not get OF access token from non OF app migration", ^{
    [[GreeDeviceIdentifier ofAccessToken] shouldBeNil];
  });
  
  it(@"should not get OF user id from non OF app migration", ^{
    [[GreeDeviceIdentifier ofUserId] shouldBeNil];
  });
  
  it(@"should not get OF application id from non OF app migration", ^{
    [[GreeDeviceIdentifier ofApplicationId] shouldBeNil];
  });
  
  it(@"should get OF access token from OF app migration", ^{
    [MPOAuth addToKeychainUsingName:@"oauth_token_access" andValue:@"xxxxx"];
    NSString* accessToken = [GreeDeviceIdentifier ofAccessToken];
    [accessToken shouldNotBeNil];
    [[accessToken should] equal:@"xxxxx"];
    [MPOAuth removeValueFromKeychainUsingName:@"oauth_token_access"];
  });
  
  it(@"should remove OF access token from OF app migration", ^{
    [MPOAuth addToKeychainUsingName:@"oauth_token_access" andValue:@"xxxxx"];
    NSString* accessToken = [GreeDeviceIdentifier ofAccessToken];
    [[accessToken should] equal:@"xxxxx"];
    [GreeDeviceIdentifier removeOfAccessToken];
    [[GreeDeviceIdentifier ofAccessToken] shouldBeNil];
  });
  
  it(@"should get OF user id from OF app migration", ^{
    OFUser* ofUser = [[OFUser alloc] init];
    ofUser.userId = @"12345";
    [ofUser shouldNotBeNil];
    [OpenFeint setLocalUser:ofUser];
    NSString* userId = [GreeDeviceIdentifier ofUserId];
    [userId shouldNotBeNil];
    [[userId should] equal:@"12345"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"OpenFeintUserOptionLocalUser"];
  });
  
  it(@"should remove OF user id from OF app migration", ^{
    OFUser* ofUser = [[OFUser alloc] init];
    ofUser.userId = @"12345";
    [ofUser shouldNotBeNil];
    [OpenFeint setLocalUser:ofUser];
    [GreeDeviceIdentifier removeOfUserId];
    [[GreeDeviceIdentifier ofUserId] shouldBeNil];
  });
  
  it(@"should get OF application id from OF app migration", ^{
    [OpenFeint setClientApplicationId:@"12345"];
    NSString* applicationId = [GreeDeviceIdentifier ofApplicationId];
    [applicationId shouldNotBeNil];
    [[applicationId should] equal:@"12345"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"OpenFeintUserOptionLocalUser"];
  });
  
  it(@"should remove OF application id from OF app migration", ^{
    [OpenFeint setClientApplicationId:@"12345"];
    NSString* applicationId = [GreeDeviceIdentifier ofApplicationId];
    [[applicationId should] equal:@"12345"];
    [GreeDeviceIdentifier removeOfApplicationId];
    [[GreeDeviceIdentifier ofApplicationId] shouldBeNil];
  });
  
});

SPEC_END
