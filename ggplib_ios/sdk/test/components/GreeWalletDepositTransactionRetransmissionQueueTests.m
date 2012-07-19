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
#import "GreeWalletDepositTransactionRetransmissionQueue.h"
#import "GreeWalletDepositIAPHistoryGateway.h"
#import "GreeWalletDepositIAPHistoryRecord.h"
#import "GreeWallet.h"

@interface GreeWalletDepositTransactionRetransmissionQueue ()
@property (retain) NSMutableArray* queue;
@property (retain) GreeWalletDepositIAPHistoryGateway* historyGateway;
- (id)initWithHistoryGateway:(GreeWalletDepositIAPHistoryGateway*)aHistoryGateway;
- (void)retransmission;
- (void)lostTransaction:(GreeWalletDepositIAPHistoryRecord*)aRecord;
- (void)commitTransaction:(GreeWalletDepositIAPHistoryRecord*)aRecord;
- (int64_t)retryInterval;
- (void)asyncWaitForExpire:(dispatch_time_t)expireTime;
@end


SPEC_BEGIN(GreeWalletDepositTransactionRetransmissionQueueSpec)

describe(@"GreeWallet Deposit Transaction Retransmission Queue", ^{
  __block GreeWalletDepositTransactionRetransmissionQueue *queue = nil;

  beforeEach(^{
    GreeWalletDepositIAPHistoryGateway *gateway = [GreeWalletDepositIAPHistoryGateway nullMock];
    queue = [GreeWalletDepositTransactionRetransmissionQueue queueWithHistoryGateway:gateway];
  });

  afterEach(^{
    queue = nil;
  });

  it(@"should initialize normally", ^{
    [[queue should] beKindOfClass:[GreeWalletDepositTransactionRetransmissionQueue class]];
  });

  it(@"should add Object normally", ^{
    [queue addObject:@"addTest"];
    [[queue.queue should] equal:[NSMutableArray arrayWithObject:@"addTest"]];
  });

  it(@"should async WaitForExpire normally", ^{
    [queue asyncWaitForExpire:0];
    [[queue shouldEventually] receive:@selector(retransmission)];
  });

  it(@"should storeTransaction and redo normally", ^{
    [[queue should] receive:@selector(asyncWaitForExpire:)];
    [queue retransmission];
  });

  it(@"should storeTransaction and lost Transaction normally", ^{
    GreeWalletDepositIAPHistoryRecord *aRecord = [GreeWalletDepositIAPHistoryRecord nullMock];
    [queue addObject:aRecord];
    [queue stub:@selector(lostTransaction:)];

    [[[queue should] receive] lostTransaction:aRecord];
    [queue retransmission];
  });

  it(@"should storeTransaction and commit Transaction normally", ^{
    GreeWalletDepositIAPHistoryRecord *aRecord = [GreeWalletDepositIAPHistoryRecord nullMock];
    [aRecord stub:@selector(receiptBinaryData) andReturn:[@"test" dataUsingEncoding:NSUTF8StringEncoding]];
    [queue addObject:aRecord];
    [queue stub:@selector(commitTransaction:)];

    [[[queue should] receive] commitTransaction:aRecord];
    [queue retransmission];
  });

  it(@"should lost Transaction normally", ^{
    GreeWalletDepositIAPHistoryRecord *aRecord = [GreeWalletDepositIAPHistoryRecord nullMock];
    [queue addObject:aRecord];
    [[[queue.historyGateway should] receive] updateWithRecord:aRecord];
    [[theValue([queue.queue count]) should] equal:theValue(1)];
    [queue lostTransaction:aRecord];
    [[theValue([queue.queue count]) should] equal:theValue(0)];
  });

  it(@"should commit Transaction normally", ^{
    GreeWalletDepositIAPHistoryRecord *aRecord = [GreeWalletDepositIAPHistoryRecord nullMock];
    [aRecord stub:@selector(receiptBinaryData) andReturn:[@"test" dataUsingEncoding:NSUTF8StringEncoding]];
    [GreeWallet stub:@selector(commitTransactionWithProductId:parameters:block:)];
    [[GreeWallet should] receive:@selector(commitTransactionWithProductId:parameters:block:)];
    [queue commitTransaction:aRecord];
  });
});


SPEC_END
