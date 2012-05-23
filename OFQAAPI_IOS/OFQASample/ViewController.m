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


#import "CaseTableDelegate.h"

@implementation ViewController

@synthesize suiteIdText;
@synthesize runIdText;
@synthesize runTestCasesButton;
@synthesize loadTestCasesButton;
@synthesize progressIndicator;
@synthesize tableView;
@synthesize selectView;
@synthesize suiteAndRunView;
@synthesize selectExecuteButton;
@synthesize progressView;
@synthesize doingLabel;

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
    progressIndicator.center = [self.view center];
    
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
    
    [selectView setTag:2];
    [selectView addButtonWithTitle:@"All"];
    [selectView addButtonWithTitle:@"Failed"];
    [selectView addButtonWithTitle:@"Un All"];
    
    
    suiteAndRunView = [[UIAlertView alloc] initWithTitle:@"Suite and Run" 
                                                 message:@"" 
                                                delegate:self 
                                       cancelButtonTitle:@"Cancel" 
                                       otherButtonTitles:@"Load", nil];
    
    [suiteAndRunView setTag:1];
    
    UILabel* suiteIdLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 40.0, 60.0, 18.0)];
//    [suiteIdLabel setTextColor:[UIColor whiteColor]];
    [suiteIdLabel setText:@"Suite ID"];
    [suiteAndRunView addSubview:suiteIdLabel];
    
    suiteIdText = [[UITextField alloc] initWithFrame:CGRectMake(82.0, 40.0, 40.0, 19.0)];
    [suiteIdText setText:@"185"];
    [suiteIdText setBackgroundColor:[UIColor whiteColor]];
    [suiteAndRunView addSubview:suiteIdText];
    
    UILabel* runIdLabel = [[UILabel alloc] initWithFrame:CGRectMake(152.0, 40.0, 60.0, 18.0)];
    //    [suiteIdLabel setTextColor:[UIColor whiteColor]];
    [runIdLabel setText:@"Run ID"];
    [suiteAndRunView addSubview:runIdLabel];
    
    runIdText = [[UITextField alloc] initWithFrame:CGRectMake(222.0, 40.0, 40.0, 18.0)];
    [runIdText setText:@"432"];
    [runIdText setBackgroundColor:[UIColor whiteColor]];
    [suiteAndRunView addSubview:runIdText];
    
    [progressView setHidden:TRUE];
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
}

- (void) loadCasesInAnotherThread{
    [[appDelegate runnerWrapper] emptyCaseWrappers];
    [[appDelegate runnerWrapper] buildRunner:[suiteIdText text]];
    
    NSArray* tmp = [[appDelegate runnerWrapper] getCaseWrappers];
    [(CaseTableDelegate*)[tableView dataSource] setTableItems:tmp];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshCases" object:nil];
    
    [self performSelectorOnMainThread:@selector(dismissAllProgressDisplay)
                           withObject:nil
                        waitUntilDone:YES];
    [progressIndicator stopAnimating];
}

- (void) runCasesInAnotherThread{
//    [[appDelegate runnerWrapper] executeSelectedCases];
    // replace this line to not submit 
    [[appDelegate runnerWrapper] executeSelectedCasesWithSubmit:[runIdText text] 
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
    [progressIndicator stopAnimating];
}


- (IBAction) chooseSelection{
    [selectView show];
}

- (IBAction) chooseSuiteAndRun{
    [suiteAndRunView show];
}

- (void) loadCases
{
    [progressIndicator startAnimating];
    NSInvocationOperation* theOp = [[[NSInvocationOperation alloc] initWithTarget:self
                                                                        selector:@selector(loadCasesInAnotherThread) 
                                                                          object:nil] autorelease];
    [operationQueue addOperation:theOp]; 
    
}

- (IBAction) runCases{
    [progressIndicator startAnimating];
    
    [progressView setProgress:0.];
    [progressView setHidden:NO];
    
    [doingLabel setHidden:NO];
    NSInvocationOperation* theOp = [[[NSInvocationOperation alloc] initWithTarget:self
                                                                         selector:@selector(runCasesInAnotherThread) 
                                                                           object:nil] autorelease];
    [operationQueue addOperation:theOp];
}

- (void) updateProgressViewWithRunning:(NSArray*) objs{
    NSLog(@"%@", objs);
    [progressView setProgress:[[objs objectAtIndex:0] floatValue]
                     animated:YES];
    
    [doingLabel setText:[objs objectAtIndex:1]];
}

- (void) dismissAllProgressDisplay{
    [progressView setHidden:YES];
    [doingLabel setHidden:YES];
}

@end
