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

@interface ViewController : UIViewController<UITextFieldDelegate>{
    UIButton* loadTestCasesButton;
    UIButton* runTestCasesButton;
    UITextField* suiteIdText;
    UITextField* runIdText;
    UISwitch* selectAllSwitch;
    
    UIActivityIndicatorView* progressIndicator;
    
    AppDelegate* appDelegate;
    CaseTableDelegate* caseTableDelegate;
    
    UITableView* tableView;
    
    
    NSOperationQueue* operationQueue;
}

@property (nonatomic, retain) IBOutlet UIButton* loadTestCasesButton;
@property (nonatomic, retain) IBOutlet UIButton* runTestCasesButton;
@property (nonatomic, retain) IBOutlet UITextField* suiteIdText;
@property (nonatomic, retain) IBOutlet UITextField* runIdText;
@property (nonatomic, retain) IBOutlet UISwitch* selectAllSwitch;

@property (nonatomic, retain) IBOutlet UITableView* tableView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* progressIndicator;

@property (retain) CaseTableDelegate* caseTableDelegate;

- (IBAction) loadCases;
- (IBAction) runCases;
- (IBAction) markAll;

@end
