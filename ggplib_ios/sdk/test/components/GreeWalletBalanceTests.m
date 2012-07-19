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
#import "GreeWalletBalance.h"
#import "GreePlatform.h"
#import "GreeURLMockingProtocol.h"
#import "GreeTestHelpers.h"
#import "GreeUser.h"
#import "GreeError.h"

#pragma mark - GreeWalletBalanceTests

SPEC_BEGIN(GreeWalletBalanceTests)
describe(@"Gree WalletPayment", ^{
  __block GreeWalletBalance* walletBalance = nil;

  beforeEach(^{
    [GreeHTTPClient stub:@selector(userAgentString) andReturn:@"TestMockUserAgent"];
    [GreeURLMockingProtocol register];
    [GreeNetworkReachability stub:@selector(alloc) andReturn:[GreeNetworkReachability nullMockWithStatus:GreeNetworkReachabilityConnectedViaWiFi]];
    [GreePlatform initializeWithApplicationId:@"123" consumerKey:@"123" consumerSecret:@"123" settings:nil delegate:nil];
    [[GreePlatform sharedInstance] stub:@selector(httpsClient) andReturn:[GreeHTTPClient nullMock]];
  });
  
  afterEach(^{
    [[[GreePlatform sharedInstance] shouldEventuallyBeforeTimingOutAfter(10.f)] receive:@selector(dealloc)];
    [GreePlatform shutdown];
    [GreeURLMockingProtocol unregister];
  });
  
  it(@"should return balance of 9001", ^{
    GreeUser* greeUser = [[GreeUser alloc] init];
    [greeUser  setValue:@"319" forKey:@"userId"];
    [[GreePlatform sharedInstance] stub:@selector(localUser) andReturn:greeUser];
    [[GreePlatform sharedInstance] stub:@selector(localUserId) andReturn:greeUser.userId];

    GreeNetworkReachability* networkReachability = [[GreeNetworkReachability alloc] init];
    [networkReachability stub:@selector(isConnectedToInternet) andReturn:theValue(YES)];
    [[GreePlatform sharedInstance] stub:@selector(reachability) andReturn:networkReachability];
    
    walletBalance = [[GreeWalletBalance alloc] init];
    
    __block NSNumber* numberObject = nil;
    __block NSError* errorObject = nil;
    MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
    NSString* responseString = @"{\"entry\":{\"user_id\":\"319\",\"balance\":\"9001\",\"platform\":\"ios\"}}";
    mock.data = [responseString  dataUsingEncoding:NSUTF8StringEncoding];
    [GreeURLMockingProtocol addMock:mock];
    
    [walletBalance queryWalletBalance:^(unsigned long long balance, NSError* error){
      numberObject = [[NSNumber numberWithLongLong:balance] retain];
      errorObject = [error retain];
    }];
    
    [[expectFutureValue(numberObject) shouldEventually] beNonNil];
    [[expectFutureValue(errorObject) shouldEventually] beNil];
    [[numberObject should] equal:theValue(9001)];
    
    [numberObject release];
    [errorObject release];
    [walletBalance release];
    [greeUser release];
    greeUser = nil;
  });

  it(@"should return balance of 0", ^{
    GreeUser* greeUser = [[GreeUser alloc] init];
    [greeUser  setValue:@"319" forKey:@"userId"];
    [[GreePlatform sharedInstance] stub:@selector(localUser) andReturn:greeUser];
    [[GreePlatform sharedInstance] stub:@selector(localUserId) andReturn:greeUser.userId];
    
    GreeNetworkReachability* networkReachability = [[GreeNetworkReachability alloc] init];
    [networkReachability stub:@selector(isConnectedToInternet) andReturn:theValue(YES)];
    [[GreePlatform sharedInstance] stub:@selector(reachability) andReturn:networkReachability];
    
    walletBalance = [[GreeWalletBalance alloc] init];
    
    __block NSNumber* numberObject = nil;
    __block NSError* errorObject = nil;
    MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
    NSString* responseString = @"{\"entry\":{\"user_id\":\"319\",\"balance\":\"0\",\"platform\":\"ios\"}}";
    mock.data = [responseString  dataUsingEncoding:NSUTF8StringEncoding];
    [GreeURLMockingProtocol addMock:mock];
    
    [walletBalance queryWalletBalance:^(unsigned long long balance, NSError* error){
      numberObject = [[NSNumber numberWithLongLong:balance] retain];
      errorObject = [error retain];
    }];
    
    [[expectFutureValue(numberObject) shouldEventually] beNonNil];
    [[expectFutureValue(errorObject) shouldEventually] beNil];
    [[numberObject should] equal:theValue(0)];
    
    [numberObject release];
    [errorObject release];
    [walletBalance release];
    [greeUser release];
    greeUser = nil;
  });
  
  it(@"should return error code GreeErrorCodeBadDataFromServer", ^{
    GreeUser* greeUser = [[GreeUser alloc] init];
    [greeUser  setValue:@"319" forKey:@"userId"];
    [[GreePlatform sharedInstance] stub:@selector(localUser) andReturn:greeUser];
    [[GreePlatform sharedInstance] stub:@selector(localUserId) andReturn:greeUser.userId];
    
    GreeNetworkReachability* networkReachability = [[GreeNetworkReachability alloc] init];
    [networkReachability stub:@selector(isConnectedToInternet) andReturn:theValue(YES)];
    [[GreePlatform sharedInstance] stub:@selector(reachability) andReturn:networkReachability];
    
    walletBalance = [[GreeWalletBalance alloc] init];
    
    __block NSNumber* numberObject = nil;
    __block NSError* errorObject = nil;
    MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
    NSString* responseString = @"{asdfqwerasdfasfasdfasdfasdf}";
    mock.data = [responseString  dataUsingEncoding:NSUTF8StringEncoding];
    [GreeURLMockingProtocol addMock:mock];
    
    [walletBalance queryWalletBalance:^(unsigned long long balance, NSError* error){
      numberObject = [[NSNumber numberWithLongLong:balance] retain];
      errorObject = [error retain];
    }];
    
    [[expectFutureValue(numberObject) shouldEventually] beNonNil];
    [[expectFutureValue(errorObject) shouldEventually] beNonNil];
    [[theValue(errorObject.code) should] equal:theValue(GreeErrorCodeBadDataFromServer)];
    [[numberObject should] equal:theValue(0)];
    
    [numberObject release];
    [errorObject release];
    [walletBalance release];
    [greeUser release];
    greeUser = nil;
  });
  
  it(@"should return error code GreeErrorCodeUserRequired", ^{
    GreeUser* greeUser = nil;
    [[GreePlatform sharedInstance] stub:@selector(localUser) andReturn:greeUser];
    [[GreePlatform sharedInstance] stub:@selector(localUserId) andReturn:greeUser.userId];
    
    GreeNetworkReachability* networkReachability = [[GreeNetworkReachability alloc] init];
    [networkReachability stub:@selector(isConnectedToInternet) andReturn:theValue(YES)];
    [[GreePlatform sharedInstance] stub:@selector(reachability) andReturn:networkReachability];
    
    walletBalance = [[GreeWalletBalance alloc] init];
    
    __block NSNumber* numberObject = nil;
    __block NSError* errorObject = nil;
    MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
    NSString* responseString = @"{\"entry\":{\"user_id\":\"319\",\"balance\":\"9001\",\"platform\":\"ios\"}}";
    mock.data = [responseString  dataUsingEncoding:NSUTF8StringEncoding];
    [GreeURLMockingProtocol addMock:mock];
    
    [walletBalance queryWalletBalance:^(unsigned long long balance, NSError* error){
      numberObject = [[NSNumber numberWithLongLong:balance] retain];
      errorObject = [error retain];
    }];
    
    [[expectFutureValue(numberObject) shouldEventually] beNonNil];
    [[expectFutureValue(errorObject) shouldEventually] beNonNil];
    [[theValue(errorObject.code) should] equal:theValue(GreeErrorCodeUserRequired)];
    [[numberObject should] equal:theValue(0)];
    
    [numberObject release];
    [errorObject release];
    [walletBalance release];
    [greeUser release];
    greeUser = nil;
  });
  
  it(@"should return error code GreeErrorCodeNetworkError", ^{
    GreeUser* greeUser = [[GreeUser alloc] init];
    [greeUser  setValue:@"319" forKey:@"userId"];
    [[GreePlatform sharedInstance] stub:@selector(localUser) andReturn:greeUser];
    [[GreePlatform sharedInstance] stub:@selector(localUserId) andReturn:greeUser.userId];
    
    GreeNetworkReachability* networkReachability = [[GreeNetworkReachability alloc] init];
    [networkReachability stub:@selector(isConnectedToInternet) andReturn:theValue(NO)];
    [[GreePlatform sharedInstance] stub:@selector(reachability) andReturn:networkReachability];
    
    walletBalance = [[GreeWalletBalance alloc] init];
    
    __block NSNumber* numberObject = nil;
    __block NSError* errorObject = nil;
    MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
    NSString* responseString = @"{\"entry\":{\"user_id\":\"319\",\"balance\":\"9001\",\"platform\":\"ios\"}}";
    mock.data = [responseString  dataUsingEncoding:NSUTF8StringEncoding];
    [GreeURLMockingProtocol addMock:mock];
    
    [walletBalance queryWalletBalance:^(unsigned long long balance, NSError* error){
      numberObject = [[NSNumber numberWithLongLong:balance] retain];
      errorObject = [error retain];
    }];
    
    [[expectFutureValue(numberObject) shouldEventually] beNonNil];
    [[expectFutureValue(errorObject) shouldEventually] beNonNil];
    [[theValue((errorObject).code) should] equal:theValue(GreeErrorCodeNetworkError)];
    [[numberObject should] equal:theValue(0)];
    
    [numberObject release];
    [errorObject release];
    [walletBalance release];
    [greeUser release];
    greeUser = nil;
  });
  
  it(@"should return error code GreeWalletBalanceErrorCodeTransactionAlreadyInProgress", ^{
    GreeUser* greeUser = [[GreeUser alloc] init];
    [greeUser  setValue:@"319" forKey:@"userId"];
    [[GreePlatform sharedInstance] stub:@selector(localUser) andReturn:greeUser];
    [[GreePlatform sharedInstance] stub:@selector(localUserId) andReturn:greeUser.userId];
    
    GreeNetworkReachability* networkReachability = [[GreeNetworkReachability alloc] init];
    [networkReachability stub:@selector(isConnectedToInternet) andReturn:theValue(YES)];
    [[GreePlatform sharedInstance] stub:@selector(reachability) andReturn:networkReachability];
    
    walletBalance = [[GreeWalletBalance alloc] init];
    
    __block NSNumber* numberObject = nil;
    __block NSError* errorObject = nil;
    MockedURLResponse* mock = [[MockedURLResponse new] autorelease];
    NSString* responseString = @"{\"entry\":{\"user_id\":\"319\",\"balance\":\"9001\",\"platform\":\"ios\"}}";
    mock.data = [responseString  dataUsingEncoding:NSUTF8StringEncoding];
    [GreeURLMockingProtocol addMock:mock];
    
    [walletBalance queryWalletBalance:^(unsigned long long balance, NSError* error){
      sleep(0);
    }];
    [walletBalance queryWalletBalance:^(unsigned long long balance, NSError* error){
      numberObject = [[NSNumber numberWithLongLong:balance] retain];
      errorObject = [error retain];
    }];
    
    [[expectFutureValue(numberObject) shouldEventually] beNonNil];
    [[expectFutureValue(errorObject) shouldEventually] beNonNil];
    [[theValue(errorObject.code) should] equal:theValue(GreeWalletBalanceErrorCodeTransactionAlreadyInProgress)];
    [[numberObject should] equal:theValue(0)];

    [numberObject release];
    [errorObject release];
    [walletBalance release];
    [greeUser release];
    greeUser = nil;
  });
});
SPEC_END
