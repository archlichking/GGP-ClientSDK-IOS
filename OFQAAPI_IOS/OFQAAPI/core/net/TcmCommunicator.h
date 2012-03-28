//
//  TcmCommunicator.h
//  OFQAAPI
//
//  Created by lei zhu on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetCommunicator.h"

@interface TcmCommunicator : NSObject <NetCommunicator>{
    @private
    NSString* tcmRetrievalUrl;
    NSString* tcmSubmitUrl;
    NSString* tcmKey;
}

@property (retain) NSString* tcmRetrievalUrl;
@property (retain) NSString* tcmSubmitUrl;
@property (retain) NSString* tcmKey;

- (id) initWithKey:(NSString*)key 
         submitUrl:(NSString*) Url 
      retrievalUrl:(NSString*)url;

- (id) doHttpPost:(NSString*) url 
              params:(NSDictionary*) params;
- (id) doHttpGet:(NSString*) url;

- (NSData*) requestCasesBySuiteId:(NSString*) suiteId;
- (void) postCasesResultByRunId:(NSString*)runId 
                             cases:(NSArray*)cases;

@end
