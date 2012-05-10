//
//  PaymentStepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 5/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StepDefinition.h"

@interface PaymentStepDefinition : StepDefinition

- (void) I_purchase_PARAM:(NSString*) item;

- (void) I_should_have_a_purchase_id_looks_PARAM:(NSString*) valid;

- (void) I_make_sure_purchase_list_PARAM:(NSString*) include 
                             _item_PARAM:(NSString*) item;

@end
