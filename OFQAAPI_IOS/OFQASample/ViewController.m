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
#import "CommandUtil.h"
#import "Constant.h"
#import "StepDefinition.h"

#import "MAlertView.h"
#import "GreePopup.h"
#import "GreeWallet.h"

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
@synthesize memLabel;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dispatchCommand:)
                                                 name:CommandDispatchPopupCommand 
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
    [suiteAndRunView addTextField:suiteIdText placeHolder:@"Suite ID : 178"];    
    
    runIdText = [[UITextField alloc] init];
    [suiteAndRunView addTextField:runIdText placeHolder:@"Run ID : 402"];
    
    
    [progressView setHidden:TRUE];
    [userBlockView setHidden:TRUE];
    [userBlockView addSubview:progressView];
    [userBlockView addSubview:doingLabel];
    [userBlockView addSubview:memLabel];
    
    [tableView setContentOffset:CGPointMake(0, 44)];
    [doingLabel setHidden:TRUE];
    [memLabel setHidden:TRUE];
    
//    [self showGreeWidgetWithDataSource:self];
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
    [[appDelegate runnerWrapper] buildRunner:[suiteIdText text] == nil?@"178":[suiteIdText text]];
    
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
    [[appDelegate runnerWrapper] executeSelectedCasesWithSubmit:[runIdText text] == nil?@"402":[runIdText text]
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
    exit(0);
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
    [memLabel setText:@""];
    [doingLabel setHidden:NO];
    [memLabel setHidden:NO];
    
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
    [memLabel setText:[objs objectAtIndex:2]];
}

- (void) dismissAllProgressDisplay{
    [userBlockView setHidden:YES];
    [progressView setHidden:YES];
    [doingLabel setHidden:YES];
    [memLabel setHidden:YES];
    [[self view] setUserInteractionEnabled:YES];
}

- (void) dispatchCommand:(NSNotification*) notification{
    NSDictionary* infoDic = [notification userInfo];
    
    if ([self respondsToSelector:@selector(dispatchCommand:withExecutor:extraInfo:)]) {
        [self dispatchCommand:[infoDic objectForKey:@"command"] 
                 withExecutor:[infoDic objectForKey:@"executor"] 
                    extraInfo:infoDic]; 
    }
}

- (void) dispatchCommand:(NSString*) command 
            withExecutor:(id) popupExecutor 
               extraInfo:(NSDictionary*) extra{
    
    switch ([command intValue]) {
        case launchPopup:
            [self performSelectorOnMainThread:@selector(showGreePopup:) 
                                   withObject: (GreePopup*) popupExecutor
                                waitUntilDone:NO];
            break;
        case dismissPopup:
            [self performSelectorOnMainThread:@selector(dismissGreePopup) 
                                   withObject:(GreePopup*) popupExecutor 
                                waitUntilDone:YES];
            [StepDefinition notifyOutsideStep];
            break;  
        case executeJavascriptInPopup:
            [self performSelectorOnMainThread:@selector(executeJsInPopup:) 
                                   withObject:extra 
                                waitUntilDone:YES];
            [StepDefinition notifyOutsideStep];
            break;
            
        case executeInWallet:
            [self performSelectorOnMainThread:@selector(launchDeositePopupInWallet:) 
                                   withObject:extra 
                                waitUntilDone:YES];
            [StepDefinition notifyOutsideStep];
            break;
        default:
            break;
    }
}

- (void) launchDeositePopupInWallet:(NSDictionary*) info{
    NSMutableArray* arr = [[NSMutableArray alloc] initWithObjects:[info objectForKey:@"item"], nil];
    [GreeWallet paymentWithItems:arr
                         message:@"ahha" 
                     callbackUrl:@"http://www.google.com.hk" 
                    successBlock:[info objectForKey:@"sBlock"] 
                    failureBlock:[info objectForKey:@"fBlock"]];
}

- (void) executeJsInPopup:(NSDictionary*) info{
    GreePopup* popup = (GreePopup*) [info objectForKey:@"executor"];
    NSString* jsResult = [popup stringByEvaluatingJavaScriptFromString:[info objectForKey:@"jsCommand"]];
    void (^callbackBlock)(NSString*) = [info objectForKey:@"jsCallback"];
    callbackBlock(jsResult);
}

//#pragma mark - GreeWidgetDataSource
//- (UIImage*)screenshotImageForWidget:(GreeWidget*)widget
//{
//    UIView* viewForScreenShot = self.view;
//    UIGraphicsBeginImageContext(viewForScreenShot.layer.visibleRect.size);
//    [viewForScreenShot.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return image;
//}

@end
