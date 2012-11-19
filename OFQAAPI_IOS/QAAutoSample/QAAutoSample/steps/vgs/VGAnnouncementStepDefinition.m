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

- (void) I_load_vgs_announcement{
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

@end
