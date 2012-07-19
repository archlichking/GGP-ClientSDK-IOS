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
#import "GreePlatform.h"
#import "GreeLogger.h"

#pragma mark - GreeLoggerTests

SPEC_BEGIN(GreeLoggerTests)

describe(@"GreeLogger", ^{
  __block GreeLogger* logger = nil;

  beforeEach(^{
    logger = [[GreeLogger alloc] init];

    GreePlatform* mock = [GreePlatform nullMock];
    [GreePlatform stub:@selector(sharedInstance) andReturn:mock];
    [mock stub:@selector(logger) andReturn:logger];
  });
  
  afterEach(^{
    [logger release];
    logger = nil;
  });

  //it corrects later.
  pending_(@"should have a description", ^{
//    NSString* expectedDescription = [NSString stringWithFormat:@"<GreeLogger:%p, level:100, includeFileLineInfo:YES>", logger];
//    [[[logger description] should] equal:expectedDescription];
  });
  
  //it corrects later.
  pending_(@"should not generate a compiler warning when ignoring return value", ^{
//    [logger log:@"Test" level:0 fromFile:__FILE__ atLine:__LINE__];
  });

  //it corrects later.
  pending_(@"should allow logs at a lower level then the logger", ^{
//    logger.level = GreeLogLevelInfo;
//    BOOL didLog = GreeLogPublic(@"Test");
//    [[theValue(didLog) should] beYes];
  });

  //it corrects later.
  pending_(@"should allow logs at the same level as the logger", ^{
//    logger.level = GreeLogLevelWarn;
//    BOOL didLog = GreeLogWarn(@"Test");
//    [[theValue(didLog) should] beYes];
  });

  //it corrects later.
  pending_(@"should filter logs at a higher level than the logger", ^{
//    logger.level = GreeLogLevelPublic;
//    BOOL didLog = GreeLogWarn(@"Test");
//    [[theValue(didLog) should] beNo];
  });

  //it corrects later.
  pending_(@"when using a file", ^{
    __block NSFileHandle* mockHandle;
    beforeEach(^{
      //don't write the actual filepath
      [[NSFileManager defaultManager] stub:@selector(createDirectoryAtPath:withIntermediateDirectories:attributes:error:)];
      [[NSFileManager defaultManager] stub:@selector(createFileAtPath:contents:attributes:)];
      
      //which means we need to fake the actual logging handle
      mockHandle = [NSFileHandle nullMock];
      [NSFileHandle stub:@selector(fileHandleForWritingAtPath:) andReturn:mockHandle];
      
      logger.logToFile = YES;
    });
    
    it(@"should create the file handle", ^{
      [[logger valueForKey:@"logHandle"] shouldNotBeNil];
    });
    
    it(@"should write", ^{
      [[mockHandle should] receive:@selector(writeData:)];
      [logger log:@"Test" level:0 fromFile:__FILE__ atLine:__LINE__];
    });
    
    context(@"but cancelling it", ^{
      beforeEach(^{
        logger.logToFile = NO;
      });
      it(@"should remove handle", ^{
        [[logger valueForKey:@"logHandle"] shouldBeNil];
      });
    });
  });
  
});

SPEC_END
