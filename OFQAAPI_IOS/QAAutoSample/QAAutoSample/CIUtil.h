//
//  CIUtil.h
//  QAAutoSample
//
//  Created by zhu lei on 9/14/12.
//  Copyright (c) 2012 OFQA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CIUtil : NSObject

+ (NSDictionary*) getRunInfoFromUrl:(NSString*) url;

+ (void) generateReport:(NSString*) key
              fromUrl:(NSString*) url;

@end
