//
//  TcmCommunicator.h
//  OFQAAPI
//
//  Created by lei zhu on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpCommunicator.h"
#import "TestCase.h"

@interface TcmCommunicator : HttpCommunicator{
    @private
    NSString* tcmRetrievalUrl;
    NSString* tcmSubmitUrl;
    NSString* tcmKey;
}


@property (retain) NSString* tcmRetrievalUrl;
@property (retain) NSString* tcmSubmitUrl;
@property (retain) NSString* tcmKey;

+ (TcmCommunicator*) sharedInstance;

+ (void) initWithKey:(NSString*)key
         submitUrl:(NSString*) Url 
      retrievalUrl:(NSString*)url;

- (NSData*) pullAllCasesFromSuite:(NSString*) suiteId;

- (void) pushAllCases:(NSArray*) cases
                toRun:(NSString*) runId;

- (void) pushCase:(TestCase*) caze
            toRun:(NSString*) runId;

@end
