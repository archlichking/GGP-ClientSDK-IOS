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
#import "GreeSerializer.h"
#import "GreeSerializable.h"
#import "NSDateFormatter+GreeAdditions.h"

#pragma mark - GreeTestUser

@interface GreeTestUser : NSObject<GreeSerializable>
@property (nonatomic, retain) NSString* username;
@property (nonatomic, retain) NSString* userId;
@property (nonatomic, retain) NSDictionary* extraData;
// designated initiailizer
- (id)initWithUserId:(NSString*)userId;
@end

@implementation GreeTestUser

@synthesize username = _username;
@synthesize userId = _userId;
@synthesize extraData = _extraData;

- (id)initWithUserId:(NSString*)userId
{
  self = [super init];
  if (self != nil) {
    _userId = [userId retain];
  }
  
  return self;
}

- (void)dealloc
{
  [_username release];
  [_userId release];
  [_extraData release];
  [super dealloc];
}

- (id)initWithGreeSerializer:(GreeSerializer*)serializer
{
  self = [self initWithUserId:[serializer objectForKey:@"id"]];
  if (self != nil) {
    _username = [[serializer objectForKey:@"name"] retain];
    _extraData = [[serializer objectForKey:@"extra"] retain];
  }
  
  return self;
}

- (void)serializeWithGreeSerializer:(GreeSerializer*)serializer
{
  [serializer serializeObject:_userId forKey:@"id"];
  [serializer serializeObject:_username forKey:@"name"];
  [serializer serializeObject:_extraData forKey:@"extra"];
}

@end

#pragma mark - GreeTestScore

@interface GreeTestScore : NSObject<GreeSerializable>
@property (nonatomic, assign) int64_t score;
@property (nonatomic, retain) GreeTestUser* user;
@property (nonatomic, retain) NSDate* dateAchieved;
// designated initializer
- (id)initWithScore:(int64_t)score;
@end

@implementation GreeTestScore

@synthesize score = _score;
@synthesize user = _user;
@synthesize dateAchieved = _dateAchieved;

- (id)initWithScore:(int64_t)score
{
  self= [super init];
  if (self != nil) {
    _score = score;
  }

  return self;
}

- (void)dealloc
{
  [_user release];
  [_dateAchieved release];
  [super dealloc];
}

- (id)initWithGreeSerializer:(GreeSerializer*)serializer
{
  self = [self initWithScore:[serializer int64ForKey:@"score"]];
  if (self != nil) {
    _user = [[serializer objectOfClass:[GreeTestUser class] forKey:@"user"] retain];
    _dateAchieved = [[serializer dateForKey:@"date"] retain];
  }
  
  return self;
}

- (void)serializeWithGreeSerializer:(GreeSerializer*)serializer
{
  [serializer serializeInt64:_score forKey:@"score"];
  [serializer serializeObject:_user forKey:@"user"];
  [serializer serializeDate:_dateAchieved forKey:@"date"];
}

@end

#pragma mark - GreeTestLeaderboard

@interface GreeTestLeaderboard : NSObject<GreeSerializable>
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSArray* topTenScores;
// designated initializer
- (id)initWithName:(NSString*)name;
@end

@implementation GreeTestLeaderboard

@synthesize name = _name;
@synthesize topTenScores = _topTenScores;

- (id)initWithName:(NSString*)name
{
  self = [super init];
  if (self != nil) {
    _name = [name retain];
  }
  
  return self;
}

- (void)dealloc
{
  [_name release];
  [_topTenScores release];
  [super dealloc];
}

- (id)initWithGreeSerializer:(GreeSerializer*)serializer
{
  self = [self initWithName:[serializer objectForKey:@"name"]];
  if (self != nil) {
    _topTenScores = [[serializer arrayOfSerializableObjectsWithClass:[GreeTestScore class] forKey:@"topTen"] retain];
  }
  
  return self;
}

