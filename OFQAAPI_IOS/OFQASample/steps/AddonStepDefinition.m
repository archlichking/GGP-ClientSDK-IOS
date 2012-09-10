//
//  AddonStepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 9/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AddonStepDefinition.h"

#import "NSString+GreeAdditions.h"
#import "NSObject+GreeAdditions.h"
#import "UIImage+GreeAdditions.h"

#import "QAAssert.h"
#import "StringUtil.h"

@implementation AddonStepDefinition

//--- begin: NSString+GreeAdditions ------------

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

//--- end: NSString+GreeAdditions ------------

- (void) executeBlock:(void(^)(void)) block{
    NSObject* o = [[NSObject alloc] init];
    [o performBlock:block afterDelay:0];
    [o release];
}

//--- begin: NSObject+GreeAdditions ----------
- (void) I_execute_block_in_NSObject{
    id executeBlock = ^(void){
        [[self getBlockRepo] setObject:@"1" forKey:@"block_execution"];
        [self notifyInStep];
    };
    [self performSelectorOnMainThread:@selector(executeBlock:) withObject:executeBlock waitUntilDone:YES]; 
    
    [self waitForInStep];
}

- (void) block_should_be_executed{
    NSString* s = [[self getBlockRepo] objectForKey:@"block_execution"];
    [QAAssert assertEqualsExpected:@"1" Actual:s];
    [[self  getBlockRepo] setObject:s forKey:@"block_execution"];
}
//--- end: NSObject+GreeAdditions --------------

//--- begin: UIImage+GreeAdditions -------------
- (void) I_resize_image_with_name_PARAM:(NSString*) n 
                       _to_height_PARAM:(NSString*) h 
                       _and_width_PARAM:(NSString*) w
              _with_rotation_mark_PARAM:(NSString*) r{
    NSArray* array = [StringUtil splitStepsFrom:n by:@"."];
    NSString* imageName = [[NSBundle mainBundle] pathForResource:[array objectAtIndex:0] ofType:[array objectAtIndex:1]];
    UIImage* img = [[UIImage alloc] initWithContentsOfFile:imageName];
    UIImage* i = nil;
    if (r == 0) {
        i = [UIImage greeResizeImage:img maxPixel:img.size.height - 10];
    }else{
        i = [UIImage greeResizeImage:img maxPixel:img.size.height - 10 rotation:[r intValue]];
    }
    [[self getBlockRepo] setObject:i forKey:@"gree_image"];
}

- (void) image_should_be_of_height_PARAM:(NSString*) h 
                        _and_width_PARAM:(NSString*) w{
    UIImage* i = [[self getBlockRepo] objectForKey:@"gree_image"];
    [QAAssert assertEqualsExpected:[NSString stringWithFormat:@"%0.f", i.size.height] Actual:h];
    [QAAssert assertEqualsExpected:[NSString stringWithFormat:@"%0.f", i.size.width] Actual:w];
    [[self getBlockRepo] removeObjectForKey:@"gree_image"];
}

- (void) I_get_base64_string_of_image_PARAM:(NSString*) n{
    NSArray* array = [StringUtil splitStepsFrom:n by:@"."];
    NSString* imageName = [[NSBundle mainBundle] pathForResource:[array objectAtIndex:0] ofType:[array objectAtIndex:1]];
    UIImage* img = [[UIImage alloc] initWithContentsOfFile:imageName];
    NSString* s = [img greeBase64EncodedString];
    [[self getBlockRepo] setObject:s forKey:@"image_string"];
}
- (void) base64_string_should_not_be_nil{
    NSString* s = [[self getBlockRepo] objectForKey:@"image_string"];
    [QAAssert assertNotNil:s];
    [[self getBlockRepo] removeObjectForKey:@"image_string"];
}


- (void) I_get_app_icon_close_to_width_PARAM:(NSString*) w{
    UIImage* i = [UIImage greeAppIconNearestWidth:[w integerValue]];
    if (i) {
        [[self getBlockRepo] setObject:i forKey:@"gree_image"];
    }
}

- (void) app_icon_width_should_be_PARAM:(NSString*) w{
    UIImage* i = [[self getBlockRepo] objectForKey:@"gree_image"];
    if (i) {
        NSLog(@"%@", [NSString stringWithFormat:@"%.0f", i.size.height]);
//        [QAAssert assertEqualsExpected:w Actual:[NSString stringWithFormat:@"%0.f", i.size.width]];
        [[self getBlockRepo] removeObjectForKey:@"gree_image"];
    }  
}
//--- end: UIImage+GreeAdditions --------------
@end
