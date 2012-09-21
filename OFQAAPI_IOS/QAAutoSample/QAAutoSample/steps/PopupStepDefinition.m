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
#import "GreeWallet.h"
#import "GreeWallet+ExternalUISupport.h"
#import "GreeWalletPaymentItem.h"
#import "GreeWalletProduct.h"
#import "GreeWalletPayment.h"
#import "GreeWalletPaymentPopup.h"
#import "GreeWalletDepositPopup.h"
#import "GreeWalletDepositIAPHistoryPopup.h"
#import "GreeAgreementPopup.h"

#import "Constant.h"
#import "StringUtil.h"
#import "CommandUtil.h"
#import "QAAssert.h"
#import "QALog.h"

// hack did finish load to notify outside
@interface GreeWalletDepositPopup(PrivateDepositetHack)
-(void)popupViewWebViewDidFinishLoad:(UIWebView *)aWebView;
@end

@implementation GreeWalletDepositPopup(PrivateDepositetHack)
-(void)popupViewWebViewDidFinishLoad:(UIWebView *)aWebView{
//    QALog(@"%@", [aWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"]);
    [[StepDefinition getOutsideBlockRepo] setObject:self forKey:@"popup"];
    [StepDefinition notifyOutsideStep];
}
@end

// hack did finish load to notify outside
@interface GreeWalletPaymentPopup(PrivatePaymentHack)
-(void)popupViewWebViewDidFinishLoad:(UIWebView *)aWebView;
@end

@implementation GreeWalletPaymentPopup(PrivatePaymentHack)
-(void)popupViewWebViewDidFinishLoad:(UIWebView *)aWebView{
    if ([self respondsToSelector:@selector(updateBackButtonStateWithWebView:)]) {
        [self performSelector:@selector(updateBackButtonStateWithWebView:) withObject:aWebView];
    }
    if ([self respondsToSelector:@selector(showCloseButton)]) {
        [self performSelector:@selector(showCloseButton)];
    }
//    QALog(@"%@", [aWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"]);
    [[StepDefinition getOutsideBlockRepo] setObject:self forKey:@"popup"];
    [StepDefinition notifyOutsideStep];
}

@end

// hack did finish load to notify outside
@interface GreeWalletDepositIAPHistoryPopup(PrivatePaymentHack)
-(void)popupViewWebViewDidFinishLoad:(UIWebView *)aWebView;
@end

@implementation GreeWalletDepositIAPHistoryPopup(PrivatePaymentHack)
-(void)popupViewWebViewDidFinishLoad:(UIWebView *)aWebView{
//    QALog(@"%@", [aWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"]);
    [[StepDefinition getOutsideBlockRepo] setObject:self forKey:@"popup"];
    [StepDefinition notifyOutsideStep];
}

@end

@interface GreePopup(PrivatePopupHacking)
- (void)popupViewWebViewDidFinishLoad:(UIWebView*)aWebView;
@end

@implementation GreePopup(PrivatePopupHacking)
- (void)popupViewWebViewDidFinishLoad:(UIWebView*)aWebView{
//    QALog(@"%@", [aWebView stringByEvaluatingJavaScriptFromString:@"document.documentElement.outerHTML"]);
    [StepDefinition notifyOutsideStep];
}
@end

// --- end ------------ popup hack

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

// --------begin-----utils
- (void) cleanCallbacks:(GreePopup*) popup{
    popup.didDismissBlock = nil;
    popup.willDismissBlock = nil;
    popup.didLaunchBlock = nil;
    popup.willLaunchBlock = nil;
    popup.completeBlock = nil;
    popup.cancelBlock = nil;
}

//---------end-------utils

