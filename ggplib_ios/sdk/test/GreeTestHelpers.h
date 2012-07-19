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

#import <Foundation/Foundation.h>

#import "GreePlatform.h"
#import "GreeNetworkReachability.h"
#import "GreeHTTPClient.h"
#import "GreeAuthorization.h"

@class GreeWriteCache;

// Makes [[UIDevice currentDevice] systemVersion] pretend to be desiredVersion
void StubUIDeviceSystemVersion(NSString* desiredVersion);
// Makes [[GreePlatform sharedInstance].localUser userId] return testUser# (where # is monotonically increasing)
void StubGreeLocalUser(void);

// Unit tests currently run with +[NSBundle mainBundle] relative to the otest executable.
// greeTestBundle serves to offer a swizzle target which will redirect +[NSBundle mainBundle]
// to the expected location (unit test bundle root)
@interface NSBundle (GreeTestingAdditions)
+ (NSBundle*)greeTestBundle;
@end

@interface NSNotificationCenter (Mocking)
// Creates a NSNotificationCenter nullMock and stubs +defaultCenter to return it.
+ (id)nullMockAsDefaultCenter;
@end

@interface UIApplication (Mocking)
// Creates a UIApplication nullMock and stubs +sharedApplication to return it.
+ (id)nullMockAsSharedApplication;
@end

@interface GreePlatform (Mocking)
// Creates a GreePlatform nullMock and stubs +sharedInstance to return it.
+ (id)nullMockAsSharedInstance;
@end

@interface GreeNetworkReachability (Mocking)
// Creates a GreeNetworkReachabilityMock with -status stubbed to return
// the given status, and -isConnectedToInternet stubbed to return a value
// appropriate for the status.
+ (id)nullMockWithStatus:(GreeNetworkReachabilityStatus)status;
@end

@interface GreeHTTPClient (Mocking)
// Creates a mock HTTP client with a bogus UserAgent that will make requests
// conforming to the GreeURLMockingProtocol's requirements.
+ (id)nullMock;
@end

@interface GreeAuthorization (Mocking)
//these return a handle to send to restoreExchangeSelectors below
+ (id)mockReauthorizeToSucceed;
+ (id)mockReauthorizeToFail;
@end

// Generic dumping ground for test helpers that are useful for more than a single group of tests
@interface GreeTestHelpers : NSObject

// Exchanges +[targetClass targetSelector] with +[replacementClass replacementSelector]
// Returns a handle to be passed back in to restoreExchangedSelectors to undo the exchange.
+ (id)exchangeClassSelector:(SEL)targetSelector onClass:(Class)targetClass withSelector:(SEL)replacementSelector onClass:(Class)replacementClass;

// Exchanges -[targetClass targetSelector] with -[replacementClass replacementSelector]
// Returns a handle to be passed back in to restoreExchangedSelectors to undo the exchange.
+ (id)exchangeInstanceSelector:(SEL)targetSelector onClass:(Class)targetClass withSelector:(SEL)replacementSelector onClass:(Class)replacementClass;

// Restores a set of exchanged method implementations. handle is zero'd inside this method.
+ (void)restoreExchangedSelectors:(id*)handle;

@end
