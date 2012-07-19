//
// Copyright 2011 GREE, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Kiwi.h"
#import "GreeAPSNotification.h"
#import "GreeNotificationTypes.h"
#import "GreeSerializer.h"
#import "JSONKit.h"

SPEC_BEGIN(GreeAPSNotificationSpec)

describe(@"GreeAPSNotification", ^{
  it(@"should deserialize", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
      @"519519", @"act",
      @"mockText", @"text",
      [NSNumber numberWithInteger:GreeNotificationSourceCustomMessage], @"type",
      [NSNumber numberWithInteger:GreeAPSNotificationIconGreeType], @"iflag",
      @"abcd", @"itoken",
      @"12345", @"cid",
      nil];
      
    GreeSerializer *serializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeAPSNotification* notification = [[GreeAPSNotification alloc] initWithGreeSerializer:serializer];

    [[notification.actorId should] equal:@"519519"];
    [[notification.text should] equal:@"mockText"];
    [[theValue(notification.type) should] equal:theValue(GreeNotificationSourceCustomMessage)];
    [[theValue(notification.iconFlag) should] equal:theValue(GreeAPSNotificationIconGreeType)];
    [[notification.iconToken should] equal:@"abcd"];
    [[notification.contentId should] equal:@"12345"];
    
    [notification release];
  });
  
  it(@"should serialize", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
      @"519519", @"act",
      @"mockText", @"text",
      [NSNumber numberWithInteger:GreeNotificationSourceCustomMessage], @"type",
      [NSNumber numberWithInteger:GreeAPSNotificationIconGreeType], @"iflag",
      @"abcd", @"itoken",
      @"12345", @"cid",
      nil];
    
    GreeSerializer* deserializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeAPSNotification* notification = [[GreeAPSNotification alloc] initWithGreeSerializer:deserializer];
    GreeSerializer* serializer = [GreeSerializer serializer];
    [notification serializeWithGreeSerializer:serializer];
    [[serializer.rootDictionary should] equal:serialized];
    [notification release];
  });
  
  it(@"should show description", ^{
    NSDictionary* serialized = [NSDictionary dictionaryWithObjectsAndKeys:
      @"519519", @"act",
      @"mockText", @"text",
      [NSNumber numberWithInteger:GreeNotificationSourceCustomMessage], @"type",
      [NSNumber numberWithInteger:GreeAPSNotificationIconGreeType], @"iflag",
      @"abcd", @"itoken",
      @"12345", @"cid",
      nil];
      
    GreeSerializer *serializer = [GreeSerializer deserializerWithDictionary:serialized];
    GreeAPSNotification* notification = [[GreeAPSNotification alloc] initWithGreeSerializer:serializer];
      
    NSString* checkString = [NSString stringWithFormat:@"<GreeAPSNotification:%p, act:519519, text:mockText, type:%@, iflag:%@, itoken:abcd, cid:12345>",
      notification,
      NSStringFromGreeNotificationSource(notification.type),
      NSStringFromGreeAPSNotificationIconType(notification.iconFlag)];
    [[[notification description] should] equal:checkString]; 
    [notification release];
  });
});

SPEC_END
