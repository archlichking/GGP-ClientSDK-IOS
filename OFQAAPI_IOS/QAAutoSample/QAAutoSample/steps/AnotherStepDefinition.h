//
//  AnotherStepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StepDefinition.h"

@interface AnotherStepDefinition : NSObject <StepDefinition>{
    
}

- (void) Given_I_want_to_do_something;
- (void) Then_10_plus_30_should_be_70;
- (void) Then_complex_10_plus_20_should_be_40;


@end
