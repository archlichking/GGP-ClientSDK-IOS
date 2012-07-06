//
//  PopupStepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PopupStepDefinition.h"

#import <QuartzCore/QuartzCore.h>

#import "GreePopup.h"

#import "Constant.h"
#import "CommandUtil.h"
#import "QAAssert.h"

@interface GreePopup(PrivatePopupHacking)
- (void)popupViewWebViewDidFinishLoad:(UIWebView*)aWebView;
@end

@implementation GreePopup(PrivatePopupHacking)
- (void)popupViewWebViewDidFinishLoad:(UIWebView*)aWebView{
    NSLog(@"%@", [aWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"]);
    [StepDefinition notifyOutsideStep];
}
@end

NSString* const JsBaseCommand = @"var STEP_TIMEOUT=250;function hl(e){var d=e.style.outline;e.style.outline='#FDFF47 solid';setTimeout(function(){e.style.outline=d;},STEP_TIMEOUT);}function fid(id){return document.getElementById(id);}function fclass(clazz){return document.getElementsByClassName(clazz)[0];}function ftag(g,t){var e=document.getElementsByTagName(g);for(var i=0;i<e.length;i++){if(e[i].innerText.indexOf(t)!=-1){return e[i];}}}function click(e){var t=document.createEvent('HTMLEvents');t.initEvent('click',false,false);setTimeout(function(){hl(e);setTimeout(function(){e.dispatchEvent(t);},STEP_TIMEOUT);},STEP_TIMEOUT);}function setText(e,t){setTimeout(function(){hl(e);setTimeout(function(){e.value=t;},STEP_TIMEOUT);},STEP_TIMEOUT);}function getText(e){var r=e.value;if(r===''||typeof(r)=='undefined'){r=e.innerText;}hl(e);return r;}";

@implementation PopupStepDefinition

- (void) I_make_screenshot_of_current_popup{
    GreeRequestServicePopup* requestPopup = [[self getBlockRepo] objectForKey:@"requestPopup"];
    
    UIView* viewForScreenShot = (UIView*)requestPopup.popupView;
    UIGraphicsBeginImageContext(viewForScreenShot.layer.visibleRect.size);
    [viewForScreenShot.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *actImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [[self getBlockRepo] setObject:actImage 
                            forKey:@"screenshot"];
}


- (NSString*) wrapJsCommand:(NSString*) command{
    return [NSString stringWithFormat:@"(function(){%@ return(%@)})()", JsBaseCommand, command];
}



- (void) I_execute_js_command_in_popup_PARAM:(NSString*) command{
    NSLog(@"starting command %@", command);
    
    GreePopup* popup = [[self getBlockRepo] objectForKey:@"popup"];
    
    NSString* js = [self wrapJsCommand:command];
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", executeJavascriptInPopup], @"command",
                                        popup, @"executor", 
                                        js, @"jsCommand",
                                        nil];
    
    [self notifyMainUIWithCommand:CommandDispatchPopupCommand 
                           object:userinfoDic];
    
    [StepDefinition waitForOutsideStep];
}

//--- begin ----------- common popup

// step definition : i will open popup
- (void) I_will_open_popup{
    GreePopup* popup = [[self getBlockRepo] objectForKey:@"popup"];
    popup.willLaunchBlock = ^(id aSender) {
        [[self getBlockRepo] setObject:@"1" forKey:@"willLaunchMark"];
        [self notifyInStep];
    };
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", launchPopup], @"command",
                                        popup, @"executor", 
                                        nil];
    
    [self notifyMainUIWithCommand:CommandDispatchPopupCommand 
                           object:userinfoDic];
    
    [self waitForInStep];
    [StepDefinition waitForOutsideStep];
    
    // reset value to default
    popup.willLaunchBlock = nil;
}

// step definition : i did open popup
- (void) I_did_open_popup{
    GreePopup* popup = [[self getBlockRepo] objectForKey:@"popup"];
    
    popup.didLaunchBlock = ^(id aSender) {
        [[self getBlockRepo] setObject:@"1" forKey:@"didLaunchMark"];
        [self notifyInStep];
    };
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", launchPopup], @"command",
                                        popup, @"executor", 
                                        nil];
    
    [self notifyMainUIWithCommand:CommandDispatchPopupCommand 
                           object:userinfoDic];
    
    [self waitForInStep];
    [StepDefinition waitForOutsideStep];
    
    // reset value to default
    popup.didLaunchBlock = nil;
}

// step definition : i will dismiss popup
- (void) I_will_dismiss_popup{
    GreePopup* popup = [[self getBlockRepo] objectForKey:@"popup"];

    popup.willDismissBlock = ^(id aSender) {
        [[self getBlockRepo] setObject:@"1" forKey:@"willDismissMark"];
        [self notifyInStep];
    };
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", dismissPopup], @"command",
                                        popup, @"executor", 
                                        nil];
    
    [self notifyMainUIWithCommand:CommandDispatchPopupCommand 
                           object:userinfoDic];
    
    [self waitForInStep];
    [StepDefinition waitForOutsideStep];
    
    // set value to default
    popup.willDismissBlock = nil;
    
}

