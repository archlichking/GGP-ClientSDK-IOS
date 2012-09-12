//
//  StepParser.h
//  OFQAAPI
//
//  Created by lei zhu on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Step;
@class StepHolder;

@interface StepParser : NSObject{
    @private
    StepHolder* holder;
    
}

@property (retain) StepHolder* holder;

- (id)initWithHolder:(StepHolder*) h;

- (NSArray*) parseSteps:(NSArray*) rawSteps;

@end