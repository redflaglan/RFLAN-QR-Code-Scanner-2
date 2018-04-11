//
//  RFLQRPassResponse.m
//  RFLANQRScanner2
//
//  Created by Tim Oliver on 11/4/18.
//  Copyright © 2018 RFLAN. All rights reserved.
//

#import "RFLQRPassResponse.h"

@implementation RFLQRPassResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"status": @"status",
             @"error": @"error",
             @"result": @"result",
             @"passSerialNumber": @"pass_sn",
             @"ticketID": @"ticket_id",
             };
}

@end
