//
//  LogJsKitStepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LogJsKitStepDefinition.h"

#import "GreePlatform.h"
#import "GreeLogger.h"
#import "GreeSettings.h"

#import "QAAssert.h"
#import "StringUtil.h"
#import "Constant.h"

@implementation LogJsKitStepDefinition

// expose 
- (void) I_launch_jskit_popup{
    [super I_launch_jskit_popup];
}

- (void) I_dismiss_jskit_base_popup{
    [super I_dismiss_jskit_base_popup];
}

- (void) I_click_invoke_button_PARAM:(NSString*) type{
    NSString* command = @"click";
    NSString* element = [NSString stringWithFormat:@"fid('%@')", type];
    
    [self invoke_in_jskit_popup_with_element:element 
                                _and_command:command 
                                  _and_value:@""];
    [self step_sleep:2];
}

- (void) I_need_to_wait_for_test_done_PARAM:(NSString*) type{
    GreeSettings* st = [[GreePlatform sharedInstance] settings];
    NSString* result = [st objectValueForSetting:@"jskitTestDone"];
    while (!result || ![result isEqualToString:@"true"]) {
        result = [st objectValueForSetting:@"jskitTestDone"];
        [NSThread sleepForTimeInterval:2];
    }
    NSLog(@"jskit test done %@", result);

    // reset @"jskitTestDone" to false
    NSDictionary* dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"false", @"jskitTestDone",
                nil];
    
    [st applySettingDictionary:dic];
    [self step_sleep:2];
}

- (void) I_set_jskit_log_level_to_PARAM:(NSString*) level{
//    NSString* element = @"";
//    switch ([level intValue]) {
//        case 0:
//            element = @"fid('logleval_id0')";
//            break;
//        case 50:
//            element = @"fid('logleval_id1')";
//            break;
//        case 100:
//            element = @"fid('logleval_id2')";
//            break;
//        default:
//            break;
//    }
//    
//    [self invoke_in_jskit_popup_with_element:element
//                                _and_command:@"check"
//                                  _and_value:@""];
    
    
    NSString* fullCommand = [NSString stringWithFormat:@"proton.app.startLog({'loglevel' : '%@'}, function(ret) {stepCallback('%@')})", level, @"start log"];
    [self invoke_in_jskit_popup_with_full_command:fullCommand];
}

- (void) I_stop_jskit_log_level_with_PARAM:(NSString*) level{
    NSString* fullCommand = [NSString stringWithFormat:@"proton.app.stopLog({'loglevel' : '%@'}, function(ret) {stepCallback('%@')})", level, @"stop log"];
//    NSString* fullCommand = [NSString stringWithFormat:@"proton.app.getConfig({'key' : 'serverFrontendOs'}, function(ret) {stepCallback(JSON.stringify(ret))})"];
    [self invoke_in_jskit_popup_with_full_command:fullCommand];
}

- (NSString*) jskit_log_level_should_be_PARAM:(NSString*) l{
    NSInteger d = [[GreePlatform sharedInstance].logger level];
    [QAAssert assertEqualsExpected:l 
                            Actual:[NSString stringWithFormat:@"%i", d]];
    return [NSString stringWithFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@", 
            @"log level", 
            l,
            [NSString stringWithFormat:@"%i", d], 
            SpliterTcmLine];
}

// set/get config
- (void) I_set_jskit_config_with_key_PARAM:(NSString*) jsKey 
                          _and_value_PARAM:(NSString*) jsValue{
     NSString* fullCommand = [NSString stringWithFormat:@"proton.app.setConfig({'key' : '%@', 'value':'%@'}, function(ret) {stepCallback('%@')})", jsKey, jsValue, @"set config"];
    [self invoke_in_jskit_popup_with_full_command:fullCommand];
}

- (void) I_get_jskit_config_value_with_key_PARAM:(NSString*) jsKey{
    NSString* fullCommand = [NSString stringWithFormat:@"proton.app.getConfig({'key' : '%@'}, function(ret) {stepCallback('%@')})", jsKey, @"get config"];
    [self invoke_in_jskit_popup_with_full_command:fullCommand];
}

- (void) jskit_config_with_key_PARAM:(NSString*) jsKey 
                    _should_be_PARAM:(NSString*) jsValue{
    GreeSettings* st = [[GreePlatform sharedInstance] settings];
    NSString* result = [st objectValueForSetting:jsKey];
    [QAAssert assertEqualsExpected:jsValue 
                            Actual:result];
}


@end
