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
#import "GreeAnalyticsEvent.h"
#import "GreeAnalyticsEventArray.h"
#import "NSString+GreeAdditions.h"


@interface GreeAnalyticsEvent (ExposePrivateAPIs)
- (id)initWithType:(NSString *)type
              name:(NSString *)name
              from:(NSString *)from
        issuedTime:(NSDate*)issuedTime
        parameters:(NSDictionary *)parameters;
@end


SPEC_BEGIN(GreeAnalyticsEventArrayTest)

describe(@"GreeAnalyticsEventArray", ^{

  it(@"should initialize with the default initializer", ^{
    GreeAnalyticsEventArray *events = [GreeAnalyticsEventArray events];
    [[events shouldNot] beNil];
    [[theValue([events haveMarkedEvents]) should] beNo];
    [[events should] beEmpty];
    [[theValue(events.maximumStorageTime) should] equal:0.f withDelta:0.f];
  });

  it(@"should allow adding an event", ^{
    GreeAnalyticsEventArray *events = [[GreeAnalyticsEventArray alloc] init];
    GreeAnalyticsEvent *event = [GreeAnalyticsEvent eventWithType:@"tp" name:@"xxx" from:@"yyy" parameters:nil];
    [events addObject:event];
    [[events should] contain:event];
    [[events should] haveCountOf:1];
    [events release]; 
  });

  it(@"should remove all events", ^{
    GreeAnalyticsEventArray *events = [[GreeAnalyticsEventArray alloc] init];
    events.maximumStorageTime = 43200.f;
    [events addObject:[GreeAnalyticsEvent eventWithType:@"tp" name:@"xxx" from:@"yyy" parameters:nil]];
    [events addObject:[GreeAnalyticsEvent eventWithType:@"tp" name:@"xxx" from:@"yyy" parameters:nil]];
    [events dropOutOfStorageTimeEvents];
    [[theValue([events haveMarkedEvents]) should] beYes];
    [events removeAllObjects];
    [[events should] beEmpty];
    [[theValue([events haveMarkedEvents]) should] beNo];
    [events release];
  });

  it(@"should remove marked events", ^{
    GreeAnalyticsEventArray *events = [[GreeAnalyticsEventArray alloc] init];
    events.maximumStorageTime = 43200.f;

    NSDate* expiredTime = [NSDate dateWithTimeIntervalSince1970:0.f];
    GreeAnalyticsEvent* expiredEvent = [[GreeAnalyticsEvent alloc]
                                        initWithType:@"tp"
                                        name:@"xxx"
                                        from:@"yyy"
                                        issuedTime:expiredTime
                                        parameters:nil];
    [events addObject:expiredEvent];
    [events addObject:[GreeAnalyticsEvent eventWithType:@"tp" name:@"xxx" from:@"yyy" parameters:nil]];
    [events addObject:[GreeAnalyticsEvent eventWithType:@"tp" name:@"xxx" from:@"yyy" parameters:nil]];
    [events dropOutOfStorageTimeEvents];
    [[theValue([events haveMarkedEvents]) should] beYes];
    [[[events eventsInMarked] should] haveCountOf:2];
    [events removeMarkedEvents];
    [[events should] beEmpty];
    [expiredEvent release];
    [events release];
  });
  
  context(@"working with the file system", ^{
    __block GreeAnalyticsEventArray* events = nil;
    __block NSURL* fileURL = nil;
    
    beforeEach(^{
      NSString* outputPath = [NSString greeCachePathForRelativePath:@"analyticsEventArrayTests/events.plist"];
      [[NSFileManager defaultManager]
       removeItemAtPath:[outputPath stringByDeletingLastPathComponent]
       error:nil];
      [[NSFileManager defaultManager]
       createDirectoryAtPath:[outputPath stringByDeletingLastPathComponent]
       withIntermediateDirectories:YES
       attributes:nil
       error:nil];

      fileURL = [[NSURL fileURLWithPath:outputPath] retain];

      events = [[GreeAnalyticsEventArray alloc] init];
      [events addObject:[GreeAnalyticsEvent eventWithType:@"tp" name:@"xxx" from:@"yyy" parameters:nil]];
    });
    
    afterEach(^{
      [events release], events = nil;
      [fileURL release], fileURL = nil;
    });

    it(@"should be able to write the events to a file", ^{
      [[theValue([events storeToFileURL:fileURL]) should] beYes];
      BOOL success = [[NSFileManager defaultManager] fileExistsAtPath:[fileURL path]];
      [[theValue(success) should] beYes];
    });
    
    it(@"should be able to read the events from a file", ^{
      [[theValue([events storeToFileURL:fileURL]) should] beYes];
      
      GreeAnalyticsEventArray* storedEvents = [GreeAnalyticsEventArray eventsFromFileURL:fileURL];
      [[storedEvents shouldNot] beNil];
      [[theValue([storedEvents count]) should] equal:theValue(1)];

      GreeAnalyticsEvent* anEvent = [storedEvents objectAtIndex:0];
      [[anEvent.type should] equal:@"tp"];
      [[anEvent.name should] equal:@"xxx"];
      [[anEvent.from should] equal:@"yyy"];
      [anEvent.parameters shouldBeNil];
    });
    
    it(@"should not store any content if passed a non-file URL for storing data", ^{    
      NSURL *cachesURL = [NSURL URLWithString:@"mockURL://"];
      [[theValue([events storeToFileURL:cachesURL]) should] beNo];
    });
    
    it(@"should not load any content if passed a non-file URL for retrieving data", ^{    
      NSURL *cachesURL = [NSURL URLWithString:@"mockURL://"];
      GreeAnalyticsEventArray* storedEvents = [GreeAnalyticsEventArray eventsFromFileURL:cachesURL];
      [storedEvents shouldBeNil];
    });
  });
});

SPEC_END
