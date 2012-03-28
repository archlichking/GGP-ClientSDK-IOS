//
//  TcmCaseBuilder.h
//  OFQAAPI
//
//  Created by lei zhu on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "CaseBuilder.h"
@class TcmCommunicator;
@class SBJsonParser;
@class TestCase;
@class StepParser;

@interface TcmCaseBuilder : NSObject <CaseBuilder>{
    @private
    TcmCommunicator* tcmComm;
    SBJsonParser* jsonParser;
    StepParser* stepParser;
}

@property (retain) TcmCommunicator* tcmComm;
@property (retain) SBJsonParser* jsonParser;
@property (retain) StepParser* stepParser;

- (id)initWithRawValue:(NSData*)rawCaze 
                holder:(StepHolder*) holder;
- (TestCase*) buildCaseBySuiteId:(NSString*) suiteId 
                          caseId:(NSString*) caseId;
- (NSArray*) buildCasesBySuiteId:(NSString*) suiteId;
@end
