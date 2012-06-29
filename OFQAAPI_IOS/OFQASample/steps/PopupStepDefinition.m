//
//  PopupStepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 6/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PopupStepDefinition.h"
#import "GreePopup.h"
#import "Constant.h"

@interface GreePopup(PrivatePopupHacking)
- (void)popupViewWebViewDidFinishLoad:(UIWebView*)aWebView;
@end

@implementation GreePopup(PrivatePopupHacking)
- (void)popupViewWebViewDidFinishLoad:(UIWebView*)aWebView{
    NSString *htmlContents = [aWebView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName(\"body\")[0].innerHTML"];
    NSLog(@"%@", htmlContents);
    [StepDefinition notifyOutsideStep];
}
@end



@implementation PopupStepDefinition

- (void) I_open_request_popup{
    // initialize request popup
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"iMac rocks in Diablo3", GreeRequestServicePopupTitle, 
                                       @"and Monk rules them all", GreeRequestServicePopupBody,
                                       @"test type", GreeRequestServicePopupListType,
                                       nil];
    
    GreeRequestServicePopup* requestPopup = [GreeRequestServicePopup popup];
    [requestPopup setParameters:parameters];
    requestPopup.didLaunchBlock = ^(id aSender) {
        NSLog(@"page popup done");
        UIWebView* view = [requestPopup.popupView valueForKeyPath:@"webView"];
        NSString* pageC = [view stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
        NSLog(@"%@", pageC);
        [self notifyInStep];
    };
    requestPopup.didDismissBlock = ^(id aSender) {
        NSLog(@"page dismissed");
    };
    //    requestPopup.completeBlock = ^(id aSender) {
    //        UIWebView* view = [requestPopup.popupView valueForKeyPath:@"webView"];
    //        NSString* pageC = [view stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML"];
    //        NSLog(@"%@", pageC);
    //        NSLog(@"page content loaded");
    //    };
    // save request popup
    [[self getBlockRepo] setObject:requestPopup forKey:@"requestPopup"];
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        requestPopup, @"popup",
                                        nil];
    
    [self notifyMainUIWithCommand:CommandNotifyLoadPopup
                           object:userinfoDic];
    
    [self waitForInStep];
}

- (void) I_execute_command_in_request_popup_PARAM:(NSString*) command{
    [StepDefinition waitForOutsideStep];
    GreeRequestServicePopup* requestPopup = [[self getBlockRepo] objectForKey:@"requestPopup"];
    
//    NSString* com = @"(function(){function fid(id){return document.getElementById(id);}function click(e){var t=document.createEvent('HTMLEvents');t.initEvent('click',false,false);e.dispatchEvent(t);}return(click(fid('btn-msg-choosed')))})()";
    NSString* com = @"(function(){var STEP_TIMEOUT=250;function hl(e){var d=e.style.outline;e.style.outline='#FDFF47 solid';setTimeout(function(){e.style.outline=d},STEP_TIMEOUT)}function fid(id){return document.getElementById(id)}function click(e){var t=document.createEvent('HTMLEvents');t.initEvent('click',false,false);e.dispatchEvent(t)}return(hl(fid('btn-msg-choosed')))})()";
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        com, CommandJSPopupCommand, 
                                        requestPopup, @"popup",
                                        nil];
    
    [self notifyMainUIWithCommand:CommandNotifyExecuteCommandInPopup 
                           object:userinfoDic];
}

- (void) I_close_request_popup{
    GreeRequestServicePopup* requestPopup = [[self getBlockRepo] objectForKey:@"requestPopup"];
 
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        requestPopup, @"popup", 
                                        nil];
    
    [self notifyMainUIWithCommand:CommandNotifyDismissPopup 
                           object:userinfoDic];
}



@end
