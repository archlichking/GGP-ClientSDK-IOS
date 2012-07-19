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
#import "GreeJSSyncCommand.h"
#import "GreeWebAppCache.h"
#import "GreeWebAppCacheItem.h"
#import "GreeMatchers.h"

@interface GreeJSSyncCommand (PrivateMethods)
- (NSArray*)updatedFiles;
- (NSArray*)failedFiles;
@end

SPEC_BEGIN(GreeJSSyncCommandTest)

describe(@"GreeJSSyncCommand",^{
  registerMatchers(@"Gree");
  
  __block GreeWebAppCache *cache = nil;
    
  beforeEach(^{
    cache = [GreeWebAppCache nullMock];
  });
    
  afterEach(^{
    cache = nil;
  });
  
  it(@"should have a name", ^{
    [[[GreeJSSyncCommand name] should] equal:@"sync"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSSyncCommand *command = [[GreeJSSyncCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSSyncCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{  
    it(@"should do nothing if the 'app' parameter is not specified", ^{
      NSDictionary *parameters = [NSDictionary dictionary];
      
      [[cache shouldNot] receive:@selector(startSync)];
      [GreeWebAppCache stub:@selector(appCacheForName:) andReturn:cache];
      
      GreeJSSyncCommand *command = [[GreeJSSyncCommand alloc] init];
      [command execute:parameters];
      [command release];
    });
    
    it(@"should do nothing if the 'app' parameter is not specified", ^{
      NSDictionary *parameters = [NSDictionary dictionary];
      
      [[cache shouldNot] receive:@selector(startSync)];
      [GreeWebAppCache stub:@selector(appCacheForName:) andReturn:cache];
      
      GreeJSSyncCommand *command = [[GreeJSSyncCommand alloc] init];
      [command execute:parameters];
      [command release];
    });
    
    it(@"should do nothing if the cache is nil and the base URL parameter is nil", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockApp", @"app", nil];
      
      [GreeWebAppCache stub:@selector(appCacheForName:) andReturn:nil];
      [[GreeWebAppCache shouldNot] receive:@selector(registerAppCacheForName:withBaseURL:)];
      
      NSURL *url = [NSURL nullMock];
      [url stub:@selector(initWithString:) andReturn:nil];
      [NSURL stub:@selector(alloc) andReturn:url];
      
      GreeJSSyncCommand *command = [[GreeJSSyncCommand alloc] init];
      [command execute:parameters];
      [command release];
    });

    it(@"should register the cache if it is nil", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockApp", @"app", nil];
      
      [GreeWebAppCache stub:@selector(appCacheForName:) andReturn:nil];
      [[GreeWebAppCache should] receive:@selector(registerAppCacheForName:withBaseURL:)];
      
      [NSURL stub:@selector(URLWithString:) andReturn:[NSURL nullMock]];
      
      GreeJSSyncCommand *command = [[GreeJSSyncCommand alloc] init];
      [command execute:parameters];
      [command release];
    });

    it(@"should set the baseURL to the cache URL if the base URL is nil", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockApp", @"app", nil];
      
      [[cache should] receive:@selector(baseURL) andReturn:[NSURL nullMock]];
      [GreeWebAppCache stub:@selector(appCacheForName:) andReturn:cache];
      
      NSURL *url = [NSURL nullMock];
      [url stub:@selector(initWithString:) andReturn:nil];
      [NSURL stub:@selector(alloc) andReturn:url];
      
      GreeJSSyncCommand *command = [[GreeJSSyncCommand alloc] init];
      [command execute:parameters];
      [command release];
    });

    it(@"should not handle a file object if it is not a dictionary", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockApp", @"app",
        [NSArray arrayWithObject:[[[NSObject alloc] init] autorelease]], @"files", nil];
        
      
      [[cache should] receive:@selector(baseURL) andReturn:[NSURL nullMock]];
      [GreeWebAppCache stub:@selector(appCacheForName:) andReturn:cache];
      
      NSURL *url = [NSURL nullMock];
      [url stub:@selector(initWithString:) andReturn:nil];
      [NSURL stub:@selector(alloc) andReturn:url];
      
      GreeJSSyncCommand *command = [[GreeJSSyncCommand alloc] init];
      [command execute:parameters];
      [command release];
    });
    
    it(@"should add the file to the failed file list if its version is less than the cached version", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockApp", @"app",
        [NSArray arrayWithObject:[NSDictionary dictionary]], @"files", nil];
              
      GreeWebAppCacheItem *item = [GreeWebAppCacheItem nullMock];
      [item stub:@selector(initWithDictionary:withBaseURL:) andReturn:item];
      [item stub:@selector(version) andReturn:theValue(1)];
      [GreeWebAppCacheItem stub:@selector(alloc) andReturn:item];
      
      [cache stub:@selector(versionOfCachedContentForURL:) andReturn:theValue(2)];
      [GreeWebAppCache stub:@selector(appCacheForName:) andReturn:cache];
      
      NSURL *url = [NSURL nullMock];
      [url stub:@selector(initWithString:) andReturn:nil];
      [NSURL stub:@selector(alloc) andReturn:url];
      
      GreeJSSyncCommand *command = [[GreeJSSyncCommand alloc] init];
      [[command.failedFiles should] receive:@selector(addObject:)];
      [command execute:parameters];
      [command release];
    });

    it(@"should check if the item is already in the queue", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockApp", @"app",
        [NSNumber numberWithLongLong:2], @"version",
        [NSArray arrayWithObject:[NSDictionary dictionary]], @"files", nil];
      
      GreeWebAppCacheItem *item = [GreeWebAppCacheItem nullMock];
      [item stub:@selector(initWithDictionary:withBaseURL:) andReturn:item];
      [item stub:@selector(version) andReturn:theValue(2)];
      [GreeWebAppCacheItem stub:@selector(alloc) andReturn:item];
      
      [cache stub:@selector(versionOfCachedContentForURL:) andReturn:theValue(1)];
      [[cache should] receive:@selector(isItemAlreadyInQueue:) andReturn:theValue(YES)];
      [GreeWebAppCache stub:@selector(appCacheForName:) andReturn:cache];
      
      NSURL *url = [NSURL nullMock];
      [url stub:@selector(initWithString:) andReturn:nil];
      [NSURL stub:@selector(alloc) andReturn:url];
      
      GreeJSSyncCommand *command = [[GreeJSSyncCommand alloc] init];
      [command execute:parameters];
      [command release];
    });

    it(@"should enqueue the item if it is not in the queue", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockApp", @"app",
        [NSNumber numberWithLongLong:2], @"version",
        [NSArray arrayWithObject:[NSDictionary dictionary]], @"files", nil];
      
      GreeWebAppCacheItem *item = [GreeWebAppCacheItem nullMock];
      [item stub:@selector(initWithDictionary:withBaseURL:) andReturn:item];
      [item stub:@selector(version) andReturn:theValue(2)];
      [GreeWebAppCacheItem stub:@selector(alloc) andReturn:item];
      
      [cache stub:@selector(versionOfCachedContentForURL:) andReturn:theValue(1)];
      [[cache should] receive:@selector(isItemAlreadyInQueue:) andReturn:theValue(NO)];
      [[cache should] receive:@selector(enqueueItem:) andReturn:theValue(YES)];
      [GreeWebAppCache stub:@selector(appCacheForName:) andReturn:cache];
      
      NSURL *url = [NSURL nullMock];
      [url stub:@selector(initWithString:) andReturn:nil];
      [NSURL stub:@selector(alloc) andReturn:url];
      
      GreeJSSyncCommand *command = [[GreeJSSyncCommand alloc] init];
      [command execute:parameters];
      [command release];
    });
  });
  
  it(@"should add a file to the updated file list when it receives an updated notification", ^{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
      @"mockApp", @"app", nil];
      
    [[cache should] receive:@selector(baseURL) andReturn:[NSURL nullMock]];
    [GreeWebAppCache stub:@selector(appCacheForName:) andReturn:cache];
      
    NSURL *url = [NSURL nullMock];
    [url stub:@selector(initWithString:) andReturn:nil];
    [NSURL stub:@selector(alloc) andReturn:url];
      
    GreeJSSyncCommand *command = [[GreeJSSyncCommand alloc] init];
    [[command.updatedFiles should] receive:@selector(addObject:)];

    [command execute:parameters];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GreeWebAppCacheFileUpdatedNotification
      object:cache
      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
        [NSURL URLWithString:@"mockURL://"], GreeWebAppCacheFileUpdatedNotificationUrlKey, nil]];
    
    [command release];
  });
  
  it(@"should add a file to the failed file list when it receives a failed notification", ^{
    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
      @"mockApp", @"app", nil];
      
    [[cache should] receive:@selector(baseURL) andReturn:[NSURL nullMock]];
    [GreeWebAppCache stub:@selector(appCacheForName:) andReturn:cache];
      
    NSURL *url = [NSURL nullMock];
    [url stub:@selector(initWithString:) andReturn:nil];
    [NSURL stub:@selector(alloc) andReturn:url];
      
    GreeJSSyncCommand *command = [[GreeJSSyncCommand alloc] init];
    [[command.failedFiles should] receive:@selector(addObject:)];

    [command execute:parameters];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GreeWebAppCacheFailedToUpdatNotification
      object:cache
      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
        [NSURL URLWithString:@"mockURL://"], GreeWebAppCacheFileUpdatedNotificationUrlKey, nil]];
    
    [command release];
  });
});

SPEC_END