// step definition : i did dismiss popup
- (void) I_did_dismiss_popup{
    GreePopup* popup = [[self getBlockRepo] objectForKey:@"popup"];
    
    popup.didDismissBlock = ^(id aSender) {
        [[self getBlockRepo] setObject:@"1" forKey:@"didDismissMark"];
        [self notifyInStep];
    };
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", dismissPopup], @"command",
                                        popup, @"executor", 
                                        nil];
    
    [self notifyMainUIWithCommand:CommandDispatchPopupCommand 
                           object:userinfoDic];
    
    
    [StepDefinition waitForOutsideStep];
    [self waitForInStep];
    
    // set value to default
    popup.didDismissBlock = nil;
}

// step definition : popup will open callback should be fired within second SEC
- (void) popup_will_open_callback_should_be_fired_within_seconds_PARAMINT:(NSString*) seconds{
    NSString* mark = [[self getBlockRepo] objectForKey:@"willLaunchMark"];
    [QAAssert assertEqualsExpected:@"1" 
                            Actual:mark];
    [[self getBlockRepo] setObject:@"0" forKey:@"willLaunchMark"];
}

// step definition : popup did open callback should be fired within second SEC
- (void) popup_did_open_callback_should_be_fired_within_seconds_PARAMINT:(NSString*) seconds{
    NSString* mark = [[self getBlockRepo] objectForKey:@"didLaunchMark"];
    [QAAssert assertEqualsExpected:@"1" 
                            Actual:mark];
    [[self getBlockRepo] setObject:@"0" forKey:@"didLaunchMark"];
}

// step definition : popup will dismiss callback should be fired within second SEC
- (void) popup_will_dismiss_callback_should_be_fired_within_seconds_PARAMINT:(NSString*) seconds{
    NSString* mark = [[self getBlockRepo] objectForKey:@"willDismissMark"];
    [QAAssert assertEqualsExpected:@"1" 
                            Actual:mark];
    [[self getBlockRepo] setObject:@"0" forKey:@"willDismissMark"];

}

// step definition : popup did dismiss callback should be fired within second SEC
- (void) popup_did_dismiss_callback_should_be_fired_within_seconds_PARAMINT:(NSString*) seconds{
    NSString* mark = [[self getBlockRepo] objectForKey:@"didDismissMark"];
    [QAAssert assertEqualsExpected:@"1" 
                            Actual:mark];
    [[self getBlockRepo] setObject:@"0" forKey:@"didDismissMark"];
    
}

// step definition : popup complete callback should be fired within second SEC
- (void) popup_complete_callback_should_be_fired_within_seconds_PARAMINT:(NSString*) seconds{
    NSString* mark = [[self getBlockRepo] objectForKey:@"completeMark"];
    [QAAssert assertEqualsExpected:@"1" 
                            Actual:mark];
}

//--- end ------------ common popup 

//--- begin ----------- request popup

// step definition : i initialize request popup with title TITLE and body BODY
- (void) I_initialize_request_popup_with_title_PARAM:(NSString*) title 
                                     _and_body_PARAM:(NSString*) body;{
    // initialize request popup
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       title, GreeRequestServicePopupTitle, 
                                       body, GreeRequestServicePopupBody,
                                       nil];
    GreeRequestServicePopup* requestPopup = [GreeRequestServicePopup popupWithParameters:parameters];
    
    requestPopup.didLaunchBlock = nil;
    requestPopup.willDismissBlock = nil;
    requestPopup.willLaunchBlock = nil;
    requestPopup.didDismissBlock = nil;
    
    [[self getBlockRepo] setObject:requestPopup forKey:@"popup"];
}

// step definition : i check request popup setting info
- (void) I_check_request_popup_setting_info_PARAM:(NSString*) info{
    GreeRequestServicePopup* requestPopup = [[self getBlockRepo] objectForKey:@"requestPopup"];
    
    NSString* js = [self wrapJsCommand:@"getText(fclass('sentence medium minor break-normal'))"];
    
    id resultBlock = ^(NSString* result){
        [[self getBlockRepo] setObject:result forKey:@"jsResult"];
        [self notifyInStep];
    };
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", executeJavascriptInPopup], @"command",
                                        requestPopup, @"executor", 
                                        js, @"jsCommand",
                                        resultBlock, @"jsCallback",
                                        nil];
    
    [self notifyMainUIWithCommand:CommandDispatchPopupCommand 
                           object:userinfoDic];
    
    [StepDefinition waitForOutsideStep];
    [self waitForInStep];
}

// step definition : request popup info INFO should be VALUE 
- (NSString*) request_popup_info_PARAM:(NSString*) info 
                      _should_be_PARAM:(NSString*) value{
    NSString* jsResult = [[self getBlockRepo] objectForKey:@"jsResult"];
    return jsResult;
}

//--- end ----------- request popup

@end
