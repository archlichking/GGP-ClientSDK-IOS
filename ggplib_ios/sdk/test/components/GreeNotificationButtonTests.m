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
#import "GreeNotificationButton.h"

static NSString* kMockTitle = @"The Title";
static NSString* kMockMessage = @"The Message";
static CGRect kMockFrame = { {0.0f, 0.0f}, {320.0f, 480.0f} };

SPEC_BEGIN(GreeNotificationButtonSpec)

describe(@"GreeNotificationButton", ^{

  it(@"should initialize", ^{
      GreeNotificationButton* notificationButton = [[GreeNotificationButton alloc]
       initWithTitle:kMockTitle
       message:kMockMessage
       icon:[UIImage imageNamed:@"sampleUserIcon.png"]
       frame:kMockFrame];
       
      [notificationButton shouldNotBeNil];
      [notificationButton release];
  });
  
  it(@"should set the correct values to its elements", ^{
      GreeNotificationButton* notificationButton = [[GreeNotificationButton alloc]
       initWithTitle:kMockTitle
       message:kMockMessage
       icon:nil
       frame:kMockFrame];
       
      [[notificationButton.titleLabel.text should] equal:kMockTitle];
      [[notificationButton.messageLabel.text should] equal:kMockMessage];
      
      BOOL ofTheComparisonBetweenTheButtonFrameAndTheMockFrame = CGRectEqualToRect(notificationButton.frame, kMockFrame);
      
      [[theValue(ofTheComparisonBetweenTheButtonFrameAndTheMockFrame) should] beYes];
    
      [notificationButton release];
  });
  
  it(@"should set the color type to the default value", ^{
      GreeNotificationButton* notificationButton = [[GreeNotificationButton alloc]
       initWithTitle:kMockTitle
       message:kMockMessage
       icon:[UIImage imageNamed:@"sampleUserIcon.png"]
       frame:kMockFrame];
       
      [[theValue(notificationButton.colorType) should] equal:theValue(GreeNotificationLightColorType)];
      [notificationButton release];
  });

  it(@"should let the user change the color value value", ^{
      GreeNotificationButton* notificationButton = [[GreeNotificationButton alloc]
       initWithTitle:kMockTitle
       message:kMockMessage
       icon:[UIImage imageNamed:@"sampleUserIcon.png"]
       frame:kMockFrame];
    
      notificationButton.colorType = GreeNotificationDarkColorType;
    
      [[theValue(notificationButton.colorType) should] equal:theValue(GreeNotificationDarkColorType)];
      [notificationButton release];
  });
  
  it(@"should default to having no close button", ^{
      GreeNotificationButton* notificationButton = [[GreeNotificationButton alloc]
       initWithTitle:kMockTitle
       message:kMockMessage
       icon:[UIImage imageNamed:@"sampleUserIcon.png"]
       frame:kMockFrame];
        
      [[theValue(notificationButton.showsCloseButton) should] beFalse];
      [notificationButton release];
  }); 
  
  it(@"should let the user set a close button", ^{
      GreeNotificationButton* notificationButton = [[GreeNotificationButton alloc]
       initWithTitle:kMockTitle
       message:kMockMessage
       icon:[UIImage imageNamed:@"sampleUserIcon.png"]
       frame:kMockFrame];
       
      notificationButton.showsCloseButton = YES;
        
      [[theValue(notificationButton.showsCloseButton) should] beTrue];
      [notificationButton release];
  });
  
  it(@"should not initialize the close button when it is not intended to be displayed", ^{
      GreeNotificationButton* notificationButton = [[GreeNotificationButton alloc]
       initWithTitle:kMockTitle
       message:kMockMessage
       icon:[UIImage imageNamed:@"sampleUserIcon.png"]
       frame:kMockFrame];
    
      [notificationButton.closeButton shouldBeNil];
      [notificationButton release];
  });
  
  it(@"should initialize the close button when it is intended to be displayed", ^{
      GreeNotificationButton* notificationButton = [[GreeNotificationButton alloc]
       initWithTitle:kMockTitle
       message:kMockMessage
       icon:[UIImage imageNamed:@"sampleUserIcon.png"]
       frame:kMockFrame];
   
     notificationButton.showsCloseButton = YES;
    
     [notificationButton.closeButton shouldNotBeNil];
     [notificationButton release];
  });
  
  it(@"should show description", ^{
      GreeNotificationButton* notificationButton = [[GreeNotificationButton alloc]
       initWithTitle:kMockTitle
       message:kMockMessage
       icon:[UIImage imageNamed:@"sampleUserIcon.png"]
       frame:kMockFrame];

      NSString *descriptionString = [NSString stringWithFormat:@"<%@:%p, title:%@, message:%@, frame:%@, colorType:%@, showsCloseButton:%@>",
                                      @"GreeNotificationButton",
                                      notificationButton,
                                      kMockTitle,
                                      kMockMessage,
                                      NSStringFromCGRect(kMockFrame),
                                      NSStringFromGreeNotificationColorType(GreeNotificationLightColorType),
                                      @"NO"];
      [[[notificationButton description] should] equal:descriptionString];
      [notificationButton release];
  });
});

SPEC_END
