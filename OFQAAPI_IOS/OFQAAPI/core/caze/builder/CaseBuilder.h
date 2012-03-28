//
//  CaseBuilder.h
//  OFQAAPI
//
//  Created by lei zhu on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TestCase.h"
#import "StepHolder.h"

@protocol CaseBuilder <NSObject>

@required
- (id)initWithRawValue:(NSData*)rawCaze holder:(StepHolder*) holder;
- (TestCase*) buildCaseBySuiteId:(NSString*) suiteId caseId:(NSString*) caseId;
- (NSArray*) buildCasesBySuiteId:(NSString*) suiteId;

@end
