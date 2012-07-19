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
#import "GreeNotification+Internal.h"
#import "GreeNotificationTypes+Internal.h"
#import "GreeSerializer.h"
#import "JSONKit.h"
#import "GreeURLMockingProtocol.h"
#import "GreeTestHelpers.h"
#import "GreeMatchers.h"

static NSString *apsJsonString = @"{                                    "  
                                  "  \"iam\": {                         "
                                  "    \"type\":1,                      "
                                  "    \"text\":\"Hello\",              "
                                  "    \"act\":519519,                  "
                                  "    \"iflag\":0,                     "
                                  "    \"itoken\":\"abcd\"              "
                                  "  }                                  "
                                  "}                                    ";

static NSString* kMockMessage = @"The Message";
static NSString* kMockIconURLString = @"http://www.google.com/";
static GreeNotificationViewDisplayType kMockNotificationType = GreeNotificationViewDisplayDefaultType;
static NSTimeInterval kMockDuration = 0.3f;

SPEC_BEGIN(GreeNotificationTests)

describe(@"GreeNotification", ^{
  registerMatchers(@"Gree");

  it(@"should initialize", ^{
    GreeNotification *notification = [[GreeNotification alloc] initWithMessage:kMockMessage
      displayType:kMockNotificationType
      duration:kMockDuration];
    
    [[notification.message should] equal:kMockMessage];
    [[theValue(notification.displayType) should] equal:theValue(kMockNotificationType)];
    [[theValue(notification.duration) should] equal:theValue(kMockDuration)];
    
    [notification release];
  });
  
  it(@"should show description", ^{
    GreeNotification *notification = [[GreeNotification alloc] initWithMessage:kMockMessage
      displayType:kMockNotificationType
      duration:kMockDuration];
      

    NSString* checkString = [NSString stringWithFormat:@"<GreeNotification:0x[0-9a-f]+, message:%@, type:%@, duration:%f>",
      kMockMessage,
      NSStringFromGreeNotificationViewDisplayType(GreeNotificationViewDisplayDefaultType),
      kMockDuration];
    [[[notification description] should] matchRegExp:checkString]; 
    [notification release];
  });

  it(@"should provide a welcome message", ^{
    GreeNotification *notification = [GreeNotification notificationForLoginWithUsername:@"George"];
      
    [[notification.message should] equal:@"Welcome, George"];
    [[theValue(notification.displayType) should] equal:theValue(GreeNotificationViewDisplayDefaultType)];
    [[theValue(notification.duration) should] equal:theValue(3.0f)];
  });
  
  it(@"should load from an aps message", ^{
    NSDictionary *apsDictionary = [apsJsonString greeObjectFromJSONString];
  
    GreeNotification *notification = [GreeNotification notificationWithAPSDictionary:apsDictionary];
      
    [[notification.message should] equal:@"Hello"];
    [[theValue(notification.displayType) should] equal:theValue(GreeNotificationViewDisplayDefaultType)];
    [[theValue(notification.duration) should] equal:theValue(3.0f)];
  });
  
  
  context(@"when creating launch information", ^{
    it(@"should build friend login", ^{
      static NSString *apsJsonString = @"{  "  
      "  \"iam\": {                         "
      "    \"type\":1,                      "
      "    \"text\":\"Hello\",              "
      "    \"act\":519519,                  "
      "    \"iflag\":0,                     "
      "    \"itoken\":\"abcd\"              "
      "  }                                  "
      "}                                    ";
      GreeNotification* notification = [GreeNotification notificationWithAPSDictionary:[apsJsonString greeObjectFromJSONString]];
      [[notification.infoDictionary should] haveValue:@"dash" forKey:@"type"];
      [[notification.infoDictionary should] haveValue:@"519519" forKey:@"actor_id"];
    });
    
    it(@"should build service message", ^{
      static NSString *apsJsonString = @"{  "
      "  \"aps\" : {                        "
      "    \"alert\" : {                    "
      "      \"body\" : \"body\"            "
      "    },                               "
      "    \"message_id\" : \"mid\",        "
      "    \"uid\"        : \"rid\"         "
      "  }                                  "
      "}                                    ";
            
      GreeNotification* notification = [GreeNotification notificationWithAPSDictionary:[apsJsonString greeObjectFromJSONString]];
      [[notification.infoDictionary should] haveValue:@"message" forKey:@"type"];
      [[notification.infoDictionary should] haveValue:@"mid" forKey:@"info-key"];
    });
    
    it(@"should build request message", ^{
      static NSString *apsJsonString = @"{  "
      "  \"aps\" : {                        "
      "    \"alert\" : {                    "
      "      \"body\" : \"body\"            "
      "    },                               "
      "    \"request_id\" : \"req_id\",     "
      "    \"uid\"        : \"rid\"         "
      "  }                                  "
      "}                                    ";
      
      GreeNotification* notification = [GreeNotification notificationWithAPSDictionary:[apsJsonString greeObjectFromJSONString]];
      [[notification.infoDictionary should] haveValue:@"request" forKey:@"type"];
      [[notification.infoDictionary should] haveValue:@"req_id" forKey:@"info-key"];
    });

    it(@"should not build sns badge message 1", ^{
      static NSString *apsJsonString = @"{  "
      "  \"aps\" : {                        "
      "    \"badge\" : \"1\",               "
      "    \"message_id\" : \"sns\"         "
      "  }                                  "
      "}                                    ";
      
      GreeNotification* notification = [GreeNotification notificationWithAPSDictionary:[apsJsonString greeObjectFromJSONString]];
      [notification shouldBeNil];
    });

    it(@"should not build sns badge message 2", ^{
      static NSString *apsJsonString = @"{  "
      "  \"aps\" : {                        "
      "    \"badge\" : \"1\",               "
      "  }                                  "
      "}                                    ";
      
      GreeNotification* notification = [GreeNotification notificationWithAPSDictionary:[apsJsonString greeObjectFromJSONString]];
      [notification shouldBeNil];
    });

    it(@"should not build invalid message in GREE Platform 1", ^{
      static NSString *apsJsonString = @"{  "
      "  \"aps\" : {                        "
      "    \"alert\" : \"alert\",           "
      "  }                                  "
      "}                                    ";
      
      GreeNotification* notification = [GreeNotification notificationWithAPSDictionary:[apsJsonString greeObjectFromJSONString]];
      [notification shouldBeNil];
    });

    it(@"should not build invalid message in GREE Platform 2", ^{
      static NSString *apsJsonString = @"{  "
      "  \"aps\" : {}                       "
      "}                                    ";
      
      GreeNotification* notification = [GreeNotification notificationWithAPSDictionary:[apsJsonString greeObjectFromJSONString]];
      [notification shouldBeNil];
    });
  });
  
  context(@"with a mock notification", ^{
    __block GreePlatform* mockedSdk = nil;
    __block GreeNotification* mockNotification = nil;
    __block id waitObject = nil;

    beforeEach(^{
      mockedSdk = [[GreePlatform nullMockAsSharedInstance] retain];
      [mockedSdk stub:@selector(httpClient) andReturn:[GreeHTTPClient nullMock]];
      [GreeURLMockingProtocol register];

      mockNotification = [[GreeNotification notificationWithAPSDictionary:[apsJsonString greeObjectFromJSONString]] retain];
    });
    
    afterEach(^{
      [mockNotification release];
      mockNotification = nil;
      [waitObject release];
      waitObject = nil;

      [GreeURLMockingProtocol unregister];
      [mockedSdk release];
      mockedSdk = nil;
    });
    
    it(@"should work with Gree icon", ^{
      [UIImage stub:@selector(greeImageNamed:) andReturn:@"stuff"];
      [mockNotification setValue:[NSNumber numberWithInt:GreeAPSNotificationIconGreeType] forKeyPath:@"iconFlag"];
      [mockNotification loadIconWithBlock:^(NSError *error) {
        [mockNotification.iconImage shouldNotBeNil];
        [error shouldBeNil];
        [[theValue(mockNotification.showLogo) should] beNo];
      }];
    });

    it(@"should default to Gree icon", ^{
      [UIImage stub:@selector(greeImageNamed:) andReturn:@"stuff"];
      [mockNotification loadIconWithBlock:^(NSError *error) {
        [mockNotification.iconImage shouldNotBeNil];
        [error shouldBeNil];
        [[theValue(mockNotification.showLogo) should] beNo];
      }];
    });
    
    it(@"should work with app icon", ^{
      [UIImage stub:@selector(greeAppIconNearestWidth:) andReturn:@"stuff"];
      [mockNotification setValue:[NSNumber numberWithInt:GreeAPSNotificationIconApplicationType] forKeyPath:@"iconFlag"];
      [mockNotification loadIconWithBlock:^(NSError *error) {
        [mockNotification.iconImage shouldNotBeNil];
        [error shouldBeNil];
        [[theValue(mockNotification.showLogo) should] beYes];
      }];
    });    
    
    context(@"when downloading icon", ^{
      beforeEach(^{
        [mockNotification setValue:[NSNumber numberWithInt:GreeAPSNotificationIconDownloadType] forKeyPath:@"iconFlag"];
        [mockNotification setValue:[GreeURLMockingProtocol httpClientPrefix] forKeyPath:@"iconToken"];
      });
      it(@"should download icons", ^{
        MockedURLResponse* mock = [MockedURLResponse getResponseWithHttpStatus:200];
        UIImage* emptyImage = [[UIImage alloc] init];
        mock.data = UIImagePNGRepresentation(emptyImage);
        [emptyImage release];
        [GreeURLMockingProtocol addMock:mock];
        
        waitObject = nil;
        [mockNotification loadIconWithBlock:^(NSError* error) {
          NSLog(@"WTF %@ %@", mockNotification.iconImage, error);
          [mockNotification.iconImage shouldNotBeNil];
          [error shouldBeNil];
          [[theValue(mockNotification.showLogo) should] beNo];
          waitObject = @"DONE";
        }];
        [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      });
      
      it(@"should handle failure when downloading icon", ^{
        MockedURLResponse* mock = [MockedURLResponse getResponseWithHttpStatus:500];
        [GreeURLMockingProtocol addMock:mock];
        
        waitObject = nil;
        [mockNotification loadIconWithBlock:^(NSError* error) {
          waitObject = [error retain];
        }];
        
        [[expectFutureValue(waitObject) shouldEventually] beKindOfClass:[NSError class]];
      });
      
      it(@"should handle missing block in icon download", ^{
        [mockNotification loadIconWithBlock:nil];
      });

    });
    
  });

});

SPEC_END
