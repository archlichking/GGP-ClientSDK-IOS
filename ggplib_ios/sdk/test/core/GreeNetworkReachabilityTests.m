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

#import "Kiwi.h"
#import "GreeNetworkReachability.h"

#pragma mark - GreeNetworkReachabilityTests

SPEC_BEGIN(GreeNetworkReachabilityTests)

describe(@"NSStringFromGreeNetworkReachabilityStatus", ^{

  it(@"should handle unknown status", ^{
    [[NSStringFromGreeNetworkReachabilityStatus(GreeNetworkReachabilityUnknown) should] equal:@"Unknown"];
  });

  it(@"should handle wifi status", ^{
    [[NSStringFromGreeNetworkReachabilityStatus(GreeNetworkReachabilityConnectedViaWiFi) should] equal:@"Connected via WiFi"];
  });

  it(@"should handle carrier status", ^{
    [[NSStringFromGreeNetworkReachabilityStatus(GreeNetworkReachabilityConnectedViaCarrier) should] equal:@"Connected via Carrier Network"];
  });
 
  it(@"should handle disconnected status", ^{
    [[NSStringFromGreeNetworkReachabilityStatus(GreeNetworkReachabilityNotConnected) should] equal:@"Not Connected"];
  });
  
  it(@"should raise on undefined status", ^{
    [[theBlock(^{
      NSStringFromGreeNetworkReachabilityStatus((GreeNetworkReachabilityStatus)0xBADF00D);
    }) should] raise];
  });

});

describe(@"GreeNetworkReachabilityStatusIsConnected", ^{
  
  it(@"should consider unknown => NO", ^{
    [[theValue(GreeNetworkReachabilityStatusIsConnected(GreeNetworkReachabilityUnknown)) should] beNo];
  });

  it(@"should consider wifi => YES", ^{
    [[theValue(GreeNetworkReachabilityStatusIsConnected(GreeNetworkReachabilityConnectedViaWiFi)) should] beYes];    
  });

  it(@"should consider carrier => YES", ^{
    [[theValue(GreeNetworkReachabilityStatusIsConnected(GreeNetworkReachabilityConnectedViaCarrier)) should] beYes];        
  });

  it(@"should consider not connected => NO", ^{
    [[theValue(GreeNetworkReachabilityStatusIsConnected(GreeNetworkReachabilityNotConnected)) should] beNo];
  });

});

describe(@"GreeNetworkReachability", ^{
  
  it(@"should have a description method", ^{
    GreeNetworkReachability* reachability = [[GreeNetworkReachability alloc] initWithHost:@"http://www.google.com"];
    NSString* expected = [NSString stringWithFormat:
      @"<GreeNetworkReachability:%p, host:www.google.com, status:Unknown>", 
      reachability];
    [[[reachability description] should] equal:expected];
    [reachability release];
  });

  context(@"when initialized with an invalid host", ^{
    __block GreeNetworkReachability* reachability = nil;

    beforeEach(^{
      reachability = [[GreeNetworkReachability alloc] initWithHost:@"192.157.123.12"];
    });
    
    afterEach(^{
      [reachability release];
      reachability = nil;
    });
    
    it(@"should return nil", ^{
      [reachability shouldBeNil];
    });

  });
  
  context(@"when initialized with a valid host", ^{
    __block GreeNetworkReachability* reachability = nil;
    
    beforeEach(^{
      reachability = [[GreeNetworkReachability alloc] initWithHost:@"http://www.google.com/"];
    });
    
    afterEach(^{
      [reachability release];
      reachability = nil;
    });
    
    it(@"should record the host", ^{
      [reachability.host isEqual:@"www.google.com"];
    });
    
    it(@"should start with unknown status", ^{
      [[theValue(reachability.status) should] equal:theValue(GreeNetworkReachabilityUnknown)];
    });

    it(@"should allow adding and removing observers", ^{
      id observer = [reachability addObserverBlock:^(GreeNetworkReachabilityStatus previous, GreeNetworkReachabilityStatus current) {
      }];

      [reachability removeObserverBlock:observer];
    });
    
    it(@"should invoke observer eventually", ^{
      __block NSString* signal = nil;
      [reachability addObserverBlock:^(GreeNetworkReachabilityStatus previous, GreeNetworkReachabilityStatus current) {
        signal = @"invoked";
      }];
      
      [[expectFutureValue(signal) shouldEventuallyBeforeTimingOutAfter(10.f)] beNonNil];
    });
    
    it(@"should not allow mutating observer state in an observer callback", ^{
      __block NSString* signal = nil;
      __block id observer = [reachability addObserverBlock:^(GreeNetworkReachabilityStatus previous, GreeNetworkReachabilityStatus current) {
        [[theBlock(^{
          [reachability removeObserverBlock:observer];
        }) should] raise];

        [[theBlock(^{
          [reachability addObserverBlock:^(GreeNetworkReachabilityStatus previous, GreeNetworkReachabilityStatus current) {
          }];
        }) should] raise];

        signal = @"invoked";
      }];
      
      [[expectFutureValue(signal) shouldEventuallyBeforeTimingOutAfter(10.f)] beNonNil];
    });

  });
  
});

SPEC_END
