//
//  AppDelegate.m
//  OFQASample
//
//  Created by lei zhu on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "TestRunnerWrapper.h"
#import "CaseBuilderFactory.h"


#import "GreePlatformSettings.h"
#import "GreeUser.h"

#import "GreeAchievement.h"
#import "GreePlatform.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize runnerWrapper;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    NSData* raw = [self loadSettings];
    runnerWrapper = [[TestRunnerWrapper alloc] initWithRawData:raw 
                                                   builderType:[CaseBuilderFactory TCM_BUILDER]];
    
    
    // --------- GREE Platform initialization
    
    NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"developSandbox", 
                              GreeSettingDevelopmentMode,
                              @"ggpsb-qa",
                              @"serverUrlSuffix",
                              nil];

    
    
    [GreePlatform initializeWithApplicationId:@"607" 
                                  consumerKey:@"ec26c5b8495b" 
                               consumerSecret:@"8b76971b196a05737c4f667fb5bcb5b2" 
                                     settings:settings
                                     delegate:self];

    
    id httpClient = [[GreePlatform sharedInstance] valueForKey:@"httpClient"];
    //All requests from the sample app should be distinguishable in our analytics system 
    [[httpClient valueForKey:@"defaultHeaders"] setObject:@"x" forKey:@"x_gree_sample_app"];
    // init user
    [GreePlatform authorize];
    
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];

    // ---------
    
    return YES;
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
    [GreePlatform handleRemoteNotification:userInfo];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{  
	return [GreePlatform handleOpenURL:url];
}
		

- (void)greePlatformWillShowModalView:(GreePlatform*)platform
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)greePlatformDidDismissModalView:(GreePlatform*)platform
{
    NSLog(@"%s", __FUNCTION__);
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    // -------------- shut down gree platform
   [GreePlatform shutdown];
    // --------------
}

- (NSData*) loadSettings{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"json"];
	if(![[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{
		// OFLog(@"OFXmlReader: Expected xml file at path %@. Not Parsing.", filePath);
        return nil;
	}
    NSFileHandle* file = [NSFileHandle fileHandleForReadingAtPath:filePath];
    NSData* rawData = [file readDataToEndOfFile];
    return rawData;
}

- (NSData*) loadDebugCase{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"debugCase" ofType:@"txt"];
	if(![[NSFileManager defaultManager] fileExistsAtPath:filePath])
	{
		// OFLog(@"OFXmlReader: Expected xml file at path %@. Not Parsing.", filePath);
        return nil;
	}
    NSFileHandle* file = [NSFileHandle fileHandleForReadingAtPath:filePath];
    NSData* rawData = [file readDataToEndOfFile];
    return rawData;
}

- (void)greePlatform:(GreePlatform*)platform didLoginUser:(GreeUser*)localUser{
    
}
//#indoc "GreePlatformDelegate#greePlatform:didLogoutUser:"
- (void)greePlatform:(GreePlatform*)platform didLogoutUser:(GreeUser*)localUser{
    
}

@end
