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
#import "JSONKit.h"

#pragma mark - Utility

//this allows you to tag quoted values like  @key instead of \"key\"
//it is assumed that it's use for json strings so it has some cases:
//  if a token goes to the end, it isn't end quoted (json always ends with brace or bracket)
//  a token can consist of all digits
static NSString* quotify(NSString*input)
{
  //this is a lot harder than it should be!
  unichar buffer[input.length * 2];  //plenty of room to grow
  unichar* outPtr = buffer;

  BOOL insideKeyword = NO;
  for (int i = 0; i < input.length; ++i) {
    unichar c = [input characterAtIndex:i];
    if (insideKeyword) {
      bool valid = NO;
      valid |= [[NSCharacterSet alphanumericCharacterSet] characterIsMember:c];
      valid |= c == '_';
      if (!valid) {
        //end the keyword
        *outPtr++ = '\"';
        insideKeyword = NO;
      }
      *outPtr++ = c;
    } else {
      if (c == '@') {
        *outPtr++ = '\"';
        insideKeyword = YES;
      } else {
        *outPtr++ = c;
      }
    }
  }
  return [NSString stringWithCharacters:buffer length:outPtr - buffer];
}

#pragma mark - Quotify Tests

SPEC_BEGIN(Quotify)

describe(@"the quotify method", ^{
  it(@"should work with multiple @ tokens", ^{
    NSString* input = @"@this is @the, string to @check!";
    [[quotify(input) should] equal:@"\"this\" is \"the\", string to \"check\"!"];
  });

  it(@"should work with string consisting only of @ tokens", ^{
    NSString* input = @"@this_combines @3ok3 ";
    [[quotify(input) should] equal:@"\"this_combines\" \"3ok3\" "];
  });
});

SPEC_END

#pragma mark - JSON Tests Using JSONKit

SPEC_BEGIN(GreeJSONTestsUsingJSONKit)

describe(@"JSONKit", ^{

  context(@"with unicode input", ^{

    it(@"should preserve on decode", ^{
      NSString* input = quotify(@"{ @key : \"g-clef:𝄞\", \"key𝄐\" : @value2 }");
      [[[input greeObjectFromJSONString] should] haveValue:@"g-clef:𝄞" forKey:@"key"];
      [[[input greeObjectFromJSONString] should] haveValue:@"value2" forKey:@"key𝄐"];
    });

    it(@"should preserve on encode", ^{
      NSArray* input = [NSArray arrayWithObject:@"g-clef:𝄞"];
      [[[input greeJSONString] should] equal:@"[\"g-clef:𝄞\"]"];
    });

  });

  it(@"should decode JSON with complex nesting", ^{
    NSString* input = quotify(@"{ @k1 : @v1, @k2 : { @k1 : @v1, @k2 : [ @v1, @v2, @v3 ] }, @k3 : [ @v1, @v2, { @k1 : @v1, @k2 : [ @v1, @v2 ], @k3 : [ ], @k4 : { }, @k5 : null }, null ] }");
    id decoded = [input greeObjectFromJSONString];
    [[decoded should] beKindOfClass:[NSDictionary class]];
    [[[decoded valueForKeyPath:@"k1"] should] equal:@"v1"];
    [[[decoded valueForKeyPath:@"k2.k1"] should] equal:@"v1"];
    [[[decoded valueForKeyPath:@"k2.k2"] should] haveCountOf:3];
    [[[decoded valueForKeyPath:@"k3"] should] haveCountOf:4];
    NSArray* k3Array = [decoded valueForKeyPath:@"k3"];
    [[k3Array should] beKindOfClass:[NSArray class]];
    id subdictionary = [k3Array objectAtIndex:2];
    [[[subdictionary valueForKeyPath:@"k2"] should] haveCountOf:2];
    [[[subdictionary valueForKeyPath:@"k3"] should] beKindOfClass:[NSArray class]];
    [[[subdictionary valueForKeyPath:@"k3"] should] haveCountOf:0];
    [[[subdictionary valueForKeyPath:@"k4"] should] beKindOfClass:[NSDictionary class]];
    [[[subdictionary valueForKeyPath:@"k4"] should] haveCountOf:0];
    [[[subdictionary valueForKeyPath:@"k5"] should] beKindOfClass:[NSNull class]];
    [[[k3Array lastObject] should] beKindOfClass:[NSNull class]];
  });
  
  it(@"should encode JSON with complex nesting", ^{
    NSDictionary* root = [NSDictionary dictionaryWithObjectsAndKeys:
      @"v1", @"k1",
      [NSDictionary dictionaryWithObjectsAndKeys:
        @"v1", @"k1",
        [NSArray arrayWithObjects:@"v1", @"v2", @"v3", nil], @"k2",
        nil], @"k2",
      [NSArray arrayWithObjects:
        @"v1", 
        @"v2", 
        [NSDictionary dictionaryWithObjectsAndKeys:
          @"v1", @"k1",
          [NSArray arrayWithObjects:@"v1", @"v2", nil], @"k2",
          [NSArray array], @"k3",
          [NSDictionary dictionary], @"k4",
          [NSNull null], @"k5",
          nil],
        [NSNull null],
        nil], @"k3",
      nil];
    
    NSError* error = nil;
    NSString* json = [root greeJSONStringWithOptions:GreeJKSerializeOptionNone error:&error];
    
    [json shouldNotBeNil];
    [[json should] beKindOfClass:[NSString class]];
    [error shouldBeNil];
  });

});

