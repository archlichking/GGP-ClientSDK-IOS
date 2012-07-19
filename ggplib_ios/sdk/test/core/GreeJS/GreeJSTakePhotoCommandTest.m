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
#import "GreeJSTakePhotoCommand.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSTakePhotoCommandTest)

describe(@"GreeJSTakePhotoCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSTakePhotoCommand name] should] equal:@"take_photo"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSTakePhotoCommand *command = [[GreeJSTakePhotoCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSTakePhotoCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
        it(@"should throw an exception if the current view controller is not a GreeJSWebViewController", ^{
      GreeJSTakePhotoCommand *command = [[GreeJSTakePhotoCommand alloc] init];
    
      UIViewController *currentViewController = [UIViewController nullMock];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:currentViewController] viewControllerForCommand:command];
      command.environment = environment;
      [[theBlock(^{
        [command execute:nil];
      }) should] raiseWithName:@"NSInternalInconsistencyException"];
      [command release];
    });

    it(@"should show the photo viewer if the current view controller is a GreeJSWebViewController", ^{
      GreeJSTakePhotoCommand *command = [[GreeJSTakePhotoCommand alloc] init];
    
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [[[currentViewController should] receive] greeJSShowTakePhotoSelector:nil];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:currentViewController] viewControllerForCommand:command];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });
  });
});

SPEC_END
