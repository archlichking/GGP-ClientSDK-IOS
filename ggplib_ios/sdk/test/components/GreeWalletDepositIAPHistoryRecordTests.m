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
#import "GreeGlobalization.h"
#import "GreeWallet+Internal.h"
#import "GreeWalletDepositIAPHistoryRecord.h"
#import "NSDateFormatter+GreeAdditions.h"

NSInteger const kGreeWalletDepositIAPHistoryRecordTestsIdentifierValue = 12345;
NSInteger const kGreeWalletDepositIAPHistoryRecordTestsTransactionStatusValue = GreeWalletDepositTransactionStatePurchasing;
NSString* const kGreeWalletDepositIAPHistoryRecordTestsIssueDateValue = @"issue_date";
NSInteger const kGreeWalletDepositIAPHistoryRecordTestsQuantityValue = 5;
NSString* const kGreeWalletDepositIAPHistoryRecordTestsProductIdValue = @"product_id";
NSString* const kGreeWalletDepositIAPHistoryRecordTestsProductNameValue = @"product_name";
NSString* const kGreeWalletDepositIAPHistoryRecordTestsPriceValue = @"price";
NSString* const kGreeWalletDepositIAPHistoryRecordTestsCurrencyCodeValue = @"currency_code";
NSString* const kGreeWalletDepositIAPHistoryRecordTestsReceiptBinaryDataValue = @"receipt_binary_data";

SPEC_BEGIN(GreeWalletDepositIAPHistoryRecordTests)

