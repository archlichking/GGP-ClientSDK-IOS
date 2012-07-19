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

#import <MessageUI/MessageUI.h>

#import "Kiwi.h"
#import "GreeJSLaunchSMSComposerCommand.h"
#import "UIViewController+GreeAdditions.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSLaunchSMSComposerCommandTest)

describe(@"GreeJSLaunchSMSComposerCommand",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSLaunchSMSComposerCommand name] should] equal:@"launch_sms_composer"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSLaunchSMSComposerCommand *command = [[GreeJSLaunchSMSComposerCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSLaunchSMSComposerCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"while executing", ^{
    it(@"should fail if the mail compose view controller can't be shown", ^{
      [MFMessageComposeViewController stub:@selector(canSendText) andReturn:theValue(NO)];
      
      UIViewController *viewController = [UIViewController nullMock];
      [[viewController shouldNot] receive:@selector(greePresentViewController:animated:completion:)];
      
      [UIViewController stub:@selector(greeLastPresentedViewController) andReturn:viewController];
      
      GreeJSLaunchSMSComposerCommand *command = [[GreeJSLaunchSMSComposerCommand alloc] init];
      [command execute:nil];
      [command release];
    });

    it(@"should fail if there is no receipient in the 'to' parameter", ^{
      [MFMessageComposeViewController stub:@selector(canSendText) andReturn:theValue(YES)];
      
      UIViewController *viewController = [UIViewController nullMock];
      [[viewController shouldNot] receive:@selector(greePresentViewController:animated:completion:)];
      
      [UIViewController stub:@selector(greeLastPresentedViewController) andReturn:viewController];
      
      GreeJSLaunchSMSComposerCommand *command = [[GreeJSLaunchSMSComposerCommand alloc] init];
      [command execute:nil];
      [command release];
    });

    it(@"should present the mail compose view controller", ^{
      MFMessageComposeViewController *smsViewController = [MFMessageComposeViewController nullMock];
      [MFMessageComposeViewController stub:@selector(canSendText) andReturn:theValue(YES)];
      [MFMessageComposeViewController stub:@selector(alloc) andReturn:smsViewController];
      
      UIViewController *viewController = [UIViewController nullMock];
      [[viewController should] receive:@selector(greePresentViewController:animated:completion:)];
      
      [UIViewController stub:@selector(greeLastPresentedViewController) andReturn:viewController];
      
      GreeJSLaunchSMSComposerCommand *command = [[GreeJSLaunchSMSComposerCommand alloc] init];
      [command execute:[NSDictionary dictionaryWithObjectsAndKeys:@"mockRecipient", @"to", nil]];
      [command release];
    });

    it(@"should dismiss the mail compose view controller", ^{
      MFMessageComposeViewController *smsViewController = [MFMessageComposeViewController nullMock];
      [MFMessageComposeViewController stub:@selector(canSendText) andReturn:theValue(YES)];
      [MFMessageComposeViewController stub:@selector(alloc) andReturn:smsViewController];
      
      UIViewController *viewController = [UIViewController nullMock];
      [[viewController should] receive:@selector(greeDismissViewControllerAnimated:completion:)];
      
      [UIViewController stub:@selector(greeLastPresentedViewController) andReturn:viewController];
      
      GreeJSLaunchSMSComposerCommand *command = [[GreeJSLaunchSMSComposerCommand alloc] init];
      [command execute:[NSDictionary dictionaryWithObjectsAndKeys:@"mockRecipient", @"to", nil]];      
      [command messageComposeViewController:smsViewController didFinishWithResult:MessageComposeResultSent];
      [command release];
    });

    it(@"should callback when the mail composer is dismissed", ^{
      MFMessageComposeViewController *smsViewController = [MFMessageComposeViewController nullMock];
      [MFMessageComposeViewController stub:@selector(canSendText) andReturn:theValue(YES)];
      [MFMessageComposeViewController stub:@selector(alloc) andReturn:smsViewController];
      
      GreeJSLaunchSMSComposerCommand *command = [[GreeJSLaunchSMSComposerCommand alloc] init];
      [command execute:[NSDictionary dictionaryWithObjectsAndKeys:@"mockRecipient", @"to", nil]];
      
      [[command should] receive:@selector(callback)];
      [command messageComposeViewController:smsViewController didFinishWithResult:MessageComposeResultSent];
      
      [command release];
    });
  });
  
});

SPEC_END
