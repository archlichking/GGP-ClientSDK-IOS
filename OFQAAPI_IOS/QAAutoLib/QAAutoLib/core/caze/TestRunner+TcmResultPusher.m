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

#import "TcmCommunicator.h"

@implementation TestRunner (TcmResultPusher)

- (void) pushCase:(TestCase*) tc
          toRunId:(NSString*) runId{
    TcmCommunicator* tComm = [TcmCommunicator sharedInstance];
    [tComm pushCase:tc toRun:runId];
}

- (void) pushAllCasesToRunId:(NSString*) runId{
    TcmCommunicator* tComm = [TcmCommunicator sharedInstance];
    
    [tComm pushAllCases:[self cases]
                  toRun:runId];
}

@end
