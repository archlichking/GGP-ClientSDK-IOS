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

#import "QAAssert.h"
#import "StringUtil.h"
#import "Constant.h"

@implementation LogJsKitStepDefinition

// expose 
- (void) I_launch_jskit_popup{
    [super I_launch_jskit_popup];
}

- (void) I_dismiss_jskit_popup{
    [super I_dismiss_jskit_popup];
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
    
    
    NSString* fullCommand = [NSString stringWithFormat:@"proton.app.startLog({'loglevel' : '%@'}, function(ret) {window.alert('')})", level];
    
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

@end
