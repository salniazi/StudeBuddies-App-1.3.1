//
//  LoginViewController.m
//  TedBuddies
//
//  Created by Mayank Pahuja on 08/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import "LoginViewController.h"
#import "ForgetPasswordViewController.h"
#import "HomeViewController.h"
#import "SignUpViewController.h"
#import "CreateProfileViewController.h"
#import "TAFacebookHelper.h"
#import "TermsAndPrivacyViewController.h"
#import "Shared.h"
#import <QuartzCore/QuartzCore.h>
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import <QuartzCore/QuartzCore.h>
#import "InstaViewController.h"
#import "AFHTTPRequestOperation.h"

#import "InstagramUserMedia.h"

@interface LoginViewController ()<SelectedValueDelegate>

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

-(UIColor *)getColor
{
    return [UIColor colorWithRed:(119.0f/255.0f) green:(190.0f/255.0f) blue:(145.0f/255.0f) alpha:1];
    //return [UIColor colorWithRed:(133.0f/255.0f) green:(224.0f/255.0f) blue:(105.0f/255.0f) alpha:1];
}
- (void)viewDidLoad
{
  [super viewDidLoad];
    
    self.btnLogin.layer.borderWidth = 1.0f;
    self.btnLogin.layer.borderColor = [self getColor].CGColor;
    self.emailLabel.layer.borderColor = ([UIColor whiteColor]).CGColor;
    self.emailLabel.layer.borderWidth = 2.0f;
    self.emailLabel.layer.cornerRadius=5;
    self.emailLabel.clipsToBounds=YES;
    self.passwordLabel.layer.cornerRadius=5;
    self.passwordLabel.clipsToBounds=YES;
    self.btnSignup.layer.cornerRadius=5;
    self.btnSignup.clipsToBounds=YES;
    self.btnLogin.layer.cornerRadius=5;
    self.btnLogin.clipsToBounds=YES;
    //self.txtFieldPassword.layer.borderColor = (__bridge CGColorRef)([UIColor whiteColor]);
    
    
//    if (![defaults boolForKey:kSignInTutorial]) {
//        
//        [[Shared sharedInst] showImageWithImageName:@"tutrialSignin"];
//        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
//        tapGesture.numberOfTapsRequired = 1;
//        [[Shared sharedInst].viewImg addGestureRecognizer:tapGesture];
//        
//    }
//    UISwipeGestureRecognizer * swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleft:)];
//    swipeleft.direction=UISwipeGestureRecognizerDirectionRight;
//    [self.view addGestureRecognizer:swipeleft];
//
//    CAGradientLayer *gradient = [CAGradientLayer layer];
//    gradient.frame = self.view.bounds;
//    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor] CGColor], (id)[[UIColor blackColor] CGColor], nil];
//    [self.view.layer insertSublayer:gradient atIndex:0];
//
//    [_loginView setHidden:YES];
//    //[_backButton setBackgroundColor:kBlueColor];
//    [defaults setBool:TRUE forKey:kShowVideo];
//    [defaults synchronize];
    
    
  // For set bydefault Setting to fill EmailId and Password
#if TARGET_IPHONE_SIMULATOR
    
//  [_txtFieldEmail setText:@"Studebuddies@gmail.com"];
//  [_txtFieldPassword setText:@"Sn5284"];
    
    [_txtFieldEmail setText:@"niazisal3@gmail.com"];
    [_txtFieldPassword setText:@"Sn5284"];
  
#endif
    
    // doing to check
//    CreateProfileViewController *createProfile = [[CreateProfileViewController alloc] initWithNibName:@"CreateProfileViewController" bundle:nil];
//    [self.navigationController pushViewController:createProfile animated:YES];

}


