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
#import "CredentialStorage.h"


#import "GreePlatformSettings.h"
#import "GreeUser.h"

#import "GreeAchievement.h"
#import "GreePlatform.h"

#import "StepDefinition.h"

#define RUN_MODE 0

#if RUN_MODE == 0
#define CONFIG_NAME           @"debugCase.txt"
#define RUN_TYPE              FILE_BUILDER
#elif RUN_MODE == 1
#define CONFIG_NAME           @"tcmsConfig.json"
#define RUN_TYPE              TCM_BUILDER
#endif


@implementation AppDelegate

@synthesize window = _window;
@synthesize baseJsCommand = _baseJsCommand;
@synthesize ggpCommand = _ggpCommand;
@synthesize ggpCommandInterface = _ggpCommandInterface;
@synthesize runnerWrapper;

//static NSString* APPID = @"12697";
static NSString* APPID = @"15265";
//static NSString* APPID = @"15199";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    // Override point for customization after application launch.
    // to use debug case, switch to debugCase.txt
    // to use tcm settings, switch to tcmsConfig.json
    NSData* rawData = [self loadConfig:CONFIG_NAME];
    NSData* baseJsCommandData = [self loadConfig:@"baseCommand.js"];
    
    _baseJsCommand = [[NSString alloc] initWithData:baseJsCommandData 
                                           encoding:NSUTF8StringEncoding];
    
    NSData* ggpCommandData = [self loadConfig:@"ggp_command.js"];
    
    _ggpCommand = [[NSString alloc] initWithData:ggpCommandData 
                                        encoding:NSUTF8StringEncoding];
    
    NSData* ggpCommandInterfaceData = [self loadConfig:@"command_interface.js"];
    
    _ggpCommandInterface = [[NSString alloc] initWithData:ggpCommandInterfaceData 
                                        encoding:NSUTF8StringEncoding];
    
    // just change APPID
    NSString* appconf = [NSString stringWithFormat:@"%@credentialsConfig.json", APPID];
    
    
    NSData* rawCredential = [self loadConfig:appconf];
    [CredentialStorage initializeCredentialStorageWithAppid:APPID 
                                                    andData:rawCredential];
    
    
    
    runnerWrapper = [[TestRunnerWrapper alloc] initWithRawData:rawData 
                                                   builderType:[CaseBuilderFactory RUN_TYPE]];
    
    
    // --------- GREE Platform initialization
    
    NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys: 
                              @"sandbox", GreeSettingDevelopmentMode,
//                              [NSNumber numberWithBool:YES], GreeSettingUseWallet,
                              nil]; 

      
    if ([NSClassFromString(@"WebView") respondsToSelector:@selector(_enableRemoteInspector)]) {
        [NSClassFromString(@"WebView") performSelector:@selector(_enableRemoteInspector)];
    }
    
    [GreePlatform initializeWithApplicationId:[[CredentialStorage sharedInstance] getValueForKey:CredentialStoredAppId] 
                                  consumerKey:[[CredentialStorage sharedInstance] getValueForKey:CredentialStoredAppKey] 
                               consumerSecret:[[CredentialStorage sharedInstance] getValueForKey:CredentialStoredAppSecret] 
                                     settings:settings
                                     delegate:self];
    
    id httpClient = [[GreePlatform sharedInstance] valueForKey:@"httpClient"];
    //All requests from the sample app should be distinguishable in our analytics system 
    [[httpClient valueForKey:@"defaultHeaders"] setObject:@"x" forKey:@"x_gree_sample_app"];
    // init user
    
    [GreePlatform handleLaunchOptions:launchOptions application:application];
//    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
    
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
    [GreePlatform handleRemoteNotification:userInfo application:application];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{  
	return [GreePlatform handleOpenURL:url application:application];
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
    NSArray * arguments = [[NSProcessInfo processInfo] arguments];
//    NSArray* arguments = [[NSArray alloc] initWithObjects:@"JenkinsMode", nil];
    NSLog(@"%@", arguments);
    
    [GreePlatform authorizeWithBlock:^(GreeUser *localUser, NSError *error) {
        if ([arguments containsObject:@"JenkinsMode"]) {
            // jenkins mode launch
            
            // need to wait
            
            while (![[GreePlatform sharedInstance] localUser]) {
                [NSThread sleepForTimeInterval:2];
            }
            
            NSOperationQueue* operationQueue = [[NSOperationQueue alloc] init];
            [operationQueue setMaxConcurrentOperationCount:1];
            
            NSString* suiteId = @"178";
            NSString* runId = @"416";
            
            NSLog(@"======================== load cases from Suite %@ ======", suiteId);
            [runnerWrapper emptyCaseWrappers];
            [runnerWrapper buildRunner:suiteId];
            
            
            [runnerWrapper markCaseWrappers:[TestCaseWrapper All]];
            NSLog(@"======================== executing cases and update result for Run %@ ======",runId);
            
            NSInvocationOperation* theOp = [[[NSInvocationOperation alloc] initWithTarget:self
                                                                                 selector:@selector(runCaseInAnotherThread:)
                                                                                   object:runId]
                                            autorelease];
            [operationQueue addOperation:theOp];
        }
    }];
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


- (void) runCaseInAnotherThread:(NSString*) runId{
    [runnerWrapper executeSelectedCasesWithSubmit:runId
                                            block:^(NSArray *objs) {
        
    }];
}

- (NSData*) loadConfig:(NSString*) fname{
    NSArray* params = [fname componentsSeparatedByString:@"."];
    NSString* filePath = [[NSBundle mainBundle] pathForResource:[params objectAtIndex:0]
                                                         ofType:[params objectAtIndex:1]];
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
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"Local User: %@", localUser);

}
//#indoc "GreePlatformDelegate#greePlatform:didLogoutUser:"
- (void)greePlatform:(GreePlatform*)platform didLogoutUser:(GreeUser*)localUser{
    NSLog(@"%s", __FUNCTION__);
}

- (void)greePlatformParamsReceived:(NSDictionary*)params
{
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"params: %@", params.description);
    
    // Show result in UIAlertVIew
    NSString *aMessage = [NSString stringWithFormat:@"%@", params];
    [[[UIAlertView alloc] initWithTitle:@"Received Launch Params"
                                message:aMessage
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
    
}


@end
