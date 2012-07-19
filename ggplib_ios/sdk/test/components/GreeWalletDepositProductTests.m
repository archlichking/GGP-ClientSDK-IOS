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
#import "GreeWalletDepositProduct.h"
#import "GreeSerializer.h"

NSString* const kGreeWalletDepositProductTestsProductId = @"12345";
NSString* const kGreeWalletDepositProductTestsTierName = @"tierName";
NSString* const kGreeWalletDepositProductTestsPrice = @"price";
NSString* const kGreeWalletDepositProductTestsCurrencyCode = @"currencyCode";
NSString* const kGreeWalletDepositProductTestsDescription = @"description";
NSString* const kGreeWalletDepositProductTestsThumbnailURLString = @"thubnailUrlString";
NSString* const kGreeWalletDepositProductTestsTotalAmountString = @"9999";
NSString* const kGreeWalletDepositProductTestsTierString = @"9";
NSString* const kGreeWalletDepositProductTestsPointString = @"9999";

SPEC_BEGIN(GreeWalletDepositProductTests)

describe(@"GreeWallet Deposit Product", ^{
  __block GreeWalletDepositProduct *product;

  beforeEach(^{
    product = [[GreeWalletDepositProduct alloc] initWithProductId:kGreeWalletDepositProductTestsProductId
                tierName:kGreeWalletDepositProductTestsTierName
                price:kGreeWalletDepositProductTestsPrice
                currencyCode:kGreeWalletDepositProductTestsCurrencyCode
                desc:kGreeWalletDepositProductTestsDescription
                thumbnailURLString:kGreeWalletDepositProductTestsThumbnailURLString
                totalAmount:kGreeWalletDepositProductTestsTotalAmountString
                tier:kGreeWalletDepositProductTestsTierString
                point:kGreeWalletDepositProductTestsPointString];
  });

  afterEach(^{
    product = nil;
  });
  context(@"when initializing", ^{

    it(@"should initizlize normally with class method", ^{
      GreeWalletDepositProduct *product1 = [GreeWalletDepositProduct product];
      [product1 shouldNotBeNil];
      [[product1 should] beKindOfClass:[GreeWalletDepositProduct class]];
    });

    it(@"should initialize normally", ^{
      [product shouldNotBeNil];
      [[product should] beKindOfClass:[GreeWalletDepositProduct class]];

      [[product.productId should] equal:kGreeWalletDepositProductTestsProductId];
      [[product.tierName should] equal:kGreeWalletDepositProductTestsTierName];
      [[product.price should] equal:kGreeWalletDepositProductTestsPrice];
      [[product.currencyCode should] equal:kGreeWalletDepositProductTestsCurrencyCode];
      [[product.desc should] equal:kGreeWalletDepositProductTestsDescription];
      [[product.thumbnailURLString should] equal:kGreeWalletDepositProductTestsThumbnailURLString];
      [[product.totalAmount should] equal:kGreeWalletDepositProductTestsTotalAmountString];
      [[product.tier should] equal:kGreeWalletDepositProductTestsTierString];
      [[product.point should] equal:kGreeWalletDepositProductTestsPointString];
    });
  });

  it(@"should return the proper dictionary", ^{
    NSDictionary *returnDictionary = [product asDictionary];
    [[[returnDictionary objectForKey:@"product_id"] should] equal:kGreeWalletDepositProductTestsProductId];
    [[[returnDictionary objectForKey:@"tier_name"] should] equal:kGreeWalletDepositProductTestsTierName];
    [[[returnDictionary objectForKey:@"price"] should] equal:kGreeWalletDepositProductTestsPrice];
    [[[returnDictionary objectForKey:@"currency_code"] should] equal:kGreeWalletDepositProductTestsCurrencyCode];
    [[[returnDictionary objectForKey:@"description"] should] equal:kGreeWalletDepositProductTestsDescription];
    [[[returnDictionary objectForKey:@"thumbnail_url"] should] equal:kGreeWalletDepositProductTestsThumbnailURLString];
    [[[returnDictionary objectForKey:@"total_amount"] should] equal:kGreeWalletDepositProductTestsTotalAmountString];
    [[[returnDictionary objectForKey:@"tier"] should] equal:kGreeWalletDepositProductTestsTierString];
    [[[returnDictionary objectForKey:@"point"] should] equal:kGreeWalletDepositProductTestsPointString];
  });

  it(@"should serialize normally", ^{
    GreeSerializer *serializer = [GreeSerializer serializer];
    [product serializeWithGreeSerializer:serializer];
    [[serializer.rootDictionary should] equal:[product asDictionary]];
  });

});

SPEC_END
