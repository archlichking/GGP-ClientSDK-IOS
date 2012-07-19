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
#import "GreeSqlQuery.h"
#import "GreeTestHelpers.h"

#pragma mark - GreeSqlQueryTests

SPEC_BEGIN(GreeSqlQueryTests)

describe(@"GreeSqlQuery", ^{
  it(@"should gracefully fail to close a NULL database", ^{
    GreeDatabaseHandle nullHandle = NULL;
    GreeDatabaseHandle database = NULL;
    [GreeSqlQuery closeDatabase:&database];
    [[theValue(database) should] equal:theValue(nullHandle)];
  });

  it(@"should create a new database if one does not exist at the given path", ^{
    NSString* databasePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"testCreatedDatabase"];
    [[NSFileManager defaultManager] removeItemAtPath:databasePath error:nil]; 
    
    [[theValue([[NSFileManager defaultManager] fileExistsAtPath:databasePath]) should] beNo];

    GreeDatabaseHandle database = [GreeSqlQuery openDatabaseAtPath:databasePath];
    [theValue(database) shouldNotBeNil];
    [GreeSqlQuery closeDatabase:&database];
    
    [[theValue([[NSFileManager defaultManager] fileExistsAtPath:databasePath]) should] beYes];
  });

  it(@"should fail to initialize when not given a database", ^{
    GreeSqlQuery* query = [[GreeSqlQuery alloc] initWithDatabase:NULL statement:@"SELECT * FROM test_table"];
    [query shouldBeNil];
  });
  
  context(@"with an open database", ^{
    __block GreeDatabaseHandle database = NULL;
    
    beforeEach(^{
      NSString* bundleDatabasePath = [[NSBundle mainBundle] pathForResource:@"testValidDatabase" ofType:@"sqlite"];
      NSString* tempDatabasePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"testValidDatabase.sqlite"];
      [[NSFileManager defaultManager] copyItemAtPath:bundleDatabasePath toPath:tempDatabasePath error:nil];
      database = [GreeSqlQuery openDatabaseAtPath:tempDatabasePath];
    });
    
    afterEach(^{
      [GreeSqlQuery closeDatabase:&database];
      NSString* tempDatabasePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"testValidDatabase.sqlite"];
      [[NSFileManager defaultManager] removeItemAtPath:tempDatabasePath error:nil];
    });
    
    it(@"should have a description method", ^{
      GreeSqlQuery* query = [[GreeSqlQuery alloc] initWithDatabase:database statement:@"SELECT * FROM test_table"];
      NSString* expected = [NSString stringWithFormat:
        @"<GreeSqlQuery:%p, database:%p, statement:SELECT * FROM test_table>", 
        query,
        database];
      [[[query description] should] equal:expected];
      [query release];
    });
    
    it(@"should have a convenience constructor", ^{
      GreeSqlQuery* query = [GreeSqlQuery queryWithDatabase:database statement:@"SELECT * FROM test_table"];
      [query shouldNotBeNil];
    });

    it(@"should fail to initialize when not given a statement", ^{
      GreeSqlQuery* query = [[GreeSqlQuery alloc] initWithDatabase:database statement:nil];
      [query shouldBeNil];
      [query release];
    });

    it(@"should fail to initialize when a statement is invalid and will not compile", ^{
      GreeSqlQuery* query = [[GreeSqlQuery alloc] initWithDatabase:database statement:@"FOO * BAR LIKE a%"];
      [query shouldBeNil];    
      [query release];
    });
    
    it(@"should allow reset", ^{
      GreeSqlQuery* query = [[GreeSqlQuery alloc] 
        initWithDatabase:database 
        statement:@"REPLACE INTO test_table (integer_field) VALUES (:int)"];
      [query shouldNotBeNil];
      [query bindInt:123 named:@"int"];
      [[theValue([query step]) should] beYes];
      [[theValue([query step]) should] beNo];
      [query reset];
      [[theValue([query step]) should] beYes];
      [query release];
    });
    
    it(@"should raise when binding after stepping without reset", ^{
      GreeSqlQuery* query = [[GreeSqlQuery alloc] 
        initWithDatabase:database 
        statement:@"INSERT INTO test_table (integer_field) VALUES (:int)"];
      [query shouldNotBeNil];
      [query bindInt:123 named:@"int"];
      [[theValue([query step]) should] beYes];
      [[theBlock(^{
        [query bindInt:321 named:@"int"];
      }) should] raise];
      [query reset];
      [query bindInt:321 named:@"int"];
      [[theValue([query step]) should] beYes];
      [query release];      
    });
    
    context(@"with a bunch of data", ^{
    
      beforeEach(^{
        GreeSqlQuery* query = [[GreeSqlQuery alloc] 
          initWithDatabase:database 
          statement:
            @"INSERT INTO test_table (integer_field, int64_field, bool_field, string_field, data_field, double_field) "
            @"VALUES (:int, :int64, :bool, :string, :data, :double)"];
        
        [query bindBool:YES named:@"bool"];
        [query bindString:@"string as string with UTF8 char: 𝄞" named:@"string"];
        [query bindData:[[NSString stringWithString:@"string as data with UTF8 char: 𝄞"] dataUsingEncoding:NSUTF8StringEncoding] named:@"data"];
        [query bindDouble:DBL_MAX named:@"double"];
        
        for (int i = 0; i < 12; ++i) {
          [query bindInt:1234 + i named:@"int"];
          [query bindInt64:5000000000 + i named:@"int64"];

          [query step];
          [query reset];
        }
        
        [query release];
      });
      
      it(@"should be able to query data with NSFastEnumeration", ^{
        GreeSqlQuery* query = [[GreeSqlQuery alloc] initWithDatabase:database statement:@"SELECT * FROM test_table"];
        [query shouldNotBeNil];
        
        int rowIndex = 0;
        for (NSDictionary* row in query) {
          [[[row objectForKey:@"integer_field"] should] equal:[NSNumber numberWithInt:1234 + rowIndex]]; 
          [[[row objectForKey:@"int64_field"] should] equal:[NSNumber numberWithLongLong:5000000000 + rowIndex]]; 
          [[[row objectForKey:@"bool_field"] should] equal:[NSNumber numberWithBool:YES]]; 
          [[[row objectForKey:@"string_field"] should] equal:@"string as string with UTF8 char: 𝄞"]; 
          [[[row objectForKey:@"data_field"] should] equal:[@"string as data with UTF8 char: 𝄞" dataUsingEncoding:NSUTF8StringEncoding]]; 
          [[[row objectForKey:@"double_field"] should] equal:[NSNumber numberWithDouble:DBL_MAX]]; 
          ++rowIndex;
        };
        
        [[theValue([query step]) should] beNo];
        [[theValue([query hasRowData]) should] beNo];

        [query release];
      });
      
      context(@"while querying a row", ^{
        __block GreeSqlQuery* query = nil;

        beforeEach(^{
          query = [[GreeSqlQuery alloc] initWithDatabase:database statement:@"SELECT * FROM test_table WHERE integer_field = :int"];
          [query shouldNotBeNil];
        });
        
        afterEach(^{
          [query release];
          query = nil;
        });
        
        it(@"should allow querying row values without NSFastEnumeration", ^{
          [query bindInt:1234 named:@"int"];
          [[theValue([query step]) should] beYes];
          [[theValue([query integerValueAtColumnNamed:@"integer_field"]) should] equal:[NSNumber numberWithInt:1234]];
          [[theValue([query int64ValueAtColumnNamed:@"int64_field"]) should] equal:[NSNumber numberWithLongLong:5000000000]];
          [[theValue([query boolValueAtColumnNamed:@"bool_field"]) should] equal:[NSNumber numberWithBool:YES]];
          [[[query stringValueAtColumnNamed:@"string_field"] should] equal:@"string as string with UTF8 char: 𝄞"];
          [[[query dataValueAtColumnNamed:@"data_field"] should] equal:[@"string as data with UTF8 char: 𝄞" dataUsingEncoding:NSUTF8StringEncoding]];
          [[theValue([query doubleValueAtColumnNamed:@"double_field"]) should] equal:[NSNumber numberWithDouble:DBL_MAX]];
        });

        it(@"should correctly detect the end and gracefully fail stepping", ^{
          [query bindInt:1234 named:@"int"];
          [[theValue([query step]) should] beYes];
          [[[query stringValueAtColumnNamed:@"string_field"] should] equal:@"string as string with UTF8 char: 𝄞"];
          [[theValue([query step]) should] beYes];
          [[theValue([query hasRowData]) should] beNo];
        });
        
        it(@"should raise when fetching non-existant value", ^{
          [[theValue([query step]) should] beYes];
          
          __block NSString* value = nil;
          [[theBlock(^{
            value = [query stringValueAtColumnNamed:@"dummy_wrong"];
          }) should] raise];

          [value shouldBeNil];
        });

      });

      context(@"while inserting a row", ^{
        __block GreeSqlQuery* query = nil;

        beforeEach(^{
          query = [[GreeSqlQuery alloc] initWithDatabase:database statement:@"INSERT INTO test_table (integer_field) VALUES (:int)"];
          [query shouldNotBeNil];
        });
        
        afterEach(^{
          [query release];
          query = nil;
        });

        it(@"should raise when binding unknown parameter", ^{
          [[theBlock(^{
            [query bindInt:789 named:@"wrongname"];
          }) should] raise];
        });

      });

    });

    it(@"should not crash when using NSFastEnumeration on an empty query" , ^{
      GreeSqlQuery* query = [[GreeSqlQuery alloc] initWithDatabase:database statement:@"SELECT * FROM test_table"];
      [query shouldNotBeNil];
      for (NSDictionary* row in query) {
        [[theValue([row count]) should] beZero];
      }
      [query release];
    });
  });

});

SPEC_END
