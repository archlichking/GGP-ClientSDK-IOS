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
#import "GreeJSPushViewCommand.h"
#import "GreeJSWebViewController.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSPushViewCommandTest)

describe(@"GreeJSPushViewCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSPushViewCommand name] should] equal:@"push_view"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSPushViewCommand *command = [[GreeJSPushViewCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSPushViewCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should do nothing if the current view controller has a next view controller", ^{
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [currentViewController stub:@selector(nextWebViewController) andReturn:[GreeJSWebViewController nullMock]];
      [[[currentViewController shouldNot] receive] navigationController];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSPushViewCommand *command = [[GreeJSPushViewCommand alloc] init];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });

    it(@"should do nothing if the current view controller has a next view controller", ^{
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [currentViewController stub:@selector(nextWebViewController) andReturn:[GreeJSWebViewController nullMock]];
      [[[currentViewController shouldNot] receive] navigationController];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSPushViewCommand *command = [[GreeJSPushViewCommand alloc] init];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });

    it(@"should do nothing if the current view controller has a next view controller", ^{
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [currentViewController stub:@selector(nextWebViewController) andReturn:[GreeJSWebViewController nullMock]];
      [[[currentViewController shouldNot] receive] navigationController];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSPushViewCommand *command = [[GreeJSPushViewCommand alloc] init];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });

    it(@"should force the view to load if the next view controller is ready", ^{
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [handler stub:@selector(isReady) andReturn:theValue(YES)];
      [[handler should] receive:@selector(forceLoadView:params:options:)];

      GreeJSWebViewController *nextViewController = [GreeJSWebViewController nullMock];
      [nextViewController stub:@selector(handler) andReturn:handler];
    
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [currentViewController stub:@selector(nextWebViewController) andReturn:nil];
      [currentViewController stub:@selector(preloadNextWebViewController) andReturn:nextViewController];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSPushViewCommand *command = [[GreeJSPushViewCommand alloc] init];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });

    it(@"should set the pending load request if the view controller is not ready", ^{
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [handler stub:@selector(isReady) andReturn:theValue(NO)];

      GreeJSWebViewController *nextViewController = [GreeJSWebViewController nullMock];
      [nextViewController stub:@selector(handler) andReturn:handler];
      [[nextViewController should] receive:@selector(setPendingLoadRequest:params:options:)];
    
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [currentViewController stub:@selector(nextWebViewController) andReturn:nil];
      [currentViewController stub:@selector(preloadNextWebViewController) andReturn:nextViewController];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSPushViewCommand *command = [[GreeJSPushViewCommand alloc] init];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });

    it(@"should reinitialize proton on the next view controller if it has a deadly error", ^{
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [handler stub:@selector(isReady) andReturn:theValue(NO)];

      GreeJSWebViewController *nextViewController = [GreeJSWebViewController nullMock];
      [nextViewController stub:@selector(handler) andReturn:handler];
      [nextViewController stub:@selector(deadlyProtonErrorOccured) andReturn:theValue(YES)];
      [[nextViewController should] receive:@selector(retryToInitializeProton)];
    
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [currentViewController stub:@selector(nextWebViewController) andReturn:nil];
      [currentViewController stub:@selector(preloadNextWebViewController) andReturn:nextViewController];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSPushViewCommand *command = [[GreeJSPushViewCommand alloc] init];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });

    it(@"should reinitialize proton on the next view controller if it has a deadly error", ^{
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [handler stub:@selector(isReady) andReturn:theValue(NO)];

      GreeJSWebViewController *nextViewController = [GreeJSWebViewController nullMock];
      [nextViewController stub:@selector(handler) andReturn:handler];
      [nextViewController stub:@selector(deadlyProtonErrorOccured) andReturn:theValue(YES)];
      [[nextViewController should] receive:@selector(retryToInitializeProton)];
    
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [currentViewController stub:@selector(nextWebViewController) andReturn:nil];
      [currentViewController stub:@selector(preloadNextWebViewController) andReturn:nextViewController];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSPushViewCommand *command = [[GreeJSPushViewCommand alloc] init];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });

    it(@"should push the next view controller", ^{      
      GreeJSWebViewController *nextViewController = [GreeJSWebViewController nullMock];    
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [currentViewController stub:@selector(nextWebViewController) andReturn:nil];
      [currentViewController stub:@selector(preloadNextWebViewController) andReturn:nextViewController];
      
      UINavigationController *navigationController = [UINavigationController nullMock];
      [[[navigationController should] receive] pushViewController:nextViewController animated:YES];
      
      [currentViewController stub:@selector(navigationController) andReturn:navigationController];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSPushViewCommand *command = [[GreeJSPushViewCommand alloc] init];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });
  });
});

SPEC_END
