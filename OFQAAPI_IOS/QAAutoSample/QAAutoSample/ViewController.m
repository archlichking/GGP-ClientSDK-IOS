//
//  ViewController.m
//  OFQASample
//
//  Created by lei zhu on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

#import "objc/runtime.h"
#import "AppDelegate.h"
#import "TestCaseWrapper.h"
#import "TestRunner.h"
#import "TestRunner+TcmResultPusher.h"
#import "CommandUtil.h"
#import "StepDefinition.h"
#import "QALog.h"

#import "QAAutoFramework.h"

#import "MAlertView.h"
#import "GreePopup.h"
#import "GreeWallet.h"
#import "GreeWidget.h"
#import "GreeAgreementPopup.h"

#import "objc/runtime.h"
#import <mach/mach.h>
#import <QuartzCore/QuartzCore.h>
#import "UIViewController+GreePlatform.h"
#import "CaseTableDelegate.h"


@interface QAAutoFramework (RunWithNotificationBlock)
- (void) runCases:(NSArray *)cases
    withTcmSubmit:(NSString*) runId
    withNotificationBlock:(void(^)(NSDictionary* params))block;

@end

@implementation QAAutoFramework (RunWithNotificationBlock)
- (void) runCases:(NSArray *)cases
    withTcmSubmit:(NSString*) runId
    withNotificationBlock:(void(^)(NSDictionary* params))block{
    if (cases) {
        [currentTestCases removeAllObjects];
        [currentTestCases addObjectsFromArray:cases];
    }
    
    int alreadyDoneNumber = 0;
    int all = [currentTestCases count];
    NSString* doing = @"";
    NSString* mem = @"";
    
    struct task_basic_info info;
    // used for memory inspect
    mach_msg_type_number_t size = sizeof(info);
    
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    unsigned long baseMem = 1l;
    
    if( kerr == KERN_SUCCESS ) {
        baseMem = info.resident_size;
    }
    
    // case running
    for (TestCase* tc in currentTestCases) {
        [runner runCase:tc];
        if (block) {
            alreadyDoneNumber ++;
            doing = [NSString stringWithFormat:@"executing %d/%d", alreadyDoneNumber, all];
            
            kerr = task_info(mach_task_self(),
                             TASK_BASIC_INFO,
                             (task_info_t)&info,
                             &size);
            if( kerr == KERN_SUCCESS ) {
                mem = [NSString stringWithFormat:@"mem usage(MB):%0.3f, INC by:%0.2f",
                       (float)info.resident_size/(1024*1024),
                       (float)(info.resident_size-baseMem)*100/baseMem];
            }
            
            NSMutableDictionary* ps = [[NSMutableDictionary alloc] init];
            NSArray* tempA = [[[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%0.1f", (float)alreadyDoneNumber/all],
                               doing,
                               mem,
                               nil] autorelease];
            [ps setObject:tempA
                   forKey:@"monitorParams"];
            block(ps);
            
            [ps release];
        }
    }
    
    alreadyDoneNumber = 0.;
    
    // case submitting
    for (TestCase* tc in currentTestCases){
        [runner pushCase:tc
                    toRunId:runId];
        if (block) {
            alreadyDoneNumber ++;
            doing = [NSString stringWithFormat:@"submitting %d/%d", alreadyDoneNumber, all];
            
            kerr = task_info(mach_task_self(),
                             TASK_BASIC_INFO,
                             (task_info_t)&info,
                             &size);
            if( kerr == KERN_SUCCESS ) {
                mem = [NSString stringWithFormat:@"mem usage(MB):%0.3f, INC by:%0.2f",
                       (float)info.resident_size/(1024*1024),
                       (float)(info.resident_size-baseMem)*100/baseMem];
            }
            NSMutableDictionary* ps = [[NSMutableDictionary alloc] init];
            NSArray* tempA = [[[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%0.1f", (float)alreadyDoneNumber/all],
                               doing,
                               mem,
                               nil] autorelease];
            [ps setObject:tempA
                   forKey:@"monitorParams"];
            block(ps);
            
            [ps release];
        }
    }
    
    kerr = task_info(mach_task_self(),
                     TASK_BASIC_INFO,
                     (task_info_t)&info,
                     &size);
    if( kerr == KERN_SUCCESS ) {
        QALog(@"total memory usage(MB) : %0.3f, increased by : %0.2f",
              (float)info.resident_size/(1024*1024),
              (float)(info.resident_size-baseMem)*100/baseMem);
    }
}

@end


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
                //--------
                [[QAAutoFramework sharedInstance] filterCases:SelectAll];
                //--------
            }else if ([title isEqualToString:@"Failed"]) {
                //--------
                [[QAAutoFramework sharedInstance] filterCases:SelectFailed];
                //--------
            }else if ([title isEqualToString:@"Un All"]) {
                //--------
                [[QAAutoFramework sharedInstance] filterCases:SelectNone];
                //--------
            }
            [(CaseTableDelegate*)[tableView dataSource] shuffleDisplayTableItems:[[QAAutoFramework sharedInstance] currentTestCases]];
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
    // ------------
    [[QAAutoFramework sharedInstance] buildCases:[suiteIdText text] == nil?@"178":[suiteIdText text]];
    // ------------
    
    [[QAAutoFramework sharedInstance] filterCases:SelectAll];
        
    [(CaseTableDelegate*)[tableView dataSource] initTableItems:[[QAAutoFramework sharedInstance] currentTestCases]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshCases" object:nil];
    
    [self performSelectorOnMainThread:@selector(dismissAllProgressDisplay)
                           withObject:nil
                        waitUntilDone:YES];
}

- (void) runCasesInAnotherThread{
    NSMutableArray* tmp = [[NSMutableArray alloc] init];
    for (TestCaseWrapper* wrapper in [(CaseTableDelegate*)[tableView dataSource] displayTableItems]) {
        if ([wrapper isSelected]) {
            TestCase* tc = [wrapper tc];
            [tmp addObject:tc];
        }
    }
    // ------------
    [[QAAutoFramework sharedInstance] runCases:tmp
                                 withTcmSubmit:[runIdText text] == nil?@"416":[runIdText text]
                         withNotificationBlock:^(NSDictionary *params) {
                             [self performSelectorOnMainThread:@selector(updateProgressViewWithRunning:)
                                                    withObject:[params objectForKey:@"monitorParams"]
                                                 waitUntilDone:YES];
                         }];
    // ------------
    [(CaseTableDelegate*)[tableView dataSource] shuffleDisplayTableItems:[[QAAutoFramework sharedInstance] currentTestCases]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshCases" object:nil];
    
    [self performSelectorOnMainThread:@selector(dismissAllProgressDisplay)
                           withObject:nil
                        waitUntilDone:YES];
    
    [tmp release];
//    exit(0);
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
            break;
        case dismissViewControl:
            [self performSelectorOnMainThread:@selector(dismissActiveGreeViewControllerAnimated:) 
                                   withObject:[NSNumber numberWithBool:YES] 
                                waitUntilDone:YES];
            [StepDefinition globalNotify];
            break;
        case executeJavascriptInPopup:
            [self performSelectorOnMainThread:@selector(executeJsInPopup:) 
                                   withObject:extra 
                                waitUntilDone:YES];
            [StepDefinition globalNotify];
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
                                waitUntilDone:NO];
            
//            [StepDefinition globalNotify];
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
            [StepDefinition globalNotify];
            break;
            
        case screenShotWidget:
            [self performSelectorOnMainThread:@selector(screenshot:) 
                                   withObject:extra
                                waitUntilDone:YES];
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
            fullCommand = [self wrapJsCommand:[NSString stringWithFormat:@"%@(%@)", cmd, element]];
        }else{
            fullCommand = [self wrapJsCommand:[NSString stringWithFormat:@"%@(%@, %@)", cmd, element, value]];
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

- (void) screenshot:(NSDictionary*) info{
    GreeWidget* widget = [info objectForKey:@"widget"];
    UIImage *image = [self screenshotImageForWidget:widget];
    void (^callbackBlock)(UIImage*) = [info objectForKey:@"cmdCallback"];
    callbackBlock(image);
}

#pragma mark - GreeWidgetDataSource
- (UIImage*)screenshotImageForWidget:(GreeWidget*)widget
{
    UIView* viewForScreenShot = self.view;
    UIGraphicsBeginImageContext(viewForScreenShot.layer.visibleRect.size);
    [viewForScreenShot.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
