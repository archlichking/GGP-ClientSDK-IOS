//
//  Constant.h
//  OFQAAPI
//
//  Created by lei zhu on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constant : NSObject

+ (int) FAILED;
+ (int) RETESTED;
+ (int) PASSED;
+ (int) UNTESTED;

+ (NSString*) getReadableResule:(int) res;

@end
