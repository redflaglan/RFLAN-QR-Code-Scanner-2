//
//  RFLQRSignInRequest.m
//  RFLANQRScanner2
//
//  Created by Tim Oliver on 11/4/18.
//  Copyright © 2018 RFLAN. All rights reserved.
//

#import "RFLQRSignInRequest.h"

@implementation RFLQRSignInRequest 

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"password": @"password",
             @"qrCodeValue": @"qrcode"
             };
}

@end
