//
//  CredentialStorage.m
//  OFQAAPI
//
//  Created by lei zhu on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CredentialStorage.h"
#import "SBJson.h"

static CredentialStorage* sSharedSDKInstance = nil;
static NSString* sAppid = nil;

NSString* const CredentialStoredAppId = @"appid";
NSString* const CredentialStoredAppKey = @"appKey";
NSString* const CredentialStoredAppSecret = @"appSecret";
NSString* const CredentialStoredUserid = @"userid";
NSString* const CredentialStoredUsername = @"username";
NSString* const CredentialStoredPassword = @"password";
NSString* const CredentialStoredOauthKey = @"oauthKey";
NSString* const CredentialStoredOauthSecret = @"oauthSecret";

@interface CredentialStorage ()
@property (nonatomic, retain) NSString* cAppid;
@property (nonatomic, retain) NSString* cAppKey;
@property (nonatomic, retain) NSString* cAppSecret;
@property (nonatomic, retain) NSDictionary* cUserCredentials;
@end

@implementation CredentialStorage
@synthesize cAppid = _cAppid;
@synthesize cAppKey = _cAppKey;
@synthesize cAppSecret = _cAppSecret;
@synthesize cUserCredentials = _cUserCredentials;


- (id) storeCredentialByData:(NSData*) rawData{
    SBJsonParser* sb = [[[SBJsonParser alloc] init] autorelease];
    NSDictionary* tempCredentials = [sb objectWithData:rawData];
    
    
    // need to restore app credentials
    _cAppid = [tempCredentials objectForKey:CredentialStoredAppId];
    _cAppKey = [tempCredentials objectForKey:CredentialStoredAppKey];
    _cAppSecret = [tempCredentials objectForKey:CredentialStoredAppSecret];
    
        
    NSMutableDictionary* tempCredDic = [[[NSMutableDictionary alloc] init] autorelease];
    
    NSArray* tempCredArray = [tempCredentials valueForKey:@"credentials"];
    for (int i = 0; i<tempCredArray.count; i++) {
        
        NSDictionary* tempSingleCredDic = [tempCredArray objectAtIndex:i];
        [tempCredDic setValue:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:
                               [tempSingleCredDic valueForKey:CredentialStoredUserid], CredentialStoredUserid,
                               [tempSingleCredDic valueForKey:CredentialStoredOauthKey], CredentialStoredOauthKey,
                               [tempSingleCredDic valueForKey:CredentialStoredOauthSecret], CredentialStoredOauthSecret,
                               nil] autorelease]
                        forKey:[NSString stringWithFormat:@"%@&%@", 
                                [tempSingleCredDic valueForKey:CredentialStoredUsername], 
                                [tempSingleCredDic valueForKey:CredentialStoredPassword]] ];
    }
    
    _cUserCredentials = [[NSDictionary alloc] initWithDictionary:tempCredDic];
    
    return self;
}

+ (id) initializeCredentialStorageWithAppid:(NSString*) appid 
                                    andData:(NSData*) rawData{
    if(!sAppid || ![sAppid isEqualToString:appid]){
        sSharedSDKInstance = [[CredentialStorage alloc] storeCredentialByData:rawData];
    }
    return sSharedSDKInstance;
}

+ (CredentialStorage*) sharedInstance{
    return sSharedSDKInstance;
}

- (id) getValueForKey:(NSString*) key{
    if([key isEqualToString:CredentialStoredAppId]){
        return _cAppid;
    }else if([key isEqualToString:CredentialStoredAppKey]){
        return _cAppKey;
    }else if([key isEqualToString:CredentialStoredAppSecret]){
        return _cAppSecret;
    }else{
        return [_cUserCredentials valueForKey:key];
    }
}
@end

