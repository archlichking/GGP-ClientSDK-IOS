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
#import "GreeJSInviteExternalUserCommand.h"
#import "UIViewController+GreePlatform.h"
#import "UIViewController+GreeAdditions.h"
#import "GreePopup.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSInviteExternalUserCommandTest)

describe(@"GreeJSInviteExternalUserCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSInviteExternalUserCommand name] should] equal:@"invite_external_user"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSInviteExternalUserCommand *command = [[GreeJSInviteExternalUserCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSInviteExternalUserCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should dismiss the current popup", ^{
      UIViewController *hostViewController = [UIViewController nullMock];
      [[[hostViewController should] receive] dismissGreePopup];
      
      GreePopup *popup = [GreePopup nullMock];
      [popup stub:@selector(hostViewController) andReturn:hostViewController];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:popup];
      
      GreeJSInviteExternalUserCommand *command = [[GreeJSInviteExternalUserCommand alloc] init];
      command.environment = environment;
      [command execute:nil];
      [command release];
    });

    it(@"should present the dashboard when the popup is finished dismissing", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockURL://", @"URL",
        nil];
    
      UIViewController *hostViewController = [UIViewController nullMock];
      [[[hostViewController should] receive]
        presentGreeDashboardWithBaseURL:[NSURL URLWithString:@"mockURL://"]
        delegate:hostViewController
        animated:YES
        completion:nil];
      
      KWMock *popup = [KWMock nullMockForClass:[GreePopup class]];
      KWCaptureSpy *dismissBlockSpy = [popup captureArgument:@selector(setDidDismissBlock:) atIndex:0];
      [popup stub:@selector(hostViewController) andReturn:hostViewController];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:popup];
      
      GreeJSInviteExternalUserCommand *command = [[GreeJSInviteExternalUserCommand alloc] init];
      command.environment = environment;
      [command execute:parameters];
      
      void (^dismissBlock)(id sender) = dismissBlockSpy.argument;      
      dismissBlock(popup);
      
      [command release];
    });
    
    it(@"should execute the original dismiss block", ^{
      __block NSString* waitObject = nil;
    
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockURL://", @"URL",
        nil];
    
      UIViewController *hostViewController = [UIViewController nullMock];
      [[[hostViewController should] receive]
        presentGreeDashboardWithBaseURL:[NSURL URLWithString:@"mockURL://"]
        delegate:hostViewController
        animated:YES
        completion:nil];
      
      void (^oldDismissBlock)(id sender) = [^(id sender){
          waitObject = [@"YES" retain];
        } copy];
      
      KWMock *popup = [KWMock nullMockForClass:[GreePopup class]];
      [[popup stubAndReturn:oldDismissBlock] didDismissBlock];
      KWCaptureSpy *dismissBlockSpy = [popup captureArgument:@selector(setDidDismissBlock:) atIndex:0];
      [popup stub:@selector(hostViewController) andReturn:hostViewController];
      
      id environment = [KWMock nullMockForProtocol:@protocol(GreeJSCommandEnvironment)];
      [environment stub:@selector(viewControllerForCommand:) andReturn:popup];
      
      GreeJSInviteExternalUserCommand *command = [[GreeJSInviteExternalUserCommand alloc] init];
      command.environment = environment;
      [command execute:parameters];
      
      void (^dismissBlock)(id sender) = dismissBlockSpy.argument;      
      dismissBlock(popup);
      
      [[expectFutureValue(waitObject) shouldEventually] beNonNil];
      
      [oldDismissBlock release];
      [waitObject release];
      [command release];
    });
  });
});

SPEC_END
