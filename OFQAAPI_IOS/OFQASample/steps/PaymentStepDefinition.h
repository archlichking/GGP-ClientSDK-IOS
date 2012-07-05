//
//  PaymentStepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StepDefinition.h"

@interface PaymentStepDefinition : StepDefinition

- (void) I_check_my_balance;
- (NSString*) my_balance_should_be_PARAM:(NSString*) balance;

- (void) I_do_payment_test;

- (void) product_test;

@end
