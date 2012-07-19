  //
// Copyright 2012 GREE, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <UIKit/UITableViewCell.h>

#import "PurchaseViewController.h"
#import "PurchaseCell.h"
#import "ActivityView.h"
#import "GreeWalletProduct.h"

static NSString* const purchaseCellReuseID = @"PurchaseCell";

@interface PurchaseViewController ()
@property (retain, nonatomic) IBOutlet UITableView *productTable;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *productActivity;
@property (retain, nonatomic) IBOutlet UILabel *balanceAmount;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *balanceActivity;
@property (retain, nonatomic) NSArray *data;
@property (retain, nonatomic) UINib *purchaseCellNib;

- (void)updateBalance;
- (void)updateProducts;
@end

@implementation PurchaseViewController
@synthesize data;
@synthesize productTable;
@synthesize productActivity;
@synthesize balanceAmount;
@synthesize balanceActivity;
@synthesize purchaseCellNib;

#pragma mark - Object Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    purchaseCellNib = [[UINib nibWithNibName:purchaseCellReuseID bundle:nil] retain];
  }
  return self;
}

- (void)dealloc
{
  [balanceAmount release];
  [balanceActivity release];
  [productTable release];
  [productActivity release];
  [purchaseCellNib release];
  [super dealloc];
}

#pragma mark - Public Interface

#pragma mark - UIViewController Overrides

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = NSLocalizedStringWithDefaultValue(@"PurchaseController.title.label", @"GreeShowCase", [NSBundle mainBundle], @"Purchase", @"Purchase controller title");
}

- (void)viewDidUnload
{
  [self setBalanceAmount:nil];
  [self setBalanceActivity:nil];
  [self setProductTable:nil];
  [self setProductActivity:nil];
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

- (void)viewDidAppear:(BOOL)animated
{
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProducts) name:@"GreeWalletUpdated" object:nil];
  [self updateBalance];
  if (!self.data)
    [self updateProducts];
}

- (void)viewWillDisappear:(BOOL)animated
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}


- (NSString*)description
{
  return [NSString stringWithFormat:@"<%@:%p>", NSStringFromClass([self class]), self];
}

#pragma mark - UITableView Delegate Methods

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
  PurchaseCell *cell = (PurchaseCell*)[aTableView cellForRowAtIndexPath:indexPath];
  [self.productTable deselectRowAtIndexPath:indexPath animated:YES];
  __block ActivityView *activityView = [[ActivityView activityViewWithContainer:self.view] retain];
  [activityView startLoading];
  
  id klass = NSClassFromString(@"GreeWallet");
  void (^block)(GreeWalletProduct *product, NSError *error) = ^(GreeWalletProduct *product, NSError *error) {
    if (nil == error ) {
      [self updateBalance];
      NSString *formatString = NSLocalizedStringWithDefaultValue(@"PurchaseViewController.alertView.purchaseSuccessFormat.text", @"GreeShowCase", [NSBundle mainBundle], @"You have successfully bought\n\"%@\"", @"Message for a successful purchase. Replacement parameter is the title of the purchased item");
      NSString *formattedMessage = [NSString stringWithFormat:formatString, product.productTitle];
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedStringWithDefaultValue(@"PurchaseViewController.purchaseGoodAlertView.button.text", @"GreeShowCase", [NSBundle mainBundle], @"Purchase Succeeded", @"PurchaseViewController alert view purchase good title")
                                                      message:formattedMessage
                                                     delegate:nil
                                            cancelButtonTitle:NSLocalizedStringWithDefaultValue(@"PurchaseViewController.alertView.button.text", @"GreeShowCase", [NSBundle mainBundle], @"Ok", @"PurchaseViewController alert view ok button")
                                            otherButtonTitles:nil, nil];
      [alert show];
      [alert release];
    } else {
      UIAlertView *alert = [[UIAlertView alloc]
                            initWithTitle:NSLocalizedStringWithDefaultValue(@"PurchaseViewController.purchaseFailAlertView.button.text", @"GreeShowCase", [NSBundle mainBundle], @"Purchase Error", @"PurchaseViewController alert view purchase error title")
                            message:error.localizedDescription
                            delegate:nil
                            cancelButtonTitle:NSLocalizedStringWithDefaultValue(@"PurchaseViewController.alertView.button.text", @"GreeShowCase", [NSBundle mainBundle], @"Ok", @"PurchaseViewController alert view ok button")
                            otherButtonTitles:nil, nil];
      [alert show];
      [alert release];
    }
    [activityView stopLoading];
    [activityView release];
  };
  [klass performSelector:@selector(purchaseProduct:withBlock:) withObject:cell.productId withObject:[block copy]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 85.0f;
}

