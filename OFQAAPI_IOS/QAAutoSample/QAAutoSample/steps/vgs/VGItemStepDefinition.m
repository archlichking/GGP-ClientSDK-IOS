//
//  VGItemStepDefinition.m
//  QAAutoSample
//
//  Created by zhu lei on 11/21/12.
//  Copyright (c) 2012 OFQA. All rights reserved.
//

#import "VGItemStepDefinition.h"

#import "GreeVirtualGoods.h"
#import "GreeVGItem.h"
#import "GreeVGItemListing.h"

#import "QAAssert.h"


@implementation VGItemStepDefinition

- (void) developer_uses_SDK_to_load_vgs_items{
    [[self getBlockRepo] removeObjectForKey:@"vgitems"];
    NSArray* items = [[GreeVirtualGoods sharedInstance] items];
    [[self getBlockRepo] setObject:items forKey:@"vgitems"];
}

- (void) vgs_items_amount_should_be_PARAMINT:(NSString*) size{
    NSArray* items =[[self getBlockRepo] objectForKey:@"vgitems"];
    [QAAssert assertEqualsExpected:size
                            Actual:[NSString stringWithFormat:@"%i", [items count]]];
}

- (void) vgs_items_should_include_identifier_PARAM:(NSString*) identifier{
    NSArray* items = [[self getBlockRepo] objectForKey:@"vgitems"];
    NSString* found = [NSString stringWithFormat:@"not found vgs item with identifier %@", identifier];
    for (GreeVGItem* i in items) {
        if ([[i identifier] isEqualToString:identifier]){
            found = nil;
        }
    }
    [QAAssert assertNil:found];
}

- (void) developer_uses_SDK_to_load_vgs_item_with_identifier_PARAM:(NSString*) identifier{
    [[self getBlockRepo] removeObjectForKey:@"vgitem"];
    GreeVGItem* item = [[GreeVirtualGoods sharedInstance] itemWithIdentifier:identifier];
    [[self getBlockRepo] setObject:item forKey:@"vgitem"];

}

- (void) info_PARAM:(NSString*) info _of_item_PARAM:(NSString*) identifier _should_be_PARAM:(NSString*) content{
    GreeVGItem* item = [[self getBlockRepo] objectForKey:@"vgitem"];
    if ([info isEqualToString:@"itemName"]) {
        [QAAssert assertEqualsExpected:content Actual:[item itemName]];
    }else  if ([info isEqualToString:@"itemDescription"]) {
        [QAAssert assertEqualsExpected:content Actual:[item itemDescription]];
    }else  if ([info isEqualToString:@"unique"]) {
        [QAAssert assertEqualsExpected:content Actual:[item isUnique]?@"YES":@"NO"];
    }else  if ([info isEqualToString:@"metadata"]) {
        [QAAssert assertContainsExpected:content Contains:[[item metadata] description]];
    }else{
        [QAAssert assertNotNil:nil];
    }
}

- (void) developer_uses_SDK_to_load_vgs_item_listings{
    [[self getBlockRepo] removeObjectForKey:@"vgitemlistings"];
    NSArray* itemlists = [[GreeVirtualGoods sharedInstance] itemListings];
    [[self getBlockRepo] setObject:itemlists forKey:@"vgitemlistings"];
}

- (void) vgs_item_listings_amount_should_be_PARAMINT:(NSString*) size{
    NSArray* itemlists =[[self getBlockRepo] objectForKey:@"vgitemlistings"];
    [QAAssert assertEqualsExpected:size
                            Actual:[NSString stringWithFormat:@"%i", [itemlists count]]];
}

- (void) vgs_item_listings_should_include_name_PARAM:(NSString*) name{
    NSArray* itemlists = [[self getBlockRepo] objectForKey:@"vgitemlistings"];
    NSString* found = [NSString stringWithFormat:@"not found vgs item listing with name %@", name];
    for (GreeVGItemListing* il in itemlists) {
        if ([[il listingName] isEqualToString:name]){
            found = nil;
        }
    }
    [QAAssert assertNil:found];
}

