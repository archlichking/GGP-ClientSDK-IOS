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
#import "GreeMatchers.h"

#pragma mark - GreeMatcherTests

SPEC_BEGIN(GreeMatcherTests)
describe(@"containString matcher", ^{
  registerMatchers(@"Gree");
  it(@"should work", ^{
    [[@"ABCDEF" should] containString:@"DE"];
  });
  it(@"should work with negatives", ^{
    [[@"ABCDEF" shouldNot] containString:@"DUD"];
  });
  it(@"should handle nil match", ^{
    [[@"ABCDEF" shouldNot] containString:nil];
  });
});

describe(@"containRegExp matcher", ^{
  registerMatchers(@"Gree");
  it(@"should work", ^{
    [[@"ABCDE" should] matchRegExp:@"[A-Z]+"];    
  });  
  it(@"should work with negatives", ^{
    [[@"123" shouldNot] matchRegExp:@"[A-Z]+"];    
  });  
  it(@"should allow options", ^{
    [[@"abc" should] matchRegExp:@"[A-Z]+" withOptions:NSRegularExpressionCaseInsensitive];
  });
});

describe(@"nearDate matcher", ^{
  registerMatchers(@"Gree");
  it(@"should succeed with close dates", ^{
    NSDate* date1 = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    NSDate* date2 = [NSDate dateWithTimeIntervalSinceReferenceDate:0.5];
    [[date1 should] nearlyEqualDate:date2];
    [[date2 should] nearlyEqualDate:date1];
  });
  it(@"should fail with farther dates", ^{
    NSDate* date1 = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    NSDate* date2 = [NSDate dateWithTimeIntervalSinceReferenceDate:1.5];
    [[date1 shouldNot] nearlyEqualDate:date2];
    [[date2 shouldNot] nearlyEqualDate:date1];
  });
  it(@"should fail with nil dates", ^{
    NSDate* date1 = [NSDate dateWithTimeIntervalSinceReferenceDate:0];
    NSDate* date2 = nil;
    [[date1 shouldNot] nearlyEqualDate:date2];
  });
});

SPEC_END
