//
//  NetworkStepDefinition.h
//  OFQAAPI
//
//  Created by lei zhu on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StepDefinition.h"

@interface NetworkStepDefinition : StepDefinition

- (void) I_test_network_access_to_host_PARAM:(NSString*) host;

- (NSString*) access_should_be_PARAM:(NSString*) status;

@end
