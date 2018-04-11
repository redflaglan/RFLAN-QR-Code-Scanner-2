//
//  RFLQRSignInResponse.h
//  RFLANQRScanner2
//
//  Created by Tim Oliver on 11/4/18.
//  Copyright © 2018 RFLAN. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "RFLRFLQRSignInUser.h"

@interface RFLQRSignInResponse : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) NSInteger status;
@property (nonatomic, copy) NSString *error;
@property (nonatomic, assign) BOOL hasPaid;
@property (nonatomic, strong) RFLRFLQRSignInUser *user;
@property (nonatomic, copy) NSString *ticketID;
@property (nonatomic, assign) BOOL isSignedIn;
@property (nonatomic, assign) BOOL isSignedUp;

@end
