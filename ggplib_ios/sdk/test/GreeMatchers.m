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

#import "GreeMatchers.h"
#import "KWFormatter.h"
#import "KWValue.h"

@interface GreePartialStringMatcher ()
@property (nonatomic,retain) NSString* matchingString;
@end  

@implementation GreePartialStringMatcher
@synthesize matchingString = _matchingString;

#pragma mark - Object Lifecycle

- (void)dealloc
{
  [_matchingString release];
  [super dealloc];
}

#pragma mark - Public Interface
- (void)containString:(NSString *)string
{
  self.matchingString = string;
}

#pragma mark - NSObject Overrides

- (NSString*)description
{
  return [NSString stringWithFormat:@"containString %@", [KWFormatter formatObject:self.matchingString]];
}

#pragma mark - KWMatching
+ (NSArray*)matcherStrings
{
  return [NSArray arrayWithObjects:@"containString:", nil];
}

- (BOOL)evaluate
{
  if(!self.matchingString) return NO;
  NSRange range = [self.subject rangeOfString:self.matchingString];
  return range.location != NSNotFound;
}

- (NSString*)failureMessageForShould 
{
  return [NSString stringWithFormat:@"expected subject to contain substring %@, was %@", 
          [KWFormatter formatObject:self.matchingString], [KWFormatter formatObject:self.subject]];
}

- (NSString*)failureMessageForShouldNot 
{
  return [NSString stringWithFormat:@"expected subject not to contain substring %@, was %@", 
          [KWFormatter formatObject:self.matchingString], [KWFormatter formatObject:self.subject]];
}
@end

@interface GreeRegularExpressionMatcher ()
@property (nonatomic, retain) NSRegularExpression* expression;
@end

@implementation GreeRegularExpressionMatcher
@synthesize expression = _expression;

#pragma mark - Object Lifecycle

- (void)dealloc
{
  [_expression release];
  [super dealloc];
}

#pragma mark - Public Interface
- (void)matchRegExp:(NSString *)string
{
  [self matchRegExp:string withOptions:0];
}

- (void)matchRegExp:(NSString *)string withOptions:(NSRegularExpressionOptions)options
{
  self.expression = [NSRegularExpression regularExpressionWithPattern:string options:options error:nil];  
  if(!self.expression) {
    [NSException raise:@"Regular Expression failed" format:string];
  }
}


#pragma mark - NSObject Overrides

- (NSString*)description
{
  return [NSString stringWithFormat:@"expression %@", [KWFormatter formatObject:self.expression]];
}


#pragma mark - KWMatching
+ (NSArray*)matcherStrings
{
  return [NSArray arrayWithObjects:@"matchRegExp:", @"matchRegExp:withOptions:", nil];
}

- (BOOL)evaluate
{
  if(!self.expression) {
    return NO;
  }
  NSRange match = [self.expression rangeOfFirstMatchInString:self.subject options:0 range:NSMakeRange(0, [self.subject length])];
  return match.location != NSNotFound;
}

- (NSString*)failureMessageForShould 
{
  return [NSString stringWithFormat:@"expected subject to match format %@, was %@", 
          [KWFormatter formatObject:self.expression], [KWFormatter formatObject:self.subject]];
}

- (NSString*)failureMessageForShouldNot 
{
  return [NSString stringWithFormat:@"expected subject not to contain substring %@, was %@", 
          [KWFormatter formatObject:self.expression], [KWFormatter formatObject:self.subject]];
}

@end

@interface GreeDateMatcher ()
@property (nonatomic, retain) NSDate* matchDate;
@end

@implementation GreeDateMatcher
@synthesize matchDate = _matchDate;

#pragma mark - Object Lifecycle

- (void)dealloc
{
  [_matchDate release];
  [super dealloc];
}

#pragma mark - Public Interface
- (void)nearlyEqualDate:(NSDate *)date
{
  self.matchDate = date;
}

#pragma mark - NSObject Overrides

- (NSString*)description
{
  return [NSString stringWithFormat:@"near date %@", self.matchDate];
}


#pragma mark - KWMatching
+ (NSArray*)matcherStrings
{
  return [NSArray arrayWithObjects:@"nearlyEqualDate:", nil];
}

- (BOOL)evaluate
{
  if(![self.subject isKindOfClass:[NSDate class]]) {
    return NO;
  }
  
  NSInteger fromDate = [self.subject timeIntervalSinceDate:self.matchDate];
  return fabs(fromDate) < 1;  //1 second slop time should be enough
}

- (NSString*)failureMessageForShould 
{
  return [NSString stringWithFormat:@"expected subject to be date near%@, was %@", 
          [KWFormatter formatObject:self.matchDate], [KWFormatter formatObject:self.subject]];
}

- (NSString*)failureMessageForShouldNot 
{
  return [NSString stringWithFormat:@"expected subject to not be date near%@, was %@", 
          [KWFormatter formatObject:self.matchDate], [KWFormatter formatObject:self.subject]];
}

@end





