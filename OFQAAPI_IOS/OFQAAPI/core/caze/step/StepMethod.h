//
//  StepMethod.h
//  OFQAAPI
//
//  Created by lei zhu on 3/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StepMethod : NSObject{
    @private
    NSArray* params;
    NSInvocation* methodInvo;
}

@property (retain) NSArray* params;
@property (retain) NSInvocation* methodInvo;

@end
