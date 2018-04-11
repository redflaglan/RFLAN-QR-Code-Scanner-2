//
//  RFLRFLQRSignInUser.m
//  RFLANQRScanner2
//
//  Created by Tim Oliver on 11/4/18.
//  Copyright © 2018 RFLAN. All rights reserved.
//

#import "RFLRFLQRSignInUser.h"

@implementation RFLRFLQRSignInUser

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"userID": @"id",
             @"alias": @"alias",
             @"firstName": @"first_name",
             @"lastName": @"last_name",
             };
}

@end
