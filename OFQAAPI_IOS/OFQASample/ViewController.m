//
//  ViewController.m
//  OFQASample
//
//  Created by lei zhu on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

#import "objc/runtime.h"
#import "SBJson.h"
#import "AppDelegate.h"
#import "CaseTableDelegate.h"
#import "TestCaseWrapper.h"
#import "TestRunnerWrapper.h"
#import "TcmCommunicator.h"


@implementation ViewController

@synthesize suiteIdText;
@synthesize runIdText;
@synthesize runTestCasesButton;
@synthesize loadTestCasesButton;
@synthesize progressIndicator;
@synthesize tableView;
@synthesize selectView;
@synthesize selectExecuteButton;

@synthesize caseTableDelegate;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    caseTableDelegate = [[CaseTableDelegate alloc] init];
    [tableView setDataSource:caseTableDelegate];
    [tableView setDelegate:caseTableDelegate];
    
    progressIndicator = [[UIActivityIndicatorView alloc] init];
    [progressIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    progressIndicator.hidden = YES;
    progressIndicator.center = [[self tableView] center];
    
    [self.view addSubview:progressIndicator];
    
    operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount:1];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshCases:)
                                                 name:@"RefreshCases" 
                                               object:nil];
    [self suiteIdText].delegate = self;
    [self runIdText].delegate = self;
    
    // init select popup dialog
    selectView = [[UIAlertView alloc] initWithTitle:@"select" 
                                            message:@"" 
                                           delegate:self 
                                  cancelButtonTitle:nil 
                                  otherButtonTitles:nil];
    
    [selectView addButtonWithTitle:@"All"];
    [selectView addButtonWithTitle:@"Failed"];
    [selectView addButtonWithTitle:@"Un All"];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString* title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"All"]) {
        [[appDelegate runnerWrapper] markCaseWrappers:[TestCaseWrapper All]];
    }else if ([title isEqualToString:@"Failed"]) {
        [[appDelegate runnerWrapper] markCaseWrappers:[TestCaseWrapper Failed]];
    }else if ([title isEqualToString:@"Un All"]) {
        [[appDelegate runnerWrapper] markCaseWrappers:[TestCaseWrapper UnAll]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshCases" object:nil];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void) refreshCases:(NSNotification*) notification{
    [tableView reloadData];
}

- (void) loadCasesInAnotherThread{
    [[appDelegate runnerWrapper] emptyCaseWrappers];
    [[appDelegate runnerWrapper] buildRunner:[suiteIdText text]];
    
    NSArray* tmp = [[appDelegate runnerWrapper] getCaseWrappers];
    [(CaseTableDelegate*)[tableView dataSource] setTableItems:tmp];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshCases" object:nil];
    [progressIndicator stopAnimating];
}

- (void) runCasesInAnotherThread{
//    [[appDelegate runnerWrapper] executeSelectedCases];
    // replace this line to not submit 
    [[appDelegate runnerWrapper] executeSelectedCasesWithSubmit:[runIdText text] 
                                                          block:^(TcmCommunicator* tcmC, NSString* runId, NSArray* cases){
                                                              [tcmC postCasesResultByRunId:runId cases:cases];
                                                          }];
    
    NSArray* tmp = [[appDelegate runnerWrapper] getCaseWrappers];
    [(CaseTableDelegate*)[tableView dataSource] setTableItems:tmp];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshCases" object:nil];
    [progressIndicator stopAnimating];
}


- (IBAction) chooseSelection{
    [selectView show];
}

- (IBAction) loadCases
{
    [progressIndicator startAnimating];
    NSInvocationOperation* theOp = [[[NSInvocationOperation alloc] initWithTarget:self
                                                                        selector:@selector(loadCasesInAnotherThread) 
                                                                          object:nil] autorelease];
    [operationQueue addOperation:theOp]; 
}

- (IBAction) runCases{
    [progressIndicator startAnimating];
    NSInvocationOperation* theOp = [[[NSInvocationOperation alloc] initWithTarget:self
                                                                         selector:@selector(runCasesInAnotherThread) 
                                                                           object:nil] autorelease];
    [operationQueue addOperation:theOp];
}

@end
