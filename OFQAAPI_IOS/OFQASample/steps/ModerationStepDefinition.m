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
    NSString* ret = @"NOTHING";
    if (status == GreeModerationStatusBeingChecked) {
        ret = @"CHECKED";
    }
    if (status == GreeModerationStatusResultApproved) {
        ret = @"APPROVED";
    }
    if (status == GreeModerationStatusDeleted) {
        ret = @"DELETED";
    }
    if (status == GreeModerationStatusResultRejected) {
        ret = @"REJECTED";
    }
    return ret;
}

// step definition :  I make sure moderation server INCLUDES text TEXT
- (void) I_make_sure_moderation_server_PARAM:(NSString*) contain 
                                 _text_PARAM:(NSString*) text{
    __block int d = 1;
    [GreeModeratedText createWithString:text
                                  block:^(GreeModeratedText *createdUserText, NSError *error) {
                                      if(!error) {
                                          [[self getBlockRepo] setObject:createdUserText forKey:@"text"];
                                      }
                                      d = 0;
    }];
    
    while (d!=0) {
        [NSThread sleepForTimeInterval:1];
    }

    if (![ModerationStepDefinition StringToBool:contain]) {
        // need to delete one
        __block int d = 1;
        GreeModeratedText* t = [[self getBlockRepo] objectForKey:@"text"];
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
    __block int d = 1;
    [GreeModeratedText createWithString:text
                                  block:^(GreeModeratedText *createdUserText, NSError *error) {
        if(!error) {
            [[self getBlockRepo] setObject:createdUserText forKey:@"text"];
        }
        d = 0;
    }];
    
    while (d != 0) {
        [NSThread sleepForTimeInterval:1];
    }
}

// step definition : status of text TEXT in native cache should be STATUS
- (void) status_of_text_PARAM:(NSString*) text _in_native_cache_should_be_PARAM:(NSString*) status{
    
}

// step definition : status of text TEXT in server should be STATUS
- (void) status_of_text_PARAM:(NSString*) text 
    _in_server_should_be_PARAM:(NSString*) status{
    GreeModeratedText* t = [[self getBlockRepo] objectForKey:@"text"];
    [QAAssert assertEqualsExpected:status 
                            Actual:[ModerationStepDefinition StatusToString:[t status]]];
}

// step definition : I update text TEXT with new text TEXT_1
// I update text my words rule all with new text my words rule them all
- (void) I_update_text_PARAM:(NSString*) text 
        _with_new_text_PARAM:(NSString*) text2{
    __block int d = 1;
    GreeModeratedText* t = [[self getBlockRepo] objectForKey:@"text"];
    [t updateWithString:text2 block:^(NSError *error) {
        d = 0;    
    }];
    while (d == 1) {
        [NSThread sleepForTimeInterval:1];
    }
}

// step definition : I check from server with status of text TEXT
- (void) I_check_from_server_with_status_of_text_PARAM:(NSString*) text{

}

// step definition : I delete from moderation server with text TEXT
- (void) I_delete_from_moderation_server_with_text_PARAM:(NSString*) text{
    __block int d = 1;
    GreeModeratedText* t = [[self getBlockRepo] objectForKey:@"text"];
    [t deleteWithBlock:^(NSError *error) {
        d = 0;
    }];
    while (d == 1) {
        [NSThread sleepForTimeInterval:1];
    }
}

@end