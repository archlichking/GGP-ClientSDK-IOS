//
//  VGItemStepDefinition.h
//  QAAutoSample
//
//  Created by zhu lei on 11/21/12.
//  Copyright (c) 2012 OFQA. All rights reserved.
//

#import "StepDefinition.h"

@interface VGItemStepDefinition : StepDefinition

- (void) developer_uses_SDK_to_load_vgs_items;
- (void) vgs_items_amount_should_be_PARAMINT:(NSString*) size;
- (void) vgs_items_should_include_identifier_PARAM:(NSString*) identifier;

- (void) developer_uses_SDK_to_load_vgs_item_with_identifier_PARAM:(NSString*) identifier;
- (void) info_PARAM:(NSString*) info _of_item_PARAM:(NSString*) identifier
   _should_be_PARAM:(NSString*) content;

- (void) developer_uses_SDK_to_load_vgs_item_listings;
- (void) vgs_item_listings_amount_should_be_PARAMINT:(NSString*) size;
- (void) vgs_item_listings_should_include_name_PARAM:(NSString*) name;

- (void) developer_uses_SDK_to_load_vgs_item_listing_categories;
- (void) vgs_item_listing_categories_amount_should_be_PARAMINT:(NSString*) size;
- (void) vgs_item_listing_categories_should_include_category_PARAM:(NSString*) name;

- (void) developer_uses_SDK_to_load_vgs_item_listing_category_PARAM:(NSString*) category;

- (void) developer_uses_SDK_to_check_basic_info_of_item_listing_with_name_PARAM:(NSString*) name;
- (void) info_PARAM:(NSString*) info _of_vgs_item_listing_PARAM:(NSString*) identifier
   _should_be_PARAM:(NSString*) content;

- (void) info_PARAM:(NSString*) info _of_vgs_item_listing_PARAM:(NSString*) name
_and_currency_PARAM:(NSString*) identifier
   _should_be_PARAM:(NSString*) price;
@end
