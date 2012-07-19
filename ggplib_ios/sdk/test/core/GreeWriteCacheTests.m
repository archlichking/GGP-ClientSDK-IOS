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
#import "GreeWriteCache.h"
#import "GreeSerializer.h"
#import "JSONKit.h"
#import "NSData+GreeAdditions.h"
#import "NSString+GreeAdditions.h"
#import "GreeAuthorization.h"

// Methods used for test validation
@interface GreeWriteCache (TestMethods)
- (NSInteger)immediatelyCountObjectOfClass:(Class)klass inCategory:(NSString*)category;
- (id)immediatelyReadNewestObjectOfClass:(Class)klass inCategory:(NSString*)category;
- (id)immediatelyReadOldestObjectOfClass:(Class)klass inCategory:(NSString*)category;
- (int64_t)immediatelyReadNewestRowIdOfClass:(Class)klass inCategory:(NSString*)category;
- (void)immediatelyWriteHash:(NSString*)hash forRowId:(int64_t)rowId;
- (NSString*)immediatelyReadHashForRowId:(int64_t)rowId;
@end

#pragma mark - Test Objects

static NSInteger CommitCountSuccess = 0;
static NSInteger CommitCountFailure = 0;
static BOOL CommitShouldFail = NO;
static float CommitDelay = 0.f;

@interface TestCacheable : NSObject<GreeWriteCacheable, GreeSerializable>
@property (nonatomic, readwrite, assign) NSInteger testInteger;
@property (nonatomic, readwrite, retain) NSString* testString;
@property (nonatomic, readwrite, retain) NSString* testCategory;
// designated initializer
- (id)initWithCategory:(NSString*)category;
- (NSString*)writeCacheCategory;
+ (NSInteger)writeCacheMaxCategorySize;
- (void)writeCacheCommitAndExecuteBlock:(void(^)(BOOL commitDidSucceed))block;
- (id)initWithGreeSerializer:(GreeSerializer*)serializer;
- (void)serializeWithGreeSerializer:(GreeSerializer*)serializer;
@end

@implementation TestCacheable

@synthesize testInteger = _testInteger;
@synthesize testString = _testString;
@synthesize testCategory = _testCategory;

- (id)initWithCategory:(NSString*)category
{
  self = [super init];
  if (self != nil) {
    _testCategory = [category retain];
  }

  return self;
}

- (NSString*)writeCacheCategory
{
  return self.testCategory;
}

+ (NSInteger)writeCacheMaxCategorySize
{
  return 5;
}

- (void)writeCacheCommitAndExecuteBlock:(void(^)(BOOL commitDidSucceed))block
{
  BOOL didSucceed = !CommitShouldFail;
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, CommitDelay * NSEC_PER_SEC);
  dispatch_after(popTime, dispatch_get_main_queue(), ^{
    block(didSucceed);
    if (didSucceed) {
      ++CommitCountSuccess;
    } else {
      ++CommitCountFailure;
    }
  });
}

- (id)initWithGreeSerializer:(GreeSerializer*)serializer
{
  self = [super init];
  if (self != nil) {
    _testInteger = [serializer integerForKey:@"testInteger"];
    _testString = [[serializer objectForKey:@"testString"] retain];
    _testCategory = [[serializer objectForKey:@"testCategory"] retain];
  }
  
  return self;
}

- (void)serializeWithGreeSerializer:(GreeSerializer*)serializer
{
  [serializer serializeInteger:self.testInteger forKey:@"testInteger"];
  [serializer serializeObject:self.testString forKey:@"testString"];
  [serializer serializeObject:self.testCategory forKey:@"testCategory"];
}

@end

@interface UnlimitedTestCacheable : TestCacheable
@end

@implementation UnlimitedTestCacheable

+ (NSInteger)writeCacheMaxCategorySize
{
  return GreeWriteCacheCategorySizeUnlimited;
}

@end

#pragma mark - GreeWriteCacheTests

