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
#import "GreeJSCloseCommand.h"
#import "GreeJSWebViewController.h"
#import "GreeNSNotification.h"
#import "GreeNotificationBoardViewController.h"
#import "GreePopup.h"
#import "GreePopupView.h"

SPEC_BEGIN(GreeJSCloseCommandTest)

describe(@"GreeJSCloseCommandTest",^{

  it(@"should have a name", ^{
    [[[GreeJSCloseCommand name] should] equal:@"close"]; 
  });
  
  it(@"execute close command with popup", ^{  
    NSDictionary* aResult = [NSDictionary dictionaryWithObjectsAndKeys:@"value", @"key", nil];

    GreePopup* popup = [GreePopup nullMock];
    [[popup should] receive:@selector(popupViewDidComplete:)];
    GreePopupView* popupView = [GreePopupView nullMock];
    
    [popup stub:@selector(popupView) andReturn:popupView];
    [popupView stub:@selector(delegate) andReturn:popup];
    
    id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
    [environment stub:@selector(viewControllerForCommand:) andReturn:popup];
                              
    GreeJSCloseCommand *command = [[GreeJSCloseCommand alloc] init];
    command.environment = environment;
    [command execute:aResult];    
    [command release];
  });
  
  it(@"execute close command with notification board", ^{  
    GreeJSCloseCommand *command = [[GreeJSCloseCommand alloc] init];
    NSDictionary* aResult = [NSDictionary dictionaryWithObjectsAndKeys:@"value", @"key", nil];
    
    GreeNotificationBoardViewController* viewController = [[GreeNotificationBoardViewController alloc] init];
    [[viewController should] receive:@selector(handler)];
    [[viewController should] receive:@selector(viewControllerForCommand:)];
    command.environment = (id)viewController;
    
    [command execute:aResult];
    
    [viewController release];
    [command release];
  });

 
  it(@"execute close command with dashboard", ^{
    GreeJSCloseCommand *command = [[GreeJSCloseCommand alloc] init];
    NSDictionary* aResult = [NSDictionary dictionaryWithObjectsAndKeys:@"value", @"key", nil];
    
    GreeJSWebViewController* viewController = [GreeJSWebViewController mock];
    [[viewController should] receive:@selector(handler)];
    [[viewController should] receive:@selector(viewControllerForCommand:)];
    command.environment = (id)viewController;
    
    [command execute:aResult];
    
    [viewController release];
    [command release];
  });

  it(@"should have a description", ^{
    GreeJSCloseCommand *command = [[GreeJSCloseCommand alloc] init];
    
    NSString* checkString = [NSString stringWithFormat:@"<GreeJSCloseCommand:%p environment:(null)>",
                             command];
    
    [[[command description] should] equal:checkString]; 
    [command release];
  });
  
});

SPEC_END
