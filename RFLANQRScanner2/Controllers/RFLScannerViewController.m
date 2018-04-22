//
//  RFLScannerViewController.m
//
//  Copyright 2013-2017 Timothy Oliver, RFLAN. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "RFLScannerViewController.h"
#import "RFLNavigationBar.h"
#import "APLSessionManager.h"
#import "RFLSettingsViewController.h"
#import "RFLToolbar.h"
#import <AFNetworking/AFNetworking.h>
#import "RFLAudioFeedback.h"
#import "RFLAPIClient.h"
#import "RFLQRSignInResponse.h"
#import "RFLQRPassResponse.h"

@interface RFLScannerViewController ()

/* View object to render the camera output */
@property (nonatomic, strong) UIImageView *previewView;

/* Dedicated class that manages the video recording session */
@property (strong, nonatomic) APLSessionManager *sessionManager;

/* Output CALayer to display the output from the camera */
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

/* Timer to periodically poll for new QR code detections */
@property (strong, nonatomic) NSTimer *stepTimer;

/* Timer to show and hide the barcode graphic */
@property (strong, nonatomic) NSTimer *barcodeTimer;

/* CALayer object that is drawn over any QR codes detected */
@property (nonatomic, retain) CALayer *barcodeTargetLayer;

/* Used to track when a barcode is being processed */
@property (nonatomic, strong) AVMetadataMachineReadableCodeObject *scanningBarcode;

/* Used to track the previously scanned barcode, so we don't constantly spam it. */
@property (nonatomic, copy) NSString *previouslyScannedCode;

/* Audio feedback */
@property (nonatomic, strong) RFLAudioFeedback *alertPlayer;

/* API Client */
@property (nonatomic, strong) RFLAPIClient *apiClient;

/* The current ticket that was scanned, pending the pass association */
@property (nonatomic, strong) RFLQRSignInResponse *currentSignInResponse;

@end

@implementation RFLScannerViewController

- (instancetype)init
{
    if (self = [super init]) {
        [self setUp];
    }
    
    return self;
}

- (void)setUp
{
    //set up a timer that periodically polls the session manager to look for barcodes
    self.stepTimer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(triggerTimer) userInfo:nil repeats:YES];
    self.alertPlayer = [[RFLAudioFeedback alloc] init];
    self.sessionManager = [[APLSessionManager alloc] init];
    self.apiClient = [[RFLAPIClient alloc] init];
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.previewView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundImage"]];
    self.previewView.frame = self.view.bounds;
    [self.view addSubview:self.previewView];
}

- (void)viewDidLoad
{
    [self.sessionManager startRunning];
    
    if (self.previewLayer == nil) {
        AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.sessionManager.captureSession];
        [previewLayer setFrame:self.previewView.bounds];
        [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        if ([[previewLayer connection] isVideoOrientationSupported]) {
            [[previewLayer connection] setVideoOrientation:AVCaptureVideoOrientationPortrait];
        }
        [self.previewView.layer addSublayer:previewLayer];
        self.previewView.layer.masksToBounds = YES;
        self.previewLayer = previewLayer;
    }
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    // Configure barcode overlay
	CALayer* barcodeTargetLayer = [[CALayer alloc] init];
	CGRect r = self.view.layer.bounds;
	barcodeTargetLayer.frame = r;
	self.barcodeTargetLayer = barcodeTargetLayer;
	[self.view.layer addSublayer:self.barcodeTargetLayer];
    
    self.navigationItem.leftBarButtonItem   = [[UIBarButtonItem alloc] initWithTitle:@"0/0" style:UIBarButtonItemStylePlain target:self action:@selector(historyButtonTapped:)];
    self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStylePlain target:self action:@selector(settingsButtonTapped:)];
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"RFLANLogoHeader"]];

    //add a tap gesture recognizer to the toolbar
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toolbarTapped:)];
    [self.navigationController.toolbar addGestureRecognizer:tapRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self historyButtonTapped:self.navigationItem.leftBarButtonItem];
    
    BOOL cenaMode = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsCenaMode];
    self.alertPlayer.cenaMode = cenaMode;
    
    NSString *apiURLString = [[NSUserDefaults standardUserDefaults] objectForKey:kSettingsAPIURL];
    self.apiClient.baseURL = [NSURL URLWithString:apiURLString];
    self.apiClient.password = [[NSUserDefaults standardUserDefaults] objectForKey:kSettingsPassword];
}

- (void)handleTap:(UIGestureRecognizer *)recognizer
{
    //clear the previously scanned barcode in case we need to scan it again
    self.previouslyScannedCode = nil;
    
	CGPoint tapPoint = [recognizer locationInView:self.previewView];
	[self focusAtPoint:tapPoint];
	[self exposeAtPoint:tapPoint];
}

