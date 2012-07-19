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
#import "GreePlatform.h"
#import "GreeHTTPClient.h"
#import "GreeURLMockingProtocol.h"
#import "AFNetworking.h"
#import "GreeAnalyticsEvent.h"
#import "GreeAnalyticsQueue.h"
#import "GreeTestHelpers.h"
#import "NSDateFormatter+GreeAdditions.h"
#import "NSString+GreeAdditions.h"
#import "GreeKeyChain.h"
#import "GreeMatchers.h"
#import "GreeNSNotification+Internal.h"

@interface GreeAnalyticsQueue (CategoryToRemoveComplierWarnings)
- (id)item;
- (id)items;
+ (NSURL*)cachesURL;
- (BOOL)storeEventsToFileURL:(NSURL*)fileURL;
- (BOOL)loadEventsFromFileURL:(NSURL*)fileURL;
- (void)addInitialPollingEvent;
- (NSArray *)filterFlushEvents:(NSArray *)events;
@property (nonatomic, retain) NSMutableArray *events;
@property (nonatomic, assign) NSTimeInterval pollingInterval;
@property (nonatomic, assign) NSTimeInterval maximumStorageTime;
@end


SPEC_BEGIN(GreeAnalyticsQueueTest)
describe(@"GreeAnalyticsQueue", ^{
  registerMatchers(@"Gree");
  beforeEach(^ {
    GreePlatform* sdk = [GreePlatform nullMockAsSharedInstance];
    [sdk stub:@selector(httpClient) andReturn:[GreeHTTPClient nullMock]];
    [GreeURLMockingProtocol register];
    
    //tests are all assuming that a user was logged in
    [GreeKeyChain stub:@selector(readWithKey:) andReturn:@"fake"];
  });
  
  afterEach(^{
    [GreeURLMockingProtocol unregister];
  });
  
  it(@"should initialize with the default initializer", ^{
    GreeAnalyticsQueue *queue = [[GreeAnalyticsQueue alloc] init];
    [[queue shouldNot] beNil];
    [queue release];
  });
 
  it(@"should initialize with the GreeSettings initializer", ^{
    GreeAnalyticsQueue *queue = [[GreeAnalyticsQueue alloc] initWithSettings:nil];
    [[queue shouldNot] beNil];
    [queue release];
  });

  
  
  context(@"when user changes", ^{
    it(@"should not include initial polling if it doesn't check the initial user", ^{
      [GreeKeyChain stub:@selector(readWithKey:) andReturn:nil];
      GreeAnalyticsQueue *queue = [[GreeAnalyticsQueue alloc] initWithSettings:nil];
      [[[queue.events should] have:0] item];
      [queue release];    
    });
    
    it(@"should start timer on login", ^{
      [GreeKeyChain stub:@selector(readWithKey:) andReturn:nil];
      GreeAnalyticsQueue *queue = [[GreeAnalyticsQueue alloc] initWithSettings:nil];
      [[queue should] receive:@selector(startPollingTimer)];
      [[NSNotificationCenter defaultCenter]postNotificationName:GreeNSNotificationUserLogin object:nil];
      [[[queue.events should] have:1] item];
      [queue release];
    });

//    it(@"should stop timer on invalidate", ^{
//      GreeAnalyticsQueue *queue = [[GreeAnalyticsQueue alloc] initWithSettings:nil];
//      [[queue should] receive:@selector(stopPollingTimer)];
//      [[NSNotificationCenter defaultCenter]postNotificationName:GreeNSNotificationUserInvalidated object:nil];
//      [queue release];
//    });
//    it(@"should stop timer on logout", ^{
//      GreeAnalyticsQueue *queue = [[GreeAnalyticsQueue alloc] initWithSettings:nil];
//      [[queue should] receive:@selector(stopPollingTimer)];
//      [[NSNotificationCenter defaultCenter]postNotificationName:GreeNSNotificationUserLogout object:nil];
//      [queue release];
//    });
    
  });
  
  it(@"should show description", ^{
    GreeAnalyticsQueue *queue = [[GreeAnalyticsQueue alloc] init];
    
    [[[queue description] should] matchRegExp:@"<GreeAnalyticsQueue:0x[0-9a-f]+, eventCount:0, pollingInterval:300.000000>"];
    [queue release]; 
  });

  it(@"should allow adding an event", ^{
    GreeAnalyticsQueue *queue = [[GreeAnalyticsQueue alloc] init];
    
    GreeAnalyticsEvent *event = [GreeAnalyticsEvent eventWithType:@"tp" name:@"xxx" from:@"yyy" parameters:nil];
    
    [queue addEvent:event];
    
    [[[queue.events should] have:1] item];
    [queue release]; 
  });

  it(@"should flush events", ^{
    __block BOOL success = NO;
    
    MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
    mock.statusCode = 200;
    [GreeURLMockingProtocol addMock:mock];
    
    GreeAnalyticsQueue *queue = [[GreeAnalyticsQueue alloc] init];
    
    GreeAnalyticsEvent *event1 = [GreeAnalyticsEvent eventWithType:@"tp" name:@"xxx1" from:@"yyy1" parameters:nil];
    GreeAnalyticsEvent *event2 = [GreeAnalyticsEvent eventWithType:@"tp" name:@"xxx2" from:@"yyy2" parameters:nil];
    GreeAnalyticsEvent *event3 = [GreeAnalyticsEvent eventWithType:@"tp" name:@"xxx3" from:@"yyy3" parameters:nil];
    
    [queue addEvent:event1];
    [queue addEvent:event2];
    [queue addEvent:event3];
    
    [[[queue.events should] have:3] items];
    
    [queue flushWithBlock:^(NSError *error) {      
      success = YES;
    }];
    
    [[expectFutureValue(theValue(success)) shouldEventually] beYes];
    
    [[[queue.events should] have:0] items];
    [queue release]; 
  });
  
  it(@"should add idle events", ^{
    GreeAnalyticsQueue *queue = [[GreeAnalyticsQueue alloc] init];
    GreeAnalyticsEvent *event1 = [GreeAnalyticsEvent eventWithType:@"tp" name:@"xxx1" from:@"yyy1" parameters:nil];
    [queue addEvent:event1];

    [queue stub:@selector(flushWithBlock:)];
    
    queue.pollingInterval = 0.05; 
    
    __block id wait = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [NSThread sleepForTimeInterval:0.15];
      wait = @"DONE";
    });
    
    [[expectFutureValue(wait) shouldEventuallyBeforeTimingOutAfter(1)] equal:@"DONE"];
    [[[queue.events objectAtIndex:0] should] beNonNil];
  });
  
  context(@"flushing", ^{

    pending(@"should flush after idle delay", ^{
      //how can I test this delay      
    });

    it(@"should require delay between flushes", ^{
      __block id endState = nil;
      __block id endState2 = nil;
      MockedURLResponse* mock = [[[MockedURLResponse alloc] init] autorelease];
      [GreeURLMockingProtocol addMock:mock];
      
      GreeAnalyticsQueue *queue = [[GreeAnalyticsQueue alloc] init];
      GreeAnalyticsEvent *event1 = [GreeAnalyticsEvent eventWithType:@"tp" name:@"xxx1" from:@"yyy1" parameters:nil];
      [queue addEvent:event1];
      
      //first flush to set up the timer
      [queue flushWithBlock:^(NSError *error) {
        endState = @"GOOD";
      }];
      
      [[expectFutureValue(endState) shouldEventually] equal:@"GOOD"];
      
      //second flush should not happen
      [queue addEvent:event1];
      [queue flushWithBlock:^(NSError *error) {
        endState2 = @"EXPECTED";
      }];

      [[expectFutureValue(endState2) shouldEventually] equal:@"EXPECTED"];
    });
    
    it(@"should do nothing if passed a nil block", ^{
      GreeAnalyticsQueue *queue = [[GreeAnalyticsQueue alloc] init];
      GreeAnalyticsEvent *event1 = [GreeAnalyticsEvent eventWithType:@"tp" name:@"xxx1" from:@"yyy1" parameters:nil];
      [queue addEvent:event1];
      
      [queue flushWithBlock:nil];      
    });
    
    it(@"should return any errors", ^{
      __block BOOL success = NO;
      __block id responseObject = nil;
      
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      mock.statusCode = 503;
      [GreeURLMockingProtocol addMock:mock];
      
      GreeAnalyticsQueue *queue = [[GreeAnalyticsQueue alloc] init];
      
      GreeAnalyticsEvent *event = [GreeAnalyticsEvent eventWithType:@"tp" name:@"xxx1" from:@"yyy1" parameters:nil];
      
      [queue addEvent:event];
      
      [[[queue.events should] have:1] item];
      
      [queue flushWithBlock:^(NSError *error) {
        success = YES;
        responseObject = [error retain];
      }];
      
      [[expectFutureValue(theValue(success)) shouldEventually] beYes];
      [[responseObject shouldNot] beNil];
      
      [[[queue.events should] have:1] item];
      [responseObject release];
      [queue release]; 
    });
    
    context(@"during flush", ^{
      it(@"should allow adding to queue", ^{
        __block id endState = nil;
        MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
        [GreeURLMockingProtocol addMock:mock];
        GreeAnalyticsQueue *queue = [[GreeAnalyticsQueue alloc] init];
        GreeAnalyticsEvent *event = [GreeAnalyticsEvent eventWithType:@"tp" name:@"xxx1" from:@"yyy1" parameters:nil];
        [queue addEvent:event];
        
        [queue flushWithBlock:^(NSError *error) {
          endState = @"DONE";
        }];
        GreeAnalyticsEvent *event2 = [GreeAnalyticsEvent eventWithType:@"tp" name:@"xxx2" from:@"yyy2" parameters:nil];
        [queue addEvent:event2];
        
        [[expectFutureValue(endState) shouldEventually] beNonNil];
        [[queue.events should] contain:event2];
      });
      
      it(@"should merge if send fails", ^{
        __block id endState = nil;
        MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
        [GreeURLMockingProtocol addMock:mock];
        mock.statusCode = 503;
        GreeAnalyticsQueue *queue = [[GreeAnalyticsQueue alloc] init];
        GreeAnalyticsEvent *event1 = [GreeAnalyticsEvent eventWithType:@"tp" name:@"xxx1" from:@"yyy1" parameters:nil];
        [queue addEvent:event1];
        
        [queue flushWithBlock:^(NSError *error) {
          endState = @"DONE";
        }];
        GreeAnalyticsEvent *event2 = [GreeAnalyticsEvent eventWithType:@"tp" name:@"xxx2" from:@"yyy2" parameters:nil];
        [queue addEvent:event2];
        
        [[expectFutureValue(endState) shouldEventually] beNonNil];
        [[queue.events should] contain:event1];
        [[queue.events should] contain:event2];
        
      });
    });
  });

});
SPEC_END
