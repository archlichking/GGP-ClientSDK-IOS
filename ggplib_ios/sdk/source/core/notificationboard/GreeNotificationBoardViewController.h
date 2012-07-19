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

#import <UIKit/UIKit.h>
#import "GreeNotificationBoard+Internal.h"
#import "GreeNotificationBoardViewControllerDelegate.h"

extern NSString* const GreeNotificationBoardDidLaunchNotification;
extern NSString* const GreeNotificationBoardDidDismissNotification;

@interface GreeNotificationBoardViewController : UIViewController <UIWebViewDelegate>
@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) UINavigationBar *navigationBar;
@property (nonatomic, retain) NSURL *URL;
@property (nonatomic, assign) id<GreeNotificationBoardViewControllerDelegate> delegate;
@property (nonatomic, retain) id results;

+ (NSURL*)URLForLaunchType:(GreeNotificationBoardLaunchType)aType withParameters:(NSDictionary*)parameters;

- (id)initWithURL:(NSURL*)URL;
@end

