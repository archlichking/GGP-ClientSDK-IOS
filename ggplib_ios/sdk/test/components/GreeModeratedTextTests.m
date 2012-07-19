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
#import "GreeModeratedText.h"
#import "GreeSerializer.h"

#import "GreePlatform+Internal.h"
#import "GreeHTTPClient.h"
#import "GreeURLMockingProtocol.h"
#import "GreeSerializer.h"

#import "NSDateFormatter+GreeAdditions.h"
#import "GreeTestHelpers.h"
#import "GreeModerationList.h"

static NSString *postBodyResponse = @"{                                         " 
                                     " \"entry\": [                             "
                                     "   {                                      " 
                                     "     \"textId\": \"012345671\",           "
                                     "     \"appId\": \"1001\",                 "
                                     "     \"authorId\": \"0123456\",           "
                                     "     \"ownerId\": \"0123456\",            "
                                     "     \"data\": \"Free Input\",            " 
                                     "     \"status\": \"0\",                   "
                                     "     \"ctime\": \"2010-07-14 14:41:00\",  " 
                                     "     \"mtime\": \"2010-07-14 14:41:00\"   " 
                                     "   }                                      " 
                                     " ]                                        "
                                     "}                                         ";

static NSString *getBodyResponse = @"{                                         " 
                                    "  \"entry\": [                            "
                                    "    {                                     "
                                    "      \"textId\": \"012345671\",          " 
                                    "      \"appId\": \"1001\",                "
                                    "      \"authorId\": \"0123456\",          "
                                    "      \"ownerId\": \"0123456\",           "
                                    "      \"data\": \"Free Input\",           "
                                    "      \"status\": \"0\"                   "  
                                    "    },                                    "
                                    "    {                                     "
                                    "      \"textId\": \"012345672\",          " 
                                    "      \"appId\": \"1001\",                "
                                    "      \"authorId\": \"0123456\",          "
                                    "      \"ownerId\": \"0123456\",           "
                                    "      \"data\": \"More Free Input\",      "
                                    "      \"status\": \"0\"                   "  
                                    "    }                                     "
                                    "  ]                                       "
                                    "}                                         ";
  

