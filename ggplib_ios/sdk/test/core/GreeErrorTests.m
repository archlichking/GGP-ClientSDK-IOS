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
#import "GreeError+Internal.h"

#pragma mark - GreeErrorTests

SPEC_BEGIN(GreeErrorTests)
describe(@"GreeError", ^{
  it(@"should create errors", ^{
    NSError* value = [GreeError localizedGreeErrorWithCode:GreeErrorCodeNetworkError];
    [[value should] beKindOfClass:[NSError class]];
    [[theValue(value.code) should] equal:theValue(GreeErrorCodeNetworkError)];
    [[value.domain should] equal:GreeErrorDomain];
    [[value.userInfo should] haveValueForKey:NSLocalizedDescriptionKey];      
  });
  it(@"should default the localized message", ^{
    NSError* value = [GreeError localizedGreeErrorWithCode:3456039];
    [[value should] beKindOfClass:[NSError class]];
    [[theValue(value.code) should] equal:theValue(3456039)];
    [[value.domain should] equal:GreeErrorDomain];
    [[value.userInfo should] haveValueForKey:NSLocalizedDescriptionKey];      
  });
});

SPEC_END
