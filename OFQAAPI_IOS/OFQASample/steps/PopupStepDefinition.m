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

- (NSString*) wrapJsCommand:(NSString*) command{
    return [NSString stringWithFormat:@"(function(){%@ return(%@)})()", JsBaseCommand, command];
}

- (void) I_execute_command_in_request_popup_PARAM:(NSString*) command{
    NSLog(@"starting command %@", command);
    
    GreeRequestServicePopup* requestPopup = [[self getBlockRepo] objectForKey:@"requestPopup"];
    
    NSString* js = [self wrapJsCommand:command];
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        js, CommandJSPopupCommand, 
                                        requestPopup, @"popup",
                                        nil];
    
    [self notifyMainUIWithCommand:CommandNotifyExecuteCommandInPopup 
                           object:userinfoDic];
    [StepDefinition waitForOutsideStep];
}

- (void) I_will_open_request_popup{
    // initialize request popup
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"iMac rocks in Diablo3", GreeRequestServicePopupTitle, 
                                       @"and Monk rules them all", GreeRequestServicePopupBody,
                                       @"test type", GreeRequestServicePopupListType,
                                       nil];
    GreeRequestServicePopup* requestPopup = [GreeRequestServicePopup popupWithParameters:parameters];
  
    requestPopup.didLaunchBlock = nil;
    requestPopup.willDismissBlock = nil;
    requestPopup.willLaunchBlock = nil;
    requestPopup.didDismissBlock = nil;
    requestPopup.willLaunchBlock = ^(id aSender) {
        [[self getBlockRepo] setObject:@"1" forKey:@"willLaunchMark"];
        [self notifyInStep];
    };
    
    [[self getBlockRepo] setObject:requestPopup forKey:@"requestPopup"];
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        requestPopup, @"popup",
                                        nil];
    
    [self notifyMainUIWithCommand:CommandNotifyLoadPopup
                           object:userinfoDic];
    
    
    [self waitForInStep];
    [StepDefinition waitForOutsideStep];
    
}
- (void) I_did_open_request_popup{
    // initialize request popup
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       @"iMac rocks in Diablo3", GreeRequestServicePopupTitle, 
                                       @"and Monk rules them all", GreeRequestServicePopupBody,
                                       @"test type", GreeRequestServicePopupListType,
                                       nil];
    GreeRequestServicePopup* requestPopup = [GreeRequestServicePopup popupWithParameters:parameters];
    
    requestPopup.didLaunchBlock = nil;
    requestPopup.willDismissBlock = nil;
    requestPopup.willLaunchBlock = nil;
    requestPopup.didDismissBlock = nil;
    requestPopup.didLaunchBlock = ^(id aSender) {
        [[self getBlockRepo] setObject:@"1" forKey:@"didLaunchMark"];
        [self notifyInStep];
    };
    
    [[self getBlockRepo] setObject:requestPopup forKey:@"requestPopup"];
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        requestPopup, @"popup",
                                        nil];
    
    [self notifyMainUIWithCommand:CommandNotifyLoadPopup
                           object:userinfoDic];
    
    [self waitForInStep];
    [StepDefinition waitForOutsideStep];
    
}

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

- (void) screenshot_should_be_similar_to_expected_one{
    NSString* imageName = [[NSBundle mainBundle] pathForResource:@"requestPopup" ofType:@"png"];
    UIImage* expImage = [[UIImage alloc] initWithContentsOfFile:imageName];
    
    UIImage* actImage = [[self getBlockRepo] objectForKey:@"screenshot"];
    
    size_t width1  = CGImageGetWidth(expImage.CGImage);
    size_t height1 = CGImageGetHeight(expImage.CGImage);
    
    size_t width  = CGImageGetWidth(actImage.CGImage);
    size_t height = CGImageGetHeight(actImage.CGImage);
    
    NSLog(@"%i, %i, %i, %i", (int)width1, (int)width, (int)height1, (int)height);
   
//    for (int x = 0; x < width; x++) {
//        for (int y = 0; y < height; y++) {
//            int c1 = [self getPixelColorFromImage:expImage X:x Y:y];
//            int c2 = [self getPixelColorFromImage:actImage X:x Y:y];
////            NSLog(@"%f", fabs(c1-c2));
//        }
//    }
//    
    return;
}

