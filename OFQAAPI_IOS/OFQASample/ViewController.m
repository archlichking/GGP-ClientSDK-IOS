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
#import "TestCaseWrapper.h"
#import "TestRunnerWrapper.h"
#import "TcmCommunicator.h"

#import "MAlertView.h"


#import "CaseTableDelegate.h"

@implementation ViewController

@synthesize suiteIdText;
@synthesize runIdText;
@synthesize runTestCasesButton;
@synthesize loadTestCasesButton;
@synthesize tableView;
@synthesize selectView;
@synthesize suiteAndRunView;
@synthesize selectExecuteButton;
@synthesize progressView;
@synthesize doingLabel;
@synthesize userBlockView;
@synthesize tableSearchBar;

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
    
    [selectView setTag:2];
    [selectView addButtonWithTitle:@"All"];
    [selectView addButtonWithTitle:@"Failed"];
    [selectView addButtonWithTitle:@"Un All"];
    
    
    suiteAndRunView = [[MAlertView alloc] initWithTitle:@"Suite and Run" 
                                                 message:@"" 
                                                delegate:self 
                                       cancelButtonTitle:@"Cancel" 
                                       otherButtonTitles:@"Load", nil];
    
    [suiteAndRunView setTag:1];
    
    suiteIdText = [[UITextField alloc] init];
    [suiteAndRunView addTextField:suiteIdText placeHolder:@"Suite ID : 185"];    
    
    runIdText = [[UITextField alloc] init];
    [suiteAndRunView addTextField:runIdText placeHolder:@"Run ID : 432"];
    
    
    [progressView setHidden:TRUE];
    [userBlockView setHidden:TRUE];
    [userBlockView addSubview:progressView];
    [userBlockView addSubview:doingLabel];
    
    [tableView setContentOffset:CGPointMake(0, 44)];
    [doingLabel setHidden:TRUE];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString* title = [alertView buttonTitleAtIndex:buttonIndex];
    switch ([alertView tag]) {
        case 1:
            // suite and run select alert
            if ([title isEqualToString:@"Load"]) {
                [self loadCases];
            }
            break;
        case 2:
            // case select alert
            if ([title isEqualToString:@"All"]) {
                [[appDelegate runnerWrapper] markCaseWrappers:[TestCaseWrapper All]];
            }else if ([title isEqualToString:@"Failed"]) {
                [[appDelegate runnerWrapper] markCaseWrappers:[TestCaseWrapper Failed]];
            }else if ([title isEqualToString:@"Un All"]) {
                [[appDelegate runnerWrapper] markCaseWrappers:[TestCaseWrapper UnAll]];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshCases" object:nil];
            break;
        default:
            break;
    }
    
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
    [tableView setContentOffset:CGPointMake(0, 44)];
}

- (void) loadCasesInAnotherThread{
    [[appDelegate runnerWrapper] emptyCaseWrappers];
    [[appDelegate runnerWrapper] buildRunner:[suiteIdText text] == nil?@"185":[suiteIdText text]];
    
    NSArray* tmp = [[appDelegate runnerWrapper] getCaseWrappers];
    [(CaseTableDelegate*)[tableView dataSource] setTableItems:tmp];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshCases" object:nil];
    
    [self performSelectorOnMainThread:@selector(dismissAllProgressDisplay)
                           withObject:nil
                        waitUntilDone:YES];
}

- (void) runCasesInAnotherThread{
//    [[appDelegate runnerWrapper] executeSelectedCases];
    // replace this line to not submit 
    [[appDelegate runnerWrapper] executeSelectedCasesWithSubmit:[runIdText text] == nil?@"432":[runIdText text]
                                                          block:^(NSArray* objs){
                                                              [self performSelectorOnMainThread:@selector(updateProgressViewWithRunning:)
                                                                                     withObject:objs 
                                                                                  waitUntilDone:YES];
                                                          }];
    
    NSArray* tmp = [[appDelegate runnerWrapper] getCaseWrappers];
    [(CaseTableDelegate*)[tableView dataSource] setTableItems:tmp];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshCases" object:nil];
    
    [self performSelectorOnMainThread:@selector(dismissAllProgressDisplay)
                           withObject:nil
                        waitUntilDone:YES];
}


- (IBAction) chooseSelection{
    [selectView show];
}

- (IBAction) chooseSuiteAndRun{
    [suiteAndRunView show];
}

- (void) loadCases
{
    [userBlockView setHidden:NO];
    NSInvocationOperation* theOp = [[[NSInvocationOperation alloc] initWithTarget:self
                                                                        selector:@selector(loadCasesInAnotherThread) 
                                                                          object:nil] autorelease];
    [operationQueue addOperation:theOp]; 
    
}

- (IBAction) runCases{
    [userBlockView setHidden:NO];
    [progressView setProgress:0.];
    [progressView setHidden:NO];
    [doingLabel setText:@""];
    [doingLabel setHidden:NO];
    
    [[self view] setUserInteractionEnabled:NO];
    
    NSInvocationOperation* theOp = [[[NSInvocationOperation alloc] initWithTarget:self
                                                                         selector:@selector(runCasesInAnotherThread) 
                                                                           object:nil] autorelease];
    [operationQueue addOperation:theOp];
}

- (void) updateProgressViewWithRunning:(NSArray*) objs{
    [progressView setProgress:[[objs objectAtIndex:0] floatValue]
                     animated:YES];
    
    [doingLabel setText:[objs objectAtIndex:1]];
}

- (void) dismissAllProgressDisplay{
    [userBlockView setHidden:YES];
    [progressView setHidden:YES];
    [doingLabel setHidden:YES];
    [[self view] setUserInteractionEnabled:YES];
}

@end
