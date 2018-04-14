//
//  RFLAppDelegate.m
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

#import "RFLAppDelegate.h"
#import "RFLNavigationBar.h"
#import "RFLToolbar.h"
#import "RFLPrivateCredentials.h"

@implementation RFLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //Set up the settings
    [self setUpSettings];
    
    //Make sure to set the status bar content as white
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    //Make sure any navigation bars created have the red appearance
    [[RFLNavigationBar appearance] setBarTintColor:[UIColor colorWithRed:220.0f/255.0f green:30.0f/255.0f blue:20.0f/255.0f alpha:0.55f]];
    [[RFLNavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    
    //create the UIWindow
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //Create the main navigation controller
    self.navigationController = [[UINavigationController alloc] initWithNavigationBarClass:[RFLNavigationBar class] toolbarClass:[RFLToolbar class]];
    
    //add the scanner view controller to the navigation controller
    self.viewController = [[RFLScannerViewController alloc] init];
    self.navigationController.viewControllers = @[self.viewController];
    
    //attach the navigation controller to the main screen window and make it visible
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)setUpSettings
{
    //Get a list of all saved data to determine what hasn't been saved yet
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *defaultKeys = [[defaults dictionaryRepresentation] allKeys];
    
    //Request URL
    if ([defaultKeys indexOfObject:kSettingsAPIURL] == NSNotFound) {
        [defaults setObject:RFLAN_CREDENTIAL_APIURL forKey:kSettingsAPIURL];
    }
    
    //Password
    if ([defaultKeys indexOfObject:kSettingsPassword] == NSNotFound) {
        [defaults setObject:RFLAN_CREDENTIAL_PASSWORD forKey:kSettingsPassword];
    }
    
    [defaults synchronize];
}

@end
