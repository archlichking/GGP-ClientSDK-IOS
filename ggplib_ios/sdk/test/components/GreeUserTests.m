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
#import "JSONKit.h"
#import "GreePlatform.h"
#import "GreeUser+Internal.h"
#import "GreeHTTPClient.h"
#import "GreeURLMockingProtocol.h"
#import "GreeSerializer.h"
#import "GreeTestHelpers.h"
#import "GreeMatchers.h"
#import "GreeError.h"

static NSString* profileTxt = @"{\"entry\": {\"id\": \"521249\", \"nickname\": \"bismuth01\",\"displayName\": \"bismuth01\",\"aboutMe\": \"\",\"birthday\": \"\","
@"\"profileUrl\": \"http://m-dev-ggpxcp1.dev.gree.jp/?mode=profile&act=look&ucode=521249\","
@"\"thumbnailUrl\": \"http://igen-dev-ggpxcp1.dev.gree.jp/life/41200900c00e00f00g.48.gif?__gda__=1323995700_b966ce525dc5e309281a0ec9a49a3be2\","
@"\"thumbnailUrlSmall\": \"http://igen-dev-ggpxcp1.dev.gree.jp/life/41200900c00e00f00g.st25.jpg?__gda__=1323995700_f641eae2be0166f69657caff1b65acce\","
@"\"thumbnailUrlLarge\": \"http://igen-dev-ggpxcp1.dev.gree.jp/life/41200900c00e00f00g.4876.gif?__gda__=1323995700_efaaca455a9a4a0db2de6bd3dd97c4ea\","
@"\"thumbnailUrlHuge\": \"http://igen-dev-ggpxcp1.dev.gree.jp/life/41200900c00e00f00g.190.gif?__gda__=1323995700_18c4cea45c6f057d5a1efd11ea017103\","
@"\"gender\": \"\", \"age\": \"\", \"bloodType\": \"\", \"hasApp\": \"true\", \"userHash\": \"\", \"userType\": \"\", \"timezone\": \"480\", \"userGrade\": \"2\", \"region\": \"AQ\", \"subregion\": \"\", \"language\": \"jpn-Jpan-JP\"}}";

static NSString* profileTxt2 = @"{\"entry\": {\"id\": \"521249\", \"nickname\": \"bismuth01\",\"displayName\": \"bismuth01\",\"aboutMe\": \"\",\"birthday\": \"\","
@"\"profileUrl\": \"http://m-dev-ggpxcp1.dev.gree.jp/?mode=profile&act=look&ucode=521249\","
@"\"thumbnailUrl\": \"http://test.gree.net/main\","
@"\"thumbnailUrlSmall\": \"http://test.gree.net/small\","
@"\"thumbnailUrlLarge\": \"http://test.gree.net/large\","
@"\"thumbnailUrlHuge\": \"http://test.gree.net/huge\","
@"\"gender\": \"\", \"age\": \"\", \"bloodType\": \"\", \"hasApp\": \"true\", \"userHash\": \"\", \"userType\": \"\", \"timezone\": \"480\", \"userGrade\": \"2\", \"region\": \"AQ\", \"subregion\": \"\", \"language\": \"jpn-Jpan-JP\"}}";


static NSString* friendsStr = @"{\"entry\": [{\"id\": \"id1\", \"nickname\": \"nickname1\",\"displayName\": \"bismuth01\",\"aboutMe\": \"\",\"birthday\": \"\","
@"\"profileUrl\": \"http://profileUrl.jpg\","
@"\"thumbnailUrl\": \"http://thumbnailUrl.jpg\","
@"\"thumbnailUrlSmall\": \"http://thumbnailUrlSmall.jpg\","
@"\"thumbnailUrlLarge\": \"http://thumbnailUrlLarge.jpg\","
@"\"thumbnailUrlHuge\": \"http://thumbnailUrlHuge.jpg\","
@"\"gender\": \"\", \"age\": \"\", \"bloodType\": \"\", \"hasApp\": \"true\", \"userHash\": \"\", \"userType\": \"\", \"timezone\": \"480\",\"userGrade\": \"2\", \"region\": \"AQ\", \"subregion\": \"\", \"language\": \"jpn-Jpan-JP\"},"
@"{\"id\": \"id2\", \"nickname\": \"nickname2\",\"displayName\": \"bismuth01\",\"aboutMe\": \"\",\"birthday\": \"\","
  @"\"profileUrl\": \"http://profileUrl.jpg\","
  @"\"thumbnailUrl\": \"http://thumbnailUrl.jpg\","
  @"\"thumbnailUrlSmall\": \"http://thumbnailUrlSmall.jpg\","
  @"\"thumbnailUrlLarge\": \"http://thumbnailUrlLarge.jpg\","
  @"\"thumbnailUrlHuge\": \"http://thumbnailUrlHuge.jpg\","
  @"\"gender\": \"\", \"age\": \"\", \"bloodType\": \"\", \"hasApp\": \"true\", \"userHash\": \"\", \"userType\": \"\", \"timezone\": \"480\", \"userGrade\": \"2\", \"region\": \"AQ\", \"subregion\": \"\", \"language\": \"jpn-Jpan-JP\"}"
@"],"
@"\"startIndex\":\"1\",\"hasNext\": \"0\",\"itemsPerPage\": \"10\""
@"}";//end of the whole json text

