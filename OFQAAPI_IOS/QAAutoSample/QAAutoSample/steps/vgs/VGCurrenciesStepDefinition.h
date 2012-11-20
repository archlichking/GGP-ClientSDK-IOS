//
//  VGCurrenciesStepDefinition.h
//  QAAutoSample
//
//  Created by zhu lei on 11/20/12.
//  Copyright (c) 2012 OFQA. All rights reserved.
//

#import "StepDefinition.h"

@interface VGCurrenciesStepDefinition : StepDefinition

- (void) developer_uses_SDK_to_load_vgs_currencies;
- (void) developer_uses_SDK_to_load_vgs_currency_with_identifier_PARAM:(NSString*) identifier;

- (void) developer_uses_SDK_to_load_vgs_currency_listings;
- (void) developer_uses_SDK_to_load_vgs_currency_listings_with_category_PARAM:(NSString*) category;

- (void) developer_uses_SDK_to_load_vgs_currency_listing_categories;

- (void) vgs_currencies_amount_should_be_PARAMINT:(NSString*) size;
- (void) vgs_currencies_should_include_name_PARAM:(NSString*) name;
- (void) info_PARAM:(NSString*) info _of_currency_PARAM:(NSString*) identifier
   _should_be_PARAM:(NSString*) content;

- (void) vgs_currency_listings_amount_should_be_PARAMINT:(NSString*) size;
- (void) vgs_currency_listings_should_include_currency_PARAM:(NSString*) name;

- (void) vgs_currency_listing_categories_amount_should_be_PARAMINT:(NSString*) size;
- (void) vgs_currency_listing_categories_should_include_category_PARAM:(NSString*) name;

@end
