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

#import "RequestGiftController.h"
#import "GreePopup.h"
#import "UIViewController+GreePlatform.h"
#import "UIColor+ShowCaseAdditions.h"

NSString* const RequestGiftTypeIceCream = @"IceCream";
NSString* const RequestGiftTypeCake = @"Cake";
NSString* const RequestGiftTypeCoal = @"Coal";
NSString* const RequestGiftTypeKey = @"RequestGiftTypeKey";


@interface RequestGiftController ()
- (void)addGiftWithTitle:(NSString*)title description:(NSString*)description type:(NSString*)giftType;
@property (nonatomic, retain) NSMutableArray* giftList;
@end

@implementation RequestGiftController

#pragma mark - Object Lifecycle
@synthesize giftList = _giftList;
@synthesize giftTableView = _giftTableView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _giftList = [[NSMutableArray alloc] init];
    // Custom initialization
  }
  return self;
}

- (void)dealloc {
  [_giftTableView release];
  [_giftList release];
  [super dealloc];
}

#pragma mark - UIViewController
- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = NSLocalizedStringWithDefaultValue(@"RequestGiftController.title.label", @"GreeShowCase", [NSBundle mainBundle], @"Send Gifts", @"Gift controller title");
  
  //here we add the gifts themselves, the braces are to make reorganization easier
  {
    NSString* title = NSLocalizedStringWithDefaultValue(@"RequestGift.gift.icecream.title", @"GreeShowCase", [NSBundle mainBundle], @"Vanilla Ice Cream", nil);
    NSString* description = NSLocalizedStringWithDefaultValue(@"RequestGift.gift.icecream.description", @"GreeShowCase", [NSBundle mainBundle], 
                                                            @"A tasty swirl of vanilla ice cream in a waffle cone, topped with all kinds of goodies.", nil);
    [self addGiftWithTitle:title description:description type:RequestGiftTypeIceCream];
  }  
  {
    NSString* title = NSLocalizedStringWithDefaultValue(@"RequestGift.gift.coal.title", @"GreeShowCase", [NSBundle mainBundle], @"Lump of coal", nil);
    NSString* description = NSLocalizedStringWithDefaultValue(@"RequestGift.gift.coal.description", @"GreeShowCase", [NSBundle mainBundle], 
                                                            @"Oh oh, somebody doesn't like you very much.", nil);
    [self addGiftWithTitle:title description:description type:RequestGiftTypeCoal];
  }  
  {
    NSString* title = NSLocalizedStringWithDefaultValue(@"RequestGift.gift.cake.title", @"GreeShowCase", [NSBundle mainBundle], @"Strawberry Cake", nil);
    NSString* description = NSLocalizedStringWithDefaultValue(@"RequestGift.gift.cake.description", @"GreeShowCase", [NSBundle mainBundle], 
                                                            @"A delicious treat!", nil);
    [self addGiftWithTitle:title description:description type:RequestGiftTypeCake];
  }  
}

- (void)viewDidUnload
{
  [self setGiftTableView:nil];
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
  NSDictionary* info = [self.giftList objectAtIndex:indexPath.row];
  //send the appropriate gift
  GreeRequestServicePopup* requestPopup = [GreeRequestServicePopup popup];
  requestPopup.parameters = [info objectForKey:@"request"];
  [self.navigationController showGreePopup:requestPopup];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.giftList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"] autorelease];
  }
  cell.textLabel.textColor = [UIColor showcaseDarkGrayColor];
  cell.backgroundColor = [UIColor whiteColor];
  NSDictionary* info = [self.giftList objectAtIndex:indexPath.row];
  cell.textLabel.text = [info objectForKey:@"title"];
  cell.imageView.image = [info objectForKey:@"image"];
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  return cell;
}



#pragma mark - Internal Methods
- (void)addGiftWithTitle:(NSString*)title description:(NSString*)description type:(NSString*)giftType
{
  NSDictionary* requestParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                 title, GreeRequestServicePopupTitle,
                                 description, GreeRequestServicePopupBody,
                                 GreeRequestServicePopupListTypeAll, GreeRequestServicePopupListType,
                                 giftType, RequestGiftTypeKey,
                                 nil];
  NSDictionary* cellInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                            requestParams, @"request",
                            title, @"title",
                            //image to come later...
                            nil];
  [self.giftList addObject:cellInfo];
}
@end
