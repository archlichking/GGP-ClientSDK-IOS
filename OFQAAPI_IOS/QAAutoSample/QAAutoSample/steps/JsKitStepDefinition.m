//
//  JsKitStepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 8/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JsKitStepDefinition.h"

#import "GreePopup.h"

#import "Constant.h"
#import "StringUtil.h"
#import "CommandUtil.h"
#import "QAAssert.h"

@interface GreePopup(PrivatePopupHacking)
- (void)popupViewWebViewDidFinishLoad:(UIWebView*)aWebView;
@end

@implementation GreePopup(PrivatePopupHacking)
- (void)popupViewWebViewDidFinishLoad:(UIWebView*)aWebView{
    //    QALog(@"%@", [aWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"]);
    [StepDefinition globalNotify];
}
@end



@implementation JsKitStepDefinition

- (void) I_load_jskit_popup{
    GreePopup* popup = [GreePopup popup];
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", launchJskitPopup], @"command",
                                        popup, @"executor",
                                        nil];
    
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    
    [StepDefinition globalWait];
}

- (void) I_test_jskit{
    
}

@end
