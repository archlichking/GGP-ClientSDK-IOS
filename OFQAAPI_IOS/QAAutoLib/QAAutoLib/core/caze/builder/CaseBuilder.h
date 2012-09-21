//
//  CaseBuilder.h
//  QAAutoLib
//
//  Created by zhu lei on 9/20/12.
//  Copyright (c) 2012 OFQA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TestCase;
@class StepHolder;

@protocol CaseBuilder <NSObject>

- (id)initWithRawValue:(NSData*)rawCaze holder:(StepHolder*) holder;
- (TestCase*) buildCaseBySuiteId:(NSString*) suiteId caseId:(NSString*) caseId;
- (NSArray*) buildCasesBySuiteId:(NSString*) suiteId;
@end
