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
#import "GreeJSDeleteCookieCommand.h"
#import "GreeSettings.h"
#import "GreePlatform.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSDeleteCookieCommandTest)

describe(@"GreeJSDeleteCookieCommand",^{
  registerMatchers(@"Gree");
  
  it(@"should have a name", ^{
    [[[GreeJSDeleteCookieCommand name] should] equal:@"delete_cookie"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSDeleteCookieCommand *command = [[GreeJSDeleteCookieCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSDeleteCookieCommand:0x[0-9a-f]+ environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should report that it did not succeed if it did not succeed", ^{
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive] callback:nil params:[NSDictionary dictionaryWithObject:@"error" forKey:@"result"]];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(handler) andReturn:handler];
    
      GreeJSDeleteCookieCommand *command = [[GreeJSDeleteCookieCommand alloc] init];    
      command.environment = environment;
      [command execute:nil];
      [command release];
    });

    it(@"should not success if the domain can not be parsed", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"mockKey", @"key", nil];
    
      GreeSettings *settings = [GreeSettings nullMock];
      [settings stub:@selector(objectValueForSetting:)
        andReturn:[NSArray arrayWithObject:
          [NSDictionary dictionaryWithObjectsAndKeys:
            @"mockKey", @"key",
            @"*", @"domain",
            [NSArray array], @"names",
            nil]]];
      
      GreePlatform *platform = [GreePlatform nullMock];
      [platform stub:@selector(settings) andReturn:settings];
       
      [GreePlatform stub:@selector(sharedInstance) andReturn:platform];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive] callback:nil params:[NSDictionary dictionaryWithObject:@"error" forKey:@"result"]];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(handler) andReturn:handler];
    
      GreeJSDeleteCookieCommand *command = [[GreeJSDeleteCookieCommand alloc] init];    
      command.environment = environment;
      [command execute:parameters];
      [command release];
    });
    
    it(@"should report that it succeeded if the process succeeded", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"mockKey", @"key", nil];
    
      GreeSettings *settings = [GreeSettings nullMock];
      [settings stub:@selector(objectValueForSetting:)
        andReturn:[NSArray arrayWithObject:
          [NSDictionary dictionaryWithObjectsAndKeys:
            @"mockKey", @"key",
            @"mockDomain", @"domain",
            [NSArray array], @"names",
            nil]]];
      
      GreePlatform *platform = [GreePlatform nullMock];
      [platform stub:@selector(settings) andReturn:settings];
       
      [GreePlatform stub:@selector(sharedInstance) andReturn:platform];
      
      GreeJSHandler *handler = [GreeJSHandler nullMock];
      [[[handler should] receive] callback:nil params:[NSDictionary dictionaryWithObject:@"success" forKey:@"result"]];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(handler) andReturn:handler];
    
      GreeJSDeleteCookieCommand *command = [[GreeJSDeleteCookieCommand alloc] init];    
      command.environment = environment;
      [command execute:parameters];
      [command release];
    });
  });
});

SPEC_END
