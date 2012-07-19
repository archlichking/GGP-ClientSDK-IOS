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
#import "GreeNotificationView.h"

static CGRect kMockFrame = { {0.0f, 0.0f}, {320.0f, 480.0f} };

SPEC_BEGIN(GreeNotificationViewSpec)

describe(@"GreeNotificationView", ^{

  it(@"should initialize with default values", ^{
      GreeNotificationView* notificationView = [[GreeNotificationView alloc] initWithFrame:kMockFrame
                                                  pointerLocation:GreeNotificationViewPointerTopLocation
                                                  colorType:GreeNotificationLightColorType];
       
      [notificationView shouldNotBeNil];
      
      BOOL ofTheComparsionOfTheViewFrameAndTheMockFrame = CGRectEqualToRect(notificationView.frame, kMockFrame);
      
      [[theValue(ofTheComparsionOfTheViewFrameAndTheMockFrame) should] beTrue];
      [[theValue(notificationView.colorType) should] equal:theValue(GreeNotificationLightColorType)];
      [[theValue(notificationView.pointerLocation) should] equal:theValue(GreeNotificationViewPointerTopLocation)];

      [notificationView release];
  });
  
  it(@"should show a description", ^{
    GreeNotificationView* notificationView = [[GreeNotificationView alloc] initWithFrame:kMockFrame
                                                pointerLocation:GreeNotificationViewPointerTopLocation
                                                colorType:GreeNotificationLightColorType];
                                                  
    NSString *descriptionString = [NSString stringWithFormat:@"<%@:%p, pointerLocation:%@, colorType:%@>",
                                    NSStringFromClass([notificationView class]),
                                    notificationView,
                                    NSStringFromGreeNotificationViewPointerLocation(GreeNotificationViewPointerTopLocation),
                                    NSStringFromGreeNotificationColorType(GreeNotificationLightColorType)];
                                      
    [[[notificationView description] should] equal:descriptionString];
    [notificationView release];
  });
});

SPEC_END