static NSString* ignoredFriends = @"{\"entry\": [{\"id\":30,\"ignorelistId\":101}, {\"id\":30,\"ignorelistId\":102}, {\"id\":30,\"ignorelistId\":103}, {\"id\":30,\"ignorelistId\":104}],"
@"\"startIndex\":\"1\",\"hasNext\": \"0\",\"itemsPerPage\": \"4\"}";

static NSString* fullIgnorePage = @"{\"entry\": [{\"id\":30,\"ignorelistId\":101}, {\"id\":30,\"ignorelistId\":102}, {\"id\":30,\"ignorelistId\":103}],"
@"\"startIndex\":\"1\",\"hasNext\": \"0\",\"itemsPerPage\": \"3\"}";

static NSString* bannedStrArray = @"{\"entry\":[{\"id\":30, \"ignorelistId\":110}]}";
static NSString* bannedStrDict = @"{\"entry\":{\"id\":30, \"ignorelistId\":110}}";
static NSString* notBannedStr = @"{\"entry\":\"\"}";
static NSString* BannedBadStr = @"{\"entry\":30}";


static NSString* kMockId = @"mockId";
static NSString* kMockNickName = @"mockNickName";
static NSString* kMockDisplayName = @"mockDisplayName";

static GreeUserGrade kMockUserGrade = GreeUserGradeLimited;
static NSString* kMockRegion = @"mockRegion";
static NSString* kMockSubRegion = @"mockSubRegion";
static NSString* kMockLanguage = @"mockLanguage";

static NSString* kMockAboutMe = @"mockAboutMe";
static NSString* kMockBirthday = @"mockBirthday";

static NSString* kMockProfileUrl = @"mockProfileUrl";
static NSString* kMockThumb = @"mockThumb";
static NSString* kMockThumbSmall = @"mockThumbSmall";
static NSString* kMockThumbLarge = @"mockThumbLarge";
static NSString* kMockThumbHuge = @"mockThumbHuge";

static NSString* kMockGender = @"mockGender";
static NSString* kMockAge = @"mockAge";
static NSString* kMockBloodType = @"mockBloodType";

static NSString* kMockUserHash = @"mockUserHash";
static NSString* kMockUserType = @"mockUserType";
static NSString* kMockTimeZone = @"mockTimeZone";

static NSString* friendJsonPattern = @"{"
                                    @"\"id\":\"%@\", \"nickname\":\"mockNickName\", \"displayName\":\"mockDisplayName\", \"aboutMe\":\"mockAboutMe\","
                                    @"\"birthday\":\"mockbirthday\", \"profileUrl\":\"mockProfileUrl\", \"thumbnailUrl\":\"mockThumbUrl\","
                                    @"\"thumbnailUrlSmall\":\"mockThumbSmall\", \"thumbnailUrlLarge\":\"mockThumbLarge\", \"thumbnailUrlHuge\":\"mockThumbLarge\", \"gender\":\"mockGender\","
                                    @"\"age\":\"mockAge\", \"bloodType\":\"mockBloodType\", \"hasApp\":\"true\", \"userHash\":\"mockUserHash\", \"userType\":\"mockUserType\", \"userGrade\": \"2\", \"region\": \"AQ\", \"subregion\": \"\", \"language\": \"jpn-Jpan-JP\""
                                    @"}";
static NSString* friendListJsonPattern = @"{\"entry\": [%@],\"startIndex\":\"%d\",\"hasNext\": \"%d\",\"itemsPerPage\": \"%d\"}";


SPEC_BEGIN(GreeUserTests)

