//
//  ModerationStepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 4/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ModerationStepDefinition.h"

#import "GreeModeratedText.h"
#import "QAAssert.h"

@implementation ModerationStepDefinition

+ (BOOL) StringToBool:(NSString*) str{
    if([str isEqualToString:@"INCLUDES"]){
        return YES;
    }
    else{
        return NO;
    }
}

+ (NSString*) StatusToString:(GreeModerationStatus) status{
    if (status == GreeModerationStatusBeingChecked) {
        return @"CHECKED";
    }
    if (status == GreeModerationStatusResultApproved) {
        return @"APPROVED";
    }
    if (status == GreeModerationStatusDeleted) {
        return @"DELETED";
    }
    if (status == GreeModerationStatusResultRejected) {
        return @"REJECTED";
    }
}

// step definition :  I make sure moderation server INCLUDES text TEXT
- (void) I_make_sure_moderation_server_PARAM:(NSString*) contain 
                                 _text_PARAM:(NSString*) text{
    [self setBlockSentinal:[StepDefinition WAITING]];
    [GreeModeratedText createWithString:text
                                  block:^(GreeModeratedText *createdUserText, NSError *error) {
                                      if(error) {
                                          [self setBlockSentinal: [StepDefinition FAILED]];
                                          [self setBlockActual:[error description]];
                                          return;
                                      }
                                      [self setBlockSentinal:[StepDefinition PASSED]];
                                      // use actual to store achievement result
                                      [self setBlockActual:createdUserText];
                                  }];
    
    while ([self blockSentinal] == [StepDefinition WAITING]) {
        [NSThread sleepForTimeInterval:1];
    }

    if (![ModerationStepDefinition StringToBool:contain]) {
        // need to delete one
        __block int d = 1;
        GreeModeratedText* t = [self blockActual];
        [t deleteWithBlock:^(NSError *error) {
            d = 0;
        }];
        while (d == 1) {
            [NSThread sleepForTimeInterval:1];
        }
    }
}

// step definition : I send to moderation server with text TEXT
- (void) I_send_to_moderation_server_with_text_PARAM:(NSString*) text{
    [self setBlockSentinal:[StepDefinition WAITING]];
    [GreeModeratedText createWithString:text
                                  block:^(GreeModeratedText *createdUserText, NSError *error) {
        if(error) {
            [self setBlockSentinal: [StepDefinition FAILED]];
            [self setBlockActual:[error description]];
            return;
        }
        [self setBlockSentinal:[StepDefinition PASSED]];
        // use actual to store achievement result
        [self setBlockActual:createdUserText];
    }];
    
    while ([self blockSentinal] == [StepDefinition WAITING]) {
        [NSThread sleepForTimeInterval:1];
    }
}

// step definition : status of text TEXT in native cache should be STATUS
- (void) status_of_text_PARAM:(NSString*) text in_native_cache_should_be_PARAM:(NSString*) status{
    
}

// step definition : status of text TEXT in server should be STATUS
- (void) status_of_text_PARAM:(NSString*) text 
    in_server_should_be_PARAM:(NSString*) status{
    GreeModeratedText* t = [self blockActual];
    [QAAssert assertEqualsExpected:status 
                            Actual:[ModerationStepDefinition StatusToString:[t status]]];
}

@end
