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
extern int const CaseResultBlocked;
extern int const CaseResultPassed;
extern int const CaseResultUntested;

@interface Constant : NSObject

+ (NSString*) getReadableResult:(int) res;

@end
