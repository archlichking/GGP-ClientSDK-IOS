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
#import "GreeJSBatchCommand.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSBatchCommandTest)

describe(@"GreeJSBatchCommandTest",^{
  registerMatchers(@"Gree");

  it(@"should have a name", ^{
    [[[GreeJSBatchCommand name] should] equal:@"batch"]; 
  });
  

  it(@"should have a description", ^{
    GreeJSBatchCommand *command = [[GreeJSBatchCommand alloc] init];
    NSString *matchString = [NSString stringWithFormat:@"<GreeJSBatchCommand:0x[0-9a-f]+, environment:\\(null\\)>"];
    
    [[[command description] should] matchRegExp:matchString]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should do nothing if the command parameter is not an array", ^{
      [[GreeJSHandler shouldNot] receive:@selector(executeCommand:parameters:handler:environment:)];
      
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        [[[NSObject alloc] init] autorelease], @"commands",
        nil];
      
      GreeJSBatchCommand *command = [[GreeJSBatchCommand alloc] init];
      [command execute:parameters];
      [command release];
    });
    
    it(@"should not execute a command if the object is not a dictionary", ^{
      [[GreeJSHandler shouldNot] receive:@selector(executeCommand:parameters:handler:environment:)];
  
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSArray arrayWithObject:[[[NSObject alloc] init] autorelease]], @"commands",
        nil];
      
      GreeJSBatchCommand *command = [[GreeJSBatchCommand alloc] init];
      [command execute:parameters];
      [command release];
    });
    
    it(@"should not execute a command if the parameters are not a dictionary", ^{
      [[GreeJSHandler shouldNot] receive:@selector(executeCommand:parameters:handler:environment:)];
  
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSArray arrayWithObject:
          [NSDictionary dictionaryWithObjectsAndKeys:
            [[[NSObject alloc] init] autorelease], @"params",
            nil]] , @"commands", nil];
      
      GreeJSBatchCommand *command = [[GreeJSBatchCommand alloc] init];
      [command execute:parameters];
      [command release];
    });

    it(@"should not execute a command if the name is not registered in the command factory", ^{
      [[GreeJSHandler shouldNot] receive:@selector(executeCommand:parameters:handler:environment:)];
  
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSArray arrayWithObject:
          [NSDictionary dictionaryWithObjectsAndKeys:
            [NSDictionary dictionary], @"params",
            @"invalidName", @"command",
            nil]] , @"commands", nil];
      
      GreeJSBatchCommand *command = [[GreeJSBatchCommand alloc] init];
      [command execute:parameters];
      [command release];
    });

    it(@"should execute a command if the above criteria are met", ^{
      [[GreeJSHandler should] receive:@selector(executeCommand:parameters:handler:environment:)];
  
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSArray arrayWithObject:
          [NSDictionary dictionaryWithObjectsAndKeys:
            [NSDictionary dictionary], @"params",
            @"batch", @"command",
            nil]] , @"commands", nil];
      
      GreeJSBatchCommand *command = [[GreeJSBatchCommand alloc] init];
      [command execute:parameters];
      [command release];
    });
  });

});

SPEC_END
