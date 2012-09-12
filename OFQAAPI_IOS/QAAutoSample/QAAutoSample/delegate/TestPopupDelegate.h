//
//  TestPopupDelegate.h
//  OFQAAPI
//
//  Created by lei zhu on 7/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PopupDelegate <NSObject>

@required - (void) dispatchCommand:(NSString*) command 
                      withExecutor:(id) popupExecutor 
                         extraInfo:(NSDictionary*) infoDic;

@end

@interface TestPopupDelegate : NSObject <PopupDelegate>


@end
