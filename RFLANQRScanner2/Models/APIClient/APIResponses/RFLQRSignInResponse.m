//
//  RFLQRSignInResponse.m
//  RFLANQRScanner2
//
//  Created by Tim Oliver on 11/4/18.
//  Copyright © 2018 RFLAN. All rights reserved.
//

#import "RFLQRSignInResponse.h"

@implementation RFLQRSignInResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"status": @"status",
             @"error": @"error",
             @"hasPaid": @"paid",
             @"user": @"user",
             @"ticketID": @"ticket_id",
             @"signedInAttendeeCount": @"signedin",
             @"totalAttendeeCount": @"signedup"
             };
}

@end
