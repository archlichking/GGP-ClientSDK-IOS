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
#import "GreeJSShowShareDialogCommand.h"
#import "UIViewController+GreePlatform.h"
#import "GreePopup.h"
#import "GreePopupView.h"

#pragma mark - GreeJSShowShareDialogCommandTest

SPEC_BEGIN(GreeJSShowShareDialogCommandTest)

describe(@"GreeJSShowShareDialogCommandTest",^{
  it(@"should have a description", ^{
    GreeJSShowShareDialogCommand *command = [[GreeJSShowShareDialogCommand alloc] init];
  
    NSString* checkString = [NSString stringWithFormat:@"<GreeJSShowShareDialogCommand:%p>",
      command];
      
    [[[command description] should] equal:checkString]; 
    [command release];
  });
  
  it(@"should have a name", ^{      
    [[[GreeJSShowShareDialogCommand name] should] equal:@"show_share_dialog"]; 
  });
  
  context(@"when executing", ^{
    it(@"should show a share service popup", ^{
      GreeJSShowShareDialogCommand *command = [[GreeJSShowShareDialogCommand alloc] init];

      UIViewController *viewController = [UIViewController nullMock];
  
      GreeSharePopup *popup = [GreeSharePopup mock];
      [popup stub:@selector(initWithParameters:) andReturn:popup];
      [popup stub:@selector(setDidDismissBlock:)];

      [[[viewController should] receive ]showGreePopup:popup];
    
      [GreeSharePopup stub:@selector(alloc) andReturn:popup];
        
      [[command stubAndReturn:viewController] viewControllerWithRequiredBaseClass:nil];
      [command execute:nil];
      [command release];
    });

    it(@"should set the close button to hidden if the type is noclose", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"noclose", @"type", nil];
    
      GreeJSShowShareDialogCommand *command = [[GreeJSShowShareDialogCommand alloc] init];

      UIViewController *viewController = [UIViewController nullMock];
  
      UIButton *closeButton = [UIButton nullMock];
      [[[closeButton should] receive] setHidden:YES];
  
      GreePopupView *popupView = [GreePopupView nullMock];
      [[popupView stubAndReturn:closeButton] closeButton];
      
      GreeSharePopup *popup = [GreeSharePopup nullMock];
      [popup stub:@selector(initWithParameters:) andReturn:popup];
      [[popup stubAndReturn:popupView] popupView];
      [GreeSharePopup stub:@selector(alloc) andReturn:popup];
        
      [[command stubAndReturn:viewController] viewControllerWithRequiredBaseClass:nil];
      [command execute:parameters];
      [command release];
    });

    it(@"should no set the close button to hidden if the type is not noclose", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockType", @"type", nil];
    
      GreeJSShowShareDialogCommand *command = [[GreeJSShowShareDialogCommand alloc] init];

      UIViewController *viewController = [UIViewController nullMock];
  
      UIButton *closeButton = [UIButton nullMock];
      [[[closeButton shouldNot] receive] setHidden:YES];
  
      GreePopupView *popupView = [GreePopupView nullMock];
      [[popupView stubAndReturn:closeButton] closeButton];
      
      GreeSharePopup *popup = [GreeSharePopup nullMock];
      [popup stub:@selector(initWithParameters:) andReturn:popup];
      [[popup stubAndReturn:popupView] popupView];
      [GreeSharePopup stub:@selector(alloc) andReturn:popup];
        
      [[command stubAndReturn:viewController] viewControllerWithRequiredBaseClass:nil];
      [command execute:parameters];
      [command release];
    });

    it(@"should not set the close button to hidden if the type is not noclose", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockType", @"type", nil];
    
      GreeJSShowShareDialogCommand *command = [[GreeJSShowShareDialogCommand alloc] init];

      UIViewController *viewController = [UIViewController nullMock];
  
      UIButton *closeButton = [UIButton nullMock];
      [[[closeButton shouldNot] receive] setHidden:YES];
  
      GreePopupView *popupView = [GreePopupView nullMock];
      [[popupView stubAndReturn:closeButton] closeButton];
      
      GreeSharePopup *popup = [GreeSharePopup nullMock];
      [popup stub:@selector(initWithParameters:) andReturn:popup];
      [[popup stubAndReturn:popupView] popupView];
      [GreeSharePopup stub:@selector(alloc) andReturn:popup];
        
      [[command stubAndReturn:viewController] viewControllerWithRequiredBaseClass:nil];
      [command execute:parameters];
      [command release];
    });

    it(@"should set the message if the message paramter is given", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockMessage", @"message", nil];
    
      GreeJSShowShareDialogCommand *command = [[GreeJSShowShareDialogCommand alloc] init];

      UIViewController *viewController = [UIViewController nullMock];
      [[command stubAndReturn:viewController] viewControllerWithRequiredBaseClass:nil];
        
      GreeSharePopup *popup = [GreeSharePopup nullMock];
      [popup stub:@selector(initWithParameters:) andReturn:popup];
      [[[popup should] receive] setText:@"mockMessage"];
      [GreeSharePopup stub:@selector(alloc) andReturn:popup];
        
      [command execute:parameters];
      [command release];
    });

    it(@"should not set the message if the message paramter is not given", ^{    
      GreeJSShowShareDialogCommand *command = [[GreeJSShowShareDialogCommand alloc] init];

      UIViewController *viewController = [UIViewController nullMock];
      [[command stubAndReturn:viewController] viewControllerWithRequiredBaseClass:nil];
        
      GreeSharePopup *popup = [GreeSharePopup nullMock];
      [popup stub:@selector(initWithParameters:) andReturn:popup];
      [[popup shouldNot] receive:@selector(setText:)];
      [GreeSharePopup stub:@selector(alloc) andReturn:popup];
        
      [command execute:nil];
      [command release];
    });

    it(@"should set the imageURLs string if they are specified", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockImageUrls", @"image_urls", nil];
      GreeJSShowShareDialogCommand *command = [[GreeJSShowShareDialogCommand alloc] init];

      UIViewController *viewController = [UIViewController nullMock];
      [[command stubAndReturn:viewController] viewControllerWithRequiredBaseClass:nil];
        
      GreeSharePopup *popup = [GreeSharePopup nullMock];
      [popup stub:@selector(initWithParameters:) andReturn:popup];
      [[[popup should] receive] setImageUrls:@"mockImageUrls"];
      [GreeSharePopup stub:@selector(alloc) andReturn:popup];
        
      [command execute:parameters];
      [command release];
    });

    it(@"should not set the imageURLs string if they are not specified", ^{
      GreeJSShowShareDialogCommand *command = [[GreeJSShowShareDialogCommand alloc] init];

      UIViewController *viewController = [UIViewController nullMock];
      [[command stubAndReturn:viewController] viewControllerWithRequiredBaseClass:nil];
        
      GreeSharePopup *popup = [GreeSharePopup nullMock];
      [popup stub:@selector(initWithParameters:) andReturn:popup];
      [[popup shouldNot] receive:@selector(setImageUrls:)];
      [GreeSharePopup stub:@selector(alloc) andReturn:popup];
        
      [command execute:nil];
      [command release];
    });
  });
  
  context(@"when the popup is dismissed", ^{
    it(@"should set the callback parameters to close", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"callback", @"callback",
        nil];
    
      GreeJSShowShareDialogCommand *command = [[GreeJSShowShareDialogCommand alloc] init];

      UIViewController *viewController = [UIViewController nullMock];
      [[command stubAndReturn:viewController] viewControllerWithRequiredBaseClass:nil];
        
      KWMock *popup = [KWMock nullMockForClass:[GreePopup class]];
      KWCaptureSpy *dismissSpy = [popup captureArgument:@selector(setDidDismissBlock:) atIndex:0];
    
      [popup stub:@selector(initWithParameters:) andReturn:popup];
      [GreeSharePopup stub:@selector(alloc) andReturn:popup];
       
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:@"callback"
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          @"close", @"result",
          nil]];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:handler] handler];
      
      command.environment = environment;
      [command execute:parameters];
      
      void (^dismissBlock)(id sender) = dismissSpy.argument;
      dismissBlock(popup);
      
      [command release];
    });

    it(@"should set the result in the callback parameters if there is a result", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"callback", @"callback",
        @"mockResult", @"result",
        nil];
    
      GreeJSShowShareDialogCommand *command = [[GreeJSShowShareDialogCommand alloc] init];

      UIViewController *viewController = [UIViewController nullMock];
      [[command stubAndReturn:viewController] viewControllerWithRequiredBaseClass:nil];
        
      KWMock *popup = [KWMock nullMockForClass:[GreePopup class]];
      KWCaptureSpy *dismissSpy = [popup captureArgument:@selector(setDidDismissBlock:) atIndex:0];
    
      [popup stub:@selector(initWithParameters:) andReturn:popup];
      [[popup stubAndReturn:@"mockResult"] results];
      [GreeSharePopup stub:@selector(alloc) andReturn:popup];
       
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:@"callback"
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          @"close", @"result",
          @"mockResult", @"param",
          nil]];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:handler] handler];
      
      command.environment = environment;
      [command execute:parameters];
      
      void (^dismissBlock)(id sender) = dismissSpy.argument;
      dismissBlock(popup);
      
      [command release];
    });    
  });
});

SPEC_END
