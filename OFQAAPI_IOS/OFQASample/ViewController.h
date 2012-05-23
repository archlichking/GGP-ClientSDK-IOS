//
//  ViewController.h
//  OFQASample
//
//  Created by lei zhu on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AppDelegate;
@class CaseTableDelegate;

@interface ViewController : UIViewController<UITextFieldDelegate, UIAlertViewDelegate>{
    UIButton* loadTestCasesButton;
    UIButton* runTestCasesButton;
    UITextField* suiteIdText;
    UITextField* runIdText;
    UILabel* doingLabel;
    
    UIButton* selectExecuteButton;
    
    UIActivityIndicatorView* progressIndicator;
    
    AppDelegate* appDelegate;
    CaseTableDelegate* caseTableDelegate;
    
    UITableView* tableView;
    
    UIAlertView* selectView;
    UIProgressView* progressView;
    
    NSOperationQueue* operationQueue;
}

@property (nonatomic, retain) IBOutlet UIButton* loadTestCasesButton;
@property (nonatomic, retain) IBOutlet UIButton* runTestCasesButton;
@property (nonatomic, retain) IBOutlet UIButton* selectExecuteButton;
@property (nonatomic, retain) IBOutlet UITextField* suiteIdText;
@property (nonatomic, retain) IBOutlet UITextField* runIdText;

@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* progressIndicator;
@property (nonatomic, retain) IBOutlet UIAlertView* selectView;
@property (nonatomic, retain) IBOutlet UIProgressView* progressView;
@property (nonatomic, retain) IBOutlet UILabel* doingLabel;

@property (retain) CaseTableDelegate* caseTableDelegate;

- (IBAction) loadCases;
- (IBAction) runCases;

- (void) updateProgressViewWithRunning:(NSArray*) objs;

@end
