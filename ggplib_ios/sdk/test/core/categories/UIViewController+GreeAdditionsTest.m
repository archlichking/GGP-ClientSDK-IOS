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

#import "UIViewController+GreeAdditions.h"

#pragma mark - UIViewController+GreeAdditionsTests


SPEC_BEGIN(UIViewController_GreeAdditionsTests)

describe(@"UIViewController+GreeAdditions", ^{
  context(@"when call +greeLastPresentedViewController", ^{
    it(@"should return rootViewController's greeLastPresentedViewController", ^{
      UIApplication *app = [UIApplication nullMock];
      [[UIApplication should] receive:@selector(sharedApplication) andReturn:app];
      [UIViewController greeLastPresentedViewController];
    });
  });
});

SPEC_END
