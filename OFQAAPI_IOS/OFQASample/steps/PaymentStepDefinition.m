//
//  PaymentStepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PaymentStepDefinition.h"
#import "GreeWallet.h"
#import "GreeWalletPaymentItem.h"
#import "QAAssert.h"

@implementation PaymentStepDefinition

- (void) I_purchase_PARAM:(NSString*) item{
    NSMutableArray* array = [[self getBlockRepo] objectForKey:@"items"];
    [GreeWallet paymentWithItems:array
                         message:@"test pay" 
                     callbackUrl:@"http://www.google.com" 
                    successBlock:^(NSString *paymentId, NSArray *items) {
                        [[self getBlockRepo] setValue:paymentId 
                                               forKey:@"paymentid"];
                        [self notifyInStep];
                    } 
                    failureBlock:^(NSString *paymentId, NSArray *items, NSError *error) {
                        [[self getBlockRepo] setValue:@""
                                               forKey:@"paymentid"];
                        [self notifyInStep];
                    }
     ];
    [self waitForInStep];
}

- (void) I_should_have_a_purchase_id_looks_PARAM:(NSString*) valid{
    NSString* paymentid = [[self getBlockRepo] objectForKey:@"paymentid"];
    if ([valid isEqualToString:@"VALID"]) {
        NSString* isNull = paymentid == nil?@"YES":@"NO";
        
        [QAAssert assertEqualsExpected:@"NO"
                                Actual:isNull];
    }else{
        [QAAssert assertEqualsExpected:@"" 
                                Actual:paymentid];
    }
}

- (void) I_make_sure_purchase_list_PARAM:(NSString*) include 
                             _item_PARAM:(NSString*) item{
    if (![[self getBlockRepo] objectForKey:@"items"]) {
        [[self getBlockRepo] setValue:[[NSMutableArray alloc] init] 
                               forKey:@"items"];
    }
    
    GreeWalletPaymentItem* pItem = [GreeWalletPaymentItem paymentItemWithItemId:@"aa" 
                                                                       itemName:@"testitem" 
                                                                      unitPrice:1
                                                                       quantity:1
                                                                       imageUrl:@"http://images.apple.com/jp/iphone/home/images/bucket_icon_ios.png"
                                                                    description:@"testdescription"];
    [[[self getBlockRepo] objectForKey:@"items"] addObject:pItem];
}

@end
