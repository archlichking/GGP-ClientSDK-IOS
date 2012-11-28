//
//  AppDelegate.m
//  OFQASample
//
//  Created by lei zhu on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "CaseBuilderFactory.h"
#import "CredentialStorage.h"

#import "Constant.h"

#import "GreePlatformSettings.h"
#import "GreeUser.h"


#import "GreeAchievement.h"
#import "GreePlatform.h"

#import "StepDefinition.h"
#import "StepExecutionLock.h"
#import "CIUtil.h"

#import "QAAutoFramework.h"
#import "QALog.h"

#import "objc/runtime.h"
#import <mach/mach.h>

#import "SampleStepDefinition.h"
#import "AuthorizationStepDefinition.h"
#import "AchievementStepDefinition.h"
#import "LeaderboardStepDefinition.h"
#import "PeopleStepDefinition.h"
#import "ModerationStepDefinition.h"
#import "FriendCodeStepDefinition.h"
#import "IgnorelistStepDefinition.h"
#import "NetworkStepDefinition.h"
#import "GreePlatformStepDefinition.h"
#import "PaymentStepDefinition.h"
#import "PopupStepDefinition.h"
#import "NotificationStepDefinition.h"
#import "BadgeStepDefinition.h"
#import "WidgetStepDefinition.h"
#import "LogJsKitStepDefinition.h"
#import "LoggerStepDefinition.h"
#import "AddonStepDefinition.h"
#import "IncentiveStepDefinition.h"
#import "StepDefinition.h"

#define RUN_MODE 1

#if RUN_MODE == 0
#define CONFIG_NAME           @"debugCase.txt"
#define RUN_TYPE              BuilderFile
#elif RUN_MODE == 1
#define CONFIG_NAME           @"tcmsConfig.json"
#define RUN_TYPE              BuilderTCM
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
//static NSString* APPID = @"57209";
static int enterSwitch = 0;

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
    // ------------
    NSArray* classArray = [[[NSArray alloc] initWithObjects:
                            class_createInstance([AuthorizationStepDefinition class], 0),
                            class_createInstance([AchievementStepDefinition class], 0),
                            class_createInstance([LeaderboardStepDefinition class], 0),
                            class_createInstance([PeopleStepDefinition class], 0),
                            class_createInstance([ModerationStepDefinition class], 0),
                            class_createInstance([FriendCodeStepDefinition class], 0),
                            class_createInstance([IgnorelistStepDefinition class], 0),
                            class_createInstance([NetworkStepDefinition class], 0),
                            class_createInstance([GreePlatformStepDefinition class], 0),
                            class_createInstance([PaymentStepDefinition class], 0),
                            class_createInstance([PopupStepDefinition class], 0),
                            class_createInstance([NotificationStepDefinition class], 0),
                            class_createInstance([BadgeStepDefinition class], 0),
                            class_createInstance([WidgetStepDefinition class], 0),
                            class_createInstance([LogJsKitStepDefinition class], 0),
                            class_createInstance([LoggerStepDefinition class], 0),
                            class_createInstance([AddonStepDefinition class], 0),
                            class_createInstance([IncentiveStepDefinition class], 0),
    
                            nil] autorelease];

    
    NSDictionary* qSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                               rawData, @"data",
                               [NSString stringWithFormat:@"%i", RUN_TYPE], @"type",
                               classArray, @"steps",
                               nil];
    
    [QAAutoFramework initializeWithSettings:qSettings];
    // ------------
    
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
    
    [GreePlatform authorizeWithBlock:^(GreeUser *localUser, NSError *error) {
    }];
    
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
    
    [GreePlatform authorizeWithBlock:^(GreeUser *localUser, NSError *error) {
        
        // only tmp hack to promise automatically launch
        if ([arguments containsObject:@"JenkinsMode"] && enterSwitch == 0) {
            // jenkins mode launch
            
            NSOperationQueue* operationQueue = [[NSOperationQueue alloc] init];
            [operationQueue setMaxConcurrentOperationCount:1];
            
            NSDictionary* configDicionary = [CIUtil getRunInfoFromUrl:@"http://localhost:3000/config?key=adfqet87983hiu783flkad09806g98adgk&platform=ios"];
            
            NSString* suiteId = [configDicionary objectForKey:@"suite_id"];
            NSString* runId = [configDicionary objectForKey:@"run_id"];
            
            QALog(@"------------- load cases from Suite %@ ", suiteId);
            [[QAAutoFramework sharedInstance] buildCases:suiteId];
            QALog(@"------------- executing cases and update result for Run %@ ",runId);
            
            NSInvocationOperation* theOp = [[NSInvocationOperation alloc] initWithTarget:self
                                                                                 selector:@selector(runCaseInAnotherThread:)
                                                                                   object:runId];
            [operationQueue addOperation:theOp];
            enterSwitch = 1;
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
    [[QAAutoFramework sharedInstance] filterCases:SelectAll];
    [[QAAutoFramework sharedInstance] runAllCases];

    // need to execute all failed cases again to make sure no network or other interference here
    [[QAAutoFramework sharedInstance] filterCases:SelectFailed];
    [[QAAutoFramework sharedInstance] runAllCases];
    
    [[QAAutoFramework sharedInstance] filterCases:SelectAll];
    [[QAAutoFramework sharedInstance] submitTcm:runId];
    
    
    QALog(@"------------- requesting subserver to generate perf report for Run %@",runId);
    [CIUtil generateReport:@"adfqet87983hiu783flkad09806g98adgk" fromUrl:@"http://localhost:3000/ios/report"];
    QALog(@"------------- perf report generated for Run %@",runId);
    
    
    
    exit(0);
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
//    NSLog(@"%s", __FUNCTION__);
//    NSLog(@"Local User: %@", localUser);

}
//#indoc "GreePlatformDelegate#greePlatform:didLogoutUser:"
- (void)greePlatform:(GreePlatform*)platform didLogoutUser:(GreeUser*)localUser{
//    NSLog(@"%s", __FUNCTION__);
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