- (void)toolbarTapped:(UIGestureRecognizer *)recognizer
{
    //Cancel any active scans
    [self.apiClient cancelCurrentSignInAttempt];
    
    //Clean out previous scan data
    self.previouslyScannedCode = nil;
    self.scanningBarcode = nil;
    self.currentSignInResponse = nil;
    
    //Hide the toolbar
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)historyButtonTapped:(id)sender
{
    [self.apiClient refreshAttendeeCountWithSuccessHandler:^(NSInteger signedIn, NSInteger totalAttendees) {
        NSString *signupText = nil;
        signupText = [NSString stringWithFormat:@"%ld / %ld", (long)signedIn, (long)totalAttendees];
        self.navigationItem.leftBarButtonItem.title = signupText;
    } failure:^(NSError *error) {
        
    }];
}

- (void)settingsButtonTapped:(id)sender
{
    UINavigationController *navController = [[UINavigationController alloc] initWithNavigationBarClass:[RFLNavigationBar class] toolbarClass:nil];
    navController.viewControllers = @[[RFLSettingsViewController new]];
    [self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - Timer Events
- (void)triggerTimer
{
    if (self.scanningBarcode || [self.sessionManager.barcodes count] < 1) {
		return;
    }
	
	@synchronized(self.sessionManager)
    {
		AVMetadataMachineReadableCodeObject *barcode = self.sessionManager.barcodes.firstObject;
        AVMetadataMachineReadableCodeObject *transformedBarcode = (AVMetadataMachineReadableCodeObject*)[self.previewLayer transformedMetadataObjectForMetadataObject:barcode];
        if ([transformedBarcode.stringValue isEqualToString:self.previouslyScannedCode]) {
            return;
        }
        
		// Draw overlay
		[self.barcodeTimer invalidate];
		self.barcodeTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(removeDetectedBarcodeUI) userInfo:nil repeats:NO];
        CGPathRef barcodeBoundary = [self createPathForPoints:transformedBarcode.corners];
        
		[CATransaction begin];
		[CATransaction setDisableActions:YES];
		[self removeDetectedBarcodeUI];
		[self.barcodeTargetLayer addSublayer:[self barcodeOverlayLayerForPath:barcodeBoundary withColor:[[self class] overlayColor]]];
		[CATransaction commit];
		CFRelease(barcodeBoundary);
        
        self.scanningBarcode = transformedBarcode;
        self.previouslyScannedCode = transformedBarcode.stringValue;
        
        if (self.currentSignInResponse == nil) {
            [self sendScanRequestWithBarcode:self.scanningBarcode];
        }
        else {
            [self sendScanRequestForPassAssociationWithQRCode:self.scanningBarcode];
        }
	}
}

#pragma mark - Network Requests
- (void)sendScanRequestWithBarcode:(AVMetadataMachineReadableCodeObject *)barcode
{
    NSString *apiURLString = [[NSUserDefaults standardUserDefaults] objectForKey:kSettingsAPIURL];
    if (apiURLString.length == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"No API URL" message:@"An API URL needs to be set before you can scan QR codes." preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    RFLToolbar *toolbar = (RFLToolbar *)self.navigationController.toolbar;
    
    //play the beep sound and show the loading graphic
    [self.alertPlayer playAlertWithType:RFLAudioFeedbackTypeBeep];
    [toolbar setState:RFLToolbarStatusLoading withMessage:@"Loading... (Tap to Cancel)"];
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    [self.apiClient signInAttendeeWithQRCode:barcode.stringValue success:^(RFLQRSignInResponse *response) {
        [self processSuccessfulSignInResponse:response];
    } failure:^(NSError *error) {
        [self handleUnsuccessfulResponseWithError:error];
        [self resetScanningState];
    }];
}

- (void)processSuccessfulSignInResponse:(RFLQRSignInResponse *)response
{
    RFLToolbar *toolbar = (RFLToolbar *)self.navigationController.toolbar;
    
    //Check the status of the API response
    if (response.status < 1) {
        NSString *errorMessage = response.error;
        if ([errorMessage length] <= 0) {
            errorMessage = @"Unknown error occurred.";
        }
        
        [self.alertPlayer playAlertWithType:RFLAudioFeedbackTypeFail];
        [toolbar setState:RFLToolbarStatusFail withMessage:errorMessage];
        return;
    }
    
    //Check to see if the customer has paid
    if (response.hasPaid == NO)
    {
        [self.alertPlayer playAlertWithType:RFLAudioFeedbackTypeUnsure];
        [toolbar setState:RFLToolbarStatusUnsure withMessage:@"Hasn't paid yet!"];
        return;
    }
    
    // Save the response so we can use it for the pass
    self.currentSignInResponse = response;
    
    //Extract their name from the API data
    RFLQRSignInUser *user  = response.user;
    NSString *alias = user.alias;
    
    NSString *successMessage = nil;
    NSString *customerName = alias;

    if (customerName.length) {
        successMessage = [NSString stringWithFormat:@"Welcome, %@! (Scan Pass Now)", customerName];
    }
    else {
        successMessage = @"Sign-in successful! (Scan Pass Now)";
    }
    
    [self.alertPlayer playAlertWithType:RFLAudioFeedbackTypeSuccess];
    [toolbar setState:RFLToolbarStatusSuccess withMessage:successMessage];
}

- (void)sendScanRequestForPassAssociationWithQRCode:(NSString *)qrCode
{
    RFLToolbar *toolbar = (RFLToolbar *)self.navigationController.toolbar;
    
    //play the beep sound and show the loading graphic
    [self.alertPlayer playAlertWithType:RFLAudioFeedbackTypeBeep];
    [toolbar setState:RFLToolbarStatusLoading withMessage:@"Loading... (Tap to Cancel)"];
    [self.navigationController setToolbarHidden:NO animated:YES];

    __weak typeof(self) weakSelf = self;
    
    id successBlock = ^(RFLQRPassResponse *response) {
        [weakSelf processSuccessfulPassAssociationResponse:response];
    };
    
    id failBlock = ^(NSError *error) {
        [weakSelf handleUnsuccessfulResponseWithError:error];
    };
    
    [self.apiClient associatePassWithQRCode:qrCode toTicketID:self.currentSignInResponse.ticketID
                                    success:successBlock failure:failBlock];
}

- (void)processSuccessfulPassAssociationResponse:(RFLQRPassResponse *)response
{
    RFLToolbar *toolbar = (RFLToolbar *)self.navigationController.toolbar;
    
    //Check the status of the API response
    if (response.status < 1) {
        NSString *errorMessage = response.error;
        if ([errorMessage length] <= 0) {
            errorMessage = @"Unknown error occurred.";
        }
        
        [self.alertPlayer playAlertWithType:RFLAudioFeedbackTypeFail];
        [toolbar setState:RFLToolbarStatusFail withMessage:errorMessage];
        return;
    }
    
    // Clean out the current sign in flag
    self.currentSignInResponse = nil;
    
    [self.alertPlayer playAlertWithType:RFLAudioFeedbackTypeSuccess];
    [toolbar setState:RFLToolbarStatusSuccess withMessage:@"Pass Association Successful!"];
}

- (void)handleUnsuccessfulResponseWithError:(NSError *)error
{
    RFLToolbar *toolbar = (RFLToolbar *)self.navigationController.toolbar;
    [self.alertPlayer playAlertWithType:RFLAudioFeedbackTypeFail];
    [toolbar setState:RFLToolbarStatusFail withMessage:error.localizedDescription];
}

- (void)resetScanningState
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        self.scanningBarcode = nil;
    });
}

