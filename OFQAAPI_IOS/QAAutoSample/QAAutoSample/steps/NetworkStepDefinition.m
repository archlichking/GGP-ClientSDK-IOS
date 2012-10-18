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


+ (NSString*) methodToString:(int) method{
    switch (method) {
        case GreeNetworkReachabilityConnectedViaWiFi:
            return @"WIFI";
        case GreeNetworkReachabilityConnectedViaCarrier:
            return @"CELL";
        default:
            return @"NONE";
    }
}

- (void) I_test_network_access_to_host_PARAM:(NSString*) host{
    GreeNetworkReachability* accessTest = [[GreeNetworkReachability alloc] initWithHost:host];
    [[self getBlockRepo] setObject:[NetworkStepDefinition boolToString:NO] 
                            forKey:@"networkResult"];
    [[self getBlockRepo] setObject:[NetworkStepDefinition methodToString:GreeNetworkReachabilityNotConnected] 
                            forKey:@"networkMethod"];
    if (accessTest == nil) {
        // host name is not valid
        
    }else{
        // valid host name
        [accessTest addObserverBlock:^(GreeNetworkReachabilityStatus previous, GreeNetworkReachabilityStatus current) {
            [[self getBlockRepo] setObject:[NetworkStepDefinition boolToString:[accessTest isConnectedToInternet]]
                                    forKey:@"networkResult"];
            [[self getBlockRepo] setObject:[NetworkStepDefinition methodToString:current] 
                                    forKey:@"networkMethod"];
            [self inStepNotify];
        }];
        [self inStepWait];
        // time out here indicates given host is not reachable
        
    }
    
    [accessTest release];
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

- (NSString*) connection_method_should_be_PARAM:(NSString*) method{
    NSString* m  = [[self getBlockRepo] objectForKey:@"networkMethod"];
    NSString* result = @"";
    [QAAssert assertEqualsExpected:method 
                            Actual:m];
    result = [result stringByAppendingFormat:@"[%@] checked, expected (%@) ==> actual (%@) %@", 
              @"network connection method", 
              method, 
              m, 
              SpliterTcmLine];
    return result;
}

@end
