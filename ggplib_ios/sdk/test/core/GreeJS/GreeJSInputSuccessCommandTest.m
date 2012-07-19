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
#import "GreeJSInputSuccessCommand.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSInputSuccessCommandTest)

describe(@"GreeJSInputSuccessCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSInputSuccessCommand name] should] equal:@"input_success"]; 
  });
  
  it(@"should have a notification name", ^{
    [[[GreeJSInputSuccessCommand notificationName] should] equal:@"GreeJSInputSuccess"];     
  });
  
  it(@"should have a description", ^{
    GreeJSInputSuccessCommand *command = [[GreeJSInputSuccessCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSInputSuccessCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should do nothing if the delegate does not respond to the stateCommandContentsReady selector", ^{
      GreeJSInputSuccessCommand *command = [[GreeJSInputSuccessCommand alloc] init];
    
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSStateCommandDelegate)];
      [environment stub:@selector(instanceOfProtocol:) andReturn:nil];
      
      command.environment = environment;
      [command execute:nil];
      [command release];
    });

    it(@"should send the stateCommandContentsReady message to its delegate", ^{
      GreeJSInputSuccessCommand *command = [[GreeJSInputSuccessCommand alloc] init];
      
      id myDelegate = [KWMock nullMockForProtocol:@protocol(GreeJSStateCommandDelegate)];
      [[[myDelegate should] receive] stateCommandInputSuccess:nil];
    
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(instanceOfProtocol:) andReturn:myDelegate];
      
      command.environment = environment;
      [command execute:nil];
      [command release];
    });
  });
});

SPEC_END
