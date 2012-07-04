//
//  Constant.h
//  OFQAAPI
//
//  Created by lei zhu on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern int const CaseResultFailed;
extern int const CaseResultRetested;
extern int const CaseResultPassed;
extern int const CaseResultUntested;

extern NSString* const CommandNotifyLoadPopup;
extern NSString* const CommandNotifyDismissPopup;
extern NSString* const CommandNotifyExecuteCommandInPopup;


extern NSString* const CommandJSPopupCommand;


@interface Constant : NSObject

+ (NSString*) getReadableResult:(int) res;

@end
