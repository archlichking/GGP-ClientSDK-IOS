//
//  IgnorelistStepDefinition.m
//  OFQAAPI
//
//  Created by lei zhu on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IgnorelistStepDefinition.h"

#import "GreeUser.h"
#import "GreePlatform.h"
#import "QAAssert.h"

@implementation IgnorelistStepDefinition

+ (NSString*) IncludeToString:(NSString*) isInclude{
    if([isInclude isEqualToString:@"INCLUDE"]){
        return @"TRUE";
    }
    else{
        return @"FALSE";
    }
}

+ (NSString*) boolToString:(BOOL) boo{
    if(boo){
        return @"TRUE";
    }else {
        return @"FALSE";
    }
}

- (void) I_make_sure_my_ignore_list_PARAM:(NSString*) contains
                              _user_PARAM:(NSString*) user{
}

- (void) I_load_my_ignore_list{
    GreeUser* user = [GreePlatform sharedInstance].localUser;
    [[self getBlockRepo] setObject:[[[NSArray alloc] init] autorelease] 
                            forKey:@"ignorelist"];
    
    NSMutableArray* array = [[[NSMutableArray alloc] init] autorelease];
    
    id<GreeEnumerator> enumerator = nil;
    if (user) {
        enumerator = [user loadIgnoredUserIdsWithBlock:^(NSArray *ignoreUserIds, NSError *error) {
            // first 10 friends could only be retrieved this way
            if (!error) {
                [array addObjectsFromArray:ignoreUserIds];
            }
            
            [self notifyInStep];
        }];
        [self waitForInStep];
        while ([enumerator canLoadNext]) {
            [enumerator loadNext:^(NSArray *items, NSError *error) {
                if(!error){
                    [array addObjectsFromArray:items];
                }
                [self notifyInStep];
            }];
            
            [self waitForInStep];
        }
    }
    [[self getBlockRepo] setObject:array forKey:@"ignorelist"];
}

- (void) I_load_first_page_of_my_ignore_list{
    GreeUser* user = [GreePlatform sharedInstance].localUser;
    [[self getBlockRepo] setObject:[[[NSArray alloc] init] autorelease] 
                            forKey:@"ignorelist"];
    
    if (user) {
       [user loadIgnoredUserIdsWithBlock:^(NSArray *ignoreUserIds, NSError *error) {
            // first 10 friends could only be retrieved this way
            if (!error) {
                if (!ignoreUserIds) {
                    [[self getBlockRepo] setObject:[[[NSArray alloc] init] autorelease] forKey:@"ignorelist"] ;
                }else{
                    [[self getBlockRepo] setObject:ignoreUserIds forKey:@"ignorelist"];
                }
                
            }
            
            [self notifyInStep];
        }];
        [self waitForInStep];
    }
}

- (void) my_ignore_list_should_be_size_of_PARAMINT:(NSString*) size{
    NSArray* ignorelist = [[self getBlockRepo] objectForKey:@"ignorelist"];
    [QAAssert assertEqualsExpected:size 
                            Actual:[NSString stringWithFormat:@"%i", [ignorelist count]]];
}

- (void) my_ignore_list_should_PARAM:(NSString*) isInclude 
                  _user_PARAM:(NSString*) user{
    NSArray* ignorelist = [[self getBlockRepo] objectForKey:@"ignorelist"];
    NSString* actualInclude = @"FALSE";
    for (NSString* iid in ignorelist) {
        if ([iid isEqualToString:user]) {
            actualInclude = @"TRUE";
            break;
        }
    }
    [QAAssert assertEqualsExpected:[IgnorelistStepDefinition IncludeToString:isInclude]
                            Actual:actualInclude];
}

- (void) I_check_user_from_my_ignore_list_with_id_PARAMINT:(NSString*) userid{
    GreeUser* user = [GreePlatform sharedInstance].localUser;
    [[self getBlockRepo] setObject:[IgnorelistStepDefinition boolToString:NO] 
                            forKey:userid];
    
    [user isIgnoringUserWithId:userid
                         block:^(BOOL isIgnored, NSError *error) {
                             if(!error){
                                 [[self getBlockRepo] setObject:[IgnorelistStepDefinition boolToString:isIgnored] 
                                                         forKey:userid];
                             }
                             [self notifyInStep];
                         }];
    [self waitForInStep];
}


- (void) status_of_PARAM:(NSString*) userid _in_my_ignore_list_should_be_PARAM:(NSString*) expIgnored{
    NSString* actualIgnored = [[self getBlockRepo] objectForKey:userid];
    [QAAssert assertEqualsExpected:expIgnored
                            Actual:actualIgnored];
}

@end
