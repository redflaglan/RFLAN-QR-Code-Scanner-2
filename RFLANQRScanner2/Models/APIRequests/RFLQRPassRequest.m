//
//  RFLQRPassRequest.m
//  RFLANQRScanner2
//
//  Created by Tim Oliver on 11/4/18.
//  Copyright © 2018 RFLAN. All rights reserved.
//

#import "RFLQRPassRequest.h"

@implementation RFLQRPassRequest

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"password": @"password",
             @"qrCodeValue": @"qrcode",
             @"ticketID": @"ticket_id"
             };
}

@end