// Use this macro to easily wait for a cache operation (which are all asynchronous) to complete
#define WAIT_FOR_OPERATION(handle) \
{ \
  __block NSString* sentinel__##handle = nil; \
  [writeCache observeWriteCacheOperation:handle forCompletionWithBlock:^{ \
    sentinel__##handle = @""; \
  }]; \
  [[expectFutureValue(sentinel__##handle) shouldEventuallyBeforeTimingOutAfter(10.f)] beNonNil]; \
} 
  
SPEC_BEGIN(GreeWriteCacheTests)

describe(@"GreeWriteCache", ^{
  __block GreeWriteCache* writeCache = nil;
  __block NSString* userId = nil;
  __block NSInteger counter = 0;
  __block GreeWriteCacheOperationHandle oh = NULL;

  // Each test will have it's own unique userId (and thus it's own cache)
  // Before each test we clear the results of any previous run (so after tests run we have results in-tact)
  beforeEach(^{
    userId = [[NSString alloc] initWithFormat:@"test%d", counter++];
    NSString* path = [NSString greeCachePathForRelativePath:[NSString stringWithFormat:@"writeCache_%@", userId]];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
  });
  
  afterEach(^{
    [userId release];
    userId = nil;
    oh = NULL;
  });
  
  it(@"should fail to initailize when not given a user id", ^{
    writeCache = [[GreeWriteCache alloc] initWithUserId:@""];
    [writeCache shouldBeNil];
    writeCache = nil;
  });
    
  context(@"with an empty cache", ^{
    __block GreeAuthorization *authMock;

    beforeEach(^{
      authMock = [[GreeAuthorization alloc] init];
      [authMock stub:@selector(isAuthorized) andReturn:theValue(YES)];
      [GreeAuthorization stub:@selector(sharedInstance) andReturn:authMock];
      
      writeCache = [[GreeWriteCache alloc] initWithUserId:userId];
    });
    
    afterEach(^{
      [authMock release];
      [writeCache release];
      writeCache = nil;
    });
    
    it(@"should create the write cache in the correct spot", ^{
      NSString* path = [NSString greeCachePathForRelativePath:[NSString stringWithFormat:@"writeCache_%@", userId]];
      [[theValue([[NSFileManager defaultManager] fileExistsAtPath:path]) should] beYes];
    });
    
    it(@"should have a method for unit tests to count objects by class and category", ^{
      TestCacheable* test = [[TestCacheable alloc] initWithCategory:@"category"];
      oh = [writeCache writeObject:test];
      [test release];
      WAIT_FOR_OPERATION(oh);
      
      [[theValue([writeCache immediatelyCountObjectOfClass:[TestCacheable class] inCategory:@"category"]) should] equal:theValue(1)];
    });
    
    it(@"should have a method for unit tests to read the newest object in a given category", ^{
      for (int i = 0; i < 2; ++i) {
        TestCacheable* test = [[TestCacheable alloc] initWithCategory:@"category"];
        test.testInteger = 10 * (i + 1);
        oh = [writeCache writeObject:test];
        [test release];
      }
      WAIT_FOR_OPERATION(oh);

      NSInteger newestTestInteger = [(TestCacheable*)[writeCache immediatelyReadNewestObjectOfClass:[TestCacheable class] inCategory:@"category"] testInteger];
      [[theValue(newestTestInteger) should] equal:theValue(20)];      
    });
    
    it(@"should have a method for unit tests to read the oldest object in a given category", ^{
      for (int i = 0; i < 2; ++i) {
        TestCacheable* test = [[TestCacheable alloc] initWithCategory:@"category"];
        test.testInteger = 10 * (i + 1);
        oh = [writeCache writeObject:test];
        [test release];
      }
      WAIT_FOR_OPERATION(oh);

      NSInteger oldestTestInteger = [(TestCacheable*)[writeCache immediatelyReadOldestObjectOfClass:[TestCacheable class] inCategory:@"category"] testInteger];
      [[theValue(oldestTestInteger) should] equal:theValue(10)];
    });
    
    it(@"should have a method for unit tests to read the newest rowId", ^{
      TestCacheable* test = [[TestCacheable alloc] initWithCategory:@"blurg"];
      oh = [writeCache writeObject:test];
      [test release];
      WAIT_FOR_OPERATION(oh);

      int64_t rowId = [writeCache immediatelyReadNewestRowIdOfClass:[TestCacheable class] inCategory:@"blurg"];
      [[theValue(rowId) should] equal:theValue(1)];
    });
    
    it(@"should have a method for unit tests to read the hash of a given rowId", ^{
      TestCacheable* test = [[TestCacheable alloc] initWithCategory:@"category"];
      oh = [writeCache writeObject:test];
      WAIT_FOR_OPERATION(oh);

      int64_t rowId = [writeCache immediatelyReadNewestRowIdOfClass:[TestCacheable class] inCategory:@"category"];
      NSString* actualHash = [writeCache immediatelyReadHashForRowId:rowId];
      
      GreeSerializer* serializer = [[GreeSerializer alloc] initWithSerializedDictionary:nil];
      [serializer serializeObject:test forKey:@"testObject"];
      [test release];

      NSData* serializedData = [((NSDictionary*)[[serializer rootDictionary] objectForKey:@"testObject"]) greeJSONData];
      NSString* expectedHash = [serializedData greeHashWithKey:@"net.gree.sdk.writecache"];

      [[actualHash should] equal:expectedHash];
    });
    
    it(@"should have a method for unit tests to write the hash for a row", ^{
      TestCacheable* test = [[TestCacheable alloc] initWithCategory:@"category"];
      oh = [writeCache writeObject:test];
      WAIT_FOR_OPERATION(oh);

      int64_t rowId = [writeCache immediatelyReadNewestRowIdOfClass:[TestCacheable class] inCategory:@"category"];
      [writeCache immediatelyWriteHash:@"test" forRowId:rowId];
      NSString* actualHash = [writeCache immediatelyReadHashForRowId:rowId];
      [[actualHash should] equal:@"test"];
    });

    it(@"should initialize properly", ^{
      [[writeCache should] beNonNil];
    });

    it(@"should have a description", ^{
      NSString* expectedDescription = [NSString stringWithFormat:@"<GreeWriteCache:%p, userId:%@>", writeCache, userId];
      [[[writeCache description] should] equal:expectedDescription];
    });

    it(@"should raise when observing a NULL handle", ^{
      [[theBlock(^{
        WAIT_FOR_OPERATION(oh);
      }) should] raise];
    });

    it(@"should raise when writing a non-cacheable object", ^{
      [[theBlock(^{        
        oh = [writeCache writeObject:(id<GreeWriteCacheable>)@"Just a string"];
        WAIT_FOR_OPERATION(oh);
      }) should] raise];
    });
    
    it(@"should raise when writing an object without a category", ^{
      [[theBlock(^{
        TestCacheable* test = [[TestCacheable alloc] initWithCategory:nil];
        oh = [writeCache writeObject:test];
        [test release];
        WAIT_FOR_OPERATION(oh);
      }) should] raise];
    });

    it(@"should allow writing objects with a category", ^{
      TestCacheable* test = [[TestCacheable alloc] initWithCategory:@"category"];
      [writeCache writeObject:test];
      [test release];
      
      for (int i = 0; i < 3; ++i) {
        TestCacheable* test = [[TestCacheable alloc] initWithCategory:@"category2"];
        oh = [writeCache writeObject:test];
        [test release];
      }
      WAIT_FOR_OPERATION(oh);

      [[theValue([writeCache immediatelyCountObjectOfClass:[TestCacheable class] inCategory:@"category"]) should] equal:theValue(1)];
      [[theValue([writeCache immediatelyCountObjectOfClass:[TestCacheable class] inCategory:@"category2"]) should] equal:theValue(3)];
    });
    
    it(@"should keep only the most recent entries in each category", ^{
      int i = 0;
      for (; i < 5; ++i) {
        TestCacheable* test = [[TestCacheable alloc] initWithCategory:@"category2"];
        test.testInteger = i;
        oh = [writeCache writeObject:test];
        [test release];
      }
      WAIT_FOR_OPERATION(oh);
      
      [[theValue([writeCache immediatelyCountObjectOfClass:[TestCacheable class] inCategory:@"category2"]) should] equal:theValue(5)];

      NSInteger newestTestInteger = [(TestCacheable*)[writeCache immediatelyReadNewestObjectOfClass:[TestCacheable class] inCategory:@"category2"] testInteger];
      [[theValue(newestTestInteger) should] equal:theValue(4)];

      NSInteger oldestTestInteger = [(TestCacheable*)[writeCache immediatelyReadOldestObjectOfClass:[TestCacheable class] inCategory:@"category2"] testInteger];
      [[theValue(oldestTestInteger) should] equal:theValue(0)];

      for (; i < 8; ++i) {
        TestCacheable* test = [[TestCacheable alloc] initWithCategory:@"category2"];
        test.testInteger = i;
        oh = [writeCache writeObject:test];
        [test release];
      }
      WAIT_FOR_OPERATION(oh);

      [[theValue([writeCache immediatelyCountObjectOfClass:[TestCacheable class] inCategory:@"category2"]) should] equal:theValue(5)];

      newestTestInteger = [(TestCacheable*)[writeCache immediatelyReadNewestObjectOfClass:[TestCacheable class] inCategory:@"category2"] testInteger];
      [[theValue(newestTestInteger) should] equal:theValue(7)];

      oldestTestInteger = [(TestCacheable*)[writeCache immediatelyReadOldestObjectOfClass:[TestCacheable class] inCategory:@"category2"] testInteger];
      [[theValue(oldestTestInteger) should] equal:theValue(3)];
    });

    it(@"should allow cancelling operations", ^{
      TestCacheable* test = [[TestCacheable alloc] initWithCategory:@"category"];
      [writeCache writeObject:test];
      oh = [writeCache writeObject:test];
      [writeCache cancelOutstandingOperations];
      [test release];
      WAIT_FOR_OPERATION(oh);
      
      [[theValue([writeCache immediatelyCountObjectOfClass:[TestCacheable class] inCategory:@"category"]) should] beLessThan:theValue(2)];
    });

  });
  
  context(@"with a populated cache", ^{
    __block GreeAuthorization *authMock;
    
    beforeEach(^{
      authMock = [[GreeAuthorization alloc] init];
      [authMock stub:@selector(isAuthorized) andReturn:theValue(YES)];
      [GreeAuthorization stub:@selector(sharedInstance) andReturn:authMock];

      writeCache = [[GreeWriteCache alloc] initWithUserId:userId];

      for (int i = 0; i < 8; ++i) {
        TestCacheable* test = [[TestCacheable alloc] initWithCategory:@"cat"];
        test.testInteger = i;
        [writeCache writeObject:test];
        [test release];
      }

      TestCacheable* test = [[TestCacheable alloc] initWithCategory:@"cat2"];
      test.testInteger = 123;
      oh = [writeCache writeObject:test];
      [test release];

      for (int i = 0; i < 26; ++i) {
        UnlimitedTestCacheable* test = [[UnlimitedTestCacheable alloc] initWithCategory:@"all"];
        test.testString = @"𝄞";
        oh = [writeCache writeObject:test];
        [test release];
      }
      WAIT_FOR_OPERATION(oh);
      
      CommitShouldFail = NO;
      CommitCountSuccess = 0;
      CommitCountFailure = 0;
      CommitDelay = 0.f;
    });
    
    afterEach(^{
      [authMock release];
      [writeCache release];
      writeCache = nil;
    });

    it(@"should initialize properly", ^{
      [[writeCache should] beNonNil];
    });
    
    it(@"should allow committing a single category", ^{
      oh = [writeCache commitAllObjectsOfClass:[TestCacheable class] inCategory:@"cat2"];
      WAIT_FOR_OPERATION(oh);
      [[theValue(CommitCountSuccess) should] equal:theValue(1)];
    });
    
    it(@"should allow committing all categories", ^{
      oh = [writeCache commitAllObjectsOfClass:[TestCacheable class]];
      WAIT_FOR_OPERATION(oh);
      [[theValue(CommitCountSuccess) should] equal:theValue(6)];
    });
    
    it(@"should remove an object once it has been successfully committed", ^{
      [[theValue([writeCache immediatelyCountObjectOfClass:[UnlimitedTestCacheable class] inCategory:@"all"]) should] equal:theValue(26)];
      oh = [writeCache commitAllObjectsOfClass:[UnlimitedTestCacheable class]];
      WAIT_FOR_OPERATION(oh);
      [[theValue(CommitCountSuccess) should] equal:theValue(26)];
      [[theValue([writeCache immediatelyCountObjectOfClass:[TestCacheable class] inCategory:@"cat"]) should] equal:theValue(5)];
      [[theValue([writeCache immediatelyCountObjectOfClass:[TestCacheable class] inCategory:@"cat2"]) should] equal:theValue(1)];
      [[theValue([writeCache immediatelyCountObjectOfClass:[UnlimitedTestCacheable class] inCategory:@"all"]) should] equal:theValue(0)];
    });
    
    it(@"should not remove an object if it fails to commit", ^{
      CommitShouldFail = YES;
      [[theValue([writeCache immediatelyCountObjectOfClass:[TestCacheable class] inCategory:@"cat"]) should] equal:theValue(5)];
      oh = [writeCache commitAllObjectsOfClass:[TestCacheable class] inCategory:@"cat"];
      WAIT_FOR_OPERATION(oh);
      [[theValue(CommitCountSuccess) should] equal:theValue(0)];
      [[theValue(CommitCountFailure) should] equal:theValue(5)];
      [[theValue([writeCache immediatelyCountObjectOfClass:[TestCacheable class] inCategory:@"cat"]) should] equal:theValue(5)];
    });
    
    it(@"should not crash if we write and discard a currently committing object", ^{
      __block BOOL commitFinished = NO;
      __block BOOL writeFinished = NO;
      
      CommitDelay = 0.5f;
      GreeWriteCacheOperationHandle commitHandle = [writeCache commitAllObjectsOfClass:[TestCacheable class] inCategory:@"cat"];
      [writeCache observeWriteCacheOperation:commitHandle forCompletionWithBlock:^{
        commitFinished = YES;
      }];

      TestCacheable* test = [[TestCacheable alloc] initWithCategory:@"cat"];
      test.testString = @"newlyWritten";
      GreeWriteCacheOperationHandle writeHandle = [writeCache writeObject:test];
      [test release];
      [writeCache observeWriteCacheOperation:writeHandle forCompletionWithBlock:^{
        writeFinished = YES;
      }];
      
      [[expectFutureValue(theValue(commitFinished)) shouldEventuallyBeforeTimingOutAfter(2.f)] beYes];
      [[expectFutureValue(theValue(writeFinished)) shouldEventuallyBeforeTimingOutAfter(2.f)] beYes];

      [[theValue([writeCache immediatelyCountObjectOfClass:[TestCacheable class] inCategory:@"cat"]) should] equal:theValue(1)];

      TestCacheable* newest = (TestCacheable*)[writeCache immediatelyReadNewestObjectOfClass:[TestCacheable class] inCategory:@"cat"];
      [[newest.testString should] equal:@"newlyWritten"];

      TestCacheable* oldest = (TestCacheable*)[writeCache immediatelyReadOldestObjectOfClass:[TestCacheable class] inCategory:@"cat"];
      [[oldest.testString should] equal:newest.testString];
    });
    
    it(@"should not commit the same object twice", ^{
      [writeCache commitAllObjectsOfClass:[TestCacheable class] inCategory:@"cat2"];
      oh = [writeCache commitAllObjectsOfClass:[TestCacheable class] inCategory:@"cat2"];
      WAIT_FOR_OPERATION(oh);
      [[theValue(CommitCountSuccess) should] equal:theValue(1)];
    });
    
    it(@"should remain committable after a commit fails", ^{
      CommitShouldFail = YES;
      oh = [writeCache commitAllObjectsOfClass:[TestCacheable class] inCategory:@"cat2"];
      WAIT_FOR_OPERATION(oh);
      [[theValue(CommitCountFailure) should] equal:theValue(1)];
      
      CommitShouldFail = NO;
      oh = [writeCache commitAllObjectsOfClass:[TestCacheable class] inCategory:@"cat2"];
      WAIT_FOR_OPERATION(oh);
      [[theValue(CommitCountSuccess) should] equal:theValue(1)];      
    });
    
    it(@"should allow deletion of all objects for a given class", ^{
      oh = [writeCache deleteAllObjectsOfClass:[TestCacheable class]];
      WAIT_FOR_OPERATION(oh);
      [[theValue([writeCache immediatelyCountObjectOfClass:[TestCacheable class] inCategory:@"cat"]) should] equal:theValue(0)];
      [[theValue([writeCache immediatelyCountObjectOfClass:[TestCacheable class] inCategory:@"cat2"]) should] equal:theValue(0)];
    });

    it(@"should allow deletion of a category of objects for a given class", ^{
      oh = [writeCache deleteAllObjectsOfClass:[TestCacheable class] inCategory:@"cat"];
      WAIT_FOR_OPERATION(oh);
      [[theValue([writeCache immediatelyCountObjectOfClass:[TestCacheable class] inCategory:@"cat"]) should] equal:theValue(0)];
      [[theValue([writeCache immediatelyCountObjectOfClass:[TestCacheable class] inCategory:@"cat2"]) should] equal:theValue(1)];
    });
    
    it(@"should throw out an entry which does not have a matching hash", ^{
      int64_t rowId = [writeCache immediatelyReadNewestRowIdOfClass:[TestCacheable class] inCategory:@"cat2"];
      [writeCache immediatelyWriteHash:@"bogushashbogushashbo" forRowId:rowId];

      [[writeCache should] receive:@selector(immediatelyDeleteObjectWithRowId:) withArguments:theValue(rowId)];

      oh = [writeCache commitAllObjectsOfClass:[TestCacheable class] inCategory:@"cat2"];
      WAIT_FOR_OPERATION(oh);
    });

  });
  
});

SPEC_END
