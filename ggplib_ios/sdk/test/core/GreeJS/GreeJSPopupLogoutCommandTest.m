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
#import "GreeJSPopupLogoutCommand.h"

#pragma mark - GreeJSPopupLogoutCommandTest

SPEC_BEGIN(GreeJSPopupLogoutCommandTest)

describe(@"GreeJSPopupLogoutCommandTest",^{

  it(@"execute logout", ^{    
    GreeJSPopupLogoutCommand *command = [[GreeJSPopupLogoutCommand alloc] init];
    [command execute:nil];
    [command release];
  });
  
  it(@"should have a description", ^{
    GreeJSPopupLogoutCommand *command = [[GreeJSPopupLogoutCommand alloc] init];
    
    NSString* checkString = [NSString stringWithFormat:@"<GreeJSPopupLogoutCommand:%p>",
                             command];
    
    [[[command description] should] equal:checkString]; 
    [command release];
  });
  
  it(@"should have a name", ^{      
    [[[GreeJSPopupLogoutCommand name] should] equal:@"logout"]; 
  });

});

SPEC_END