SPEC_BEGIN(GreeModeratedTextSpec)
describe(@"GreeModeratedText", ^{
  
  beforeEach(^{
    GreePlatform* sdk = [GreePlatform nullMockAsSharedInstance];
    [sdk stub:@selector(httpClient) andReturn:[GreeHTTPClient nullMock]];
    [GreeURLMockingProtocol register];
  });
  
  afterEach(^{
    [GreeURLMockingProtocol unregister];
  });
  
  it(@"should deserialize", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"mockTextId", @"textId",
                                @"mockAppId", @"appId",
                                @"mockAuthorId", @"authorId",
                                @"mockOwnerId", @"ownerId",
                                @"mockData", @"data",
                                @"0", @"status", 
                                nil];
    
    GreeSerializer* serializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeModeratedText* userText = [[GreeModeratedText alloc] initWithGreeSerializer:serializer];
    [[userText.textId should] equal:@"mockTextId"];
    [[userText.appId should] equal:@"mockAppId"];
    [[userText.authorId should] equal:@"mockAuthorId"];
    [[[userText performSelector:@selector(ownerId)] should] equal:@"mockOwnerId"];
    [[theValue(userText.status) should] equal:theValue(GreeModerationStatusBeingChecked)];
    [userText release];
  });
  
  it(@"should serialize", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"mockTextId", @"textId",
                                @"mockAppId", @"appId",
                                @"mockAuthorId", @"authorId",
                                @"mockOwnerId", @"ownerId",
                                @"mockData", @"data",
                                @"0", @"status",
                                nil];
    
    GreeSerializer* deserializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeModeratedText* userText = [[GreeModeratedText alloc] initWithGreeSerializer:deserializer];
    GreeSerializer* serializer = [GreeSerializer serializer];
    [userText serializeWithGreeSerializer:serializer];
    [[serializer.rootDictionary should] equal:serialized];
  });
  
  it(@"should show description", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"mockTextId", @"textId",
                                @"mockAppId", @"appId",
                                @"mockAuthorId", @"authorId",
                                @"mockOwnerId", @"ownerId",
                                @"mockData", @"data",
                                @"0", @"status",
                                nil];
    
    GreeSerializer* serializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeModeratedText* userText = [[GreeModeratedText alloc] initWithGreeSerializer:serializer];

    NSString* checkString = [NSString stringWithFormat:@"<GreeModeratedText:%p, textId:mockTextId, appId:mockAppId, content:mockData, status:0 lastUpdated:(null)>",
      userText];
      
    [[[userText description] should] equal:checkString]; 
    [userText release];
  });

  it(@"should create a new moderated text", ^{
    __block GreeModeratedText* userText = nil;
    MockedURLResponse* mock = [[[MockedURLResponse alloc] init] autorelease];
    mock.data = [[NSString stringWithFormat:postBodyResponse] dataUsingEncoding:NSUTF8StringEncoding];
    [GreeURLMockingProtocol addMock:mock];
    [GreeModeratedText createWithString:@"Free Input" block:^(GreeModeratedText* aUserText, NSError* error) {
      userText = [aUserText retain];
    }];
    
    [[expectFutureValue(userText) shouldEventually] beNonNil];

    [[userText.textId should] equal:@"012345671"];
    [[userText.appId should] equal:@"1001"];
    [[userText.authorId should] equal:@"0123456"];
    [[[userText performSelector:@selector(ownerId)] should] equal:@"0123456"];
    [[userText.content should] equal:@"Free Input"];
    [[theValue(userText.status) should] equal:theValue(0)];
    [userText release];
  });
  
  it(@"should handle failure when creating a new moderated text", ^{
    __block id error = nil;
    MockedURLResponse* mock = [[[MockedURLResponse alloc] init] autorelease];
    mock.statusCode = 500;
    [GreeURLMockingProtocol addMock:mock];
    [GreeModeratedText createWithString:@"Free Input" block:^(GreeModeratedText* aUserText, NSError* anError) {
      error = [anError retain];
    }];
    
    [[expectFutureValue(error) shouldEventually] beKindOfClass:[NSError class]];
    [error release];
  });
  
  it(@"should retrieve existing moderated texts", ^{
    __block NSArray* userTexts = nil;
    MockedURLResponse* mock = [[[MockedURLResponse alloc] init] autorelease];
    mock.data = [[NSString stringWithFormat:getBodyResponse] dataUsingEncoding:NSUTF8StringEncoding];
    [GreeURLMockingProtocol addMock:mock];
    [GreeModeratedText loadFromIds:[NSArray arrayWithObjects:@"012345671", @"012345672", nil] block:^(NSArray* someUserTexts, NSError* error) {
      userTexts = [someUserTexts retain]; 
    }];
      
    [[expectFutureValue(userTexts) shouldEventually] beNonNil];
    [[[userTexts should] have:2] items];

    GreeModeratedText *userText1 = [userTexts objectAtIndex:0];
    [[userText1.textId should] equal:@"012345671"];
    [[userText1.appId should] equal:@"1001"];
    [[userText1.authorId should] equal:@"0123456"];
    [[[userText1 performSelector:@selector(ownerId)] should] equal:@"0123456"];
    [[userText1.content should] equal:@"Free Input"];
    [[theValue(userText1.status) should] equal:theValue(0)];
    [userText1 release];
    
    GreeModeratedText *userText2 = [userTexts objectAtIndex:1];
    [[userText2.textId should] equal:@"012345672"];
    [[userText2.appId should] equal:@"1001"];
    [[userText2.authorId should] equal:@"0123456"];
    [[[userText2 performSelector:@selector(ownerId)] should] equal:@"0123456"];
    [[userText2.content should] equal:@"More Free Input"];
    [[theValue(userText2.status) should] equal:theValue(0)];
    [userText2 release];
  });
  
  it(@"should handle missing block on load", ^{
    //if this tries to load anything, it would fail due to missing mock
    [GreeModeratedText loadFromIds:[NSArray arrayWithObject:@"nope"] block:nil];
  });
  
  it(@"should handle failure when retrieving existing moderated texts", ^{
    __block id error = nil;
    MockedURLResponse* mock = [[[MockedURLResponse alloc] init] autorelease];
    mock.statusCode = 500;
    [GreeURLMockingProtocol addMock:mock];
    [GreeModeratedText loadFromIds:[NSArray arrayWithObjects:@"012345671", @"012345672", nil] block:^(NSArray* someUserTexts, NSError* anError) {
      error = [anError retain];
    }];
    
    [[expectFutureValue(error) shouldEventually] beKindOfClass:[NSError class]];
    [error release];
  });
  
  it(@"should consider any moderated texts with the same id as equal", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"mockTextId", @"textId",
                                @"mockAppId", @"appId",
                                @"mockAuthorId", @"authorId",
                                @"mockOwnerId", @"ownerId",
                                @"mockData", @"data",
                                @"0", @"status",
                                nil];
    
    GreeSerializer* deserializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeModeratedText* userText = [[GreeModeratedText alloc] initWithGreeSerializer:deserializer];
    GreeModeratedText* userText2 = [[GreeModeratedText alloc] initWithGreeSerializer:deserializer];

    [[userText should] equal:userText2];
    [[theValue([userText hash]) should] equal:theValue([userText2 hash])];

    [userText release];
    [userText2 release];
  });
  
  it(@"should consider any moderated texts with the different ids as not equal", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"mockTextId", @"textId",
                                @"mockAppId", @"appId",
                                @"mockAuthorId", @"authorId",
                                @"mockOwnerId", @"ownerId",
                                @"mockData", @"data",
                                @"0", @"status",
                                nil];
    NSDictionary* serialized2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"mockTextId2", @"textId",
                                @"mockAppId", @"appId",
                                @"mockAuthorId", @"authorId",
                                @"mockOwnerId", @"ownerId",
                                @"mockData", @"data",
                                @"0", @"status",
                                nil];
    
    GreeSerializer* deserializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeModeratedText* userText = [[GreeModeratedText alloc] initWithGreeSerializer:deserializer];
    
    GreeSerializer* deserializer2 = [GreeSerializer deserializerWithDictionary:serialized2];
    GreeModeratedText* userText2 = [[GreeModeratedText alloc] initWithGreeSerializer:deserializer2];

    [[userText shouldNot] equal:userText2];
    [[theValue([userText hash]) shouldNot] equal:theValue([userText2 hash])];

    [userText release];
    [userText2 release];
  });

  it(@"should fail comparisons with non-GreeModeratedText objects", ^{
    GreeModeratedText* userText = [[[GreeModeratedText alloc] init] autorelease];
    [[userText shouldNot] equal:@"a string"];
  });
  
  context(@"It should update and delete items", ^{
    __block GreeModeratedText *userText = nil;
    
    beforeEach(^{
        NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"mockTextId", @"textId",
                                @"mockAppId", @"appId",
                                @"mockAuthorId", @"authorId",
                                @"mockOwnerId", @"ownerId",
                                @"mockData", @"data",
                                @"0", @"status", 
                                nil];
    
      GreeSerializer* serializer = [GreeSerializer deserializerWithDictionary:serialized];
      userText = [[GreeModeratedText alloc] initWithGreeSerializer:serializer];
    });
    
    afterEach(^{
      [userText release];
      userText = nil; 
    });
    
    it(@"update an existing moderated text", ^{
      __block BOOL success = NO;

      MockedURLResponse* mock = [[[MockedURLResponse alloc] init] autorelease];
      mock.statusCode = 201;
      [GreeURLMockingProtocol addMock:mock];

      [userText updateWithString:@"Some text" block:^(NSError* error) {
        success = (error == nil);
      }];
    
      [[expectFutureValue(theValue(success)) shouldEventually] beYes];    
    });
  
    it(@"should handle failure when updating existing moderated texts", ^{
      __block id error = nil;
    
      MockedURLResponse* mock = [[[MockedURLResponse alloc] init] autorelease];
      mock.statusCode = 500;
      [GreeURLMockingProtocol addMock:mock];
    
      [userText updateWithString:@"Some text" block:^(NSError* anError) {
        error = [anError retain];
      }];
    
      [[expectFutureValue(error) shouldEventually] beKindOfClass:[NSError class]];
    
      [error release];
    }); 

    it(@"should allow for deleting an moderated text", ^{
      __block BOOL success = NO;
    
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      mock.statusCode = 202;
      [GreeURLMockingProtocol addMock:mock];
      
      [userText deleteWithBlock:^(NSError* error) {
        success = (error == nil);
      }];
    
      [[expectFutureValue(theValue(success)) shouldEventually] beYes];    
    }); 
  
    it(@"should handle failure when deleting a moderated text", ^{
      __block id error = nil;
    
      MockedURLResponse* mock = [[[MockedURLResponse alloc] init] autorelease];
      mock.statusCode = 500;
      [GreeURLMockingProtocol addMock:mock];
    
      [userText deleteWithBlock:^(NSError* anError) {
        error = [anError retain];
      }];
    
      [[expectFutureValue(error) shouldEventually] beKindOfClass:[NSError class]];
      [error release];
    });
    
    it(@"should add to moderation lists", ^{
      GreePlatform* mockSdk = [GreePlatform nullMockAsSharedInstance];
      [mockSdk stub:@selector(moderationList) andReturn:[[[GreeModerationList alloc] init] autorelease]];
      [userText beginNotification];
      [mockSdk.moderationList shouldNotBeNil];
      NSDictionary* innerList = [mockSdk.moderationList valueForKey:@"textList"];
      [[innerList should] haveValue:userText forKey:userText.textId];
    });
    
    it(@"should remove from moderation list", ^{
      GreePlatform* mockSdk = [GreePlatform nullMockAsSharedInstance];
      [mockSdk stub:@selector(moderationList) andReturn:[[[GreeModerationList alloc] init] autorelease]];
      NSMutableDictionary* innerList = [mockSdk.moderationList valueForKey:@"textList"];
      [innerList setObject:userText forKey:userText.textId];
      [userText endNotification];
      [[innerList shouldNot] haveValueForKey:userText.textId];
    });
  });
});

SPEC_END

