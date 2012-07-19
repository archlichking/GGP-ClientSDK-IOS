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

#import "GreeJSStopLogWritingFileCommand.h"
#import "GreeLogger.h"

@interface GreeJSStopLogWritingFileCommand ()
- (void)stopWritingLog:(GreeLogger*)logger inputId:(NSString*)inputId index:(NSInteger)index;
@property (nonatomic, retain) NSString* errorMessage;
@end

@implementation GreeJSStopLogWritingFileCommand

@synthesize errorMessage = _errorMessage;

+ (NSString *)name
{
  return @"stop_log_writing_file";
}

- (void)execute:(NSDictionary*)parameters
{
  self.errorMessage = [NSString string];
  NSString* input_fileId = [parameters objectForKey:@"logfile_id"];
  if (input_fileId.length == 0) {
    self.errorMessage = @"input value is empty.";
  } else {  
    GreeLogger* logger = [GreePlatform sharedInstance].logger;    
    if (logger.fileIdList != nil) {
      for (NSString* fileId in logger.fileIdList) {
        if ([fileId rangeOfString:input_fileId].location != NSNotFound) {
          if ([fileId isEqualToString:@"logfile_id+0"]) {
            [self stopWritingLog:logger inputId:fileId index:0];
            break;
          } else if ([fileId isEqualToString:@"logfile_id+1"]) {
            [self stopWritingLog:logger inputId:fileId index:1];
            break;
          } else if ([fileId isEqualToString:@"logfile_id+2"]) {
            [self stopWritingLog:logger inputId:fileId index:2];
            break;
          } else {
            self.errorMessage = @"logfile_id dosen't exist.";
          }
        } else {
           self.errorMessage = @"input logfile_id dosen't exist.";
        }
      }
    } else {
      self.errorMessage = @"logfile_id_list is null.";
    }
  }
  
  NSMutableDictionary* dictionary = [NSMutableDictionary dictionaryWithDictionary:parameters];
  [dictionary setObject:self.errorMessage forKey:@"error"];
  
  NSDictionary* results = [NSDictionary dictionaryWithObject:dictionary forKey:@"result"];
  [[self.environment handler]
   callback:[dictionary objectForKey:@"callback"]
   params:results];
  
}

- (void)stopWritingLog:(GreeLogger*)logger inputId:(NSString*)inputId index:(NSInteger)index
{
  NSString* filePath = [NSString string];
  filePath = [logger.filePathList objectAtIndex:index];
  [logger.logToFileList replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:NO]];
  self.errorMessage = @"";
}

- (void)dealloc
{
  [_errorMessage release];
  [super dealloc];
}

- (NSString*)description
{
  return [NSString stringWithFormat:@"<%@:%p>", NSStringFromClass([self class]), self];
}

@end
