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
#import "GreeJSAsyncCommand.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSAsyncCommandTest)

describe(@"GreeJSCommand",^{
  registerMatchers(@"Gree");
  it(@"should return nil for its name", ^{
    [[GreeJSAsyncCommand name] shouldBeNil];
  });
  
  it(@"should have a description", ^{
    GreeJSAsyncCommand *command = [[GreeJSAsyncCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSAsyncCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  it(@"should report that it is completed to the enviromment, when its callback method is used", ^{
    GreeJSAsyncCommand *command = [[GreeJSAsyncCommand alloc] init];    
    
    GreeJSHandler *handler = [GreeJSHandler nullMock];
    [[[handler should] receive] onCommandCompleted:command];
    
    id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
    [[environment stubAndReturn:handler] handler];
    
    command.environment = environment;
    
    [command callback];
    [command release];
  });

  it(@"should abort", ^{
    GreeJSAsyncCommand *command = [[GreeJSAsyncCommand alloc] init];    
    
    [[[[NSNotificationCenter defaultCenter] should] receive] removeObserver:command];
    
    [command abort];
    [command release];
  });

  it(@"should return YES to the isAsynchronousCommand method", ^{
    GreeJSAsyncCommand *command = [[GreeJSAsyncCommand alloc] init];    
    [[theValue([command isAsynchronousCommand]) should] beYes];
    [command release];
  });
});

SPEC_END
