//
//  OFQAAPI.h
//  OFQAAPI
//
//  Created by lei zhu on 2/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TcmCommunicator.h"

@interface OFQAAPI : NSObject{
    TcmCommunicator* t;
}

@property (retain) TcmCommunicator* t;

@end
