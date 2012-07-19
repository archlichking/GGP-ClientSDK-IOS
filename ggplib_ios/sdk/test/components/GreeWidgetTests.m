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
#import "GreeTestHelpers.h"
#import "GreeWidget.h"
#import "GreeWidget+Internal.h"
#import "GreeWidgetItem.h"
#import "GreeBadgeValues.h"
#import "GreeSettings.h"


@interface  UIFont (mock)
+ (id)empty:(CGFloat)n traits:(int)m;
@end
@implementation UIFont (mock)
+ (id)empty:(CGFloat)n traits:(int)m {
  return nil;
}
@end


@interface  UIWindowMock : UIWindow
@property (nonatomic, readwrite, assign) UIView* bar;
@end

@implementation UIWindowMock
@synthesize bar = _bar;
- (void)addSubview:(UIView *)subview
{
  self.bar = subview;
}
@end

@interface UIViewControllerMock: UIViewController<GreeWidgetDataSource>
@end


@implementation UIViewControllerMock

- (UIImage*)screenshotImageForWidget:(GreeWidget*)widget
{
  return [UIImage mock];
}

@end


#pragma mark - GreeWidgetTests



SPEC_BEGIN(GreeWidgetTests)


describe(@"GreeWidget", ^{
  __block id systemFontHandler;
  __block GreeSettings *settings;

  beforeAll(^{
    // swizzle to avoid crash due to UIFont
    systemFontHandler = [[GreeTestHelpers
                          exchangeClassSelector:@selector(systemFontOfSize:traits:)
                          onClass:[UIFont class]
                          withSelector:@selector(empty:traits:)
                          onClass:[UIFont class]] retain];
  });
  
  afterAll(^{
    [GreeTestHelpers restoreExchangedSelectors:&systemFontHandler];
  });
  
  beforeEach( ^{      
    [UILabel stub:@selector(defaultFont) andReturn:nil];
    [UIFont stub:@selector(fontWithName:size:) andReturn:nil];
    [UIColor stub:@selector(colorWithRed:green:blue:alpha:) andReturn:nil];
    
    NSDictionary* values = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:GreeWidgetPositionBottomLeft],GreeSettingWidgetPosition,
                              [NSNumber numberWithBool:YES],GreeSettingWidgetExpandable,nil];
    settings = [[GreeSettings alloc] init];
    [settings applySettingDictionary:values];
  });
  
  afterEach(^{
    [settings release];
  });

  it(@"should initialize", ^{
    GreeWidget *widget = [[GreeWidget alloc] initWithSettings:settings];
    [[widget should] beNonNil];
    [widget release];
  });

  it(@"should set the correct values", ^{
    GreeWidget *widget = [[GreeWidget alloc] initWithSettings:settings];

    [[theValue(widget.position) should] equal:theValue(GreeWidgetPositionBottomLeft)];
    [[theValue(widget.expandable) should] beYes];
    
    [widget release];
  });

  it(@"should hide screenshot button if callback is not given", ^{
    GreeWidget *widget = [[GreeWidget alloc] initWithSettings:settings];
    [widget performSelector:@selector(loadBarItems)];
  
    [[theValue(widget.screenshotItem.hidden) should] beYes];
  
    UIViewControllerMock* mockViewController = [UIViewControllerMock mock];
    widget.dataSource = mockViewController;

    [[theValue(widget.screenshotItem.hidden) should] beNo];
    widget.dataSource = nil;
    [[theValue(widget.screenshotItem.hidden) should] beYes];
    
    [widget release];
  });
  
  it(@"should has a correct description", ^{
    GreeWidget *widget = [[GreeWidget alloc] initWithSettings:settings];
    NSString* desc = [NSString stringWithFormat:@"<%@:%p, position:%@, visible:%@, expandable:%@>",
                         NSStringFromClass([GreeWidget class]), 
                         widget,
                         @"GreeWidgetPositionBottomLeft",
                         @"NO",
                         @"YES"];
    [[[widget description] should] equal:desc];
  });
  
  context(@"with a mock GreeBadgeValue", ^{
    it(@"should reflect badgeValues", ^{
      GreeWidget *widget = [[GreeWidget alloc] initWithSettings:settings];
      [widget performSelector:@selector(loadBarItems)];

      id badgeHandle = [GreeTestHelpers
        exchangeClassSelector:@selector(loadBadgeValuesWithBlock:)
        onClass:[GreeBadgeValues class]
        withSelector:@selector(__loadBadgeValuesWithBlock:)
        onClass:[GreeBadgeValues class]];
        
      GreeBadgeValues* badge = [[GreeBadgeValues mock] retain];
      [badge stub:@selector(socialNetworkingServiceBadgeCount) andReturn:theValue(10)];
      [badge stub:@selector(applicationBadgeCount) andReturn:theValue(20)];

      [widget updateBadgesWithValue:badge];
      [[theValue(widget.userMessageItem.badgeCount) shouldEventually] equal:theValue(10)];
      [[theValue(widget.gameMessageItem.badgeCount) shouldEventually] equal:theValue(20)];
      
      [GreeTestHelpers restoreExchangedSelectors:&badgeHandle];
      
      [widget release];
    });
  });
  
});

SPEC_END
