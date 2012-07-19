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
#import "GreeWalletDepositIAPHistoryGateway.h"
#import "GreeWalletDepositIAPHistoryRecord.h"
#import "NSString+GreeAdditions.h"


SPEC_BEGIN(GreeWalletDepositIAPHistoryGatewayTests)

describe(@"GreeWalletDepositIAPHistoryGateway", ^{
  __block NSString* aUserId = @"12345";
  
  beforeEach(^{
    NSString* aHistoryDatabasePath = [NSString stringWithFormat:@"gree.wallet/%@.sqlite", aUserId];
    NSString* aFileSystemPath = [NSString greeDocumentsPathForRelativePath:aHistoryDatabasePath];
    [[NSFileManager defaultManager] removeItemAtPath:aFileSystemPath error:nil];
  });

  it(@"should be nil with no user id initialization", ^{
    GreeWalletDepositIAPHistoryGateway* gateway = [GreeWalletDepositIAPHistoryGateway gatewayWithUserId:@""];
    [gateway shouldBeNil];
  });
  
  it(@"should initialize correctly with user id", ^{
    GreeWalletDepositIAPHistoryGateway* gateway = [GreeWalletDepositIAPHistoryGateway gatewayWithUserId:aUserId];
    [gateway shouldNotBeNil];
  });

  it(@"should create a history database file", ^{
    GreeWalletDepositIAPHistoryGateway* gateway = [GreeWalletDepositIAPHistoryGateway gatewayWithUserId:aUserId];
    [gateway shouldNotBeNil];
    NSString* aHistoryDatabasePath = [NSString stringWithFormat:@"gree.wallet/%@.sqlite", aUserId];
    NSString* aFileSystemPath = [NSString greeDocumentsPathForRelativePath:aHistoryDatabasePath];
    [[theValue([[NSFileManager defaultManager] fileExistsAtPath:aFileSystemPath]) should] beYes];
  });
  
  it(@"should be able to insert a record object", ^{
    NSString* aReceiptString = @"{ 'hoge' : 'fuga' }";
    GreeWalletDepositIAPHistoryRecord* aRecord = [[[GreeWalletDepositIAPHistoryRecord alloc] init] autorelease];
    [aRecord shouldNotBeNil];
    aRecord.transactionState = 1;
    aRecord.issueDate = [NSDate date];
    aRecord.quantity = 1;
    aRecord.productId = @"net.gree.app1.tier7";
    aRecord.productName = @"HogeCoin1000";
    aRecord.receiptBinaryData = [aReceiptString dataUsingEncoding:NSUTF8StringEncoding];
    GreeWalletDepositIAPHistoryGateway* gateway = [GreeWalletDepositIAPHistoryGateway gatewayWithUserId:aUserId];
    [gateway shouldNotBeNil];
    [gateway insertWithRecord:aRecord withBlock:^(BOOL aResult) {
      [[theValue(aResult) should] beYes];
    }];
  });

  it(@"should be able to select records with offset", ^{
    NSString* aReceiptString = @"{ 'hoge' : 'fuga' }";
    GreeWalletDepositIAPHistoryGateway* gateway = [GreeWalletDepositIAPHistoryGateway gatewayWithUserId:aUserId];
    [gateway shouldNotBeNil];
    [gateway findWithOffset:0 withBlock:^(NSArray *resultSet) {
      [[resultSet should] haveCountOf:0];
    }];
    
    for (int i = 0; i < 9; i++) {
      GreeWalletDepositIAPHistoryRecord* aRecord = [[[GreeWalletDepositIAPHistoryRecord alloc] init] autorelease];
      [aRecord shouldNotBeNil];
      aRecord.transactionState = 1;
      aRecord.issueDate = [NSDate date]; //[NSDate dateWithTimeIntervalSinceReferenceDate:i*60*60];
      aRecord.quantity = 1;
      aRecord.productId = @"net.gree.app1.tier7";
      aRecord.productName = @"HogeCoin1000";
      aRecord.receiptBinaryData = [aReceiptString dataUsingEncoding:NSUTF8StringEncoding];
      [gateway insertWithRecord:aRecord withBlock:^(BOOL aResult) {
        [[theValue(aResult) should] beYes];
      }];
    }

    [gateway findWithOffset:0 withBlock:^(NSArray *resultSet) {
      [[resultSet should] haveCountOf:9];
    }];
  });

  it(@"should be able to retrieve just one record of the last date", ^{
    GreeWalletDepositIAPHistoryGateway* gateway = [GreeWalletDepositIAPHistoryGateway gatewayWithUserId:aUserId];
    [gateway shouldNotBeNil];
    [gateway findWithOffset:0 withBlock:^(NSArray *resultSet) {
      [[resultSet should] haveCountOf:0];
    }];
    
    for (int i = 0; i < 9; i++) {
      GreeWalletDepositIAPHistoryRecord* aRecord = [[[GreeWalletDepositIAPHistoryRecord alloc] init] autorelease];
      [aRecord shouldNotBeNil];
      aRecord.transactionState = i;
      aRecord.issueDate = [NSDate dateWithTimeIntervalSinceReferenceDate:i*60*60];
      aRecord.quantity = 1;
      aRecord.productId = @"net.gree.app1.tier7";
      aRecord.productName = [NSString stringWithFormat:@"HogeCoin%d", i];
      aRecord.receiptBinaryData = [@"{ 'hoge' : 'fuga' }" dataUsingEncoding:NSUTF8StringEncoding];
      [gateway insertWithRecord:aRecord withBlock:^(BOOL aResult) {
        [[theValue(aResult) should] beYes];
      }];
    }
    
    [gateway countNeedToCollateRecordWithBlock:^(NSUInteger count) {
      [[theValue(count) should] equal:theValue(2)];
    }];
  });
  
});


SPEC_END

