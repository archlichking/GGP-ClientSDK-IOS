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
#import "GreeJSShowAlertViewCommand.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSShowAlertViewCommandTest)

describe(@"GreeJSShowAlertViewCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSShowAlertViewCommand name] should] equal:@"show_alert_view"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSShowAlertViewCommand *command = [[GreeJSShowAlertViewCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSShowAlertViewCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should add buttons from the buttons parameter", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSArray arrayWithObject:@"mockButtonTitle"], @"buttons",
        nil];
    
      UIAlertView *alertView = [UIAlertView nullMock];
      [alertView stub:@selector(initWithTitle:message:delegate:cancelButtonTitle:otherButtonTitles:) andReturn:alertView];
      [[alertView should] receive:@selector(addButtonWithTitle:)];
      [UIAlertView stub:@selector(alloc) andReturn:alertView];

      GreeJSShowAlertViewCommand *command = [[GreeJSShowAlertViewCommand alloc] init];    
      [command execute:parameters];
      [command release];      
    });

    it(@"should set the cancel button index if one is specified", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInteger:1], @"cancel_index",
        nil];
    
      UIAlertView *alertView = [UIAlertView nullMock];
      [alertView stub:@selector(initWithTitle:message:delegate:cancelButtonTitle:otherButtonTitles:) andReturn:alertView];
      [[alertView should] receive:@selector(setCancelButtonIndex:)];
      [UIAlertView stub:@selector(alloc) andReturn:alertView];

      GreeJSShowAlertViewCommand *command = [[GreeJSShowAlertViewCommand alloc] init];    
      [command execute:parameters];
      [command release];      
    });

    it(@"should callback when the alert view is dismissed", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInteger:1], @"cancel_index",
        nil];
    
      UIAlertView *alertView = [UIAlertView nullMock];
      [alertView stub:@selector(initWithTitle:message:delegate:cancelButtonTitle:otherButtonTitles:) andReturn:alertView];
      [[alertView should] receive:@selector(setCancelButtonIndex:)];
      [UIAlertView stub:@selector(alloc) andReturn:alertView];

      GreeJSShowAlertViewCommand *command = [[GreeJSShowAlertViewCommand alloc] init];    
      [command execute:parameters];
      
      [[command should] receive:@selector(callback)];
      
      [command alertView:alertView clickedButtonAtIndex:0];
      
      [command release];
    });
  });
});

SPEC_END
