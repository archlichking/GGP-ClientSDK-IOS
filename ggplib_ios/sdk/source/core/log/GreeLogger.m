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

#import "GreeLogger.h"
#import "NSString+GreeAdditions.h"

@interface GreeLogger ()
-(void)deleteAdditionalLogsFolder;
@end

@implementation GreeLogger

@synthesize level = _level;
@synthesize includeFileLineInfo = _includeFileLineInfo;
@synthesize logToFile = _logToFile;
@synthesize filePathList = _filePathList;
@synthesize fileLogLevelList = _fileLogLevelList;
@synthesize fileCount = _fileCount;
@synthesize fileIdList = _fileIdList;
@synthesize logToFileList = _logToFileList;
@synthesize internalSettingsLogLevel = _internalSettingsLogLevel;
@synthesize additionalLogsFolder = _additionalLogsFolder;

#pragma mark - Object Lifecycle

- (id)init
{
  self = [super init];
  if (self != nil) {
    [self deleteAdditionalLogsFolder];
    _includeFileLineInfo = YES;    
    _filePathList = [[NSMutableArray alloc] init];
    _fileLogLevelList = [[NSMutableArray alloc] init];
    _fileIdList = [[NSMutableArray alloc] init];
    _fileCount = 0;    
    _logToFileList = [[NSMutableArray alloc] init];
    _internalSettingsLogLevel = 0;
    _additionalLogsFolder = [NSString string];
  }
  
  return self;
}

- (void)dealloc
{
  [_filePathList release];
  [_fileLogLevelList release];
  [_fileIdList release];
  [_logToFileList release];
  [_additionalLogsFolder release];
  [super dealloc];
}

#pragma mark - Public Interface

- (void)log:(NSString*)message level:(NSInteger)level fromFile:(char const*)file atLine:(int)line, ...
{
  NSMutableString* prefix = [[NSMutableString alloc] initWithCapacity:64];
  [prefix appendString:@"[Gree]"];
  
  if (self.includeFileLineInfo) {
    NSString* fileString = [[NSString alloc] initWithUTF8String:file];
    [prefix appendFormat:@"[%@:%d] ", [fileString lastPathComponent], line];
    [fileString release];
  }
  
  va_list args;
  va_start(args, line);
  NSString* formattedMessage = [[NSString alloc] initWithFormat:message arguments:args];
  va_end(args);
  
  NSString* finalString = [[NSString alloc] initWithFormat:@"%@ %@", prefix, formattedMessage];
  if (self.internalSettingsLogLevel >= level) {
    NSLog(@"%@", finalString);
  }
  
  if (0 < _filePathList.count) {
    for (int count = 0; count < _fileLogLevelList.count; count++) {
      NSString* fileLogLevel = [_fileLogLevelList objectAtIndex:count];
      if ([fileLogLevel integerValue] >= level) {
        if ([[_logToFileList objectAtIndex:count] boolValue]) {      
          NSString* filePath = [_filePathList objectAtIndex:count];
          if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            NSString* withNewline = [finalString stringByAppendingString:@"\n"];
            NSFileHandle* fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:[withNewline dataUsingEncoding:NSUTF8StringEncoding]];
            [fileHandle closeFile];
          }
        }
      }
    }
  }
  
  [finalString release];
  [formattedMessage release];
  [prefix release];
}

- (BOOL)logToFile
{
  return _logToFile;
}

- (void)setLogToFile:(BOOL)logToFile
{
  _logToFile = logToFile;

  if(logToFile) {
    if (_fileCount < 3) {
      NSString* fileName = [NSString stringWithFormat:@"Log %@", [NSDate date]];
      fileName = [fileName stringByReplacingOccurrencesOfString:@":" withString:@"."];
      NSString* folderName = [GreePlatform sharedInstance].logger.additionalLogsFolder;
      if (0 < folderName.length) {
        fileName = [folderName stringByAppendingFormat:@"/%@", fileName];
      }
      NSString*filePath = [NSString greeLoggingPathForRelativePath:fileName];
      [_filePathList addObject:filePath];
      [[NSFileManager defaultManager] createDirectoryAtPath:[filePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:NULL];
      [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
      
      NSString* logfile_id = [NSString stringWithFormat:@"logfile_id+%d", _fileCount];
      [_fileIdList addObject:logfile_id];
      [_logToFileList addObject:[NSNumber numberWithBool:logToFile]];
      [_fileLogLevelList addObject:[NSString stringWithFormat:@"%d", _level]];
      _fileCount++;
    }
  }
}

- (NSInteger)level
{
  return _level;
}

- (void)setLevel:(NSInteger)level
{
  _level = level;
}

-(void)deleteAdditionalLogsFolder
{
  NSString* folderName = [NSString stringWithString:@"AdditionalLogFiles"];  
  NSString*folderlePath = [NSString greeLoggingPathForRelativePath:folderName];
  if ([[NSFileManager defaultManager] fileExistsAtPath:folderlePath]) {
    [[NSFileManager defaultManager] removeItemAtPath:folderlePath error:nil];
  }
}

- (void)setLoggerParameters:(NSString*)additionalLogsFolder level:(NSInteger)level logToFile:(BOOL)logToFile 
{
  @synchronized(self) {
    self.additionalLogsFolder = additionalLogsFolder;
    self.level = level;
    self.logToFile = logToFile;
  }
}

#pragma mark - NSObject Overrides

- (NSString*)description
{
  return [NSString stringWithFormat:
          @"<%@:%p, level:%d, includeFileLineInfo:%@>", 
          NSStringFromClass([self class]), 
          self,
          self.level,
          self.includeFileLineInfo ? @"YES" : @"NO"];
}

@end
