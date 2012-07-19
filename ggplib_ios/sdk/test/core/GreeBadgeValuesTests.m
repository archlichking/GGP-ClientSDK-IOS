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
#import "GreeSerializer.h"
#import "GreeBadgeValues+Internal.h"
#import "GreeURLMockingProtocol.h"
#import "GreePlatform.h"
#import "GreeTestHelpers.h"

#pragma mark - GreeBadgeValuesTests

static NSString *postBodyResponse = @"{                  " 
                                     " \"entry\": {      "
                                     "     \"sns\":1,    "
                                     "     \"app\":1     "
                                     "   }               "
                                     "}                  ";

SPEC_BEGIN(GreeBadgeValuesTests)
describe(@"GreeBadgeValues", ^{
  it(@"should deserialize", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInteger:1], @"sns",
                                [NSNumber numberWithInteger:1], @"app",
                                nil];
    
    GreeSerializer* serializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeBadgeValues* values = [[GreeBadgeValues alloc] initWithGreeSerializer:serializer];
    [[theValue(values.socialNetworkingServiceBadgeCount) should] equal:theValue(1)];
    [[theValue(values.applicationBadgeCount) should] equal:theValue(1)];
    [values release];
  });
  
  it(@"should serialize", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInteger:1], @"sns",
                                [NSNumber numberWithInteger:1], @"app",
                                nil];
                                   
    GreeSerializer* deserializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeBadgeValues* values = [[GreeBadgeValues alloc] initWithGreeSerializer:deserializer];
    GreeSerializer* serializer = [GreeSerializer serializer];
    [values serializeWithGreeSerializer:serializer];
    [[serializer.rootDictionary should] equal:serialized];
    [values release];
  });
  
  it(@"should show description", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithInteger:1], @"sns",
                                [NSNumber numberWithInteger:1], @"app",
                                nil];
                                   
    GreeSerializer* deserializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeBadgeValues* values = [[GreeBadgeValues alloc] initWithGreeSerializer:deserializer];
    
    NSString* expected = [NSString stringWithFormat:@"<GreeBadgeValues:%p, sns:1, app:1>",
      values];
    
    [[[values description] should] equal:expected];
    
    [values release];
  });
  
  context(@"when loading the badge values", ^{
    beforeEach(^{
      GreePlatform* mockedSdk = [GreePlatform nullMockAsSharedInstance];
      [mockedSdk stub:@selector(httpClient) andReturn:[GreeHTTPClient nullMock]];
      [GreeURLMockingProtocol register];
    });
    
    afterEach(^{
      [GreeURLMockingProtocol unregister];
    });
  
    it(@"should do nothing (and not crash) if it is not passed a block", ^{
      [GreeBadgeValues loadBadgeValuesForCurrentApplicationWithBlock:nil];
    });
    
    it(@"should fetch the badge numbers for the current application", ^{
      __block id waitObject = nil;
    
      MockedURLResponse* mock = [[[MockedURLResponse alloc] init] autorelease];
      mock.data = [[NSString stringWithFormat:postBodyResponse] dataUsingEncoding:NSUTF8StringEncoding];
      [GreeURLMockingProtocol addMock:mock];
      
      [GreeBadgeValues loadBadgeValuesForCurrentApplicationWithBlock:^(GreeBadgeValues *values, NSError *error){
        waitObject = [values retain];
      }];
      
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      
      GreeBadgeValues *badgeValues = (GreeBadgeValues*)waitObject;
           
      [[theValue(badgeValues.socialNetworkingServiceBadgeCount) should] equal:theValue(1)];
      [[theValue(badgeValues.applicationBadgeCount) should] equal:theValue(1)];
      
      [waitObject release];
    });
    
    it(@"should handle failure when fetching badge numbers for the current application", ^{
      __block id waitObject = nil;
    
      MockedURLResponse* mock = [[[MockedURLResponse alloc] init] autorelease];
      mock.statusCode = 500;
      [GreeURLMockingProtocol addMock:mock];
      
      [GreeBadgeValues loadBadgeValuesForCurrentApplicationWithBlock:^(GreeBadgeValues *values, NSError *error){
        waitObject = [error copy];
      }];
      
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      [waitObject release];
    });
    
    it(@"should do nothing (and not crash) if it is not passed a block", ^{
      [GreeBadgeValues loadBadgeValuesForAllApplicationsWithBlock:nil];
    });
    
    it(@"should fetch the badge numbers for all applications", ^{
      __block id waitObject = nil;
    
      MockedURLResponse* mock = [[[MockedURLResponse alloc] init] autorelease];
      mock.data = [[NSString stringWithFormat:postBodyResponse] dataUsingEncoding:NSUTF8StringEncoding];
      [GreeURLMockingProtocol addMock:mock];
      
      [GreeBadgeValues loadBadgeValuesForAllApplicationsWithBlock:^(GreeBadgeValues *values, NSError *error){
        waitObject = [values retain];
      }];
      
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      
      GreeBadgeValues *badgeValues = (GreeBadgeValues*)waitObject;
           
      [[theValue(badgeValues.socialNetworkingServiceBadgeCount) should] equal:theValue(1)];
      [[theValue(badgeValues.applicationBadgeCount) should] equal:theValue(1)];
      
      [waitObject release];
    });
    
    it(@"should handle failure when fetching badge numbers for the all applications", ^{
      __block id waitObject = nil;
    
      MockedURLResponse* mock = [[[MockedURLResponse alloc] init] autorelease];
      mock.statusCode = 500;
      [GreeURLMockingProtocol addMock:mock];
      
      [GreeBadgeValues loadBadgeValuesForAllApplicationsWithBlock:^(GreeBadgeValues *values, NSError *error){
        waitObject = [error copy];
      }];
      
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      [waitObject release];
    });
  });
  
  it(@"should reset badge values of its observers", ^{
    __block id waitObject = nil;

    id notificationHandler = [[NSNotificationCenter defaultCenter]
      addObserverForName:GreeBadgeValuesDidUpdateNotification
      object:nil
      queue:[NSOperationQueue mainQueue]
      usingBlock:^(NSNotification* notification) {
        waitObject = [notification.object retain];
    }];

    [GreeBadgeValues resetBadgeValues];

    GreeBadgeValues *badgeValues = (GreeBadgeValues*)waitObject;

    [[theValue(badgeValues.socialNetworkingServiceBadgeCount) should] equal:theValue(0)];
    [[theValue(badgeValues.applicationBadgeCount) should] equal:theValue(0)];

    [[NSNotificationCenter defaultCenter] removeObserver:notificationHandler];
    [waitObject release];    
  });
});
SPEC_END
