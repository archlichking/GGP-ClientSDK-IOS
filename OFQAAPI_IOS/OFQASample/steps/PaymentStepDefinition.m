//
//  PaymentStepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PaymentStepDefinition.h"

#import "GreeWallet.h"
#import "GreeWallet+ExternalUISupport.h"
#import "GreeWalletPaymentItem.h"
#import "GreeWalletProduct.h"

#import "GreePopup.h"

#import "QAAssert.h"
#import "StringUtil.h"
#import "CommandUtil.h"


// define gree payment delegate
@interface GreePaymentDelegate : NSObject <GreeWalletDelegate>
- (void) walletPaymentDidLaunchPopup;
- (void) walletPaymentDidDismissPopup;
@end

@implementation GreePaymentDelegate
- (void) walletPaymentDidLaunchPopup;{
    NSLog(@"payment request popup did launch");
    //[StepDefinition notifyOutsideStep];
}

- (void) walletPaymentDidDismissPopup{
    NSLog(@"payment request popup did dismiss");
}
@end


@implementation PaymentStepDefinition

// --- begin ---------- balance

// step definition : i check my balance
- (void) I_check_my_balance{
    [GreeWallet loadBalanceWithBlock:^(unsigned long long balance, NSError *error) {
        if(!error){
            [[self getBlockRepo] setObject:[NSString stringWithFormat:@"%d", balance] 
                                    forKey:@"balance"];
        }
        [self notifyInStep];
    }];
    [self waitForInStep];
}

// step definition : my balance should be BALANCE
- (NSString*) my_balance_should_be_PARAM:(NSString*) balance{
    NSString* b = [[self getBlockRepo] objectForKey:@"balance"];
    [QAAssert assertEqualsExpected:balance 
                            Actual:b];
    
    return [NSString stringWithFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@", 
            @"balance checked", 
            balance, 
            b, 
            SpliterTcmLine];
}

// --- end ------------ balance

// --- begin ---------- product list

// step definition : i load product list of game GID
- (void) I_load_product_list_of_game_PARAMINT:(NSString*) gid{
    [GreeWallet loadProductsWithBlock:^(NSArray *products, NSError *error) {
        if(!error){
            [[self getBlockRepo] setObject:products forKey:@"products"];
        }
        NSLog(@"%@", products);
        [self notifyInStep];
    }];
    
    [self waitForInStep];
}

// step definition : product list should be size of SIZE
- (NSString*) product_list_should_be_size_of_PARAMINT:(NSString*) size{
    NSArray* products = [[self getBlockRepo] objectForKey:@"products"];
    NSString* expSize = [NSString stringWithFormat:@"%i", [products count]];
    [QAAssert assertEqualsExpected:size 
                            Actual:expSize];
    return [NSString stringWithFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@", 
            @"product list size", 
            size, 
            expSize, 
            SpliterTcmLine];
}

// step definition : product list should have product with id PID and title TITLE and code CD and price PRZ and tier TIER and points PTS
- (NSString*) product_list_should_have_product_with_id_PARAM:(NSString*) pid 
                                         _and_title_PARAM:(NSString*) title 
                                          _and_code_PARAM:(NSString*) code 
                                         _and_price_PARAM:(NSString*) price 
                                          _and_tier_PARAM:(NSString*) tier 
                                     _and_points_PARAMINT:(NSString*) points{
    NSArray* products = [[self getBlockRepo] objectForKey:@"products"];
    
    NSString* result = @"";
    
    for (GreeWalletProduct* product in products) {
        if ([[product productId] isEqualToString:pid]) {
            [QAAssert assertEqualsExpected:title Actual:[product productTitle]];
            result = [result stringByAppendingFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@", 
                      @"productTitle", 
                      title, 
                      [product productTitle], 
                      SpliterTcmLine];
            
            [QAAssert assertEqualsExpected:code Actual:[product currencyCode]];
            result = [result stringByAppendingFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@", 
                      @"currencyCode", 
                      code, 
                      [product currencyCode], 
                      SpliterTcmLine];
            
            [QAAssert assertEqualsExpected:price Actual:[product price]];
            result = [result stringByAppendingFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@", 
                      @"price", 
                      price, 
                      [product price], 
                      SpliterTcmLine];
            
            [QAAssert assertEqualsExpected:tier Actual:[product tier]];
            result = [result stringByAppendingFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@", 
                      @"tier", 
                      tier, 
                      [product tier], 
                      SpliterTcmLine];
            
            [QAAssert assertEqualsExpected:points Actual:[product points]];
            result = [result stringByAppendingFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@", 
                      @"points", 
                      points, 
                      [product points], 
                      SpliterTcmLine];
        }
        return result;
    }
    [QAAssert assertEqualsExpected:pid 
                            Actual:nil 
                       WithMessage:@"no product item matches"];
    return result;
    
}
// --- end ------------ product list 

//--- begin --------- payment popup

// step definition : I add payment item with ID xx, NAME xx, UNIT_PRICE xx, QUANTITY xx, IMAGE_URL xx and DESCRIPTION xx
- (void) I_add_payment_item_with_ID_PARAM:(NSString*) pid 
                          _and_NAME_PARAM:(NSString*) name 
                     _and_UNITPRICE_PARAM:(NSString*) price 
                      _and_QUANTITY_PARAM:(NSString*) quality 
                      _and_IMAGEURL_PARAM:(NSString*) imageurl 
                   _and_DESCRIPTION_PARAM:(NSString*) description{
    GreeWalletPaymentItem* item = [GreeWalletPaymentItem paymentItemWithItemId:pid 
                                                                      itemName:name 
                                                                     unitPrice:[price integerValue] 
                                                                      quantity:[quality integerValue] 
                                                                      imageUrl:imageurl
                                                                   description:description];
    NSMutableArray* arr = [[self getBlockRepo] objectForKey:@"paymentItemList"];
    if (!arr) {
        arr = [[NSMutableArray alloc] init];
    }
    
    [arr addObject:item];
    
    [[self getBlockRepo] setObject:arr 
                            forKey:@"paymentItemList"];
}

// step definition : I did open the payment request popup
- (void) I_did_open_the_payment_request_popup{
    
    id successBlock = ^ (NSString* paymentId, NSArray* items){
       // [self notifyInStep];  
    };
    
    id failureBlock = ^ (NSString* paymentId, NSArray* items, NSError* error){
       // [self notifyInStep];  
    };
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", executeInPaymentRequestPopup], @"command",
                                        [[self getBlockRepo] objectForKey:@"paymentItemList"], @"items",
                                        @"", @"message",
                                        @"http://www.google.com", @"callbackUrl",
                                        successBlock, @"sBlock",
                                        failureBlock, @"fBlock",
                                        nil];
    // set delegate to hack did popup and did dismiss
    GreePaymentDelegate* delegate = [[GreePaymentDelegate alloc] init];
    [GreeWallet setDelegate:delegate];
    
    [self notifyMainUIWithCommand:CommandDispatchPopupCommand 
                           object:userinfoDic];
    [StepDefinition waitForOutsideStep];
//    [self waitForInStep];
}

//--- end ----------- payment popup


@end
