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
#import "GreeJSShowModalViewCommand.h"
#import "UIViewController+GreeAdditions.h"
#import "GreeJSModalNavigationController.h"
#import "UIImage+GreeAdditions.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSShowModalViewCommandTest)

describe(@"GreeJSShowModalViewCommand",^{
  registerMatchers(@"Gree");
  
  it(@"should have a name", ^{
    [[[GreeJSShowModalViewCommand name] should] equal:@"show_modal_view"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSShowModalViewCommand *command = [[GreeJSShowModalViewCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSShowModalViewCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });

  context(@"when executing", ^{
    beforeEach(^{
      [[UIBarButtonItem stub] alloc];
      [UIImage stub:@selector(greeImageNamed:)];
    });
  
    it(@"should do nothing if the last presented view controller is a GreeJSModalNavigationController", ^{
      [UIViewController stub:@selector(greeLastPresentedViewController) andReturn:[GreeJSModalNavigationController nullMock]];

      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
  
      id environment = [KWMock mockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSShowModalViewCommand *command = [[GreeJSShowModalViewCommand alloc] init];
      command.environment = environment;
      [[command shouldNot] receive:@selector(createModalNavigationController:params:)];
      [command execute:nil];
      [command release];
    });
    
    it(@"should force the nextViewController to load if it is ready", ^{
      [UIViewController stub:@selector(greeLastPresentedViewController) andReturn:[UIViewController nullMock]];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [handler stub:@selector(isReady) andReturn:theValue(YES)];
      [[handler should] receive:@selector(forceLoadView:params:options:)];
      
      GreeJSWebViewController *nextViewController = [GreeJSWebViewController nullMock];
      [nextViewController stub:@selector(handler) andReturn:handler];
      
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [nextViewController stub:@selector(beforeWebViewController) andReturn:currentViewController];
      [currentViewController stub:@selector(preloadNextWebViewController) andReturn:nextViewController];
      
      id environment = [KWMock mockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSShowModalViewCommand *command = [[GreeJSShowModalViewCommand alloc] init];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });

    it(@"should set a pending request if the next view controller is not ready", ^{
      [UIViewController stub:@selector(greeLastPresentedViewController) andReturn:[UIViewController nullMock]];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [handler stub:@selector(isReady) andReturn:theValue(NO)];
      
      GreeJSWebViewController *nextViewController = [GreeJSWebViewController nullMock];
      [nextViewController stub:@selector(handler) andReturn:handler];
      [[nextViewController should] receive:@selector(setPendingLoadRequest:params:options:)];
      
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [nextViewController stub:@selector(beforeWebViewController) andReturn:currentViewController];
      [currentViewController stub:@selector(preloadNextWebViewController) andReturn:nextViewController];
      
      id environment = [KWMock mockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSShowModalViewCommand *command = [[GreeJSShowModalViewCommand alloc] init];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });
    
    it(@"should reinitialize proton if a deadly error occurs", ^{
      [UIViewController stub:@selector(greeLastPresentedViewController) andReturn:[UIViewController nullMock]];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [handler stub:@selector(isReady) andReturn:theValue(NO)];
      
      GreeJSWebViewController *nextViewController = [GreeJSWebViewController nullMock];
      [nextViewController stub:@selector(handler) andReturn:handler];
      [nextViewController stub:@selector(deadlyProtonErrorOccured) andReturn:theValue(YES)];
      [[nextViewController should] receive:@selector(retryToInitializeProton)];
      
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [nextViewController stub:@selector(beforeWebViewController) andReturn:currentViewController];
      [currentViewController stub:@selector(preloadNextWebViewController) andReturn:nextViewController];
      
      id environment = [KWMock mockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSShowModalViewCommand *command = [[GreeJSShowModalViewCommand alloc] init];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });
    
    it(@"should be configurable with a namespace and method", ^{
      NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockNamespace", @"ns",
        @"mockMethod", @"method",
        nil];
    
      [UIViewController stub:@selector(greeLastPresentedViewController) andReturn:[UIViewController nullMock]];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [handler stub:@selector(isReady) andReturn:theValue(YES)];
      
      GreeJSWebViewController *nextViewController = [GreeJSWebViewController nullMock];
      [nextViewController stub:@selector(handler) andReturn:handler];
      [[nextViewController should] receive:@selector(setModalRightButtonCallback:)];
      [[nextViewController should] receive:@selector(setModalRightButtonCallbackInfo:)];
      
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [nextViewController stub:@selector(beforeWebViewController) andReturn:currentViewController];
      [currentViewController stub:@selector(preloadNextWebViewController) andReturn:nextViewController];
      
      id environment = [KWMock mockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSShowModalViewCommand *command = [[GreeJSShowModalViewCommand alloc] init];
      command.environment = environment;
      [command execute:params];
      [command release];
    });
  });
});

SPEC_END
