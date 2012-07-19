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
#import "GreeWalletPaymentItem+Internal.h"
#import "GreeSerializer.h"

SPEC_BEGIN(GreeWalletPaymentItemTests)

describe(@"Gree WalletPaymentItem", ^{

  it(@"should deserialize", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"mockid", @"itemId",
                                @"mockname", @"itemName",
                                [NSNumber numberWithInt:1], @"unitPrice",
                                [NSNumber numberWithInt:2], @"quantity",
                                @"mockurl", @"imageUrl",
                                @"mockdesc", @"description",
                                nil];
    
    GreeSerializer* serializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeWalletPaymentItem* item = [[GreeWalletPaymentItem alloc] initWithGreeSerializer:serializer];
    [[item.itemId should] equal:@"mockid"];
    [[item.itemName should] equal:@"mockname"];
    [[theValue(item.unitPrice) should] equal:theValue(1)];
    [[theValue(item.quantity) should] equal:theValue(2)];
    [[item.imageUrl should] equal:@"mockurl"];
    [[item.description should] equal:@"mockdesc"];
    [item release];
  });
  
  it(@"should show descriptionString", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"mockid", @"itemId",
                                @"mockname", @"itemName",
                                [NSNumber numberWithInt:1], @"unitPrice",
                                [NSNumber numberWithInt:2], @"quantity",
                                @"mockurl", @"imageUrl",
                                @"mockdesc", @"description",
                                nil];
    
    GreeSerializer* serializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeWalletPaymentItem* item = [[GreeWalletPaymentItem alloc] initWithGreeSerializer:serializer];
    NSString* checkString = [NSString stringWithFormat:@"<GreeWalletPaymentItem:%p, itemId:mockid, itemName:mockname, unitPrice:1, quantity:2, imageUrl:mockurl, description:mockdesc>", item];
    [[[item descriptionString] should] equal:checkString]; 
    [item release];
  });

  it(@"should serialize", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"mockid", @"itemId",
                                @"mockname", @"itemName",
                                [NSNumber numberWithInt:1], @"unitPrice",
                                [NSNumber numberWithInt:2], @"quantity",
                                @"mockurl", @"imageUrl",
                                @"mockdesc", @"description",
                                nil];
    
    GreeSerializer* deserializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeWalletPaymentItem* item = [[GreeWalletPaymentItem alloc] initWithGreeSerializer:deserializer];
    GreeSerializer* serializer = [GreeSerializer serializer];
    [item serializeWithGreeSerializer:serializer];
    [[serializer.rootDictionary should] equal:serialized];
    [item release];
  });

  it(@"should create object", ^{
    GreeWalletPaymentItem* item = [GreeWalletPaymentItem paymentItemWithItemId:@"mockid" itemName:@"mockname" unitPrice:1 quantity:2 imageUrl:@"mockurl" description:@"mockdesc"];
    [[item.itemId should] equal:@"mockid"];
    [[item.itemName should] equal:@"mockname"];
    [[theValue(item.unitPrice) should] equal:theValue(1)];
    [[theValue(item.quantity) should] equal:theValue(2)];
    [[item.imageUrl should] equal:@"mockurl"];
    [[item.description should] equal:@"mockdesc"];
  });

  it(@"should check item validity1", ^{
    GreeWalletPaymentItem* item1 = [GreeWalletPaymentItem paymentItemWithItemId:@"mockid" itemName:@"mockname" unitPrice:1 quantity:2 imageUrl:@"mockurl" description:@"mockdesc"];
    GreeWalletPaymentItem* item2 = [GreeWalletPaymentItem paymentItemWithItemId:@"mockid" itemName:@"mockname" unitPrice:1 quantity:2 imageUrl:@"mockurl" description:@"mockdesc"];
    NSArray* itemList = [NSArray arrayWithObjects:item1, item2, nil];
    NSArray* ary = [GreeWalletPaymentItem paymentDictionaryListWithItemList:itemList];
    [ary shouldNotBeNil];
  });
  
  it(@"should check item validity2", ^{
    GreeWalletPaymentItem* item1 = [GreeWalletPaymentItem paymentItemWithItemId:@"mockid" itemName:@"mockname" unitPrice:1 quantity:2 imageUrl:@"mockurl" description:@"mockdesc"];
    GreeWalletPaymentItem* item2 = [GreeWalletPaymentItem paymentItemWithItemId:nil itemName:@"mockname" unitPrice:1 quantity:2 imageUrl:@"mockurl" description:@"mockdesc"];
    NSArray* itemList = [NSArray arrayWithObjects:item1, item2, nil];
    NSArray* ary = [GreeWalletPaymentItem paymentDictionaryListWithItemList:itemList];
    [ary shouldBeNil];
  });

  it(@"should check item validity3", ^{
    GreeWalletPaymentItem* item1 = [GreeWalletPaymentItem paymentItemWithItemId:@"mockid" itemName:@"mockname" unitPrice:1 quantity:2 imageUrl:@"mockurl" description:@"mockdesc"];
    GreeWalletPaymentItem* item2 = [GreeWalletPaymentItem paymentItemWithItemId:@"mockid" itemName:@"" unitPrice:1 quantity:2 imageUrl:@"mockurl" description:@"mockdesc"];
    NSArray* itemList = [NSArray arrayWithObjects:item1, item2, nil];
    NSArray* ary = [GreeWalletPaymentItem paymentDictionaryListWithItemList:itemList];
    [ary shouldBeNil];
  });

  it(@"should check item validity4", ^{
    GreeWalletPaymentItem* item1 = [GreeWalletPaymentItem paymentItemWithItemId:@"mockid" itemName:@"mockname" unitPrice:1 quantity:2 imageUrl:@"mockurl" description:@"mockdesc"];
    GreeWalletPaymentItem* item2 = [GreeWalletPaymentItem paymentItemWithItemId:@"mockid" itemName:@"mockname" unitPrice:0 quantity:2 imageUrl:@"mockurl" description:@"mockdesc"];
    NSArray* itemList = [NSArray arrayWithObjects:item1, item2, nil];
    NSArray* ary = [GreeWalletPaymentItem paymentDictionaryListWithItemList:itemList];
    [ary shouldBeNil];
  });

  it(@"should check item validity5", ^{
    GreeWalletPaymentItem* item1 = [GreeWalletPaymentItem paymentItemWithItemId:@"mockid" itemName:@"mockname" unitPrice:1 quantity:2 imageUrl:@"mockurl" description:@"mockdesc"];
    GreeWalletPaymentItem* item2 = [GreeWalletPaymentItem paymentItemWithItemId:@"mockid" itemName:@"mockname" unitPrice:1 quantity:0 imageUrl:@"mockurl" description:@"mockdesc"];
    NSArray* itemList = [NSArray arrayWithObjects:item1, item2, nil];
    NSArray* ary = [GreeWalletPaymentItem paymentDictionaryListWithItemList:itemList];
    [ary shouldBeNil];
  });

  it(@"should check item validity6", ^{
    GreeWalletPaymentItem* item1 = [GreeWalletPaymentItem paymentItemWithItemId:@"mockid" itemName:@"mockname" unitPrice:1 quantity:2 imageUrl:@"mockurl" description:@"mockdesc"];
    GreeWalletPaymentItem* item2 = [GreeWalletPaymentItem paymentItemWithItemId:@"mockid" itemName:@"mockname" unitPrice:1 quantity:2 imageUrl:nil description:@"mockdesc"];
    NSArray* itemList = [NSArray arrayWithObjects:item1, item2, nil];
    NSArray* ary = [GreeWalletPaymentItem paymentDictionaryListWithItemList:itemList];
    [ary shouldNotBeNil];
  });

  it(@"should check item validity7", ^{
    GreeWalletPaymentItem* item1 = [GreeWalletPaymentItem paymentItemWithItemId:@"mockid" itemName:@"mockname" unitPrice:1 quantity:2 imageUrl:@"mockurl" description:@"mockdesc"];
    GreeWalletPaymentItem* item2 = [GreeWalletPaymentItem paymentItemWithItemId:@"mockid" itemName:@"mockname" unitPrice:1 quantity:2 imageUrl:@"mockurl" description:nil];
    NSArray* itemList = [NSArray arrayWithObjects:item1, item2, nil];
    NSArray* ary = [GreeWalletPaymentItem paymentDictionaryListWithItemList:itemList];
    [ary shouldNotBeNil];
  });

  it(@"should create item list from dictionary list", ^{
    NSDictionary* serialized1 = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"mockid1", @"itemId",
                                @"mockname1", @"itemName",
                                [NSNumber numberWithInt:1], @"unitPrice",
                                [NSNumber numberWithInt:2], @"quantity",
                                @"mockurl1", @"imageUrl",
                                @"mockdesc1", @"description",
                                nil];
    NSDictionary* serialized2 = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @"mockid2", @"itemId",
                                 @"mockname2", @"itemName",
                                 [NSNumber numberWithInt:3], @"unitPrice",
                                 [NSNumber numberWithInt:4], @"quantity",
                                 @"mockurl2", @"imageUrl",
                                 @"mockdesc2", @"description",
                                 nil];
    NSArray* dictionaryList = [NSArray arrayWithObjects:serialized1, serialized2, nil];    
    NSArray* itemList = [GreeWalletPaymentItem paymentItemListWithDictionaryList:dictionaryList]; 
    GreeWalletPaymentItem* item1 = [itemList objectAtIndex:0];
    [[item1.itemId should] equal:@"mockid1"];
    [[item1.itemName should] equal:@"mockname1"];
    [[theValue(item1.unitPrice) should] equal:theValue(1)];
    [[theValue(item1.quantity) should] equal:theValue(2)];
    [[item1.imageUrl should] equal:@"mockurl1"];
    [[item1.description should] equal:@"mockdesc1"];
    GreeWalletPaymentItem* item2 = [itemList objectAtIndex:1];
    [[item2.itemId should] equal:@"mockid2"];
    [[item2.itemName should] equal:@"mockname2"];
    [[theValue(item2.unitPrice) should] equal:theValue(3)];
    [[theValue(item2.quantity) should] equal:theValue(4)];
    [[item2.imageUrl should] equal:@"mockurl2"];
    [[item2.description should] equal:@"mockdesc2"];
  });
  
});

SPEC_END

