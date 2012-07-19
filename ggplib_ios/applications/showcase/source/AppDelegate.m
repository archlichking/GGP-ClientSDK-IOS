//
// Copyright 2011 GREE, Inc.
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

#import "AppDelegate.h"

#import "SampleRootController.h"
#import "GreePlatformSettings.h"
#import "GreeWallet.h"
#import "UIViewController+GreePlatform.h"
#import <QuartzCore/QuartzCore.h>
#import "UIViewController+GreePlatform.h"


static NSString* APP_DEVELOPMENT_MODE = @"production"; 
static NSString* ENTER_APPLICATION_ID = @"52760"; 
static NSString* ENTER_CONSUMER_KEY = @"0f4e35479874"; 
static NSString* ENTER_CONSUMER_SECRET = @"55ac9d4a03b31b81c3b24b0454549848";

@implementation ShowCaseNavigationController

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self showGreeWidgetWithDataSource:self];
}

#pragma mark - GreeWidgetDataSource
- (UIImage*)screenshotImageForWidget:(GreeWidget*)widget
{
  UIView* viewForScreenShot = self.view;
  UIGraphicsBeginImageContext(viewForScreenShot.layer.visibleRect.size);
  [viewForScreenShot.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

@end


@interface AppDelegate()
@property(nonatomic,retain) SampleRootController* rootController;
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize splitViewController = _splitViewController;
@synthesize rootController =  _rootController;

#pragma mark - Object Lifecycle

- (void)dealloc
{
  [_window release];
  [_navigationController release];
  [_splitViewController release];
  [_rootController release];
  [super dealloc];
}

/*
 GreeAchievements GameCenter processing
 In order to get your achievements to work with GameCenter, you need to add a line to the settings dictionary below.
   
 NSDictionary* gcAchievements = [NSDictionary dictionaryWithObjectsAndKeys:@"GameCenterAchievementId1", @"GreeAchievementId1",@"GameCenterAchievementId2",@"GreeAchievementId2",nil];

 NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
 @"develop", GreeSettingDevelopmentMode,
 gcAchievements, GreeSettingGameCenterAchievementMapping,
 nil];
 */

#pragma mark - UIApplicationDelegate Methods

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
  NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
                            APP_DEVELOPMENT_MODE, GreeSettingDevelopmentMode,
                            [NSNumber numberWithBool:YES], GreeSettingUseWallet,
                            [NSNumber numberWithBool:YES], GreeSettingEnableGrade0,
                            nil];
#if TARGET_IPHONE_SIMULATOR
  if ([NSClassFromString(@"WebView") respondsToSelector:@selector(_enableRemoteInspector)]) {
    [NSClassFromString(@"WebView") performSelector:@selector(_enableRemoteInspector)];
  }
#endif

  //print encrypted strings to console 
  [GreePlatform printEncryptedStringWithConsumerKey:ENTER_CONSUMER_KEY consumerSecret:ENTER_CONSUMER_SECRET scramble:@"somethingSecret"];
  //If you use the encrypted consumerKey and consumerSecret you should enable following line and set the ecnrypted string to initialize method
//  [GreePlatform setConsumerProtectionWithScramble:@"somethingSecret"];
  [GreePlatform initializeWithApplicationId:ENTER_APPLICATION_ID consumerKey:ENTER_CONSUMER_KEY consumerSecret:ENTER_CONSUMER_SECRET settings:settings delegate:self];
    
  id httpClient = [[GreePlatform sharedInstance] valueForKey:@"httpClient"];
  //All requests from the sample app should be distinguishable in our analytics system 
  [[httpClient valueForKey:@"defaultHeaders"] setObject:@"x" forKey:@"x_gree_sample_app"];
  [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
  
  self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
  
  // Override point for customization after application launch.
  SampleRootController* rootController = [[[SampleRootController alloc] init] autorelease];
  self.rootController = rootController;
  self.navigationController = [[[ShowCaseNavigationController alloc] initWithRootViewController:rootController] autorelease];
  self.window.rootViewController = self.navigationController;
  [self.window makeKeyAndVisible];
    
  [GreePlatform authorize];
  
  [GreePlatform handleLaunchOptions:launchOptions application:application];
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication*)application
{
  /*
   Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
   Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
   */
}

- (void)applicationDidEnterBackground:(UIApplication*)application
{
  /*
   Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
   If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
   */
}

- (void)applicationWillEnterForeground:(UIApplication*)application
{
  /*
   Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
   */
}

- (void)applicationDidBecomeActive:(UIApplication*)application
{
  /*
   Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   */
}

- (void)applicationWillTerminate:(UIApplication*)application
{
  /*
   Called when the application is about to terminate.
   Save data if appropriate.
   See also applicationDidEnterBackground:.
   */
  //shutdown GreePlatform 
  [GreePlatform shutdown];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  [GreePlatform postDeviceToken:deviceToken block:^(NSError * error) {
    if (error) {
      NSLog(@"Error uploading User Token:%@", error);
    }
  }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  NSLog(@"Error registering for remote notifications:%@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
  [GreePlatform handleRemoteNotification:userInfo application:application];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{  
  return [GreePlatform handleOpenURL:url application:application];
}

#pragma mark - GreePlatformDelegate Protocol

- (void)greePlatformWillShowModalView:(GreePlatform*)platform
{
  NSLog(@"%s", __FUNCTION__);
}

- (void)greePlatformDidDismissModalView:(GreePlatform*)platform
{
  NSLog(@"%s", __FUNCTION__);
}

- (void)greePlatform:(GreePlatform*)platform didLoginUser:(GreeUser*)localUser
{
  NSLog(@"%s", __FUNCTION__);
  NSLog(@"Local User: %@", localUser);
  [self.rootController loadUser];
}

- (void)greePlatform:(GreePlatform*)platform didLogoutUser:(GreeUser*)localUser
{
  NSLog(@"%s", __FUNCTION__);
  [self.rootController loadUser];
}

- (void)greePlatformParamsReceived:(NSDictionary*)params
{
  NSLog(@"%s", __FUNCTION__);
  NSLog(@"params: %@", params.description);

  // Show result in UIAlertVIew
  NSString *aMessage = [NSString stringWithFormat:@"%@", params];
  [[[[UIAlertView alloc] initWithTitle:@"Received Launch Params"
                              message:aMessage
                             delegate:nil
                    cancelButtonTitle:nil
                    otherButtonTitles:@"OK", nil] autorelease] show];
}

- (void)greePlatform:(GreePlatform *)platform didUpdateLocalUser:(GreeUser *)localUser
{
  NSLog(@"%s", __FUNCTION__);
  NSLog(@"Local User: %@", localUser);
}

@end