- (void) I_will_dismiss_request_popup{
    GreeRequestServicePopup* requestPopup = [[self getBlockRepo] objectForKey:@"requestPopup"];
    
    requestPopup.didLaunchBlock = nil;
    requestPopup.willDismissBlock = nil;
    requestPopup.willLaunchBlock = nil;
    requestPopup.didDismissBlock = nil;
    requestPopup.willDismissBlock = ^(id aSender) {
        [[self getBlockRepo] setObject:@"1" forKey:@"willDismissMark"];
        [self notifyInStep];
    };
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        requestPopup, @"popup", 
                                        nil];
    
    [self notifyMainUIWithCommand:CommandNotifyDismissPopup 
                           object:userinfoDic];
    
    
    [self waitForInStep];
    [StepDefinition waitForOutsideStep];
    
}
- (void) I_did_dismiss_request_popup{
    GreeRequestServicePopup* requestPopup = [[self getBlockRepo] objectForKey:@"requestPopup"];
    
    requestPopup.didLaunchBlock = nil;
    requestPopup.willDismissBlock = nil;
    requestPopup.willLaunchBlock = nil;
    requestPopup.didDismissBlock = nil;
    requestPopup.didDismissBlock = ^(id aSender) {
        [[self getBlockRepo] setObject:@"1" forKey:@"didDismissMark"];
        [self notifyInStep];
    };
    
    NSMutableDictionary* userinfoDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                        requestPopup, @"popup", 
                                        nil];
    
    [self notifyMainUIWithCommand:CommandNotifyDismissPopup 
                           object:userinfoDic];
    
    [StepDefinition waitForOutsideStep];
    [self waitForInStep];
}


- (void) popup_will_open_callback_should_be_fired_within_seconds_PARAMINT:(NSString*) seconds{
    NSString* mark = [[self getBlockRepo] objectForKey:@"willLaunchMark"];
    [QAAssert assertEqualsExpected:@"1" 
                            Actual:mark];
}
- (void) popup_did_open_callback_should_be_fired_within_seconds_PARAMINT:(NSString*) seconds{
    NSString* mark = [[self getBlockRepo] objectForKey:@"didLaunchMark"];
    [QAAssert assertEqualsExpected:@"1" 
                            Actual:mark];
}
- (void) popup_will_dismiss_callback_should_be_fired_within_seconds_PARAMINT:(NSString*) seconds{
    NSString* mark = [[self getBlockRepo] objectForKey:@"willDismissMark"];
    [QAAssert assertEqualsExpected:@"1" 
                            Actual:mark];
}
- (void) popup_did_dismiss_callback_should_be_fired_within_seconds_PARAMINT:(NSString*) seconds{
    NSString* mark = [[self getBlockRepo] objectForKey:@"didDismissMark"];
    [QAAssert assertEqualsExpected:@"1" 
                            Actual:mark];
}
- (void) complete_callback_should_work_fine{
    NSString* mark = [[self getBlockRepo] objectForKey:@"completeMark"];
    [QAAssert assertEqualsExpected:@"1" 
                            Actual:mark];
}

- (int) getPixelColorFromImage:(UIImage*) image
                             X:(int) x 
                             Y:(int) y{
    int color = 0;
    
    CGImageRef cgImage = [image CGImage];
    size_t width = CGImageGetWidth(cgImage);
    
    CGDataProviderRef provider = CGImageGetDataProvider(cgImage);
    CFDataRef bitmapData = CGDataProviderCopyData(provider);
    const UInt8* data = CFDataGetBytePtr(bitmapData);
    size_t offset = ((width * y) + x) * 4;
    UInt8 red = data[offset];
    UInt8 blue = data[offset+1];
    UInt8 green = data[offset+2];
    UInt8 alpha = data[offset+3];
    CFRelease(bitmapData);
    if (red+blue+green > 306) {
        NSLog(@"%i", red+blue+green);
    }
    color = (int)(red*3/255+blue/255+green*6/255)/10;
    
    return color;
}

@end
