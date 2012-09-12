//
//  StringUtil.h
//  OFQAAPI
//
//  Created by lei zhu on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString* const SpliterFileLine;
extern NSString* const SpliterTcmLine;

@interface StringUtil : NSObject

+ (NSArray*) splitStepsFrom:(NSString*) raw by:(NSString*) spliter;
+ (NSArray*) extractStepsFrom:(NSArray*) rawCase;
+ (NSString*) methodNameToCommand:(NSString*) methodName; 
+ (NSRegularExpression*) methodNameToRegexp:(NSString*) methodName;

@end
