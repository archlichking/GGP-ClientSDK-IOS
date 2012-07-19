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
#import "GreeJSShowRequestDialogCommand.h"
#import "GreePopup.h"

#pragma mark - GreeJSShowRequestDialogCommandTest

SPEC_BEGIN(GreeJSShowRequestDialogCommandTest)

describe(@"GreeJSShowRequestDialogCommand",^{
  it(@"should have a description", ^{
    GreeJSShowRequestDialogCommand *command = [[GreeJSShowRequestDialogCommand alloc] init];
  
    NSString* checkString = [NSString stringWithFormat:@"<GreeJSShowRequestDialogCommand:%p>",
      command];
      
    [[[command description] should] equal:checkString]; 
    [command release];
  });
  
  it(@"should have a name", ^{      
    [[[GreeJSShowRequestDialogCommand name] should] equal:@"show_request_dialog"]; 
  });
  
  context(@"when executing", ^{
    it(@"should show a request service popup", ^{
      UIViewController *viewController = [UIViewController nullMock];
      [[viewController should] receive:@selector(showGreePopup:)];
    
      GreeRequestServicePopup *popup = [GreeRequestServicePopup nullMock];
      [popup stub:@selector(initWithParameters:) andReturn:popup];
    
      [GreeRequestServicePopup stub:@selector(alloc) andReturn:popup];
        
      GreeJSShowRequestDialogCommand *command = [[GreeJSShowRequestDialogCommand alloc] init];
      [command stub:@selector(viewControllerWithRequiredBaseClass:) andReturn:viewController];
      [command execute:nil];
      [command release];
    });
  });

  context(@"when dismissing", ^{
    it(@"should set the callback parameters to close", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"callback", @"callback",
        nil];
    
      GreeJSShowRequestDialogCommand *command = [[GreeJSShowRequestDialogCommand alloc] init];

      UIViewController *viewController = [UIViewController nullMock];
      [[command stubAndReturn:viewController] viewControllerWithRequiredBaseClass:nil];
        
      KWMock *popup = [KWMock nullMockForClass:[GreeRequestServicePopup class]];
      KWCaptureSpy *dismissSpy = [popup captureArgument:@selector(setDidDismissBlock:) atIndex:0];
    
      [popup stub:@selector(initWithParameters:) andReturn:popup];
      [GreeRequestServicePopup stub:@selector(alloc) andReturn:popup];
       
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

    it(@"should return the popup result if there is a result", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"callback", @"callback",
        nil];
    
      GreeJSShowRequestDialogCommand *command = [[GreeJSShowRequestDialogCommand alloc] init];

      UIViewController *viewController = [UIViewController nullMock];
      [[command stubAndReturn:viewController] viewControllerWithRequiredBaseClass:nil];
        
      KWMock *popup = [KWMock nullMockForClass:[GreeRequestServicePopup class]];
      KWCaptureSpy *dismissSpy = [popup captureArgument:@selector(setDidDismissBlock:) atIndex:0];
    
      [popup stub:@selector(initWithParameters:) andReturn:popup];
      [[popup stubAndReturn:@"mockResults"] results];
      [GreeRequestServicePopup stub:@selector(alloc) andReturn:popup];
       
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive]
        callback:@"callback"
        params:[NSDictionary dictionaryWithObjectsAndKeys:
          @"close", @"result",
          @"mockResults", @"param",
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
