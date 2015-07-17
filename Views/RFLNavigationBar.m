//
//  ICNavigationBar.m
//  icomics
//
//  Created by Tim Oliver on 7/02/2014.
//  Copyright (c) 2014 Timothy Oliver. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "RFLNavigationBar.h"

/* Navigation Bar Implementation */
@interface RFLNavigationBar ()
@property (nonatomic, strong) UIView *colorView;
@end

@implementation RFLNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.barStyle = UIBarStyleBlack;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //realign the color layer with the background
    self.colorView.frame = ({
        CGRect bounds = self.bounds;
        if ([UIApplication sharedApplication].statusBarHidden == NO)
            bounds.origin.y -= 20.0f;
        bounds.size.height += 20.0f;
        bounds;
    });
}

- (void)setBarTintColor:(UIColor *)barTintColor
{
    if (self.colorView == nil) {
        self.colorView = [[UIView alloc] initWithFrame:(CGRect){0,0,1,44}];
        self.colorView.alpha = 1.0f;
        self.colorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self insertSubview:self.colorView atIndex:1];
    };

    self.colorView.backgroundColor = barTintColor;
}

@end
