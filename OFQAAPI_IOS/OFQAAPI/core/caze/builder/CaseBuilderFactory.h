//
//  CaseBuilderFactory.h
//  OFQAAPI
//
//  Created by lei zhu on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class StepHolder;

@interface CaseBuilderFactory : NSObject

+ (int) TCM_BUILDER;
+ (int) FILE_BUILDER;

+ (id) makeBuilderByType:(int)type 
                     raw:(NSData*)rawValue 
              stepHolder:(StepHolder*) holder;
@end
