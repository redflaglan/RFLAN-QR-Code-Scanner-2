//
//  RFLScannerViewController.m
//
//  Copyright 2013 Timothy Oliver, RFLAN. All rights reserved.
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
#import "AFNetworking.h"

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

/* Operation manager that tracks requests made to the API service */
@property (nonatomic,strong) AFHTTPRequestOperationManager *requestOperationManager;

/* Sound files to play at various states */
@property (nonatomic, assign) SystemSoundID beepSound;
@property (nonatomic, assign) SystemSoundID successSound;
@property (nonatomic, assign) SystemSoundID unsureSound;
@property (nonatomic, assign) SystemSoundID failSound;

- (SystemSoundID)soundNamed:(NSString *)soundName;
- (void)historyButtonTapped:(id)sender;
- (void)settingsButtonTapped:(id)sender;
- (void)handleTap:(UIGestureRecognizer *)recognizer;
- (void)focusAtPoint:(CGPoint)point;
- (void)exposeAtPoint:(CGPoint)point;
- (void)triggerTimer;
- (void)removeDetectedBarcodeUI;
- (CAShapeLayer*)barcodeOverlayLayerForPath:(CGPathRef)path withColor:(UIColor*)color;
- (void)removeAllSublayersFromLayer:(CALayer *)layer;
- (CGMutablePathRef)createPathForPoints:(NSArray *)points;
+ (UIColor *)overlayColor;
- (void)sendScanRequestWithBarcode:(AVMetadataMachineReadableCodeObject *)barcode;
- (void)processSuccessfulResponse:(id)responseObject;
- (void)handleUnsuccessfulResponseWithError:(NSError *)error;
- (void)toolbarTapped:(UIGestureRecognizer *)recognizer;
- (void)resetScanningState;

@end

@implementation RFLScannerViewController

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.previewView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundImage"]];
    self.previewView.frame = self.view.bounds;
    [self.view addSubview:self.previewView];
    
    self.successSound   = [self soundNamed:@"Success.wav"];
    self.unsureSound    = [self soundNamed:@"Unsure.wav"];
    self.failSound      = [self soundNamed:@"Fail.wav"];
    self.beepSound      = [self soundNamed:@"Beep.wav"];
}

- (void)viewDidLoad
{
    self.sessionManager = [[APLSessionManager alloc] init];
	[self.sessionManager startRunning];
    
	AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.sessionManager.captureSession];
	[previewLayer setFrame:self.previewView.bounds];
	[previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
	if ([[previewLayer connection] isVideoOrientationSupported]) {
		[[previewLayer connection] setVideoOrientation:AVCaptureVideoOrientationPortrait];
	}
	[self.previewView.layer addSublayer:previewLayer];
	[self.previewView.layer setMasksToBounds:YES];
	[self setPreviewLayer:previewLayer];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    // Configure barcode overlay
	CALayer* barcodeTargetLayer = [[CALayer alloc] init];
	CGRect r = self.view.layer.bounds;
	barcodeTargetLayer.frame = r;
	self.barcodeTargetLayer = barcodeTargetLayer;
	[self.view.layer addSublayer:self.barcodeTargetLayer];
    
    //set up a timer that periodically polls the session manager to look for barcodes
    self.stepTimer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(triggerTimer) userInfo:nil repeats:YES];

    self.navigationItem.leftBarButtonItem   = [[UIBarButtonItem alloc] initWithTitle:@"0" style:UIBarButtonItemStylePlain target:self action:@selector(historyButtonTapped:)];
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
}

- (void)dealloc
{
    //Dispose of the system audio sounds
    AudioServicesDisposeSystemSoundID(self.successSound);
    AudioServicesDisposeSystemSoundID(self.failSound);
    AudioServicesDisposeSystemSoundID(self.unsureSound);
    AudioServicesDisposeSystemSoundID(self.beepSound);
}

