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

#import "GreeJSStartLogAdditionalFileCommand.h"
#import "GreeLogger.h"

@interface GreeJSStartLogAdditionalFileCommand ()
@end

@implementation GreeJSStartLogAdditionalFileCommand

+ (NSString *)name
{
  return @"start_log_additional_file";
}

- (void)execute:(NSDictionary*)parameters
{
  NSString* loglevelString = [parameters objectForKey:@"loglevel"];
  if (loglevelString.length == 0) {
    loglevelString = [NSString stringWithFormat:@"%d", GreeLogLevelInfo];
  }

  NSString* errorMessage = [NSString string];
  NSString* logfileId = [NSString string];
  
  GreeLogger* logger = [GreePlatform sharedInstance].logger;
  if(logger.fileCount < 3) {
    [logger setLoggerParameters:[NSString stringWithString:@"AdditionalLogFiles"]
                          level:[loglevelString integerValue]
                      logToFile:YES];
    logfileId = [logger.fileIdList objectAtIndex:logger.fileCount - 1];
  } else {
    errorMessage = @"can't create new logfiles.";
  }

  NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithDictionary:parameters];
  [dictionary setObject:errorMessage forKey:@"error"];
  [dictionary setObject:logfileId forKey:@"logfile_id"];

  NSDictionary* results = [NSDictionary dictionaryWithObject:dictionary forKey:@"result"];
  [[self.environment handler]
   callback:[dictionary objectForKey:@"callback"]
   params:results];
  
}

- (NSString*)description
{
  return [NSString stringWithFormat:@"<%@:%p>", NSStringFromClass([self class]), self];
}

@end
