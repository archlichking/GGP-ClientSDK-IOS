//
//  IncentiveStepDefinition.h
//  QAAutoSample
//
//  Created by zhu lei on 10/18/12.
//  Copyright (c) 2012 OFQA. All rights reserved.
//

#import "StepDefinition.h"

@interface IncentiveStepDefinition : StepDefinition

- (void) I_initialize_incentive_with_incentive_type_PARAM:(NSString*) type
                                             _and_message_PARAM:(NSString*) msg;

- (void) I_send_incentive_to_user_of_email_PARAM:(NSString*) emails;

- (void) incentive_target_should_be_PARAMINT:(NSString*) target;

- (void) I_mark_incentive_as_processed;

- (void) I_query_unprocessed_incentives_of_type_PARAM:(NSString*) type;
- (void) unprocessed_incentive_number_should_be_PARAMINT:(NSString*) amount;
- (void) unprocessed_incentives_should_include_incentive_of_message_PARAM:(NSString*) msg;
@end