describe(@"Gree Wallet Deposit IAPHistory Record", ^{
  __block GreeWalletDepositIAPHistoryRecord *record = nil;

  NSString* (^setStateAndGetResultString)(enum GreeWalletDepositTransactionState) = ^(enum GreeWalletDepositTransactionState state){
    record.transactionState = state;
    NSDictionary *resultDictionary = [NSJSONSerialization JSONObjectWithData:
                                      [[record jsonStringForHistoryList] dataUsingEncoding:NSUTF8StringEncoding]
                                      options:0 error:nil];
    return (NSString *)[resultDictionary objectForKey:@"status"];
  };

  NSString* (^setStatusAndGetResultString)(int) = ^(int status){
    [record setStatus:status];
    NSDictionary *resultDictionary = [NSJSONSerialization JSONObjectWithData:
                                      [[record jsonStringForHistoryList] dataUsingEncoding:NSUTF8StringEncoding]
                                      options:0 error:nil];
    return (NSString *)[resultDictionary objectForKey:@"status"];
  };

  beforeEach(^{
    NSDictionary *recordDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithInteger:kGreeWalletDepositIAPHistoryRecordTestsIdentifierValue], @"identifier",
                                      [NSNumber numberWithInteger:kGreeWalletDepositIAPHistoryRecordTestsTransactionStatusValue], @"transaction_status",
                                      [NSNumber numberWithDouble:NSTimeIntervalSince1970], @"issue_date",
                                      [NSNumber numberWithInteger:kGreeWalletDepositIAPHistoryRecordTestsQuantityValue], @"quantity",
                                      kGreeWalletDepositIAPHistoryRecordTestsProductIdValue, @"product_id",
                                      kGreeWalletDepositIAPHistoryRecordTestsProductNameValue, @"product_name",
                                      kGreeWalletDepositIAPHistoryRecordTestsPriceValue, @"price",
                                      kGreeWalletDepositIAPHistoryRecordTestsCurrencyCodeValue, @"currency_code",
                                      [kGreeWalletDepositIAPHistoryRecordTestsReceiptBinaryDataValue dataUsingEncoding:NSUTF8StringEncoding], @"receipt_binary_data",
                                      nil];
    record = [GreeWalletDepositIAPHistoryRecord recordWithDictionary:recordDictionary];
  });

  afterEach(^{
    record = nil;
  });

  it(@"should initialize normally", ^{
    [record shouldNotBeNil];
    [[record should] beKindOfClass:[GreeWalletDepositIAPHistoryRecord class]];
    [[theValue(record.identifier) should] equal:theValue(kGreeWalletDepositIAPHistoryRecordTestsIdentifierValue)];
    [[theValue(record.transactionState) should] equal:theValue(kGreeWalletDepositIAPHistoryRecordTestsTransactionStatusValue)];
    [[record.issueDate should] equal:[NSDate dateWithTimeIntervalSince1970:NSTimeIntervalSince1970]];
    [[theValue(record.quantity) should] equal:theValue(kGreeWalletDepositIAPHistoryRecordTestsQuantityValue)];
    [[record.productId should] equal:kGreeWalletDepositIAPHistoryRecordTestsProductIdValue];
    [[record.productName should] equal:kGreeWalletDepositIAPHistoryRecordTestsProductNameValue];
    [[record.price should] equal:kGreeWalletDepositIAPHistoryRecordTestsPriceValue];
    [[record.currencyCode should] equal:kGreeWalletDepositIAPHistoryRecordTestsCurrencyCodeValue];
    [[record.receiptBinaryData should] equal:[kGreeWalletDepositIAPHistoryRecordTestsReceiptBinaryDataValue dataUsingEncoding:NSUTF8StringEncoding]];
  });

  it(@"should set jsonString for HistoryList normally", ^{
    NSDictionary *resultDictionary = [NSJSONSerialization JSONObjectWithData:
                                      [[record jsonStringForHistoryList] dataUsingEncoding:NSUTF8StringEncoding]
                                      options:0 error:nil];

    [[[resultDictionary objectForKey:@"id"] should] equal:[NSString stringWithFormat:@"%d", kGreeWalletDepositIAPHistoryRecordTestsIdentifierValue]];
    [[[resultDictionary objectForKey:@"title"] should] equal:kGreeWalletDepositIAPHistoryRecordTestsProductNameValue];
    [[[resultDictionary objectForKey:@"date"] should] equal:[[NSDateFormatter greeSystemMediumStyleDateFormatter]
                                                             stringFromDate:[NSDate dateWithTimeIntervalSince1970:NSTimeIntervalSince1970]]];
    [[[resultDictionary objectForKey:@"button-title"] should]
      equal:GreePlatformString(@"wallet.deposit.history.contactbutton.title", @"Contact")];

    [[setStateAndGetResultString(GreeWalletDepositTransactionStateInitialized) should]
     equal:GreePlatformString(@"wallet.deposit.history.status.initialized", @"Preparing")];
    [[setStateAndGetResultString(GreeWalletDepositTransactionStateIAPPurchasing) should]
     equal:GreePlatformString(@"wallet.deposit.history.status.iappurchasing", @"Awaiting IAP purchase request")];
    [[setStateAndGetResultString(GreeWalletDepositTransactionStatePurchasing) should]
     equal:GreePlatformString(@"wallet.deposit.history.status.purchasing", @"Awaiting GREE purchase request")];
    [[setStateAndGetResultString(GreeWalletDepositTransactionStateCommited) should]
     equal:GreePlatformString(@"wallet.deposit.history.status.commited", @"Completed")];
    [[setStateAndGetResultString(GreeWalletDepositTransactionStateNetworkError) should]
     equal:GreePlatformString(@"wallet.deposit.history.status.networkerror", @"Wait for verification")];
    [[setStateAndGetResultString(GreeWalletDepositTransactionStateReceiptError) should]
     equal:GreePlatformString(@"wallet.deposit.history.status.receipterror", @"Failed(receipt error)")];
    [[setStateAndGetResultString(GreeWalletDepositTransactionStateReceiptDuplicatedError) should]
     equal:GreePlatformString(@"wallet.deposit.history.status.duplicatederror", @"Cancelled(duplicated)")];
    [[setStateAndGetResultString(GreeWalletDepositTransactionStateOtherError) should]
     equal:GreePlatformString(@"wallet.deposit.history.status.othererror", @"Failed")];
    [[setStateAndGetResultString(GreeWalletDepositTransactionStateCancelled) should]
     equal:GreePlatformString(@"wallet.deposit.history.status.cancelled", @"Cancelled")];
    [[setStateAndGetResultString(GreeWalletDepositTransactionStateTransmitting) should]
     equal:GreePlatformString(@"wallet.deposit.history.status.transmitting", @"Transmitting")];
    [[setStateAndGetResultString(10) should]
     equal:GreePlatformString(@"wallet.deposit.history.status.unknown", @"Unknown")];
  });

  it(@"should set status normally", ^{
    [[setStatusAndGetResultString(kGreeWalletDeposiTransactionResultOK) should]
     equal:GreePlatformString(@"wallet.deposit.history.status.commited", @"Completed")];
    [[setStatusAndGetResultString(kGreeWalletDeposiTransactionResultDuplecatingReceipt) should]
     equal:GreePlatformString(@"wallet.deposit.history.status.duplicatederror", @"Cancelled(duplicated)")];
    [[setStatusAndGetResultString(kGreeWalletDeposiTransactionResultInvalidReceipt) should]
     equal:GreePlatformString(@"wallet.deposit.history.status.receipterror", @"Failed(receipt error)")];
    [[setStatusAndGetResultString(kGreeWalletDeposiTransactionResultConnectionFailure) should]
     equal:GreePlatformString(@"wallet.deposit.history.status.networkerror", @"Wait for verification")];
    [[setStatusAndGetResultString(kGreeWalletDeposiTransactionResultCancel) should]
     equal:GreePlatformString(@"wallet.deposit.history.status.cancelled", @"Cancelled")];
    [[setStatusAndGetResultString(kGreeWalletDeposiTransactionResultIAPFailure) should]
     equal:GreePlatformString(@"wallet.deposit.history.status.iappurchasing", @"Awaiting IAP purchase request")];
    [[setStatusAndGetResultString(kGreeWalletDeposiTransactionResultHCGivingFailure) should]
     equal:GreePlatformString(@"wallet.deposit.history.status.othererror", @"Failed")];
  });
});

SPEC_END
