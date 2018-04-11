//
//  RFLAudioFeedback.m
//  RFLANQRScanner2
//
//  Created by Tim Oliver on 12/4/18.
//  Copyright © 2018 RFLAN. All rights reserved.
//

#import "RFLAudioFeedback.h"
#import <AudioToolbox/AudioToolbox.h>

@interface RFLAudioFeedback ()

/* Sound files to play at various states */
@property (nonatomic, assign) SystemSoundID beepSound;
@property (nonatomic, assign) SystemSoundID successSound;
@property (nonatomic, assign) SystemSoundID unsureSound;
@property (nonatomic, assign) SystemSoundID failSound;

@end

@implementation RFLAudioFeedback

- (instancetype)init
{
    if (self = [super init]) {
        _successSound   = [self soundNamed:@"Success.wav"];
        _unsureSound    = [self soundNamed:@"Unsure.wav"];
        _failSound      = [self soundNamed:@"Fail.wav"];
        _beepSound      = [self soundNamed:@"Beep.wav"];
    }
    
    return self;
}

- (void)dealloc
{
    //Dispose of the system audio sounds
    AudioServicesDisposeSystemSoundID(self.successSound);
    AudioServicesDisposeSystemSoundID(self.failSound);
    AudioServicesDisposeSystemSoundID(self.unsureSound);
    AudioServicesDisposeSystemSoundID(self.beepSound);
}

- (void)playAlertWithType:(RFLAudioFeedbackType)type
{
    SystemSoundID soundID = 0;
    
    switch (type) {
        case RFLAudioFeedbackTypeBeep: soundID = self.beepSound; break;
        case RFLAudioFeedbackTypeFail: soundID = self.failSound; break;
        case RFLAudioFeedbackTypeUnsure: soundID = self.unsureSound; break;
        case RFLAudioFeedbackTypeSuccess: soundID = self.successSound; break;
    }
    
    AudioServicesPlaySystemSound(soundID);
}

- (void)setCenaMode:(BOOL)cenaMode
{
    if (_cenaMode == cenaMode) { return; }
    
    if (self.successSound > 0) {
        AudioServicesDisposeSystemSoundID(self.successSound);
    }

    if (cenaMode) {
        self.successSound = [self soundNamed:@"Success2.wav"];
    }
    else {
        self.successSound = [self soundNamed:@"Success.wav"];
    }
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

@end
