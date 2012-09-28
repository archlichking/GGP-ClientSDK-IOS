//
//  JsKitStepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 8/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BaseJsKitStepDefinition.h"

#import "GreePopup.h"
#import "GreePopupView.h"

#import "Constant.h"
#import "StringUtil.h"
#import "CommandUtil.h"
#import "QAAssert.h"
#import "QALog.h"

@interface GreePopup(PrivateJskitPopupHacking)
- (void)popupViewWebViewDidFinishLoad:(UIWebView*)aWebView;

@end

@implementation GreePopup(PrivateJskitPopupHacking)
- (void)popupViewWebViewDidFinishLoad:(UIWebView*)aWebView{
    QALog(@"%@", [aWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"]);
    [StepDefinition globalNotify];
}

@end



@implementation BaseJsKitStepDefinition

- (void) I_launch_jskit_popup{
    GreePopup* popup = [GreePopup popup];
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", launchJskitPopup], @"command",
                                        popup, @"executor",
                                        nil];
    
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    
    [StepDefinition globalWait];
    
    [[self getBlockRepo] setObject:popup forKey:@"baseJskitPopup"];
}

- (void) I_dismiss_jskit_base_popup{
    GreePopup* popup = [[self getBlockRepo] objectForKey:@"baseJskitPopup"];
    
//    popup.didDismissBlock = ^(id aSender) {
//        [self inStepNotify];
//    };
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", dismissPopup], @"command",
                                        popup, @"executor", 
                                        nil];
    
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    
//    [self inStepWait];
//    [StepDefinition globalWait];
}

- (void) I_dismiss_last_opened_popup{
    GreePopup* popup = [[self getBlockRepo] objectForKey:@"baseJskitPopup"];
    
    //    popup.didDismissBlock = ^(id aSender) {
    //        [self inStepNotify];
    //    };
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", dismissPopup], @"command",
                                        popup, @"executor", 
                                        nil];
    
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    
    //    [self inStepWait];
//    [StepDefinition globalWait]; 
}

- (void) I_dismiss_last_opened_viewControl{
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", dismissViewControl], @"command",
                                        nil];
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    [StepDefinition globalWait]; 
}

- (void) step_sleep:(NSTimeInterval) interval{
    [NSThread sleepForTimeInterval:interval];
}

- (void) invoke_in_jskit_popup_with_full_command:(NSString*) command{
    GreePopup* popup = [[self getBlockRepo] objectForKey:@"baseJskitPopup"];
    
    id resultBlock = ^(NSString* result){
        [self inStepNotify];
    };
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", executeJskitCommandInPopup], @"command",
                                        popup, @"executor",
                                        @"", @"jsKitElement",
                                        command, @"jsKitCommand",
                                        @"", @"jsKitValue",
                                        resultBlock, @"jsKitCallback",
                                        nil];
    
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    
    [self inStepWait];
    [StepDefinition globalWait];
    [popup release];
    
    [self step_sleep:2];
}

- (void) invoke_in_jskit_popup_with_element:(NSString*) element 
                               _and_command:(NSString*) command 
                                 _and_value:(NSString*) value {
    GreePopup* popup = [[self getBlockRepo] objectForKey:@"baseJskitPopup"];
    
    id resultBlock = ^(NSString* result){
        [self inStepNotify];
    };
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", executeJskitCommandInPopup], @"command",
                                        popup, @"executor",
                                        element, @"jsKitElement",
                                        command, @"jsKitCommand",
                                        value, @"jsKitValue",
                                        resultBlock, @"jsKitCallback",
                                        nil];
    
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    
    
//    [StepDefinition globalWait];
    [self inStepWait];
    [popup release];
}

@end