- (void) I_execute_js_command_in_popup_PARAM:(NSString*) command{
    
    GreePopup* popup = [[self getBlockRepo] objectForKey:@"popup"];
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", executeJavascriptInPopup], @"command",
                                        popup, @"executor", 
                                        command, @"jsCommand",
                                        nil];
    
    [self notifyMainUIWithCommand:CommandDispatchCommand 
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
    
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    
    [self waitForInStep];
    [StepDefinition waitForOutsideStep];
    
    // reset value to default
    [self cleanCallbacks:popup];
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
    
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    
    [self waitForInStep];
    [StepDefinition waitForOutsideStep];
    
    // reset value to default
    [self cleanCallbacks:popup];
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
    
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    
    
    [self waitForInStep];
    [StepDefinition waitForOutsideStep];
    
    // set value to default
    [self cleanCallbacks:popup];
    
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
    
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    
    [self waitForInStep];
    [StepDefinition waitForOutsideStep];
    
    // set value to default
    [self cleanCallbacks:popup];
    [[self getBlockRepo] setObject:[[NSMutableArray alloc] init] forKey:@"paymentItemList"];
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
    
    [self cleanCallbacks:requestPopup];
    
    // initialize request matrix
    NSDictionary* requestMatrix = [[NSDictionary alloc] initWithObjectsAndKeys: 
                                   @"stringify(fclass('sentence medium minor break-normal'))", @"title",
                                   @"stringify(fclass('sentence medium minor break-normal'))", @"body",
                                   nil];
    
    [[self getBlockRepo] setObject:requestMatrix forKey:@"requestPage"];
    [[self getBlockRepo] setObject:requestPopup forKey:@"popup"];
}

// step definition : i check request popup setting info
- (void) I_check_request_popup_setting_info_PARAM:(NSString*) info{
    GreeRequestServicePopup* requestPopup = [[self getBlockRepo] objectForKey:@"popup"];
    
    NSDictionary* requestMatrix = [[self getBlockRepo] objectForKey:@"requestPage"];
    
    NSString* js = [requestMatrix objectForKey:info];
    
    id resultBlock = ^(NSString* result){
        [[self getBlockRepo] setObject:result forKey:info];
        [self notifyInStep];
    };
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", executeJavascriptInPopup], @"command",
                                        requestPopup, @"executor",
                                        js, @"jsCommand",
                                        resultBlock, @"jsCallback",
                                        nil];
    
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    
    [StepDefinition waitForOutsideStep];
    [self waitForInStep];
    
    [requestPopup release];
}

// step definition : request popup info INFO should be VALUE 
- (NSString*) request_popup_info_PARAM:(NSString*) info 
                      _should_be_PARAM:(NSString*) value{
    
    NSString* jsResult = [[self getBlockRepo] objectForKey:info];
    
    [QAAssert assertContainsExpected:jsResult Contains:value];
    return [NSString stringWithFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@", 
            @"request popup info", 
            value,
            jsResult, 
            SpliterTcmLine];
}

//--- end ----------- request popup

//--- begin --------- invite popup

// step definition : i initialize invite popup with message MSG and callback url URL and users USER1,USER2,USER3
- (void) I_initialize_invite_popup_with_message_PARAM:(NSString*) msg 
                               _and_callback_url_PARAM:(NSString*) cbUrl
                                     _and_users_PARAM:(NSString*) userids{
    NSArray* toUsers = [userids componentsSeparatedByString:@","];
    
    GreeInvitePopup* invitePopup = [GreeInvitePopup popup];
    invitePopup.message = msg;
    invitePopup.callbackURL = [NSURL URLWithString:cbUrl];
    invitePopup.toUserIds = toUsers;
    
    [self cleanCallbacks:invitePopup];
    
    
    NSDictionary* inviteMatrix = [[NSDictionary alloc] initWithObjectsAndKeys: 
                                   @"stringify(fclass('balloon bottom list-item round shrink'))", @"message",
                                   nil];
    
    [[self getBlockRepo] setObject:inviteMatrix forKey:@"invitePage"];
    [[self getBlockRepo] setObject:invitePopup 
                            forKey:@"popup"];
}

// step definition : i check invite popup seeting info INFO
- (void) I_check_invite_popup_setting_info_PARAM:(NSString*) info{
    GreeInvitePopup* invitePopup = [[self getBlockRepo] objectForKey:@"popup"];
    
    NSDictionary* inviteMatrix = [[self getBlockRepo] objectForKey:@"invitePage"];
    
    NSString* js = [inviteMatrix objectForKey:info];
    
    id resultBlock = ^(NSString* result){
        [[self getBlockRepo] setObject:result forKey:info];
        [self notifyInStep];
    };
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", executeJavascriptInPopup], @"command",
                                        invitePopup, @"executor",
                                        js, @"jsCommand",
                                        resultBlock, @"jsCallback",
                                        nil];
    
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    
    [StepDefinition waitForOutsideStep];
    [self waitForInStep];
    [invitePopup release];

}

