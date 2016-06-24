//
//  SettingViewController.m
//  TedBuddies
//
//  Created by Sunidhi Gupta on 28/11/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import "SettingViewController.h"
#import "ViewProfileViewController.h"
#import "PreferenceSettingViewController.h"
#import "TermsAndPrivacyViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.viewReportMessage.hidden = NO;
    
    arraySettingOption = [[NSArray alloc]initWithObjects:@"View Profile",@"Preference Settings",@"Terms Conditions",@"Privacy Policy",@"Report a Problem",@"Logout", nil];
    
    UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backSwipeAction)];
    [backSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:backSwipe];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
     [self.tabBarController.tabBar setHidden:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ----------- UITableView DataSource and Delegate ----------

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arraySettingOption count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
        UITableViewCell *cell = nil;
        static NSString *CellIdentifier = @"Cell";
        cell  = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        // if(cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CustomSettingCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

    UILabel *lblHeading = (UILabel *)[cell.contentView viewWithTag:10];
    lblHeading.text = [arraySettingOption objectAtIndex:indexPath.row];
    
    if(indexPath.row %2 == 0)
    {
        cell.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0];
        cell.contentView.backgroundColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:241.0/255.0 alpha:1.0];
    }
    else
    {
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    return cell;
        
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
        {
            ViewProfileViewController * viewProfile = [[ViewProfileViewController alloc]initWithNibName:@"ViewProfileViewController" bundle:nil];
            
            viewProfile.inviteButtonHidden = YES;
            viewProfile.editProfile = NO;
            [viewProfile setHidesBottomBarWhenPushed:NO];
            [viewProfile setBuddyId:[defaults objectForKey:kUserId]];
            [self.navigationController pushViewController:viewProfile animated:YES];
        }
            break;
        case 1:
        {
            PreferenceSettingViewController *preferenceSettingViewC = [[PreferenceSettingViewController alloc] initWithNibName:@"PreferenceSettingViewController" bundle:nil];
            [self.navigationController pushViewController:preferenceSettingViewC animated:YES];
        }
            break;
        case 2:
        {
            TermsAndPrivacyViewController *termsAndPrivacyViewC= [[TermsAndPrivacyViewController alloc] initWithNibName:@"TermsAndPrivacyViewController" bundle:nil];
            termsAndPrivacyViewC.headingName = @"Terms Condition";
            [self.navigationController pushViewController:termsAndPrivacyViewC animated:YES];
        }
            break;
        case 3:
        {
            TermsAndPrivacyViewController *termsAndPrivacyViewC= [[TermsAndPrivacyViewController alloc] initWithNibName:@"TermsAndPrivacyViewController" bundle:nil];
            termsAndPrivacyViewC.headingName = @"Privacy Policy";
            [self.navigationController pushViewController:termsAndPrivacyViewC animated:YES];

        }
            break;
        case 4:
        {
            [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"Are you sure you want to send report a problem?" leftButtonTitle:@"Yes" rightButtonTitle:@"Cancel" selectedButton:^(NSInteger selected, UIAlertView *aView)
             {
                 if (selected == 0)
                 {
                     self.viewReportMessage.hidden = NO;
                    [self.view addSubview:_viewReportMessage];
                 }
             }];
        }
            break;
        case 5:
        {
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
                          //BOOL toShowVideo = [[defaults valueForKey:kShowVideo] boolValue];

                          [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
                          [self.tabBarController setSelectedIndex:2];
                          [self.navigationController popViewControllerAnimated:NO];
                          
                          [SharedAppDelegate removeTabBarScreen];
                      }];
                     
                 }
             }];
            
        }
            break;
    
        default:
            break;
    }
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


#pragma mark ----------- Custom methods -------------

- (void)callApiServiceForReportAProblem
{
    
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
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



- (IBAction)backButtonClick:(UIButton *)sender
{
    [self backSwipeAction];
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

- (void)backSwipeAction
{
    [self.navigationController popViewControllerAnimated:YES];
}



@end
