//
//  StringUtil.h
//  OFQAAPI
//
//  Created by lei zhu on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface StringUtil : NSObject

+ (NSString*) FILE_LINE_SPLITER;
+ (NSString*) TCM_LINE_SPLITER;

+ (NSArray*) splitStepsFrom:(NSString*) raw by:(NSString*) spliter;
+ (NSArray*) extractStepsFrom:(NSArray*) rawCase;
+ (NSString*) methodNameToCommand:(NSString*) methodName; 
+ (NSRegularExpression*) methodNameToRegexp:(NSString*) methodName;

@end
