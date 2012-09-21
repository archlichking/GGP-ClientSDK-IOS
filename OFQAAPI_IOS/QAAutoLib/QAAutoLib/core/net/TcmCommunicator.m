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

static TcmCommunicator* sSharedInstance = nil;

@implementation TcmCommunicator

@synthesize tcmKey;
@synthesize tcmSubmitUrl;
@synthesize tcmRetrievalUrl;

+ (void) initWithKey:(NSString*)key
         submitUrl:(NSString*)submitUrl 
      retrievalUrl:(NSString*)url{
    if (!sSharedInstance) {
        sSharedInstance = [[TcmCommunicator alloc] initializeWithKey:key
                                                           submitUrl:submitUrl
                                                        retrievalUrl:url];
    }
}

+ (TcmCommunicator*) sharedInstance{
    return sSharedInstance;
}

- (id) initializeWithKey:(NSString*)key
         submitUrl:(NSString*)submitUrl
      retrievalUrl:(NSString*)url{
    
    [self setTcmKey:key];
    [self setTcmSubmitUrl:submitUrl];
    [self setTcmRetrievalUrl:url];
    return self;
}



- (NSData*) pullAllCasesFromSuite:(NSString*) suiteId{
    NSString* url = [[self tcmRetrievalUrl] stringByAppendingFormat:@"%@&key=%@", suiteId, [self tcmKey]];
    NSData* rawResult = [self doHttpGet:url
                                 params:nil];
    return rawResult;
}

- (void) pushAllCases:(NSArray*)cases
                toRun:(NSString*) runId{
    for (int i=0; i<cases.count; i++) {
        TestCase* tc = [cases objectAtIndex:i];
        NSString* url = [[self tcmSubmitUrl] stringByAppendingFormat:@"%@/%@&key=%@", runId, [tc caseId], [self tcmKey]];
        NSMutableDictionary* mud = [[NSMutableDictionary alloc] init];
        [mud setValue: [NSString stringWithFormat:@"%d", [tc result]]
               forKey:@"status_id"];
        [mud setValue:[tc resultComment] 
               forKey:@"comment"];
        
        [self doHttpPost:url
                  params:mud];
        QALog(@"pushing TCM with case %@", [tc caseId]);
        [mud release];
    }
}

- (void) pushCase:(TestCase*) caze
            toRun:(NSString*) runId{
    NSString* url = [[self tcmSubmitUrl] stringByAppendingFormat:@"%@/%@&key=%@", runId, [caze caseId], [self tcmKey]];
    NSMutableDictionary* mud = [[NSMutableDictionary alloc] init];
    [mud setValue: [NSString stringWithFormat:@"%d", [caze result]]
           forKey:@"status_id"];
    [mud setValue:[caze resultComment]
           forKey:@"comment"];
    
    [self doHttpPost:url
              params:mud];
    QALog(@"pushing TCM with case %@", [caze caseId]);
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
