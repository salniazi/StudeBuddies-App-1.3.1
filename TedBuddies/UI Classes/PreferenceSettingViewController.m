//
//  PreferenceSettingViewController.m
//  TedBuddies
//
//  Created by Sunil on 08/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import "PreferenceSettingViewController.h"
#import "FindBuddiesViewController.h"
#import "LoginViewController.h"
#import "ViewProfileViewController.h"
#import "HomeViewController.h"
#import "TermsAndPrivacyViewController.h"
#import "Shared.h"
#import "SWRevealViewController.h"
#import "PostViewController.h"
#import "ScheduleListViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"

@interface PreferenceSettingViewController ()
{
    BOOL isOnCoursePrefix;
    BOOL isOnSwitchTime;
    BOOL isOnswitchMajor;
    BOOL isOnswitchClassTitle;
    BOOL isOnswitchSchool;
    UIView *leftView;
    SWRevealViewController *revealController;
    UINavigationController *navController;
    
    BOOL isFirstTimeLoad;
    
}

@end

@implementation PreferenceSettingViewController

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
    [super viewDidLoad];

    isFirstTimeLoad=true;
    
    revealController = [self revealViewController];
    _btnClassSchedule.layer.cornerRadius=3;
    _btnClassSchedule.clipsToBounds=YES;
    
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)tapViewToRemoveLeftView:(UITapGestureRecognizer*)gesture
{
    [leftView removeFromSuperview];
    [revealController rightRevealToggle:gesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, self.view.frame.size.height)];
    [leftView setUserInteractionEnabled:YES];
    [leftView setBackgroundColor:[UIColor clearColor]];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapViewToRemoveLeftView:)];
    tapGesture.numberOfTapsRequired = 1;
    [leftView addGestureRecognizer:tapGesture];
    [SharedAppDelegate.window addSubview:leftView];
    self.hidesBottomBarWhenPushed = YES;
    //set tutorials screens
    if (![defaults boolForKey:kPreferenceSettingsTutorial]) {
        
        [[Shared sharedInst] showImageWithImageName:@"tutorialPreference"];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
        tapGesture.numberOfTapsRequired = 1;
        [[Shared sharedInst].viewImg addGestureRecognizer:tapGesture];
        
    }
    [self setFonts];
//    if ([defaults boolForKey:kShowUploadSchedule])
//    {
//        [_switchClassTitle setOn:YES];
//        [_switchCoursePrefix setOn:YES];
//        [_switchTime setOn:YES];
//    }
//    else
//    {
//        
//        [_switchClassTitle setOn:NO];
//        [_switchCoursePrefix setOn:NO];
//        [_switchTime setOn:NO];
//    }

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //[self.tabBarController.tabBar setHidden:YES];
    
//    SharedAppDelegate.tabBarController.tabBar.hidden = YES;
//    SharedAppDelegate.tabBarController.tabBar.translucent = YES;
    [self.tabBarController.tabBar setHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    SharedAppDelegate.tabBarController.tabBar.hidden = NO;
//    SharedAppDelegate.tabBarController.tabBar.translucent = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - gesture recognizer delegates
- (void)tapView:(UITapGestureRecognizer*)gesture
{
    [[Shared sharedInst] removeView];
    [defaults setBool:true forKey:kPreferenceSettingsTutorial];
}


- (void)setFonts
{
    
    UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backSwipeAction)];
    [backSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:backSwipe];
    
    [_btnSend.layer setBorderColor:kBlueColor.CGColor];
    [_btnSend.layer setBorderWidth:kButtonBorderWidth];
    [_btnSend.layer setCornerRadius:kButtonCornerRadius];
    //_scrollView.height = 550;
//    [_scrollView setContentSize:CGSizeMake(320, 543)];
//   
//    [_scrollView setScrollEnabled:YES];
    [self callAPIGetPreferences];
}

#pragma mark - web service

