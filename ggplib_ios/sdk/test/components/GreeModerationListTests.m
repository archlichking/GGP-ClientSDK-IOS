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
#import "GreeModeratedText+Internal.h"
#import "GreeModerationList.h"
#import "GreeURLMockingProtocol.h"
#import "GreePlatform.h"
#import "GreeHTTPClient.h"
#import "GreeTestHelpers.h"

#pragma mark - GreeModerationListTests

static GreeModeratedText* fakeText(void);
static GreeModeratedText* fakeWithData(NSString* textId, GreeModerationStatus status, NSTimeInterval timeInterval);
static NSMutableDictionary* buildFromList(NSArray* items);

static GreeModeratedText* fakeText(void) 
{
  GreeModeratedText* fakeAText = [[[GreeModeratedText alloc] init] autorelease];
  [fakeAText setValue:@"FAKE" forKey:@"textId"];
  return fakeAText;
}

static GreeModeratedText* fakeWithData(NSString* textId, GreeModerationStatus status, NSTimeInterval timeInterval)
{
  GreeModeratedText* fakeAText = [[[GreeModeratedText alloc] init] autorelease];
  [fakeAText setValue:textId forKey:@"textId"];
  fakeAText.status = status;
  if(timeInterval) {
    [fakeAText setValue:[NSDate dateWithTimeIntervalSinceNow:-timeInterval] forKey:@"lastCheckedTimestamp"];
  }
  return fakeAText;  
}

static NSMutableDictionary* buildFromList(NSArray* items)
{
  NSMutableDictionary* dict = [NSMutableDictionary dictionary];
  for(GreeModeratedText* text in items) {
    [dict setObject:text forKey:text.textId];    
  }
  return dict;
}

@interface GreeModerationList (Testing)
- (void)setTimerWithInterval:(int64_t)interval;
@end

SPEC_BEGIN(GreeModerationListTests)


