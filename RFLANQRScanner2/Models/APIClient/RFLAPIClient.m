//
//  RFLAPIClient.m
//  RFLANQRScanner2
//
//  Created by Tim Oliver on 14/4/18.
//  Copyright © 2018 RFLAN. All rights reserved.
//

#import "RFLAPIClient.h"
#import <AFNetworking/AFNetworking.h>
#import <Mantle/Mantle.h>

#import "RFLQRSignInRequest.h"
#import "RFLQRSignInResponse.h"

#import "RFLQRPassRequest.h"
#import "RFLQRPassResponse.h"

#import "RFLAttendeeCountResponse.h"

@interface RFLAPIClient ()

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
        _baseURL = [NSURL URLWithString:APIURL];
        _password = password;
        [self setUp];
    }
    
    return self;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self setUp];
    }
    
    return self;
}

- (void)setUp
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    _httpSessionManager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
    _httpSessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
}

#pragma mark - Sign-in -

- (void)signInAttendeeWithQRCode:(NSString *)qrCode
                         success:(void (^)(RFLQRSignInResponse *))successHandler
                         failure:(void (^)(NSError *))failHandler
{
    if (self.isSigningInUser || self.baseURL.absoluteString.length == 0) { return; }
    
    // Create the parameters object
    RFLQRSignInRequest *requestParameters = [[RFLQRSignInRequest alloc] initWithQRCodeValue:qrCode password:self.password];
    NSDictionary *parametersDict = [MTLJSONAdapter JSONDictionaryFromModel:requestParameters error:nil];
    
    // Craft the endpoint URL
    NSURL *url = [self.baseURL URLByAppendingPathComponent:@"qrsignin"];
    
    // Success block when the request succeeds
    id requestSuccessBlock = ^(NSURLSessionDataTask *task, id responseObject) {
        NSError *error = nil;
        RFLQRSignInResponse *response = [MTLJSONAdapter modelOfClass:RFLQRSignInResponse.class
                                                  fromJSONDictionary:responseObject error:&error];
        if (successHandler) { successHandler(response); }
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

- (void)associatePassWithQRCode:(NSString *)qrCode
                     toTicketID:(NSInteger)ticketID
                        success:(void (^)(RFLQRPassResponse *))successHandler
                        failure:(void (^)(NSError *))failHandler
{
    RFLQRPassRequest *requestParameters = [[RFLQRPassRequest alloc] initWithQRCode:qrCode ticketID:ticketID password:self.password];
    NSDictionary *parametersDict = [MTLJSONAdapter JSONDictionaryFromModel:requestParameters error:nil];
    
    // Craft the endpoint URL
    NSURL *url = [self.baseURL URLByAppendingPathComponent:@"qrpass"];
    
    id requestSuccessBlock = ^(NSURLSessionDataTask *task, id responseObject) {
        RFLQRPassResponse *response = [MTLJSONAdapter modelOfClass:RFLQRPassResponse.class
                                                fromJSONDictionary:responseObject error:nil];
        if (successHandler) { successHandler(response); }
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

- (void)cancelCurrentSignInAttempt
{
    if (self.qrPassTask) {
        [self.qrPassTask cancel];
        self.qrPassTask = nil;
    }
    
    if (self.codeScanTask) {
        [self.codeScanTask cancel];
        self.codeScanTask = nil;
    }
}

#pragma mark - Attendee Count -
- (void)refreshAttendeeCountWithSuccessHandler:(void (^)(NSInteger, NSInteger))successHandler
                                       failure:(void (^)(NSError *))failHandler
{
    if (self.attendeeRequestTask || self.baseURL.absoluteString.length == 0) { return; }
    
    // Craft the endpoint URL
    NSURL *url = [self.baseURL URLByAppendingPathComponent:@"attendance"];
    
    // Success block when the request succeeds
    id requestSuccessBlock = ^(NSURLSessionDataTask *task, id responseObject) {
        RFLAttendeeCountResponse *response = [MTLJSONAdapter modelOfClass:RFLAttendeeCountResponse.class
                                                       fromJSONDictionary:responseObject error:nil];
        if (successHandler) {
            successHandler(response.signedInAttendeeCount, response.totalAttendeeCount);
        }
        self.attendeeRequestTask = nil;
    };
    
    // Fail block if an error occurs
    id requestFailBlock = ^(NSURLSessionDataTask *task, NSError *error) {
        if (failHandler) { failHandler(error); }
        self.attendeeRequestTask = nil;
    };
    
    // Create the request
    self.attendeeRequestTask = [self.httpSessionManager POST:url.absoluteString
                                                  parameters:@{@"password": self.password}
                                             progress:nil
                                              success:requestSuccessBlock
                                              failure:requestFailBlock];
    // Kick off the request
    [self.attendeeRequestTask resume];
}

@end
