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
#import "GreeAES128.h"
#import "NSData+GreeAdditions.h"
#import "NSString+GreeAdditions.h"

SPEC_BEGIN(GreeAES128Spec)

describe(@"GreeKeyChainSpec", ^{

  __block GreeAES128 *aes = nil;
  
  beforeEach(^{
    aes = [[GreeAES128 alloc] init];
  });
  
  afterEach(^{
    [aes release];
  });
  
  it(@"should generate 16byte length of NSData", ^{
    NSData* data = [aes generateKey];
    [[theValue([data length]) should] equal:theValue(16)];
  });

  it(@"should generate randam data", ^{
    NSData* data1 = [aes generateKey];
    NSData* data2 = [aes generateKey];
    [[data1 shouldNot] equal:data2];
  });

  it(@"should encrypt", ^{
    NSString* seedKey = [[aes generateKey] greeFormatInHex];
    NSData *keydata = [seedKey greeHexStringFormatInBinary];
    [aes setKey:[keydata bytes]];
    [aes setInitializationVector:[keydata bytes]];  
    NSString* rawStr = @"be904852b9fbf127108b06d4b79160cc6384d919cf1290040ee266f198f69969a007c75f001327485117021227f7ee43";
    NSData *rawData = [rawStr greeHexStringFormatInBinary];
    NSData *encryptedData = [aes encrypt:[rawData bytes] length:[rawData length]];
    NSData *decryptedData = [aes decrypt:[encryptedData bytes] length:[encryptedData length]];
    NSString* rawStrAfterEncodeDecode = [decryptedData greeFormatInHex];
    [[rawStrAfterEncodeDecode should] equal:rawStr];    
  });  
});

SPEC_END
