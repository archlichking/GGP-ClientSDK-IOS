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

@synthesize stepCage;

static StepHolder* stepHolder = nil;

+ (StepHolder*) instance:(id) c{
    if (stepHolder == nil) {
        stepHolder = [stepHolder initWithStepObj:c];
    }
    return stepHolder;
}

- (id) initWithStepObj:(id) c{
    if (self=[super init])
    {
        NSMutableDictionary* dd = [[NSMutableDictionary alloc] init];
        
        [self setStepCage:dd];
        //set class object into dictionary
        [[self stepCage] setObject:c 
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
            [[self stepCage] setObject:mInvocation
                         forKey:regexp];
            
        }
        [dd release];
    }
    //free(refMethods);
    return self;
}

- (id) getClassObject{
    return [stepCage objectForKey:@"classObj"];
}

- (StepMethod*) getMethodByStep:(NSString*) stepString{
    for (id key in stepCage) {
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
            [sm setMethodInvo:[stepCage objectForKey:key]];
            //pull params if any
            NSMutableArray* params = [[[NSMutableArray alloc] init] autorelease];
            for (int i =1; i<[[ns objectAtIndex:0] numberOfRanges]; i++) {
                [params addObject:[stepString substringWithRange:[[ns objectAtIndex:0] rangeAtIndex:i]]];
            }
            [sm setParams:params];
            return sm;
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
