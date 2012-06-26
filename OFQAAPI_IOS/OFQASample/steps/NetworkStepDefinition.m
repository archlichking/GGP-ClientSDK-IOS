//
//  NetworkStepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NetworkStepDefinition.h"
#import "GreeNetworkReachability.h"

#import "QAAssert.h"
#import "StringUtil.h"

@implementation NetworkStepDefinition

+ (NSString*) boolToString:(BOOL) boo{
    if(boo){
        return @"YES";
    }else
        return @"NO";
}

- (void) I_test_network_access_to_host_PARAM:(NSString*) host{
    GreeNetworkReachability* accessTest = [[GreeNetworkReachability alloc] initWithHost:host];
    Boolean b = [accessTest isConnectedToInternet];
    [[self getBlockRepo] setObject:[NetworkStepDefinition boolToString:b] 
                            forKey:@"networkResult"];
}

- (NSString*) access_should_be_PARAM:(NSString*) status{
    NSString* b  = [[self getBlockRepo] objectForKey:@"networkResult"];
    NSString* result = @"";
    [QAAssert assertEqualsExpected:status 
                            Actual:b];
    result = [result stringByAppendingFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@", 
              @"network reachability", 
              status, 
              b, 
              SpliterTcmLine];
    return result;
}

@end