describe(@"GreeUserTests", ^{  
  registerMatchers(@"Gree");
  __block NSData* firstPageFriends = nil;
  __block NSData* fullPageIgnoreList = nil;
  __block GreeAuthorization *authMock;
  __block NSData* fakeImageData = nil;

  beforeAll(^{
    NSString* friend1 = [NSString stringWithFormat:friendJsonPattern, @"friend1"];
    NSString* friend2 = [NSString stringWithFormat:friendJsonPattern, @"friend2"];
    NSString* friend3 = [NSString stringWithFormat:friendJsonPattern, @"friend3"];
    NSString* friendArrayJson = [NSString stringWithFormat:@"%@,%@,%@", friend1, friend2, friend3];
    firstPageFriends = [[[NSString stringWithFormat:friendListJsonPattern, friendArrayJson, 1, 0, 3] dataUsingEncoding:NSUTF8StringEncoding] retain];
    fullPageIgnoreList = [[fullIgnorePage dataUsingEncoding:NSUTF8StringEncoding] retain];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(NULL, 50, 50, 8, 256, colorSpace, kCGImageAlphaPremultipliedLast);
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    UIImage* image = [UIImage imageWithCGImage:cgImage];
    fakeImageData = [UIImagePNGRepresentation(image) retain];
    CFRelease(cgImage);
    CFRelease(context);
  });
  
  afterAll(^{
    [firstPageFriends release];
    firstPageFriends = nil;
    [fullPageIgnoreList release];
    fullPageIgnoreList = nil;
    [fakeImageData release];
    fakeImageData = nil;
  });
  
  beforeEach(^{
    GreePlatform* mockedSdk = [GreePlatform nullMockAsSharedInstance];
    [mockedSdk stub:@selector(httpClient) andReturn:[GreeHTTPClient nullMock]];
    [mockedSdk stub:@selector(localUser) andReturn:[GreeUser nullMock]];
    [GreeURLMockingProtocol register];
    authMock = [[GreeAuthorization alloc] init];
    [authMock stub:@selector(isAuthorized) andReturn:theValue(YES)];
    [GreeAuthorization stub:@selector(sharedInstance) andReturn:authMock];
  });
  afterEach(^{
    [GreeURLMockingProtocol unregister];
    [authMock release];
  });
  
  it(@"should show description", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                kMockId, @"id",
                                kMockNickName, @"nickname",
                                kMockDisplayName, @"displayName",
                                
                                [NSNumber numberWithInt:kMockUserGrade], @"userGrade",
                                kMockRegion, @"region",
                                kMockSubRegion, @"subregion",
                                kMockLanguage, @"language",
                                
                                kMockAboutMe, @"aboutMe",
                                kMockBirthday, @"birthday",
                                
                                kMockProfileUrl, @"profileUrl",
                                kMockThumb, @"thumbnailUrl",
                                kMockThumbSmall, @"thumbnailUrlSmall",
                                kMockThumbLarge, @"thumbnailUrlLarge",
                                kMockThumbHuge, @"thumbnailUrlHuge",
                                
                                kMockGender, @"gender",
                                kMockAge, @"age",
                                kMockBloodType, @"bloodType",
                                
                                [NSNumber numberWithBool:YES], @"hasApp",
                                kMockUserHash, @"userHash",
                                kMockUserType, @"userType",
                                kMockTimeZone, @"timezone",
                                nil];
    GreeSerializer* serializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeUser* user = [[GreeUser alloc] initWithGreeSerializer:serializer];
    NSString* checkString = [NSString stringWithFormat:@"<%@:%p, id:%@, nickname:%@, hasThisApplication:YES, userGrade:%d, region:%@, subRegion:%@, language:%@, timeZone:%@>", 
                             NSStringFromClass([GreeUser class]),
                             user,
                             kMockId,
                             kMockNickName,
                             kMockUserGrade,
                             kMockRegion,
                             kMockSubRegion,
                             kMockLanguage,
                             kMockTimeZone];
    [[[user description] should] equal:checkString]; 
    [user release];
  });
  
  it(@"should compare solely based on userId", ^{
    NSMutableDictionary* sourceData = [NSMutableDictionary dictionaryWithObject:@"123" forKey:@"id"];
    
    [sourceData setObject:[NSNumber numberWithInt:24] forKey:@"age"];
    [sourceData setObject:@"male" forKey:@"gender"];
    
    GreeSerializer* deserializer = [GreeSerializer deserializerWithDictionary:sourceData];
    GreeUser* user1 = [[GreeUser alloc] initWithGreeSerializer:deserializer];

    [sourceData setObject:[NSNumber numberWithInt:36] forKey:@"age"];
    [sourceData setObject:@"female" forKey:@"gender"];
  
    deserializer = [GreeSerializer deserializerWithDictionary:sourceData];
    GreeUser* user2 = [[GreeUser alloc] initWithGreeSerializer:deserializer];
    
    [[user1 should] equal:user2];
    [[theValue([user1 hash]) should] equal:theValue([user2 hash])];
    
    [user1 release];
    [user2 release];
  });
  
  it(@"should deserialize", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                kMockId, @"id",
                                kMockNickName, @"nickname",
                                kMockDisplayName, @"displayName",
                                
                                [NSNumber numberWithInt:kMockUserGrade], @"userGrade",
                                kMockRegion, @"region",
                                kMockSubRegion, @"subregion",
                                kMockLanguage, @"language",
                                
                                kMockAboutMe, @"aboutMe",
                                kMockBirthday, @"birthday",
                                
                                kMockProfileUrl, @"profileUrl",
                                kMockThumb, @"thumbnailUrl",
                                kMockThumbSmall, @"thumbnailUrlSmall",
                                kMockThumbLarge, @"thumbnailUrlLarge",
                                kMockThumbHuge, @"thumbnailUrlHuge",
                                
                                kMockGender, @"gender",
                                kMockAge, @"age",
                                kMockBloodType, @"bloodType",
                                
                                [NSNumber numberWithBool:YES], @"hasApp",
                                kMockUserHash, @"userHash",
                                kMockUserType, @"userType",
                                kMockTimeZone, @"timezone",
                                nil];
    
    GreeSerializer* serializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeUser* user = [[GreeUser alloc] initWithGreeSerializer:serializer];
    
    [[user.userId should] equal:kMockId];
    [[user.nickname should] equal:kMockNickName];
    [[[user performSelector:@selector(displayName)] should] equal:kMockDisplayName];
    
    [[theValue(user.userGrade) should] equal:theValue(kMockUserGrade)];
    [[user.region should] equal:kMockRegion];
    [[user.subRegion should] equal:kMockSubRegion];
    [[user.language should] equal:kMockLanguage];   
    
    [[user.aboutMe should] equal:kMockAboutMe];
    [[user.birthday should] equal:kMockBirthday];
    
    [[[user performSelector:@selector(profileUrl)] should] equal:[NSURL URLWithString:kMockProfileUrl]];
    [[user.thumbnailUrl should] equal:[NSURL URLWithString:kMockThumb]];
    [[user.thumbnailUrlSmall should] equal:[NSURL URLWithString:kMockThumbSmall]];
    [[user.thumbnailUrlLarge should] equal:[NSURL URLWithString:kMockThumbLarge]];
    [[user.thumbnailUrlHuge should] equal:[NSURL URLWithString:kMockThumbHuge]];
    
    [[user.gender should] equal:kMockGender];
    [[user.age should] equal:kMockAge];
    [[user.bloodType should] equal:kMockBloodType];
    
    [[theValue([user hasThisApplication]) should] beTrue];
    [[[user performSelector:@selector(userHash)] should] equal:kMockUserHash];
    [[[user performSelector:@selector(userType)] should] equal:kMockUserType];
    [[user.timeZone should] equal:kMockTimeZone];    
    
    [user release];
  });
  
  it(@"should serialize", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                kMockId, @"id",
                                kMockNickName, @"nickname",
                                kMockDisplayName, @"displayName",
                                
                                [NSNumber numberWithInt:kMockUserGrade], @"userGrade",
                                kMockRegion, @"region",
                                kMockSubRegion, @"subregion",
                                kMockLanguage, @"language",

                                kMockAboutMe, @"aboutMe",
                                kMockBirthday, @"birthday",
                                
                                kMockProfileUrl, @"profileUrl",
                                kMockThumb, @"thumbnailUrl",
                                kMockThumbSmall, @"thumbnailUrlSmall",
                                kMockThumbLarge, @"thumbnailUrlLarge",
                                kMockThumbHuge, @"thumbnailUrlHuge",
                                
                                kMockGender, @"gender",
                                kMockAge, @"age",
                                kMockBloodType, @"bloodType",
                                
                                [NSNumber numberWithBool:YES], @"hasApp",
                                kMockUserHash, @"userHash",
                                kMockUserType, @"userType",
                                kMockTimeZone, @"timezone",
                                
                                @"2012-01-01 03:03:04", @"creationDate",
                                nil];
    
    GreeSerializer* deserializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeUser* user = [[GreeUser alloc] initWithGreeSerializer:deserializer];
    GreeSerializer* serializer = [GreeSerializer serializer];
    [user serializeWithGreeSerializer:serializer];
    [[serializer.rootDictionary should] equal:serialized];
    [user release];
  });

  it(@"should handle missing block in user profile download", ^{
    [GreeUser loadUserWithId:@"521249" block:nil];
    //just not dying is a sufficient test
  });
  
  it(@"should download user profile", ^{
    __block id waitObject = nil;
    MockedURLResponse* mockResponse = [[MockedURLResponse new] autorelease];
    mockResponse.data = [profileTxt dataUsingEncoding:NSUTF8StringEncoding];
    [GreeURLMockingProtocol addMock:mockResponse];
    
    [GreeUser loadUserWithId:@"521249" block:^(GreeUser* user, NSError* error){
      waitObject = [user retain];
    }];
    [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    GreeUser* user = (GreeUser*)waitObject;
    [[user.userId should] equal:@"521249"];
    [[user.nickname should] equal:@"bismuth01"];
    [[theValue([user hasThisApplication]) should] beTrue];
    [[user.timeZone should] equal:@"480"];
    
    [[theValue(user.userGrade) should] equal:theValue(2)];
    [[user.region should] equal:@"AQ"];
    [[user.language should] equal:@"jpn-Jpan-JP"];
    
    [waitObject release];
  });
  
  it(@"should handle failure when downloading user profile", ^{
    __block id waitObject = nil;
    MockedURLResponse* mockResponse = [[MockedURLResponse new] autorelease];
    mockResponse.statusCode = 500;
    [GreeURLMockingProtocol addMock:mockResponse];
    
    [GreeUser loadUserWithId:@"521249" block:^(GreeUser* user, NSError* error){
      waitObject = [error copy];
    }];
    [[expectFutureValue(waitObject) shouldEventually] beKindOfClass:[NSError class]];
    [waitObject release];
  });
  
  it(@"should handle 401 errors in downloading user profile", ^{
    GreeAuthorization* mockAuth = [[GreeAuthorization alloc] init];
    [GreeAuthorization stub:@selector(sharedInstance) andReturn:mockAuth];
    MockedURLResponse* mockResponse = [[MockedURLResponse new] autorelease];
    mockResponse.statusCode = 401;
    [GreeURLMockingProtocol addMock:mockResponse];
    
    id authSwizzle = [GreeAuthorization mockReauthorizeToSucceed];
    
    __block id wait = nil;
    [GreeUser loadUserWithId:@"521249" block:^(GreeUser* user, NSError* error){
      [error shouldNotBeNil];
      wait = @"DONE";
    }];
    [[expectFutureValue(wait) shouldEventually] beNonNil];
    [GreeTestHelpers restoreExchangedSelectors:&authSwizzle];
    [mockAuth release];
  });
  
  it(@"should still error with download user profile when authorization fails", ^{
    __block id waitObject = nil;
    GreeAuthorization* mockAuth = [[GreeAuthorization alloc] init];
    [GreeAuthorization stub:@selector(sharedInstance) andReturn:mockAuth];
    MockedURLResponse* mockResponse = [[MockedURLResponse new] autorelease];
    mockResponse.statusCode = 401;
    [GreeURLMockingProtocol addMock:mockResponse];
    
    id authSwizzle = [GreeAuthorization mockReauthorizeToFail];
    
    [GreeUser loadUserWithId:@"521249" block:^(GreeUser* user, NSError* error){
      waitObject = [error copy];
    }];
    [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    [waitObject release];
    [GreeTestHelpers restoreExchangedSelectors:&authSwizzle];
    [mockAuth release];
  });
  
  context(@"with a user", ^{
    __block GreeUser* user = nil;
    
    beforeEach(^{
      NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
        kMockId, @"id",
        kMockNickName, @"nickname",
        kMockDisplayName, @"displayName",
        
        [NSNumber numberWithInt:kMockUserGrade], @"userGrade",
        kMockRegion, @"region",
        kMockSubRegion, @"subregion",
        kMockLanguage, @"language",
        
        kMockAboutMe, @"aboutMe",
        kMockBirthday, @"birthday",
        
        kMockProfileUrl, @"profileUrl",
        kMockThumb, @"thumbnailUrl",
        kMockThumbSmall, @"thumbnailUrlSmall",
        kMockThumbLarge, @"thumbnailUrlLarge",
        kMockThumbHuge, @"thumbnailUrlHuge",
        
        kMockGender, @"gender",
        kMockAge, @"age",
        kMockBloodType, @"bloodType",
        
        [NSNumber numberWithBool:YES], @"hasApp",
        kMockUserHash, @"userHash",
        kMockUserType, @"userType",
        kMockTimeZone, @"timezone",
        nil];
      
      GreeSerializer* serializer = [GreeSerializer deserializerWithDictionary:serialized];
      user = [[GreeUser alloc] initWithGreeSerializer:serializer];      
    });
    
    afterEach(^{
      [user release];
    });
    
    context(@"with creation dates", ^{
      it(@"should serialize with one", ^{
        NSDate* userCreationDate = [user valueForKey:@"creationDate"];
        [userCreationDate shouldNotBeNil];
        GreeSerializer* reserialize = [GreeSerializer serializer];
        [user serializeWithGreeSerializer:reserialize];
        GreeUser* finalUser = [[GreeUser alloc] initWithGreeSerializer:reserialize];
        [finalUser shouldNotBeNil];
        [[[finalUser valueForKey:@"creationDate"] should] nearlyEqualDate:userCreationDate];
      });
    });

    it(@"should handle missing block in user profile picture download", ^{
      [user setValue:[NSURL URLWithString:[NSString stringWithFormat:@"%@/profileIcon", [GreeURLMockingProtocol httpClientPrefix]]] forKeyPath:@"thumbnailUrl"];
      [user loadThumbnailWithSize:GreeUserThumbnailSizeStandard block:nil];
    });

    it(@"should handle cancelled thumbnail download when there is no download in progress", ^{
        [user cancelThumbnailLoad];
    });

    context(@"loading thumbnail from expired user", ^{
      __block id waitObject = nil;
      __block MockedURLResponse* missingImage = nil;
      __block MockedURLResponse* mockUserResponse = nil;
      __block MockedURLResponse* mockImageResponse = nil;
      
      beforeEach(^{
        missingImage = [[MockedURLResponse alloc] init];
        missingImage.statusCode = 404;
        mockImageResponse = [[MockedURLResponse alloc] init];
        mockImageResponse.data = fakeImageData;
        mockImageResponse.statusCode = 200;
        mockImageResponse.headers = [NSDictionary dictionaryWithObject:@"image/png" forKey:@"Content-Type"];
        mockUserResponse = [[MockedURLResponse alloc] init];
        mockUserResponse.statusCode = 200;
        mockUserResponse.data = [profileTxt2 dataUsingEncoding:NSUTF8StringEncoding];
      });
      
      afterEach(^{
        [missingImage release];
        [mockImageResponse release];
        [mockUserResponse release];
        waitObject = nil;
      });

      it(@"should reload expired thumbnail URLs", ^{
        [GreeURLMockingProtocol addMock:missingImage];
        [GreeURLMockingProtocol addMock:mockUserResponse];
        [GreeURLMockingProtocol addMock:mockImageResponse];
        
        [user setValue:[NSURL URLWithString:@"http://test.gree.net/URLSMALL"] forKey:@"thumbnailUrlSmall"];
        [user loadThumbnailWithSize:GreeUserThumbnailSizeSmall block:^(UIImage *icon, NSError *error) {
          [icon shouldNotBeNil];
          waitObject = @"DONE";
        }];
        [[expectFutureValue(waitObject) shouldEventually] equal:@"DONE"];
        [[[user valueForKey:@"creationDate"] should] nearlyEqualDate:[NSDate date]];
        [[[[user valueForKey:@"thumbnailUrl"] absoluteString] should] equal:@"http://test.gree.net/main"];
        [[[[user valueForKey:@"thumbnailUrlSmall"] absoluteString] should] equal:@"http://test.gree.net/small"];
        [[[[user valueForKey:@"thumbnailUrlLarge"] absoluteString] should] equal:@"http://test.gree.net/large"];
        [[[[user valueForKey:@"thumbnailUrlHuge"] absoluteString] should] equal:@"http://test.gree.net/huge"];
      });
    });  
    
    context(@"and a mocked success response", ^{
      __block id waitObject = nil;
      __block MockedURLResponse* mockResponse = nil;

      beforeEach(^{
        mockResponse = [[MockedURLResponse alloc] init];
        mockResponse.data = fakeImageData;
        mockResponse.headers = [NSDictionary dictionaryWithObject:@"image/png" forKey:@"Content-Type"];
        mockResponse.statusCode = 200;
        [GreeURLMockingProtocol addMock:mockResponse];
      });
      
      afterEach(^{
        [waitObject release];
        waitObject = nil;
        [mockResponse release];
        mockResponse = nil;
      });
      
      it(@"should handle cancelled thumbnail download", ^{
        mockResponse.delay = .1f;
        
        [user setValue:[NSURL URLWithString:[NSString stringWithFormat:@"%@/profileIcon", [GreeURLMockingProtocol httpClientPrefix]]] forKeyPath:@"thumbnailUrl"];
        [user loadThumbnailWithSize:GreeUserThumbnailSizeStandard block:^(UIImage* icon, NSError* error) {
          waitObject = [icon retain];
        }];

        [user cancelThumbnailLoad];
        
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:mockResponse.delay + .01f]];
        [waitObject shouldBeNil];
      });

      
      it(@"should cancel previous outstanding downloads when another is request", ^{
        mockResponse.delay = .1f;

        MockedURLResponse* secondResponse = [[[MockedURLResponse alloc] init] autorelease];
        secondResponse.data = fakeImageData;
        secondResponse.headers = [NSDictionary dictionaryWithObject:@"image/png" forKey:@"Content-Type"];
        secondResponse.statusCode = 200;
        [GreeURLMockingProtocol addMock:secondResponse];
        
        [user setValue:[NSURL URLWithString:[NSString stringWithFormat:@"%@/profileIcon", [GreeURLMockingProtocol httpClientPrefix]]] forKeyPath:@"thumbnailUrl"];
        [user setValue:[NSURL URLWithString:[NSString stringWithFormat:@"%@/profileIcon", [GreeURLMockingProtocol httpClientPrefix]]] forKeyPath:@"thumbnailUrlHuge"];

        [user loadThumbnailWithSize:GreeUserThumbnailSizeStandard block:^(UIImage* icon, NSError* error) {
          // we should never get here
          waitObject = @"standard icon";
          [[waitObject should] equal:@"bzzt"];
        }];
        
        [user loadThumbnailWithSize:GreeUserThumbnailSizeHuge block:^(UIImage* icon, NSError* error) {
          waitObject = @"huge icon";
        }];

        [[expectFutureValue(waitObject) shouldEventually] equal:@"huge icon"];
      });
    
      it(@"should download standard thumbnail", ^{        
        [user setValue:[NSURL URLWithString:[NSString stringWithFormat:@"%@/profileIcon", [GreeURLMockingProtocol httpClientPrefix]]] forKeyPath:@"thumbnailUrl"];
        [user loadThumbnailWithSize:GreeUserThumbnailSizeStandard block:^(UIImage* icon, NSError* error) {
          waitObject = [icon retain];
        }];
        [[expectFutureValue(waitObject) shouldEventually] beKindOfClass:[UIImage class]];
      });

      it(@"should download small thumbnail", ^{        
        [user setValue:[NSURL URLWithString:[NSString stringWithFormat:@"%@/profileIcon", [GreeURLMockingProtocol httpClientPrefix]]] forKeyPath:@"thumbnailUrlSmall"];
        [user loadThumbnailWithSize:GreeUserThumbnailSizeSmall block:^(UIImage* icon, NSError* error) {
          waitObject = [icon retain];
        }];
        [[expectFutureValue(waitObject) shouldEventually] beKindOfClass:[UIImage class]];
      });

      it(@"should download large thumbnail", ^{
        [user setValue:[NSURL URLWithString:[NSString stringWithFormat:@"%@/profileIcon", [GreeURLMockingProtocol httpClientPrefix]]] forKeyPath:@"thumbnailUrlLarge"];
        [user loadThumbnailWithSize:GreeUserThumbnailSizeLarge block:^(UIImage* icon, NSError* error) {
          waitObject = [icon retain];
        }];
        [[expectFutureValue(waitObject) shouldEventually] beKindOfClass:[UIImage class]];
      });

      it(@"should download huge thumbnail", ^{        
        [user setValue:[NSURL URLWithString:[NSString stringWithFormat:@"%@/profileIcon", [GreeURLMockingProtocol httpClientPrefix]]] forKeyPath:@"thumbnailUrlHuge"];
        [user loadThumbnailWithSize:GreeUserThumbnailSizeHuge block:^(UIImage* icon, NSError* error) {
          waitObject = [icon retain];
        }];
        [[expectFutureValue(waitObject) shouldEventually] beKindOfClass:[UIImage class]];
      });
      
    });

    it(@"should handle failure when downloading user profile picture", ^{
      __block id waitObject = nil;
      MockedURLResponse* mockResponse = [[MockedURLResponse new] autorelease];
      mockResponse.statusCode = 500;
      [GreeURLMockingProtocol addMock:mockResponse];
      
      [user setValue:[NSURL URLWithString:[NSString stringWithFormat:@"%@/profileIcon", [GreeURLMockingProtocol httpClientPrefix]]] forKeyPath:@"thumbnailUrl"];
      [user loadThumbnailWithSize:GreeUserThumbnailSizeStandard block:^(UIImage* icon, NSError* error) {
        waitObject = [error retain];
      }];
      [[expectFutureValue(waitObject) shouldEventually] beKindOfClass:[NSError class]];
      [waitObject release];
    });

    it(@"should handle missing block in load friends", ^{
      [user loadFriendsWithBlock:nil];
    });
    
    it(@"should load friends", ^{
      __block id waitObject = nil;
      MockedURLResponse* mockResponse = [[MockedURLResponse new] autorelease];
      mockResponse.data = [friendsStr dataUsingEncoding:NSUTF8StringEncoding];
      [GreeURLMockingProtocol addMock:mockResponse];
      
      [user loadFriendsWithBlock:^(NSArray* friends, NSError* error) {
        waitObject = [friends retain];
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];

      NSArray* friendList = (NSArray*)waitObject;
      GreeUser* user = [friendList objectAtIndex:0];
      [[user.userId should] equal:@"id1"];
      [[user.nickname should] equal:@"nickname1"];
      
      user = [friendList objectAtIndex:1];
      [[user.userId should] equal:@"id2"];
      [[user.nickname should] equal:@"nickname2"];
      [waitObject release];
    });

    it(@"should handle load friends failure", ^{
      __block id waitObject = nil;
      MockedURLResponse* mockResponse = [[MockedURLResponse new] autorelease];
      mockResponse.statusCode = 500;
      [GreeURLMockingProtocol addMock:mockResponse];
      
      [user loadFriendsWithBlock:^(NSArray* friends, NSError* error) {
        waitObject = [error copy];
      }];

      [[expectFutureValue(waitObject) shouldEventually] beKindOfClass:[NSError class]];
      [waitObject release];
    });

    it(@"should handle missing block in load ignored users", ^{
      [user loadIgnoredUserIdsWithBlock:nil];
    });

    it(@"should load ignored users", ^{
      __block id waitObject = nil;
      MockedURLResponse* mockResponse = [[MockedURLResponse new] autorelease];
      mockResponse.data = [ignoredFriends dataUsingEncoding:NSUTF8StringEncoding];
      [GreeURLMockingProtocol addMock:mockResponse];
      
      [user loadIgnoredUserIdsWithBlock:^(NSArray* ignoredUsers, NSError* error) {
        waitObject = [ignoredUsers retain];
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];

      NSArray* ignoreList = (NSArray*)waitObject;    
      [[theValue([ignoreList count]) should] equal:theValue(4)];
      
      [[[ignoreList objectAtIndex:0] should] equal:@"101"];
      [[[ignoreList objectAtIndex:1] should] equal:@"102"];
      [[[ignoreList objectAtIndex:2] should] equal:@"103"];

      [waitObject release];
    });
    
    it(@"should handle load ignored users failure", ^{
      __block id waitObject = nil;
      MockedURLResponse* mockResponse = [[MockedURLResponse new] autorelease];
      mockResponse.statusCode = 500;
      [GreeURLMockingProtocol addMock:mockResponse];
      
      [user loadIgnoredUserIdsWithBlock:^(NSArray* ignoredUsers, NSError* error) {
        waitObject = [error copy];
      }];
      [[expectFutureValue(waitObject) shouldEventually] beKindOfClass:[NSError class]];
      [waitObject release];
    });
    
    it(@"should handle missing block in checking user ignored", ^{
      [user isIgnoringUserWithId:@"usertocheck" block:nil];
    });
    
    it(@"should download ignored status information, and the entry data is an array", ^{
      __block id waitObject = nil;
      MockedURLResponse* mockResponse = [[MockedURLResponse new] autorelease];
      mockResponse.data = [bannedStrArray dataUsingEncoding:NSUTF8StringEncoding];
      [GreeURLMockingProtocol addMock:mockResponse];
      
      [user isIgnoringUserWithId:@"110" block:^(BOOL isIgnored, NSError* error) {
        waitObject = [[NSNumber numberWithBool:isIgnored] retain];
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];

      [[theValue([waitObject boolValue]) should] beYes];      
      [waitObject release];
    });
    
    it(@"should download ignored status information, and the entry data is a dictionary", ^{
      __block id waitObject = nil;
      MockedURLResponse* mockResponse = [[MockedURLResponse new] autorelease];
      mockResponse.data = [bannedStrDict dataUsingEncoding:NSUTF8StringEncoding];
      [GreeURLMockingProtocol addMock:mockResponse];
      
      [user isIgnoringUserWithId:@"110" block:^(BOOL isIgnored, NSError* error) {
        waitObject = [[NSNumber numberWithBool:isIgnored] retain];
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      
      [[theValue([waitObject boolValue]) should] beYes];      
      [waitObject release];
    });
    
    it(@"should download ignored status information, and the entry data is a bad data format", ^{
      __block id waitObject = nil;
      __block id waitError = nil;
      MockedURLResponse* mockResponse = [[MockedURLResponse new] autorelease];
      mockResponse.data = [BannedBadStr dataUsingEncoding:NSUTF8StringEncoding];
      [GreeURLMockingProtocol addMock:mockResponse];
      
      [user isIgnoringUserWithId:@"110" block:^(BOOL isIgnored, NSError* error) {
        waitObject = [[NSNumber numberWithBool:isIgnored] retain];
        waitError = [error retain];
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      [[theValue([waitObject boolValue]) should] beNo];  
      
      [[expectFutureValue(waitError) shouldEventually] beNonNil];
      NSError* error = (NSError*)waitError;
      [[theValue(error.code) should] equal:theValue(GreeErrorCodeBadDataFromServer)];
      [waitObject release];
      [waitError release];
    });
    
    it(@"should download not ignored status information", ^{
      __block id waitObject = nil;
      MockedURLResponse* mockResponse = [[MockedURLResponse new] autorelease];
      mockResponse.data = [notBannedStr dataUsingEncoding:NSUTF8StringEncoding];
      [GreeURLMockingProtocol addMock:mockResponse];
      
      [user isIgnoringUserWithId:@"110" block:^(BOOL isIgnored, NSError* error) {
        waitObject = [[NSNumber numberWithBool:isIgnored] retain];
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];

      [[theValue([waitObject boolValue]) should] beNo];      
      [waitObject release];
    });
    
    it(@"should handle failure when downloading ignored status", ^{
      __block id waitObject = nil;
      MockedURLResponse* mockResponse = [[MockedURLResponse new] autorelease];
      mockResponse.statusCode = 500;
      [GreeURLMockingProtocol addMock:mockResponse];
      
      [user isIgnoringUserWithId:@"userToCheck" block:^(BOOL isIgnored, NSError* error) {
        waitObject = [error copy];
      }];
      [[expectFutureValue(waitObject) shouldEventually] beKindOfClass:[NSError class]];
      [waitObject release];
    });
  });
    
  context(@"enumerator friends", ^{
    __block NSObject<GreeEnumerator>* enumerator = nil;
    
    beforeEach(^{
      NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
        kMockId, @"id",
        nil];
      GreeSerializer* serializer = [GreeSerializer deserializerWithDictionary:serialized];
      GreeUser* user = [[GreeUser alloc] initWithGreeSerializer:serializer];
      enumerator = [[user loadFriendsWithBlock:nil] retain];
      [user release];
    });
    
    afterEach(^{
      [enumerator release];
      enumerator = nil;
    });
    
    it(@"should exist", ^{
      [[enumerator should] beNonNil];
    });
    
    it(@"should read a page", ^{
      __block id waitObject = nil;
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      mock.data = firstPageFriends;
      [GreeURLMockingProtocol addMock:mock];
      
      [enumerator loadNext:^(NSArray *items, NSError *error) {
        waitObject = [items retain];
      }];
      
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      [[theValue([waitObject count]) should] equal:theValue(3)];
      [[[waitObject objectAtIndex:0] should] beKindOfClass:[GreeUser class]];
      [waitObject release];
    });
    
    it(@"should go back a page", ^{
      __block id waitObject = nil;
      MockedURLResponse* pullPageMock = [[MockedURLResponse new] autorelease];
      pullPageMock.data = firstPageFriends;
      [GreeURLMockingProtocol addMock:pullPageMock];
      [GreeURLMockingProtocol addMock:pullPageMock];
      [GreeURLMockingProtocol addMock:pullPageMock];
      
      [enumerator loadNext:^(NSArray *items, NSError *error) {
        [enumerator loadNext:^(NSArray *items, NSError *error) {
          [enumerator loadPrevious:^(NSArray *items, NSError *error) {
            waitObject = [items retain];
          }];
        }];
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      [[theValue([waitObject count]) should] equal:theValue(3)];
      [[[waitObject objectAtIndex:0] should] beKindOfClass:[GreeUser class]];
      [waitObject release];
    });

  });
  
  context(@"enumerator friend ignorelist", ^{
    __block NSObject<GreeEnumerator>* enumerator = nil;
    
    beforeEach(^{
      NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
        kMockId, @"id",
        nil];
      GreeSerializer* serializer = [GreeSerializer deserializerWithDictionary:serialized];
      GreeUser* user = [[GreeUser alloc] initWithGreeSerializer:serializer];
      enumerator = [user loadIgnoredUserIdsWithBlock:nil];
      [user release];
    });
    
    it(@"should exist", ^{
      [[enumerator should] beNonNil];
    });
    
    it(@"should read a page", ^{
      __block id waitObject = nil;
      MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
      mock.data = fullPageIgnoreList;
      [GreeURLMockingProtocol addMock:mock];
      
      [enumerator loadNext:^(NSArray *items, NSError *error) {
        waitObject = [items retain];
      }];
      
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      [[waitObject should] haveCountOf:3];
      [waitObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [[obj should] beKindOfClass:[NSString class]];
      }];
      [waitObject release];
    });
    
    it(@"should go back a page", ^{
      __block id waitObject = nil;
      MockedURLResponse* pullPageMock = [[MockedURLResponse new] autorelease];
      pullPageMock.data = fullPageIgnoreList;
      [GreeURLMockingProtocol addMock:pullPageMock];
      [GreeURLMockingProtocol addMock:pullPageMock];
      [GreeURLMockingProtocol addMock:pullPageMock];
      
      [enumerator loadNext:^(NSArray *items, NSError *error) {
        [enumerator loadNext:^(NSArray *items, NSError *error) {
          [enumerator loadPrevious:^(NSArray *items, NSError *error) {
            waitObject = [items retain];
          }];
        }];
      }];
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      [[waitObject should] haveCountOf:3];
      [waitObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [[obj should] beKindOfClass:[NSString class]];
      }];
      [waitObject release];
    });
  });  
  it(@"should allow grade updates", ^{
    [[[GreePlatform sharedInstance].localUser should] receive:@selector(setUserGrade:)];
    [GreeUser upgradeLocalUser:2];
  });

});

SPEC_END