// step definition : invite popup info INFO should be VALUE
- (NSString*) invite_popup_info_PARAM:(NSString*) info 
                     _should_be_PARAM:(NSString*) value{
    NSString* jsResult = [[self getBlockRepo] objectForKey:info];
    
    [QAAssert assertContainsExpected:jsResult Contains:value];
    return [NSString stringWithFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@", 
            @"request popup info", 
            value,
            jsResult, 
            SpliterTcmLine];
}

//--- end ----------- invite popup

//--- begin --------- share popup

// step definition : i initialize share popup with text TXT
- (void) I_initialize_share_popup_with_text_PARAM:(NSString*) text{
    GreeSharePopup* popup = [GreeSharePopup popup];
    popup.text = text;
    
    [self cleanCallbacks:popup];
    
    NSDictionary* shareMatrix = [[NSDictionary alloc] initWithObjectsAndKeys: 
                                  @"stringify(fid('ggp_share_body'))", @"text",
                                  nil];
    
    [[self getBlockRepo] setObject:shareMatrix forKey:@"sharePage"];
    [[self getBlockRepo] setObject:popup 
                            forKey:@"popup"];
    
}

// step definition : i check share popup setting info INFO
- (void) I_check_share_popup_setting_info_PARAM:(NSString*) info{
    GreeSharePopup* popup = [[self getBlockRepo] objectForKey:@"popup"];
    
    NSDictionary* shareMatrix = [[self getBlockRepo] objectForKey:@"sharePage"];
    
    NSString* js = [shareMatrix objectForKey:info];
    
    id resultBlock = ^(NSString* result){
        [[self getBlockRepo] setObject:result forKey:info];
        [self notifyInStep];
    };
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", executeJavascriptInPopup], @"command",
                                        popup, @"executor",
                                        js, @"jsCommand",
                                        resultBlock, @"jsCallback",
                                        nil];
    
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    
    [StepDefinition waitForOutsideStep];
    [self waitForInStep];
    [popup release];
}

// step definition : share popup info INFO should be VALUE
- (NSString*) share_popup_info_PARAM:(NSString*) info 
                    _should_be_PARAM:(NSString*) value{
    NSString* jsResult = [[self getBlockRepo] objectForKey:info];
    
    [QAAssert assertContainsExpected:jsResult Contains:value];
    return [NSString stringWithFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@", 
            @"request popup info", 
            value,
            jsResult, 
            SpliterTcmLine];
}
//--- end ----------- share popup

//--- begin --------- payment popup

// step definition : I add payment item with ID xx, NAME xx, UNIT_PRICE xx, QUANTITY xx, IMAGE_URL xx and DESCRIPTION xx
- (void) I_add_payment_item_with_ID_PARAM:(NSString*) pid 
                          _and_NAME_PARAM:(NSString*) name 
                     _and_UNITPRICE_PARAM:(NSString*) price 
                      _and_QUANTITY_PARAM:(NSString*) quality 
                      _and_IMAGEURL_PARAM:(NSString*) imageurl 
                   _and_DESCRIPTION_PARAM:(NSString*) description{
    GreeWalletPaymentItem* item = [GreeWalletPaymentItem paymentItemWithItemId:pid 
                                                                      itemName:name 
                                                                     unitPrice:[price integerValue] 
                                                                      quantity:[quality integerValue] 
                                                                      imageUrl:imageurl
                                                                   description:description];
    NSMutableArray* arr = [[self getBlockRepo] objectForKey:@"paymentItemList"];
    if (!arr) {
        arr = [[NSMutableArray alloc] init];
    }
    
    [arr addObject:item];
    
    [[self getBlockRepo] setObject:arr 
                            forKey:@"paymentItemList"];
}