#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (!self.data) {
    return 0;
  }
  return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  PurchaseCell *cell = nil;
  GreeWalletProduct *productData = (GreeWalletProduct*)[self.data objectAtIndex:indexPath.row];
  if (productData) {
    cell = [tableView dequeueReusableCellWithIdentifier:purchaseCellReuseID];
    if (!cell) {      
      NSArray *topLevelObjects = [self.purchaseCellNib instantiateWithOwner:nil options:nil];
      for (id object in topLevelObjects) {
        if ([object isKindOfClass:[PurchaseCell class]]) {
          cell = object;
          break;
        } else {
          NSAssert(nil, @"WalletCell not found!");
        }
      }
    }
    
    if (cell) {
      [cell updateFromGreeWalletProduct:productData];
    }
  }
  return cell;
}

#pragma mark - Internal Methods

- (void)updateBalance {
  [self.balanceAmount setText:@""];
  [self.balanceActivity startAnimating];

  id klass = NSClassFromString(@"GreeWallet");
  void (^block)(unsigned long long result, NSError *error) = ^(unsigned long long result, NSError *error) {
    if (nil == error)
      [self.balanceAmount setText:[NSString stringWithFormat:@"%d", result]];
    else
      [self.balanceAmount setText:NSLocalizedStringWithDefaultValue(@"PurchaseViewController.updateBalance.error.text", @"GreeShowCase", [NSBundle mainBundle], @"NA", @"For english NA; the abbreviation of Not Available")];
    [self.balanceActivity stopAnimating];
  };
  [klass performSelector:@selector(loadBalanceWithBlock:) withObject:[block copy]];
}

- (void)updateProducts
{
  self.data = nil;
  int numberOfRows = [self.productTable numberOfRowsInSection:0];
  if (numberOfRows) {
    NSMutableArray *rowsToDelete = [NSMutableArray arrayWithCapacity:numberOfRows];
    while (numberOfRows > 0) {
      [rowsToDelete addObject:[NSIndexPath indexPathForRow:--numberOfRows inSection:0]];
    }
    [self.productTable beginUpdates];
    [self.productTable deleteRowsAtIndexPaths:rowsToDelete withRowAnimation:(UITableViewRowAnimationFade)];
    [self.productTable endUpdates];
  }
  [self.productActivity startAnimating];

  id klass = NSClassFromString(@"GreeWallet");
  void (^block)(NSArray *products, NSError *error) = ^(NSArray *products, NSError *error) {
    self.data = products;
    int rows = [self.data count];
    NSMutableArray *indicies = [NSMutableArray arrayWithCapacity:[self.data count]];
    for (int i = 0; i < rows; i++) {
      [indicies addObject:[NSIndexPath indexPathForRow:i inSection:0]];
    }
    [self.productTable beginUpdates];
    [self.productTable insertRowsAtIndexPaths:indicies withRowAnimation:UITableViewRowAnimationFade];
    [self.productTable endUpdates];
    if (self.data)
      [self.productActivity stopAnimating];
  };
  [klass performSelector:@selector(loadProductsWithBlock:) withObject:[block copy]];
}

@end
