//
//  RFLQRPassRequest.h
//  RFLANQRScanner2
//
//  Created by Tim Oliver on 11/4/18.
//  Copyright © 2018 RFLAN. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface RFLQRPassRequest : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *qrCodeValue;
@property (nonatomic, copy) NSString *ticketID;

@end
