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


const int BuilderTCM = 0;
const int BuilderFile = 1;

@implementation CaseBuilderFactory

+ (id) makeBuilderByType:(int)type 
                     raw:(NSData*)rawValue  
              stepHolder:(StepHolder*) holder{
    switch (type) {
        case BuilderTCM:
            return [[TcmCaseBuilder alloc] initWithRawValue:rawValue holder:holder];
            break;
        case BuilderFile:
            return [[FileCaseBuilder alloc] initWithRawValue:rawValue holder:holder];
        default:
            break;
    }
    return self;
}

@end
