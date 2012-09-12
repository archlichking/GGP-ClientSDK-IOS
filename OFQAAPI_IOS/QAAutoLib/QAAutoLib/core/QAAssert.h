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

+ (void) assertNotEqualsExpected:(id)expected 
                       Actual:(id)result;

+ (void) assertNotEqualsExpected:(id)expected 
                       Actual:(id)result 
                  WithMessage:(NSString*) message;

+ (void) assertContainsExpected:(id)expected 
                        Contains:(id)result;

+ (void) assertContainsExpected:(id)expected 
                       Contains:(id)result
                    WithMessage:(NSString*) message;


+ (void) assertNotNil:(id)result;

+ (void) assertNotNil:(id)result 
          WithMessage:(NSString*) message;

+ (void) assertNil:(id)result;

+ (void) assertNil:(id)result 
          WithMessage:(NSString*) message;
@end