- (void)serializeWithGreeSerializer:(GreeSerializer*)serializer
{
  [serializer serializeObject:_name forKey:@"name"];
  [serializer serializeArrayOfSerializableObjects:_topTenScores ofClass:[GreeTestScore class] forKey:@"topTen"];
}

@end

#pragma mark - GreeSerializerTests

SPEC_BEGIN(GreeSerializerTests)

describe(@"GreeSerializer", ^{

  context(@"when initialized for serialization", ^{
    __block GreeSerializer* serializer = nil;
    __block NSDateFormatter* formatter = nil;
    __block NSDateFormatter* utcFormatter = nil;
    
    beforeEach(^{
      serializer = [[GreeSerializer serializer] retain];
      formatter = [[NSDateFormatter alloc] init];
      [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
      
      utcFormatter = [[NSDateFormatter alloc] init];
      [utcFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
      [utcFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    });
    
    afterEach(^{
      [formatter release];
      [utcFormatter release];
      
      [serializer release];
      serializer = nil;
    });

    it(@"should serialize all known types", ^{
      [serializer serializeObject:@"STRING" forKey:@"string"];
      [serializer serializeObject:[NSNumber numberWithInteger:1234] forKey:@"number"];
      NSDictionary* testDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"v1", @"k1", nil];
      [serializer serializeObject:testDictionary forKey:@"dictionary"];
      NSArray* testArray = [NSArray arrayWithObjects:@"v1", @"v2", nil];
      [serializer serializeObject:testArray forKey:@"array"];
      [serializer serializeObject:[NSNull null] forKey:@"null"];
      [serializer serializeDate:[NSDate dateWithTimeIntervalSince1970:0] forKey:@"date"];
      [serializer serializeUTCDate:[NSDate dateWithTimeIntervalSince1970:0] forKey:@"utc_date"];
      [serializer serializeInteger:1234 forKey:@"integer"];
      [serializer serializeInt64:NSUIntegerMax + 1 forKey:@"int64"];
      [serializer serializeDouble:DBL_MAX forKey:@"double"];
      [serializer serializeBool:YES forKey:@"bool"];
      [serializer serializeUrl:[NSURL URLWithString:@"http://www.google.com/?hl=en"] forKey:@"url"];
      NSArray* arrayOfUsers = [NSArray arrayWithObjects:
        [[GreeTestUser alloc] initWithUserId:@"1"],
        [[GreeTestUser alloc] initWithUserId:@"2"],
        [[GreeTestUser alloc] initWithUserId:@"3"],
        [[GreeTestUser alloc] initWithUserId:@"4"],
        [NSArray arrayWithObjects:
          [[GreeTestUser alloc] initWithUserId:@"5"],
          [[GreeTestUser alloc] initWithUserId:@"6"],
          nil],
        nil];
      [serializer serializeArrayOfSerializableObjects:arrayOfUsers ofClass:[GreeTestUser class] forKey:@"serializableObjects"];
      
      NSDictionary* root = [serializer rootDictionary];
      [[[root objectForKey:@"string"] should] equal:@"STRING"];
      [[[root objectForKey:@"number"] should] beKindOfClass:[NSNumber class]];
      [[[root objectForKey:@"number"] should] equal:[NSNumber numberWithInteger:1234]];
      [[[root objectForKey:@"dictionary"] should] beKindOfClass:[NSDictionary class]];
      [[[root objectForKey:@"dictionary"] should] equal:testDictionary];
      [[[root objectForKey:@"array"] should] beKindOfClass:[NSArray class]];
      [[[root objectForKey:@"array"] should] equal:testArray];
      [[[root objectForKey:@"null"] should] beKindOfClass:[NSNull class]];
      [[[formatter dateFromString:[root objectForKey:@"date"]] should] equal:[NSDate dateWithTimeIntervalSince1970:0]];
      [[[utcFormatter dateFromString:[root objectForKey:@"utc_date"]] should] equal:[NSDate dateWithTimeIntervalSince1970:0]];
      [[root objectForKey:@"integer"] shouldNotBeNil];
      [[theValue([[root objectForKey:@"integer"] integerValue]) should] equal:1234 withDelta:0];
      [[root objectForKey:@"int64"] shouldNotBeNil];
      [[theValue([[root objectForKey:@"int64"] longLongValue]) should] equal:NSUIntegerMax + 1 withDelta:0];
      [[root objectForKey:@"double"] shouldNotBeNil];
      [[theValue([[root objectForKey:@"double"] doubleValue]) should] equal:DBL_MAX withDelta:0.];
      [[root objectForKey:@"bool"] shouldNotBeNil];
      [[theValue([[root objectForKey:@"bool"] boolValue]) should] beTrue];
      [[[root objectForKey:@"url"] should] beKindOfClass:[NSString class]];
      [[[root objectForKey:@"url"] should] equal:@"http://www.google.com/?hl=en"];
      [[[root objectForKey:@"serializableObjects"] should] haveCountOf:5];
      [[[(NSArray*)[root objectForKey:@"serializableObjects"] objectAtIndex:0] should] haveValue:@"1" forKey:@"id"];
      [[[(NSArray*)[root objectForKey:@"serializableObjects"] objectAtIndex:1] should] haveValue:@"2" forKey:@"id"];
      [[[(NSArray*)[root objectForKey:@"serializableObjects"] objectAtIndex:2] should] haveValue:@"3" forKey:@"id"];
      [[[(NSArray*)[root objectForKey:@"serializableObjects"] objectAtIndex:3] should] haveValue:@"4" forKey:@"id"];
      NSArray* subArray = [(NSArray*)[root objectForKey:@"serializableObjects"] objectAtIndex:4];
      [[subArray should] beKindOfClass:[NSArray class]];
      [[subArray should] haveCountOf:2];
      [[[subArray objectAtIndex:0] should] haveValue:@"5" forKey:@"id"];
      [[[subArray objectAtIndex:1] should] haveValue:@"6" forKey:@"id"];
    });
    
    it(@"should serialize custom objects with nested custom objects", ^{
      GreeTestUser* user = [[GreeTestUser alloc] initWithUserId:@"1"];
      user.username = @"testname";
      user.extraData = nil;
      
      GreeTestScore* score = [[GreeTestScore alloc] initWithScore:4400000000];
      score.user = user;
      score.dateAchieved = [NSDate dateWithTimeIntervalSince1970:0];
      [user release];
      
      GreeTestLeaderboard* leaderboard = [[GreeTestLeaderboard alloc] initWithName:@"test"];
      leaderboard.topTenScores = [NSArray arrayWithObject:score];
      [score release];
      
      GreeSerializer* serializer = [GreeSerializer serializer];
      [serializer serializeObject:leaderboard forKey:@"leaderboard"];
      [leaderboard release];
      
      NSDictionary* root = [serializer rootDictionary];
      [[[root objectForKey:@"leaderboard"] should] beKindOfClass:[NSDictionary class]];
      
      NSDictionary* serializedLeaderboard = [root objectForKey:@"leaderboard"];
      [[[serializedLeaderboard objectForKey:@"name"] should] equal:@"test"];
      [[[serializedLeaderboard objectForKey:@"topTen"] should] haveCountOf:1];
      
      NSDictionary* serializedScore = [(NSArray*)[serializedLeaderboard objectForKey:@"topTen"] objectAtIndex:0];
      [[[formatter dateFromString:[serializedScore objectForKey:@"date"]] should] equal:[NSDate dateWithTimeIntervalSince1970:0]];
      [[[serializedScore objectForKey:@"score"] should] equal:[NSNumber numberWithLongLong:4400000000]];

      NSDictionary* serializedUser = [serializedScore objectForKey:@"user"];
      [[[serializedUser objectForKey:@"id"] should] equal:@"1"];
      [[[serializedUser objectForKey:@"name"] should] equal:@"testname"];
      [[serializedUser objectForKey:@"extra"] shouldBeNil];
    });
    
    it(@"should serialize dictionaries with a single custom object type", ^{
      NSDictionary* dictionaryOfUsers = [NSDictionary dictionaryWithObjectsAndKeys:
        [[GreeTestUser alloc] initWithUserId:@"1"], @"me",
        [[GreeTestUser alloc] initWithUserId:@"2"], @"you",
        [NSArray arrayWithObjects:
          [[GreeTestUser alloc] initWithUserId:@"3"],        
          [[GreeTestUser alloc] initWithUserId:@"4"],
          nil], @"them",        
        nil];
      [serializer serializeDictionaryOfSerializableObjects:dictionaryOfUsers ofClass:[GreeTestUser class] forKey:@"serializableObjectDictionary"];

      NSDictionary* serializedUserDictionary = [[serializer rootDictionary] objectForKey:@"serializableObjectDictionary"];
      [[[serializedUserDictionary objectForKey:@"me"] should] beKindOfClass:[NSDictionary class]];
      [[[serializedUserDictionary objectForKey:@"me"] should] haveValue:@"1" forKey:@"id"];
      [[[serializedUserDictionary objectForKey:@"you"] should] beKindOfClass:[NSDictionary class]];      
      [[[serializedUserDictionary objectForKey:@"you"] should] haveValue:@"2" forKey:@"id"];
      [[[serializedUserDictionary objectForKey:@"them"] should] beKindOfClass:[NSArray class]];
      [[[serializedUserDictionary objectForKey:@"them"] should] haveCountOf:2];
      [[[(NSArray*)[serializedUserDictionary objectForKey:@"them"] objectAtIndex:0] should] beKindOfClass:[NSDictionary class]];
      [[[(NSArray*)[serializedUserDictionary objectForKey:@"them"] objectAtIndex:0] should] haveValue:@"3" forKey:@"id"];
    });
    
  });

  context(@"when initialized for deserialization", ^{
    
    context(@"without a dictionary", ^{
      __block GreeSerializer* serializer = nil;
      
      beforeEach(^{
        serializer = [[GreeSerializer deserializerWithDictionary:nil] retain];
      });
      
      afterEach(^{
        [serializer release];
        serializer = nil;
      });
      
      it(@"should not crash when deserializing", ^{
        [[serializer objectForKey:@"testKey"] shouldBeNil];
        [[serializer dateForKey:@"testKey"] shouldBeNil];
        [[serializer UTCDateForKey:@"testKey"] shouldBeNil];
        [[theValue([serializer integerForKey:@"testKey"]) should] beZero];
        [[theValue([serializer int64ForKey:@"testKey"]) should] beZero];
        [[theValue([serializer doubleForKey:@"testKey"]) should] beZero];
        [[theValue([serializer boolForKey:@"testKey"]) should] beFalse];
        [[serializer urlForKey:@"testKey"] shouldBeNil];
        [[serializer objectOfClass:[GreeTestScore class] forKey:@"testKey"] shouldBeNil];
      });
      
      it(@"should allow serialization", ^{
        [serializer serializeBool:YES forKey:@"boolKey"];
        [[theValue([serializer boolForKey:@"boolKey"]) should] beTrue];
      });

    });
    
    context(@"with a dictionary", ^{
      __block GreeSerializer* serializer = nil;
      
      afterEach(^{
        [serializer release];
        serializer = nil;
      });
      
      it(@"should deserialize built-ins", ^{
        NSDateFormatter* formatter = [NSDateFormatter greeStandardDateFormatter];
        NSDateFormatter* utcFormatter = [NSDateFormatter greeUTCDateFormatter];
        
        NSDictionary* sample = [NSDictionary dictionaryWithObjectsAndKeys:
          @"http://www.google.com/?hl=en", @"url",
          @"YES", @"bool",
          @"1234", @"integer",
          @"4400000000", @"int64",
          @"1.23456789", @"double",
          [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:0]], @"date",
          [utcFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:0]], @"utc_date",
          [NSDictionary dictionaryWithObjectsAndKeys:
            @"v1", @"k1",
            @"v2", @"k2", 
            [NSArray arrayWithObject:@"v3"], @"k3",
            nil], @"dictionary",
          [NSArray arrayWithObjects:
            @"v1", 
            @"v2", 
            [NSDictionary dictionaryWithObjectsAndKeys:
              @"v1", @"k1",
              nil],
            nil], @"array",
          [NSNull null], @"null",
          nil];
        serializer = [[GreeSerializer deserializerWithDictionary:sample] retain];
        
        [[[serializer urlForKey:@"url"] should] equal:[NSURL URLWithString:@"http://www.google.com/?hl=en"]];
        [[theValue([serializer boolForKey:@"bool"]) should] beTrue];
        [[theValue([serializer integerForKey:@"integer"]) should] equal:theValue(1234)];
        [[theValue([serializer int64ForKey:@"int64"]) should] equal:theValue(4400000000)];
        [[theValue([serializer doubleForKey:@"double"]) should] equal:1.234567890 withDelta:0.];
        [[[serializer dateForKey:@"date"] should] equal:[NSDate dateWithTimeIntervalSince1970:0]];
        [[[serializer UTCDateForKey:@"utc_date"] should] equal:[NSDate dateWithTimeIntervalSince1970:0]];
        [[[serializer objectForKey:@"dictionary"] should] beKindOfClass:[NSDictionary class]];
        [[[serializer objectForKey:@"dictionary"] should] haveCountOf:3];
        [[[serializer objectForKey:@"array"] should] beKindOfClass:[NSArray class]];
        [[[serializer objectForKey:@"array"] should] haveCountOf:3];
        [[[serializer objectForKey:@"null"] should] equal:[NSNull null]];
      });

      it(@"should deserialize custom objects", ^{
        NSDateFormatter* formatter = [NSDateFormatter greeStandardDateFormatter];
        NSDictionary* sample = [NSDictionary dictionaryWithObjectsAndKeys:
          @"test", @"name",
          [NSArray arrayWithObjects:
            [NSDictionary dictionaryWithObjectsAndKeys:
              @"1234", @"score",
              [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:0]], @"date",
              [NSDictionary dictionaryWithObjectsAndKeys:
                @"2", @"id",
                @"andy", @"name",
                [NSDictionary dictionaryWithObjectsAndKeys:
                  @"male", @"gender",
                  @"26", @"age",
                  nil], @"extra",
                nil], @"user",
              nil],
            [NSDictionary dictionaryWithObjectsAndKeys:
              @"4321", @"score",
              [NSDictionary dictionaryWithObjectsAndKeys:
                @"3", @"id",
                @"ben", @"name",
                nil], @"user",
              nil],
            [NSDictionary dictionaryWithObjectsAndKeys:
              @"4400000000", @"score",
              [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:0]], @"date",
              [NSDictionary dictionaryWithObjectsAndKeys:
                @"1", @"id",
                nil], @"user",
              nil],
            nil], @"topTen",
          nil];
        
        GreeTestLeaderboard* leaderboard = [[GreeTestLeaderboard alloc] 
          initWithGreeSerializer:[GreeSerializer deserializerWithDictionary:sample]];
        
        [[leaderboard.name should] equal:@"test"];
        [[leaderboard.topTenScores should] haveCountOf:3];        

        GreeTestScore* scoreOne = [leaderboard.topTenScores objectAtIndex:0];
        [[theValue(scoreOne.score) should] equal:theValue(1234)];
        [[scoreOne.dateAchieved should] equal:[NSDate dateWithTimeIntervalSince1970:0]];
        [[scoreOne.user.userId should] equal:@"2"];
        [[scoreOne.user.username should] equal:@"andy"];
        [[scoreOne.user.extraData should] beNonNil];
        [[scoreOne.user.extraData should] haveCountOf:2];

        GreeTestScore* scoreTwo = [leaderboard.topTenScores objectAtIndex:1];
        [[theValue(scoreTwo.score) should] equal:theValue(4321)];
        [scoreTwo.dateAchieved shouldBeNil];
        [[scoreTwo.user.userId should] equal:@"3"];
        [[scoreTwo.user.username should] equal:@"ben"];
        [scoreTwo.user.extraData shouldBeNil];

        GreeTestScore* scoreThree = [leaderboard.topTenScores objectAtIndex:2];
        [[theValue(scoreThree.score) should] equal:theValue(4400000000)];
        [[scoreThree.dateAchieved should] equal:[NSDate dateWithTimeIntervalSince1970:0]];
        [[scoreThree.user.userId should] equal:@"1"];
        [scoreThree.user.username shouldBeNil];
        [scoreThree.user.extraData shouldBeNil];
        
        [leaderboard release];
      });
    
      it(@"should allow modification of deserialized data", ^{
        NSDictionary* sample = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"YES", @"bool",
                                @"1234", @"integer",
                                @"4400000000", @"int64",
                                @"1.23456789", @"double",
                                @"1970-01-01 00:00:00", @"date",
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"v1", @"k1",
                                  @"v2", @"k2", 
                                  nil], @"dictionary",
                                [NSArray arrayWithObjects:@"v1", @"v2", nil], @"array",
                                [NSNull null], @"null",
                                nil];
        serializer = [[GreeSerializer deserializerWithDictionary:sample] retain];
        [serializer serializeDate:[NSDate dateWithTimeIntervalSinceReferenceDate:0] forKey:@"date"];
        [[[serializer dateForKey:@"date"] should] equal:[NSDate dateWithTimeIntervalSinceReferenceDate:0]];
      });
      
      it(@"should deserialized complex custom object nesting", ^{
        NSDictionary* sample = [NSDictionary dictionaryWithObjectsAndKeys:
          [NSDictionary dictionaryWithObjectsAndKeys:
            [NSArray arrayWithObjects:
              [NSDictionary dictionaryWithObjectsAndKeys:@"12", @"score", nil],
              [NSDictionary dictionaryWithObjectsAndKeys:@"34", @"score", nil],
              nil], @"arrayOfScores",
            [NSDictionary dictionaryWithObjectsAndKeys:@"56", @"score", nil], @"singularScore",
            nil], @"dictionaryOfScores",
          [NSArray arrayWithObjects:
            [NSArray arrayWithObjects:
              [NSDictionary dictionaryWithObjectsAndKeys:@"112", @"score", nil],
              [NSDictionary dictionaryWithObjectsAndKeys:@"134", @"score", nil],
              nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"56", @"score", nil],
            nil], @"arrayOfScores",
          nil];

        GreeSerializer* serializer = [GreeSerializer deserializerWithDictionary:sample];
        NSDictionary* dictionaryOfScores = [serializer dictionaryOfSerializableObjectsWithClass:[GreeTestScore class] forKey:@"dictionaryOfScores"];
        
        [[[dictionaryOfScores objectForKey:@"arrayOfScores"] should] beKindOfClass:[NSArray class]];
        [[[dictionaryOfScores objectForKey:@"arrayOfScores"] should] haveCountOf:2];
        GreeTestScore* score0 = [(NSArray*)[dictionaryOfScores objectForKey:@"arrayOfScores"] objectAtIndex:0];
        GreeTestScore* score1 = [(NSArray*)[dictionaryOfScores objectForKey:@"arrayOfScores"] objectAtIndex:1];
        [[score0 should] beKindOfClass:[GreeTestScore class]];
        [[score1 should] beKindOfClass:[GreeTestScore class]];
        [[theValue(score0.score) should] equal:12 withDelta:0.001];
        [[theValue(score1.score) should] equal:34 withDelta:0.001];
        GreeTestScore* singled = [dictionaryOfScores objectForKey:@"singularScore"];
        [[singled should] beKindOfClass:[GreeTestScore class]];
        [[theValue(singled.score) should] equal:56 withDelta:0.001];
        
        NSArray* arrayOfScores = [serializer arrayOfSerializableObjectsWithClass:[GreeTestScore class] forKey:@"arrayOfScores"];
        [[[arrayOfScores objectAtIndex:0] should] beKindOfClass:[NSArray class]];
        [[[arrayOfScores objectAtIndex:0] should] haveCountOf:2];
        GreeTestScore* scoreA0 = [(NSArray*)[arrayOfScores objectAtIndex:0] objectAtIndex:0];
        GreeTestScore* scoreA1 = [(NSArray*)[arrayOfScores objectAtIndex:0] objectAtIndex:1];
        [[scoreA0 should] beKindOfClass:[GreeTestScore class]];
        [[scoreA1 should] beKindOfClass:[GreeTestScore class]];
        [[theValue(scoreA0.score) should] equal:112 withDelta:0.001];
        [[theValue(scoreA1.score) should] equal:134 withDelta:0.001];
        [[[arrayOfScores objectAtIndex:1] should] beKindOfClass:[GreeTestScore class]];
      });

    });
    
  });
  
  it(@"should deserialize immutable containers by default", ^{
    GreeSerializer* serializer = [[GreeSerializer alloc] initWithSerializedDictionary:
      [NSDictionary dictionaryWithObjectsAndKeys:
        [NSArray arrayWithObject:@"v1"], @"k1",
        nil]];
    
    [[[serializer objectForKey:@"k1"] shouldNot] respondToSelector:@selector(addObject:)];
  });

  it(@"should deserialize mutable containers when asked", ^{
    GreeSerializer* serializer = [[GreeSerializer alloc] initWithSerializedDictionary:
      [NSDictionary dictionaryWithObjectsAndKeys:
        [NSArray arrayWithObject:@"v1"], @"k1",
        nil]];

    serializer.deserialzeIntoMutableContainers = YES;
    
    [[[serializer objectForKey:@"k1"] should] respondToSelector:@selector(addObject:)];
  });
  
  context(@"when deserializing an array", ^{

    it(@"should convert objects", ^{
      NSArray* serialized = [NSArray arrayWithObjects:
                             [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"id", @"name1", @"name", nil],
                             [NSDictionary dictionaryWithObjectsAndKeys:@"2", @"id", @"name2", @"name", nil],
                             nil];
      NSArray* deserialized = [GreeSerializer deserializeArray:serialized withClass:[GreeTestUser class]];
      [[deserialized should] haveCountOf:2];
      [[[deserialized objectAtIndex:0] should] haveValue:@"1" forKeyPath:@"userId"];
      [[[deserialized objectAtIndex:0] should] haveValue:@"name1" forKeyPath:@"username"];
      [[[deserialized objectAtIndex:1] should] haveValue:@"2" forKeyPath:@"userId"];
      [[[deserialized objectAtIndex:1] should] haveValue:@"name2" forKeyPath:@"username"];
    });
    
    it(@"should gracefully fail when the input array is nil", ^{
      NSArray* deserialized = [GreeSerializer deserializeArray:nil withClass:[GreeTestUser class]];
      [deserialized shouldBeNil];
    });

    it(@"should gracefully fail when the input class is nil", ^{
      NSArray* serialized = [NSArray arrayWithObjects:
        [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"id", @"name1", @"name", nil],
        [NSDictionary dictionaryWithObjectsAndKeys:@"2", @"id", @"name2", @"name", nil],
        nil];
      NSArray* deserialized = [GreeSerializer deserializeArray:serialized withClass:nil];
      [deserialized shouldBeNil];
    });
  });
  
});

SPEC_END
