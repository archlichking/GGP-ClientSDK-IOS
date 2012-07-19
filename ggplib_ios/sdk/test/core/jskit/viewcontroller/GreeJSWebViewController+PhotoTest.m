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
#import "GreeTestHelpers.h"
#import "GreeJSWebViewControllerTestHelper.h"

#import "GreeJSWebViewController.h"
#import "GreeJSWebViewController+Photo.h"

#pragma mark - GreeJSWebViewController+PhotoTests

// for mocking
#import "GreeJSHandler.h"

@interface GreeJSWebViewController(ExposePrivateAPIS)
  @property(nonatomic, retain) GreeJSTakePhotoActionSheet *photoTypeSelector;
  @property(nonatomic, retain) GreeJSTakePhotoPickerController *photoPickerController;
  @property(nonatomic, retain) id popoverPhotoPicker;
@end

SPEC_BEGIN(GreeJSWebViewControllerTests_Photo)

describe(@"GreeJSWebViewController+Photo", ^{
  __block GreeJSWebViewController *viewController;
  beforeEach(^{
    [GreeJSWebViewControllerTestHelper setMocksForinit];
    viewController = [[GreeJSWebViewController alloc] init];
  });
  afterEach(^{
    [viewController release];
  });
  
  describe(@"applyBase64StringFromImage", ^{
    context(@"when called with valid image", ^{
      it(@"should set photopicker callback to self handler", ^{
        UIImage *image = [UIImage mock];
        UIImage *resizedImage = [UIImage mock];
        NSString *b64s = [NSString mock];
        GreeJSTakePhotoPickerController *tppc = [GreeJSTakePhotoPickerController mock];
        CGSize size;
        size.width = 100;
        size.height = 100;
        GreeJSHandler *handler = [GreeJSHandler mock];

        [[UIImage should] receive:@selector(greeResizeImage:maxPixel:rotation:) andReturn:resizedImage];
        [[resizedImage should] receive:@selector(greeBase64EncodedString) andReturn:b64s];
        [[tppc should] receive:@selector(callbackFunction)];
        viewController.photoPickerController = tppc;
        [[resizedImage should] receive:@selector(size) andReturn:theValue(size) withCount:2];
        [[handler should] receive:@selector(callback:params:)];
        [viewController stub:@selector(handler) andReturn:handler];
        [viewController applyBase64StringFromImage:image];

        [UIImage clearStubs];
      });
    });

    context(@"when called with invalid image", ^{
      it(@"should do nothing", ^{
        UIImage *image = [UIImage mock];
        UIImage *resizedImage = [UIImage mock];
        GreeJSTakePhotoPickerController *tppc = [GreeJSTakePhotoPickerController mock];

        [[UIImage should] receive:@selector(greeResizeImage:maxPixel:rotation:) andReturn:resizedImage];
        [[resizedImage should] receive:@selector(greeBase64EncodedString) andReturn:nil];
        [[tppc shouldNot] receive:@selector(callbackFunction)];
        viewController.photoPickerController = tppc;  

        [viewController applyBase64StringFromImage:image];

        [UIImage clearStubs];
      });
    });
  });
});

SPEC_END
