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
#import "GreeJSPopViewCommand.h"
#import "GreeJSWebViewController.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSPopViewCommandTest)

describe(@"GreeJSPopViewCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSPopViewCommand name] should] equal:@"pop_view"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSPopViewCommand *command = [[GreeJSPopViewCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSPopViewCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should pop to the previous view controller", ^{
      GreeJSWebViewController *beforeWebViewController = [GreeJSWebViewController nullMock];
      UINavigationController *navigationController = [UINavigationController nullMock];
      [[[navigationController should] receive] popToViewController:beforeWebViewController animated:YES];
      
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [currentViewController stub:@selector(beforeWebViewController) andReturn:beforeWebViewController];
      [currentViewController stub:@selector(navigationController) andReturn:navigationController];
    
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSPopViewCommand *command = [[GreeJSPopViewCommand alloc] init];    
      command.environment = environment;
      [command execute:nil];
      [command release];      
    });

    it(@"should pop one view controller if the count is one", ^{    
      GreeJSWebViewController *beforeBeforeViewController = [GreeJSWebViewController nullMock];
    
      GreeJSWebViewController *beforeWebViewController = [GreeJSWebViewController nullMock];
      [beforeWebViewController stub:@selector(beforeWebViewController) andReturn:beforeBeforeViewController];
            
      UINavigationController *navigationController = [UINavigationController nullMock];
      [[[navigationController should] receive] popToViewController:beforeWebViewController animated:YES];
      
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [currentViewController stub:@selector(beforeWebViewController) andReturn:beforeWebViewController];
      [currentViewController stub:@selector(navigationController) andReturn:navigationController];
    
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSPopViewCommand *command = [[GreeJSPopViewCommand alloc] init];    
      command.environment = environment;
      [command execute:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"count"]];
      [command release];      
    });

    it(@"should pop two view controllers if the count is 2", ^{
      GreeJSWebViewController *beforeBeforeViewController = [GreeJSWebViewController nullMock];
    
      GreeJSWebViewController *beforeWebViewController = [GreeJSWebViewController nullMock];
      [beforeWebViewController stub:@selector(beforeWebViewController) andReturn:beforeBeforeViewController];
      
      UINavigationController *navigationController = [UINavigationController nullMock];
      [[[navigationController should] receive] popToViewController:beforeBeforeViewController animated:YES];
      
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [currentViewController stub:@selector(beforeWebViewController) andReturn:beforeWebViewController];
      [currentViewController stub:@selector(navigationController) andReturn:navigationController];
    
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSPopViewCommand *command = [[GreeJSPopViewCommand alloc] init];    
      command.environment = environment;
      [command execute:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:2] forKey:@"count"]];
      [command release];      
    });
    
    it(@"should go to the beginning if there is a count is negative", ^{
      GreeJSWebViewController *beforeBeforeBeforeViewController = [GreeJSWebViewController nullMock];

      GreeJSWebViewController *beforeBeforeViewController = [GreeJSWebViewController nullMock];
      [beforeBeforeViewController stub:@selector(beforeWebViewController) andReturn:beforeBeforeBeforeViewController];
    
      GreeJSWebViewController *beforeWebViewController = [GreeJSWebViewController nullMock];
      [beforeWebViewController stub:@selector(beforeWebViewController) andReturn:beforeBeforeViewController];
      
      UINavigationController *navigationController = [UINavigationController nullMock];
      [[[navigationController should] receive] popToViewController:beforeBeforeBeforeViewController animated:YES];
      
      GreeJSWebViewController *currentViewController = [GreeJSWebViewController nullMock];
      [currentViewController stub:@selector(beforeWebViewController) andReturn:beforeWebViewController];
      [currentViewController stub:@selector(navigationController) andReturn:navigationController];
    
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:currentViewController];
      
      GreeJSPopViewCommand *command = [[GreeJSPopViewCommand alloc] init];    
      command.environment = environment;
      [command execute:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:-1] forKey:@"count"]];
      [command release];      
    });
  });
});

SPEC_END
