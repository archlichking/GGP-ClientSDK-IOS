//
//  HttpCommunicator.m
//  QAAutoLib
//
//  Created by zhu lei on 9/19/12.
//  Copyright (c) 2012 OFQA. All rights reserved.
//

#import "HttpCommunicator.h"

#import "QALog.h"

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@implementation HttpCommunicator

- (id) doHttpPost:(NSString*)url
           params:(NSDictionary*)params{
    NSURL* rUrl = [NSURL URLWithString:url];
    
    NSData* result = nil;
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:rUrl];
    for (NSString* key in [params allKeys]) {
        [request setPostValue:[params objectForKey:key] forKey:key];
    }
    [request setValidatesSecureCertificate:NO];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        result = [request responseData];
    }else{
        QALog(@"[NETWORK ERROR] %@", [error description]);
    }
    
    return result;
}

- (id) doHttpGet:(NSString*)url
          params:(NSDictionary*)params{
    
    NSData* result = nil;
    
    // composite params for get
    if (params) {
        url = [url stringByAppendingString:@"?"];
        for (NSString* key in [params allKeys]) {
            url = [url stringByAppendingString:[NSString stringWithFormat:@"%@=%@", key, [params objectForKey:key]]];
        }
    }
    
    NSURL* rUrl = [NSURL URLWithString:url];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:rUrl];
    [request setValidatesSecureCertificate:NO];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        result = [request responseData];
    }else{
        QALog(@"[NETWORK ERROR] %@", [error description]);
    }
    return result;
}


@end