- (void) developer_uses_SDK_to_load_vgs_item_listing_categories{
    [[self getBlockRepo] removeObjectForKey:@"vgitemlistingCategories"];
    NSArray* itemlistingCategories = [[GreeVirtualGoods sharedInstance] itemListingCategories];
    [[self getBlockRepo] setObject:itemlistingCategories forKey:@"vgitemlistingCategories"];
}

- (void) vgs_item_listing_categories_amount_should_be_PARAMINT:(NSString*) size{
    NSArray* itemlistingCategories = [[self getBlockRepo] objectForKey:@"vgitemlistingCategories"];
    [QAAssert assertEqualsExpected:size
                            Actual:[NSString stringWithFormat:@"%i", [itemlistingCategories count]]];
}

- (void) vgs_item_listing_categories_should_include_category_PARAM:(NSString*) name{
    NSArray* itemlistingCategories = [[self getBlockRepo] objectForKey:@"vgitemlistingCategories"];
    NSString* found = [NSString stringWithFormat:@"not found vgs item listing category with name %@", name];
    for (NSString* ilc in itemlistingCategories) {
        if ([ilc isEqualToString:name]){
            found = nil;
        }
    }
    [QAAssert assertNil:found];
}

- (void) developer_uses_SDK_to_load_vgs_item_listing_category_PARAM:(NSString*) category{
    [[self getBlockRepo] removeObjectForKey:@"vgitemlistings"];
    NSArray* itemlists = [[GreeVirtualGoods sharedInstance] itemListingsInCategory:category];
    [[self getBlockRepo] setObject:itemlists forKey:@"vgitemlistings"];
}

- (void) developer_uses_SDK_to_check_basic_info_of_item_listing_with_name_PARAM:(NSString*) name{
    NSArray* itemlists = [[self getBlockRepo] objectForKey:@"vgitemlistings"];
    [[self getBlockRepo] removeObjectForKey:@"vgitemlisting"];
    
    for (GreeVGItemListing* il in itemlists) {
        if ([[il listingName] isEqualToString:name]){
            [[self getBlockRepo] setObject:il
                                    forKey:@"vgitemlisting"];
            break;
        }
    }
}

- (void) info_PARAM:(NSString*) info _of_vgs_item_listing_PARAM:(NSString*) identifier _should_be_PARAM:(NSString*) content{
    GreeVGItemListing* il = [[self getBlockRepo] objectForKey:@"vgitemlisting"];
    if ([info isEqualToString:@"listingDescription"]) {
        [QAAssert assertEqualsExpected:content
                                Actual:[il listingDescription]];
    }else  if ([info isEqualToString:@"category"]) {
        [QAAssert assertEqualsExpected:content
                                Actual:[il category]];
    }else  if ([info isEqualToString:@"quantity"]) {
        [QAAssert assertEqualsExpected:content
                                Actual:[NSString stringWithFormat:@"%i", [il quantity]]];
    }else  if ([info isEqualToString:@"currencies"]) {
        [QAAssert assertContainsExpected:content
                                Contains:[[il purchaseCurrencies] description]];
    }else  if ([info isEqualToString:@"metadata"]) {
        [QAAssert assertContainsExpected:content
                                Contains:[[il metadata] description]];
    }else{
        [QAAssert assertNotNil:nil];
    }
}

- (void) info_PARAM:(NSString*) info _of_vgs_item_listing_PARAM:(NSString*) name
_and_currency_PARAM:(NSString*) identifier
   _should_be_PARAM:(NSString*) price{
    GreeVGItemListing* il = [[self getBlockRepo] objectForKey:@"vgitemlisting"];
    if ([info isEqualToString:@"priceForCurrency"]) { 
//        [QAAssert assertEqualsExpected:price
//                                Actual:[NSString stringWithFormat:@"%i", [il priceForCurrency:identifier]]];
        NSLog(@"%@", [NSString stringWithFormat:@"%i", [il priceForCurrency:identifier]]);
    }else  if ([info isEqualToString:@"formattedPriceForCurrency"]) {
//        [QAAssert assertEqualsExpected:price
//                                Actual:[il formattedPriceForCurrency:identifier]];
         NSLog(@"%@", [NSString stringWithFormat:@"%@", [il formattedPriceForCurrency:identifier]]);
    }else{
        [QAAssert assertNotNil:nil];
    }
}

@end
