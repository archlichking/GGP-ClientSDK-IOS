//
//  TestRunner+TcmResultPusher.h
//  OFQAAPI
//
//  Created by lei zhu on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestRunner.h"

@class  TestCase;

@interface TestRunner (TcmResultPusher)

- (void) pushCase:(TestCase*) tc
                    toRunId:(NSString*) runId;

- (void) pushAllCasesToRunId:(NSString*) runId;

@end
