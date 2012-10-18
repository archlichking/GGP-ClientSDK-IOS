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


@implementation PaymentStepDefinition

// --- begin ---------- balance

// step definition : i check my balance
- (void) I_check_my_balance{
    [[self getBlockRepo] removeObjectForKey:@"balance"];
    [GreeWallet loadBalanceWithBlock:^(unsigned long long balance, NSError *error) {
        if(!error){
            [[self getBlockRepo] setObject:[NSString stringWithFormat:@"%lld", balance] 
                                    forKey:@"balance"];
        }
        [self inStepNotify];
    }];
    [self inStepWait];
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
        [self inStepNotify];
    }];
    
    [self inStepWait];
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
    [QAAssert assertNil:@"no product item matches"];
    return result;
    
}
// --- end ------------ product list 

// --- begin ---------- payment verification
- (void) I_verify_payment_order_PARAM:(NSString*) order{
    [[self getBlockRepo] removeObjectForKey:@"paymentVerificationResult"];
    [GreeWallet paymentVerifyWithPaymentId:order 
                              successBlock:^(NSString *paymentId, NSArray *items) {
                                  [[self getBlockRepo] setObject:@"SUCCESS" forKey:@"paymentVerificationResult"];
                                  [self inStepNotify];
                              } 
                              failureBlock:^(NSString *paymentId, NSArray *items, NSError *error) {
                                  [[self getBlockRepo] setObject:@"FAILED" forKey:@"paymentVerificationResult"];
                                  [self inStepNotify];
                              }];
    [self inStepWait];
}


- (void) payment_order_verify_result_should_be_PARAM:(NSString*) status{
    [QAAssert assertEqualsExpected:status 
                            Actual:[[self getBlockRepo] objectForKey:@"paymentVerificationResult"]];
}

// --- end ---------- payment verification

// --- begin -------- buy
- (void) I_buy_product_with_id_PARAM:(NSString*) product{
    [[self getBlockRepo] removeObjectForKey:@"purchasedProduct"];
    [GreeWallet purchaseProduct:product
                      withBlock:^(GreeWalletProduct *product, NSError *error) {
                          if (!error) {
                              [[self getBlockRepo] setObject:product forKey:@"purchasedProduct"];
                          }
                          [self inStepNotify];
                      }];
    [self inStepWait];
    
    [self I_check_my_balance];
}

- (void) purchased_product_id_should_be_PARAM:(NSString*) product{
    GreeWalletProduct* p = [[self getBlockRepo] objectForKey:@"purchasedProduct"];
    [QAAssert assertEqualsExpected:product Actual:[p productId]];
}

// --- end ---------- buy
@end
