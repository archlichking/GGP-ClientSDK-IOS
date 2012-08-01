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
    //    NSLog(@"%@", [aWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"]);
    [StepDefinition notifyOutsideStep];
}
@end



@implementation JsKitStepDefinition

- (void) I_load_popup{
}

- (void) I_test_jskit{
}

@end
