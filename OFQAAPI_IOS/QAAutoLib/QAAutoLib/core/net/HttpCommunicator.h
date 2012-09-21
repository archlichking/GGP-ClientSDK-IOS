//
//  HttpCommunicator.h
//  QAAutoLib
//
//  Created by zhu lei on 9/19/12.
//  Copyright (c) 2012 OFQA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpCommunicator : NSObject

- (id) doHttpPost:(NSString*)url
           params:(NSDictionary*)params;

- (id) doHttpGet:(NSString*)url
          params:(NSDictionary*)params;

@end