SPEC_END

#pragma mark - JSON Tests Using NSJSONSerialization

SPEC_BEGIN(GreeJSONTestsUsingNSJSONSerialization)

describe(@"NSJSONSerialization", ^{
  
  context(@"with unicode input", ^{
    
    it(@"should preserve on decode", ^{
      NSString* input = quotify(@"{ @key : \"g-clef:𝄞\", \"key𝄐\" : @value2 }");
      id output = [NSJSONSerialization JSONObjectWithData:[input dataUsingEncoding:NSUTF8StringEncoding] options:0x0 error:nil];
      [[output should] haveValue:@"g-clef:𝄞" forKey:@"key"];
      [[output should] haveValue:@"value2" forKey:@"key𝄐"];
    });
    
    it(@"should preserve on encode", ^{
      NSArray* input = [NSArray arrayWithObject:@"g-clef:𝄞"];
      NSString* output = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:input options:0x0 error:nil] encoding:NSUTF8StringEncoding];
      [[output should] equal:@"[\"g-clef:𝄞\"]"];
      [output release];
    });
    
  });
  
  it(@"should decode JSON with complex nesting", ^{
    NSString* input = quotify(@"{ @k1 : @v1, @k2 : { @k1 : @v1, @k2 : [ @v1, @v2, @v3 ] }, @k3 : [ @v1, @v2, { @k1 : @v1, @k2 : [ @v1, @v2 ], @k3 : [ ], @k4 : { }, @k5 : null }, null ] }");
    id decoded = [NSJSONSerialization JSONObjectWithData:[input dataUsingEncoding:NSUTF8StringEncoding] options:0x0 error:nil];
    [[decoded should] beKindOfClass:[NSDictionary class]];
    [[[decoded valueForKeyPath:@"k1"] should] equal:@"v1"];
    [[[decoded valueForKeyPath:@"k2.k1"] should] equal:@"v1"];
    [[[decoded valueForKeyPath:@"k2.k2"] should] haveCountOf:3];
    [[[decoded valueForKeyPath:@"k3"] should] haveCountOf:4];
    NSArray* k3Array = [decoded valueForKeyPath:@"k3"];
    [[k3Array should] beKindOfClass:[NSArray class]];
    id subdictionary = [k3Array objectAtIndex:2];
    [[[subdictionary valueForKeyPath:@"k2"] should] haveCountOf:2];
    [[[subdictionary valueForKeyPath:@"k3"] should] beKindOfClass:[NSArray class]];
    [[[subdictionary valueForKeyPath:@"k3"] should] haveCountOf:0];
    [[[subdictionary valueForKeyPath:@"k4"] should] beKindOfClass:[NSDictionary class]];
    [[[subdictionary valueForKeyPath:@"k4"] should] haveCountOf:0];
    [[[subdictionary valueForKeyPath:@"k5"] should] beKindOfClass:[NSNull class]];
    [[[k3Array lastObject] should] beKindOfClass:[NSNull class]];
  });
  
  it(@"should encode JSON with complex nesting", ^{
    NSDictionary* root = [NSDictionary dictionaryWithObjectsAndKeys:
      @"v1", @"k1",
      [NSDictionary dictionaryWithObjectsAndKeys:
        @"v1", @"k1",
        [NSArray arrayWithObjects:@"v1", @"v2", @"v3", nil], @"k2",
        nil], @"k2",
      [NSArray arrayWithObjects:
        @"v1", 
        @"v2", 
        [NSDictionary dictionaryWithObjectsAndKeys:
          @"v1", @"k1",
          [NSArray arrayWithObjects:@"v1", @"v2", nil], @"k2",
          [NSArray array], @"k3",
          [NSDictionary dictionary], @"k4",
          [NSNull null], @"k5",
          nil],
        [NSNull null],
        nil], @"k3",
      nil];
    
    NSError* error = nil;
    NSString* json = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:root options:0x0 error:&error] encoding:NSUTF8StringEncoding];
    
    [json shouldNotBeNil];
    [[json should] beKindOfClass:[NSString class]];
    [error shouldBeNil];
    
    [json release];
  });
  
});

SPEC_END
