//
// Copyright 2012 GREE, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Kiwi.h"
#import "GreeJSPopupNeedUpgradeCommand.h"
#import "GreePopup.h"
#import "GreePopupView.h"
#import "GreeNotificationBoardViewController.h"
#import "UIViewController+GreeAdditions.h"
#import "GreeAuthorization.h"
#import "GreeJSHandler.h"
#import "GreeMatchers.h"

@interface GreeJSPopupNeedUpgradeCommand(ExposePrivateMethods)

- (void)setHaveBeenDismissed:(BOOL)haveBeenDismissed;
- (void)greePopupDidDismissNotification:(NSNotification*)aNotification;
@end

SPEC_BEGIN(GreeJSPopupNeedUpgradeCommandTest)

describe(@"GreeJSPopupNeedUpgradeCommand",^{
  registerMatchers(@"Gree");
  
  it(@"should have a name", ^{
    [[[GreeJSPopupNeedUpgradeCommand name] should] equal:@"need_upgrade"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSPopupNeedUpgradeCommand *command = [[GreeJSPopupNeedUpgradeCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSPopupNeedUpgradeCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should reload the webview if no callback function is provided but the operation was successful", ^{
      GreeJSPopupNeedUpgradeCommand *command = [[GreeJSPopupNeedUpgradeCommand alloc] init];
    
      KWMock *authorization = [KWMock nullMockForClass:[GreeAuthorization class]];
      KWCaptureSpy *successSpy = [authorization captureArgument:@selector(upgradeWithParams:successBlock:failureBlock:) atIndex:1];
      
      [[GreeAuthorization stubAndReturn:authorization] sharedInstance];
      
      UIWebView *webView = [UIWebView nullMock];

      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:webView] webviewForCommand:command];
      
      command.environment = environment;
      [command execute:nil];
      
      void (^successBlock)(void) = successSpy.argument;
      successBlock();
      
      [[[webView shouldEventually] receive] reload];
      
      [[NSNotificationCenter defaultCenter] removeObserver:command];
      [command release];
    });

    it(@"should report back to the handler when the request is successful and a callback function is given", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"callback", @"callback",
        nil];
    
      GreeJSPopupNeedUpgradeCommand *command = [[GreeJSPopupNeedUpgradeCommand alloc] init];
    
      KWMock *authorization = [KWMock nullMockForClass:[GreeAuthorization class]];
      KWCaptureSpy *successSpy = [authorization captureArgument:@selector(upgradeWithParams:successBlock:failureBlock:) atIndex:1];
      
      [[GreeAuthorization stubAndReturn:authorization] sharedInstance];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];

      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:handler] handler];
      
      command.environment = environment;
      [command execute:parameters];
      
      void (^successBlock)(void) = successSpy.argument;
      successBlock();
      
      [[[handler shouldEventually] receive]
        callback:@"callback"
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          @"callback", @"callback",
          @"success", @"result",
          nil]];

      [[NSNotificationCenter defaultCenter] removeObserver:command];
      [command release];
    });
    
    it(@"should reload the webview if no callback function is provided but the operation was successful", ^{
      GreeJSPopupNeedUpgradeCommand *command = [[GreeJSPopupNeedUpgradeCommand alloc] init];
    
      KWMock *authorization = [KWMock nullMockForClass:[GreeAuthorization class]];
      KWCaptureSpy *successSpy = [authorization captureArgument:@selector(upgradeWithParams:successBlock:failureBlock:) atIndex:1];
      
      [[GreeAuthorization stubAndReturn:authorization] sharedInstance];
      
      UIWebView *webView = [UIWebView nullMock];

      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:webView] webviewForCommand:command];
      
      command.environment = environment;
      [command execute:nil];
      
      void (^successBlock)(void) = successSpy.argument;
      successBlock();
      
      [[[webView shouldEventually] receive] reload];

      [[NSNotificationCenter defaultCenter] removeObserver:command];
      [command release];
    });
    
    it(@"should cancel the popup if the view controller is a popup, there is no callback, and the request failed", ^{
      GreeJSPopupNeedUpgradeCommand *command = [[GreeJSPopupNeedUpgradeCommand alloc] init];
    
      KWMock *authorization = [KWMock nullMockForClass:[GreeAuthorization class]];
      KWCaptureSpy *failureSpy = [authorization captureArgument:@selector(upgradeWithParams:successBlock:failureBlock:) atIndex:2];
      
      [[GreeAuthorization stubAndReturn:authorization] sharedInstance];
      
      id myDelegate = [KWMock nullMockForProtocol:@protocol(GreePopupViewDelegate)];
      
      GreePopupView *popupView = [GreePopupView nullMock];
      [popupView stub:@selector(delegate) andReturn:myDelegate];
      
      GreePopup *popup = [GreePopup nullMock];
      [[popup stubAndReturn:popupView] popupView];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:popup] viewControllerForCommand:command];
      
      command.environment = environment;
      [command execute:nil];
      
      void (^failureBlock)(void) = failureSpy.argument;
      failureBlock();
      
      [[[myDelegate shouldEventually] receive] popupViewDidCancel];
      
      [[NSNotificationCenter defaultCenter] removeObserver:command];
      [command release];
    });
      
    it(@"should dismiss the current view controller if it is a notification board", ^{
      GreeJSPopupNeedUpgradeCommand *command = [[GreeJSPopupNeedUpgradeCommand alloc] init];
    
      KWMock *authorization = [KWMock nullMockForClass:[GreeAuthorization class]];
      KWCaptureSpy *failureSpy = [authorization captureArgument:@selector(upgradeWithParams:successBlock:failureBlock:) atIndex:2];
      
      [[GreeAuthorization stubAndReturn:authorization] sharedInstance];
      
      GreeNotificationBoardViewController *notificationBoard = [GreeNotificationBoardViewController nullMock];
     
      [[UIViewController stubAndReturn:notificationBoard] greeLastPresentedViewController]; 
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:notificationBoard] viewControllerForCommand:command];
      
      command.environment = environment;
      [command execute:nil];
      
      void (^failureBlock)(void) = failureSpy.argument;
      failureBlock();
      
      [[[notificationBoard shouldEventually] receive] greeDismissViewControllerAnimated:YES completion:nil];      
      
       [[NSNotificationCenter defaultCenter] removeObserver:command];
      [command release];
    });
      
    it(@"should report back to the handler when the request is a failure and a callback function is given", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"callback", @"callback",
        nil];
    
      GreeJSPopupNeedUpgradeCommand *command = [[GreeJSPopupNeedUpgradeCommand alloc] init];
    
      KWMock *authorization = [KWMock nullMockForClass:[GreeAuthorization class]];
      KWCaptureSpy *failureSpy = [authorization captureArgument:@selector(upgradeWithParams:successBlock:failureBlock:) atIndex:2];
      
      [[GreeAuthorization stubAndReturn:authorization] sharedInstance];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];

      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:handler] handler];
      
      command.environment = environment;
      [command execute:parameters];
      
      void (^failureBlock)(void) = failureSpy.argument;
      failureBlock();
      
      [[[handler shouldEventually] receive]
        callback:@"callback"
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          @"callback", @"callback",
          @"fail", @"result",
          nil]];

      [[NSNotificationCenter defaultCenter] removeObserver:command];
      [command release];
    });
  });
  
  it(@"should set the value of have been dismissed if it receives a notification", ^{
    GreeJSPopupNeedUpgradeCommand *command = [[GreeJSPopupNeedUpgradeCommand alloc] init];
    
    GreePopup *popup = [GreePopup nullMock];
    
    id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
    [[environment stubAndReturn:popup] viewControllerForCommand:command];
    
    NSNotification *notification = [NSNotification
      notificationWithName:@"mockName"
      object:nil
      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:popup, @"sender", nil]];
    
    command.environment = environment;
    [[[command should] receive] setHaveBeenDismissed:YES];
    
    [command greePopupDidDismissNotification:notification];
    
    [[NSNotificationCenter defaultCenter] removeObserver:command];
    [command release];
  });
  
});

SPEC_END
