//
//  TcmCommunicator.m
//  OFQAAPI
//
//  Created by lei zhu on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TcmCommunicator.h"
#import "TestCase.h"
#import "QALog.h"

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@implementation TcmCommunicator

@synthesize tcmKey;
@synthesize tcmSubmitUrl;
@synthesize tcmRetrievalUrl;

- (id) initWithKey:(NSString*)key 
         submitUrl:(NSString*)submitUrl 
      retrievalUrl:(NSString*)url{
    [self setTcmKey:key];
    [self setTcmSubmitUrl:submitUrl];
    [self setTcmRetrievalUrl:url];
    return self;
}

- (id) doHttpPost:(NSString*)url 
              params:(NSDictionary*)params{
    NSURL* rUrl = [NSURL URLWithString:url];

    NSData* result = nil;
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:rUrl];
    [request setPostValue:[params objectForKey:@"status_id"] forKey:@"status_id"];
    [request setPostValue:[params objectForKey:@"comment"] forKey:@"comment"];
    [request setValidatesSecureCertificate:NO];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        result = [request responseData];
    }else{
        QALog(@"sb xcode, network error ===== %@", [error description]);
    }

    return result;
}

- (id) doHttpGet:(NSString*)url{
    NSURL* rUrl = [NSURL URLWithString:url];
    NSData* result = nil;
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:rUrl];
    [request setValidatesSecureCertificate:NO];
    [request startSynchronous];
    NSError *error = [request error];
    if (!error) {
        result = [request responseData];
    }else{
        QALog(@"sb xcode, network error ===== %@", [error description]);
    }
    return result;
}

- (NSData*) requestCasesBySuiteId:(NSString*)suiteId{
    NSString* url = [[self tcmRetrievalUrl] stringByAppendingFormat:@"%@&key=%@", suiteId, [self tcmKey]];
    NSData* rawResult = [self doHttpGet:url];
    return rawResult;
}

- (void) postCasesResultByRunId:(NSString*)runId 
                             cases:(NSArray*)cases{
    for (int i=0; i<cases.count; i++) {
        TestCase* tc = [cases objectAtIndex:i];
        NSString* url = [[self tcmSubmitUrl] stringByAppendingFormat:@"%@/%@&key=%@", runId, [tc caseId], [self tcmKey]];
        NSMutableDictionary* mud = [[NSMutableDictionary alloc] init];
        [mud setValue: [NSString stringWithFormat:@"%d", [tc result]]
               forKey:@"status_id"];
        [mud setValue:[tc resultComment] 
               forKey:@"comment"];
        
        [self doHttpPost:url params:mud];
        [mud release];
    }
}

- (void) postCasesResultByRunId:(NSString *)runId 
                        AndCase:(TestCase *) tc{
    NSString* url = [[self tcmSubmitUrl] stringByAppendingFormat:@"%@/%@&key=%@", runId, [tc caseId], [self tcmKey]];
    NSMutableDictionary* mud = [[NSMutableDictionary alloc] init];
    [mud setValue: [NSString stringWithFormat:@"%d", [tc result]]
           forKey:@"status_id"];
    [mud setValue:[tc resultComment] 
           forKey:@"comment"];
    
    [self doHttpPost:url params:mud];
    [mud release];
}

//
//- (void)dealloc{
//    [tcmKey release];
//    [tcmSubmitUrl release];
//    [tcmRetrievalUrl release];
//    [super dealloc];
//}

@end
