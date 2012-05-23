//
//  TestRunnerWrapper.h
//  OFQAAPI
//
//  Created by lei zhu on 3/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class  TestRunner;
@class CaseBuilder;
@class TcmCommunicator;


@interface TestRunnerWrapper : NSObject{
    @private
    TestRunner* runner;
    CaseBuilder* cb;
    NSMutableArray* caseWrappers;
    int type;
}


@property (retain) TestRunner* runner;
@property (retain) CaseBuilder* cb;
@property (retain) NSMutableArray* caseWrappers;
@property int type;

- (id)initWithRawData:(NSData*) rawData builderType:(int) type;

- (void) addCaseWrappers:(NSArray*) testCaseWrappers;

- (NSArray*) getCaseWrappers;

- (void) executeSelectedCasesWithSubmit:(NSString*) runId 
                                  block:(void(^)(NSArray* objs))block;
- (void) emptyCaseWrappers;

- (void) buildRunner:(NSString*) suiteId;

- (void) markCaseWrappers:(int) selectType;

@end
