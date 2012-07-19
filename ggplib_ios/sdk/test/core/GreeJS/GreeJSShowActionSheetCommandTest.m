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
#import "GreeJSShowActionSheetCommand.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSShowActionSheetCommandTest)

describe(@"GreeJSShowActionSheetCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSShowActionSheetCommand name] should] equal:@"show_action_sheet"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSShowActionSheetCommand *command = [[GreeJSShowActionSheetCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSShowActionSheetCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should add buttons from the buttons parameter", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSArray arrayWithObject:@"mockButtonTitle"], @"buttons",
        nil];
    
      UIActionSheet *actionSheet = [UIActionSheet nullMock];
      [actionSheet stub:@selector(initWithTitle:delegate:cancelButtonTitle:destructiveButtonTitle:otherButtonTitles:) andReturn:actionSheet];
      [[actionSheet should] receive:@selector(addButtonWithTitle:)];
      [UIActionSheet stub:@selector(alloc) andReturn:actionSheet];

      GreeJSShowActionSheetCommand *command = [[GreeJSShowActionSheetCommand alloc] init];    
      [command execute:parameters];
      [command release];      
    });

    it(@"should set the cancel button index if one is specified", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInteger:1], @"destructive_index",
        nil];
    
      UIActionSheet *actionSheet = [UIActionSheet nullMock];
      [actionSheet stub:@selector(initWithTitle:delegate:cancelButtonTitle:destructiveButtonTitle:otherButtonTitles:) andReturn:actionSheet];
      [[actionSheet should] receive:@selector(setDestructiveButtonIndex:)];
      [UIActionSheet stub:@selector(alloc) andReturn:actionSheet];

      GreeJSShowActionSheetCommand *command = [[GreeJSShowActionSheetCommand alloc] init];    
      [command execute:parameters];
      [command release];      
    });

    it(@"should set the cancel button index if one is specified", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInteger:1], @"cancel_index",
        nil];
    
      UIActionSheet *actionSheet = [UIActionSheet nullMock];
      [actionSheet stub:@selector(initWithTitle:delegate:cancelButtonTitle:destructiveButtonTitle:otherButtonTitles:) andReturn:actionSheet];
      [[actionSheet should] receive:@selector(setCancelButtonIndex:)];
      [UIActionSheet stub:@selector(alloc) andReturn:actionSheet];

      GreeJSShowActionSheetCommand *command = [[GreeJSShowActionSheetCommand alloc] init];    
      [command execute:parameters];
      [command release];      
    });

    it(@"should callback when the alert view is dismissed", ^{
      NSDictionary *parameters = [NSDictionary dictionary];
    
      UIActionSheet *actionSheet = [UIActionSheet nullMock];
      [actionSheet stub:@selector(initWithTitle:message:delegate:cancelButtonTitle:destructiveButtonTitle:otherButtonTitles:) andReturn:actionSheet];
      [UIActionSheet stub:@selector(alloc) andReturn:actionSheet];

      GreeJSShowActionSheetCommand *command = [[GreeJSShowActionSheetCommand alloc] init];    
      [command execute:parameters];
      
      [[command should] receive:@selector(callback)];
      
      [command actionSheet:actionSheet didDismissWithButtonIndex:1];
      
      [command release];
    });
  });
});

SPEC_END
