//
//  StepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSConditionLock* outsideStepLock; // this is now only allowed in popup steps

@interface StepDefinition : NSObject{
    @protected
    __block NSMutableDictionary* blockRepo;
    
    @private
    NSConditionLock* inStepLock;
    int TIMEOUT;
}

- (NSMutableDictionary*) getBlockRepo;

- (void) waitForInStep;

- (void) notifyInStep;

-(void) setTimeout:(int) timeout;

- (void) notifyMainUIWithCommand:(NSString*) command 
                          object:(id) obj;

+ (void) notifyOutsideStep;
+ (void) waitForOutsideStep;

@end
