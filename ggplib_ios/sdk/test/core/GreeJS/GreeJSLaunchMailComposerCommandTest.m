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
#import "GreeJSLaunchMailComposerCommand.h"
#import "UIViewController+GreeAdditions.h"
#import "GreeMatchers.h"

SPEC_BEGIN(GreeJSLaunchMailComposerTest)

describe(@"GreeJSLaunchMailComposer",^{
  registerMatchers(@"Gree");
  it(@"should have a name", ^{
    [[[GreeJSLaunchMailComposerCommand name] should] equal:@"launch_mail_composer"]; 
  });
  
  it(@"should have a description", ^{
    GreeJSLaunchMailComposerCommand *command = [[GreeJSLaunchMailComposerCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSLaunchMailComposerCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"while executing", ^{
    it(@"should fail if the mail compose view controller can't be shown", ^{
      [MFMailComposeViewController stub:@selector(canSendMail) andReturn:theValue(NO)];
      
      UIViewController *viewController = [UIViewController nullMock];
      [[viewController shouldNot] receive:@selector(greePresentViewController:animated:completion:)];
      
      [UIViewController stub:@selector(greeLastPresentedViewController) andReturn:viewController];
      
      GreeJSLaunchMailComposerCommand *command = [[GreeJSLaunchMailComposerCommand alloc] init];
      [command execute:nil];
      [command release];
    });

    it(@"should present the mail compose view controller", ^{
      MFMailComposeViewController *mailViewController = [MFMailComposeViewController nullMock];
      [MFMailComposeViewController stub:@selector(canSendMail) andReturn:theValue(YES)];
      [MFMailComposeViewController stub:@selector(alloc) andReturn:mailViewController];
      
      
      UIViewController *viewController = [UIViewController nullMock];
      [[viewController should] receive:@selector(greePresentViewController:animated:completion:)];
      
      [UIViewController stub:@selector(greeLastPresentedViewController) andReturn:viewController];
      
      GreeJSLaunchMailComposerCommand *command = [[GreeJSLaunchMailComposerCommand alloc] init];
      [command execute:nil];
      [command release];
    });

    it(@"should dismiss the mail compose view controller", ^{
      MFMailComposeViewController *mailViewController = [MFMailComposeViewController nullMock];
      [MFMailComposeViewController stub:@selector(canSendMail) andReturn:theValue(YES)];
      [MFMailComposeViewController stub:@selector(alloc) andReturn:mailViewController];
      
      UIViewController *viewController = [UIViewController nullMock];
      [[viewController should] receive:@selector(greeDismissViewControllerAnimated:completion:)];
      
      [UIViewController stub:@selector(greeLastPresentedViewController) andReturn:viewController];
      
      GreeJSLaunchMailComposerCommand *command = [[GreeJSLaunchMailComposerCommand alloc] init];
      [command execute:nil];      
      [command mailComposeController:mailViewController didFinishWithResult:MFMailComposeResultSent error:nil];
      [command release];
    });

    it(@"should callback when the mail composer is dismissed", ^{
      MFMailComposeViewController *mailViewController = [MFMailComposeViewController nullMock];
      [MFMailComposeViewController stub:@selector(canSendMail) andReturn:theValue(YES)];
      [MFMailComposeViewController stub:@selector(alloc) andReturn:mailViewController];
      
      GreeJSLaunchMailComposerCommand *command = [[GreeJSLaunchMailComposerCommand alloc] init];
      [command execute:nil];
      
      [[command should] receive:@selector(callback)];
      [command mailComposeController:mailViewController didFinishWithResult:MFMailComposeResultSent error:nil];
      
      [command release];
    });
  });
  
});

SPEC_END
