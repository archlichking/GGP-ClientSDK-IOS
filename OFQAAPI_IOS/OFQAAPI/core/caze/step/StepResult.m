//
//  StepResult.m
//  OFQAAPI
//
//  Created by lei zhu on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StepResult.h"

@implementation StepResult

@synthesize result;
@synthesize comment;

- (id)initWithResult:(int) r 
             comment:(NSString*) c{
    if (self=[super init]){
    
        [self setResult:r];
        [self setComment:c];
    }
    return self;
}

//- (void)dealloc{
//    [comment release];
//    [super dealloc];
//}

@end
