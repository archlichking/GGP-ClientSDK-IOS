//
//  AppDelegate.h
//  OFQASample
//
//  Created by lei zhu on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GreePlatform.h"
#import "TestCaseWrapper.h"
@class TestRunnerWrapper;

@interface AppDelegate : UIResponder <UIApplicationDelegate, GreePlatformDelegate>{
@private
    TestRunnerWrapper* runnerWrapper;
    NSString* baseJsCommand;
}

@property (strong, nonatomic) UIWindow *window;
@property (retain) TestRunnerWrapper* runnerWrapper;
@property (retain) NSString* baseJsCommand;

- (NSData*) loadConfig:(NSString*) fname;

@end