-(void)swipeleft:(UISwipeGestureRecognizer*)gestureRecognizer
{
    [UIView animateWithDuration:.8
                          delay: 0
                        options: (UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         self.loginView.frame = CGRectMake(0, _loginView.frame.origin.y + 500, _loginView.frame.size.width, _loginView.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done hiding!");
                         [_loginView setHidden:YES];
                         //[_txtFieldEmail becomeFirstResponder];
                         [self toBringVideo];
                         //[self setEditing:YES];
                     }];
}


-(void)toBringVideo
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
    
    // First play the moview then movie to next screen
    NSURL *portraitUrl = [[NSBundle mainBundle] URLForResource:@"abc1" withExtension:@"mp4"];
    
    // our splash controller
    XOSplashVideoController *splashVideoController =
    [[XOSplashVideoController alloc] initWithVideoPortraitUrl:portraitUrl
                                            portraitImageName:nil
                                                 landscapeUrl:nil
                                           landscapeImageName:nil
                                                     delegate:self];
    [splashVideoController setWantsFullScreenLayout:YES];
    splashVideoController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    //[self presentViewController:splashVideoController animated:YES completion:nil];
    [UIView animateWithDuration:0.8 animations:^{
        splashVideoController.view.alpha = .5;
    } completion:^(BOOL b){
        [self presentViewController:splashVideoController animated:YES completion:^{
            splashVideoController.view.alpha = 1;
        }];
    }];

}
- (void)viewDidAppear:(BOOL)animated
{
    //[self setViewWithAnimation];
//    BOOL toShowVideo = [[defaults valueForKey:kShowVideo] boolValue];
//    if(toShowVideo)
//    {
//        [self toBringVideo];
//    }
//    else
//    {
//        [self setFonts];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
        [self.view addGestureRecognizer:tapGesture];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        BOOL notFirstTime = [[defaults  valueForKey:kSignInTutorial] boolValue];
        if(notFirstTime)
        {
            if([[defaults valueForKey:@"registration"] isEqualToString:@"SignUp"])
            {
                SignUpViewController *signUpView = [[SignUpViewController alloc] initWithNibName:@"SignUpViewController" bundle:nil];
                [self.navigationController pushViewController:signUpView animated:NO];
            }
            else if([[defaults valueForKey:@"registration"] isEqualToString:@"Login"])
            {
                //[self toBringVideo];

            }
            else
            {
                [self setViewWithAnimation];
            }
        }
        else
        {
            if([[defaults valueForKey:@"registration"] isEqualToString:@"SignUp"])
            {
                [_txtFieldEmail resignFirstResponder];
                [self.view endEditing:YES];
                [self hideViewWithAnimation];
                SignUpViewController *signUpView = [[SignUpViewController alloc] initWithNibName:@"SignUpViewController" bundle:nil];
                [self.navigationController pushViewController:signUpView animated:NO];

            }
            
        }
   // }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // FOR GOOGLE ANALYTICS
    self.navigationController.navigationBarHidden=YES;
    self.screenName = @"Login Screen";
}
-(void)viewWillDisappear:(BOOL)animated
{

    [super viewWillDisappear:animated];
    //[self hideViewWithAnimation];
}
- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

-(void)setViewWithAnimation
{
//    [_loginView setHidden:NO];
//    [UIView animateWithDuration:.8
//                          delay: 0.1
//                        options: (UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
//                     animations:^{
//                         self.loginView.frame = CGRectMake(0, _loginView.frame.origin.y - 500, _loginView.frame.size.width, _loginView.frame.size.height);
//                     }
//                     completion:^(BOOL finished){
//                         NSLog(@"Done bringing!");
//                         
//                         //[_txtFieldEmail becomeFirstResponder];
//
//                         //[self setEditing:YES];
//                     }];
}

-(void)hideViewWithAnimation
{
    
//    [UIView animateWithDuration:.8
//                          delay: 0
//                        options: (UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
//                     animations:^{
//                         self.loginView.frame = CGRectMake(0, _loginView.frame.origin.y + 500, _loginView.frame.size.width, _loginView.frame.size.height);
//                     }
//                     completion:^(BOOL finished){
//                         NSLog(@"Done hiding!");
//                         [_loginView setHidden:YES];
//                         //[_txtFieldEmail becomeFirstResponder];
//                         
//                         //[self setEditing:YES];
//                     }];
}
- (IBAction)currentSignInClicked:(id)sender
{
    // ID.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action"     // Event category (required)
                                                          action:@"signin_button_press"  // Event action (required)
                                                           label:@"sign_in"          // Event label
                                                           value:nil] build]];    // Event value
    if([self.loginView isHidden])
    {
        [self setViewWithAnimation];
    }
}


