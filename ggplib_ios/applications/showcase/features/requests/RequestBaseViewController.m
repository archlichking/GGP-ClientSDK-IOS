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

#import "RequestBaseViewController.h"
#import "RequestViewController.h"
#import "RequestGiftController.h"
#import "UIColor+ShowCaseAdditions.h"

@interface RequestBaseViewController ()

@end

@implementation RequestBaseViewController
@synthesize buttonTableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
      // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = NSLocalizedStringWithDefaultValue(@"RequestBaseController.title.label", @"GreeShowCase", [NSBundle mainBundle], @"Requests", @"Requests base controller title");
}

- (void)viewDidUnload
{
  [self setButtonTableView:nil];
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}


#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 44.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{ 
  switch (indexPath.row) {
    case 0: 
    {
      UIViewController* controller = [[[RequestGiftController alloc] initWithNibName:nil bundle:nil] autorelease];
      [self.navigationController pushViewController:controller animated:YES];
    }
      break;
    case 1:
    {
      UIViewController* controller = [[[RequestViewController alloc] initWithNibName:nil bundle:nil] autorelease];
      [self.navigationController pushViewController:controller animated:YES];
    }
      break;      
    default:
      NSAssert(NO, @"Undefined button index pressed");
      break;
  }
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"] autorelease];
  }
  cell.textLabel.textColor = [UIColor showcaseDarkGrayColor];
  cell.backgroundColor = [UIColor whiteColor];
  NSString* titles[2] = {
    NSLocalizedStringWithDefaultValue(@"RequestBaseController.button0.label", @"GreeShowCase", [NSBundle mainBundle], @"Send Gifts", nil),
    NSLocalizedStringWithDefaultValue(@"RequestBaseController.button1.label", @"GreeShowCase", [NSBundle mainBundle], @"Custom Request", nil),
  };
  cell.textLabel.text = titles[indexPath.row];
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  return cell;
}



@end
