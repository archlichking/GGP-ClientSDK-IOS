//
//  AppDelegate.h
//  OFQAJenkins
//
//  Created by lei zhu on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GreePlatform.h"
@class TestRunnerWrapper;
@class SBJsonParser;


@interface AppDelegate : UIResponder <UIApplicationDelegate, GreePlatformDelegate>{
@private
    TestRunnerWrapper* runnerWrapper;
    NSOperationQueue* operationQueue;
    SBJsonParser* jsonParser;
}

@property (strong, nonatomic) UIWindow *window;
@property (retain) TestRunnerWrapper* runnerWrapper;

- (NSData*) loadSettings;

@end