- (void) I_set_payment_popup_message_PARAM:(NSString*) msg{
    [[self getBlockRepo] setObject:msg 
                            forKey:@"message"];
}

// step definition : I did open the payment request popup
- (void) I_did_open_payment_request_popup{
    
    id successBlock = ^ (NSString* paymentId, NSArray* items){
        QALog(@"%@", paymentId);
        // [self notifyInStep];  
    };
    
    id failureBlock = ^ (NSString* paymentId, NSArray* items, NSError* error){
        // [self notifyInStep];  
    };
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", executeInPaymentRequestPopup], @"command",
                                        [[self getBlockRepo] objectForKey:@"paymentItemList"], @"items",
                                        [[self getBlockRepo] objectForKey:@"message"], @"message",
                                        @"http://www.google.com", @"callbackUrl",
                                        successBlock, @"sBlock",
                                        failureBlock, @"fBlock",
                                        nil];
    // set delegate to hack did popup and did dismiss
    
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    [StepDefinition waitForOutsideStep];
    
    GreeWalletPaymentPopup* popup = [[StepDefinition getOutsideBlockRepo] objectForKey:@"popup"];
    [[self getBlockRepo] setObject:popup 
                            forKey:@"popup"];
    
    NSDictionary* paymentRequestMatrix = [[NSDictionary alloc] initWithObjectsAndKeys: 
                                 @"stringify(ftag('title'))", @"popupTitle",
                                 @"stringify(fclass('sentence medium minor'))", @"message",
                                 @"stringify(fclass('solid min'))", @"totalAmount",
                                 @"stringify(fclass('list-item'))", @"payment items",
                                 nil];
    
    [[self getBlockRepo] setObject:paymentRequestMatrix forKey:@"paymentRequestPage"];
}

- (void) I_check_payment_request_popup_info_PARAM:(NSString*) info{
    GreeWalletPaymentPopup* popup = [[self getBlockRepo] objectForKey:@"popup"];
    
    NSDictionary* paymentRequestMatrix = [[self getBlockRepo] objectForKey:@"paymentRequestPage"];
    
    NSString* js = [paymentRequestMatrix objectForKey:info];
    
    id resultBlock = ^(NSString* result){
        [[self getBlockRepo] setObject:result forKey:info];
        [self notifyInStep];
    };
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", executeJavascriptInPopup], @"command",
                                        popup, @"executor",
                                        js, @"jsCommand",
                                        resultBlock, @"jsCallback",
                                        nil];
    
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    
    [self waitForInStep];
    [StepDefinition waitForOutsideStep];
   
}

- (NSString*) payment_request_popup_info_PARAM:(NSString*) info 
                         _should_be_PARAM:(NSString*) value{
    NSString* jsResult = [[self getBlockRepo] objectForKey:info];
    
    [QAAssert assertContainsExpected:jsResult Contains:value];
    return [NSString stringWithFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@", 
            @"payment request popup info", 
            value,
            jsResult, 
            SpliterTcmLine];
}

- (NSString*) payment_request_item_PARAM:(NSString*) name
              _info_PARAM:(NSString*) info 
              _should_be_PARAM:(NSString*) value{
    if ([info isEqualToString:@"IMAGEURL"]) {
        // hack for IMAGEURL now
        return @"";
    }
    NSString* jsResult = [[self getBlockRepo] objectForKey:@"payment items"];
    [QAAssert assertContainsExpected:jsResult Contains:value];
    return [NSString stringWithFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@", 
            @"payment request item info", 
            value,
            jsResult, 
            SpliterTcmLine];
}

//--- end ----------- payment popup

//--- begin --------- deposit popup
// step definition : i did open deposit popup
- (void) I_did_open_deposit_popup{
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", executeInDepositPopup], @"command",
                                        nil];
    // set delegate to hack did popup and did dismiss
    
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    [StepDefinition waitForOutsideStep];
    
    GreeWalletDepositPopup* popup = [[StepDefinition getOutsideBlockRepo] objectForKey:@"popup"];
    [[self getBlockRepo] setObject:popup 
                            forKey:@"popup"];
    
    NSDictionary* depositMatrix = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   @"getText(fid('com.aurorafeint.ofxdev1.currency4'))", @"price of currency4",
                                   @"getText(fid('com.aurorafeint.ofxdev1.currency3'))", @"price of currency3",
                                   @"stringify(fclass('com.aurorafeint.ofxdev1.currency3'))", @"tc amount of current4",
                                   nil];
    
    [[self getBlockRepo] setObject:depositMatrix forKey:@"depositPage"];
}