- (void)setFonts
{
  [_btnLogin setTitle:@"Sign In" forState:UIControlStateNormal];
  [_btnLogin.titleLabel setFont:FONT_REGULAR(14)];
  
  [_btnForgotPassword setTitle:@"Forgot Password?" forState:UIControlStateNormal];
  [_btnForgotPassword setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [_btnForgotPassword.titleLabel setFont:FONT_LIGHT(14)];
  
  [_txtFieldEmail setText:@""];
  [_txtFieldPassword setText:@""];
  
  NSAttributedString *strMail = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
  self.txtFieldEmail.attributedPlaceholder = strMail;
  
  NSAttributedString *strPassword = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
  self.txtFieldPassword.attributedPlaceholder = strPassword;
}

#pragma mark - gesture recognizer delegates

- (void)tapView:(UITapGestureRecognizer*)gesture
{
    //SOURABH
    //if first time
    BOOL notFirstTime = [[defaults  valueForKey:kSignInTutorial] boolValue];
    if(!notFirstTime)
    {
        //_loginView.hidden = YES;
        [[Shared sharedInst] removeView];
        [defaults setBool:true forKey:kSignInTutorial];
       
    }
        
    
    //if(self.editing)
        [self.view endEditing:YES];
    
    if(_loginView.hidden == YES)
    {
        [self setViewWithAnimation];
        
    }
    else
    {
       // [self hideViewWithAnimation];
    }

}

#pragma mark - textfield

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(textField.tag == 1)
    {
        
    }
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
  
  if(_txtFieldEmail.text.length == 0 || _txtFieldPassword.text.length == 0)
  {
    _msgString = @"Don't forget to fill all the required fields";
    return NO;
  }
  else if (![Utils NSStringIsValidEmail:_txtFieldEmail.text])
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
#pragma mark - web service

- (void)callAPITwitterLoginWithDictionary:(NSDictionary*)dictSend withCompletionBlock:(void (^)(id response,NSError *error))responeBlock
{
  [Utils startLoaderWithMessage:@""];
  
  [Connection callServiceWithName:kLoginService postData:dictSend callBackBlock:^(id response, NSError *error)
   {
     [Utils stopLoader];
     if (response)
     {
       responeBlock(response,error);
       
     }
     else
     {
       responeBlock(nil,error);
     }
   }];
}

- (void)callAPIForgotPasswordWithEmailid:(NSString*)emailId
{
  NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                            emailId,kEmailId,
                            nil];
  
  [Utils startLoaderWithMessage:@""];
  [Connection callServiceWithName:kForgotPassword postData:dictSend callBackBlock:^(id response, NSError *error)
   {
     [Utils stopLoader];
     if (response)
     {
       if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
       {
         [Utils showAlertViewWithMessage:[response objectForKeyNonNull:kMessage]];
       }
       else
       {
         [Utils showAlertViewWithMessage:[response objectForKeyNonNull:kMessage]];
       }
     }
   }];
}

#pragma mark - alertview delegates

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
  UITextField *textField = [alertView textFieldAtIndex:0];
  if (buttonIndex == 0)
  {
    if ([Utils NSStringIsValidEmail:textField.text])
    {
      [self callAPIForgotPasswordWithEmailid:textField.text];
    }
    else if ([textField.text isEqualToString:@""])
    {
      [Utils showAlertViewWithMessage:@"Don't forget to fill email"];
    }
    else
    {
      [Utils showAlertViewWithMessage:@"Please enter a valid email id"];
    }
      [self.txtFieldEmail becomeFirstResponder];
  }
}

#pragma mark - buttons

- (IBAction)btnLoginTapped:(UIButton *)sender
{
  if ([self isValid])
  {
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              _txtFieldEmail.text,kEmailId,
                              _txtFieldPassword.text,kPassword,
                              [NSString stringWithFormat:@"%i",kLoginTypeEmail],kLoginType,
                              @"",kFacebookId,
                              @"",kTwitterId,
                              [defaults objectForKey:kDeviceToken],kDeviceToken,
                              @"1",kDeviceType,
                              @"",kName,
                              @"",kDob,
                              @"",kProfilePicture,
                              nil];
    [Utils startLoaderWithMessage:@""];
    
    [Connection callServiceWithName:kLoginService postData:dictSend callBackBlock:^(id response, NSError *error)
     {
       [Utils stopLoader];
       if (response)
       {
         if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
         {
           [defaults setObject:[[response objectForKey:kResult] objectForKey:kUserId] forKey:kUserId];
           [defaults setObject:[[response objectForKey:kResult] objectForKey:kName] forKey:kName];
           [defaults setObject:[[response objectForKey:kResult] objectForKey:kProfilePicture] forKey:kProfilePicture];
            [defaults setObject:[[response objectForKey:kResult] objectForKey:kProfilePicture] forKey:kProfilePicture];

            [defaults setObject:[[response objectForKey:kResult] objectForKey:kisCreated] forKey:kisCreated];
            [defaults setObject:[[response objectForKey:kResult] objectForKey:kiisclassuploaded] forKey:kiisclassuploaded];
             if ([[[response objectForKey:kResult] objectForKey:kUniversityId] isKindOfClass:[NSNull class]]) {
                 [defaults setValue:nil forKey:kUniversityId];
             }
             else
             {
                 [defaults setValue:[[response objectForKey:kResult] objectForKey:kUniversityId] forKey:kUniversityId];
             }
             if ([[[response objectForKey:kResult] objectForKey:kUniversityName] isKindOfClass:[NSNull class]]) {
                 [defaults setValue:nil forKey:kUniversityName];
             }
             else
             {
                 [defaults setValue:[[response objectForKey:kResult] objectForKey:kUniversityName] forKey:kUniversityName];
             }


             NSLog(@"%@",[defaults objectForKey:kUniversityId]);
           
           [defaults synchronize];
           
           NSLog(@"%@",[defaults objectForKey:kProfilePicture]);
           if ([[[response objectForKeyNonNull:kResult] objectForKeyNonNull:kIsCreated] boolValue] == true)
           {
               _txtFieldEmail.text = @"";
               _txtFieldPassword.text = @"";
             [defaults setBool:YES forKey:kIsLoggedIn];
             [defaults synchronize];
            [SharedAppDelegate addTabBarScreen];

//               [UIView animateWithDuration:.8
//                                     delay: 0
//                                   options: (UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
//                                animations:^{
//                                    [self.view endEditing:YES];
//                                    self.loginView.frame = CGRectMake(0, _loginView.frame.origin.y + 480, _loginView.frame.size.width, _loginView.frame.size.height);
//                                }
//                                completion:^(BOOL finished){
//                                    NSLog(@"Done!");
//                                    [_loginView setHidden:YES];
//                                    //[_txtFieldEmail becomeFirstResponder];
//                                    [SharedAppDelegate addTabBarScreen];
//                                    //[self setEditing:YES];
//                                }];
//             
           }
           else
           {
               
             CreateProfileViewController *createProfile = [[CreateProfileViewController alloc] initWithNibName:@"CreateProfileViewController" bundle:nil];
             [self.navigationController pushViewController:createProfile animated:YES];
           }
         }
         else
         {
           [Utils showAlertViewWithMessage:[response objectForKey:kMessage]];
         }
       }
     }];
  }

  else
  {
    [Utils showAlertViewWithMessage:_msgString];
  }
}

