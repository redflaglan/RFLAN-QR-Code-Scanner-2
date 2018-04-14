//
//  RFLAPIClient.h
//  RFLANQRScanner2
//
//  Created by Tim Oliver on 14/4/18.
//  Copyright © 2018 RFLAN. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RFLQRSignInUser;

@interface RFLAPIClient : NSObject

@property (nonatomic, readonly) BOOL isSigningInUser;
@property (nonatomic, readonly) BOOL isCheckingUserCount;

- (instancetype)initWithAPIURL:(NSString *)APIURL password:(NSString *)password;

- (void)signInAttendeeWithQRCode:(NSString *)qrCode
                         success:(void (^)(RFLQRSignInUser *))successHandler
                         failure:(void (^)(NSError *))failHandler;

- (void)refreshAttendeeCountWithSuccessHandler:(void (^)(NSInteger))successHandler
                                       failure:(void (^)(NSError *))failHandler;

@end
