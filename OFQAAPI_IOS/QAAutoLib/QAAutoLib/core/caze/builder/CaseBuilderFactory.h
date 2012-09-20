//
//  CaseBuilderFactory.h
//  OFQAAPI
//
//  Created by lei zhu on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class StepHolder;

extern const int TCM_BUILDER;
extern const int FILE_BUILDER;

@interface CaseBuilderFactory : NSObject

+ (id) makeBuilderByType:(int)type 
                     raw:(NSData*)rawValue 
              stepHolder:(StepHolder*) holder;
@end
