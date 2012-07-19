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
#import "GreeTestHelpers.h"
@interface TestSwizzler : NSObject
- (NSString*)one;
- (NSString*)two;
+ (NSString*)classOne;
+ (NSString*)classTwo;
@end

@implementation TestSwizzler
- (NSString*)one { return @"one"; }
- (NSString*)two { return @"two"; }
+ (NSString*)classOne { return @"classOne"; }
+ (NSString*)classTwo {return @"classTwo"; }
@end


#pragma mark - GreeTestHelperTests

SPEC_BEGIN(GreeTestHelperTests)
describe(@"TestHelpers", ^{
  context(@"when swizzling", ^{
    it(@"should swap instance methods", ^{
      id fixIt = [GreeTestHelpers exchangeInstanceSelector:@selector(one) onClass:[TestSwizzler class] withSelector:@selector(two) onClass:[TestSwizzler class]];
      TestSwizzler* obj = [[[TestSwizzler alloc] init] autorelease];
      [[[obj two] should] equal:@"one"];
      [[[obj one] should] equal:@"two"];
      [GreeTestHelpers restoreExchangedSelectors:&fixIt];
      [[[obj one] should] equal:@"one"];
      [[[obj two] should] equal:@"two"];
    });
    it(@"should swap class methods", ^{
      id fixIt = [GreeTestHelpers exchangeClassSelector:@selector(classOne) onClass:[TestSwizzler class] withSelector:@selector(classTwo) onClass:[TestSwizzler class]];
      [[[TestSwizzler classTwo] should] equal:@"classOne"];
      [[[TestSwizzler classOne] should] equal:@"classTwo"];
      [GreeTestHelpers restoreExchangedSelectors:&fixIt];
      [[[TestSwizzler classOne] should] equal:@"classOne"];
      [[[TestSwizzler classTwo] should] equal:@"classTwo"];
    });
  });
});

SPEC_END
