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
#import "GreeJSPopupNeedReAuthorizeCommand.h"
#import "GreePopup.h"
#import "GreePopupView.h"
#import "GreeAuthorization.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSPopupNeedReAuthorizeCommandTest)

describe(@"GreeJSPopupNeedReAuthorizeCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSPopupNeedReAuthorizeCommand name] should] equal:@"need_re_authorize"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSPopupNeedReAuthorizeCommand *command = [[GreeJSPopupNeedReAuthorizeCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSPopupNeedReAuthorizeCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"while executing", ^{
    it(@"should reauthorize", ^{
      GreeJSPopupNeedReAuthorizeCommand *command = [[GreeJSPopupNeedReAuthorizeCommand alloc] init];

      GreeAuthorization *authorization = [GreeAuthorization nullMock];
      [[[authorization should] receive] reAuthorize];
      [[GreeAuthorization stubAndReturn:authorization] sharedInstance];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:[GreePopup nullMock]] viewControllerForCommand:command];
      
      command.environment = environment;
      [command execute:nil];
      [command release];
    });

    it(@"should not cancel the popup if the delegate is not set", ^{
      GreeJSPopupNeedReAuthorizeCommand *command = [[GreeJSPopupNeedReAuthorizeCommand alloc] init];

      id delegate = [KWMock nullMockForProtocol:@protocol(GreePopupViewDelegate)];
      [[[delegate shouldNot] receive] popupViewDidCancel];

      GreePopupView *popupView = [GreePopupView nullMock];
      [popupView stub:@selector(delegate) andReturn:nil];
      
      GreePopup *popup = [GreePopup nullMock];
      [[popup stubAndReturn:popupView] popupView];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:popup] viewControllerForCommand:command];
      
      command.environment = environment;
      [command execute:nil];
      [command release];
    });

    it(@"should cancel the popup if the delegate is set", ^{
      GreeJSPopupNeedReAuthorizeCommand *command = [[GreeJSPopupNeedReAuthorizeCommand alloc] init];

      id delegate = [KWMock nullMockForProtocol:@protocol(GreePopupViewDelegate)];
      [[[delegate should] receive] popupViewDidCancel];

      GreePopupView *popupView = [GreePopupView nullMock];
      [popupView stub:@selector(delegate) andReturn:delegate];

      GreePopup *popup = [GreePopup nullMock];
      [[popup stubAndReturn:popupView] popupView];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:popup] viewControllerForCommand:command];
      
      command.environment = environment;
      [command execute:nil];
      [command release];
    });
        
  });
});

SPEC_END
