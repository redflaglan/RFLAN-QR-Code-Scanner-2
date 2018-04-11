//
//  RFLAudioFeedback.h
//  RFLANQRScanner2
//
//  Created by Tim Oliver on 12/4/18.
//  Copyright © 2018 RFLAN. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RFLAudioFeedbackType) {
    RFLAudioFeedbackTypeBeep,
    RFLAudioFeedbackTypeSuccess,
    RFLAudioFeedbackTypeFail,
    RFLAudioFeedbackTypeUnsure
};

@interface RFLAudioFeedback : NSObject

@property (nonatomic, assign) BOOL cenaMode;

- (void)playAlertWithType:(RFLAudioFeedbackType)type;

@end
