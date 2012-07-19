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
#import "GreeJSPopupCloseSharePopupCommand.h"
#import "GreePopup.h"
#import "GreePopupView.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSPopupCloseSharePopupCommandTest)

describe(@"GreeJSPopupCloseSharePopupCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSPopupCloseSharePopupCommand name] should] equal:@"close_popup"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSPopupCloseSharePopupCommand *command = [[GreeJSPopupCloseSharePopupCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSPopupCloseSharePopupCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should not cancel the popup if the delegate is not set", ^{
      GreeJSPopupCloseSharePopupCommand *command = [[GreeJSPopupCloseSharePopupCommand alloc] init];

      id delegate = [KWMock nullMockForProtocol:@protocol(GreePopupViewDelegate)];
      [[[delegate shouldNot] receive] popupViewDidComplete:nil];

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
      GreeJSPopupCloseSharePopupCommand *command = [[GreeJSPopupCloseSharePopupCommand alloc] init];

      id delegate = [KWMock nullMockForProtocol:@protocol(GreePopupViewDelegate)];
      [[[delegate should] receive] popupViewDidComplete:nil];

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
