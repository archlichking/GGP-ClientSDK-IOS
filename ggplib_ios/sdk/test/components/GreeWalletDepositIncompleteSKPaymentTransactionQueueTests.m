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

#import <StoreKit/StoreKit.h>
#import "Kiwi.h"
#import "GreeWalletDepositIncompleteSKPaymentTransactionQueue.h"
#import "GreeWalletDepositIAPHistoryGateway.h"
#import "GreeWalletDepositProductsList.h"
#import "GreeWalletDepositProduct.h"

@interface GreeWalletDepositIncompleteSKPaymentTransactionQueue ()
@property (retain) NSMutableArray* transactions;
- (void)storeTransaction;
- (void)recordTransaction:(SKPaymentTransaction*)aTransaction;
- (int64_t)retryInterval;
- (void)asyncWaitForExpire:(dispatch_time_t)expireTime;
@end

SPEC_BEGIN(GreeWalletDepositIncompleteSKPaymentTransactionQueueSpec)

describe(@"GreeWallet Deposit IncompleteSKPayment Transaction Queue", ^{
  __block GreeWalletDepositIncompleteSKPaymentTransactionQueue *queue = nil;

  beforeEach(^{
    queue = [GreeWalletDepositIncompleteSKPaymentTransactionQueue queue];
  });

  afterEach(^{
    queue = nil;
  });

  it(@"should initialize normally", ^{
    [[queue should] beKindOfClass:[GreeWalletDepositIncompleteSKPaymentTransactionQueue class]];
  });

  it(@"should add Object normally", ^{
    [queue addObject:@"addTest"];
    [[queue.transactions should] equal:[NSMutableArray arrayWithObject:@"addTest"]];
  });

  it(@"should storeTransaction and redo normally", ^{
    [[queue should] receive:@selector(asyncWaitForExpire:)];
    [queue storeTransaction];
  });

  it(@"should storeTransaction normally", ^{
    SKPaymentTransaction *testTransaction = [SKPaymentTransaction nullMock];
    [queue addObject:testTransaction];
    queue.historyGateway = [GreeWalletDepositIAPHistoryGateway nullMock];
    queue.productsList = [GreeWalletDepositProductsList nullMock];
    [SKPaymentQueue stub:@selector(defaultQueue)];

    [[theValue([queue.transactions count]) should] equal:theValue(1)];
    [queue storeTransaction];
    [[theValue([queue.transactions count]) should] equal:theValue(0)];

  });

  it(@"should record Transaction normally", ^{
    GreeWalletDepositProduct *aProduct = [GreeWalletDepositProduct nullMock];
    [aProduct stub:@selector(tierName) andReturn:@"tier"];
    [aProduct stub:@selector(price) andReturn:@"321"];
    [aProduct stub:@selector(currencyCode) andReturn:@"currencyCode"];

    GreeWalletDepositProductsList *aProductList = [GreeWalletDepositProductsList nullMock];
    [aProductList stub:@selector(productFromProductId:) andReturn:aProduct];
    queue.productsList = aProductList;
    queue.historyGateway = [GreeWalletDepositIAPHistoryGateway nullMock];

    SKPayment *aPayment = [SKPayment nullMock];
    [aPayment stub:@selector(productIdentifier) andReturn:@"12345a"];
    [aPayment stub:@selector(quantity) andReturn:theValue(234)];

    SKPaymentTransaction *aTransaction = [SKPaymentTransaction nullMock];
    [aTransaction stub:@selector(payment) andReturn:aPayment];
    [aTransaction stub:@selector(transactionState) andReturn:theValue(SKPaymentTransactionStatePurchased)];

    [[queue.historyGateway should] receive:@selector(insertWithRecord:withBlock:)];

    [queue recordTransaction:aTransaction];
  });

  it(@"should async WaitForExpire normally", ^{
    [queue asyncWaitForExpire:0];
    [[queue shouldEventually] receive:@selector(storeTransaction)];
  });

});


SPEC_END
