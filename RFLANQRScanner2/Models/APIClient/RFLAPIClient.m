//
//  RFLAPIClient.m
//  RFLANQRScanner2
//
//  Created by Tim Oliver on 14/4/18.
//  Copyright © 2018 RFLAN. All rights reserved.
//

#import "RFLAPIClient.h"
#import <AFNetworking/AFNetworking.h>

#import "RFLQRSignInRequest.h"
#import "RFLQRSignInResponse.h"

#import "RFLQRPassRequest.h"
#import "RFLQRPassResponse.h"

@interface RFLAPIClient ()

/* The password for the API access */
@property (nonatomic, copy) NSString *password;

/* The base URL for all endpoints */
@property (nonatomic, strong) NSURL *baseURL;

/* Data task for tracking requests to validate QR codes */
@property (nonatomic, strong) NSURLSessionDataTask *codeScanTask;

/* Data task for assigning ticket ID to pass */
@property (nonatomic, strong) NSURLSessionDataTask *qrPassTask;

/* Data task for tracking requests to the attendee count API */
@property (nonatomic, strong) NSURLSessionDataTask *attendeeRequestTask;

/* AFNetworking Session Manager */
@property (nonatomic, strong) AFHTTPSessionManager *httpSessionManager;

@end

@implementation RFLAPIClient

#pragma mark - Creation -

- (instancetype)initWithAPIURL:(NSString *)APIURL password:(NSString *)password
{
    if (self = [super init]) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _httpSessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
        _baseURL = [NSURL URLWithString:APIURL];
        _password = password;
    }
    
    return self;
}

#pragma mark - Sign-in -

- (void)signInAttendeeWithQRCode:(NSString *)qrCode
                         success:(void (^)(RFLQRSignInUser *))successHandler
                         failure:(void (^)(NSError *))failHandler
{
    if (self.isSigningInUser) { return; }
    
    // Create the parameters object
    RFLQRSignInRequest *requestParameters = [[RFLQRSignInRequest alloc] initWithQRCodeValue:qrCode password:self.password];
    NSDictionary *parametersDict = requestParameters.dictionaryValue;
    
    // Craft the endpoint URL
    NSURL *url = [self.baseURL URLByAppendingPathComponent:@"signin"];
    
    // Success block when the request succeeds
    id requestSuccessBlock = ^(NSURLSessionDataTask *task, id responseObject) {
        RFLQRSignInResponse *response = [[RFLQRSignInResponse alloc] initWithDictionary:responseObject error:nil];
        [self performPassRequestWithQRCode:qrCode scanResponse:response success:successHandler failure:failHandler];
        self.codeScanTask = nil;
    };

    // Fail block if an error occurs
    id requestFailBlock = ^(NSURLSessionDataTask *task, NSError *error) {
        if (failHandler) { failHandler(error); }
        self.codeScanTask = nil;
    };
    
    // Create the request
    self.codeScanTask = [self.httpSessionManager POST:url.absoluteString
                                           parameters:parametersDict
                                             progress:nil
                                              success:requestSuccessBlock
                                              failure:requestFailBlock];
    // Kick off the request
    [self.codeScanTask resume];
}

- (void)performPassRequestWithQRCode:(NSString *)qrCode
                        scanResponse:(RFLQRSignInResponse *)scanResponse
                            success:(void (^)(RFLQRSignInUser *))successHandler
                            failure:(void (^)(NSError *))failHandler
{
    RFLQRPassRequest *requestParameters = [[RFLQRPassRequest alloc] initWithQRCode:qrCode ticketID:scanResponse.ticketID password:self.password];
    NSDictionary *parametersDict = requestParameters.dictionaryValue;
    
    // Craft the endpoint URL
    NSURL *url = [self.baseURL URLByAppendingPathComponent:@"scanpass"];
    
    id requestSuccessBlock = ^(NSURLSessionDataTask *task, id responseObject) {
        if (successHandler) { successHandler(scanResponse.user); }
        self.qrPassTask = nil;
    };
    
    // Fail block if an error occurs
    id requestFailBlock = ^(NSURLSessionDataTask *task, NSError *error) {
        if (failHandler) { failHandler(error); }
        self.qrPassTask = nil;
    };
    
    // Create the request
    self.qrPassTask = [self.httpSessionManager POST:url.absoluteString
                                           parameters:parametersDict
                                             progress:nil
                                              success:requestSuccessBlock
                                              failure:requestFailBlock];
    // Kick off the request
    [self.qrPassTask resume];
}

#pragma mark - Attendee Count -
- (void)refreshAttendeeCountWithSuccessHandler:(void (^)(NSInteger))successHandler
                                       failure:(void (^)(NSError *))failHandler
{
    
}

@end
