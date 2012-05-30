//
//  ViewController.h
//  OFQAJenkins
//
//  Created by lei zhu on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;

@interface ViewController : UIViewController{
    UILabel* doingLabel;    
    UIProgressView* progressView;
}


@property (nonatomic, retain) IBOutlet UIProgressView* progressView;
@property (nonatomic, retain) IBOutlet UILabel* doingLabel;

@end
