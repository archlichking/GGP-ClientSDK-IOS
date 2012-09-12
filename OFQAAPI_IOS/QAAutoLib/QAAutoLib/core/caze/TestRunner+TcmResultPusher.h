//
//  TestRunner+TcmResultPusher.h
//  OFQAAPI
//
//  Created by lei zhu on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestRunner.h"

@interface TestRunner (TcmResultPusher)
- (void) pushCaseResultTo:(NSArray*) testCases 
                    runId:(NSString*) runId;
@end
