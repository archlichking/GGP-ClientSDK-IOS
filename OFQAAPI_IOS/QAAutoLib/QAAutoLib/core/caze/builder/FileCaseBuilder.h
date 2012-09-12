//
//  FileCaseBuilder.h
//  OFQAAPI
//
//  Created by lei zhu on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CaseBuilder.h"
@class StepParser;

@interface FileCaseBuilder : NSObject <CaseBuilder>{
    @protected
    NSString* caseRaw;
    StepParser* stepParser;
}

@property (copy) NSString* caseRaw;
@property (retain) StepParser* stepParser;

- (id)initWithRawValue:(NSData*)rawCaze 
                holder:(StepHolder*) holder;

- (TestCase*) buildFromDebugFile;

// collection of TestCase
- (TestCase*) buildCaseBySuiteId:(NSString*) suiteId 
                          caseId:(NSString*) caseId;
- (NSArray*) buildCasesBySuiteId:(NSString*) suiteId;
@end
