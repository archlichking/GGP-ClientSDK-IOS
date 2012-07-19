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
#import "GreeJSInputFailureCommand.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSInputFailureCommandTest)

describe(@"GreeJSInputFailureCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSInputFailureCommand name] should] equal:@"input_failure"]; 
  });
  
  it(@"should have a notification name", ^{
    [[[GreeJSInputFailureCommand notificationName] should] equal:@"GreeJSInputFailure"];     
  });
  
  it(@"should have a description", ^{
    GreeJSInputFailureCommand *command = [[GreeJSInputFailureCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSInputFailureCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should do nothing if the delegate does not respond to the stateCommandContentsReady selector", ^{
      GreeJSInputFailureCommand *command = [[GreeJSInputFailureCommand alloc] init];
    
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSStateCommandDelegate)];
      [environment stub:@selector(instanceOfProtocol:) andReturn:nil];
      
      command.environment = environment;
      [command execute:nil];
      [command release];
    });

    it(@"should send the stateCommandContentsReady message to its delegate", ^{
      GreeJSInputFailureCommand *command = [[GreeJSInputFailureCommand alloc] init];
      
      id myDelegate = [KWMock nullMockForProtocol:@protocol(GreeJSStateCommandDelegate)];
      [[[myDelegate should] receive] stateCommandInputFailure:nil];
    
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(instanceOfProtocol:) andReturn:myDelegate];
      
      command.environment = environment;
      [command execute:nil];
      [command release];
    });
  });
});

SPEC_END
