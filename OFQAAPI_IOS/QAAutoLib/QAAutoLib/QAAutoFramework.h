//
//  QAAutoFramework.h
//  QAAutoLib
//
//  Created by zhu lei on 9/19/12.
//  Copyright (c) 2012 OFQA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TestCase;
@class TestRunner;

@interface QAAutoFramework : NSObject{
    @private
    NSArray* originalTestCases;
    TestRunner* runner;
}

+ (QAAutoFramework*) sharedInstance;
+ (QAAutoFramework*) initializeWithSettings:(NSDictionary*) settings;


@end
