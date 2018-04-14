//
//  RFLQRSignInRequest.h
//  RFLANQRScanner2
//
//  Created by Tim Oliver on 11/4/18.
//  Copyright © 2018 RFLAN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface RFLQRSignInRequest : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *qrCodeValue;

- (instancetype)initWithQRCodeValue:(NSString *)qrCode password:(NSString *)password;

@end
