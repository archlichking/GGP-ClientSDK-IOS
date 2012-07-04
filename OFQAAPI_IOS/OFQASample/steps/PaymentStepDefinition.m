//
//  PaymentStepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PaymentStepDefinition.h"

#import "GreeWallet.h"
#import "GreeWalletPaymentItem.h"

@implementation PaymentStepDefinition

- (void) I_test_payment_api{
    GreeWalletPaymentItem* item = [GreeWalletPaymentItem paymentItemWithItemId:@"314" 
                                                                      itemName:@"laylay" 
                                                                     unitPrice:1 
                                                                      quantity:1 
                                                                      imageUrl:@"" 
                                                                   description:@""];
    
    NSMutableArray* temp = [[NSMutableArray alloc] initWithObjects:item, nil];
    
    [GreeWallet paymentWithItems:temp 
                         message:@"kick your ass"
                     callbackUrl:@""
                    successBlock:^(NSString *paymentId, NSArray *items) {
                        [self notifyInStep];
                    } 
                    failureBlock:^(NSString *paymentId, NSArray *items, NSError *error) {
                        [self notifyInStep];
                    }];
    
    [self waitForInStep];
    [temp release];
}

@end
