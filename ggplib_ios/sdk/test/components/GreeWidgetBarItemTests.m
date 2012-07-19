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
#import "GreeWidgetItem.h"

@interface  UIFont (mock)
+ (id)empty:(CGFloat)n traits:(int)m;
@end
@implementation UIFont (mock)
+ (id)empty:(CGFloat)n traits:(int)m {
  return nil;
}
@end

#pragma mark - GreeWidgetBarItemTests

@interface GreeWidgetItem ()
@property (nonatomic, readwrite, retain) UILabel *numberLabel;
@end

SPEC_BEGIN(GreeWidgetBarItemTests)

beforeAll(^{
});
afterAll(^{
});


describe(@"GreeWidgetBarItem", ^{
  __block id systemFontHandler;

  beforeAll(^{
    // swizzle to avoid crash due to UIFont
    systemFontHandler = [GreeTestHelpers
                         exchangeClassSelector:@selector(systemFontOfSize:traits:)
                         onClass:[UIFont class]
                         withSelector:@selector(empty:traits:)
                         onClass:[UIFont class]];
  });
  
  afterAll(^{
    [GreeTestHelpers restoreExchangedSelectors:&systemFontHandler];
  });
  
  beforeEach(^{
    [UILabel stub:@selector(defaultFont) andReturn:nil];
    [UIFont stub:@selector(fontWithName:size:) andReturn:nil];
    [UIColor stub:@selector(colorWithRed:green:blue:alpha:) andReturn:nil];
  });

  it(@"should initialize", ^{
    UIImage* image = [UIImage nullMock];
    GreeWidgetItem* item = [GreeWidgetItem itemWithImage:image callbackBlock:NULL];
    [[item should] beNonNil];
  });

  it(@"should invoke callback on tap", ^{
    __block BOOL tapped = NO;
    UIImage* image = [UIImage nullMock];
    GreeWidgetItem* item = [GreeWidgetItem itemWithImage:image callbackBlock:^() {
      tapped = YES;
    }];
    [item performSelector:@selector(buttonTouched:)];
    [[theValue(tapped) shouldEventually] beYes];
  });
  
  it(@"should not crash if null block is given to callbackBlock", ^{
    UIImage* image = [UIImage nullMock];
    GreeWidgetItem* item = [GreeWidgetItem itemWithImage:image callbackBlock:NULL];
    [item performSelector:@selector(buttonTouched:)];
  });

});

SPEC_END
