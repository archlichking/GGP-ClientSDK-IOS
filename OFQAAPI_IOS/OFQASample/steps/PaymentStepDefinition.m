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
#import "GreePopup.h"

#import "QAAssert.h"
#import "StringUtil.h"
#import "CommandUtil.h"

@interface GreePopup(PrivatePopupHacking)
- (void)popupViewWebViewDidFinishLoad:(UIWebView*)aWebView;
@end

@implementation GreePopup(PrivatePopupHacking)
- (void)popupViewWebViewDidFinishLoad:(UIWebView*)aWebView{
    //    NSLog(@"%@", [aWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"]);
    [StepDefinition notifyOutsideStep];
}
@end

@implementation PaymentStepDefinition

- (void)  I_check_my_balance{

    [GreeWallet loadBalanceWithBlock:^(unsigned long long balance, NSError *error) {
        if(!error){
            [[self getBlockRepo] setObject:[NSString stringWithFormat:@"%d", balance] 
                                    forKey:@"balance"];
        }
        [self notifyInStep];
    }];
    [self waitForInStep];
}

- (NSString*)  my_balance_should_be_PARAM:(NSString*) balance{
    NSString* b = [[self getBlockRepo] objectForKey:@"balance"];
    [QAAssert assertEqualsExpected:balance 
                            Actual:b];
    
    return [NSString stringWithFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@", 
            @"balance checked", 
            balance, 
            b, 
            SpliterTcmLine];
}

- (void) product_test{
    [GreeWallet loadProductsWithBlock:^(NSArray *products, NSError *error) {
        if(!error){
            
        }
        NSLog(@"%@", products);
        [self notifyInStep];
    }];
    [self waitForInStep];
}

- (void) I_do_payment_test{
    GreeWallet* wallet = [[GreeWallet alloc] init];
   
    GreeWalletPaymentItem* item = [GreeWalletPaymentItem paymentItemWithItemId:@"1" itemName:@"1" unitPrice:1 quantity:1 imageUrl:@"http://a.b.com" description:@"1"];
    
    id success = ^(NSString *paymentId, NSArray *items){
        [self notifyInStep];
    };
    
    id failed = ^(NSString *paymentId, NSArray *items, NSError *error) {
        [self notifyInStep];
    };
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", executeInWallet], @"command",
                                        wallet, @"executor",
                                        item, @"item",
                                        success, @"sBlock",
                                        failed, @"fBlock",
                                        nil];
    
    
    
    [self notifyMainUIWithCommand:CommandDispatchPopupCommand 
                           object:userinfoDic];
    
    
    [StepDefinition waitForOutsideStep];
    [self waitForInStep];
}

@end
