//
//  CommandUtil.h
//  OFQAAPI
//
//  Created by lei zhu on 2/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const CommandGiven;
extern NSString* const CommandWhen;
extern NSString* const CommandThen;
extern NSString* const CommandAnd;
extern NSString* const CommandAfter;
extern NSString* const CommandBefore;

extern NSString* const CommandDispatchCommand;

extern enum {
    launchPopup,
    dismissPopup,
    executeJavascriptInPopup,
    executeInPaymentRequestPopup,
    executeInDepositPopup,
    executeInDepositHistoryPopup,
    getWidget,
    hideWidget
} CommandPopup;

@interface CommandUtil : NSObject
@end
