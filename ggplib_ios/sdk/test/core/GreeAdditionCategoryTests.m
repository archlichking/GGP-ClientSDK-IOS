//
// Copyright 2012 GREE, Inc.
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
#import "NSData+GreeAdditions.h"
#import "NSString+GreeAdditions.h"
#import "NSBundle+GreeAdditions.h"
#import "NSURL+GreeAdditions.h"
#import "NSHTTPCookieStorage+GreeAdditions.h"
#import "NSDictionary+GreeAdditions.h"
#import "GreeTestHelpers.h"
#import <UIKit/UIKit.h>
#import "NSDateFormatter+GreeAdditions.h"
#import "GreeMatchers.h"

@interface UIImage (GreeAdditionsPrivate)
+ (UIImage*)greeChooseImageClosestToWidth:(NSInteger)targetWidth current:(UIImage*)current challenger:(UIImage*)challenger;
@end

#pragma mark - GreeAdditionCategoryTests

SPEC_BEGIN(GreeAdditionCategoryTests)
describe(@"NSString categories", ^{
  context(@"when padding application version", ^{
    it(@"should handle integer", ^{
      [[[@"2" formatAsGreeVersion] should] equal:@"0002.00.00"];
    });    
    it(@"should handle two pieces", ^{
      [[[@"2.3" formatAsGreeVersion] should] equal:@"0002.03.00"];
    });    
    it(@"should handle full values", ^{
      [[[@"1234.34.67" formatAsGreeVersion] should] equal:@"1234.34.67"];
    });    
    it(@"should ignore later pieces", ^{
      [[[@"1.2.3.4.5.6." formatAsGreeVersion] should] equal:@"0001.02.03"];
    });    
    it(@"should ignore non-numeric values", ^{
      [[[@"a.b.c" formatAsGreeVersion] should] equal:@"0000.00.00"];
    });    
  });


  it(@"should build hash dictionaries", ^{
    NSDictionary* outVal = [@"there" greeHashWithNonceAndKeyPrefix:@"hi"];
    [[outVal should] haveValueForKey:@"hash"];
    [[outVal should] haveValueForKey:@"nonce"];
  });
  
  context(@"when localizing html on demand", ^{

    it(@"should handle clean replacements", ^{
      NSString* html = 
        @"<!-- localized:MAGICAL -->\n"
        @"hey\n this\n is\n placeholder\n"
        @"<!-- localized -->\n\n";
      NSString* expected =
        @"bonk\n\n";
      [[[html greeStringByReplacingHtmlLocalizedStringWithKey:@"MAGICAL" withString:@"bonk"] should] equal:expected];
    });
    
    it(@"should handle 1-line replacements", ^{
      NSString* html = 
        @"<!-- localized:MAGICAL -->"
        @"yoda is a yodite"
        @"<!-- localized -->\n";
      NSString* expected =
        @"bonk\n";
      [[[html greeStringByReplacingHtmlLocalizedStringWithKey:@"MAGICAL" withString:@"bonk"] should] equal:expected];
    });
    
    it(@"should not handle multiline replacements", ^{
      NSString* html = 
        @"<!-- localized:MAGICAL\n\n guys this is placeholder and a big comment -->"
        @"replace me<!-- localized -->\n";
      [[[html greeStringByReplacingHtmlLocalizedStringWithKey:@"MAGICAL" withString:@"bonk"] should] equal:html];
    });

  });

});

describe(@"NSData categories", ^{

  it(@"should handle a nil key", ^{
    NSData* data = [NSData dataWithBytes:"hey" length:3];
    [[data greeHashWithKey:nil] shouldBeNil];
  });
  
  it(@"should produce correct output for at least 1 known vector", ^{
    NSData* data = [@"The quick brown fox jumps over the lazy dog" dataUsingEncoding:NSUTF8StringEncoding];
    [[[data greeHashWithKey:@"key"] should] equal:@"de7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9"];
  });

});

describe(@"NSBundle categories", ^{

  it(@"should pop a uialert and return nil", ^{
    id swizzleHandle = [GreeTestHelpers 
                        exchangeClassSelector:@selector(greePlatformCoreBundle) 
                        onClass:[NSBundle class] 
                        withSelector:@selector(greeTestBundle) 
                        onClass:[NSBundle class]];
    
    
    UIAlertView* alertMock = [UIAlertView nullMock];
    [alertMock stub:@selector(initWithTitle:message:delegate:cancelButtonTitle:otherButtonTitles:) andReturn:alertMock];
    [alertMock stub:@selector(autorelease) andReturn:alertMock];
    [[alertMock shouldEventuallyBeforeTimingOutAfter(1.f)] receive:@selector(show)];
    [UIAlertView stub:@selector(alloc) andReturn:alertMock];
    
    NSBundle* bundle = [NSBundle greePlatformCoreBundle];
    [bundle shouldBeNil];
    
    [GreeTestHelpers restoreExchangedSelectors:&swizzleHandle];
  });
    
});

