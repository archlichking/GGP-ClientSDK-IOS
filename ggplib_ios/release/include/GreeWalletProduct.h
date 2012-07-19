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

/**
 * @file GreeWalletProduct.h
 * GreeWalletProduct class
 */

#import <UIKit/UIKit.h>

////#indoc "GreeWalletProduct"
////#indocBegin "GreeWalletProduct" en 1
///**
// * @brief A class encapsulation the product data for Gree Hard Currency store items
// * 
// */
////#indocEnd "GreeWalletProduct" en 1
@interface GreeWalletProduct : NSObject

/**
 * @brief The product's productId string
 */
@property(nonatomic, readonly)NSString* productId;

/**
 * @brief The product's title string
 */
@property(nonatomic, readonly)NSString* productTitle;

/**
 * @brief The product description string
 */
@property(nonatomic, readonly)NSString* productDescription;

/**
 * @brief The string representation of the currency code
 */
@property(nonatomic, readonly)NSString* currencyCode;

/**
 * @brief The product's price as a string
 */
@property(nonatomic, readonly)NSString* price;

/**
 * @brief A URL as a string for downloading the product icon
 */
@property(nonatomic, readonly)NSString* iconURL;

/**
 * @brief The tier of the product
 */
@property(nonatomic, readonly)NSString* tier;

/**
 * @brief The total amount of coins issued upon purchase of the product. May be nil. If nil use the value in points.
 */
@property(nonatomic, readonly)NSString* totalAmount;

/**
 * @brief The amount of bonus coins issued upon purchase of the product
 */
@property(nonatomic, readonly)NSString* points;

/**
 * @brief A method which initiates a http get request for the image in indicated in the iconURL field
 * @param block A block which will be called with either the image downloaded from the address specified in iconURL or
 * an NSError instance denoting an error which prevented the download from occuring.
 */
- (void)loadIconWithBlock:(void(^)(UIImage* image, NSError* error))block;

/**
 * @brief A method to cancel the http get request initiated with loadIconWithBlock:
 */
- (void)cancelIconLoad;
@end
