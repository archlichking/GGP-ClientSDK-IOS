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
#import "GreeJSLoadAsynchronousCommand.h"
#import "GreeWebAppCache.h"
#import "GreeMatchers.h"

@interface GreeJSLoadAsynchronousCommand (ExposePrivateMethods)
- (void)windup;
- (GreeWebAppCache*)appCache;
- (void)waitForCoreFiles;
- (void)failedToUpdate:(NSNotification*)notification;
- (void)coreFilesUpdatedNotification:(NSNotification*)notification;
- (void)onCoreFilesSyncComplete;
- (void)fileUpdatedNotification:(NSNotification*)notification;
- (void)_readyToLoad;
@end

SPEC_BEGIN(GreeJSLoadAsynchronousCommandTest)

describe(@"GreeJSLoadAsynchronousCommand",^{
  registerMatchers(@"Gree");
  
  it(@"should have a description", ^{
    GreeJSLoadAsynchronousCommand *command = [[GreeJSLoadAsynchronousCommand alloc] init];    
    [[[command description] should] matchRegExp:@"<GreeJSLoadAsynchronousCommand:0x[0-9a-f]+, environment:\\(null\\)>"]; 
    [command release];
  });
  
  context(@"when executing", ^{
    it(@"should callback with a false result if there is no app parameters", ^{
      GreeJSLoadAsynchronousCommand *command = [[GreeJSLoadAsynchronousCommand alloc] init];
      
      [[[command should] receive] setResult:[NSNumber numberWithBool:NO]];
      [[[command should] receive] callback];
      
      [command execute:nil];
      [command release];
    });

    it(@"should callback with a false result if the url is not in the manifest", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockAppName", @"app",
        @"mockURL://", @"url",
        nil];
      
      GreeJSLoadAsynchronousCommand *command = [[GreeJSLoadAsynchronousCommand alloc] init];
      
      [[[command should] receive] setResult:[NSNumber numberWithBool:NO]];
      [[[command should] receive] callback];
      [command execute:parameters];
      [command release];
    });

    it(@"should listen for a core files notification if the web cache is syncing files", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockAppName", @"app",
        @"mockURL://", @"url",
        nil];
      
      GreeJSLoadAsynchronousCommand *command = [[GreeJSLoadAsynchronousCommand alloc] init];
      
      GreeWebAppCache *appCache = [GreeWebAppCache nullMock];
      [[appCache stubAndReturn:theValue(YES)] isURLInManifest:[NSURL URLWithString:@"mockURL://"]];
      [[appCache stubAndReturn:theValue(YES)] isSyncingCoreFiles];
      [[GreeWebAppCache stubAndReturn:appCache] appCacheForName:@"mockAppName"];
  
      [[command stubAndReturn:[NSURL URLWithString:@"mockURL://"]] urlToLoadWithParams:parameters];
      
      [[[[NSNotificationCenter defaultCenter] should] receive]
        addObserver:command
        selector:@selector(coreFilesUpdatedNotification:)
        name:GreeWebAppCacheCoreFilesUpdatedNotification
        object:appCache];
      
      [command execute:parameters];
      [command release];
    });

    it(@"should windup with a result of NO if it is not ready to boot", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockAppName", @"app",
        @"mockURL://", @"url",
        nil];
      
      GreeJSLoadAsynchronousCommand *command = [[GreeJSLoadAsynchronousCommand alloc] init];
      
      GreeWebAppCache *appCache = [GreeWebAppCache nullMock];
      [[appCache stubAndReturn:theValue(YES)] isURLInManifest:[NSURL URLWithString:@"mockURL://"]];
      [[appCache stubAndReturn:theValue(NO)] isSyncingCoreFiles];
      [[appCache stubAndReturn:theValue(NO)] isReadyToBoot];
      [[GreeWebAppCache stubAndReturn:appCache] appCacheForName:@"mockAppName"];
  
      [[command stubAndReturn:[NSURL URLWithString:@"mockURL://"]] urlToLoadWithParams:parameters];
      [[[command should] receive] setResult:[NSNumber numberWithBool:NO]];
      [[[command should] receive] windup];
      
      [command execute:parameters];
      [command release];
    });
    
    it(@"should listen for the file updated notification if it is ready to boot but the caches is not up to date", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockAppName", @"app",
        @"mockURL://", @"url",
        nil];
      
      GreeJSLoadAsynchronousCommand *command = [[GreeJSLoadAsynchronousCommand alloc] init];
      
      GreeWebAppCache *appCache = [GreeWebAppCache nullMock];
      [[appCache stubAndReturn:theValue(YES)] isURLInManifest:[NSURL URLWithString:@"mockURL://"]];
      [[appCache stubAndReturn:theValue(NO)] isSyncingCoreFiles];
      [[appCache stubAndReturn:theValue(YES)] isReadyToBoot];
      [[appCache stubAndReturn:theValue(NO)] hasUpToDateCacheForURL:[NSURL URLWithString:@"mockURL://"]];

      [[GreeWebAppCache stubAndReturn:appCache] appCacheForName:@"mockAppName"];
  
      [[command stubAndReturn:[NSURL URLWithString:@"mockURL://"]] urlToLoadWithParams:parameters];
      
      [[[[NSNotificationCenter defaultCenter] should] receive]
        addObserver:command
        selector:@selector(fileUpdatedNotification:)
        name:GreeWebAppCacheFileUpdatedNotification
        object:appCache];
      
      [command execute:parameters];
      [command release];
    });
    
    it(@"should listen for the file updated notification if it is ready to boot but the caches is not up to date", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockAppName", @"app",
        @"mockURL://", @"url",
        nil];
      
      GreeJSLoadAsynchronousCommand *command = [[GreeJSLoadAsynchronousCommand alloc] init];
      
      GreeWebAppCache *appCache = [GreeWebAppCache nullMock];
      [[appCache stubAndReturn:theValue(YES)] isURLInManifest:[NSURL URLWithString:@"mockURL://"]];
      [[appCache stubAndReturn:theValue(NO)] isSyncingCoreFiles];
      [[appCache stubAndReturn:theValue(YES)] isReadyToBoot];
      [[appCache stubAndReturn:theValue(NO)] hasUpToDateCacheForURL:[NSURL URLWithString:@"mockURL://"]];

      [[GreeWebAppCache stubAndReturn:appCache] appCacheForName:@"mockAppName"];
  
      [[command stubAndReturn:[NSURL URLWithString:@"mockURL://"]] urlToLoadWithParams:parameters];
      
      [[[[NSNotificationCenter defaultCenter] should] receive]
        addObserver:command
        selector:@selector(fileUpdatedNotification:)
        name:GreeWebAppCacheFileUpdatedNotification
        object:appCache];
      
      [command execute:parameters];
      [command release];
    });
    
    it(@"should call 'readyToLoad' on its subclass if it is ready to load and there is data at the file URL", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockAppName", @"app",
        @"mockURL://", @"url",
        nil];
      
      GreeJSLoadAsynchronousCommand *command = [[GreeJSLoadAsynchronousCommand alloc] init];
      
      GreeWebAppCache *appCache = [GreeWebAppCache nullMock];
      [[appCache stubAndReturn:theValue(YES)] isURLInManifest:[NSURL URLWithString:@"mockURL://"]];
      [[appCache stubAndReturn:theValue(NO)] isSyncingCoreFiles];
      [[appCache stubAndReturn:theValue(YES)] isReadyToBoot];
      [[appCache stubAndReturn:theValue(YES)] hasUpToDateCacheForURL:[NSURL URLWithString:@"mockURL://"]];
      [[appCache stubAndReturn:[NSURL fileURLWithPath:@"mockPath"]] cachePathForURL:[NSURL URLWithString:@"mockURL://"]];
      [[GreeWebAppCache stubAndReturn:appCache] appCacheForName:@"mockAppName"];
      
      [[NSData stubAndReturn:[NSData data]] dataWithContentsOfFile:[NSURL fileURLWithPath:@"mockPath"]];
  
      [[command stubAndReturn:[NSURL URLWithString:@"mockURL://"]] urlToLoadWithParams:parameters];
      [[[command should] receive] readyToLoadPath:[NSURL fileURLWithPath:@"mockPath"] data:[NSData data]];
      
      [command execute:parameters];
      [command release];
    });

    it(@"should windup and have a result of YES", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockAppName", @"app",
        @"mockURL://", @"url",
        nil];
      
      GreeJSLoadAsynchronousCommand *command = [[GreeJSLoadAsynchronousCommand alloc] init];
      
      GreeWebAppCache *appCache = [GreeWebAppCache nullMock];
      [[appCache stubAndReturn:theValue(YES)] isURLInManifest:[NSURL URLWithString:@"mockURL://"]];
      [[appCache stubAndReturn:theValue(NO)] isSyncingCoreFiles];
      [[appCache stubAndReturn:theValue(YES)] isReadyToBoot];
      [[appCache stubAndReturn:theValue(YES)] hasUpToDateCacheForURL:[NSURL URLWithString:@"mockURL://"]];
      [[GreeWebAppCache stubAndReturn:appCache] appCacheForName:@"mockAppName"];
        
      [[command stubAndReturn:[NSURL URLWithString:@"mockURL://"]] urlToLoadWithParams:parameters];
      [[[command should] receive] setResult:[NSNumber numberWithBool:YES]];
      [[[command should] receive] windup];
      
      [command execute:parameters];
      [command release];
    });
  });
  
  context(@"after receiving the failed to update notification", ^{
    it(@"should not windup if the url is not the loaded url", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockAppName", @"app",
        @"mockURL://", @"url",
        nil];
      
      GreeJSLoadAsynchronousCommand *command = [[GreeJSLoadAsynchronousCommand alloc] init];
      
      GreeWebAppCache *appCache = [GreeWebAppCache nullMock];
      [[appCache stubAndReturn:theValue(YES)] isURLInManifest:[NSURL URLWithString:@"mockURL://"]];
      
      [[command stubAndReturn:[NSURL URLWithString:@"mockURL://"]] urlToLoadWithParams:parameters];
      [[command stubAndReturn:appCache] appCache];
      
      [[[command should] receive] waitForCoreFiles];
      
      NSNotification *notification = [NSNotification
        notificationWithName:@"mockName"
        object:nil
        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
          [NSURL URLWithString:@"mockURL://"], @"url",
          nil]];
      
      [command execute:parameters];
      [command failedToUpdate:notification];
      [command release];            
    });
    
    it(@"should windup if the url is the loaded url", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockAppName", @"app",
        @"mockURL://", @"url",
        nil];
      
      GreeJSLoadAsynchronousCommand *command = [[GreeJSLoadAsynchronousCommand alloc] init];
      
      GreeWebAppCache *appCache = [GreeWebAppCache nullMock];
      [[appCache stubAndReturn:theValue(YES)] isURLInManifest:[NSURL URLWithString:@"mockURL://"]];
      [[GreeWebAppCache stubAndReturn:appCache] appCacheForName:@"mockAppName"];
      
      [[command stubAndReturn:[NSURL URLWithString:@"mockURL://"]] urlToLoadWithParams:parameters];
      
      [[[command should] receiveWithCount:2] windup];
      
      NSNotification *notification = [NSNotification
        notificationWithName:@"mockName"
        object:nil
        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
          [NSURL URLWithString:@"mockURL://"], @"url",
          nil]];
      
      [command execute:parameters];
      [command failedToUpdate:notification];
      [command release];            
    }); 
  });

  context(@"after receiving the core files updated notification", ^{
    it(@"should call the onCoreFilesSyncComplete method", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockAppName", @"app",
        @"mockURL://", @"url",
        nil];
      
      GreeJSLoadAsynchronousCommand *command = [[GreeJSLoadAsynchronousCommand alloc] init];
      
      GreeWebAppCache *appCache = [GreeWebAppCache nullMock];
      [[appCache stubAndReturn:theValue(YES)] isURLInManifest:[NSURL URLWithString:@"mockURL://"]];
      [[appCache stubAndReturn:theValue(YES)] isSyncingCoreFiles];
      [[GreeWebAppCache stubAndReturn:appCache] appCacheForName:@"mockAppName"];
  
      [[command stubAndReturn:[NSURL URLWithString:@"mockURL://"]] urlToLoadWithParams:parameters];
      
      [command execute:parameters];
      [[[command should] receive] onCoreFilesSyncComplete];
      [command coreFilesUpdatedNotification:[NSNotification nullMock]];
      [command release];
    });
  });

  context(@"after receiving the files update notification", ^{
    it(@"should call the _readyToLoad method if there is a URL", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockAppName", @"app",
        @"mockURL://", @"url",
        nil];
      
      GreeJSLoadAsynchronousCommand *command = [[GreeJSLoadAsynchronousCommand alloc] init];
      
      GreeWebAppCache *appCache = [GreeWebAppCache nullMock];
      [[appCache stubAndReturn:theValue(YES)] isURLInManifest:[NSURL URLWithString:@"mockURL://"]];
      [[appCache stubAndReturn:theValue(YES)] isSyncingCoreFiles];
      [[GreeWebAppCache stubAndReturn:appCache] appCacheForName:@"mockAppName"];
  
      [[command stubAndReturn:[NSURL URLWithString:@"mockURL://"]] urlToLoadWithParams:parameters];
      
      NSNotification *notification = [NSNotification
        notificationWithName:@"mockName"
        object:nil
        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
          [NSURL URLWithString:@"mockURL://"], GreeWebAppCacheFileUpdatedNotificationUrlKey,
          nil]];
      
      
      [command execute:parameters];
      [[[command should] receive] _readyToLoad];
      [command fileUpdatedNotification:notification];
      [command release];
    });
    
    it(@"should do nothing if the url is not equal to the urlToLoad", ^{
      NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:
        @"mockAppName", @"app",
        @"mockURL://", @"url",
        nil];
      
      GreeJSLoadAsynchronousCommand *command = [[GreeJSLoadAsynchronousCommand alloc] init];
      
      GreeWebAppCache *appCache = [GreeWebAppCache nullMock];
      [[appCache stubAndReturn:theValue(YES)] isURLInManifest:[NSURL URLWithString:@"mockURL://"]];
      [[appCache stubAndReturn:theValue(YES)] isSyncingCoreFiles];
      [[GreeWebAppCache stubAndReturn:appCache] appCacheForName:@"mockAppName"];
  
      [[command stubAndReturn:[NSURL URLWithString:@"mockURL://"]] urlToLoadWithParams:parameters];
      
      NSNotification *notification = [NSNotification
        notificationWithName:@"mockName"
        object:nil
        userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
          [NSURL URLWithString:@"mockURL1://"], GreeWebAppCacheFileUpdatedNotificationUrlKey,
          nil]];
      
      [command execute:parameters];
      [[[command shouldNot] receive] _readyToLoad];
      [command fileUpdatedNotification:notification];
      [command release];
    });
  });
});

SPEC_END
