//
//  RFLQRPassRequest.m
//  RFLANQRScanner2
//
//  Created by Tim Oliver on 11/4/18.
//  Copyright © 2018 RFLAN. All rights reserved.
//

#import "RFLQRPassRequest.h"

@implementation RFLQRPassRequest

- (instancetype)initWithQRCode:(NSString *)qrCode ticketID:(NSInteger)ticketID password:(NSString *)password
{
    if (self = [super init]) {
        _qrCodeValue = qrCode;
        _ticketID = ticketID;
        _password = password;
    }
    
    return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"password": @"password",
             @"qrCodeValue": @"qrcode",
             @"ticketID": @"ticket_id"
             };
}

@end
