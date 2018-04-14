//
//  RFLAPIClient.h
//  RFLANQRScanner2
//
//  Created by Tim Oliver on 14/4/18.
//  Copyright © 2018 RFLAN. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RFLQRSignInResponse;

@interface RFLAPIClient : NSObject

@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSURL *baseURL;

@property (nonatomic, readonly) BOOL isSigningInUser;
@property (nonatomic, readonly) BOOL isCheckingUserCount;

- (instancetype)initWithAPIURL:(NSString *)APIURL password:(NSString *)password;

- (void)signInAttendeeWithQRCode:(NSString *)qrCode
                         success:(void (^)(RFLQRSignInResponse *))successHandler
                         failure:(void (^)(NSError *))failHandler;

- (void)cancelCurrentSignInAttempt;

- (void)refreshAttendeeCountWithSuccessHandler:(void (^)(NSInteger, NSInteger))successHandler
                                       failure:(void (^)(NSError *))failHandler;

@end
