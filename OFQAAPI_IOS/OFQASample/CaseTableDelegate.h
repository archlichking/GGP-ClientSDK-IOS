//
//  CaseTableDelegate.h
//  OFQAAPI
//
//  Created by lei zhu on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CaseTableDelegate : UITableViewController<UITableViewDelegate,UITableViewDataSource>{
    
    NSArray* tableItems;
    UIImage* unchecked;
    UIImage* checked;
    UIImage* failed_checked;
}

@property (copy) NSArray* tableItems;

@end
