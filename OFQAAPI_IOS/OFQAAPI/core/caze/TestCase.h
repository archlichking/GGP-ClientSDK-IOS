//
//  TestCase.h
//  OFQAAPI
//
//  Created by lei zhu on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Step;

@interface TestCase : NSObject{
    @private
    NSString* caseId;
    NSString* title;
    //steps should be collection of Step obj
    NSArray* steps;
    int result;
    NSString* resultComment;
    bool isExecuted;
}

@property (copy) NSString* caseId;
@property (copy) NSString* title;
@property (retain) NSArray* steps;
@property (assign) int result;
@property (copy) NSString* resultComment;
@property (assign) bool isExecuted;

- (id)initWithId:(NSString*) cId 
           title:(NSString*) cTitle 
           steps:(NSArray*) steps;
- (void) execute;

@end