// step definition : i check deposit popup info INFO
- (void) I_check_deposit_popup_info_PARAM:(NSString*) info{
    GreeWalletDepositPopup* popup = [[self getBlockRepo] objectForKey:@"popup"];
    
    NSDictionary* depositMatrix = [[self getBlockRepo] objectForKey:@"depositPage"];
    
    NSString* js = [depositMatrix objectForKey:info];
    
    id resultBlock = ^(NSString* result){
        [[self getBlockRepo] setObject:result forKey:info];
        [self notifyInStep];
    };
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", executeJavascriptInPopup], @"command",
                                        popup, @"executor",
                                        js, @"jsCommand",
                                        resultBlock, @"jsCallback",
                                        nil];
    
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    
    [self waitForInStep];
    [StepDefinition waitForOutsideStep];
    [popup release];
}

// step definition : deposit popup info INFO should be VALUE
- (NSString*) deposit_popup_info_PARAM:(NSString*) info
                      _should_be_PARAM:(NSString*) value{
    NSString* jsResult = [[self getBlockRepo] objectForKey:info];
    
    [QAAssert assertContainsExpected:jsResult Contains:value];
    return [NSString stringWithFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@", 
            @"deposit popup info", 
            value,
            jsResult, 
            SpliterTcmLine];
}

//--- end ----------- deposit popup

//--- begin --------- deposit history popup
- (void) I_did_open_deposit_history_popup{
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", executeInDepositHistoryPopup], @"command",
                                        nil];
    // set delegate to hack did popup and did dismiss
    
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    [StepDefinition waitForOutsideStep];
    
    GreeWalletDepositIAPHistoryPopup* popup = [[StepDefinition getOutsideBlockRepo] objectForKey:@"popup"];
    [[self getBlockRepo] setObject:popup 
                            forKey:@"popup"];
    
    NSDictionary* depositHistoryMatrix = [[NSDictionary alloc] initWithObjectsAndKeys: 
                                          @"stringify(fid('collation-button'))", @"collation button",
                                          nil];
    
    [[self getBlockRepo] setObject:depositHistoryMatrix forKey:@"depositHistoryPage"];
}

- (void) I_check_deposit_history_popup_info_PARAM:(NSString*) info{
    GreeWalletDepositIAPHistoryPopup* popup = [[self getBlockRepo] objectForKey:@"popup"];
    
    NSDictionary* depositHistoryMatrix = [[self getBlockRepo] objectForKey:@"depositHistoryPage"];
    
    NSString* js = [depositHistoryMatrix objectForKey:info];
    
    id resultBlock = ^(NSString* result){
        [[self getBlockRepo] setObject:result forKey:info];
        [self notifyInStep];
    };
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        [NSString stringWithFormat:@"%i", executeJavascriptInPopup], @"command",
                                        popup, @"executor",
                                        js, @"jsCommand",
                                        resultBlock, @"jsCallback",
                                        nil];
    
    [self notifyMainUIWithCommand:CommandDispatchCommand 
                           object:userinfoDic];
    
    [self waitForInStep];
    [StepDefinition waitForOutsideStep];
    [popup release];
}

- (NSString*) deposit_history_popup_info_PARAM:(NSString*) info
                              _should_be_PARAM:(NSString*) value{
    NSString* jsResult = [[self getBlockRepo] objectForKey:info];
    
    [QAAssert assertContainsExpected:jsResult Contains:value];
    return [NSString stringWithFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@", 
            @"deposit history popup info", 
            value,
            jsResult, 
            SpliterTcmLine];
}

//--- end ----------- deposit history popup

//--- begin --------- agreement popup

//--- end ----------- agreement popup

@end
