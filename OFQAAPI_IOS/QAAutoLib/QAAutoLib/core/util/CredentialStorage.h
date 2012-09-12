//
//  CredentialStorage.h
//  OFQAAPI
//
//  Created by lei zhu on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CredentialStorage;

extern NSString* const CredentialStoredAppId;
extern NSString* const CredentialStoredAppKey;
extern NSString* const CredentialStoredAppSecret;
extern NSString* const CredentialStoredUserid;
extern NSString* const CredentialStoredUsername;
extern NSString* const CredentialStoredPassword;
extern NSString* const CredentialStoredOauthKey;
extern NSString* const CredentialStoredOauthSecret;

@interface CredentialStorage : NSObject

- (id) storeCredentialByData:(NSData*) rawData;

+ (id) initializeCredentialStorageWithAppid:(NSString*) appid 
                                    andData:(NSData*) rawData;
+ (CredentialStorage*) sharedInstance;

- (id) getValueForKey:(NSString*) key;

@end
