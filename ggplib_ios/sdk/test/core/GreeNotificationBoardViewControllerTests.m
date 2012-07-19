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
#import "GreeNotificationBoardViewController.h"
#import "GreePlatform.h"
#import "GreeSettings.h"
#import "GreeTestHelpers.h"

#pragma mark - GreeNotificationBoardViewControllerTests

@interface GreeNotificationBoardViewController(ExposePrivateAPIS)
- (void)pushNextItem:(BOOL)showBackButton;
- (void)backButtonPressed:(id)sender;
- (void)doneButtonPressed:(id)sender;
@end

SPEC_BEGIN(GreeNotificationBoardViewControllerTests)

describe(@"GreeNotificationBoardViewController", ^{

  context(@"when initializing", ^{    
    it(@"should initialize with a URL", ^{
      GreeNotificationBoardViewController *viewController = [[GreeNotificationBoardViewController alloc]
        initWithURL:nil];
      [[viewController shouldNot] beNil]; 
      [viewController release];
    });
    
    it(@"should set the correct values", ^{    
      GreeNotificationBoardViewController *viewController = [[GreeNotificationBoardViewController alloc]
        initWithURL:[NSURL URLWithString:@"http://www.google.com"]];
      [[viewController.URL should] equal:[NSURL URLWithString:@"http://www.google.com"]];
      [viewController release];

    });
  });
  
  context(@"when pushing a navigation item", ^{
    __block UINavigationItem *item;
    __block UILabel *label;
    beforeEach(^{      
      item = [UINavigationItem nullMock];
      [item stub:@selector(init) andReturn:item];
      [UINavigationItem stub:@selector(alloc) andReturn:item];

      label = [UILabel nullMock];
      [label stub:@selector(init) andReturn:label];
      [UILabel stub:@selector(alloc) andReturn:label];
      [UIFont stub:@selector(boldSystemFontOfSize:) andReturn:[UIFont nullMock]];
      [UIColor stub:@selector(colorWithWhite:alpha:) andReturn:[UIColor nullMock]];
      [UIColor stub:@selector(whiteColor) andReturn:[UIColor nullMock]];
    });
    
    it(@"should add a back button if requested", ^{
      GreeNotificationBoardViewController *viewController = [[GreeNotificationBoardViewController alloc]
        initWithURL:nil];
      
      [[item should] receive:@selector(setLeftBarButtonItem:)];
      
      [viewController pushNextItem:YES];
      [viewController release];
    });
    
    it(@"should not add a back button if not requested", ^{
      GreeNotificationBoardViewController *viewController = [[GreeNotificationBoardViewController alloc]
        initWithURL:nil];
      
      [[item shouldNot] receive:@selector(setLeftBarButtonItem:)];
      
      [viewController pushNextItem:NO];
      [viewController release];
    });
    
    it(@"should add a close button", ^{
      GreeNotificationBoardViewController *viewController = [[GreeNotificationBoardViewController alloc]
        initWithURL:nil];
      
      [[item should] receive:@selector(setRightBarButtonItem:)];
      
      [viewController pushNextItem:NO];
      [viewController release];
    });
  });
  
  context(@"creating the notification url", ^{   
    beforeEach(^{      
      GreePlatform *platform = [GreePlatform nullMock];
      [GreePlatform stub:@selector(sharedInstance) andReturn:platform];      
    });
    
    it(@"should set a url for launching the sns", ^{        
      GreeSettings* settings = [GreeSettings nullMock];
      [settings stub:@selector(stringValueForSetting:) andReturn:@"mockValue:/"];
      [[GreePlatform sharedInstance] stub:@selector(settings) andReturn:settings];

      NSURL *url = [GreeNotificationBoardViewController URLForLaunchType:GreeNotificationBoardLaunchWithSns withParameters:nil];    
  
      [[[url absoluteString] should] equal:@"mockValue://sns"];
    });

    it(@"should set a url for launching the game", ^{        
      GreeSettings* settings = [GreeSettings nullMock];
      [settings stub:@selector(stringValueForSetting:) andReturn:@"mockValue:/"];
      [[GreePlatform sharedInstance] stub:@selector(settings) andReturn:settings];

      NSURL *url = [GreeNotificationBoardViewController URLForLaunchType:GreeNotificationBoardLaunchWithPlatform withParameters:nil];    
  
      [[[url absoluteString] should] equal:@"mockValue://game"];
    });

    it(@"should set an arbitrary url", ^{
      NSDictionary *urlDictionary = [NSDictionary dictionaryWithObject:@"mockURL://" forKey:@"url"];
 
      NSURL *url = [GreeNotificationBoardViewController URLForLaunchType:GreeNotificationBoardLaunchWithExternalUrl withParameters:urlDictionary];    
  
      [[[url absoluteString] should] equal:@"mockURL://"];
    });

    it(@"should set a url with an internal action", ^{
      NSDictionary *urlDictionary = [NSDictionary dictionaryWithObject:@"mockAction" forKey:@"action"];
 
      GreeSettings* settings = [GreeSettings nullMock];
      [settings stub:@selector(stringValueForSetting:) andReturn:@"mockValue://"];
      [[GreePlatform sharedInstance] stub:@selector(settings) andReturn:settings];

      NSURL *url = [GreeNotificationBoardViewController URLForLaunchType:GreeNotificationBoardLaunchWithInternalAction withParameters:urlDictionary];    
  
      [[[url absoluteString] should] equal:@"mockValue://mockAction"];
    });

    it(@"should set a url to launch with a message detail", ^{
      NSDictionary *urlDictionary = [NSDictionary dictionaryWithObject:@"mockInfoKey" forKey:@"info-key"];
 
      GreeSettings* settings = [GreeSettings nullMock];
      [settings stub:@selector(stringValueForSetting:) andReturn:@"mockValue://"];
      [[GreePlatform sharedInstance] stub:@selector(settings) andReturn:settings];

      NSURL *url = [GreeNotificationBoardViewController URLForLaunchType:GreeNotificationBoardLaunchWithMessageDetail withParameters:urlDictionary];    
  
      [[[url absoluteString] should] equal:@"mockValue://mockInfoKey"];
    });

    it(@"should set a url to launch with request detail", ^{
      NSDictionary *urlDictionary = [NSDictionary dictionaryWithObject:@"mockInfoKey" forKey:@"info-key"];
 
      GreeSettings* settings = [GreeSettings nullMock];
      [settings stub:@selector(stringValueForSetting:) andReturn:@"mockValue://"];
      [[GreePlatform sharedInstance] stub:@selector(settings) andReturn:settings];

      NSURL *url = [GreeNotificationBoardViewController URLForLaunchType:GreeNotificationBoardLaunchWithRequestDetail withParameters:urlDictionary];    
  
      [[[url absoluteString] should] equal:@"mockValue://mockInfoKey"];
    });

    it(@"should return a default url for an unknown type", ^{
      GreeSettings* settings = [GreeSettings nullMock];
      [settings stub:@selector(stringValueForSetting:) andReturn:@"mockValue:/"];
      [[GreePlatform sharedInstance] stub:@selector(settings) andReturn:settings];
    
      NSURL *url = [GreeNotificationBoardViewController URLForLaunchType:10000 withParameters:nil];    
  
      [[[url absoluteString] should] equal:@"mockValue://"];
    });
  });
  
  it(@"should popup the navigation item if the back button is pressed", ^{
    UINavigationBar *navigationBar = [UINavigationBar nullMock];
    [[navigationBar should] receive:@selector(popNavigationItemAnimated:)];
    
    GreeNotificationBoardViewController *viewController = [[GreeNotificationBoardViewController alloc] initWithURL:nil];
    [viewController stub:@selector(navigationBar) andReturn:navigationBar];
            
    [viewController backButtonPressed:[UIButton nullMock]];
    [viewController release];
  });

  it(@"should dismiss if the done button is pressed", ^{    
    GreeNotificationBoardViewController *viewController = [[GreeNotificationBoardViewController alloc] initWithURL:nil];
    [[viewController should] receive:@selector(dismiss)];
    [viewController doneButtonPressed:[UIButton nullMock]];
    [viewController release];
  });
});

SPEC_END
