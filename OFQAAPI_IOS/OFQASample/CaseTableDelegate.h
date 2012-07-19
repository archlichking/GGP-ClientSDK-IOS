//
//  CaseTableDelegate.h
//  OFQAAPI
//
//  Created by lei zhu on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CaseTableDelegate : UITableViewController<UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate>{
    
    NSMutableArray* displayTableItems;
    NSArray* fullTableItems;
    
    
    UIImage* unchecked;
    UIImage* checked;
    UIImage* failed_checked;
}

@property (retain) NSMutableArray* displayTableItems;

- (void) initTableItems:(NSArray*) items;

@end
