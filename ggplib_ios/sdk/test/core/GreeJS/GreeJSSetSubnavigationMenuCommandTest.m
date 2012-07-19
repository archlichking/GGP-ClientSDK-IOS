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
#import "GreeJSSetSubnavigationMenuCommand.h"
#import "GreeJSWebViewController+SubNavigation.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSSetSubnavigationMenuCommandTest)

describe(@"GreeJSSetSubnavigationMenuCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSSetSubnavigationMenuCommand name] should] equal:@"set_subnavigation"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSSetSubnavigationMenuCommand *command = [[GreeJSSetSubnavigationMenuCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSSetSubnavigationMenuCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should throw an exception if the current view controller is not a GreeJSWebViewController", ^{
      GreeJSSetSubnavigationMenuCommand *command = [[GreeJSSetSubnavigationMenuCommand alloc] init];
    
      UIViewController *currentViewController = [UIViewController nullMock];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:currentViewController] viewControllerForCommand:command];
      command.environment = environment;
      [[theBlock(^{
        [command execute:nil];
      }) should] raiseWithName:@"NSInternalInconsistencyException"];
      [command release];
    });

    it(@"should configure the subnavigation menu", ^{
      GreeJSSetSubnavigationMenuCommand *command = [[GreeJSSetSubnavigationMenuCommand alloc] init];
    
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [[[currentViewController should] receive] configureSubnavigationMenuWithParams:nil];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:currentViewController] viewControllerForCommand:command];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });
  });
});

SPEC_END