describe(@"NSHTTPCookieStorage category", ^{
  
  beforeEach(^{
    for (NSHTTPCookie* cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
      [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
  });
  
  it(@"should set/get individual cookies", ^{
    [[[NSHTTPCookieStorage greeCookiesWithDomain:@"test.gree.net"] should] equal:[NSArray array]];
    [NSHTTPCookieStorage greeSetCookie:@"duh" forName:@"testCookie" domain:@"test.gree.net"];
    [[[NSHTTPCookieStorage greeGetCookieValueWithName:@"testCookie" domain:@"test.gree.net"] should] equal:@"duh"];
  });
  
  it(@"should set cookies with params", ^{
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
      @"derp", @"blerp",
      @"testValue", @"testKey",
      nil];
    [NSHTTPCookieStorage greeSetCookieWithParams:params domain:@"test.gree.net"];
    
    [[[NSHTTPCookieStorage greeGetCookieValueWithName:@"blerp" domain:@"test.gree.net"] should] equal:@"derp"];
    [[[NSHTTPCookieStorage greeGetCookieValueWithName:@"testKey" domain:@"test.gree.net"] should] equal:@"testValue"];
  });
  
  context(@"with some cookies", ^{
    
    beforeEach(^{
      [NSHTTPCookieStorage greeSetCookie:@"duh" forName:@"testCookie0" domain:@"test.gree.net"];
      [NSHTTPCookieStorage greeSetCookie:@"hud" forName:@"testCookie1" domain:@"test.gree.net"];
      [NSHTTPCookieStorage greeSetCookie:@"red" forName:@"testCookie2" domain:@"test.gree.net"];
    });
    
    it(@"should be able to delete cookies", ^{
      [NSHTTPCookieStorage greeDeleteCookieWithName:@"testCookie1" domain:@"test.gree.net"];
      [[NSHTTPCookieStorage greeGetCookieValueWithName:@"testCookie1" domain:@"test.gree.net"] shouldBeNil];
    });
    
    it(@"should be able to get cookies for a specific domain", ^{
      NSArray* cookies = [NSHTTPCookieStorage greeCookiesWithDomain:@"test.gree.net"];
      [[theValue([cookies count]) should] equal:theValue(3)];
    });
    
  });

});

describe(@"NSDictionary category", ^{
	it(@"should be able to create query string from single key and value", ^{
		NSDictionary* params = [[[NSDictionary alloc]initWithObjectsAndKeys:@"bar", @"foo",
																		   nil
								] autorelease];
		[[[params greeBuildQueryString] should] equal:@"foo=bar"];
	});
	it(@"should be able to create query string from multiple keys and values", ^{
		NSDictionary* params = [[[NSDictionary alloc]initWithObjectsAndKeys:@"value1", @"key1",
																		   @"value2", @"key2",
																		   nil
								] autorelease];
		[[[params greeBuildQueryString] should] equal:@"key2=value2&key1=value1"];
	});
	it(@"should be able to create query string from float value", ^{
		NSDictionary* params = [[[NSDictionary alloc]initWithObjectsAndKeys:[[[NSNumber alloc] initWithFloat:2.25f] autorelease], @"key",
																			nil
								] autorelease];
		[[[params greeBuildQueryString] should] equal:@"key=2.25"];
	});
	it(@"should be able to create query string without nil object", ^{
		NSDictionary* params = [[[NSDictionary alloc]initWithObjectsAndKeys:[[[NSNull alloc] init] autorelease], @"nilObj",
																			@"value", @"key",
																			nil
								 ] autorelease];
		[[[params greeBuildQueryString] should] equal:@"key=value"];
	});
});

describe(@"NSURL category", ^{

  context(@"when deleting query string in URL", ^{
    it(@"should be able to delete query string from url", ^{
      NSURL *url = [NSURL URLWithString:@"http://foo.bar.com/foo/bar?aaa=bbb&ccc=ddd"];
      [[[[url URLByDeletingQuery] absoluteString] should] equal:@"http://foo.bar.com/foo/bar"];
    });
    it(@"should not affect url which query string is not contained", ^{
      NSURL *url = [NSURL URLWithString:@"http://foo.bar.com/foo/bar"];
      [[[[url URLByDeletingQuery] absoluteString] should] equal:@"http://foo.bar.com/foo/bar"];
    });
  });

});

describe(@"UIImage category", ^{
  __block UIImage* small;
  __block UIImage* medium;
  __block UIImage* large;
  beforeEach(^{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(NULL, 50, 50, 8, 256, colorSpace, kCGImageAlphaPremultipliedLast);
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    small = [UIImage imageWithCGImage:cgImage];
    CFRelease(cgImage);
    CFRelease(context);
    
    context = CGBitmapContextCreate(NULL, 80, 80, 8, 80*4, colorSpace, kCGImageAlphaPremultipliedLast);
    cgImage = CGBitmapContextCreateImage(context);
    medium = [UIImage imageWithCGImage:cgImage];
    CFRelease(cgImage);
    CFRelease(context);
    
    context = CGBitmapContextCreate(NULL, 120, 120, 8, 120*4, colorSpace, kCGImageAlphaPremultipliedLast);
    cgImage = CGBitmapContextCreateImage(context);
    large = [UIImage imageWithCGImage:cgImage];
    CFRelease(cgImage);
    CFRelease(context);
    
    CFRelease(colorSpace);
  });
  
  it(@"should always choose first value", ^{
    UIImage* current = nil;
    current = [UIImage greeChooseImageClosestToWidth:50 current:current challenger:small];
    [[current should] equal:small];
  });
  it(@"should accept exact value when bigger", ^{
    UIImage* current = small;
    current = [UIImage greeChooseImageClosestToWidth:80 current:current challenger:medium];
    [[current should] equal:medium];
  });
  it(@"should accept exact value when smaller", ^{
    UIImage* current = large;
    current = [UIImage greeChooseImageClosestToWidth:80 current:current challenger:medium];
    [[current should] equal:medium];
  });
  it(@"should accept closer when smaller", ^{
    UIImage* current = small;
    current = [UIImage greeChooseImageClosestToWidth:90 current:current challenger:medium];
    [[current should] equal:medium];
  });
  it(@"should accept closer when bigger", ^{
    UIImage* current = large;
    current = [UIImage greeChooseImageClosestToWidth:40 current:current challenger:medium];
    [[current should] equal:medium];
  });
  it(@"should not take larger value when over size", ^{
    UIImage* current = medium;
    current = [UIImage greeChooseImageClosestToWidth:40 current:current challenger:large];
    [[current should] equal:medium];
  });
  it(@"should not take smaller value when under size", ^{
    UIImage* current = medium;
    current = [UIImage greeChooseImageClosestToWidth:240 current:current challenger:small];
    [[current should] equal:medium];
  });
  it(@"should work with nil when bigger", ^{
    UIImage* current = large;
    current = [UIImage greeChooseImageClosestToWidth:40 current:current challenger:nil];
    [[current should] equal:large];
  });
  it(@"should work with nil when smaller", ^{
    UIImage* current = small;
    current = [UIImage greeChooseImageClosestToWidth:240 current:current challenger:nil];
    [[current should] equal:small];
  });
});

describe(@"NSDateFormatter category", ^{
  registerMatchers(@"Gree");

  beforeEach(^{
    NSTimeZone* zone = [NSTimeZone timeZoneWithName:@"PDT"];
    [NSTimeZone setDefaultTimeZone:zone];
  });
  it(@"should format standard", ^{
    NSDateFormatter* basicFormat = [[NSDateFormatter alloc] init];
    [basicFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate* testDate = [[basicFormat dateFromString:@"2012-01-01 00:00"] retain];
    [basicFormat release];
    NSDateFormatter* format = [NSDateFormatter greeStandardDateFormatter];
    NSString* formatted = [format stringFromDate:testDate];
    [[formatted should] equal:@"2012-01-01 00:00:00"];
  });
  it(@"should format styled", ^{
    NSDateFormatter* basicFormat = [[NSDateFormatter alloc] init];
    [basicFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate* testDate = [[basicFormat dateFromString:@"2012-01-01 00:00"] retain];
    [basicFormat release];
    NSDateFormatter* format = [NSDateFormatter greeSystemMediumStyleDateFormatter];
    NSString* formatted = [format stringFromDate:testDate];
    [[formatted should] equal:@"Jan 1, 2012 12:00:00 AM"];
  });
  it(@"should format with UTC", ^{
    NSDateFormatter* basicFormat = [[NSDateFormatter alloc] init];
    [basicFormat setDateFormat:@"yyyy-MM-dd HH:mm zzz"];
    NSDate* testDate = [[basicFormat dateFromString:@"2012-01-01 00:00 GMT"] retain];
    [basicFormat release];
    NSDateFormatter* format = [NSDateFormatter greeUTCDateFormatter];
    NSString* formatted = [format stringFromDate:testDate];
    [[formatted should] equal:@"2012-01-01 00:00:00"];
  });
  it(@"should format with Zone", ^{
    NSDateFormatter* basicFormat = [[NSDateFormatter alloc] init];
    [basicFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate* testDate = [[basicFormat dateFromString:@"2012-01-01 00:00"] retain];
    [basicFormat release];

    NSDateFormatter* format = [NSDateFormatter greeDateAndZoneFormatter];
    NSString* formatted = [format stringFromDate:testDate];
    [[formatted should] matchRegExp:@"2012-01-01T00:00:00[-+]0[89]00"];
  });
});


SPEC_END
