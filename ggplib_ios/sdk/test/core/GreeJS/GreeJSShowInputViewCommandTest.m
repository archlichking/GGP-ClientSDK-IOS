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
#import "GreeJSShowInputViewCommand.h"
#import "GreeJSFormViewController.h"
#import "GreeJSInputViewController.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSShowInputViewCommandTest)

describe(@"GreeJSShowInputViewCommand",^{
  registerMatchers(@"Gree");
  
  it(@"should have a name", ^{
    [[[GreeJSShowInputViewCommand name] should] equal:@"show_input_view"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSShowInputViewCommand *command = [[GreeJSShowInputViewCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSShowInputViewCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });

  context(@"when executing", ^{    
    it(@"should do nothing if the last presented view controller is a GreeJSModalNavigationController", ^{
      [UIViewController stub:@selector(greeLastPresentedViewController) andReturn:[GreeJSModalNavigationController nullMock]];

      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
  
      id environment = [KWMock mockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSShowInputViewCommand *command = [[GreeJSShowInputViewCommand alloc] init];
      command.environment = environment;
      [[command shouldNot] receive:@selector(showModalView:)];
      [command execute:nil];
      [command release];
    });
    
    it(@"should set the input view controller to form view controller if the parameters have 'form' as the type", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"form", @"type", nil];
      
      [[GreeJSFormViewController should] receive:@selector(alloc)];
    
      [UIViewController stub:@selector(greeLastPresentedViewController) andReturn:[UIViewController nullMock]];

      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
  
      id environment = [KWMock mockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSShowInputViewCommand *command = [[GreeJSShowInputViewCommand alloc] init];
      command.environment = environment;
      [command execute:parameters];
      [command release];
    });    

    it(@"should set the input view controller to input view controller if the parameters have any other type (or no type)", ^{
      NSDictionary *parameters = [NSDictionary dictionary];
      
      [[GreeJSInputViewController should] receive:@selector(alloc)];
    
      [UIViewController stub:@selector(greeLastPresentedViewController) andReturn:[UIViewController nullMock]];

      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
  
      id environment = [KWMock mockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSShowInputViewCommand *command = [[GreeJSShowInputViewCommand alloc] init];
      command.environment = environment;
      [command execute:parameters];
      [command release];
    });    

    it(@"should show the modal view", ^{
      NSDictionary *parameters = [NSDictionary dictionary];
      
      [[GreeJSInputViewController should] receive:@selector(alloc)];
    
      [UIViewController stub:@selector(greeLastPresentedViewController) andReturn:[UIViewController nullMock]];

      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [[currentViewController should] receive:@selector(greeJSPresentModalNavigationController:animated:)];
  
      id environment = [KWMock mockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSShowInputViewCommand *command = [[GreeJSShowInputViewCommand alloc] init];
      command.environment = environment;
      [[command should] receive:@selector(showModalView:)];
      [command execute:parameters];
      [command release];
    }); 
  });
});

SPEC_END
