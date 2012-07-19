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
#import "GreeJSSubnavigationIconPersistentCache.h"

#pragma mark - GreeJSSubnavigationIconPersistentCacheTest

SPEC_BEGIN(GreeJSSubnavigationIconPersistentCacheTest)

describe(@"GreeJSSubnavigationIconPersistentCache tests", ^{
  __block UIImage* fakeImage;
  beforeEach(^{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(NULL, 50, 50, 8, 256, colorSpace, kCGImageAlphaPremultipliedLast);
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    fakeImage = [[UIImage imageWithCGImage:cgImage] retain];
    CFRelease(cgImage);
    CFRelease(context);
    [[GreeJSSubnavigationIconPersistentCache sharedImageCache] clearCache];
  });
  afterEach(^{
    [fakeImage release];
  });
  
  it(@"should define a cache", ^{
    [[GreeJSSubnavigationIconPersistentCache sharedImageCache] shouldNotBeNil];
  });
  
  it(@"should cache in memory", ^{
    GreeJSSubnavigationIconPersistentCache* cache = [GreeJSSubnavigationIconPersistentCache sharedImageCache];
    
    NSURL* url = [NSURL URLWithString:@"http://test.gree.net/testingURL"];
    [cache cacheImageData:UIImagePNGRepresentation(fakeImage) forURL:url];
    //note: haveValueForKey doesn't seem to work right with NSCache
    id storedData = [cache objectForKey:[url absoluteString]];
    [storedData shouldNotBeNil];
  });
  
  it(@"should allow clearing memory cache", ^{
    GreeJSSubnavigationIconPersistentCache* cache = [GreeJSSubnavigationIconPersistentCache sharedImageCache];
    NSURL* url = [NSURL URLWithString:@"http://test.gree.net/testingURL"];
    [cache cacheImageData:UIImagePNGRepresentation(fakeImage) forURL:url];
    [cache clearMemoryCache];
    
    id storedData = [cache objectForKey:[url absoluteString]];
    [storedData shouldBeNil];
  });
  
  it(@"should cache to disk", ^{
    GreeJSSubnavigationIconPersistentCache* cache = [GreeJSSubnavigationIconPersistentCache sharedImageCache];

    NSURL* url = [NSURL URLWithString:@"http://test.gree.net/testingURL"];
    NSData* imageData = UIImagePNGRepresentation(fakeImage);
    [[imageData should] receive:@selector(writeToFile:atomically:)];
    [cache cacheImageData:imageData forURL:url];
  });
  
  it(@"should clear disk storage", ^{
    GreeJSSubnavigationIconPersistentCache* cache = [GreeJSSubnavigationIconPersistentCache sharedImageCache];

    NSURL* url = [NSURL URLWithString:@"http://test.gree.net/testingURL"];
    NSData* imageData = UIImagePNGRepresentation(fakeImage);
    [cache cacheImageData:imageData forURL:url];
    
    [[[NSFileManager defaultManager] should] receive:@selector(removeItemAtPath:error:)];
    [cache clearDiskCache];
  });
  
  it(@"should read from memory", ^{
    GreeJSSubnavigationIconPersistentCache* cache = [GreeJSSubnavigationIconPersistentCache sharedImageCache];
    
    NSURL* url = [NSURL URLWithString:@"http://test.gree.net/testingURL"];
    NSData* imageData = UIImagePNGRepresentation(fakeImage);
    [cache cacheImageData:imageData forURL:url];
    
    [[UIImage shouldNot] receive:@selector(imageWithContentsOfFile:)];
    UIImage* retrieveImage = [cache cachedImageForURL:url];
    [retrieveImage shouldNotBeNil];
    [[theValue(retrieveImage.size.width) should] equal:theValue(fakeImage.size.width)];
  });
  
  it(@"should read disk when memory isn't there", ^{
    GreeJSSubnavigationIconPersistentCache* cache = [GreeJSSubnavigationIconPersistentCache sharedImageCache];
    
    NSURL* url = [NSURL URLWithString:@"http://test.gree.net/testingURL"];
    NSData* imageData = UIImagePNGRepresentation(fakeImage);
    [cache cacheImageData:imageData forURL:url];
    [cache clearMemoryCache];
    UIImage* retrieveImage = [cache cachedImageForURL:url];
    [retrieveImage shouldNotBeNil];
    [[theValue(retrieveImage.size.width) should] equal:theValue(fakeImage.size.width)];    
  });
  
  it(@"should return nil if there isn't any data", ^{
    GreeJSSubnavigationIconPersistentCache* cache = [GreeJSSubnavigationIconPersistentCache sharedImageCache];
    NSURL* url = [NSURL URLWithString:@"http://test.gree.net/testingURL"];
    UIImage* retrieveImage = [cache cachedImageForURL:url];
    [retrieveImage shouldBeNil];
  });
  
});
SPEC_END
