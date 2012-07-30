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
        ret = @"CHECKING";
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
    
    [GreeModeratedText createWithString:text
                                  block:^(GreeModeratedText *createdUserText, NSError *error) {
                                      if(!error) {
                                          [[self getBlockRepo] setObject:createdUserText forKey:@"text"];
                                      }
                                      [self notifyInStep];
    }];
    
    [self waitForInStep];

//    if (![ModerationStepDefinition StringToBool:contain]) {
//        // need to delete one
//        GreeModeratedText* t = [[self getBlockRepo] objectForKey:@"text"];
//        
//        [t deleteWithBlock:^(NSError *error) {
//            [self notifyInStep];
//        }];
//        [self waitForInStep];
//    }
}

// step definition : I send to moderation server with text TEXT
- (void) I_send_to_moderation_server_with_text_PARAM:(NSString*) text{
    [GreeModeratedText createWithString:text
                                  block:^(GreeModeratedText *createdUserText, NSError *error) {
        if(!error) {
            [[self getBlockRepo] setObject:createdUserText forKey:@"text"];
        }
        [self notifyInStep];
    }];
    
    [self waitForInStep];
}

// step definition : status of text TEXT in server should be STATUS
- (void) status_of_text_PARAM:(NSString*) text 
    _should_be_PARAM:(NSString*) status{
    GreeModeratedText* t = [[self getBlockRepo] objectForKey:@"text"];
    [QAAssert assertEqualsExpected:status 
                            Actual:[ModerationStepDefinition StatusToString:[t status]]];
}

// step definition : I update text TEXT with new text TEXT_1
// I update text my words rule all with new text my words rule them all
- (void) I_update_text_PARAM:(NSString*) text 
        _with_new_text_PARAM:(NSString*) text2{
    
    GreeModeratedText* t = [[self getBlockRepo] objectForKey:@"text"];
//    NSLog(@"%@ --------- in update one", t);
    [t updateWithString:text2 block:^(NSError *error) {
        if(!error) {
            [[self getBlockRepo] setObject:t forKey:@"text"];
//            NSLog(@"%@ --------- in update two", t);
        }
        [self notifyInStep];    
    }];
    [self waitForInStep];
    
//    [[self getBlockRepo] setObject:[self fetchModerationFromServerById:[t textId]] forKey:@"text"];
    
}

// step definition : I check from SERVER with status of text TEXT
- (void) I_load_from_PARAM:(NSString*) position _with_moderation_text_PARAM:(NSString*) text{
    GreeModeratedText* t = [[self getBlockRepo] objectForKey:@"text"];
//    NSLog(@"%@ --------- in load one", t);
    NSMutableArray* ids = [[NSMutableArray alloc] initWithObjects:[t textId], nil];
    [GreeModeratedText loadFromIds:ids
                             block:^(NSArray *userTexts, NSError *error) {
                                 if(!error){
//                                     NSLog(@"%@ --------- in load two", [userTexts objectAtIndex:0]);
                                     [[self getBlockRepo] setObject:[userTexts objectAtIndex:0] 
                                                             forKey:@"text"];
                                 }
                                 [self notifyInStep];
                             }];
    [self waitForInStep];
    [ids release];
}

// step definition : I check from server with status of text TEXT
- (void) I_check_from_native_cache_with_status_of_text_PARAM:(NSString*) text{
    
}

// step definition : new text should be TEXT
- (void) new_text_should_be_PARAM:(NSString*) text{
    GreeModeratedText* t = [[self getBlockRepo] objectForKey:@"text"];
//    NSLog(@"%@", [t content]);
//    NSLog(@"%@", text);
    [QAAssert assertEqualsExpected:text 
                            Actual:[t content]];
}

// step definition : I delete from moderation server with text TEXT
- (void) I_delete_from_moderation_server_with_text_PARAM:(NSString*) text{
   
    GreeModeratedText* t = [[self getBlockRepo] objectForKey:@"text"];
    [t deleteWithBlock:^(NSError *error) {
        if(!error){
            [self notifyInStep];
        }
    }];
    [self waitForInStep];
    
//    [[self getBlockRepo] setObject:[self fetchModerationFromServerById:[t textId]] forKey:@"text"];
}

// step definition : I serialize moderation text
- (void) I_serialize_moderation_text{
    GreeModeratedText* t = [[self getBlockRepo] objectForKey:@"text"];
    t serializeWithGreeSerializer:<#(GreeSerializer *)#>]
}
@end
