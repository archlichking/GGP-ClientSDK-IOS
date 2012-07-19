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

#import "GreeTestHelpers.h"

#import <objc/runtime.h>
#import "GreePlatform+Internal.h"
#import "GreeURLMockingProtocol.h"
#import "GreeHTTPClient.h"
#import "GreeWriteCache.h"
#import "GreeUser.h"

#import "Kiwi.h"

#pragma mark - General Utility Methods

void StubUIDeviceSystemVersion(NSString* desiredVersion)
{
  UIDevice* mock = [UIDevice nullMock];
  [mock stub:@selector(systemVersion) andReturn:desiredVersion];
  [UIDevice stub:@selector(currentDevice) andReturn:mock];
}

void StubGreeLocalUser(void)
{
  static int stubCount = 0;
  GreeUser* mockLocalUser = [GreeUser nullMock];
  [mockLocalUser stub:@selector(userId) andReturn:[NSString stringWithFormat:@"testUser%d", stubCount]];
  [[GreePlatform sharedInstance] stub:@selector(localUser) andReturn:mockLocalUser];
}

#pragma mark - NSBundle (GreeTestingAdditions)

@implementation NSBundle (GreeTestingAdditions)

+ (NSBundle*)greeTestBundle
{
  return [NSBundle bundleForClass:[GreeTestHelpers class]];
}

@end

#pragma mark - NSNotificationCenter (Mocking)

@implementation NSNotificationCenter (Mocking)

+ (id)nullMockAsDefaultCenter
{
  NSNotificationCenter* mock = [NSNotificationCenter nullMock];
  [NSNotificationCenter stub:@selector(defaultCenter) andReturn:mock];
  return mock;
}

@end

#pragma mark - UIApplication (Mocking)

@implementation UIApplication (Mocking)

+ (id)nullMockAsSharedApplication
{
  UIApplication* mock = [UIApplication nullMock];
  [UIApplication stub:@selector(sharedApplication) andReturn:mock];
  return mock;
}

@end

#pragma mark - GreePlatform (Mocking)

@implementation GreePlatform (Mocking)

+ (id)nullMockAsSharedInstance
{
  GreePlatform* mock = [GreePlatform nullMock];
  [GreePlatform stub:@selector(sharedInstance) andReturn:mock];
  return mock;
}

@end

#pragma mark - GreeNetworkReachability (Mocking)

@implementation GreeNetworkReachability (Mocking)

+ (id)nullMockWithStatus:(GreeNetworkReachabilityStatus)status
{
  GreeNetworkReachability* mock = [GreeNetworkReachability nullMock];
  [mock stub:@selector(initWithHost:) andReturn:mock];
  [mock stub:@selector(status) andReturn:theValue(status)];
  BOOL isConnectedToInternet = 
    (status == GreeNetworkReachabilityConnectedViaWiFi) || 
    (status == GreeNetworkReachabilityConnectedViaCarrier);
  [mock stub:@selector(isConnectedToInternet) andReturn:theValue(isConnectedToInternet)];
  return mock;
}

@end

#pragma mark - GreeHTTPClient (Mocking)

@implementation GreeHTTPClient (Mocking)

+ (id)nullMock
{
  [GreeHTTPClient stub:@selector(userAgentString) andReturn:@"Duuuhh"];
  return [[[GreeHTTPClient alloc] 
    initWithBaseURL:[NSURL URLWithString:[GreeURLMockingProtocol httpClientPrefix]] 
    key:@"mockkey" 
    secret:@"mocksecret"] autorelease];
}

@end

#pragma mark - GreeAuthorization (Mocking)
@implementation GreeAuthorization (Mocking)
#pragma mark - Swizzle methods
- (void)executeSuccess
{
}
- (void)executeFailure
{
}
#pragma mark - Public
+ (id)mockReauthorizeToSucceed
{
  return [GreeTestHelpers exchangeInstanceSelector:@selector(reAuthorize) 
                            onClass:[GreeAuthorization class] 
                            withSelector:@selector(executeSuccess) 
                            onClass:[GreeAuthorization class]];
  
}
+ (id)mockReauthorizeToFail
{
  return [GreeTestHelpers exchangeInstanceSelector:@selector(reAuthorize) 
                            onClass:[GreeAuthorization class] 
                            withSelector:@selector(executeFailure) 
                            onClass:[GreeAuthorization class]];
  
}
@end

#pragma mark - GreeTestHelpers

@implementation GreeTestHelpers

#pragma mark Method Swizzling

+ (id)exchangeClassSelector:(SEL)targetSelector onClass:(Class)targetClass withSelector:(SEL)replacementSelector onClass:(Class)replacementClass
{
  Method original = class_getClassMethod(targetClass, targetSelector);
  Method replacement = class_getClassMethod(replacementClass, replacementSelector);
  method_exchangeImplementations(original, replacement);
  
  void(^restoreBlock)(void) = ^{
    method_exchangeImplementations(original, replacement);
  };

  return Block_copy(restoreBlock);
}

+ (id)exchangeInstanceSelector:(SEL)targetSelector onClass:(Class)targetClass withSelector:(SEL)replacementSelector onClass:(Class)replacementClass
{
  Method original = class_getInstanceMethod(targetClass, targetSelector);
  Method replacement = class_getInstanceMethod(replacementClass, replacementSelector);
  method_exchangeImplementations(original, replacement);

  void(^restoreBlock)(void) = ^{
    method_exchangeImplementations(original, replacement);
  };

  return Block_copy(restoreBlock);
}

+ (void)restoreExchangedSelectors:(id*)handle
{
  if (handle != NULL && (*handle) != nil) {
    ((void(^)(void))(*handle))();
    Block_release((*handle));
    (*handle) = nil;
  }
}

#pragma mark Initialization
+ (void)load
{
  [GreeTestHelpers 
    exchangeClassSelector:@selector(mainBundle) 
    onClass:[NSBundle class] 
    withSelector:@selector(greeTestBundle) 
    onClass:[NSBundle class]];
  [GreeTestHelpers 
   exchangeClassSelector:@selector(greePlatformCoreBundle) 
   onClass:[NSBundle class] 
   withSelector:@selector(greeTestBundle) 
   onClass:[NSBundle class]];
}

@end
