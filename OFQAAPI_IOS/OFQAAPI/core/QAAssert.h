//
//  OFAssert.h
//  OFQAAPI
//
//  Created by lei zhu on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QAAssert : NSObject

+ (void) that:(BOOL) expr;

+ (void) assertEqualsExpected:(id)expected 
                       Actual:(id)result;

@end
