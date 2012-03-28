//
//  StepResult.h
//  OFQAAPI
//
//  Created by lei zhu on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StepResult : NSObject{
    @private
    int result;
    NSString* comment;
}

@property int result;
@property (retain) NSString* comment;

- (id)initWithResult:(int) r 
             comment:(NSString*) c;


@end
