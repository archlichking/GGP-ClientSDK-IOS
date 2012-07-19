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
#import "GreeJSShowInviteDialogCommand.h"
#import "GreeTestHelpers.h"
#import "GreePopup.h"

#pragma mark - GreeJSShowInviteDialogCommandTest

SPEC_BEGIN(GreeJSShowInviteDialogCommandTest)

describe(@"GreeJSShowInviteDialogCommandTest",^{
  it(@"should have a description", ^{
    GreeJSShowInviteDialogCommand *command = [[GreeJSShowInviteDialogCommand alloc] init];
  
    NSString* checkString = [NSString stringWithFormat:@"<GreeJSShowInviteDialogCommand:%p>",
      command];
      
    [[[command description] should] equal:checkString]; 
    [command release];
  });
  
  it(@"should have a name", ^{      
    [[[GreeJSShowInviteDialogCommand name] should] equal:@"show_invite_dialog"]; 
  });
  
  context(@"when executing", ^{
    it(@"should show a share service popup", ^{
      GreeJSShowInviteDialogCommand *command = [[GreeJSShowInviteDialogCommand alloc] init];

      UIViewController *viewController = [UIViewController nullMock];
      [[viewController should] receive:@selector(showGreePopup:)];
  
      GreeInvitePopup *popup = [GreeInvitePopup nullMock];
      [[popup should] receive:@selector(setDidDismissBlock:)];
      [popup stub:@selector(initWithParameters:) andReturn:popup];
    
      [GreeInvitePopup stub:@selector(alloc) andReturn:popup];
        
      [[command stubAndReturn:viewController] viewControllerWithRequiredBaseClass:nil];
      [command execute:nil];
      [command release];
    });

    it(@"should set the popup message if a message is passed", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSDictionary dictionaryWithObjectsAndKeys:
          @"mockMessage", @"body",
          nil], @"invite", nil];
      GreeJSShowInviteDialogCommand *command = [[GreeJSShowInviteDialogCommand alloc] init];

      UIViewController *viewController = [UIViewController nullMock];
      [[command stubAndReturn:viewController] viewControllerWithRequiredBaseClass:nil];
        
      GreeInvitePopup *popup = [GreeInvitePopup nullMock];
      [popup stub:@selector(initWithParameters:) andReturn:popup];
      [[[popup should] receive] setMessage:@"mockMessage"];
      [[GreeInvitePopup stubAndReturn:popup] popupWithParameters:parameters];
        
      [command execute:parameters];
      [command release];
    });

    it(@"should not set the popup message if a message is not passed", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSDictionary dictionary], @"invite", nil];
      GreeJSShowInviteDialogCommand *command = [[GreeJSShowInviteDialogCommand alloc] init];

      UIViewController *viewController = [UIViewController nullMock];
      [[command stubAndReturn:viewController] viewControllerWithRequiredBaseClass:nil];
        
      GreeInvitePopup *popup = [GreeInvitePopup nullMock];
      [popup stub:@selector(initWithParameters:) andReturn:popup];
      [[[popup shouldNot] receive] setMessage:@"mockMessage"];
      [[GreeInvitePopup stubAndReturn:popup] popupWithParameters:parameters];
        
      [command execute:parameters];
      [command release];
    });
    
    it(@"should set the popup callbackurl if the callback url is passed", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSDictionary dictionaryWithObjectsAndKeys:
          @"mockURL://", @"callbackurl",
          nil], @"invite", nil];
      GreeJSShowInviteDialogCommand *command = [[GreeJSShowInviteDialogCommand alloc] init];

      UIViewController *viewController = [UIViewController nullMock];
      [[command stubAndReturn:viewController] viewControllerWithRequiredBaseClass:nil];
        
      GreeInvitePopup *popup = [GreeInvitePopup nullMock];
      [popup stub:@selector(initWithParameters:) andReturn:popup];
      [[[popup should] receive] setCallbackURL:[NSURL URLWithString:@"mockURL://"]];
      [[GreeInvitePopup stubAndReturn:popup] popupWithParameters:parameters];
        
      [command execute:parameters];
      [command release];
    });

    it(@"should not set the popup message if the callback url is not set", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSDictionary dictionary], @"invite", nil];
      GreeJSShowInviteDialogCommand *command = [[GreeJSShowInviteDialogCommand alloc] init];

      UIViewController *viewController = [UIViewController nullMock];
      [[command stubAndReturn:viewController] viewControllerWithRequiredBaseClass:nil];
        
      GreeInvitePopup *popup = [GreeInvitePopup nullMock];
      [popup stub:@selector(initWithParameters:) andReturn:popup];
      [[[popup shouldNot] receive] setCallbackURL:[NSURL URLWithString:@"mockURL://"]];
      [[GreeInvitePopup stubAndReturn:popup] popupWithParameters:parameters];
        
      [command execute:parameters];
      [command release];
    });

    it(@"should not set the popup message if a message is not passed", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSDictionary dictionary], @"invite", nil];
      GreeJSShowInviteDialogCommand *command = [[GreeJSShowInviteDialogCommand alloc] init];

      UIViewController *viewController = [UIViewController nullMock];
      [[command stubAndReturn:viewController] viewControllerWithRequiredBaseClass:nil];
        
      GreeInvitePopup *popup = [GreeInvitePopup nullMock];
      [popup stub:@selector(initWithParameters:) andReturn:popup];
      [[[popup shouldNot] receive] setMessage:@"mockMessage"];
      [[GreeInvitePopup stubAndReturn:popup] popupWithParameters:parameters];
        
      [command execute:parameters];
      [command release];
    });
    
    it(@"should set the toUserIds if the toUserIds value is passed", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSDictionary dictionaryWithObjectsAndKeys:
          [NSArray array], @"to_user_id",
          nil], @"invite", nil];
      GreeJSShowInviteDialogCommand *command = [[GreeJSShowInviteDialogCommand alloc] init];

      UIViewController *viewController = [UIViewController nullMock];
      [[command stubAndReturn:viewController] viewControllerWithRequiredBaseClass:nil];
        
      GreeInvitePopup *popup = [GreeInvitePopup nullMock];
      [popup stub:@selector(initWithParameters:) andReturn:popup];
      [[[popup should] receive] setToUserIds:[NSArray array]];
      [[GreeInvitePopup stubAndReturn:popup] popupWithParameters:parameters];
        
      [command execute:parameters];
      [command release];
    });

    it(@"should not set the toUserIds if the toUserIds value are not passed", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSDictionary dictionary], @"invite", nil];
      GreeJSShowInviteDialogCommand *command = [[GreeJSShowInviteDialogCommand alloc] init];

      UIViewController *viewController = [UIViewController nullMock];
      [[command stubAndReturn:viewController] viewControllerWithRequiredBaseClass:nil];
        
      GreeInvitePopup *popup = [GreeInvitePopup nullMock];
      [popup stub:@selector(initWithParameters:) andReturn:popup];
      [[[popup shouldNot] receive] setToUserIds:[NSArray array]];
      [[GreeInvitePopup stubAndReturn:popup] popupWithParameters:parameters];
        
      [command execute:parameters];
      [command release];
    });
  });
  
  context(@"when the popup is dismissed", ^{
    it(@"should set the callback parameters to close", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"callback", @"callback",
        nil];
    
      GreeJSShowInviteDialogCommand *command = [[GreeJSShowInviteDialogCommand alloc] init];

      UIViewController *viewController = [UIViewController nullMock];
      [[command stubAndReturn:viewController] viewControllerWithRequiredBaseClass:nil];
        
      KWMock *popup = [KWMock nullMockForClass:[GreeInvitePopup class]];
      KWCaptureSpy *dismissSpy = [popup captureArgument:@selector(setDidDismissBlock:) atIndex:0];
    
      [popup stub:@selector(initWithParameters:) andReturn:popup];
      [GreeInvitePopup stub:@selector(alloc) andReturn:popup];
       
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
    
      GreeJSShowInviteDialogCommand *command = [[GreeJSShowInviteDialogCommand alloc] init];

      UIViewController *viewController = [UIViewController nullMock];
      [[command stubAndReturn:viewController] viewControllerWithRequiredBaseClass:nil];
        
      KWMock *popup = [KWMock nullMockForClass:[GreeInvitePopup class]];
      KWCaptureSpy *dismissSpy = [popup captureArgument:@selector(setDidDismissBlock:) atIndex:0];
    
      [popup stub:@selector(initWithParameters:) andReturn:popup];
      [[popup stubAndReturn:@"mockResult"] results];
      [GreeInvitePopup stub:@selector(alloc) andReturn:popup];
       
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
