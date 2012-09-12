//
//  NetCommunicator.h
//  OFQAAPI
//
//  Created by lei zhu on 2/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NetCommunicator <NSObject>

@required
- (id) doHttpPost:(NSString*) url 
              params:(NSDictionary*) params;
- (id) doHttpGet:(NSString*) url;

@end
