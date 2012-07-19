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
#import "GreeJSSetViewTitleCommand.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSSetViewTitleCommandTest)

describe(@"GreeJSSetViewTitleCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSSetViewTitleCommand name] should] equal:@"set_view_title"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSSetViewTitleCommand *command = [[GreeJSSetViewTitleCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSSetViewTitleCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should not set the navigation item title if no title parameter is given", ^{
      GreeJSSetViewTitleCommand *command = [[GreeJSSetViewTitleCommand alloc] init];
    
      UINavigationItem *navigationItem = [UINavigationItem nullMock];
      [[navigationItem shouldNot] receive:@selector(setTitle:)];
      
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [[currentViewController stubAndReturn:navigationItem] navigationItem];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:currentViewController] viewControllerForCommand:command];
      
      command.environment = environment;
      [command execute:nil];
      [command release];
    });

    it(@"should set the navigation item's title to the value in the title parameter", ^{
      GreeJSSetViewTitleCommand *command = [[GreeJSSetViewTitleCommand alloc] init];
    
      UINavigationItem *navigationItem = [UINavigationItem nullMock];
      [[[navigationItem should] receive] setTitle:@"mockTitle"];
      
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [[currentViewController stubAndReturn:navigationItem] navigationItem];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [[environment stubAndReturn:currentViewController] viewControllerForCommand:command];
      
      command.environment = environment;
      [command execute:[NSDictionary dictionaryWithObject:@"mockTitle" forKey:@"title"]];
      [command release];
    });
  });
});

SPEC_END
