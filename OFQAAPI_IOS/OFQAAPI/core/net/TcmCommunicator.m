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
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:rUrl];
    // set post params
    [request setHTTPMethod:@"POST"];
    NSData* postBody = [[NSString stringWithFormat:@"status_id=%@&comment=%@", [params objectForKey:@"status_id"], [params objectForKey:@"comment"]] dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:postBody];
    
    NSHTTPURLResponse* response = [[[NSHTTPURLResponse alloc] init] autorelease];
    NSError* error = [[[NSError alloc] init] autorelease];
    NSData* result = [NSURLConnection sendSynchronousRequest:request 
                                           returningResponse:&response 
                                                       error:&error];
    
    if (response.statusCode < 200 || response.statusCode > 299) {
        QALog(@"sb xcode, network error");
    }
    return result;
}

- (id) doHttpGet:(NSString*)url{
    NSURL* rUrl = [NSURL URLWithString:url];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:rUrl];
    
    [request setHTTPMethod:@"GET"];
    
    NSHTTPURLResponse* response = [[[NSHTTPURLResponse alloc] init] autorelease];
    
    NSError* error = [[[NSError alloc] init] autorelease];
    
    NSData* result = [NSURLConnection sendSynchronousRequest:request 
                                           returningResponse:&response 
                                                       error:&error];
    
    if (response.statusCode < 200 || response.statusCode > 299) {
        QALog(@"sb xcode, network error");
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
