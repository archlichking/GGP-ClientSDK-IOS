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
#import "GreeJSWebViewController.h"
#import "GreeJSCommand.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSCommandTest)

describe(@"GreeJSCommand",^{
  registerMatchers(@"Gree");
  it(@"should return nil for its name", ^{
    [[GreeJSCommand name] shouldBeNil];
  });
  
  it(@"should have a description", ^{
    GreeJSCommand *command = [[GreeJSCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should do nothing", ^{
      GreeJSCommand *command = [[GreeJSCommand alloc] init];    
      [command execute:nil];
      [command release];    
    });
  });
  
  context(@"when returning the required base view controller", ^{
    it(@"should throw an exception if the environment's view controller is not the required base", ^{
      GreeJSCommand *command = [[GreeJSCommand alloc] init];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:[UIViewController nullMock]] viewControllerForCommand:command];
      
      command.environment = environment;
      
      [[theBlock(^{
        [command viewControllerWithRequiredBaseClass:[GreeJSWebViewController class]];
      }) should] raise];
      
      [command release];
    });

    it(@"should return the view controller from the environment if it meets the requirement", ^{
      UIViewController *viewController = nil;
      
      GreeJSCommand *command = [[GreeJSCommand alloc] init];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:[GreeJSWebViewController nullMock]] viewControllerForCommand:command];
      
      command.environment = environment;
      
      viewController = [command viewControllerWithRequiredBaseClass:[GreeJSWebViewController class]];
      
      [[viewController should] beKindOfClass:[GreeJSWebViewController class]];
      
      [command release];
    });

    it(@"should use UIViewController if passed a nil value", ^{
      UIViewController *viewController = nil;
      
      GreeJSCommand *command = [[GreeJSCommand alloc] init];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:[UIViewController nullMock]] viewControllerForCommand:command];
      
      command.environment = environment;
      
      viewController = [command viewControllerWithRequiredBaseClass:nil];
      
      [[viewController should] beKindOfClass:[UIViewController class]];
      
      [command release];
    });
  });
  
  it(@"should return NO from the asynchronous command test", ^{
    GreeJSCommand *command = [[GreeJSCommand alloc] init];
    [[theValue([command isAsynchronousCommand]) should] beNo];
    [command release];
  });
});

SPEC_END
