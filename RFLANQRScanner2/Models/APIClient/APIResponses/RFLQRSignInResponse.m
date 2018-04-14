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
<<<<<<< HEAD
             @"ticketID": @"ticket_id"
=======
             @"ticketID": @"ticket_id",
             @"signedInAttendeeCount": @"signedin",
             @"totalAttendeeCount": @"signedup"
>>>>>>> 9dfaf2077aedf055329d513cc33ab257998a74ae
             };
}

@end
