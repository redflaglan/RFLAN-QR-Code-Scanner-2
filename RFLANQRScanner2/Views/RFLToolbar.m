//
//  RFLToolbar.m
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

#import "RFLToolbar.h"

@interface RFLToolbar ()

@property (nonatomic, strong) UIImage *successImage;
@property (nonatomic, strong) UIImage *failImage;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *labelView;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation RFLToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.successImage   = [UIImage imageNamed:@"SuccessIcon"];
        self.failImage      = [UIImage imageNamed:@"FailIcon"];
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicator.center = CGPointMake(20, 20);
        self.activityIndicator.hidesWhenStopped = YES;
        [self addSubview:self.activityIndicator];
        
        self.imageView = [[UIImageView alloc] init];
        [self addSubview:self.imageView];
        
        self.labelView = [[UILabel alloc] initWithFrame:CGRectMake(36,0,320,44)];
        [self addSubview:self.labelView];
    }
    return self;
}

- (void)setState:(RFLToolbarStatus)status withMessage:(NSString *)message
{
    self.labelView.text = message;
    
    [self.activityIndicator stopAnimating];
    self.imageView.hidden = YES;
    
    if (status ==  RFLToolbarStatusLoading)
    {
        self.labelView.textColor = [UIColor colorWithWhite:0.3f alpha:1.0f];
        [self.activityIndicator startAnimating];
    }
    else if (status == RFLToolbarStatusFail)
    {
        self.labelView.textColor = [UIColor colorWithRed:170.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
        self.imageView.image = self.failImage;
        self.imageView.hidden = NO;
        self.imageView.frame = (CGRect){CGPointMake(8, 11), self.failImage.size};
    }
    else if (status == RFLToolbarStatusSuccess)
    {
        self.labelView.textColor = [UIColor colorWithRed:0.0f/255.0f green:170.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
        self.imageView.image = self.successImage;
        self.imageView.hidden = NO;
        self.imageView.frame = (CGRect){CGPointMake(8, 11), self.successImage.size};
    }
    else if (status == RFLToolbarStatusUnsure)
    {
        self.labelView.textColor = [UIColor colorWithRed:208.0f/255.0f green:128.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
        [self.activityIndicator startAnimating];
    }
}

@end