- (void)callApiServiceForReportAProblem
{
    
    NSString *strMessage = _txtFieldReportMessage.text;
    if ([strMessage isEqualToString:@""] || [strMessage isEqual:NULL]) {
        return;
    } else {
        strMessage = _txtFieldReportMessage.text;
    }
    
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,strMessage,@"message",
                              nil];
    
    [Utils startLoaderWithMessage:@""];
    
    [Connection callServiceWithName:kReportAProblem postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         [Utils stopLoader];
         if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
         {
             [Utils showAlertViewWithMessage:[response objectForKeyNonNull:kMessage]];
         }
         
     }];
    
}
- (void)callAPIGetPreferences
{
  NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                            [defaults objectForKey:kUserId],kUserId,
                            nil];
    
    if (isFirstTimeLoad)
    {
        [Utils startLoaderWithMessage:@""];
    }
  
  [Connection callServiceWithName:kGetPrefrences postData:dictSend callBackBlock:^(id response, NSError *error)
   {
       if (isFirstTimeLoad)
       {
           [Utils stopLoader];
       }
       isFirstTimeLoad=false;
       
       
     if (response)
     {
       if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
       {
         isOnswitchMajor = [[[response objectForKeyNonNull:kResult] objectForKeyNonNull:kIsMajor] boolValue];
         isOnswitchClassTitle = [[[response objectForKeyNonNull:kResult] objectForKeyNonNull:kIsClassTitle] boolValue];
         isOnswitchSchool = [[[response objectForKeyNonNull:kResult] objectForKeyNonNull:kIsUniversity] boolValue];
         isOnCoursePrefix = [[[response objectForKeyNonNull:kResult] objectForKeyNonNull:@"isCourseNO"] boolValue];
         isOnSwitchTime = [[[response objectForKeyNonNull:kResult] objectForKeyNonNull:kIsTimeSection] boolValue];
            NSLog(@"%d",[defaults boolForKey:kiisclassuploaded]);
           [defaults setObject:[[response objectForKey:kResult] objectForKey:kiisclassuploaded] forKey:kiisclassuploaded];
         
         _switchCoursePrefix.on = isOnCoursePrefix;
         _switchMajor.on = isOnswitchMajor;
         _switchSchool.on = isOnswitchSchool; 
            NSLog(@"%d",[defaults boolForKey:kiisclassuploaded]);
        if([defaults boolForKey:kiisclassuploaded])
        {
         
         
           
        if ([_switchCoursePrefix isOn])
        {
            [_switchTime setEnabled:YES];
            [_switchTime setOn:isOnSwitchTime animated:NO];
        }
        
        else
      
        {
         
            [_switchTime setOn:FALSE animated:NO];
            [_switchTime setEnabled:NO];
         
        }
     }
        else
        {
            [_switchClassTitle setOn:false animated:NO];
            [_switchTime setOn:false animated:NO];
            [_switchCoursePrefix setOn:false animated:NO];
            
            [_switchClassTitle setEnabled:NO];
            [_switchTime setEnabled:NO];
            [_switchCoursePrefix setEnabled:NO];
        }
         [_switchClassTitle setHidden:NO];
         [_switchMajor setHidden:NO];
         [_switchCoursePrefix setHidden:NO];
         [_switchSchool setHidden:NO];
         [_switchTime setHidden:NO];
       }
     }
   }];
}


- (void)callAPISetPreferences
{
  
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [_switchMajor isOn]?@"True":@"False",kIsMajor,
                              [_switchClassTitle isOn]?@"True":@"False",kIsClassTitle,
                              [_switchSchool isOn]?@"True":@"False",kIsUniversity,
                              [_switchCoursePrefix isOn]?@"True":@"False",@"isCourseNO",
                              [_switchTime isOn]?@"True":@"False",kIsTimeSection,
                              [defaults objectForKey:kUserId],kUserId,
                              nil];
    [Utils startLoaderWithMessage:@""];
    [Connection callServiceWithName:kSetPrefrencesService postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         [Utils stopLoader];
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 [Utils showAlertViewWithMessage:[response objectForKeyNonNull:kMessage]];
                 //[self.navigationController popViewControllerAnimated:YES];
                 if (_isFirstTime)
                 {
                    [SharedAppDelegate addTabBarScreen];
                 }
                 


             }
         }
     }
     ];
    
    
}

#pragma mark - gesture recognizer action

- (void)backSwipeAction
{
    //[self.navigationController popViewControllerAnimated:YES];
   
}



#pragma mark Textfield Delegate Method

