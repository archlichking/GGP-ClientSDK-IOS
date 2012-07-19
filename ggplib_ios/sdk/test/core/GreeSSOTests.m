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
#import "GreeSSO.h"
#import "GreePlatform+Internal.h"
#import "GreeHTTPClient.h"
#import "GreeSettings.h"
#import "GreeAES128.h"
#import "NSHTTPCookieStorage+GreeAdditions.h"
#import "NSData+GreeAdditions.h"
#import "NSString+GreeAdditions.h"
#import "GreeTestHelpers.h"

SPEC_BEGIN(GreeSSOSpec)

describe(@"GreeSSOSpec", ^{
  
  beforeEach(^{
    GreeSettings* settings = [[[GreeSettings alloc] init] autorelease];
    [settings applySettingDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
      GreeDevelopmentModeDevelop, GreeSettingDevelopmentMode,
      @"test", GreeSettingServerUrlSuffix,
      @"1234", GreeSettingApplicationId,
      nil]];
    [settings finalizeSettings];
    
    GreePlatform* mockedSdk = [GreePlatform nullMockAsSharedInstance];
    [mockedSdk stub:@selector(settings) andReturn:settings];
    [mockedSdk stub:@selector(httpClient) andReturn:[GreeHTTPClient nullMock]];
  });
  
  context(@"as sso server", ^{

    __block GreeSSO* ssoServer = nil;
    
    beforeAll(^{
      NSString* seedKey = [[[[[GreeAES128 alloc] init] autorelease] generateKey] greeFormatInHex];
      ssoServer = [[GreeSSO alloc] initAsServerWithSeedKey:seedKey clientApplicationId:@"5678"]; 
    });
    
    afterAll(^{
      [ssoServer release];
    });
    
    it(@"should make acceptPageUrl", ^{
      NSURL* url = [ssoServer acceptPageUrl];
      [[[url absoluteString] should] equal:@"http://open-dev-test.dev.gree-dev.net/?action=sso_authorize&app_id=5678"];
    });

    it(@"should make acceptPageUrl", ^{
      NSString* greeDomain = [[GreePlatform sharedInstance].settings stringValueForSetting:GreeSettingServerUrlDomain];
      NSString* cookieStr = [NSHTTPCookieStorage greeGetCookieValueWithName:@"gssid" domain:greeDomain];
      if(!cookieStr){
        cookieStr = @"be904852b9fbf127108b06d4b79160cc6384d919cf1290040ee266f198f69969a007c75f001327485117021227f7ee43";
        [NSHTTPCookieStorage greeSetCookie:cookieStr forName:@"gssid" domain:greeDomain];
      }
      NSURL* url1 = [ssoServer ssoAcceptUrlWithFlag:YES];
      [[[url1 scheme] should] equal:@"greeapp5678"];
      [[[url1 host] should] equal:@"sso"];
      NSDictionary *params1 = [[url1 query] greeDictionaryFromQueryString];      
      [[theValue([[params1 objectForKey:@"key"] length]) shouldNot] equal:theValue(0)];
      
      NSURL* url2 = [ssoServer ssoAcceptUrlWithFlag:NO];
      [[[url2 scheme] should] equal:@"greeapp5678"];
      [[[url2 host] should] equal:@"sso"];
      NSDictionary *params2 = [[url2 query] greeDictionaryFromQueryString];      
      [[theValue([[params2 objectForKey:@"key"] length]) should] equal:theValue(0)];
    });
    
    it(@"should have a description method", ^{
      NSString* expected = [NSString stringWithFormat:@"<%@:%p, %@:%p, clientSeedKey:%@, clientApplicationId:%@>",
        NSStringFromClass([ssoServer class]),
        ssoServer,
        NSStringFromClass([[ssoServer valueForKey:@"aes128"] class]),
        [ssoServer valueForKey:@"aes128"],
        [ssoServer valueForKey:@"clientSeedKey"],
        [ssoServer valueForKey:@"clientApplicationId"]];
        [[[ssoServer description] should] equal:expected];
    });

  });  

  context(@"as sso client", ^{

    __block GreeSSO* ssoClient = nil;
    
    beforeAll(^{
      ssoClient = [[GreeSSO alloc] initAsClient]; 
    });
    
    afterAll(^{
      [ssoClient release];
    });
  
    it(@"should make acceptPageUrl", ^{
      NSString* requestToken = @"828dbf3b6337b9ace3f34549";
      NSString* context = @"eyJhbGciOiJIUzI1NiJ9.eyJrZXkiOlsidWRpZC1GMTNGMDlEN0ZDOTM1RDc0OUU3OTA1NUVCNENENUFBMCIsInV1aWQtOUVBRDcyRjJDRDhGNDk2NTkzMTI5NTAxQURERTUyQUUiXSwidGltZXN0YW1wIjoxMzMwOTUyNjE2LCJoa2V5IjoiMTA5QURENjVCMERFIn0.K7o-9NHraIGy-jnfqOUc8PfobnSpZqR8t4NWoAo6_Jk";
      NSURL* url = [ssoClient
                    ssoRequireUrlWithServerApplicationId:@"9123"
                    requestToken:requestToken
                    context:context
                    parameters:[NSDictionary
                                dictionaryWithObjectsAndKeys:
                                @"JPAP000052760", @"ent_code",
                                @"DR00000052760", @"reg_code",
                                @"370", @"target",
                                nil]];
      [[[url scheme] should] equal:@"greesso9123"];
      [[[url host] should] equal:@"authorize"];
      [[[url path] should] equal:@"/request"];
      NSDictionary *params = [[url query] greeDictionaryFromQueryString];      
      [[[params objectForKey:@"app_id"] should] equal:@"1234"];
      [[[params objectForKey:@"oauth_token"] should] equal:requestToken];
      [[[params objectForKey:@"context"] should] equal:context];
      [[[params objectForKey:@"ent_code"] should] equal:@"JPAP000052760"];
      [[[params objectForKey:@"reg_code"] should] equal:@"DR00000052760"];
      [[[params objectForKey:@"target"] should] equal:@"370"];
    });
    
    it(@"should set gssid" , ^{
      NSString* greeDomain = [[GreePlatform sharedInstance].settings stringValueForSetting:GreeSettingServerUrlDomain];
      NSString* originarlCookieStr = [NSHTTPCookieStorage greeGetCookieValueWithName:@"gssid" domain:greeDomain];
      [NSHTTPCookieStorage greeDeleteCookieWithName:@"gssid" domain:greeDomain];
      [[NSHTTPCookieStorage greeGetCookieValueWithName:@"gssid" domain:greeDomain] shouldBeNil];
      
      GreeAES128* aes = [[GreeAES128 alloc] init];
      NSData *keydata = [[ssoClient valueForKey:@"clientSeedKey"] greeHexStringFormatInBinary];
      [aes setKey:[keydata bytes]];
      [aes setInitializationVector:[keydata bytes]];  
      NSString* rawStr = @"be904852b9fbf127108b06d4b79160cc6384d919cf1290040ee266f198f69969a007c75f001327485117021227f7ee43";
      NSData *rawData = [rawStr greeHexStringFormatInBinary];
      NSData *encryptedData = [aes encrypt:[rawData bytes] length:[rawData length]];
      [aes release];
      
      [ssoClient setDecryptGssIdWithEncryptedGssId:[encryptedData greeFormatInHex]];
      [[NSHTTPCookieStorage greeGetCookieValueWithName:@"gssid" domain:greeDomain] shouldNotBeNil];

      if(originarlCookieStr){ //restore
        [NSHTTPCookieStorage greeSetCookie:originarlCookieStr forName:@"gssid" domain:greeDomain];
      }
    });    
    
    it(@"should have a description method", ^{
      NSString* expected = [NSString stringWithFormat:@"<%@:%p, %@:%p, clientSeedKey:%@, clientApplicationId:%@>",
        NSStringFromClass([ssoClient class]),
        ssoClient,
        NSStringFromClass([[ssoClient valueForKey:@"aes128"] class]),
        [ssoClient valueForKey:@"aes128"],
        [ssoClient valueForKey:@"clientSeedKey"],
        [ssoClient valueForKey:@"clientApplicationId"]];
      [[[ssoClient description] should] equal:expected];
    });
  });
    
});

SPEC_END