#pragma mark - Focus/Exposure
- (void)focusAtPoint:(CGPoint)point
{
    CGPoint convertedFocusPoint = [self.previewLayer captureDevicePointOfInterestForPoint:point];
    [self.sessionManager autoFocusAtPoint:convertedFocusPoint];
}

- (void)exposeAtPoint:(CGPoint)point
{
    CGPoint convertedExposurePoint = [self.previewLayer captureDevicePointOfInterestForPoint:point];
    [self.sessionManager exposeAtPoint:convertedExposurePoint];
}

#pragma mark - Barcode Labelling Methods
- (CGMutablePathRef)createPathForPoints:(NSArray *)points
{
	CGMutablePathRef path = CGPathCreateMutable();
	CGPoint point;
	
	if ([points count] > 0) {
		CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)[points objectAtIndex:0], &point);
		CGPathMoveToPoint(path, nil, point.x, point.y);
		
		int i = 1;
		while (i < [points count]) {
			CGPointMakeWithDictionaryRepresentation((CFDictionaryRef)[points objectAtIndex:i], &point);
			CGPathAddLineToPoint(path, nil, point.x, point.y);
			i++;
		}
		
		CGPathCloseSubpath(path);
	}
	
	return path;
}

- (void)removeDetectedBarcodeUI
{
	[self removeAllSublayersFromLayer:self.barcodeTargetLayer];
}

- (CAShapeLayer*)barcodeOverlayLayerForPath:(CGPathRef)path withColor:(UIColor*)color
{
	CAShapeLayer *maskLayer = [CAShapeLayer layer];
	
	[maskLayer setPath:path];
	[maskLayer setLineJoin:kCALineJoinRound];
	[maskLayer setLineWidth:2.0];
	[maskLayer setStrokeColor:[color CGColor]];
	[maskLayer setFillColor:[[color colorWithAlphaComponent:0.20] CGColor]];
	
	return maskLayer;
}

- (void)removeAllSublayersFromLayer:(CALayer *)layer
{
	if (layer) {
		NSArray* sublayers = [[layer sublayers] copy];
		for (CALayer* l in sublayers) {
			[l removeFromSuperlayer];
		}
	}
}

+ (UIColor *)overlayColor
{
    static UIColor* color = nil;
    
    if (color == nil) {
        color = [UIColor greenColor];
    }
	
    return color;
}

@end
