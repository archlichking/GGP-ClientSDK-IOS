//
//  StepHolder.m
//  OFQAAPI
//
//  Created by lei zhu on 2/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StepHolder.h"
#import "StringUtil.h"
#import "StepMethod.h"
#import "objc/runtime.h"

@implementation StepHolder

@synthesize stepCages;

static StepHolder* stepHolder = nil;

+ (StepHolder*) instance:(id) c{
    if (stepHolder == nil) {
        stepHolder = [stepHolder init];
    }
    return stepHolder;
}

- (id) init{
    if (self = [super init]) {
        stepCages = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id) addStepObj:(id) c{
    
    NSMutableDictionary* dd = [[[NSMutableDictionary alloc] init] autorelease];
        
    //set class object into dictionary
    [dd setObject:c 
           forKey:@"classObj"];
    
    int unsigned methodCount = 0;  
    
    Method* refMethods = class_copyMethodList([c class], &methodCount);
    
    for (int ie=0; ie<methodCount;ie++) {
        
        SEL s = method_getName(refMethods[ie]);
        NSMethodSignature* mSignature = [[c class] instanceMethodSignatureForSelector:s];
        NSInvocation* mInvocation = [NSInvocation invocationWithMethodSignature:mSignature];
        [mInvocation setSelector:s];
            
        //set invocation obj
        NSRegularExpression* regexp = [StringUtil methodNameToRegexp:NSStringFromSelector(s)];
        [dd setObject:mInvocation
                forKey:regexp];
            
    }
    [[self stepCages] addObject:dd];
    //free(refMethods);
    return self;
}


- (StepMethod*) getMethodByStep:(NSString*) stepString{
    for (NSMutableDictionary* dd in stepCages) {
       
        for (id key in dd) {
            // temporary use, need to be modified
            if ([key isKindOfClass:[NSString class]]) {
                continue;
            }
            NSArray* ns = [key matchesInString:stepString 
                                       options:0 
                                         range:NSMakeRange(0, [stepString length])];
            // should be at least 1 if matched
            if (ns != nil && [ns count]>0) {
                
                StepMethod* sm = [[[StepMethod alloc] init] autorelease];
                [sm setMethodInvo:[dd objectForKey:key]];
                //pull params if any
                NSMutableArray* params = [[[NSMutableArray alloc] init] autorelease];
                // we need to omit first two params, because we also match GIVEN WHEN THEN in param 1
                
                NSLog(@"%@ ------> %@", stepString, key);
                for (int i =2; i<[[ns objectAtIndex:0] numberOfRanges]; i++) {
                    // have to make type conversion here
                    // todo
                    
                    [params addObject:[stepString substringWithRange:[[ns objectAtIndex:0] rangeAtIndex:i]]];
                }
                [sm setParams:params];
                [sm setRefObj:[dd objectForKey:@"classObj"]];
                return sm;
            }
        }
    }
    return nil;
}

//- (void)dealloc{
////    [stepHolder release];
//    [stepCage release];
//    [super dealloc];
//}

@end
