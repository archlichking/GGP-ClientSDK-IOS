//
//  QALog.h
//  OFQAAPI
//
//  Created by lei zhu on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define QALog(message,...){                     \
    NSLog([NSString stringWithFormat:@"[QAAuto] => %@", message], ##__VA_ARGS__);              \
}                                               

@interface QALog : NSObject

@end
