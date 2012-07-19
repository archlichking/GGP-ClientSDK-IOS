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
 * @file GreeWallet+ExternalUISupport.h
 * GreeWallet ExternalUISupport Category
 */

#import "GreeWallet.h"

@class GreeWalletProduct;

/**
 * @brief Notification which is sent when the product list has been updated. 
 */
extern NSString *const GreeWalletUpdatedNotification;

/**
 * @brief Class extension with low level APIs which are intended for use in providing a custom UI for purchasing Gree
 * Coin bundles
 * 
 * This class extension adds 3 API calls which may be used to provide a custom implementation of the Gree Coin purchase
 * UI.
 * The first provides methods for querying the current user's Gree Coin balance. The second retrieves the coin bundles
 * defined for purchase within the application. The third allows for the purchase of a bundle.
 */
@interface GreeWallet (ExteriorUISupport)

/**
 * @brief Block prototype which receives the balance amount on a successful wallet balance query
 * @param balance Numeric value which represents the amount of coins in the current users wallet.
 * @param error An NSError with an error code and localized description. nil if the request was successfully loaded.
 * @see loadBalance:
 */
typedef void (^GreeWalletBalanceLoadBlock)(unsigned long long balance, NSError* error);

/**
 * @brief Block prototype which receives an NSArray instance containing Gree currency products available to the
 * application
 * @param products An NSArray of NSDictionaries which contain the product data. Dictionary keys and helper methods
 * are defined in GreeWalletProduct.h
 * @param error An NSError with an error code and localized description. nil if the request was successfully loaded.
 * @see loadProducts:
 */
typedef void (^GreeWalletProductsLoadBlock)(NSArray* products, NSError* error);

/**
 * @brief Block prototype called when a purchase of a GreeWalletProduct is successful
 * @param product An GreeWalletProduct instance with the product information of the product which was purchased.
 * @param error An NSError with an error code and localized description. nil if the purchase was successful.
 * @see purchaseProduct:block:
 */
typedef void (^GreeWalletPurchaseBlock)(GreeWalletProduct* product, NSError* error);

/**
 * @brief Method to return the coin balance of the current user
 * Call this method to asynchronously retrieve the coin balance of the current user. On a successful request the
 * block will be invoked with current users coin balance and a nil value for error. If there is an error the block
 * is invoked with 0 blance and error will contain an NSError instance describing the error condition.
 * @param block A block with the signature defined by GreeWalletBalanceLoadBlock. Must not be nil.
 * @return BOOL value NO if the parameters were not specified correctly. YES otherwise.
 */
+ (BOOL)loadBalanceWithBlock:(GreeWalletBalanceLoadBlock)block;

/**
 * @brief Method to return the Coin Bundles available to the application
 * Call this method to asynchronously retrieve the coin bundles defined for the current application. On a successful
 * request the block will be invoked with an NSArray containing instances of NSDictorary each of which describe a
 * purchasable Coin Bundle. If there is an error the block will be invoked with nil for the value of products and error
 * will contain a pointer to an NSArray instance describing the error condition.
 * @param block A block with the signature defined by GreeWalletProductsLoadBlock. Must not be nil.
 * @return BOOL value NO if the parameters were not specified correctly. YES otherwise.
 */
+ (BOOL)loadProductsWithBlock:(GreeWalletProductsLoadBlock)block;

/**
 * @brief Method to purchase a coin bundle
 * Call this method to asynchronously purchase a coin bundle product. The productId parameter specifies which product to
 * purchase. On a successful request the block is invoked with product pointing to an NSDictionary with the purchased
 * products product data and nil as error. If there is an error the block is invoked with nil as product and error
 * pointing to a NSError instance describing the error condition.
 * @param productId An NSString with a string from the product_id key of a products data dictionary. Must not be nil.
 * @param block A block with the signature defined by GreeWalletPurchaseBlock. Must not be nil.
 * @return BOOL value NO if the parameters were not specified correctly. YES otherwise.
 */
+ (BOOL)purchaseProduct:(NSString*)productId withBlock:(GreeWalletPurchaseBlock)block;

@end

