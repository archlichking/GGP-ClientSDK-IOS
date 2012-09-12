//
//  CaseTableDelegate.m
//  OFQAAPI
//
//  Created by lei zhu on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CaseTableDelegate.h"
#import "TestCase.h"
#import "TestCaseWrapper.h"
#import "Constant.h"

#import "AppDelegate.h"

@implementation CaseTableDelegate

@synthesize displayTableItems;

- (id)init{
    if (self=[super init])
    {
        displayTableItems = [[NSMutableArray alloc] init];
        fullTableItems = [[NSArray alloc] init];
        NSString* imageName = [[NSBundle mainBundle] pathForResource:@"unchecked" ofType:@"png"];
        unchecked = [[UIImage alloc] initWithContentsOfFile:imageName];
        imageName = [[NSBundle mainBundle] pathForResource:@"checked" ofType:@"png"];
        checked = [[UIImage alloc] initWithContentsOfFile:imageName];
        imageName = [[NSBundle mainBundle] pathForResource:@"failed_checked" ofType:@"png"];
        failed_checked = [[UIImage alloc] initWithContentsOfFile:imageName];
    }
    return self;

}

- (void) initTableItems:(NSArray*) items{
    displayTableItems = [[NSMutableArray alloc] initWithArray:items];
    fullTableItems = [[NSArray alloc] initWithArray:items];
}

- (UITableViewCell *)tableView:(UITableView *)tView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* cellIdentifier = @"Cell";
    UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:cellIdentifier];
    TestCaseWrapper* tw = [displayTableItems objectAtIndex:indexPath.row];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:cellIdentifier] autorelease];
        // Set up the cell...
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if ([tw isSelected]) {
        if ([[tw tc] result] == CaseResultFailed) {
            cell.imageView.image = failed_checked;
        }else{
            cell.imageView.image = checked;
        }
    }else{
        cell.imageView.image = unchecked;
    }
    
    cell.textLabel.text = [[tw tc] title];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"# %@ %@", [[tw tc] caseId], [tw result]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section {
    return [displayTableItems count];
}

-(NSString *)tableView:(UITableView *)tableView 
titleForHeaderInSection:(NSInteger)section {
	return [[[NSString alloc] initWithFormat:@"Total %i Cases", [displayTableItems count]] autorelease];
}

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"%i", indexPath.row);
    if ([[displayTableItems objectAtIndex:indexPath.row] isSelected]) {
        [tableView cellForRowAtIndexPath:indexPath].imageView.image = unchecked;
        [[displayTableItems objectAtIndex:indexPath.row] setIsSelected:false];
    }else{
        [tableView cellForRowAtIndexPath:indexPath].imageView.image = checked;
        [[displayTableItems objectAtIndex:indexPath.row] setIsSelected:true];
    }
    
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
    return;
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    NSMutableArray* arr = [[[NSMutableArray alloc] init] autorelease];
    if ([searchText length] < 3) {
        // to avoid unnecessary search
        [arr addObjectsFromArray:fullTableItems];
        if ([searchText length] == 0) {
            [theSearchBar resignFirstResponder];
        }
    }
    else{
        for (TestCaseWrapper* tcw in fullTableItems){
            if ([[tcw.tc.title lowercaseString] rangeOfString:[searchText lowercaseString]].length > 0) {
                [arr addObject:tcw];
            }
        }
    }
    [self setDisplayTableItems:arr];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshCases" 
                                                        object:nil 
                                                      userInfo:[[NSDictionary alloc] initWithObjectsAndKeys:@"YES", @"isSearching", nil]];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    // hide search button after search
    [theSearchBar resignFirstResponder];
}

- (void)dealloc{
    [displayTableItems release];
    [fullTableItems release];
    [super dealloc];
}

@end
