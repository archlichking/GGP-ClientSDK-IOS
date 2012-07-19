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

#import "PurchaseCell.h"
#import "GreeWalletProduct.h"
#import "UIImageView+ShowCaseAdditions.h"

@interface PurchaseCell ()
@property(nonatomic, retain)GreeWalletProduct* productInstance;
- (void)cleanUpOldImageRequest;
- (void)updateImage;
- (void)updateLabels;
@end

@implementation PurchaseCell
@synthesize iconImage = _iconImage;
@synthesize textName = _textName;
@synthesize textDescription = _textDescription;
@synthesize textPrice = _textPrice;
@synthesize amount = _amount;
@synthesize productId = _productId;
@synthesize productInstance = _productInstance;

- (void)dealloc {
  [self cleanUpOldImageRequest];
  [_productInstance release];
  [_iconImage release];
  [_textName release];
  [_textDescription release];
  [_textPrice release];
  [_amount release];
  [super dealloc];
}

- (void)updateFromGreeWalletProduct:(GreeWalletProduct*)product
{
  [self cleanUpOldImageRequest];
  self.productInstance = product;
  [self updateLabels];
  [self updateImage];
}

- (void)updateImage
{
  [self.iconImage showLoadingImageWithSize:self.iconImage.frame.size];
  [self.productInstance loadIconWithBlock:^(UIImage *image, NSError *error) {
    CGFloat scale = [UIScreen mainScreen].scale;
    [self.iconImage showImage:image withSize:CGSizeMake(self.bounds.size.width * scale, self.bounds.size.height * scale)];
  }];
}

#pragma mark private methods
- (void)updateLabels
{
  NSNumberFormatter *currencyStyle = [[NSNumberFormatter alloc] init];
  NSNumber *price = [currencyStyle numberFromString:_productInstance.price];
  [currencyStyle setNumberStyle:NSNumberFormatterCurrencyStyle];
  [currencyStyle setCurrencyCode:_productInstance.currencyCode];
  self.productId = _productInstance.productId;
  self.textPrice.text = [currencyStyle stringFromNumber:price];
  self.textDescription.text = _productInstance.productDescription;
  self.textName.text = _productInstance.productTitle;
  self.amount.text = [NSString stringWithFormat:@"%@(%@)", _productInstance.totalAmount, _productInstance.points];
  [currencyStyle release];
}

- (void)cleanUpOldImageRequest
{
  [self.productInstance cancelIconLoad];
}
@end
