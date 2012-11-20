//
//  AnnouncementStepDefinition.m
//  QAAutoSample
//
//  Created by zhu lei on 11/19/12.
//  Copyright (c) 2012 OFQA. All rights reserved.
//

#import "VGAnnouncementStepDefinition.h"

#import "GreeVirtualGoods.h"
#import "GreeVirtualGoods+Announcements.h"

#import "QAAssert.h"

@implementation VGAnnouncementStepDefinition

- (void) developer_uses_SDK_to_load_vgs_announcements{
    [[self getBlockRepo] removeObjectForKey:@"vgannouncements"];
    [[GreeVirtualGoods sharedInstance] loadAnnouncementsWithBlock:^(NSArray *announcements, NSError *error) {
        if(!error){
            [[self getBlockRepo] setObject:announcements forKey:@"vgannouncements"];
        }
        [self inStepNotify];
    }];
    [self inStepWait];
}

- (void) vgs_announcement_amount_should_be_PARAMINT:(NSString*) size{
    NSArray* vgannouncements = [[self getBlockRepo] objectForKey:@"vgannouncements"];
    [QAAssert assertEqualsExpected:size
                            Actual:[NSString stringWithFormat:@"%i", [vgannouncements count]]];
}

- (void) vgs_announcement_should_include_title_PARAM:(NSString*) title
                                     _and_body_PARAM:(NSString*) body{
    NSArray* vgannouncements = [[self getBlockRepo] objectForKey:@"vgannouncements"];
    NSString* found = [NSString stringWithFormat:@"not found vgs announcement with title %@ and body %@", title, body];
    for (GreeVGAnnouncement* ann in vgannouncements) {
        if ([[ann subject] isEqualToString:title]
            && [[ann body] isEqualToString:body]) {
            found = nil;
        }
    }
    [QAAssert assertNil:found];
}

- (void) developer_uses_SDK_to_check_basic_info_of_announcement_with_title_PARAM:(NSString*) title{
    [[self getBlockRepo] removeObjectForKey:@"vgannouncement"];
    NSArray* vgannouncements = [[self getBlockRepo] objectForKey:@"vgannouncements"];
    for (GreeVGAnnouncement* ann in vgannouncements) {
        if ([[ann subject] isEqualToString:title]) {
            [[self getBlockRepo] setObject:ann forKey:@"vgannouncement"];
            break;
        }
    }
}

- (void) info_PARAM:(NSString*) info _of_announcement_PARAM:(NSString*) title
   _should_be_PARAM:(NSString*) content{
    GreeVGAnnouncement* ann = [[self getBlockRepo] objectForKey:@"vgannouncement"];
    if ([info isEqualToString:@"body"]) {
        [QAAssert assertEqualsExpected:content Actual:[ann body]];
    }else if([info isEqualToString:@"isRead"]){
        [QAAssert assertEqualsExpected:content Actual:[ann isUnread]?@"YES":@"NO"];
    }else if([info isEqualToString:@"date"]){
        [QAAssert assertEqualsExpected:content Actual:[[ann date] description]];
    }else{
        [QAAssert assertNotNil:nil];
    }
}

@end
