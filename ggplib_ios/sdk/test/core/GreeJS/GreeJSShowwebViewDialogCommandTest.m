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
#import "GreeJSShowWebViewDialogCommand.h"
#import "GreePopup.h"

#pragma mark - GreeJSShowPopupDialogCommandTest

SPEC_BEGIN(GreeJSShowWebViewDialogCommandTest)

describe(@"GreeJSShowWebViewDialogCommand",^{
  __block UIViewController *viewController;
  __block KWMock *popup;
  __block KWCaptureSpy *dismissBlockSpy;
  
  beforeEach(^{
    viewController = [UIViewController nullMock];
  
    popup = [KWMock nullMockForClass:[GreePopup class]];
    dismissBlockSpy = [popup captureArgument:@selector(setDidDismissBlock:) atIndex:0];
    
    [popup stub:@selector(initWithParameters:) andReturn:popup];
    [[popup stubAndReturn:^{}] didDismissBlock];
    [GreePopup stub:@selector(alloc) andReturn:popup];
  });
  
  afterEach(^{
    viewController = nil;
    popup = nil;
    dismissBlockSpy = nil;
  });

  it(@"should show a popup if given a URL", ^{
    [[viewController should] receive:@selector(showGreePopup:)];
        
    GreeJSShowWebViewDialogCommand *command = [[GreeJSShowWebViewDialogCommand alloc] init];
    [command stub:@selector(viewControllerWithRequiredBaseClass:) andReturn:viewController];
    [command execute:[NSDictionary dictionaryWithObjectsAndKeys:@"http://www.gree.co.jp", @"URL", nil]];
    [command release];
  });
  
  context(@"When there is no URL", ^{
    it(@"should call the dismiss block", ^{
      [[popup should] receive:@selector(didDismissBlock)];
            
      GreeJSShowWebViewDialogCommand *command = [[GreeJSShowWebViewDialogCommand alloc] init];
      [command stub:@selector(viewControllerWithRequiredBaseClass:) andReturn:viewController];
      [command execute:nil];
      [command release];
    });
    
    it(@"should not show the popup", ^{
      [[viewController shouldNot] receive:@selector(showPopup:)];

      GreeJSShowWebViewDialogCommand *command = [[GreeJSShowWebViewDialogCommand alloc] init];
      [command stub:@selector(viewControllerWithRequiredBaseClass:) andReturn:viewController];
      [command execute:nil];
      [command release];
    });
  });
  
  context(@"when there is an invalid URL", ^{
    it(@"should call the dismiss block", ^{
      [[popup should] receive:@selector(didDismissBlock)];
            
      GreeJSShowWebViewDialogCommand *command = [[GreeJSShowWebViewDialogCommand alloc] init];
      [command stub:@selector(viewControllerWithRequiredBaseClass:) andReturn:viewController];
      [command execute:[NSDictionary dictionaryWithObject:@"###" forKey:@"URL"]];
      [command release];
    });
    
    it(@"should not show the popup", ^{
      [[viewController shouldNot] receive:@selector(showPopup:)];

      GreeJSShowWebViewDialogCommand *command = [[GreeJSShowWebViewDialogCommand alloc] init];
      [command stub:@selector(viewControllerWithRequiredBaseClass:) andReturn:viewController];
      [command execute:[NSDictionary dictionaryWithObject:@"###" forKey:@"URL"]];
      [command release];
    });
  });
  
  context(@"when dismissing", ^{
    it(@"should return yes if the sender is nil", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"callback", @"callback",
        nil];
    
      GreeJSShowWebViewDialogCommand *command = [[GreeJSShowWebViewDialogCommand alloc] init];
      [[[command should] receive] callback];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:@"callback"
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithBool:YES], @"result",
          nil]];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:handler] handler];
      
      command.environment = environment;
      [command stub:@selector(viewControllerWithRequiredBaseClass:) andReturn:viewController];
      [command execute:parameters];
      
      void (^dismissBlock)(id sender) = dismissBlockSpy.argument;
      dismissBlock(nil);
      
      [command release];
    });
    
    it(@"should return no if the sender is not nil and not a popup", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"callback", @"callback",
        nil];
    
      GreeJSShowWebViewDialogCommand *command = [[GreeJSShowWebViewDialogCommand alloc] init];
      [[[command should] receive] callback];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:@"callback"
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithBool:NO], @"result",
          nil]];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:handler] handler];
      
      command.environment = environment;
      [command stub:@selector(viewControllerWithRequiredBaseClass:) andReturn:viewController];
      [command execute:parameters];
      
      void (^dismissBlock)(id sender) = dismissBlockSpy.argument;
      dismissBlock([NSObject nullMock]);
      
      [command release];
    });
    
    it(@"should return no if the sender is a popup but the results are nil", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"callback", @"callback",
        nil];
    
      GreeJSShowWebViewDialogCommand *command = [[GreeJSShowWebViewDialogCommand alloc] init];
      [[[command should] receive] callback];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:@"callback"
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithBool:NO], @"result",
          nil]];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:handler] handler];
      
      command.environment = environment;
      [command stub:@selector(viewControllerWithRequiredBaseClass:) andReturn:viewController];
      [command execute:parameters];
      
      void (^dismissBlock)(id sender) = dismissBlockSpy.argument;
      
      [[popup stubAndReturn:nil] results];
      
      dismissBlock(popup);
      
      [command release];
    });
    
    it(@"should return no, as well as the result data, if the sender is popup and the results are defined", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"callback", @"callback",
        nil];
    
      GreeJSShowWebViewDialogCommand *command = [[GreeJSShowWebViewDialogCommand alloc] init];
      [[[command should] receive] callback];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:@"callback"
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          [NSNumber numberWithBool:NO], @"result",
          [NSDictionary dictionary], @"data",
          nil]];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:handler] handler];
      
      command.environment = environment;
      [command stub:@selector(viewControllerWithRequiredBaseClass:) andReturn:viewController];
      [command execute:parameters];
      
      void (^dismissBlock)(id sender) = dismissBlockSpy.argument;
      
      [[popup stubAndReturn:[NSDictionary dictionary]] results];
      
      dismissBlock(popup);
      
      [command release];
    });
  });
  
  it(@"should have a description", ^{
    GreeJSShowWebViewDialogCommand *command = [[GreeJSShowWebViewDialogCommand alloc] init];
  
    NSString* checkString = [NSString stringWithFormat:@"<GreeJSShowWebViewDialogCommand:%p>",
      command];
      
    [[[command description] should] equal:checkString]; 
    [command release];
  });
  
  it(@"should have a name", ^{      
    [[[GreeJSShowWebViewDialogCommand name] should] equal:@"show_webview_dialog"]; 
  });
});

SPEC_END