describe(@"GreeModerationList", ^{
  context(@"testing helpers", ^{
    beforeEach(^{
      [NSDate stub:@selector(date) andReturn:[NSDate date]];  //freeze time!
    });
    
    it(@"should set data properly", ^{
      GreeModeratedText* text = fakeWithData(@"FAKEID", GreeModerationStatusResultRejected, 20);
      [[text.textId should] equal:@"FAKEID"];
      [[theValue(text.status) should] equal:theValue(GreeModerationStatusResultRejected)];
      
      NSDate* fromObject = [text valueForKey:@"lastCheckedTimestamp"];
      NSTimeInterval interval = [fromObject timeIntervalSinceDate:[NSDate date]];
      [[theValue(interval) should] equal:-20 withDelta:0.001];
    });

    it(@"should allow null dates", ^{
      GreeModeratedText* text = fakeWithData(@"FAKEID", GreeModerationStatusResultRejected, 0);
      NSDate* fromObject = [text valueForKey:@"lastCheckedTimestamp"];
      [fromObject shouldBeNil];
    });

    it(@"should make lists", ^{
      GreeModeratedText* text1 = fakeWithData(@"one", GreeModerationStatusDeleted, 0);
      GreeModeratedText* text2 = fakeWithData(@"two", GreeModerationStatusDeleted, 0);
      NSDictionary* checkDict = buildFromList([NSArray arrayWithObjects:text1, text2, nil]);
      [[checkDict should] haveCountOf:2];
      [[checkDict should] haveValueForKey:@"one"];
      [[checkDict should] haveValueForKey:@"two"];
                                               
      
    });
    
    
  });
  
  
  
  
  
  it(@"should serialize on add", ^{
    GreeModerationList* testList = [[[GreeModerationList alloc] init] autorelease];
    
    NSUserDefaults* defaultMock = [NSUserDefaults nullMock];
    [[defaultMock should] receive:@selector(setObject:forKey:)];
    [NSUserDefaults stub:@selector(standardUserDefaults) andReturn:defaultMock];

    [testList addText:fakeText()];
//    [testList performSelector:@selector(serialize)];    
  });
  
  it(@"should serialize on remove", ^{
    GreeModerationList* testList = [[[GreeModerationList alloc] init] autorelease];
    [[testList valueForKey:@"textList"] setObject:fakeText() forKey:@"FAKE"];
    
    NSUserDefaults* defaultMock = [NSUserDefaults nullMock];
    [[defaultMock should] receive:@selector(setObject:forKey:)];
    [NSUserDefaults stub:@selector(standardUserDefaults) andReturn:defaultMock];
    
    [testList removeText:fakeText()];
  });
  
  it(@"should deserialize when initialized", ^{
    NSUserDefaults* defaultMock = [NSUserDefaults nullMock];
    NSDictionary* fakeTextObject = [NSDictionary dictionaryWithObject:@"FAKE" forKey:@"textId"];
    NSDictionary* fakeList = [NSDictionary dictionaryWithObject:fakeTextObject forKey:@"FAKE"];
    NSDictionary* fakeDictionary = [NSDictionary dictionaryWithObject:fakeList forKey:@"GreeModeratedTexts"];
    
    [[defaultMock should] receive:@selector(objectForKey:) andReturn:fakeDictionary];
    [NSUserDefaults stub:@selector(standardUserDefaults) andReturn:defaultMock];
    
    GreeModerationList* testList = [[[GreeModerationList alloc] initWithSerialization] autorelease];
    [[[testList valueForKey:@"textList"] should] haveCountOf:1];
    [testList finish];
  });
  
  it(@"should timer periodically", ^{
    GreeModerationList* testList = [[[GreeModerationList alloc] init] autorelease];
    [[testList should] receive:@selector(process) withCountAtLeast:4];
//    [testList stub:@selector(process)];
    
    [testList setTimerWithInterval:0.2];
    
    __block id wait = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [NSThread sleepForTimeInterval:1];
      wait = @"DONE";
    });
    
    [[expectFutureValue(wait) shouldEventuallyBeforeTimingOutAfter(2)] equal:@"DONE"];
    [testList finish];
  });
  
  it(@"should trap multiple timers", ^{
    GreeModerationList* testList = [[[GreeModerationList alloc] init] autorelease];
    [testList setTimerWithInterval:0.1];
    [testList setTimerWithInterval:0.2];
    //this should make the test coverage work, but how can I make sure it works?
  });
  
  it(@"should show a description", ^{
    GreeModerationList* testList = [[[GreeModerationList alloc] init] autorelease];
    NSString* expected = [NSString stringWithFormat:@"<GreeModerationList:%p textList:{\n}>", testList];
    [[testList.description should] equal:expected];
    
    
  });
  
  context(@"when updating", ^{
    __block GreePlatform* mockedSdk = nil;
    __block GreeModerationList* testList;
    beforeEach(^{
      mockedSdk = [[GreePlatform nullMockAsSharedInstance] retain];
      [mockedSdk stub:@selector(httpClient) andReturn:[GreeHTTPClient nullMock]];
      [GreeURLMockingProtocol register];
      
      testList = [[GreeModerationList alloc] init];
//      [testList stub:@selector(setTimerWithInterval:)];  //the timer stuff can't safely be included here
    });
    
    afterEach(^{
      [testList release];
      
      [GreeURLMockingProtocol unregister];
      [mockedSdk release];
      mockedSdk = nil;
    });
    
    it(@"should update some statuses when missing timestamps", ^{
      __block id waitObject = nil;
      MockedURLResponse* mock = [[[MockedURLResponse alloc] init] autorelease];
      mock.requestBlock = ^(NSURLRequest* req){
        [[theValue([req.URL.absoluteString rangeOfString:@"under"].location) shouldNot] equal:theValue(NSNotFound)];
        [[theValue([req.URL.absoluteString rangeOfString:@"deleted"].location) should] equal:theValue(NSNotFound)];
        [[theValue([req.URL.absoluteString rangeOfString:@"approved"].location) shouldNot] equal:theValue(NSNotFound)];
        [[theValue([req.URL.absoluteString rangeOfString:@"rejected"].location) should] equal:theValue(NSNotFound)];
        waitObject = @"DONE";
        return YES;
      };
      [GreeURLMockingProtocol addMock:mock];
      
      GreeModeratedText* beingChecked = fakeWithData(@"under", GreeModerationStatusBeingChecked, 0);
      GreeModeratedText* deleted = fakeWithData(@"deleted", GreeModerationStatusDeleted, 0);
      GreeModeratedText* approved = fakeWithData(@"approved", GreeModerationStatusResultApproved, 0);
      GreeModeratedText* rejected = fakeWithData(@"rejected", GreeModerationStatusResultRejected, 0);
      [testList setValue:buildFromList([NSArray arrayWithObjects:beingChecked, deleted, rejected, approved, nil]) forKey:@"textList"];
      
      [testList performSelector:@selector(process)];
      [[expectFutureValue(waitObject) shouldEventually] equal:@"DONE"];
    });
    
    it(@"should update if time expired", ^{
      __block id waitObject = nil;
      MockedURLResponse* mock = [[[MockedURLResponse alloc] init] autorelease];
      mock.requestBlock = ^(NSURLRequest* req){
        [[theValue([req.URL.absoluteString rangeOfString:@"under"].location) shouldNot] equal:theValue(NSNotFound)];
        [[theValue([req.URL.absoluteString rangeOfString:@"approved"].location) shouldNot] equal:theValue(NSNotFound)];
        waitObject = @"DONE";
        return YES;
      };
      [GreeURLMockingProtocol addMock:mock];
      
      GreeModeratedText* beingChecked = fakeWithData(@"under", GreeModerationStatusBeingChecked, 3.01*60*60);
      GreeModeratedText* approved = fakeWithData(@"approved", GreeModerationStatusResultApproved, 24.01*60*60);
      [testList setValue:buildFromList([NSArray arrayWithObjects:beingChecked, approved, nil]) forKey:@"textList"];
      
      [testList performSelector:@selector(process)];
      [[expectFutureValue(waitObject) shouldEventually] equal:@"DONE"];
    });
        
    it(@"should not update some statuses", ^{
      //no mocks set, because we want to fail if they are called
      GreeModeratedText* beingChecked = fakeWithData(@"under", GreeModerationStatusBeingChecked, 2.95*60*60);
      GreeModeratedText* deleted = fakeWithData(@"deleted", GreeModerationStatusDeleted, 0);
      GreeModeratedText* approved = fakeWithData(@"approved", GreeModerationStatusResultApproved, 23.95*60*60);
      GreeModeratedText* rejected = fakeWithData(@"rejected", GreeModerationStatusResultRejected, 0);
      [testList setValue:buildFromList([NSArray arrayWithObjects:beingChecked, deleted, rejected, approved, nil]) forKey:@"textList"];

      [testList performSelector:@selector(process)];
    });
    
    it(@"should send updates", ^{
      __block id waitObject = nil;
      MockedURLResponse* mock = [[[MockedURLResponse alloc] init] autorelease];
      
      NSString* returnObject = @"{ \"textId\": \"under\", \"status\" : \"2\" }";
      NSData* returnData = [[NSString stringWithFormat:@"{\"entry\":[%@]}", returnObject] dataUsingEncoding:NSUTF8StringEncoding];
      mock.data = returnData;
      [GreeURLMockingProtocol addMock:mock];
      
      GreeModeratedText* beingChecked = fakeWithData(@"under", GreeModerationStatusBeingChecked, 0);
      [testList setValue:buildFromList([NSArray arrayWithObjects:beingChecked, nil]) forKey:@"textList"];
      
      NSDate* dateBeforeProcessed = [beingChecked valueForKey:@"lastCheckedTimestamp"];
      [dateBeforeProcessed shouldBeNil];

      [[NSNotificationCenter defaultCenter] addObserverForName:GreeModeratedTextUpdatedNotification object:beingChecked queue:nil usingBlock:^(NSNotification *note) {
        waitObject = @"DONE";
        NSDate* date = [beingChecked valueForKey:@"lastCheckedTimestamp"];
        [date shouldNotBeNil];
        [[date should] beKindOfClass:[NSDate class]];
      }];
      
      [testList performSelector:@selector(process)];
      
      [[expectFutureValue(waitObject) shouldEventually] equal:@"DONE"];
    });
    
    
  });
  
  
  
});

SPEC_END
