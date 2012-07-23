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

// balance
- (void) I_check_my_balance;
- (NSString*) my_balance_should_be_PARAM:(NSString*) balance;

// product list
- (void) I_load_product_list_of_game_PARAMINT:(NSString*) gid;
- (NSString*) product_list_should_be_size_of_PARAMINT:(NSString*) size;
- (NSString*) product_list_should_have_product_with_id_PARAM:(NSString*) pid 
                                         _and_title_PARAM:(NSString*) title 
                                          _and_code_PARAM:(NSString*) code 
                                         _and_price_PARAM:(NSString*) price 
                                          _and_tier_PARAM:(NSString*) tier 
                                     _and_points_PARAMINT:(NSString*) points;

// payment popup
- (void) I_add_payment_item_with_ID_PARAM:(NSString*) pid 
                          _and_NAME_PARAM:(NSString*) name 
                     _and_UNITPRICE_PARAM:(NSString*) price 
                      _and_QUANTITY_PARAM:(NSString*) quality 
                      _and_IMAGEURL_PARAM:(NSString*) imageurl 
                   _and_DESCRIPTION_PARAM:(NSString*) description;

- (void) I_did_open_the_payment_request_popup;


@end
