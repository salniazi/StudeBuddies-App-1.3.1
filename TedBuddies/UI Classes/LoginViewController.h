//
//  LoginViewController.h
//  TedBuddies
//
//  Created by Mayank Pahuja on 08/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"
#import "XOSplashVideoController.h"


@interface LoginViewController : GAITrackedViewController <UIGestureRecognizerDelegate,XOSplashVideoDelegate>

@property (strong, nonatomic) IBOutlet UITextField *txtFieldEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnLogin;
@property (strong, nonatomic) IBOutlet UIButton *btnForgotPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnLoginWithTwitter;
@property (strong, nonatomic) IBOutlet UIButton *btnLoginFacebook;
@property (strong, nonatomic) IBOutlet UIButton *btnSignup;
@property (strong, nonatomic) NSString *msgString;

@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;

- (IBAction)btnLoginTapped:(UIButton *)sender;
- (IBAction)btnFotgotPasswordTapped:(UIButton *)sender;
- (IBAction)btnLoginWithTwitterTapped:(UIButton *)sender;
- (IBAction)btnLoginFacebookTapped:(UIButton *)sender;
- (IBAction)btnSignupTapped:(UIButton *)sender;
- (IBAction)termsAndConditionButtonClick:(UIButton *)sender;
- (IBAction)privacyPolicyButtonClick:(UIButton *)sender;

// NEW

@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIButton *currentSignInButton;

@property (weak, nonatomic) IBOutlet UILabel *seperatorLabel;

@property (weak, nonatomic) IBOutlet UIButton *backButton;



@end
