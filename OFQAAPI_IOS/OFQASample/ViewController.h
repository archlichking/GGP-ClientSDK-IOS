//
//  ViewController.h
//  OFQASample
//
//  Created by lei zhu on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIViewController+GreePlatform.h>

#import "GreeWidget.h"

@class AppDelegate;
@class CaseTableDelegate;
@class MAlertView;



@interface ViewController : UIViewController<UITextFieldDelegate, UIAlertViewDelegate>{
    UIBarButtonItem* loadTestCasesButton;
    UIBarButtonItem* runTestCasesButton;
    
    UITextField* suiteIdText;
    UITextField* runIdText;
    
    UILabel* doingLabel;
    UILabel* memLabel;
    
    UIBarButtonItem* selectExecuteButton;
    
    AppDelegate* appDelegate;
    CaseTableDelegate* caseTableDelegate;
    
    UITableView* tableView;
    
    UIAlertView* selectView;
    MAlertView* suiteAndRunView;
    
    UIView* userBlockView;
    
    UIProgressView* progressView;
    
    NSOperationQueue* operationQueue;
    
    UISearchBar* tableSearchBar;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem* loadTestCasesButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* runTestCasesButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* selectExecuteButton;
@property (nonatomic, retain) IBOutlet UITextField* suiteIdText;
@property (nonatomic, retain) IBOutlet UITextField* runIdText;

@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UIAlertView* selectView;
@property (nonatomic, retain) IBOutlet MAlertView* suiteAndRunView;
@property (nonatomic, retain) IBOutlet UIProgressView* progressView;

@property (nonatomic, retain) IBOutlet UIView* userBlockView;
@property (nonatomic, retain) IBOutlet UILabel* doingLabel;
@property (nonatomic, retain) IBOutlet UILabel* memLabel;
@property (nonatomic, retain) IBOutlet UISearchBar* tableSearchBar;

@property (retain) CaseTableDelegate* caseTableDelegate;

- (void) loadCases;
- (IBAction) runCases;

- (void) updateProgressViewWithRunning:(NSArray*) objs;

- (void) loadPopup:(GreePopup*) popup;

@end
