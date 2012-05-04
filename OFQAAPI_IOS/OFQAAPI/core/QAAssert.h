//
//  OFAssert.h
//  OFQAAPI
//
//  Created by lei zhu on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QAAssert : NSObject

+ (void) assertEqualsExpected:(id)expected 
                       Actual:(id)result;

+ (void) assertEqualsExpected:(id)expected 
                       Actual:(id)result 
                      WithMessage:(NSString*) message;

@end