- (IBAction)btnFotgotPasswordTapped:(UIButton *)sender
{
    //[self setEditing:NO animated:NO];
    [self.view endEditing:YES];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:kAPPNAME message:@"Enter your email id" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel",nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    alertView.tag = 101;
    UITextField *textField = [alertView textFieldAtIndex:0];
    [textField setKeyboardType:UIKeyboardTypeEmailAddress];
    textField.keyboardType = UIKeyboardTypeEmailAddress;
    [alertView show];
  
  //    CreateProfileViewController * createView = [[CreateProfileViewController alloc]initWithNibName:@"CreateProfileViewController" bundle:nil];
  //    [self.navigationController pushViewController:createView animated:YES];
  
  
  
}

- (IBAction)btnLoginWithTwitterTapped:(UIButton *)sender
{
  [Utils startLoaderWithMessage:@""];
  
  
  [[TATweetHelper sharedInstance]loginWithTwitterWithCompletion:^(id response) {
    
    [Utils stopLoader];
    
    
    if (response) {
      
      NSString* _socialId = [response objectForKey:@"id"];
      NSString *_name = [response objectForKey:@"name"];
      NSString *strImageUrl = [response objectForKey:@"profile_image_url"];
      
      NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"",kEmailId,
                                @"",kPassword,
                                [NSString stringWithFormat:@"%i",kLoginTypeTwitter],kLoginType,
                                @"",kFacebookId,
                                @"",kInstaId,
                                _socialId,kTwitterId,
                                [defaults objectForKey:kDeviceToken],kDeviceToken,
                                @"1",kDeviceType,
                                _name,kName,
                                @"",kDob,
                                strImageUrl,kProfilePicture,
                                nil];
      
      [self callAPITwitterLoginWithDictionary:dictSend withCompletionBlock:^(id response, NSError *error)
       {
         switch ([[[response objectForKey:kResult] objectForKey:kRstKey] intValue])
         {
           case 1:
           {
             [defaults setObject:[[response objectForKey:kResult] objectForKey:kUserId] forKey:kUserId];
             [defaults setObject:[[response objectForKey:kResult] objectForKey:kName] forKey:kName];
                [defaults setObject:[[response objectForKey:kResult] objectForKey:kisCreated] forKey:kisCreated];
             [defaults setObject:[[response objectForKey:kResult] objectForKey:kProfilePicture] forKey:kProfilePicture];
                [defaults setObject:[[response objectForKey:kResult] objectForKey:kiisclassuploaded] forKey:kiisclassuploaded];
               if ([[[response objectForKey:kResult] objectForKey:kUniversityId] isKindOfClass:[NSNull class]]) {
                   [defaults setValue:nil forKey:kUniversityId];
               }
               else
               {
                   [defaults setValue:[[response objectForKey:kResult] objectForKey:kUniversityId] forKey:kUniversityId];
               }
               if ([[[response objectForKey:kResult] objectForKey:kUniversityName] isKindOfClass:[NSNull class]]) {
                   [defaults setValue:nil forKey:kUniversityName];
               }
               else
               {
                   [defaults setValue:[[response objectForKey:kResult] objectForKey:kUniversityName] forKey:kUniversityName];
               }

             [defaults synchronize];
             if ([[[response objectForKeyNonNull:kResult] objectForKeyNonNull:kIsCreated] boolValue] == true)
             {
               [defaults setBool:YES forKey:kIsLoggedIn];
               [defaults synchronize];
               [SharedAppDelegate addTabBarScreen];
             }
             else
             {
               NSDictionary *dictReceivedDetails = @{kName: _name,kProfileImage:strImageUrl};
               CreateProfileViewController *createProfile = [[CreateProfileViewController alloc] initWithNibName:@"CreateProfileViewController" bundle:nil];
               [createProfile setDictReceivedDetails:dictReceivedDetails];
               [self.navigationController pushViewController:createProfile animated:YES];
             }
           }
             break;
          // case 2:
//           {
//             [[Utils sharedInstance] showAlertWithTextFieldWithTitle:kAPPNAME message:@"Kindly enter your email id" leftButtonTitle:@"OK" rightButtonTitle:@"Cancel" selectedButton:^(NSInteger selected, UIAlertView *aView)
//              {
//                UITextField *textField = [aView textFieldAtIndex:0];
//                if (selected == 0)
//                {
//                  if ([Utils NSStringIsValidEmail:textField.text])
//                  {
//                      //222654714
//                    NSString *twitterId = _socialId;
//                    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
//                                              textField.text,kEmailId,
//                                              @"",kPassword,
//                                              [NSString stringWithFormat:@"%i",kLoginTypeTwitter],kLoginType,
//                                              @"",kFacebookId,
//                                              twitterId,kTwitterId,
//                                              [defaults objectForKey:kDeviceToken],kDeviceToken,
//                                              @"1",kDeviceType,
//                                              _name,kName,
//                                              @"",kDob,
//                                              strImageUrl,kProfilePicture,
//                                              nil];
//                    [Utils startLoaderWithMessage:@"Loading.."];
//                    [self callAPITwitterLoginWithDictionary:dictSend withCompletionBlock:^(id response, NSError *error)
//                     {
//                       [Utils stopLoader];
//                       [Utils stopLoader];
//                       if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
//                       {
//                         if ([[[response objectForKey:kResult] objectForKey:kRstKey] intValue] == 4)
//                         {
//                           [Utils showAlertViewWithMessage:[response objectForKey:kMessage]];
//                         }
//                         else
//                         {
//                           [defaults setObject:[[response objectForKey:kResult] objectForKey:kUserId] forKey:kUserId];
//                           [defaults setObject:[[response objectForKey:kResult] objectForKey:kName] forKey:kName];
//                           [defaults setObject:[[response objectForKey:kResult] objectForKey:kProfilePicture] forKey:kProfilePicture];
//                           [defaults synchronize];
//                           if ([[[response objectForKeyNonNull:kResult] objectForKeyNonNull:kIsCreated] boolValue] == true)
//                           {
//                             [defaults setBool:YES forKey:kIsLoggedIn];
//                             [defaults synchronize];
//                             [SharedAppDelegate addTabBarScreen];
//                           }
//                           else
//                           {
//                             NSDictionary *dictReceivedDetails = @{kName: _name,kProfileImage:strImageUrl};
//                             CreateProfileViewController *createProfile = [[CreateProfileViewController alloc] initWithNibName:@"CreateProfileViewController" bundle:nil];
//                             [createProfile setDictReceivedDetails:dictReceivedDetails];
//                             [self.navigationController pushViewController:createProfile animated:YES];
//                           }
//                         }
//                       }
//                     }];
//                    
//                    
//                  }
//                  else
//                  {
//                    [Utils showAlertViewWithMessage:@"Please enter a valid email id"];
//                  }
//                }
//              }];
//           }
             //break;
             
           default:
             break;
         }
       }];
    }
    else
    {
      //[Utils showAlertViewWithMessage:@"Please login on twitter in your settings."];
      [Utils showAlertViewWithMessage:kTwitterPermissionOfLogin];
    }
    
  }];
}


