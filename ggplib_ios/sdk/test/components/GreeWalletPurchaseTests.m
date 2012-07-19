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

#import <StoreKit/StoreKit.h>

#import "GreePlatform.h"
#import "GreeURLMockingProtocol.h"
#import "GreeWallet+Internal.h"
#import "GreeTestHelpers.h"
#import "GreeUser.h"
#import "GreeError.h"
#import "GreeWalletPurchase.h"
#import "GreeWalletDeposit.h"
#import "GreeWalletDepositPrefetchManager.h"
#import "GreeWalletDepositProduct.h"
#import "GreeWalletDepositProductsList.h"
#import "GreeWalletProduct+Internal.h"

NSString* const kGreeWalletPurchaseTestsValidUserStatusResponse = @"{\"entry\":{\"user_id\":\"1000015\",\"user_status\":\"1\",\"title\":\"\",\"message\":\"success to validate user status. but user age is under limit.\",\"cause\":\"success to validate user status. but user age is under limit. native session:1000015\"}}";
NSString* const kGreeWalletPurchaseTestsInvalidUserStatusResponse = @"{\"status\":\"-1\",\"message\":\"error\"}";
NSString* const kGreeWalletPurchaseTestsValidTransactionResponse = @"{\"status\":\"0\",\"message\":\"successful\"}";
NSString* const kGreeWalletPurchaseTestsInvalidTransactionResponse = @"{\"status\":\"-1\",\"message\":\"error\"}";

NSString* const kGreeWalletPurchaseTestsValidProductId = @"valid.product.id";
NSString* const kGreeWalletPurchaseTestsInvalidProductId = @"invalid.product.id";
NSString* const kGreeWalletPurchaseTestsPrice = @"99.99";

#pragma mark - GreeWalletPurchaseTests

