//
//  RFLSettingsViewController.m
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

#import "RFLSettingsViewController.h"

@interface RFLSettingsViewController () <UITextFieldDelegate>

@property (nonatomic,assign) BOOL contentChanged;
@property (nonatomic,strong) UITextField *textFieldPassword;
@property (nonatomic,strong) UITextField *textFieldAPIURL;
@property (nonatomic,strong) UISwitch *cenaSwitch;

@end

@implementation RFLSettingsViewController

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    self.tableView.cellLayoutMarginsFollowReadableWidth = NO;

    self.textFieldAPIURL = [[UITextField alloc] initWithFrame:CGRectMake(110, 0, 320-110, 44)];
    self.textFieldAPIURL.font = [UIFont systemFontOfSize:15.0f];
    self.textFieldAPIURL.text = [defaults objectForKey:kSettingsAPIURL];
    self.textFieldAPIURL.delegate = self;
    self.textFieldAPIURL.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textFieldAPIURL.returnKeyType = UIReturnKeyDone;
    
    self.textFieldPassword = [[UITextField alloc] initWithFrame:CGRectMake(110, 0, 320-110, 44)];
    self.textFieldPassword.font = [UIFont systemFontOfSize:15.0f];
    self.textFieldPassword.text = [defaults objectForKey:kSettingsPassword];
    self.textFieldPassword.delegate = self;
    self.textFieldPassword.returnKeyType = UIReturnKeyDone;

    self.cenaSwitch = [[UISwitch alloc] init];
    self.cenaSwitch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.cenaSwitch.on = [defaults boolForKey:kSettingsCenaMode];
    [self.cenaSwitch addTarget:self action:@selector(switchDidChange:) forControlEvents:UIControlEventValueChanged];
    
    self.title = @"Settings";
    self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonTapped:)];
    self.navigationItem.leftBarButtonItem   = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonTapped:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) { return 1; }

    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.textLabel.textColor = [UIColor colorWithWhite:0.5f alpha:1.0f];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"API URL";
            [cell.contentView addSubview:self.textFieldAPIURL];
        }
        else {
            cell.textLabel.text = @"Password";
            [cell.contentView addSubview:self.textFieldPassword];
        }
    }
    else {
        cell.textLabel.text = @"You Can't See Me";
        CGRect frame = self.cenaSwitch.frame;
        frame.origin.x = CGRectGetWidth(cell.contentView.frame) - (frame.size.width + 15);
        frame.origin.y = CGRectGetMidY(cell.contentView.bounds) - (frame.size.height * 0.5f);
        self.cenaSwitch.frame = frame;
        [cell.contentView addSubview:self.cenaSwitch];
    }
        
    return cell;
}

#pragma mark - Delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.contentChanged = YES;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - Dismissal
- (void)switchDidChange:(id)sender {
    self.contentChanged = YES;
}

- (void)doneButtonTapped:(id)sender
{
    if (self.contentChanged) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.textFieldAPIURL.text forKey:kSettingsAPIURL];
        [defaults setObject:self.textFieldPassword.text forKey:kSettingsPassword];
        [defaults setBool:self.cenaSwitch.on forKey:kSettingsCenaMode];
        [defaults synchronize];
    }
    
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelButtonTapped:(id)sender
{
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
