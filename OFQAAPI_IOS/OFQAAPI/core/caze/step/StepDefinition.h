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

@end