- (IBAction)instaButtonTapped:(id)sender
{
    InstaViewController *instaController = [[InstaViewController alloc] initWithNibName:@"InstaViewController" bundle:nil];
    instaController.selectedDelegate = self;
    [self.navigationController pushViewController:instaController animated:YES];
    
}

-(void)callMethod:(NSArray *)imagesArray
{
    NSLog(@"imagesarray count = %lu",(unsigned long)[imagesArray count]);
    [Utils startLoaderWithMessage:@""];
    
    NSMutableArray *arrAdditionlPics = [[NSMutableArray alloc]init];
    int counter = 1;
    
    for (InstagramUserMedia* media in imagesArray)
    {
       // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            NSString* thumbnailUrl = media.thumbnailUrl;
            NSLog(@"thumbnailurl = %@",thumbnailUrl);
            [arrAdditionlPics addObject:thumbnailUrl];
       // });
       
        if (counter == 5) {
            break;
        }
        
        counter++;
        
    }

    NSString *userName = @"";
    NSString *profileImage = @"";
    
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"",kEmailId,
                              @"",kPassword,
                              [NSString stringWithFormat:@"%i",kLoginTypeInstagram],kLoginType,
                              @"",kFacebookId,
                              @"",kTwitterId,
                              [defaults objectForKey:kUserInstagramId],kInstaId,
                              [defaults objectForKey:kDeviceToken],kDeviceToken,
                              @"1",kDeviceType,
                              [defaults objectForKey:kUserInstagramFullname],kName,
                              @"",kDob,
                              [defaults objectForKey:kUserInstagramProfilePicture],kProfilePicture,
                              nil];
    
    userName = [defaults objectForKey:kUserInstagramusername];
    profileImage = [defaults objectForKey:kUserInstagramProfilePicture];
    [Utils startLoaderWithMessage:@""];
    
    [Connection callServiceWithName:kLoginService postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         [Utils stopLoader];
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
            
                     [defaults setObject:[[response objectForKey:kResult] objectForKey:kUserId] forKey:kUserId];
                     [defaults setObject:[[response objectForKey:kResult] objectForKey:kName] forKey:kName];
                    [defaults setObject:[[response objectForKey:kResult] objectForKey:kisCreated] forKey:kisCreated];
                     [defaults setObject:[[response objectForKey:kResult] objectForKey:kProfilePicture] forKey:kProfilePicture];
                    [defaults setObject:[[response objectForKey:kResult] objectForKey:kiisclassuploaded] forKey:kiisclassuploaded];
                    if ([[[response objectForKey:kResult] objectForKey:kUniversityId] isKindOfClass:[NSNull class]]) {
                        [defaults setValue:nil forKey:kUniversityId];
                    }
                    else
                    {
                        [defaults setValue:[[response objectForKey:kResult] objectForKey:kUniversityId] forKey:kUniversityId];
                    }
                 if ([[[response objectForKey:kResult] objectForKey:kUniversityName] isKindOfClass:[NSNull class]]) {
                     [defaults setValue:nil forKey:kUniversityName];
                 }
                 else
                 {
                     [defaults setValue:[[response objectForKey:kResult] objectForKey:kUniversityName] forKey:kUniversityName];
                 }

                     [defaults synchronize];
                     if ([[[response objectForKeyNonNull:kResult] objectForKeyNonNull:kIsCreated] boolValue] == true)
                     {
                         [defaults setBool:YES forKey:kIsLoggedIn];
                         [defaults synchronize];
                         [SharedAppDelegate addTabBarScreen];
                         
                     }
                     else
                     {
                         
                         NSDictionary *dictReceivedDetails = @{kName: userName,kProfileImage:profileImage,kAddionalProfilePicture:arrAdditionlPics};
                         CreateProfileViewController *createProfile = [[CreateProfileViewController alloc] initWithNibName:@"CreateProfileViewController" bundle:nil];
                         [createProfile setDictReceivedDetails:dictReceivedDetails];
                         [self.navigationController pushViewController:createProfile animated:YES];

                     }
             }
             
        }
         
     }];
         
             
    
         /*if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 [defaults setObject:[[response objectForKey:kResult] objectForKey:kUserId] forKey:kUserId];
                 [defaults setObject:[[response objectForKey:kResult] objectForKey:kName] forKey:kName];
                 [defaults setObject:[[response objectForKey:kResult] objectForKey:kProfilePicture] forKey:kProfilePicture];
                 [defaults synchronize];
                 if ([[[response objectForKeyNonNull:kResult] objectForKeyNonNull:kIsCreated] boolValue] == true)
                 {
                     [defaults setBool:YES forKey:kIsLoggedIn];
                     [defaults synchronize];
                     [SharedAppDelegate addTabBarScreen];
                 }
                 else
                 {
                     NSDictionary *dictReceivedDetails = @{kName: userName,kProfileImage:profileImage,kAddionalProfilePicture:arrAdditionlPics};
                     CreateProfileViewController *createProfile = [[CreateProfileViewController alloc] initWithNibName:@"CreateProfileViewController" bundle:nil];
                     [createProfile setDictReceivedDetails:dictReceivedDetails];
                     [self.navigationController pushViewController:createProfile animated:YES];
                 }
             }*/
    

     

}
- (IBAction)btnLoginFacebookTapped:(UIButton *)sender
{
  
  
  [[Utils sharedInstance] showAlertWithTitle:@"Facebook" message:[NSString stringWithFormat:@"\"%@\" would like to access your basic profile info, list of friends and photos on your behalf.",kAPPNAME] leftButtonTitle:@"Don't Allow" rightButtonTitle:@"Ok" selectedButton:^(NSInteger selected, UIAlertView *aView) {
    
    if (selected == 1) {
      
      NSArray *permissionsArray = [[NSArray alloc] initWithObjects:
                                   @"read_stream",
                                   @"email",
                                   @"user_birthday",
                                   @"user_photos",
                                   nil];
      
      // [Utils startLoaderWithMessage:@""];
      
      
      [TAFacebookHelper fetchPersonalInfoWithParams:@"id,picture.type(large),name,email,birthday" withPermissions:permissionsArray completionHandler:^(id response, NSError *e) {
        
        [Utils stopLoader];
        NSString *userName = @"";
        NSString *profileImage = @"";
        if (e == nil)
        {
          NSLog(@"Successfully Login%@",response);
          NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [response objectForKeyNonNull:@"email"],kEmailId,
                                    @"",kPassword,
                                    [NSString stringWithFormat:@"%i",kLoginTypeFacebook],kLoginType,
                                    [response objectForKeyNonNull:@"id"],kFacebookId,
                                    @"",kTwitterId,
                                    @"",kInstaId,
                                    [defaults objectForKey:kDeviceToken],kDeviceToken,
                                    @"1",kDeviceType,
                                    [response objectForKey:@"name"],kName,
                                    @"",kDob,
                                    [[[response objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"],kProfilePicture,
                                    nil];
            
            userName = [response objectForKey:@"name"];
            profileImage = [[[response objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
            
            [TAFacebookHelper fetchLatestPhotosWithParams:nil withPermissions:permissionsArray completionHandler:^(id response, NSError *e)
            {
                if (e == nil)
                {
                    NSLog(@"response ::%@",response);
                      NSMutableArray *arrAdditionlPics = [[NSMutableArray alloc]init];
                   
                    int counter = 1;
                    
                    for (NSMutableDictionary *tempDict in [response valueForKey:@"data"])
                    {
                        // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                        NSString* thumbnailUrl = [[[tempDict valueForKey:@"images"] firstObject] valueForKey:@"source"];
                        NSLog(@"thumbnailurl = %@",thumbnailUrl);
                        [arrAdditionlPics addObject:thumbnailUrl];
                        // });
                        
                        if (counter == 5) {
                            break;
                        }
                        counter++;                        
                    }
                    
                    
                    
                    [Utils startLoaderWithMessage:@""];
                    
                    [Connection callServiceWithName:kLoginService postData:dictSend callBackBlock:^(id response, NSError *error)
                     {
                         [Utils stopLoader];
                         if (response)
                         {
                             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
                             {
                                 [defaults setObject:[[response objectForKey:kResult] objectForKey:kUserId] forKey:kUserId];
                                 [defaults setObject:[[response objectForKey:kResult] objectForKey:kName] forKey:kName];
                                 [defaults setObject:[[response objectForKey:kResult] objectForKey:kisCreated] forKey:kisCreated];
                                 [defaults setObject:[[response objectForKey:kResult] objectForKey:kProfilePicture] forKey:kProfilePicture];
                                  [defaults setObject:[[response objectForKey:kResult] objectForKey:kiisclassuploaded] forKey:kiisclassuploaded];
                                 if ([[[response objectForKey:kResult] objectForKey:kUniversityId] isKindOfClass:[NSNull class]]) {
                                     [defaults setValue:nil forKey:kUniversityId];
                                 }
                                 else
                                 {
                                     [defaults setValue:[[response objectForKey:kResult] objectForKey:kUniversityId] forKey:kUniversityId];
                                 }
                                 if ([[[response objectForKey:kResult] objectForKey:kUniversityName] isKindOfClass:[NSNull class]]) {
                                     [defaults setValue:nil forKey:kUniversityName];
                                 }
                                 else
                                 {
                                     [defaults setValue:[[response objectForKey:kResult] objectForKey:kUniversityName] forKey:kUniversityName];
                                 }

                                 [defaults synchronize];
                                 if ([[[response objectForKeyNonNull:kResult] objectForKeyNonNull:kIsCreated] boolValue] == true)
                                 {
                                     [defaults setBool:YES forKey:kIsLoggedIn];
                                     [defaults synchronize];
                                     [SharedAppDelegate addTabBarScreen];
                                 }
                                 else
                                 {
                                     NSDictionary *dictReceivedDetails = @{kName: userName,kProfileImage:profileImage,kAddionalProfilePicture:arrAdditionlPics};
                                     CreateProfileViewController *createProfile = [[CreateProfileViewController alloc] initWithNibName:@"CreateProfileViewController" bundle:nil];
                                     [createProfile setDictReceivedDetails:dictReceivedDetails];
                                     [self.navigationController pushViewController:createProfile animated:YES];
                                 }
                             }
                         }
                     }];
                   
                }
                
            }];
            
            
            
 //           [Utils startLoaderWithMessage:@""];
            
//            [Connection callServiceWithName:kLoginService postData:dictSend callBackBlock:^(id response, NSError *error)
//             {
//                 [Utils stopLoader];
//                 if (response)
//                 {
//                     if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
//                     {
//                         [defaults setObject:[[response objectForKey:kResult] objectForKey:kUserId] forKey:kUserId];
//                         [defaults setObject:[[response objectForKey:kResult] objectForKey:kName] forKey:kName];
//                         [defaults setObject:[[response objectForKey:kResult] objectForKey:kProfilePicture] forKey:kProfilePicture];
//                         [defaults synchronize];
//                         if ([[[response objectForKeyNonNull:kResult] objectForKeyNonNull:kIsCreated] boolValue] == true)
//                         {
//                             [defaults setBool:YES forKey:kIsLoggedIn];
//                             [defaults synchronize];
//                             [SharedAppDelegate addTabBarScreen];
//                         }
//                         else
//                         {
//                             NSDictionary *dictReceivedDetails = @{kName: userName,kProfileImage:profileImage};
//                             CreateProfileViewController *createProfile = [[CreateProfileViewController alloc] initWithNibName:@"CreateProfileViewController" bundle:nil];
//                             [createProfile setDictReceivedDetails:dictReceivedDetails];
//                             [self.navigationController pushViewController:createProfile animated:YES];
//                         }
//                     }
//                 }
//             }];
          
        }
        else
        {
          
            [Utils showAlertViewWithMessage:kFacebookPermissionOfLogin];
        }
      }];
    }
    else {
        
        
      
    }
  }];
  
}

- (IBAction)btnSignupTapped:(UIButton *)sender
{
//    if(self.loginView.hidden == NO)
//        [self hideViewWithAnimation];
//  SignUpViewController *signUpView = [[SignUpViewController alloc] initWithNibName:@"SignUpViewController" bundle:nil];
//  [self.navigationController pushViewController:signUpView animated:YES];
    [self.view endEditing:YES];
    
    if ([self isValid])
    {
        NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                                  _txtFieldEmail.text,kEmailId,
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
                     
                     [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:[NSString stringWithFormat:[response objectForKey:kMessage],_txtFieldEmail.text] leftButtonTitle:@"Ok" rightButtonTitle:nil selectedButton:^(NSInteger selected, UIAlertView *aView)
                      {
                          _txtFieldEmail.text = @"";
                          _txtFieldPassword.text = @"" ;
                          [self.navigationController popViewControllerAnimated:YES];
                      }];
                     
                     
                 }
                 else
                 {
                     [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:[response objectForKeyNonNull:kMessage] leftButtonTitle:@"OK" rightButtonTitle:nil selectedButton:^(NSInteger selected, UIAlertView *aView)
                      {
                          _txtFieldEmail.text = @"";
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

- (IBAction)termsAndConditionButtonClick:(UIButton *)sender
{
  TermsAndPrivacyViewController *termsAndPrivacyViewC= [[TermsAndPrivacyViewController alloc] initWithNibName:@"TermsAndPrivacyViewController" bundle:nil];
  termsAndPrivacyViewC.headingName = @"Terms Condition";
  [self.navigationController pushViewController:termsAndPrivacyViewC animated:YES];
}

- (IBAction)privacyPolicyButtonClick:(UIButton *)sender
{
  TermsAndPrivacyViewController *termsAndPrivacyViewC= [[TermsAndPrivacyViewController alloc] initWithNibName:@"TermsAndPrivacyViewController" bundle:nil];
  termsAndPrivacyViewC.headingName = @"Privacy Policy";
  [self.navigationController pushViewController:termsAndPrivacyViewC animated:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  [touches anyObject];
  
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
  //isLongPress = YES;
  return YES;
}

#pragma mark- LoginSplashVideoDelegate

- (void)splashVideoLoaded:(LoginViewController *)splashVideo
{
    [defaults setBool:FALSE forKey:kShowVideo];
    [defaults synchronize];
    // load up our real view controller, but don't put it in to the window until the video is done
    // if there's anything expensive to do it should happen in the background now
    [_loginView setHidden:NO];
    _currentSignInButton.layer.cornerRadius = 4.0f;
    _btnSignup.layer.cornerRadius = 4.0f;
    
    //set tutorials screens
    
    if (![defaults boolForKey:kSignInTutorial]) {
        
        [[Shared sharedInst] showImageWithImageName:@"tutrialSignin"];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
        tapGesture.numberOfTapsRequired = 1;
        [[Shared sharedInst].viewImg addGestureRecognizer:tapGesture];
        
    }

    
}

- (void)splashVideoComplete:(LoginViewController *)splashVideo
{
    [_loginView setHidden:NO];

    [defaults setBool:FALSE forKey:kShowVideo];
    [defaults synchronize];
    // swap out the splash controller for our app's
    [self dismissViewControllerAnimated:NO completion:nil];
    [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
    [self setFonts];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    [self.view addGestureRecognizer:tapGesture];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
//    BOOL notFirstTime = [[defaults  valueForKey:kSignInTutorial] boolValue];
//    if(notFirstTime)
//    {
//        [self setViewWithAnimation];
//    }
    
}
- (IBAction)backBtnClcikedd:(id)sender {
    [UIView animateWithDuration:.8
                          delay: 0
                        options: (UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         self.loginView.frame = CGRectMake(0, _loginView.frame.origin.y + 500, _loginView.frame.size.width, _loginView.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         NSLog(@"Done hiding!");
                         [_loginView setHidden:YES];
                         //[_txtFieldEmail becomeFirstResponder];
                         [self toBringVideo];
                         //[self setEditing:YES];
                     }];}


@end
