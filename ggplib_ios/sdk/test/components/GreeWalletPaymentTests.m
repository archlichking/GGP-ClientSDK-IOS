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
#import "GreeWalletPayment.h"

#import "GreePlatform.h"
#import "GreeURLMockingProtocol.h"
#import "GreeTestHelpers.h"
#import "GreeUser.h"
#import "GreeError.h"
#import "GreeWalletPaymentItem.h"

SPEC_BEGIN(GreeWalletPaymentTests)

describe(@"Gree WalletPayment", ^{
  __block GreePlatform* mockedSdk = nil;
  __block GreeUser* greeUser = nil;
  __block GreeWalletPayment* walletPayment = nil;
  
  beforeAll(^{
    greeUser = [[GreeUser alloc] init];
    [greeUser  setValue:@"319" forKey:@"userId"];
  });
  
  afterAll(^{
    [greeUser release];
    greeUser = nil;
  });
  
  beforeEach(^{
    [GreeHTTPClient stub:@selector(userAgentString) andReturn:@"Duuuhh"];
    mockedSdk = [[GreePlatform nullMockAsSharedInstance] retain];
    [mockedSdk stub:@selector(localUser) andReturn:greeUser];
    [mockedSdk stub:@selector(localUserId) andReturn:greeUser.userId];
    [GreeURLMockingProtocol register];
    walletPayment = [[GreeWalletPayment alloc] init];
    [walletPayment setValue:[GreeHTTPClient nullMock] forKey:@"httpConsumerClient"];    
  });
  
  afterEach(^{
    [GreeURLMockingProtocol unregister];
    [mockedSdk release];
    mockedSdk = nil;
    [walletPayment release];
    walletPayment = nil;
  });

  it(@"should verify success", ^{
    __block id waitObject = nil;
    MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
    NSString* responseString = @"{\"entry\":{\"paymentId\":\"003447\",\"platform\":\"ios\",\"status\":\"2\",\"paymentItems\": [{\"itemId\":\"ex101\",\"itemName\":\"NameOfTheItem\",\"unitPrice\":\"300\",\"quantity\":\"1\",\"imageUrl\":\"\",\"description\":\"descriptionString\"}]}}";
    mock.data = [responseString  dataUsingEncoding:NSUTF8StringEncoding];
    [GreeURLMockingProtocol addMock:mock];    
    [walletPayment paymentVerifyWithPaymentId:@"12345" 
       successBlock:^(NSString* paymentId, NSArray* items){
         waitObject = [items retain];
         [[paymentId should] equal:@"003447"];
       }
       failureBlock:^(NSString* paymentId, NSArray* items, NSError* error){
       }
     ];
    [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    GreeWalletPaymentItem* item = [waitObject objectAtIndex:0];
    [[item.itemId should] equal:@"ex101"];
    [[item.itemName should] equal:@"NameOfTheItem"];
    [[theValue(item.unitPrice) should] equal:theValue(300)];
    [[theValue(item.quantity) should] equal:theValue(1)];
    [[item.description should] equal:@"descriptionString"];    
    [waitObject release];
  });  
  
  it(@"should verify failure because of cancel operation", ^{
    //Actually this pattern doesn't occur.
    __block id waitObject = nil;
    MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
    NSString* responseString = @"{\"entry\":{\"paymentId\":\"003447\",\"platform\":\"ios\",\"status\":\"3\",\"paymentItems\": [{\"itemId\":\"ex101\",\"itemName\":\"NameOfTheItem\",\"unitPrice\":\"300\",\"quantity\":\"1\",\"imageUrl\":\"\",\"description\":\"descriptionString\"}]}}";
    mock.data = [responseString  dataUsingEncoding:NSUTF8StringEncoding];
    [GreeURLMockingProtocol addMock:mock];
    [walletPayment paymentVerifyWithPaymentId:@"12345" 
       successBlock:^(NSString* paymentId, NSArray* items){
       }
       failureBlock:^(NSString* paymentId, NSArray* items, NSError* error){
         waitObject = [items retain];
         [[paymentId should] equal:@"003447"];
         [[theValue(error.code) should] equal:theValue(GreeWalletPaymentErrorCodeUserCanceled)];
       }
     ];
    [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    GreeWalletPaymentItem* item = [waitObject objectAtIndex:0];
    [[item.itemId should] equal:@"ex101"];
    [[item.itemName should] equal:@"NameOfTheItem"];
    [[theValue(item.unitPrice) should] equal:theValue(300)];
    [[theValue(item.quantity) should] equal:theValue(1)];
    [[item.description should] equal:@"descriptionString"];
    [waitObject release];
  });  
  
  it(@"should verify failure because of transaction expire", ^{
    __block id waitObject = nil;
    MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
    NSString* responseString = @"{\"entry\":{\"paymentId\":\"003447\",\"platform\":\"ios\",\"status\":\"4\",\"paymentItems\": [{\"itemId\":\"ex101\",\"itemName\":\"NameOfTheItem\",\"unitPrice\":\"300\",\"quantity\":\"1\",\"imageUrl\":\"\",\"description\":\"descriptionString\"}]}}";
    mock.data = [responseString  dataUsingEncoding:NSUTF8StringEncoding];
    [GreeURLMockingProtocol addMock:mock];
    [walletPayment paymentVerifyWithPaymentId:@"12345" 
       successBlock:^(NSString* paymentId, NSArray* items){
       }
       failureBlock:^(NSString* paymentId, NSArray* items, NSError* error){
         waitObject = [items retain];
         [[paymentId should] equal:@"003447"];
         [[theValue(error.code) should] equal:theValue(GreeWalletPaymentErrorCodeTransactionExpired)];
       }
     ];
    [[expectFutureValue(waitObject) shouldEventually] beNonNil];
    GreeWalletPaymentItem* item = [waitObject objectAtIndex:0];
    [[item.itemId should] equal:@"ex101"];
    [[item.itemName should] equal:@"NameOfTheItem"];
    [[theValue(item.unitPrice) should] equal:theValue(300)];
    [[theValue(item.quantity) should] equal:theValue(1)];
    [[item.description should] equal:@"descriptionString"];
    [waitObject release];
  });  

  it(@"should verify failure because of unexpected JSON", ^{
    __block id waitObject = nil;
    MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
    NSString* responseString = @"{\"entry\":[\"obj1\",\"obj2\"]}";
    mock.data = [responseString  dataUsingEncoding:NSUTF8StringEncoding];
    [GreeURLMockingProtocol addMock:mock];
    [walletPayment paymentVerifyWithPaymentId:@"12345" 
       successBlock:^(NSString* paymentId, NSArray* items){
         waitObject = @"success";
       }
       failureBlock:^(NSString* paymentId, NSArray* items, NSError* error){
         [paymentId shouldBeNil];
         [items shouldBeNil];
         [[theValue(error.code) should] equal:theValue(GreeErrorCodeBadDataFromServer)];
       }
     ];
    [[expectFutureValue(waitObject) shouldEventually] beNil];
  });  
    
  it(@"should verify failure because of network error", ^{
    __block id waitObject = nil;
    [walletPayment paymentVerifyWithPaymentId:@"12345" 
     successBlock:^(NSString* paymentId, NSArray* items){
       waitObject = @"success";
     }
     failureBlock:^(NSString* paymentId, NSArray* items, NSError* error){
       [paymentId shouldBeNil];
       [items shouldBeNil];
     }
    ];
    [[expectFutureValue(waitObject) shouldEventually] beNil];
  });  

  it(@"should call verifyPaymentWithGettingUserId when missing userId", ^{
    [mockedSdk stub:@selector(localUser) andReturn:nil];
    [mockedSdk stub:@selector(localUserId) andReturn:nil];
    [[walletPayment should] receive:@selector(verifyPaymentWithGettingUserId)];
    [walletPayment paymentVerifyWithPaymentId:@"12345" 
       successBlock:^(NSString* paymentId, NSArray* items){
       }
       failureBlock:^(NSString* paymentId, NSArray* items, NSError* error){
       }
     ];
  });  
  
});

SPEC_END

