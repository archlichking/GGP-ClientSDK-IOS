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
#import "GreeJSFailedWithErrorCommand.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSFailedWithErrorCommandTest)

describe(@"GreeJSFailedWithErrorCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSFailedWithErrorCommand name] should] equal:@"failed_with_error"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSFailedWithErrorCommand *command = [[GreeJSFailedWithErrorCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSFailedWithErrorCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should do nothing if the delegate does not implement the stateCommandFailedWithError: method", ^{    
      id delegate = [NSObject nullMock];
      [[delegate shouldNot] receive:@selector(stateCommandFailedWithError:)];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(instanceOfProtocol:) andReturn:delegate];
      
      GreeJSFailedWithErrorCommand *command = [[GreeJSFailedWithErrorCommand alloc] init];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });

    it(@"should report failure to the delegate", ^{    
      id delegate = [KWMock nullMockForProtocol:@protocol(GreeJSStateCommandDelegate)];
      [[[delegate should] receive] stateCommandFailedWithError:nil];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(instanceOfProtocol:) andReturn:delegate];
      
      GreeJSFailedWithErrorCommand *command = [[GreeJSFailedWithErrorCommand alloc] init];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });

    it(@"should report failure to the delegate and pass the error dictionary", ^{    
      id delegate = [KWMock nullMockForProtocol:@protocol(GreeJSStateCommandDelegate)];
      [[[delegate should] receive] stateCommandFailedWithError:[NSDictionary dictionary]];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(instanceOfProtocol:) andReturn:delegate];
      
      GreeJSFailedWithErrorCommand *command = [[GreeJSFailedWithErrorCommand alloc] init];
      command.environment = environment;
      [command execute:[NSDictionary dictionaryWithObjectsAndKeys:
        [NSDictionary dictionary], @"error", nil]];
      [command release];
    });
  });
});

SPEC_END
