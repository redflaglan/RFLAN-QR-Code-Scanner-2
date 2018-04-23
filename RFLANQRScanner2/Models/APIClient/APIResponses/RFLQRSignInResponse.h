//
//  RFLQRSignInResponse.h
//  RFLANQRScanner2
//
//  Created by Tim Oliver on 11/4/18.
//  Copyright © 2018 RFLAN. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "RFLQRSignInUser.h"

@interface RFLQRSignInResponse : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) NSInteger status;
@property (nonatomic, copy) NSString *error;
@property (nonatomic, assign) BOOL hasPaid;
@property (nonatomic, strong) RFLQRSignInUser *user;
@property (nonatomic, assign) NSInteger ticketID;
@property (nonatomic, assign) NSInteger signedInAttendeeCount;
@property (nonatomic, assign) NSInteger totalAttendeeCount;

@end
