//
//  StepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StepDefinition : NSObject{
    @protected
    __block NSMutableDictionary* blockRepo;
}

- (NSMutableDictionary*) getBlockRepo;
- (void) setTimeout:(int) timeout;


- (void) inStepWait;
- (void) inStepNotify;

- (void) notifyMainUIWithCommand:(NSString*) command 
                          object:(id) obj;

+ (void) globalNotify;
+ (void) globalWait;
+ (NSMutableDictionary*) getOutsideBlockRepo;

@end
