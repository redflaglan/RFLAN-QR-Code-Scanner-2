//
//  RFLQRPassResponse.h
//  RFLANQRScanner2
//
//  Created by Tim Oliver on 11/4/18.
//  Copyright © 2018 RFLAN. All rights reserved.
//

#import "MTLModel.h"

@interface RFLQRPassResponse : MTLModel

@property (nonatomic, assign) NSInteger status;
@property (nonatomic, copy) NSString *error;
@property (nonatomic, copy) NSString *result;
@property (nonatomic, copy) NSString *passSerialNumber;
@property (nonatomic, copy) NSString *ticketID;

@end
