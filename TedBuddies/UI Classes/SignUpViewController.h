//
//  SignUpViewController.h
//  TedBuddies
//
//  Created by Mayank Pahuja on 08/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *txtFieldUsername;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnSend;
@property (strong, nonatomic) NSString *msgString;
@property (weak, nonatomic) IBOutlet UIButton *btnSignUp;
@property (weak, nonatomic) IBOutlet UIButton *btnLogIn;
@property (weak, nonatomic) IBOutlet UIButton *btnGuestUser;
@property(nonatomic, copy) NSAttributedString *attributedPlaceholder;


- (IBAction)btnSendTapped:(UIButton *)sender;
- (IBAction)btnLoginTapped:(UIButton *)sender;
- (IBAction)btnGuestUserTapped:(UIButton *)sender;

@end