- (SystemSoundID)soundNamed:(NSString *)soundName
{
    SystemSoundID sound = 0;
    
    NSURL *soundURL = [NSURL fileURLWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:soundName]];
    if (soundURL != nil) {
        OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundURL, &sound);
        if (error != kAudioServicesNoError) {
            NSLog(@"Problem loading Sound");
        }
    }
    
    return sound;
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
    if (self.requestOperationManager.operationQueue.operationCount > 0)
        [self.requestOperationManager.operationQueue cancelAllOperations];
    
    self.previouslyScannedCode = nil;
    self.scanningBarcode = nil;
    
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)historyButtonTapped:(id)sender
{
    NSString *apiURL = [[NSUserDefaults standardUserDefaults] objectForKey:kSettingsAPIURL];
    if ([apiURL length] == 0)
        return;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"qrcode"] = @"";
    parameters[@"password"] = [[NSUserDefaults standardUserDefaults] objectForKey: kSettingsPassword];
    
    id successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *signups = (NSDictionary *)responseObject;
        
        NSString *signupText = nil;
        NSNumber *signedIn = signups[@"signedin"];
        NSNumber *totalSignups = signups[@"signedup"];
        
        if ([signedIn intValue] >= 0  && [totalSignups intValue] > 0)
            signupText = [NSString stringWithFormat:@"%d / %d", signedIn.intValue, totalSignups.intValue];
        
        self.navigationItem.leftBarButtonItem.title = signupText;
    };
    
    [[AFHTTPRequestOperationManager manager] POST:apiURL parameters:parameters success:successBlock failure:nil];
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
	if (self.scanningBarcode || [self.sessionManager.barcodes count] < 1)
		return;
	
	@synchronized(self.sessionManager)
    {
		AVMetadataMachineReadableCodeObject *barcode = self.sessionManager.barcodes.firstObject;
        AVMetadataMachineReadableCodeObject *transformedBarcode = (AVMetadataMachineReadableCodeObject*)[self.previewLayer transformedMetadataObjectForMetadataObject:barcode];
		if ([transformedBarcode.stringValue isEqualToString:self.previouslyScannedCode])
            return;
        
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
        [self sendScanRequestWithBarcode:self.scanningBarcode];
	}
}

#pragma mark - Network Requests
- (void)sendScanRequestWithBarcode:(AVMetadataMachineReadableCodeObject *)barcode
{
    RFLToolbar *toolbar = (RFLToolbar *)self.navigationController.toolbar;
    
    //create the request manager if this is the first time
    if (self.requestOperationManager == nil)
        self.requestOperationManager = [AFHTTPRequestOperationManager manager];
    
    //play the beep sound and show the loading graphic
    AudioServicesPlaySystemSound(self.beepSound);
    [toolbar setState:RFLToolbarStatusLoading withMessage:@"Loading... (Tap to Cancel)"];
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    //set up the request parameters
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"qrcode"] = barcode.stringValue;
    parameters[@"password"] = [[NSUserDefaults standardUserDefaults] objectForKey:kSettingsPassword];
    
    id successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        [self processSuccessfulResponse:responseObject];
        [self resetScanningState];
    };
    
    id failBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleUnsuccessfulResponseWithError:error];
        [self resetScanningState];
    };
    
    [self.requestOperationManager POST:[[NSUserDefaults standardUserDefaults] objectForKey:kSettingsAPIURL] parameters:parameters success:successBlock failure:failBlock];
}

- (void)processSuccessfulResponse:(id)responseObject
{
    RFLToolbar *toolbar = (RFLToolbar *)self.navigationController.toolbar;
    NSDictionary *json = (NSDictionary *)responseObject;
    
    //Check the status of the API response
    if ([json[@"status"] intValue] < 1)
    {
        NSString *errorMessage = (NSString *)[json objectForKey:@"error"];
        if ([errorMessage length] <= 0)
            errorMessage = @"Unknown error occurred.";
        
        AudioServicesPlaySystemSound(self.failSound);
        [toolbar setState:RFLToolbarStatusFail withMessage:errorMessage];
        return;
    }
    
    //Check to see if the customer has paid
    if ([json[@"paid"] intValue] <= 0)
    {
        AudioServicesPlaySystemSound(self.unsureSound);
        [toolbar setState:RFLToolbarStatusUnsure withMessage:@"Hasn't paid yet!"];
        return;
    }
    
    //Extract their name from the API data
    NSDictionary *user  = json[@"user"][@"user"];
    NSString *firstName = user[@"first_name"];
    NSString *lastName  = user[@"last_name"];
    
    NSString *successMessage = nil;
    if ([firstName length])
    {
        NSString *successMessage = firstName;
        if ([lastName length] > 0)
            successMessage = [successMessage stringByAppendingFormat:@" %@", lastName];
        
        successMessage = [successMessage stringByAppendingString:@"!"];
        
    }
    else {
        successMessage = @"Sign-in successful!";
    }
    
    AudioServicesPlaySystemSound(self.successSound);
    [toolbar setState:RFLToolbarStatusSuccess withMessage:successMessage];
}

- (void)handleUnsuccessfulResponseWithError:(NSError *)error
{
    RFLToolbar *toolbar = (RFLToolbar *)self.navigationController.toolbar;
    
    AudioServicesPlaySystemSound(self.failSound);
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
