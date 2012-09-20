//
//  CaseBuilderFactory.m
//  OFQAAPI
//
//  Created by lei zhu on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CaseBuilderFactory.h"
#import "CaseBuilder.h"
#import "FileCaseBuilder.h"
#import "TcmCaseBuilder.h"
#import "StepHolder.h"

const int TCM_BUILDER = 0;
const int FILE_BUILDER = 1;

@implementation CaseBuilderFactory

+ (id) makeBuilderByType:(int)type 
                     raw:(NSData*)rawValue  
              stepHolder:(StepHolder*) holder{
    switch (type) {
        case TCM_BUILDER:
            return [[[TcmCaseBuilder alloc] initWithRawValue:rawValue holder:holder] autorelease];
            break;
        case FILE_BUILDER:
            return [[[FileCaseBuilder alloc] initWithRawValue:rawValue holder:holder] autorelease];
        default:
            break;
    }
    return self;
}

@end
