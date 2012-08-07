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
#import "GreeWidget.h"
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
                                                 name:CommandDispatchCommand 
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
    [suiteAndRunView addTextField:runIdText placeHolder:@"Run ID : 416"];
    
    
    [progressView setHidden:TRUE];
    [userBlockView setHidden:TRUE];
    [userBlockView addSubview:progressView];
    [userBlockView addSubview:doingLabel];
    [userBlockView addSubview:memLabel];
    
    [tableView setContentOffset:CGPointMake(0, 44)];
    [doingLabel setHidden:TRUE];
    [memLabel setHidden:TRUE];
    
    [tableSearchBar setDelegate:caseTableDelegate];
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
    NSDictionary* userInfo = [notification userInfo];
    if (![userInfo objectForKey:@"isSearching"]) {
        [tableView setContentOffset:CGPointMake(0, 44)];
    }
}

- (void) loadCasesInAnotherThread{
    [[appDelegate runnerWrapper] emptyCaseWrappers];
    [[appDelegate runnerWrapper] buildRunner:[suiteIdText text] == nil?@"178":[suiteIdText text]];
    
    NSArray* tmp = [[appDelegate runnerWrapper] getCaseWrappers];
    [(CaseTableDelegate*)[tableView dataSource] initTableItems:tmp];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshCases" object:nil];
    
    [self performSelectorOnMainThread:@selector(dismissAllProgressDisplay)
                           withObject:nil
                        waitUntilDone:YES];
}

- (void) runCasesInAnotherThread{
    [[appDelegate runnerWrapper] setCaseWrappers:[(CaseTableDelegate*)[tableView dataSource] displayTableItems]];
    // replace this line to not submit 
    [[appDelegate runnerWrapper] executeSelectedCasesWithSubmit:[runIdText text] == nil?@"416":[runIdText text]
                                                          block:^(NSArray* objs){
                                                              [self performSelectorOnMainThread:@selector(updateProgressViewWithRunning:)
                                                                                     withObject:objs 
                                                                                  waitUntilDone:YES];
                                                          }];
    
    NSMutableArray* tmp = [[appDelegate runnerWrapper] getCaseWrappers];
    [(CaseTableDelegate*)[tableView dataSource] setDisplayTableItems:tmp];
    
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
    [memLabel setText:@""];
    [doingLabel setHidden:NO];
    [memLabel setHidden:NO];
    [tableSearchBar resignFirstResponder];
    
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
            
        case executeInPaymentRequestPopup:
            [self performSelectorOnMainThread:@selector(launchPaymentRequestPopupInWallet:) 
                                   withObject:extra 
                                waitUntilDone:YES];
            break;
        case executeInDepositPopup:
            [self performSelectorOnMainThread:@selector(launchPaymentDepositPopupInWallet) 
                                   withObject:extra 
                                waitUntilDone:YES];
            break;
        case executeInDepositHistoryPopup:
            [self performSelectorOnMainThread:@selector(launchPaymentDepositHistoryPopupInWallet) 
                                   withObject:extra 
                                waitUntilDone:YES];
            break;
            
        case launchJskitPopup:
            [self performSelectorOnMainThread:@selector(launchJskitPopup:) 
                                   withObject:extra 
                                waitUntilDone:YES];
            break;
            
        case executeJskitCommandInPopup:
            [self performSelectorOnMainThread:@selector(executeJskitCommandInPopup:) 
                                   withObject:extra 
                                waitUntilDone:YES];
            
            [StepDefinition notifyOutsideStep];
            break;
            
            
        case getWidget:
            [self performSelectorOnMainThread:@selector(activeWidget:) 
                                   withObject:extra 
                                waitUntilDone:YES];
            break;
        case hideWidget:
            [self performSelectorOnMainThread:@selector(hideGreeWidget) 
                                   withObject:nil 
                                waitUntilDone:YES];
            [StepDefinition notifyOutsideStep];
            break;
        default:
            break;
    }
}

- (void) launchPaymentRequestPopupInWallet:(NSDictionary*) info{
    [GreeWallet paymentWithItems:[info objectForKey:@"items"]
                         message:[info objectForKey:@"message"]
                     callbackUrl:[info objectForKey:@"callbackUrl"]
                    successBlock:[info objectForKey:@"sBlock"]
                    failureBlock:[info objectForKey:@"fBlock"]];
}

- (void) launchPaymentDepositPopupInWallet{
    [GreeWallet launchDepositPopup];
}

- (void) launchPaymentDepositHistoryPopupInWallet{
    [GreeWallet launchDepositHistoryPopup];
}

- (NSString*) wrapJsCommand:(NSString*) command{
    return [NSString stringWithFormat:@"(function(){%@ return(%@)})()", 
            [appDelegate baseJsCommand], 
            command];
}

- (void) executeJsInPopup:(NSDictionary*) info{
    GreePopup* popup = (GreePopup*) [info objectForKey:@"executor"];
    NSString* jsCommand = [self wrapJsCommand:[info objectForKey:@"jsCommand"]];
    NSString* jsResult = [popup stringByEvaluatingJavaScriptFromString:jsCommand];
    void (^callbackBlock)(NSString*) = [info objectForKey:@"jsCallback"];
    callbackBlock(jsResult);
}

- (void) launchJskitPopup:(NSDictionary*) info{
    GreePopup* popup = (GreePopup*) [info objectForKey:@"executor"];
    popup.willLaunchBlock = ^(id sender){
        NSString *aFilePath = [[NSBundle mainBundle] pathForResource:@"cases.html" ofType:nil];
        NSData *aHtmlData = [NSData dataWithContentsOfFile:aFilePath];
        NSURL *aBaseURL = [NSURL fileURLWithPath:aFilePath];
        [popup loadData:aHtmlData MIMEType:@"text/html" textEncodingName:nil baseURL:aBaseURL];
    };
    
    [self showGreePopup:popup];
}

- (void) executeJskitCommandInPopup:(NSDictionary*) info{
    
    GreePopup* popup = (GreePopup*) [info objectForKey:@"executor"];
    NSString* element = [info objectForKey:@"jsKitElement"];
    NSString* cmd = [info objectForKey:@"jsKitCommand"];
    NSString* value = [info objectForKey:@"jsKitValue"];
    
    NSString* fullCommand = @"";
    
    if ([element isEqualToString:@""]) {
        // full command mode
        fullCommand = cmd;
    }else{
        if ([value isEqualToString:@""]) {
            fullCommand = [NSString stringWithFormat:@"%@(%@)", cmd, element];
        }else{
            fullCommand = [NSString stringWithFormat:@"%@(%@, %@)", cmd, element, value];
        }
    }
    
    NSString* jsResult = [popup stringByEvaluatingJavaScriptFromString:fullCommand];
    void (^callbackBlock)(NSString*) = [info objectForKey:@"jsKitCallback"];
    callbackBlock(jsResult);
}

- (void) activeWidget:(NSDictionary*) info{
    [self showGreeWidgetWithDataSource:self];
    GreeWidget* widget = [self activeGreeWidget];
    [widget setExpandable:[[info objectForKey:@"expandable"] boolValue]];
    [widget setPosition:[[info objectForKey:@"position"] intValue]];
    void (^callbackBlock)(GreeWidget*) = [info objectForKey:@"cmdCallback"];
    callbackBlock(widget);
}

#pragma mark - GreeWidgetDataSource
- (UIImage*)screenshotImageForWidget:(GreeWidget*)widget
{
    //    UIGraphicsBeginImageContext(self.view.layer.visibleRect.size);
    //    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    //    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    //    UIGraphicsEndImageContext();
    //    return image;
}

@end
