//
//  RFLAttendeeCountResponse.m
//  RFLANQRScanner2
//
//  Created by Tim Oliver on 14/4/18.
//  Copyright © 2018 RFLAN. All rights reserved.
//

#import "RFLAttendeeCountResponse.h"

@implementation RFLAttendeeCountResponse

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"signedInAttendeeCount": @"signedin",
             @"totalAttendeeCount": @"signedup"
            };
}

@end
