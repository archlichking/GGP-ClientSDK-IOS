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

@implementation CaseTableDelegate

@synthesize tableItems;

- (id)init{
    if (self=[super init])
    {
        tableItems = [[NSArray alloc] init];
        NSString* imageName = [[NSBundle mainBundle] pathForResource:@"unchecked" ofType:@"png"];
        unchecked = [[UIImage alloc] initWithContentsOfFile:imageName];
        imageName = [[NSBundle mainBundle] pathForResource:@"checked" ofType:@"png"];
        checked = [[UIImage alloc] initWithContentsOfFile:imageName];
        imageName = [[NSBundle mainBundle] pathForResource:@"failed_checked" ofType:@"png"];
        failed_checked = [[UIImage alloc] initWithContentsOfFile:imageName];
    }
    return self;

}

- (UITableViewCell *)tableView:(UITableView *)tView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString* cellIdentifier = @"Cell";
    UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:cellIdentifier];
    TestCaseWrapper* tw = [tableItems objectAtIndex:indexPath.row];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                       reuseIdentifier:cellIdentifier] autorelease];
        // Set up the cell...
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if ([tw isSelected]) {
        if ([[tw tc] result] == [Constant FAILED]) {
            cell.imageView.image = failed_checked;
        }else{
            cell.imageView.image = checked;
        }
    }else{
        cell.imageView.image = unchecked;
    }
    
    cell.textLabel.text = [[tw tc] title];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"# %@ %@", [[tw tc] caseId], [tw result]];
    NSLog(@"%@", [[tw tc] caseId]);
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section {
    return [tableItems count];
}

-(NSString *)tableView:(UITableView *)tableView 
titleForHeaderInSection:(NSInteger)section {
	return [[[NSString alloc] initWithFormat:@"Total %i Cases", [tableItems count]] autorelease];
}

- (void)tableView:(UITableView *)tableView 
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"%i", indexPath.row);
    if ([[tableItems objectAtIndex:indexPath.row] isSelected]) {
        [tableView cellForRowAtIndexPath:indexPath].imageView.image = unchecked;
        [[tableItems objectAtIndex:indexPath.row] setIsSelected:false];
    }else{
        [tableView cellForRowAtIndexPath:indexPath].imageView.image = checked;
        [[tableItems objectAtIndex:indexPath.row] setIsSelected:true];
    }
    
}

- (void)dealloc{
    [tableItems release];
    [super dealloc];
}

@end