SPEC_BEGIN(GreeWalletPurchaseTests)
describe(@"Gree WalletPurchase", ^{
  __block SKPaymentQueue* skPaymentQueue = nil;
  __block GreeWalletDeposit* walletDeposit = nil;
  __block GreeWalletDepositPrefetchManager *prefetchManager = nil;
  __block GreeWalletDepositProductsList *productsList = nil;
  
  beforeAll(^{
  });
  
  afterAll(^{
  });
  
  beforeEach(^{
    skPaymentQueue = [[SKPaymentQueue nullMock] retain];
    [SKPaymentQueue stub:@selector(defaultQueue) andReturn:skPaymentQueue];
    [GreeHTTPClient stub:@selector(userAgentString) andReturn:@"TestMockUserAgent"];
    [GreeURLMockingProtocol register];
    [GreeNetworkReachability stub:@selector(alloc) andReturn:[GreeNetworkReachability nullMockWithStatus:GreeNetworkReachabilityConnectedViaWiFi]];
    [GreePlatform initializeWithApplicationId:@"123" consumerKey:@"123" consumerSecret:@"123" settings:nil delegate:nil];
    [[GreePlatform sharedInstance] stub:@selector(httpsClient) andReturn:[GreeHTTPClient nullMock]];
    walletDeposit = [[GreeWalletDeposit nullMock] retain];
    prefetchManager = [[GreeWalletDepositPrefetchManager nullMock] retain];
    productsList = [[GreeWalletDepositProductsList nullMock] retain];
    [GreeWallet stub:@selector(walletDeposit) andReturn:walletDeposit];
    [walletDeposit stub:@selector(prefetchManager) andReturn:prefetchManager];
    [prefetchManager stub:@selector(productsList) andReturn:productsList];
  });
  
  afterEach(^{
    [SKPaymentQueue clearStubs];
    [GreeWallet clearStubs];
    [skPaymentQueue release];
    [[[GreePlatform sharedInstance] shouldEventuallyBeforeTimingOutAfter(10.f)] receive:@selector(dealloc)];
    [GreePlatform shutdown];
    [GreeURLMockingProtocol unregister];
    [walletDeposit release];
    [prefetchManager release];
    [productsList release];
  });
  
  it(@"should complete a transaction and return a GreeWalletProduct", ^{
    GreeUser* greeUser = [[GreeUser alloc] init];
    [greeUser  setValue:@"319" forKey:@"userId"];
    [[GreePlatform sharedInstance] stub:@selector(localUser) andReturn:greeUser];
    [[GreePlatform sharedInstance] stub:@selector(localUserId) andReturn:greeUser.userId];
    
    GreeNetworkReachability* networkReachability = [[GreeNetworkReachability alloc] init];
    [networkReachability stub:@selector(isConnectedToInternet) andReturn:theValue(YES)];
    [[GreePlatform sharedInstance] stub:@selector(reachability) andReturn:networkReachability];
    
    GreeWalletPurchase* walletPurchase = [[GreeWalletPurchase alloc] init];
    [SKPaymentQueue stub:@selector(canMakePayments) andReturn:theValue(YES)];
    
    SKProduct* storeProduct = [SKProduct nullMock];   
    [productsList stub:@selector(skProductFromProductId:) andReturn:storeProduct];
    
    GreeWalletDepositProduct* walletProduct = [GreeWalletDepositProduct nullMock];
    [walletProduct stub:@selector(productId) andReturn:kGreeWalletPurchaseTestsValidProductId];
    [walletProduct stub:@selector(price) andReturn:kGreeWalletPurchaseTestsPrice];
    [productsList stub:@selector(productFromProductId:) andReturn:walletProduct];
    
    
    [[skPaymentQueue should] receive:@selector(addTransactionObserver:)];
    [[skPaymentQueue should] receive:@selector(addPayment:)];

    NSArray* mockedResponses = [NSArray arrayWithObjects:kGreeWalletPurchaseTestsValidUserStatusResponse, kGreeWalletPurchaseTestsValidTransactionResponse, nil];
    for (NSString* responseString in mockedResponses) {
      MockedURLResponse *mock = [[MockedURLResponse new] autorelease];
      mock.data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
      [GreeURLMockingProtocol addMock:mock];
    }
    
    __block NSError* errorObject = nil;
    __block GreeWalletProduct* returnedObject = nil;
    GreeWalletProduct* stubProduct = [GreeWalletProduct nullMock];
    [stubProduct stub:@selector(initWithGreeWalletDepositProduct:) andReturn:stubProduct];
    [walletPurchase purchaseProduct:kGreeWalletPurchaseTestsValidProductId block:^(GreeWalletProduct* product, NSError* error){
      errorObject = [error retain];
      returnedObject = [product retain];
    }];
    
    SKPaymentTransaction *skTransaction = [SKPaymentTransaction nullMock];
    [skTransaction stub:@selector(transactionState) andReturn:theValue(SKPaymentTransactionStatePurchasing)];
    [skTransaction stub:@selector(transactionIdentifier) andReturn:theValue(kGreeWalletPurchaseTestsValidProductId)];
    SKPayment* skPayment = [SKPayment nullMock];
    [skPayment stub:@selector(productIdentifier) andReturn:kGreeWalletPurchaseTestsValidProductId];
    [skTransaction stub:@selector(payment) andReturn:skPayment];

    [walletPurchase paymentQueue:skPaymentQueue updatedTransactions:[NSArray arrayWithObject:skTransaction]];
    
    [skTransaction stub:@selector(transactionState) andReturn:theValue(SKPaymentTransactionStatePurchased)];
    [[skPaymentQueue should] receive:@selector(finishTransaction:)];
    [[walletDeposit should] receive:@selector(recordTransaction:withStatus:)];
    [walletPurchase paymentQueue:skPaymentQueue updatedTransactions:[NSArray arrayWithObject:skTransaction]];
    
    [[expectFutureValue(errorObject) shouldEventually] beNil];
    [[expectFutureValue(returnedObject) shouldEventually] beNonNil];

    [productsList clearStubs];
    [networkReachability clearStubs];
    [networkReachability release];
    [storeProduct clearStubs];
    [walletProduct clearStubs];
    [errorObject release];
    [returnedObject release];
    [walletPurchase release];
    [greeUser release];
  });
  
  it(@"should return GreeError GreeWalletPurchaseErrorCodeUserCancelled", ^{
    GreeUser* greeUser = [[GreeUser alloc] init];
    [greeUser  setValue:@"319" forKey:@"userId"];
    [[GreePlatform sharedInstance] stub:@selector(localUser) andReturn:greeUser];
    [[GreePlatform sharedInstance] stub:@selector(localUserId) andReturn:greeUser.userId];
    
    GreeNetworkReachability* networkReachability = [[GreeNetworkReachability alloc] init];
    [networkReachability stub:@selector(isConnectedToInternet) andReturn:theValue(YES)];
    [[GreePlatform sharedInstance] stub:@selector(reachability) andReturn:networkReachability];
    
    GreeWalletPurchase* walletPurchase = [[GreeWalletPurchase alloc] init];
    [SKPaymentQueue stub:@selector(canMakePayments) andReturn:theValue(YES)];
    
    SKProduct* storeProduct = [SKProduct nullMock];   
    [productsList stub:@selector(skProductFromProductId:) andReturn:storeProduct];
    
    GreeWalletDepositProduct* walletProduct = [GreeWalletDepositProduct nullMock];
    [walletProduct stub:@selector(productId) andReturn:kGreeWalletPurchaseTestsValidProductId];
    [walletProduct stub:@selector(price) andReturn:kGreeWalletPurchaseTestsPrice];
    [productsList stub:@selector(productFromProductId:) andReturn:walletProduct];
    
    
    [[skPaymentQueue should] receive:@selector(addTransactionObserver:)];
    [[skPaymentQueue should] receive:@selector(addPayment:)];
    
    NSArray* mockedResponses = [NSArray arrayWithObjects:kGreeWalletPurchaseTestsValidUserStatusResponse, kGreeWalletPurchaseTestsValidTransactionResponse, nil];
    for (NSString* responseString in mockedResponses) {
      MockedURLResponse *mock = [[MockedURLResponse new] autorelease];
      mock.data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
      [GreeURLMockingProtocol addMock:mock];
    }
    
    __block NSError* errorObject = nil;
    __block GreeWalletProduct* returnedObject = nil;
    GreeWalletProduct* stubProduct = [GreeWalletProduct nullMock];
    [stubProduct stub:@selector(initWithGreeWalletDepositProduct:) andReturn:stubProduct];
    [walletPurchase purchaseProduct:kGreeWalletPurchaseTestsValidProductId block:^(GreeWalletProduct* product, NSError* error){
      errorObject = [error retain];
      returnedObject = [product retain];
    }];
    
    SKPaymentTransaction *skTransaction = [SKPaymentTransaction nullMock];
    [skTransaction stub:@selector(transactionState) andReturn:theValue(SKPaymentTransactionStatePurchasing)];
    [skTransaction stub:@selector(transactionIdentifier) andReturn:theValue(kGreeWalletPurchaseTestsValidProductId)];
    SKPayment* skPayment = [SKPayment nullMock];
    [skPayment stub:@selector(productIdentifier) andReturn:kGreeWalletPurchaseTestsValidProductId];
    [skTransaction stub:@selector(payment) andReturn:skPayment];

    [walletPurchase paymentQueue:skPaymentQueue updatedTransactions:[NSArray arrayWithObject:skTransaction]];
    
    [skTransaction stub:@selector(transactionState) andReturn:theValue(SKPaymentTransactionStateFailed)];
    [[skPaymentQueue should] receive:@selector(finishTransaction:)];
    [[walletDeposit should] receive:@selector(recordTransaction:withStatus:)];
    [walletPurchase paymentQueue:skPaymentQueue updatedTransactions:[NSArray arrayWithObject:skTransaction]];
    
    [[expectFutureValue(errorObject) shouldEventually] beNonNil];
    [[theValue(errorObject.code) should] equal:theValue(GreeWalletPurchaseErrorCodeUserCancelled)];
    [[expectFutureValue(returnedObject) shouldEventually] beNil];
    
    [productsList clearStubs];
    [networkReachability clearStubs];
    [networkReachability release];
    [storeProduct clearStubs];
    [walletProduct clearStubs];
    [errorObject release];
    [returnedObject release];
    [walletPurchase release];
    [greeUser release];
  });
    
  it(@"should return GreeError GreeWalletDepositErrorCodeFailedTransactionCommit", ^{
    GreeUser* greeUser = [[GreeUser alloc] init];
    [greeUser  setValue:@"319" forKey:@"userId"];
    [[GreePlatform sharedInstance] stub:@selector(localUser) andReturn:greeUser];
    [[GreePlatform sharedInstance] stub:@selector(localUserId) andReturn:greeUser.userId];
    
    GreeNetworkReachability* networkReachability = [[GreeNetworkReachability alloc] init];
    [networkReachability stub:@selector(isConnectedToInternet) andReturn:theValue(YES)];
    [[GreePlatform sharedInstance] stub:@selector(reachability) andReturn:networkReachability];
    
    GreeWalletPurchase* walletPurchase = [[GreeWalletPurchase alloc] init];
    [SKPaymentQueue stub:@selector(canMakePayments) andReturn:theValue(YES)];
    
    SKProduct* storeProduct = [SKProduct nullMock];   
    [productsList stub:@selector(skProductFromProductId:) andReturn:storeProduct];
    
    GreeWalletDepositProduct* walletProduct = [GreeWalletDepositProduct nullMock];
    [walletProduct stub:@selector(productId) andReturn:kGreeWalletPurchaseTestsValidProductId];
    [walletProduct stub:@selector(price) andReturn:kGreeWalletPurchaseTestsPrice];
    [productsList stub:@selector(productFromProductId:) andReturn:walletProduct];
    
    
    [[skPaymentQueue should] receive:@selector(addTransactionObserver:)];
    [[skPaymentQueue should] receive:@selector(addPayment:)];
    
    NSArray* mockedResponses = [NSArray arrayWithObjects:kGreeWalletPurchaseTestsValidUserStatusResponse, kGreeWalletPurchaseTestsInvalidTransactionResponse, nil];
    for (NSString* responseString in mockedResponses) {
      MockedURLResponse *mock = [[MockedURLResponse new] autorelease];
      mock.data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
      [GreeURLMockingProtocol addMock:mock];
    }
    
    __block NSError* errorObject = nil;
    __block GreeWalletProduct* returnedObject = nil;
    GreeWalletProduct* stubProduct = [GreeWalletProduct nullMock];
    [stubProduct stub:@selector(initWithGreeWalletDepositProduct:) andReturn:stubProduct];
    [walletPurchase purchaseProduct:kGreeWalletPurchaseTestsValidProductId block:^(GreeWalletProduct* product, NSError* error){
      errorObject = [error retain];
      returnedObject = [product retain];
    }];
    
    SKPaymentTransaction *skTransaction = [SKPaymentTransaction nullMock];
    [skTransaction stub:@selector(transactionState) andReturn:theValue(SKPaymentTransactionStatePurchasing)];
    [skTransaction stub:@selector(transactionIdentifier) andReturn:theValue(kGreeWalletPurchaseTestsValidProductId)];
    SKPayment* skPayment = [SKPayment nullMock];
    [skPayment stub:@selector(productIdentifier) andReturn:kGreeWalletPurchaseTestsValidProductId];
    [skTransaction stub:@selector(payment) andReturn:skPayment];
    [walletPurchase paymentQueue:skPaymentQueue updatedTransactions:[NSArray arrayWithObject:skTransaction]];
    
    [skTransaction stub:@selector(transactionState) andReturn:theValue(SKPaymentTransactionStatePurchased)];
    [[skPaymentQueue should] receive:@selector(finishTransaction:)];
    [[walletDeposit should] receive:@selector(recordTransaction:withStatus:)];
    [walletPurchase paymentQueue:skPaymentQueue updatedTransactions:[NSArray arrayWithObject:skTransaction]];
    
    [[expectFutureValue(errorObject) shouldEventually] beNonNil];
    [[theValue(errorObject.code) should] equal:theValue(GreeWalletDepositErrorCodeFailedTransactionCommit)];
    [[expectFutureValue(returnedObject) shouldEventually] beNil];
    
    [productsList clearStubs];
    [networkReachability clearStubs];
    [networkReachability release];
    [storeProduct clearStubs];
    [walletProduct clearStubs];
    [errorObject release];
    [returnedObject release];
    [walletPurchase release];
    [greeUser release];
  });
  
  it(@"should return GreeError GreeWalletDepositErrorCodeFailedTransactionCommit", ^{
    GreeUser* greeUser = [[GreeUser alloc] init];
    [greeUser  setValue:@"319" forKey:@"userId"];
    [[GreePlatform sharedInstance] stub:@selector(localUser) andReturn:greeUser];
    [[GreePlatform sharedInstance] stub:@selector(localUserId) andReturn:greeUser.userId];
    
    GreeNetworkReachability* networkReachability = [[GreeNetworkReachability alloc] init];
    [networkReachability stub:@selector(isConnectedToInternet) andReturn:theValue(YES)];
    [[GreePlatform sharedInstance] stub:@selector(reachability) andReturn:networkReachability];
    
    GreeWalletPurchase* walletPurchase = [[GreeWalletPurchase alloc] init];
    [SKPaymentQueue stub:@selector(canMakePayments) andReturn:theValue(YES)];
    
    SKProduct* storeProduct = [SKProduct nullMock];   
    [productsList stub:@selector(skProductFromProductId:) andReturn:storeProduct];
    
    GreeWalletDepositProduct* walletProduct = [GreeWalletDepositProduct nullMock];
    [walletProduct stub:@selector(productId) andReturn:kGreeWalletPurchaseTestsValidProductId];
    [walletProduct stub:@selector(price) andReturn:kGreeWalletPurchaseTestsPrice];
    [productsList stub:@selector(productFromProductId:) andReturn:walletProduct];
    
    
    [[skPaymentQueue should] receive:@selector(addTransactionObserver:)];
    [[skPaymentQueue should] receive:@selector(addPayment:)];
    
    NSArray* mockedResponses = [NSArray arrayWithObjects:kGreeWalletPurchaseTestsValidUserStatusResponse, kGreeWalletPurchaseTestsInvalidTransactionResponse, nil];
    for (NSString* responseString in mockedResponses) {
      MockedURLResponse *mock = [[MockedURLResponse new] autorelease];
      mock.data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
      [GreeURLMockingProtocol addMock:mock];
    }
    
    __block NSError* errorObject = nil;
    __block GreeWalletProduct* returnedObject = nil;
    GreeWalletProduct* stubProduct = [GreeWalletProduct nullMock];
    [stubProduct stub:@selector(initWithGreeWalletDepositProduct:) andReturn:stubProduct];
    [walletPurchase purchaseProduct:kGreeWalletPurchaseTestsValidProductId block:^(GreeWalletProduct* product, NSError* error){
      errorObject = [error retain];
      returnedObject = [product retain];
    }];
    
    SKPaymentTransaction *skTransaction = [SKPaymentTransaction nullMock];
    [skTransaction stub:@selector(transactionState) andReturn:theValue(SKPaymentTransactionStatePurchasing)];
    [skTransaction stub:@selector(transactionIdentifier) andReturn:theValue(kGreeWalletPurchaseTestsValidProductId)];
    SKPayment* skPayment = [SKPayment nullMock];
    [skPayment stub:@selector(productIdentifier) andReturn:kGreeWalletPurchaseTestsValidProductId];
    [skTransaction stub:@selector(payment) andReturn:skPayment];
    [walletPurchase paymentQueue:skPaymentQueue updatedTransactions:[NSArray arrayWithObject:skTransaction]];
    
    [skTransaction stub:@selector(transactionState) andReturn:theValue(SKPaymentTransactionStatePurchased)];
    [[skPaymentQueue should] receive:@selector(finishTransaction:)];
    [[walletDeposit should] receive:@selector(recordTransaction:withStatus:)];
    [walletPurchase paymentQueue:skPaymentQueue updatedTransactions:[NSArray arrayWithObject:skTransaction]];
    
    [[expectFutureValue(errorObject) shouldEventually] beNonNil];
    [[theValue(errorObject.code) should] equal:theValue(GreeWalletDepositErrorCodeFailedTransactionCommit)];
    [[expectFutureValue(returnedObject) shouldEventually] beNil];
    
    [productsList clearStubs];
    [networkReachability clearStubs];
    [networkReachability release];
    [storeProduct clearStubs];
    [walletProduct clearStubs];
    [errorObject release];
    [returnedObject release];
    [walletPurchase release];
    [greeUser release];
  });
  
  it(@"should return GreeError Zero due to nil commit response", ^{
    GreeUser* greeUser = [[GreeUser alloc] init];
    [greeUser  setValue:@"319" forKey:@"userId"];
    [[GreePlatform sharedInstance] stub:@selector(localUser) andReturn:greeUser];
    [[GreePlatform sharedInstance] stub:@selector(localUserId) andReturn:greeUser.userId];
    
    GreeNetworkReachability* networkReachability = [[GreeNetworkReachability alloc] init];
    [networkReachability stub:@selector(isConnectedToInternet) andReturn:theValue(YES)];
    [[GreePlatform sharedInstance] stub:@selector(reachability) andReturn:networkReachability];
    
    GreeWalletPurchase* walletPurchase = [[GreeWalletPurchase alloc] init];
    [SKPaymentQueue stub:@selector(canMakePayments) andReturn:theValue(YES)];
    
    SKProduct* storeProduct = [SKProduct nullMock];   
    [productsList stub:@selector(skProductFromProductId:) andReturn:storeProduct];
    
    GreeWalletDepositProduct* walletProduct = [GreeWalletDepositProduct nullMock];
    [walletProduct stub:@selector(productId) andReturn:kGreeWalletPurchaseTestsValidProductId];
    [walletProduct stub:@selector(price) andReturn:kGreeWalletPurchaseTestsPrice];
    [productsList stub:@selector(productFromProductId:) andReturn:walletProduct];
    
    
    [[skPaymentQueue should] receive:@selector(addTransactionObserver:)];
    [[skPaymentQueue should] receive:@selector(addPayment:)];
    
    NSArray* mockedResponses = [NSArray arrayWithObjects:kGreeWalletPurchaseTestsValidUserStatusResponse, nil];
    for (NSString* responseString in mockedResponses) {
      MockedURLResponse *mock = [[MockedURLResponse new] autorelease];
      mock.data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
      [GreeURLMockingProtocol addMock:mock];
    }
    
    __block NSError* errorObject = nil;
    __block GreeWalletProduct* returnedObject = nil;
    GreeWalletProduct* stubProduct = [GreeWalletProduct nullMock];
    [stubProduct stub:@selector(initWithGreeWalletDepositProduct:) andReturn:stubProduct];
    [walletPurchase purchaseProduct:kGreeWalletPurchaseTestsValidProductId block:^(GreeWalletProduct* product, NSError* error){
      errorObject = [error retain];
      returnedObject = [product retain];
    }];
    
    SKPaymentTransaction *skTransaction = [SKPaymentTransaction nullMock];
    [skTransaction stub:@selector(transactionState) andReturn:theValue(SKPaymentTransactionStatePurchasing)];
    [skTransaction stub:@selector(transactionIdentifier) andReturn:theValue(kGreeWalletPurchaseTestsValidProductId)];
    SKPayment* skPayment = [SKPayment nullMock];
    [skPayment stub:@selector(productIdentifier) andReturn:kGreeWalletPurchaseTestsValidProductId];
    [skTransaction stub:@selector(payment) andReturn:skPayment];
    [walletPurchase paymentQueue:skPaymentQueue updatedTransactions:[NSArray arrayWithObject:skTransaction]];
    
    [skTransaction stub:@selector(transactionState) andReturn:theValue(SKPaymentTransactionStatePurchased)];
    [[skPaymentQueue should] receive:@selector(finishTransaction:)];
    [[walletDeposit should] receive:@selector(recordTransaction:withStatus:)];
    [walletPurchase paymentQueue:skPaymentQueue updatedTransactions:[NSArray arrayWithObject:skTransaction]];
    
    [[expectFutureValue(errorObject) shouldEventually] beNonNil];
    [[theValue(errorObject.code) should] equal:theValue(0)];
    [[expectFutureValue(returnedObject) shouldEventually] beNil];
    
    [productsList clearStubs];
    [networkReachability clearStubs];
    [networkReachability release];
    [storeProduct clearStubs];
    [walletProduct clearStubs];
    [errorObject release];
    [returnedObject release];
    [walletPurchase release];
    [greeUser release];
  });
  
  it(@"should return GreeError zero due nil user status response", ^{
    GreeUser* greeUser = [[GreeUser alloc] init];
    [greeUser  setValue:@"319" forKey:@"userId"];
    [[GreePlatform sharedInstance] stub:@selector(localUser) andReturn:greeUser];
    [[GreePlatform sharedInstance] stub:@selector(localUserId) andReturn:greeUser.userId];
    
    GreeNetworkReachability* networkReachability = [[GreeNetworkReachability alloc] init];
    [networkReachability stub:@selector(isConnectedToInternet) andReturn:theValue(YES)];
    [[GreePlatform sharedInstance] stub:@selector(reachability) andReturn:networkReachability];
    
    GreeWalletPurchase* walletPurchase = [[GreeWalletPurchase alloc] init];
    [SKPaymentQueue stub:@selector(canMakePayments) andReturn:theValue(YES)];
    
    SKProduct* storeProduct = [SKProduct nullMock];   
    [productsList stub:@selector(skProductFromProductId:) andReturn:storeProduct];
    
    GreeWalletDepositProduct* walletProduct = [GreeWalletDepositProduct nullMock];
    [walletProduct stub:@selector(productId) andReturn:kGreeWalletPurchaseTestsValidProductId];
    [walletProduct stub:@selector(price) andReturn:kGreeWalletPurchaseTestsPrice];
    [productsList stub:@selector(productFromProductId:) andReturn:walletProduct];
    
    
    [[skPaymentQueue shouldNot] receive:@selector(addTransactionObserver:)];
    [[skPaymentQueue shouldNot] receive:@selector(addPayment:)];
    
    NSArray* mockedResponses = [NSArray arrayWithObjects:nil, nil];
    for (NSString* responseString in mockedResponses) {
      MockedURLResponse *mock = [[MockedURLResponse new] autorelease];
      mock.data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
      [GreeURLMockingProtocol addMock:mock];
    }
    
    __block NSError* errorObject = nil;
    __block GreeWalletProduct* returnedObject = nil;
    GreeWalletProduct* stubProduct = [GreeWalletProduct nullMock];
    [stubProduct stub:@selector(initWithGreeWalletDepositProduct:) andReturn:stubProduct];
    [walletPurchase purchaseProduct:kGreeWalletPurchaseTestsValidProductId block:^(GreeWalletProduct* product, NSError* error){
      errorObject = [error retain];
      returnedObject = [product retain];
    }];
    
    [[expectFutureValue(errorObject) shouldEventually] beNonNil];
    [[theValue(errorObject.code) should] equal:theValue(0)];
    [[expectFutureValue(returnedObject) shouldEventually] beNil];
    
    [productsList clearStubs];
    [networkReachability clearStubs];
    [networkReachability release];
    [storeProduct clearStubs];
    [walletProduct clearStubs];
    [errorObject release];
    [returnedObject release];
    [walletPurchase release];
    [greeUser release];
  });
  
  it(@"should return GreeError GreeWalletPurchaseErrorCodeInvalidProductId due to missing GreeWalletDepositProduct", ^{
    GreeUser* greeUser = [[GreeUser alloc] init];
    [greeUser  setValue:@"319" forKey:@"userId"];
    [[GreePlatform sharedInstance] stub:@selector(localUser) andReturn:greeUser];
    [[GreePlatform sharedInstance] stub:@selector(localUserId) andReturn:greeUser.userId];
    
    GreeNetworkReachability* networkReachability = [[GreeNetworkReachability alloc] init];
    [networkReachability stub:@selector(isConnectedToInternet) andReturn:theValue(YES)];
    [[GreePlatform sharedInstance] stub:@selector(reachability) andReturn:networkReachability];
    
    GreeWalletPurchase* walletPurchase = [[GreeWalletPurchase alloc] init];
    [SKPaymentQueue stub:@selector(canMakePayments) andReturn:theValue(YES)];
    
    SKProduct* storeProduct = [SKProduct nullMock];   
    [productsList stub:@selector(skProductFromProductId:) andReturn:storeProduct];
    
    [productsList stub:@selector(productFromProductId:) andReturn:nil];
    
    [[skPaymentQueue shouldNot] receive:@selector(addTransactionObserver:)];
    [[skPaymentQueue shouldNot] receive:@selector(addPayment:)];
    
    NSArray* mockedResponses = [NSArray arrayWithObjects:nil, nil];
    for (NSString* responseString in mockedResponses) {
      MockedURLResponse *mock = [[MockedURLResponse new] autorelease];
      mock.data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
      [GreeURLMockingProtocol addMock:mock];
    }
    
    __block NSError* errorObject = nil;
    __block GreeWalletProduct* returnedObject = nil;
    GreeWalletProduct* stubProduct = [GreeWalletProduct nullMock];
    [stubProduct stub:@selector(initWithGreeWalletDepositProduct:) andReturn:stubProduct];
    [walletPurchase purchaseProduct:kGreeWalletPurchaseTestsValidProductId block:^(GreeWalletProduct* product, NSError* error){
      errorObject = [error retain];
      returnedObject = [product retain];
    }];
    
    [[expectFutureValue(errorObject) shouldEventually] beNonNil];
    [[theValue(errorObject.code) should] equal:theValue(GreeWalletPurchaseErrorCodeInvalidProductId)];
    [[expectFutureValue(returnedObject) shouldEventually] beNil];
    
    [productsList clearStubs];
    [networkReachability clearStubs];
    [networkReachability release];
    [storeProduct clearStubs];
    [errorObject release];
    [returnedObject release];
    [walletPurchase release];
    [greeUser release];
  });

  it(@"should return GreeError GreeWalletPurchaseErrorCodeInvalidProductId due to missing SKProduct", ^{
    GreeUser* greeUser = [[GreeUser alloc] init];
    [greeUser  setValue:@"319" forKey:@"userId"];
    [[GreePlatform sharedInstance] stub:@selector(localUser) andReturn:greeUser];
    [[GreePlatform sharedInstance] stub:@selector(localUserId) andReturn:greeUser.userId];
    
    GreeNetworkReachability* networkReachability = [[GreeNetworkReachability alloc] init];
    [networkReachability stub:@selector(isConnectedToInternet) andReturn:theValue(YES)];
    [[GreePlatform sharedInstance] stub:@selector(reachability) andReturn:networkReachability];
    
    GreeWalletPurchase* walletPurchase = [[GreeWalletPurchase alloc] init];
    [SKPaymentQueue stub:@selector(canMakePayments) andReturn:theValue(YES)];
    
    [productsList stub:@selector(skProductFromProductId:) andReturn:nil];
    
    GreeWalletDepositProduct* walletProduct = [GreeWalletDepositProduct nullMock];
    [walletProduct stub:@selector(productId) andReturn:kGreeWalletPurchaseTestsValidProductId];
    [walletProduct stub:@selector(price) andReturn:kGreeWalletPurchaseTestsPrice];
    [productsList stub:@selector(productFromProductId:) andReturn:walletProduct];
    
    
    [[skPaymentQueue shouldNot] receive:@selector(addTransactionObserver:)];
    [[skPaymentQueue shouldNot] receive:@selector(addPayment:)];
    
    NSArray* mockedResponses = [NSArray arrayWithObjects:nil, nil];
    for (NSString* responseString in mockedResponses) {
      MockedURLResponse *mock = [[MockedURLResponse new] autorelease];
      mock.data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
      [GreeURLMockingProtocol addMock:mock];
    }
    
    __block NSError* errorObject = nil;
    __block GreeWalletProduct* returnedObject = nil;
    GreeWalletProduct* stubProduct = [GreeWalletProduct nullMock];
    [stubProduct stub:@selector(initWithGreeWalletDepositProduct:) andReturn:stubProduct];
    [walletPurchase purchaseProduct:kGreeWalletPurchaseTestsValidProductId block:^(GreeWalletProduct* product, NSError* error){
      errorObject = [error retain];
      returnedObject = [product retain];
    }];
    
    [[expectFutureValue(errorObject) shouldEventually] beNonNil];
    [[theValue(errorObject.code) should] equal:theValue(GreeWalletPurchaseErrorCodeInvalidProductId)];
    [[expectFutureValue(returnedObject) shouldEventually] beNil];
    
    [productsList clearStubs];
    [networkReachability clearStubs];
    [networkReachability release];
    [walletProduct clearStubs];
    [errorObject release];
    [returnedObject release];
    [walletPurchase release];
    [greeUser release];
  });

  it(@"should return GreeError GreeWalletPurchaseErrorCodeInvalidProductId due to both products missing", ^{
    GreeUser* greeUser = [[GreeUser alloc] init];
    [greeUser  setValue:@"319" forKey:@"userId"];
    [[GreePlatform sharedInstance] stub:@selector(localUser) andReturn:greeUser];
    [[GreePlatform sharedInstance] stub:@selector(localUserId) andReturn:greeUser.userId];
    
    GreeNetworkReachability* networkReachability = [[GreeNetworkReachability alloc] init];
    [networkReachability stub:@selector(isConnectedToInternet) andReturn:theValue(YES)];
    [[GreePlatform sharedInstance] stub:@selector(reachability) andReturn:networkReachability];
    
    GreeWalletPurchase* walletPurchase = [[GreeWalletPurchase alloc] init];
    [SKPaymentQueue stub:@selector(canMakePayments) andReturn:theValue(YES)];
    
    [productsList stub:@selector(skProductFromProductId:) andReturn:nil];
    
    [productsList stub:@selector(productFromProductId:) andReturn:nil];
    
    
    [[skPaymentQueue shouldNot] receive:@selector(addTransactionObserver:)];
    [[skPaymentQueue shouldNot] receive:@selector(addPayment:)];
    
    NSArray* mockedResponses = [NSArray arrayWithObjects:nil, nil];
    for (NSString* responseString in mockedResponses) {
      MockedURLResponse *mock = [[MockedURLResponse new] autorelease];
      mock.data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
      [GreeURLMockingProtocol addMock:mock];
    }
    
    __block NSError* errorObject = nil;
    __block GreeWalletProduct* returnedObject = nil;
    GreeWalletProduct* stubProduct = [GreeWalletProduct nullMock];
    [stubProduct stub:@selector(initWithGreeWalletDepositProduct:) andReturn:stubProduct];
    [walletPurchase purchaseProduct:kGreeWalletPurchaseTestsValidProductId block:^(GreeWalletProduct* product, NSError* error){
      errorObject = [error retain];
      returnedObject = [product retain];
    }];
    
    [[expectFutureValue(errorObject) shouldEventually] beNonNil];
    [[theValue(errorObject.code) should] equal:theValue(GreeWalletPurchaseErrorCodeInvalidProductId)];
    [[expectFutureValue(returnedObject) shouldEventually] beNil];
    
    [productsList clearStubs];
    [networkReachability clearStubs];
    [networkReachability release];
    [errorObject release];
    [returnedObject release];
    [walletPurchase release];
    [greeUser release];
  });

  it(@"should return GreeError GreeErrorCodeNetworkError due to no connectivity", ^{
    GreeUser* greeUser = [[GreeUser alloc] init];
    [greeUser  setValue:@"319" forKey:@"userId"];
    [[GreePlatform sharedInstance] stub:@selector(localUser) andReturn:greeUser];
    [[GreePlatform sharedInstance] stub:@selector(localUserId) andReturn:greeUser.userId];
    
    GreeNetworkReachability* networkReachability = [[GreeNetworkReachability alloc] init];
    [networkReachability stub:@selector(isConnectedToInternet) andReturn:theValue(NO)];
    [[GreePlatform sharedInstance] stub:@selector(reachability) andReturn:networkReachability];
    
    GreeWalletPurchase* walletPurchase = [[GreeWalletPurchase alloc] init];
    [SKPaymentQueue stub:@selector(canMakePayments) andReturn:theValue(YES)];
    
    [productsList stub:@selector(skProductFromProductId:) andReturn:nil];
    
    [productsList stub:@selector(productFromProductId:) andReturn:nil];
    
    [[skPaymentQueue shouldNot] receive:@selector(addTransactionObserver:)];
    [[skPaymentQueue shouldNot] receive:@selector(addPayment:)];
    
    NSArray* mockedResponses = [NSArray arrayWithObjects:nil, nil];
    for (NSString* responseString in mockedResponses) {
      MockedURLResponse *mock = [[MockedURLResponse new] autorelease];
      mock.data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
      [GreeURLMockingProtocol addMock:mock];
    }
    
    __block NSError* errorObject = nil;
    __block GreeWalletProduct* returnedObject = nil;
    GreeWalletProduct* stubProduct = [GreeWalletProduct nullMock];
    [stubProduct stub:@selector(initWithGreeWalletDepositProduct:) andReturn:stubProduct];
    [walletPurchase purchaseProduct:kGreeWalletPurchaseTestsValidProductId block:^(GreeWalletProduct* product, NSError* error){
      errorObject = [error retain];
      returnedObject = [product retain];
    }];
    
    [[expectFutureValue(errorObject) shouldEventually] beNonNil];
    [[theValue(errorObject.code) should] equal:theValue(GreeErrorCodeNetworkError)];
    [[expectFutureValue(returnedObject) shouldEventually] beNil];
    
    [productsList clearStubs];
    [networkReachability clearStubs];
    [networkReachability release];
    [errorObject release];
    [returnedObject release];
    [walletPurchase release];
    [greeUser release];
  });

  it(@"should return GreeError GreeErrorCodeUserRequired due to nil user", ^{
    [[GreePlatform sharedInstance] stub:@selector(localUser) andReturn:nil];
    [[GreePlatform sharedInstance] stub:@selector(localUserId) andReturn:nil];
    
    GreeNetworkReachability* networkReachability = [[GreeNetworkReachability alloc] init];
    [networkReachability stub:@selector(isConnectedToInternet) andReturn:theValue(NO)];
    [[GreePlatform sharedInstance] stub:@selector(reachability) andReturn:networkReachability];
    
    GreeWalletPurchase* walletPurchase = [[GreeWalletPurchase alloc] init];
    [SKPaymentQueue stub:@selector(canMakePayments) andReturn:theValue(YES)];
    
    [productsList stub:@selector(skProductFromProductId:) andReturn:nil];
    
    [productsList stub:@selector(productFromProductId:) andReturn:nil];
    
    [[skPaymentQueue shouldNot] receive:@selector(addTransactionObserver:)];
    [[skPaymentQueue shouldNot] receive:@selector(addPayment:)];
    
    NSArray* mockedResponses = [NSArray arrayWithObjects:nil, nil];
    for (NSString* responseString in mockedResponses) {
      MockedURLResponse *mock = [[MockedURLResponse new] autorelease];
      mock.data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
      [GreeURLMockingProtocol addMock:mock];
    }
    
    __block NSError* errorObject = nil;
    __block GreeWalletProduct* returnedObject = nil;
    GreeWalletProduct* stubProduct = [GreeWalletProduct nullMock];
    [stubProduct stub:@selector(initWithGreeWalletDepositProduct:) andReturn:stubProduct];
    [walletPurchase purchaseProduct:kGreeWalletPurchaseTestsValidProductId block:^(GreeWalletProduct* product, NSError* error){
      errorObject = [error retain];
      returnedObject = [product retain];
    }];
    
    [[expectFutureValue(errorObject) shouldEventually] beNonNil];
    [[theValue(errorObject.code) should] equal:theValue(GreeErrorCodeUserRequired)];
    [[expectFutureValue(returnedObject) shouldEventually] beNil];
    
    [productsList clearStubs];
    [networkReachability clearStubs];
    [networkReachability release];
    [errorObject release];
    [returnedObject release];
    [walletPurchase release];
  });

  it(@"should return GreeError GreeErrorCodeNotAuthorized due to disabled payments", ^{
    [[GreePlatform sharedInstance] stub:@selector(localUser) andReturn:nil];
    [[GreePlatform sharedInstance] stub:@selector(localUserId) andReturn:nil];
    
    GreeNetworkReachability* networkReachability = [[GreeNetworkReachability alloc] init];
    [networkReachability stub:@selector(isConnectedToInternet) andReturn:theValue(NO)];
    [[GreePlatform sharedInstance] stub:@selector(reachability) andReturn:networkReachability];
    
    GreeWalletPurchase* walletPurchase = [[GreeWalletPurchase alloc] init];
    [SKPaymentQueue stub:@selector(canMakePayments) andReturn:theValue(NO)];
    
    [productsList stub:@selector(skProductFromProductId:) andReturn:nil];
    
    [productsList stub:@selector(productFromProductId:) andReturn:nil];
    
    [[skPaymentQueue shouldNot] receive:@selector(addTransactionObserver:)];
    [[skPaymentQueue shouldNot] receive:@selector(addPayment:)];
    
    __block NSError* errorObject = nil;
    __block GreeWalletProduct* returnedObject = nil;
    
    [walletPurchase purchaseProduct:kGreeWalletPurchaseTestsValidProductId block:^(GreeWalletProduct* product, NSError* error){
      errorObject = [error retain];
      returnedObject = [product retain];
    }];
    
    [[expectFutureValue(errorObject) shouldEventually] beNonNil];
    [[theValue(errorObject.code) should] equal:theValue(GreeErrorCodeNotAuthorized)];
    [[expectFutureValue(returnedObject) shouldEventually] beNil];
    
    [productsList clearStubs];
    [networkReachability clearStubs];
    [networkReachability release];
    [errorObject release];
    [returnedObject release];
    [walletPurchase release];
  });

});
SPEC_END
