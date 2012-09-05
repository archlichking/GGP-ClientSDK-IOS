//
//  AddonStepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 9/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddonStepDefinition.h"

#import "NSString+GreeAdditions.h"

#import "QAAssert.h"

@implementation AddonStepDefinition

// step definition: i get hex string from binary string STR
- (void) I_get_hex_string_from_binary_string_PARAM:(NSString*) str{
    NSData* d = [str greeHexStringFormatInBinary];
    [[self getBlockRepo] setObject:d forKey:@"hex_string"];
}

// step definition: hex string should not be nil
- (void) hex_string_should_not_be_nil{
    NSData* d = [[self getBlockRepo] objectForKey:@"hex_string"];
    [QAAssert assertNotNil:d];
    [[self getBlockRepo] removeObjectForKey:@"hex_string"];
}

// step definition: i get normalized string length of string STR
- (void) I_get_normalized_string_length_of_string_PARAM:(NSString*) str{
    NSInteger length = [str greeTextLengthGreeNormalized];
    [[self getBlockRepo] setObject:[NSNumber numberWithInteger:length] 
                            forKey:@"string_length"];
}

// step definition: string length should be L
- (void) string_length_should_be_PARAMINT:(NSString*) length{
    NSNumber* l = [[self getBlockRepo] objectForKey:@"string_length"];
    [QAAssert assertEqualsExpected:length
                            Actual:[l stringValue]];
    [[self getBlockRepo] removeObjectForKey:@"string_length"];
}

// step definition: i remove html tag with string STR
- (void) I_remove_html_tag_with_string_PARAM:(NSString*) str{
    NSString* s = [str stringByRemoveHtmlTags];
    [[self  getBlockRepo] setObject:s forKey:@"gree_string"];
}

// step definition: string result should be STR
- (void) string_result_should_be_PARAM:(NSString*) str{
    NSString* s = [[self getBlockRepo] objectForKey:@"gree_string"];
    [QAAssert assertEqualsExpected:str Actual:s];
    [[self getBlockRepo] removeObjectForKey:@"gree_string"];
}

// step definition: I replace localized string STR with key K and value V
- (void) I_replace_localized_string_PARAM:(NSString*) str 
                          _with_key_PARAM:(NSString*) key 
                         _and_value_PARAM:(NSString*) value{
    NSString* s = [str greeStringByReplacingHtmlLocalizedStringWithKey:key 
                                                            withString:value];
    [[self  getBlockRepo] setObject:s forKey:@"gree_string"];
}

// step definition: I decode html element entries with string STR
- (void) I_decode_html_element_entries_with_string_PARAM:(NSString*) str{
    NSString* s = [str stringByDecodingHTMLEntities];
    [[self  getBlockRepo] setObject:s forKey:@"gree_string"];
}
@end
