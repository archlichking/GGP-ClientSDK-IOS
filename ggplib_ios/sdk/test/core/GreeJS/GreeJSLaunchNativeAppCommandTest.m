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
#import "GreeJSLaunchNativeAppCommand.h"
#import "UIViewController+GreeAdditions.h"
#import "GreeNotificationBoardViewController.h"
#import "GreeDashboardViewController.h"
#import "GreeJSHandler.h"
#import "GreePlatform.h"
#import "GreeMatchers.h"
#import "GreeTestHelpers.h"

@interface GreeJSLaunchNativeAppCommand (PrivateMethods)
- (void)callbackWithErrorMessage:(NSString*)message params:(NSDictionary*)params;
@end

SPEC_BEGIN(GreeJSLaunchNativeAppCommandTest)

describe(@"GreeJSLaunchNativeAppCommand",^{
  registerMatchers(@"Gree");
  
  it(@"should have a name", ^{
    [[[GreeJSLaunchNativeAppCommand name] should] equal:@"launch_native_app"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSLaunchNativeAppCommand *command = [[GreeJSLaunchNativeAppCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSLaunchNativeAppCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should callback with an error if no URL is project", ^{
      NSDictionary *params = [NSDictionary dictionary];
      
      GreeJSLaunchNativeAppCommand *command = [[GreeJSLaunchNativeAppCommand alloc] init];
      [[command should] receive:@selector(callbackWithErrorMessage:params:)];
      [command execute:params];
      [command release];
    });

    it(@"should callback with an error if the URL is nil", ^{
      NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockURL://", @"URL", nil];
      
      [NSURL stub:@selector(URLWithString:) andReturn:nil];
      
      GreeJSLaunchNativeAppCommand *command = [[GreeJSLaunchNativeAppCommand alloc] init];
      [[command should] receive:@selector(callbackWithErrorMessage:params:)];
      [command execute:params];
      [command release];
    });
    
    context(@"when it is a GREEURL scheme", ^{
      __block NSURL *URL;
      
      beforeEach(^{
        URL = [NSURL nullMock];
        [URL stub:@selector(isSelfGreeURLScheme) andReturn:theValue(YES)];
        [URL stub:@selector(host) andReturn:@"start"];
        
        NSArray *pathComponents = [NSArray arrayWithObjects:@"start", @"request", nil];
        [URL stub:@selector(pathComponents) andReturn:pathComponents];
        
        [NSURL stub:@selector(URLWithString:) andReturn:URL];
      });
      
      it(@"should not dismiss anything if the view controller is not a notification board", ^{
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
          @"mockURL://", @"URL", nil];
      
        UIViewController *viewController = [UIViewController nullMock];
        [[viewController shouldNot] receive:@selector(greeDismissViewControllerAnimated:completion:)];
                
        id environment = [KWMock mockForProtocol:@protocol(GreeJSCommandEnvironment)];
        [environment stub:@selector(viewControllerForCommand:) andReturn:viewController];
        
        GreeJSLaunchNativeAppCommand *command = [[GreeJSLaunchNativeAppCommand alloc] init];
        command.environment = environment;
        [command execute:params];
        [command release];
      });

      it(@"should dismiss the notification board if it is displaying", ^{
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
          @"mockURL://", @"URL", nil];
          
        UIViewController *presentingViewController = [UIViewController nullMock];
        [[presentingViewController should] receive:@selector(dismissGreeNotificationBoardAnimated:completion:)];
        
        GreeNotificationBoardViewController *viewController = [GreeNotificationBoardViewController nullMock];
        [viewController stub:@selector(greePresentingViewController) andReturn:presentingViewController];
                
        id environment = [KWMock mockForProtocol:@protocol(GreeJSCommandEnvironment)];
        [environment stub:@selector(viewControllerForCommand:) andReturn:viewController];

        GreeJSLaunchNativeAppCommand *command = [[GreeJSLaunchNativeAppCommand alloc] init];
        command.environment = environment;
        [command execute:params];
        [command release];
      });
      
      it(@"should execute the notification board callback", ^{
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
          @"mockURL://", @"URL", nil];

        GreeJSLaunchNativeAppCommand *command = [[GreeJSLaunchNativeAppCommand alloc] init];
          
        KWMock *presentingViewController = [KWMock nullMockForClass:[UIViewController class]];
        KWCaptureSpy *completionSpy = [presentingViewController
          captureArgument:@selector(dismissGreeNotificationBoardAnimated:completion:)
          atIndex:1];
        
        GreeNotificationBoardViewController *viewController = [GreeNotificationBoardViewController nullMock];
        [viewController stub:@selector(greePresentingViewController) andReturn:presentingViewController];
                
        id environment = [KWMock mockForProtocol:@protocol(GreeJSCommandEnvironment)];
        [[environment stubAndReturn:viewController] viewControllerForCommand:command];

        GreePlatform *platform = [GreePlatform nullMockAsSharedInstance];
        [[platform should] receive:@selector(notifyLaunchParameterToApp:)];
        [[platform stubAndReturn:platform] sharedInstance];

        command.environment = environment;
        [command execute:params];
        
        void (^completion)(id results) = completionSpy.argument;
        completion(nil);
        
        [command release];
      });
      
      it(@"should also dismiss the notification board if a dashboard is displaying it", ^{
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
          @"mockURL://", @"URL", nil];
          
        GreeDashboardViewController *presentingViewController = [GreeDashboardViewController nullMock];
        [[presentingViewController should] receive:@selector(dismissGreeNotificationBoardAnimated:completion:)];
        
        GreeNotificationBoardViewController *viewController = [GreeNotificationBoardViewController nullMock];
        [viewController stub:@selector(greePresentingViewController) andReturn:presentingViewController];
                
        id environment = [KWMock mockForProtocol:@protocol(GreeJSCommandEnvironment)];
        [environment stub:@selector(viewControllerForCommand:) andReturn:viewController];

        GreeJSLaunchNativeAppCommand *command = [[GreeJSLaunchNativeAppCommand alloc] init];
        command.environment = environment;
        [command execute:params];
        [command release];
      });
      
      it(@"callback after dismissing the notification board and the dashboard", ^{
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
          @"mockURL://", @"URL", nil];

        GreeJSLaunchNativeAppCommand *command = [[GreeJSLaunchNativeAppCommand alloc] init];
        
        KWMock *presentingPresentingViewController = [KWMock nullMockForClass:[UIViewController class]];
        KWCaptureSpy *completion2Spy = [presentingPresentingViewController
          captureArgument:@selector(dismissGreeDashboardAnimated:completion:)
          atIndex:1];
          
        KWMock *presentingViewController = [KWMock nullMockForClass:[GreeDashboardViewController class]];
        KWCaptureSpy *completion1Spy = [presentingViewController
          captureArgument:@selector(dismissGreeNotificationBoardAnimated:completion:)
          atIndex:1];
        [[presentingViewController stubAndReturn:presentingPresentingViewController] greePresentingViewController];
        
        GreeNotificationBoardViewController *viewController = [GreeNotificationBoardViewController nullMock];
        [[viewController stubAndReturn:presentingViewController] greePresentingViewController];
                
        id environment = [KWMock mockForProtocol:@protocol(GreeJSCommandEnvironment)];
        [[environment stubAndReturn:viewController] viewControllerForCommand:command];
        
        GreePlatform *platform = [GreePlatform nullMockAsSharedInstance];
        [[platform should] receive:@selector(notifyLaunchParameterToApp:)];
        [[platform stubAndReturn:platform] sharedInstance];

        command.environment = environment;
        [command execute:params];
        
        void (^completion1)(id results) = completion1Spy.argument;
        completion1(nil);
        
        void (^completion2)(id results) = completion2Spy.argument;
        completion2(nil);
        
        [command release];
      });
    });

    context(@"the application can not open the URL", ^{
      __block id application;
      
      beforeEach(^{
        application = [UIApplication nullMock];
        [application stub:@selector(canOpenURL:) andReturn:theValue(NO)];
        [UIApplication stub:@selector(sharedApplication) andReturn:application];
      });
      
      afterEach(^{
        application = nil;
      });
      
      it(@"should return an error if the app store line is nil", ^{
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
          @"mockURL://", @"URL", nil];
        
        GreeJSLaunchNativeAppCommand *command = [[GreeJSLaunchNativeAppCommand alloc] init];
        [[command should] receive:@selector(callbackWithErrorMessage:params:)];
        [command execute:params];
        [command release];
      });
      
      it(@"should open the app in the app store if the url is not found", ^{
        NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
          @"mockURL://", @"URL",
          @"mockAppStoreURL://", @"ios_src",
          nil];
          
        [[application should] receive:@selector(openURL:)];
        
        GreeJSLaunchNativeAppCommand *command = [[GreeJSLaunchNativeAppCommand alloc] init];
        [command execute:params];
        [command release];
      });
    });
    
    it(@"should open the URL if it can", ^{
      NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockURL://", @"URL",
        nil];
        
      UIApplication *application = [UIApplication nullMock];
      [application stub:@selector(canOpenURL:) andReturn:theValue(YES)];
      [UIApplication stub:@selector(sharedApplication) andReturn:application];
      
      GreeJSLaunchNativeAppCommand *command = [[GreeJSLaunchNativeAppCommand alloc] init];
      [command execute:params];
      [command release];
    });
  });
  
  it(@"should not have the error send a callback if the callback does not exist", ^{
    GreeJSHandler *handler = [GreeJSHandler nullMock];
    [[handler shouldNot] receive:@selector(callback:params:)];
    
    id environment = [KWMock mockForProtocol:@protocol(GreeJSCommandEnvironment)];
    [environment stub:@selector(handler) andReturn:handler];
    
    GreeJSLaunchNativeAppCommand *command = [[GreeJSLaunchNativeAppCommand alloc] init];
    command.environment = environment;
    [command callbackWithErrorMessage:@"mockMessage" params:nil];
    [command release];    
  });

  it(@"should send a callback if the callback exists", ^{
    GreeJSHandler *handler = [GreeJSHandler nullMock];
    [[handler should] receive:@selector(callback:params:)];
    
    id environment = [KWMock mockForProtocol:@protocol(GreeJSCommandEnvironment)];
    [environment stub:@selector(handler) andReturn:handler];
    
    GreeJSLaunchNativeAppCommand *command = [[GreeJSLaunchNativeAppCommand alloc] init];
    command.environment = environment;
    [command callbackWithErrorMessage:@"mockMessage" params:[NSDictionary
      dictionaryWithObjectsAndKeys:@"mockCallback", @"callback", nil]];
    [command release];    
  });
  
});

SPEC_END
