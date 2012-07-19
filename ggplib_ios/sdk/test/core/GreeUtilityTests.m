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
#import "GreeUtility.h"
#import "GreeTestHelpers.h"
#import <UIKit/UIKit.h>

#pragma mark - GreeUtilityTests

SPEC_BEGIN(GreeUtilityTests)

describe(@"GreeDeviceOsVersionIsAtLeast", ^{
  
  it(@"should return YES when given an earlier version", ^{
    StubUIDeviceSystemVersion(@"2.1.1");
    [[theValue(GreeDeviceOsVersionIsAtLeast(@"1.0.1")) should] beYes];
    [[theValue(GreeDeviceOsVersionIsAtLeast(@"2.1.0")) should] beYes];
    [[theValue(GreeDeviceOsVersionIsAtLeast(@"2.0.3")) should] beYes];
  });

  it(@"should return NO when given a later version", ^{
    StubUIDeviceSystemVersion(@"4.0.1");
    [[theValue(GreeDeviceOsVersionIsAtLeast(@"5.0.1")) should] beNo];
    [[theValue(GreeDeviceOsVersionIsAtLeast(@"4.1.0")) should] beNo];
    [[theValue(GreeDeviceOsVersionIsAtLeast(@"4.0.3")) should] beNo];
  });

});

SPEC_END
