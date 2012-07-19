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
#import "JSONKit.h"
#import "GreeWalletDepositProductsList.h"
#import "GreeWalletDepositProduct.h"

NSString* const kGreeWalletDepositProductsListTestsProductId = @"net.gree.sdk.showcase.tier12";
NSString* const kGreeWalletDepositProductsListTestslocalizedTitle = @"Coin Tier 12";
NSString* const kGreeWalletDepositProductsListTestsPrice = @"1000";
NSString* const kGreeWalletDepositProductsListTestsDescriptionMeta = @"metaDescription";
NSString* const kGreeWalletDepositProductsListTestsThumbnailURLStringMeta = @"http://thumbnailUrl";

SPEC_BEGIN(GreeWalletDepositProductsListTests)

describe(@"GreeWallet Deposit ProductsList", ^{
  __block GreeWalletDepositProductsList *productsList;
  __block GreeWalletDepositProduct *resultProduct;
  __block SKProduct *testSKProduct;
  beforeEach(^{
    productsList = [GreeWalletDepositProductsList productsList];
    testSKProduct = [SKProduct mock];
    [testSKProduct stub:@selector(productIdentifier) andReturn:kGreeWalletDepositProductsListTestsProductId];
    [testSKProduct stub:@selector(localizedTitle) andReturn:kGreeWalletDepositProductsListTestslocalizedTitle];
    [testSKProduct stub:@selector(price) andReturn:kGreeWalletDepositProductsListTestsPrice];
    [testSKProduct stub:@selector(priceLocale) andReturn:[NSLocale currentLocale]];
    productsList.skProductsArray = [NSArray arrayWithObject:testSKProduct];
    NSString *metaPriceJson = @"{\"entry\":{\"net.gree.sdk.showcase.tier12\":{\"tier\":\"12\",\"point\":\"999\"}}}";
    NSString *metaJson = [NSString stringWithFormat:@"{"
                                                      @"\"products\" : ["
                                                        @"{"
                                                          @"\"contents\" : {"
                                                            @"\"description\" : \"%@\","
                                                            @"\"productId\" : \"%@\","
                                                            @"\"thumbnailUrl\" : \"%@\","
                                                            @"\"totalAmount\" : \"999\""
                                                          @"}"
                                                        @"}"
                                                      @"]"
                                                    @"}",
                          kGreeWalletDepositProductsListTestsDescriptionMeta,
                          kGreeWalletDepositProductsListTestsProductId,
                          kGreeWalletDepositProductsListTestsThumbnailURLStringMeta];
    productsList.priceList = [metaPriceJson greeMutableObjectFromJSONString];
    productsList.metaDataDictionary = [metaJson greeMutableObjectFromJSONString];
    [productsList merge];
    resultProduct = [productsList.mergedProductsList objectAtIndex:0];
  });

  afterEach(^{
    productsList = nil;
  });

  it(@"should initialize normally", ^{
    [productsList shouldNotBeNil];
    [[productsList should] beKindOfClass:[GreeWalletDepositProductsList class]];
  });

  it(@"should merge normally", ^{
    [[resultProduct should] beKindOfClass:[GreeWalletDepositProduct class]];
    [[resultProduct.productId should] equal:kGreeWalletDepositProductsListTestsProductId];
    [[resultProduct.tierName should] equal:kGreeWalletDepositProductsListTestslocalizedTitle];
    [[resultProduct.price should] equal:[NSString stringWithFormat:@"%.2f", [kGreeWalletDepositProductsListTestsPrice floatValue]]];
    [[resultProduct.currencyCode should] equal:[[NSLocale currentLocale] objectForKey:NSLocaleCurrencyCode]];
    [[resultProduct.desc should] equal:kGreeWalletDepositProductsListTestsDescriptionMeta];
    [[resultProduct.thumbnailURLString should] equal:kGreeWalletDepositProductsListTestsThumbnailURLStringMeta];
  });

  it(@"should return merged ProductsList Dictionary", ^{
    [[[productsList mergedProductsListDictionary] should] equal:
      [NSDictionary dictionaryWithObject:[NSArray arrayWithObject:[resultProduct asDictionary]]
       forKey:@"entry"]
    ];
  });

  it(@"should return merged ProductsList JSONString", ^{
    [[[productsList mergedProductsListJSONString] should] equal:
      [[NSArray arrayWithObject:[resultProduct asDictionary]] greeJSONString]
    ];
  });

  it(@"should return product From ProductId", ^{
    [[[productsList productFromProductId:kGreeWalletDepositProductsListTestsProductId] should] equal:resultProduct];
  });

  it(@"should return skProduct From ProductId", ^{
    [[[productsList skProductFromProductId:kGreeWalletDepositProductsListTestsProductId] should] equal:testSKProduct];
  });
});

SPEC_END
