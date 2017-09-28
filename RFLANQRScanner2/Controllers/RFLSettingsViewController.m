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

- (void)doneButtonTapped:(id)sender;
- (void)cancelButtonTapped:(id)sender;

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
    
    self.textFieldAPIURL = [[UITextField alloc] initWithFrame:CGRectMake(110, 0, 320-110, 44)];
    self.textFieldAPIURL.font = [UIFont systemFontOfSize:15.0f];
    self.textFieldAPIURL.text = [defaults objectForKey:kSettingsAPIURL];
    self.textFieldAPIURL.delegate = self;
    self.textFieldAPIURL.returnKeyType = UIReturnKeyDone;
    
    self.textFieldPassword = [[UITextField alloc] initWithFrame:CGRectMake(110, 0, 320-110, 44)];
    self.textFieldPassword.font = [UIFont systemFontOfSize:15.0f];
    self.textFieldPassword.text = [defaults objectForKey:kSettingsPassword];
    self.textFieldPassword.delegate = self;
    self.textFieldPassword.returnKeyType = UIReturnKeyDone;
    
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
    
    if (indexPath.row == 0)
    {
        cell.textLabel.text = @"API URL";
        [cell.contentView addSubview:self.textFieldAPIURL];
    }
    else
    {
        cell.textLabel.text = @"Password";
        [cell.contentView addSubview:self.textFieldPassword];
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
- (void)doneButtonTapped:(id)sender
{
    if (self.contentChanged)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.textFieldAPIURL.text forKey:kSettingsAPIURL];
        [defaults setObject:self.textFieldPassword.text forKey:kSettingsPassword];
        [defaults synchronize];
    }
    
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelButtonTapped:(id)sender
{
    [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
