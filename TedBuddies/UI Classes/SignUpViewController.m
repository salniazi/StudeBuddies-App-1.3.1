//
//  SignUpViewController.m
//  TedBuddies
//
//  Created by Mayank Pahuja on 08/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import "SignUpViewController.h"
#import "LoginViewController.h"
#import "HomeViewController.h"
#import "PostViewController.h"
#import "FindBuddiesViewController.h"
#import "MarketPlaceViewController.h"
#import "MessagesViewController.h"
#import "TabbarViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [defaults setObject:@"Login" forKey:@"registration"];

    [super viewDidLoad];
    [self setFonts];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setFonts
{
    [_txtFieldPassword setFont:FONT_REGULAR(14)];
    [_txtFieldUsername setFont:FONT_REGULAR(14)];
    
    [_btnSignUp setTitle:@"Sign Up" forState:UIControlStateNormal];
    [_btnSignUp.titleLabel setFont:FONT_REGULAR(14)];
    
    [_btnLogIn.titleLabel setFont:FONT_REGULAR(14)];
    [_btnGuestUser.titleLabel setFont:FONT_REGULAR(14)];
    
    
    NSAttributedString *strMail = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
    self.txtFieldUsername.attributedPlaceholder = strMail;
    
    NSAttributedString *strPassword = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
    self.txtFieldPassword.attributedPlaceholder = strPassword;
    
    
    
    UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backSwipeAction)];
    [backSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:backSwipe];
}

#pragma mark - gesture recognizer action

- (void)backSwipeAction
{
    [defaults setObject:@"Login" forKey:@"registration"];
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - textfield

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - validation

- (BOOL)isValid
{
    _msgString = nil;
    
    if(_txtFieldUsername.text.length == 0 || _txtFieldPassword.text.length == 0)
    {
        _msgString = @"Don't forget to fill all the required fields";
        return NO;
    }
    else if (![Utils NSStringIsValidEmail:_txtFieldUsername.text])
    {
        _msgString = @"Please enter a valid email id";
        return NO;
    }
    else if(_txtFieldPassword.text.length < 6)
    {
        _msgString = @"Password length should be atleast 6 characters";
        return NO;
    }
    
    return YES;
}

#pragma mark - button action

- (IBAction)btnSendTapped:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    if ([self isValid])
    {
        NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                                  _txtFieldUsername.text,kEmailId,
                                  _txtFieldPassword.text,kPassword,
                                  [defaults objectForKey:kDeviceToken],kDeviceToken,
                                  @"1",kDeviceType,
                                  nil];
        [Utils startLoaderWithMessage:@""];
        [Connection callServiceWithName:kSignupService postData:dictSend callBackBlock:^(id response, NSError *error)
         {
             if (response)
             {
                 [Utils stopLoader];
                 if ([[response objectForKeyNonNull:kSuccess] boolValue] == YES)
                 {
                     
                     [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:[NSString stringWithFormat:[response objectForKey:kMessage],_txtFieldUsername.text] leftButtonTitle:@"Ok" rightButtonTitle:nil selectedButton:^(NSInteger selected, UIAlertView *aView)
                      {
                          _txtFieldUsername.text = @"";
                          _txtFieldPassword.text = @"" ;
                          [self.navigationController popViewControllerAnimated:YES];
                      }];
                     
                     
                 }
                 else
                 {
                     [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:[response objectForKeyNonNull:kMessage] leftButtonTitle:@"OK" rightButtonTitle:nil selectedButton:^(NSInteger selected, UIAlertView *aView)
                      {
                          _txtFieldUsername.text = @"";
                          _txtFieldPassword.text = @"" ;
                          [self.navigationController popViewControllerAnimated:YES];
                          
                      }];
                 }
             }
         }];
    }
    else
    {
        [Utils showAlertViewWithMessage:_msgString];
    }
    
}

- (IBAction)btnLoginTapped:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnGuestUserTapped:(UIButton *)sender
{
    [defaults setObject:@"0" forKey:kUserId];
    [defaults synchronize];
    [self addTabbarController];
}

#pragma mark - tab bar controller

- (void)addTabbarController
{
    [SharedAppDelegate addTabBarScreen];
}

@end