- (void)textFieldDidBeginEditing:(UITextField *)textField          // became first responder
{
    //textField.autocorrectionType = UITextAutocorrectionTypeYes;
    _txtFieldReportMessage = textField;
    //if(textField != self.txtFieldReportMessage)
    // [self setViewMovedUp:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField              // called when 'return' key pressed.
{
    [_txtFieldReportMessage resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //if(textField != self.txtFieldReportMessage)
    //[self setViewMovedUp:NO];
}

#pragma mark ------------ IBActions Button action --------------

- (IBAction)btnViewProfileTapped:(UIButton *)sender
{
    ViewProfileViewController * viewProfile = [[ViewProfileViewController alloc]initWithNibName:@"ViewProfileViewController" bundle:nil];
    
    viewProfile.inviteButtonHidden = YES;
    viewProfile.editProfile = NO;
    [viewProfile setHidesBottomBarWhenPushed:NO];
    [viewProfile setBuddyId:[defaults objectForKey:kUserId]];
    [self.navigationController pushViewController:viewProfile animated:YES];
}

- (IBAction)switchMajorAction:(UISwitch *)sender
{

    isOnswitchMajor = sender.on;
//    if (!(isOnswitchMajor && isOnswitchSchool && isOnswitchClassTitle)) {
//        [_switchCoursePrefix setOn:FALSE animated:YES];
//        [_switchTime setOn:FALSE animated:YES];
//        [_switchCoursePrefix setEnabled:NO];
//        [_switchTime setEnabled:NO];
//    } else {
//        [_switchCoursePrefix setEnabled:YES];
//        [_switchTime setEnabled:YES];
//        [_switchCoursePrefix setOn:isOnCoursePrefix animated:YES];
//        [_switchTime setOn:isOnSwitchTime animated:YES];
//    }
//    
  
}

- (IBAction)switchSchoolAction:(UISwitch *)sender
{
    isOnswitchSchool = sender.on;
//    if (!(isOnswitchMajor && isOnswitchSchool && isOnswitchClassTitle)) {
//        [_switchCoursePrefix setOn:FALSE animated:YES];
//        [_switchTime setOn:FALSE animated:YES];
//        [_switchCoursePrefix setEnabled:NO];
//        [_switchTime setEnabled:NO];
//    } else {
//        [_switchCoursePrefix setEnabled:YES];
//        [_switchTime setEnabled:YES];
//        [_switchCoursePrefix setOn:isOnCoursePrefix animated:YES];
//        [_switchTime setOn:isOnSwitchTime animated:YES];
//    }
}

- (IBAction)switchClassTitleAction:(UISwitch *)sender
{
    isOnswitchClassTitle = sender.on;
    if (!isOnswitchClassTitle) {
        [_switchCoursePrefix setOn:FALSE animated:YES];
        [_switchTime setOn:FALSE animated:YES];
        [_switchCoursePrefix setEnabled:NO];
        [_switchTime setEnabled:NO];
    } else if (!isOnCoursePrefix){
      [_switchCoursePrefix setEnabled:YES];
      [_switchTime setEnabled:NO];
      [_switchCoursePrefix setOn:isOnCoursePrefix animated:YES];
      //[_switchTime setOn:isOnSwitchTime animated:YES];
    } else {
      [_switchCoursePrefix setEnabled:YES];
      [_switchTime setEnabled:YES];
      [_switchCoursePrefix setOn:isOnCoursePrefix animated:YES];
      [_switchTime setOn:isOnSwitchTime animated:YES];
    }
}

- (IBAction)switchTimeAction:(UISwitch *)sender
{
    isOnSwitchTime = sender.on;
}

- (IBAction)switchCoursePrefixAction:(UISwitch *)sender
{
    isOnCoursePrefix = sender.on;
  if (!isOnCoursePrefix) {
    [_switchTime setOn:FALSE animated:YES];
    [_switchTime setEnabled:NO];
  } else {
    [_switchTime setEnabled:YES];
    [_switchTime setOn:isOnSwitchTime animated:YES];
  }
}


- (IBAction)btnBackTapped:(UIButton *)sender
{
    [self backSwipeAction];
}

- (IBAction)btnSaveTapped:(UIButton *)sender
{
    [self callAPISetPreferences];
    SharedAppDelegate.isChangePreference=true;
}


- (IBAction)btnReportAProblemTapped:(UIButton *)sender {
    
    self.viewReportMessage.hidden = NO;
    [self.view addSubview:_viewReportMessage];
    
    //[self callApiServiceForReportAProblem];
//    [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"Are you sure you want to send report a problem?" leftButtonTitle:@"Yes" rightButtonTitle:@"Cancel" selectedButton:^(NSInteger selected, UIAlertView *aView)
//     {
//         if (selected == 0)
//         {
//             self.viewReportMessage.hidden = NO;
//             [self.view addSubview:_viewReportMessage];
//         }
//     }];
    
}

- (IBAction)btnPrivacyPolicyTapped:(UIButton *)sender {
   
//    TermsAndPrivacyViewController *termsAndPrivacyViewC= [[TermsAndPrivacyViewController alloc] initWithNibName:@"TermsAndPrivacyViewController" bundle:nil];
//    termsAndPrivacyViewC.headingName = @"Privacy Policy";
//    [self.navigationController pushViewController:termsAndPrivacyViewC animated:YES];
    
    TermsAndPrivacyViewController *vcTermsAndPrivacy = [[TermsAndPrivacyViewController alloc] initWithNibName:@"TermsAndPrivacyViewController" bundle:nil];
    vcTermsAndPrivacy.headingName = @"Privacy Policy";
    navController=[[UINavigationController alloc] initWithRootViewController:vcTermsAndPrivacy];
    navController.navigationBarHidden=YES;
    [self presentViewController:navController animated:YES completion:nil];

}

- (IBAction)btnTermsAndConditionTapped:(UIButton *)sender {

//    TermsAndPrivacyViewController *termsAndPrivacyViewC= [[TermsAndPrivacyViewController alloc] initWithNibName:@"TermsAndPrivacyViewController" bundle:nil];
//    termsAndPrivacyViewC.headingName = @"Terms Condition";
//    [self.navigationController pushViewController:termsAndPrivacyViewC animated:YES];
    
    TermsAndPrivacyViewController *vcTermsAndPrivacy = [[TermsAndPrivacyViewController alloc] initWithNibName:@"TermsAndPrivacyViewController" bundle:nil];
    vcTermsAndPrivacy.headingName = @"Terms Condition";
    navController=[[UINavigationController alloc] initWithRootViewController:vcTermsAndPrivacy];
    navController.navigationBarHidden=YES;
    [self presentViewController:navController animated:YES completion:nil];


}

- (IBAction)closeButtonClick:(id)sender {
    
    self.viewReportMessage.hidden = YES;
    [_viewReportMessage removeFromSuperview];
}

- (IBAction)sendButtonClick:(id)sender {
    [self callApiServiceForReportAProblem];
    self.viewReportMessage.hidden = YES;
    [_viewReportMessage removeFromSuperview];
}


- (IBAction)btnLogOutTapped:(UIButton *)sender {
    
    [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"Are you sure you want to logout?" leftButtonTitle:@"Yes" rightButtonTitle:@"Cancel" selectedButton:^(NSInteger selected, UIAlertView *aView)
     {
         if (selected == 0)
         {
             [Utils startLoaderWithMessage:@""];
             NSMutableDictionary *dictSend = [[NSMutableDictionary alloc] init];
             [dictSend setObject:[defaults objectForKey:kDeviceToken] forKey:kDeviceToken];
             
             [Connection callServiceWithName:kLogoutApp postData:dictSend callBackBlock:^(id response, NSError *error)
              {
                  [Utils stopLoader];
                  NSLog(@"re:%@",response);
                  [defaults setBool:NO forKey:kIsLoggedIn];
                  [defaults setBool:TRUE forKey:kShowVideo];
                  
                  [defaults synchronize];
                  
                  [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
                  [self.tabBarController setSelectedIndex:2];
                  [self.navigationController popViewControllerAnimated:NO];
                  
                  [defaults synchronize];
                  
                  [[DBSession sharedSession] unlinkAll];
                  
                  [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:@"StudeBuddies"];
                  
//                  
//                  NSFileManager *fileMgr = [NSFileManager defaultManager];
//                  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//                  NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
//                  
//                  NSString *pathToFolder = [documentsDirectory stringByAppendingPathComponent:@"Attachment"];
//                  
//                  NSArray *fileArray = [fileMgr contentsOfDirectoryAtPath:pathToFolder error:nil];
//                  for (NSString *filename in fileArray)  {
//                      
//                      [fileMgr removeItemAtPath:[pathToFolder stringByAppendingPathComponent:filename] error:NULL];
//                  }

                  
                  [SharedAppDelegate removeTabBarScreen];
              }];
             
         }
     }];
}

- (IBAction)btnSchedulTapped:(id)sender
{
   // [SharedAppDelegate btnScheduleTapped:nil];
    
    ScheduleListViewController *vcScheduleList = [[ScheduleListViewController alloc] initWithNibName:@"ScheduleListViewController" bundle:nil];
    navController=[[UINavigationController alloc] initWithRootViewController:vcScheduleList];
    navController.navigationBarHidden=YES;
    [self presentViewController:navController animated:YES completion:nil];
    
}


@end
