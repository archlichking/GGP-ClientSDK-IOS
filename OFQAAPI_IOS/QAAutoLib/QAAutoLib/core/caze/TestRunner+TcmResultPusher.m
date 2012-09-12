//
//  TestRunner+TcmResultPusher.m
//  OFQAAPI
//
//  Created by lei zhu on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestRunner+TcmResultPusher.h"
#import "TestCase.h"
#import "QALog.h"

@implementation TestRunner (TcmResultPusher)

- (void) pushCaseResultTo:(NSArray*) testCases 
                    runId:(NSString*) runId{
    
    for (int i=0; i<[testCases count]; i++) {
        TestCase* tc = [testCases objectAtIndex:i];
        QALog(@"%@ ==================", [tc caseId]);
    }
}

@end
