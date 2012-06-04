//
//  AppDelegate.m
//  OFQAJenkins
//
//  Created by lei zhu on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "TestCaseWrapper.h"
#import "TestRunnerWrapper.h"
#import "CaseBuilderFactory.h"
#import "TcmCommunicator.h"
#import "SBJson.h"

#import "GreePlatformSettings.h"
#import "GreeUser.h"

#import "GreeAchievement.h"
#import "GreePlatform.h"



@implementation AppDelegate


@synthesize runnerWrapper;
@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    NSLog(@"%@", launchOptions);
    
    NSData* raw = [self loadSettings];
    runnerWrapper = [[TestRunnerWrapper alloc] initWithRawData:raw 
                                                   builderType:[CaseBuilderFactory TCM_BUILDER]];
    
    
    // --------- GREE Platform initialization
    
    NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys: 
                              @"sandbox", GreeSettingDevelopmentMode,
                              [NSNumber numberWithBool:YES], GreeSettingUseWallet,
                              @"true",@"useWallet", 
                              nil]; 
    
    
    if ([NSClassFromString(@"WebView") respondsToSelector:@selector(_enableRemoteInspector)]) {
        [NSClassFromString(@"WebView") performSelector:@selector(_enableRemoteInspector)];
    }
    
    [GreePlatform initializeWithApplicationId:@"12697" 
                                  consumerKey:@"3c47b530df23" 
                               consumerSecret:@"c6958d092a3db174de86678f31d86d01" 
                                     settings:settings
                                     delegate:self];
    //    [GreePlatform initializeWithApplicationId:@"11787" 
    //                                  consumerKey:@"97f61d7b8f43" 
    //                               consumerSecret:@"38a4325e76d9b66fb5cd2bda5a2eaa59" 
    //                                     settings:settings
    //                                     delegate:self];
    
    
    id httpClient = [[GreePlatform sharedInstance] valueForKey:@"httpClient"];
    //All requests from the sample app should be distinguishable in our analytics system 
    [[httpClient valueForKey:@"defaultHeaders"] setObject:@"x" forKey:@"x_gree_sample_app"];
    // init user
    [GreePlatform authorize];
    [GreePlatform handleLaunchOptions:launchOptions application:application];
    
    operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount:1];
    
    jsonParser = [[[SBJsonParser alloc] init] autorelease];
    
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
    NSLog(@"======================== read run config from server ======");
    NSString* configUrl = @"http://localhost:3000/config";
    
    TcmCommunicator* tcmComm = [[TcmCommunicator alloc] initWithKey:@"" 
                                                          submitUrl:@"" 
                                                       retrievalUrl:configUrl];
    NSData* resp = [tcmComm doHttpGet:configUrl];
    
    NSString *rawConfigJson = [[[NSString alloc] initWithData:resp 
                                                      encoding:NSUTF8StringEncoding] autorelease];
    NSDictionary* configSettings = [[jsonParser objectWithString:rawConfigJson] valueForKey:@"auto_config"];
    // suite id 178 by default
    NSString* suiteId = [configSettings valueForKey:@"suite_id"]?[configSettings valueForKey:@"suite_id"]: @"178"; 
    
    // run id 402 by default
    NSString* runId = [configSettings valueForKey:@"run_id"]?[configSettings valueForKey:@"run_id"]: @"402"; 
    
    
    NSLog(@"======================== load cases from Suite %@ ======", suiteId);
    [runnerWrapper emptyCaseWrappers];
    [runnerWrapper buildRunner:suiteId];
    
    
    [runnerWrapper markCaseWrappers:[TestCaseWrapper All]];
    NSLog(@"======================== executing cases ======");
    
    NSInvocationOperation* theOp = [[[NSInvocationOperation alloc] initWithTarget:self
                                                                         selector:@selector(runCasesInAnotherThreadWithId:) 
                                                                           object:runId] autorelease];
    [operationQueue addOperation:theOp];
    
    NSLog(@"======================== update result for Run %@ ======", runId);
    
    
}

- (void) runCasesInAnotherThreadWithId:(NSString*) runId{
    //    [[appDelegate runnerWrapper] executeSelectedCases];
    // replace this line to not submit 
    [runnerWrapper executeSelectedCasesWithSubmit:runId
                                            block:^(NSArray* objs){
                                                [self performSelectorOnMainThread:@selector(updateProgressViewWithRunning:)
                                                                       withObject:objs 
                                                                    waitUntilDone:YES];
                                                          }];
}


- (void) updateProgressViewWithRunning:(NSArray*) objs{
//    [progressView setProgress:[[objs objectAtIndex:0] floatValue]
//                     animated:YES];
//    
//    [doingLabel setText:[objs objectAtIndex:1]];
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
}@end
