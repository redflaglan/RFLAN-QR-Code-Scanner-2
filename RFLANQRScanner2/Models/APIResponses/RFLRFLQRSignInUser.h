//
//  RFLRFLQRSignInUser.h
//  RFLANQRScanner2
//
//  Created by Tim Oliver on 11/4/18.
//  Copyright © 2018 RFLAN. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface RFLRFLQRSignInUser : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) NSInteger userID;
@property (nonatomic, copy) NSString *alias;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;

@end
