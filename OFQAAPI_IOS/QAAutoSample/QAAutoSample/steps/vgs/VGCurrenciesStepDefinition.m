//
//  VGCurrenciesStepDefinition.m
//  QAAutoSample
//
//  Created by zhu lei on 11/20/12.
//  Copyright (c) 2012 OFQA. All rights reserved.
//

#import "VGCurrenciesStepDefinition.h"

#import "GreeVirtualGoods.h"
#import "GreeVGCurrency.h"
#import "GreeVGCurrencyListing.h"

#import "QAAssert.h"

@implementation VGCurrenciesStepDefinition

- (void) developer_uses_SDK_to_load_vgs_currencies{
    [[self getBlockRepo] removeObjectForKey:@"vgcurrencies"];
    NSArray* currencies = [[GreeVirtualGoods sharedInstance] currencies];
    [[self getBlockRepo] setObject:currencies forKey:@"vgcurrencies"];
}

- (void) developer_uses_SDK_to_load_vgs_currency_with_identifier_PARAM:(NSString*) identifier{
    [[self getBlockRepo] removeObjectForKey:@"vgcurrency"];
    GreeVGCurrency* c = [[GreeVirtualGoods sharedInstance] currencyWithIdentifier:identifier];
    [[self getBlockRepo] setObject:c forKey:@"vgcurrency"];
}

- (void) developer_uses_SDK_to_load_vgs_currency_listings{
    [[self getBlockRepo] removeObjectForKey:@"vgcurrenylistings"];
    NSArray* currencylistings = [[GreeVirtualGoods sharedInstance] currencyListings];
    [[self getBlockRepo] setObject:currencylistings forKey:@"vgcurrenylistings"];
}

- (void) developer_uses_SDK_to_load_vgs_currency_listings_with_category_PARAM:(NSString*) category{
    [[self getBlockRepo] removeObjectForKey:@"vgcurrenylistings"];
    NSArray* currencylistings = [[GreeVirtualGoods sharedInstance] currencyListingsInCategory:category];
    [[self getBlockRepo] setObject:currencylistings forKey:@"vgcurrenylistings"];
}

- (void) developer_uses_SDK_to_load_vgs_currency_listing_categories{
    [[self getBlockRepo] removeObjectForKey:@"vgcurrenylistingCategories"];
    NSArray* currencylistingCategories = [[GreeVirtualGoods sharedInstance] currencyListingCategories];
    [[self getBlockRepo] setObject:currencylistingCategories forKey:@"vgcurrenylistingCategories"];
}

- (void) vgs_currencies_amount_should_be_PARAMINT:(NSString*) size{
    NSArray* currencies = [[self getBlockRepo] objectForKey:@"vgcurrencies"];
    [QAAssert assertEqualsExpected:size
                            Actual:[NSString stringWithFormat:@"%i", [currencies count]]];
}

- (void) vgs_currencies_should_include_name_PARAM:(NSString*) name{
    NSArray* currencies = [[self getBlockRepo] objectForKey:@"vgcurrencies"];
    NSString* found = [NSString stringWithFormat:@"not found vgs currency with name %@", name];
    for (GreeVGCurrency* c in currencies) {
        if ([[c currencyName] isEqualToString:name]){
            found = nil;
        }
    }
    [QAAssert assertNil:found];
}

- (void) info_PARAM:(NSString*) info _of_currency_PARAM:(NSString*) identifier
   _should_be_PARAM:(NSString*) content{
    GreeVGCurrency* c = [[self getBlockRepo] objectForKey:@"vgcurrency"];
    if ([info isEqualToString:@"currencyName"]) {
        [QAAssert assertEqualsExpected:content Actual:[c currencyName]];
    }else if([info isEqualToString:@"currencyDescription"]){
        [QAAssert assertEqualsExpected:content Actual:[c currencyDescription]];
    }else{
        [QAAssert assertNotNil:nil];
    }
}

- (void) vgs_currency_listings_amount_should_be_PARAMINT:(NSString*) size{
    NSArray* currencylistings = [[self getBlockRepo] objectForKey:@"vgcurrenylistings"];
    [QAAssert assertEqualsExpected:size
                            Actual:[NSString stringWithFormat:@"%i", [currencylistings count]]];
}

- (void) vgs_currency_listings_should_include_currency_PARAM:(NSString*) name{
    NSArray* currencylistings = [[self getBlockRepo] objectForKey:@"vgcurrenylistings"];
    NSString* found = [NSString stringWithFormat:@"not found vgs currency listing with name %@", name];
    for (GreeVGCurrencyListing* cl in currencylistings) {
        if ([[cl listingName] isEqualToString:name]){
            found = nil;
        }
    }
    [QAAssert assertNil:found];
}

- (void) vgs_currency_listing_categories_amount_should_be_PARAMINT:(NSString*) size{
    NSArray* currencylistingCategories = [[self getBlockRepo] objectForKey:@"vgcurrenylistingCategories"];
    [QAAssert assertEqualsExpected:size
                            Actual:[NSString stringWithFormat:@"%i", [currencylistingCategories count]]];
}

- (void) vgs_currency_listing_categories_should_include_category_PARAM:(NSString*) name{
    NSArray* currencylistingCategories = [[self getBlockRepo] objectForKey:@"vgcurrenylistingCategories"];
    NSString* found = [NSString stringWithFormat:@"not found vgs currency listing category with name %@", name];
    for (NSString* clc in currencylistingCategories) {
        if ([clc isEqualToString:name]){
            found = nil;
        }
    }
    [QAAssert assertNil:found];

}

@end
