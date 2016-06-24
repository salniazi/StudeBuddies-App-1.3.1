//
//  FindBuddiesViewController.m
//  TedBuddies
//
//  Created by Sunil on 08/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import "PendingRequestsViewController.h"
#import "ViewProfileViewController.h"
#import "UITabBarController+HideTabBar.h"
#import "SWRevealViewController.h"
#import "UITabBar+CustomBadge.h"


@interface PendingRequestsViewController ()
{
    SWRevealViewController *revealController;
    BOOL isFirstTimeLoad;
}

@end

@implementation PendingRequestsViewController

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

    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController setTabBarHidden:NO animated:NO];
    [self.tabBarController.tabBar setHidden:NO];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
   
    [self setFonts];
}

- (void)setFonts
{
    [self callAPIFindBuddies];
    UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backSwipeAction)];
    [backSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:backSwipe];
    [_lblNavBar setFont:FONT_REGULAR(kNavigationFontSize)];
    
    
}
#pragma mark - gesture recognizer action

- (void)backSwipeAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - web service
- (void)callAPIFindBuddies
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
                              nil];
    if (isFirstTimeLoad)
    {
        [Utils startLoaderWithMessage:@""];

    }
    
    [Connection callServiceWithName:kGetPendingRequest postData:dictSend callBackBlock:^(id response, NSError *error)
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
                 arrayBuddies = nil;
                 arrayBuddies = [[NSArray alloc] initWithArray:[response objectForKeyNonNull:kResult]];
                 [_tableView reloadData];
                 if (arrayBuddies.count == 0)
                 {
                     [self.tabBarController.tabBar setBadgeStyle:kCustomBadgeStyleNone value:arrayBuddies.count atIndex:4];
                    
                     [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"There are no pending requests" buttonArray:[NSArray arrayWithObjects:@"OK", nil] selectedButton:^(NSInteger selected, UIAlertView *aView)
                     {
                         [self.navigationController popViewControllerAnimated:YES];
                     }];
                 }
                 else
                 {
                     [self.tabBarController.tabBar setBadgeStyle:kCustomBadgeStyleNumber value:arrayBuddies.count atIndex:4];

                 }
             }
         }
     }];
}

#pragma mark - button action

- (IBAction)btnBackTapped:(id)sender
{
    
    //[self backSwipeAction];
    ViewProfileViewController * viewProfile = [[ViewProfileViewController alloc]initWithNibName:@"ViewProfileViewController" bundle:nil];
    viewProfile.inviteButtonHidden = YES;
    viewProfile.editProfile = NO;
    [self.tabBarController.tabBar setHidden:YES];
    [viewProfile setHidesBottomBarWhenPushed:NO];
    [viewProfile setBuddyId:[defaults objectForKey:kUserId]];
    [self.navigationController pushViewController:viewProfile animated:YES];
    
}
- (IBAction)settingButtonClick:(id)sender
{
    if([[defaults objectForKey:kUserId] isEqualToString:@"0"])
    {
        [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"Kindly login to use this feature" leftButtonTitle:@"OK" rightButtonTitle:@"Cancel" selectedButton:^(NSInteger selected, UIAlertView *aView)
         {
             if (selected == 0)
             {
             }
         }];
    }
    else
    {
        [revealController rightRevealToggle:sender];
    }
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayBuddies count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"PendingBuddiesCell" owner:self options:nil] lastObject];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView *imgProfile = (UIImageView *)[cell.contentView viewWithTag:10];
    UILabel *lblName = (UILabel *)[cell.contentView viewWithTag:11];
    
    tempDict = arrayBuddies[indexPath.row];
    
    
    if (indexPath.row % 2 == 0)
    {
        [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    }
    else
    {
        [cell.contentView setBackgroundColor:kGrayGolor];
    }
    NSString *imgname=[NSString stringWithFormat:@"%@",[tempDict objectForKeyNonNull:kBuddyImage]];
    [imgProfile setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImageURl,imgname]]placeholderImage:[UIImage imageNamed:@"gaust_user.png"]];
    
    
    [lblName setText:[tempDict objectForKeyNonNull:kBuddyName]];
    [lblName setFont:FONT_REGULAR(14)];
    
    [imgProfile.layer setCornerRadius:22];
    [imgProfile setClipsToBounds:YES];
    
    UIButton * acceptButton = (UIButton *) [cell.contentView viewWithTag:12];
    [acceptButton.layer setBorderWidth:kButtonBorderWidth];
    [acceptButton.layer setBorderColor:kBlueColor.CGColor];
    [acceptButton.layer setCornerRadius:kButtonCornerRadius];
    [acceptButton setTitleColor:kBlueColor forState:UIControlStateNormal];
    
    [acceptButton addTarget:self action:@selector(btnAcceptAction:) forControlEvents:UIControlEventTouchUpInside];
    acceptButton.tag = indexPath.row;
    
    UIButton * beleteButton = (UIButton *) [cell.contentView viewWithTag:13];
    [beleteButton addTarget:self action:@selector(btnDeleteAction:) forControlEvents:UIControlEventTouchUpInside];
    beleteButton.tag = indexPath.row;
    [beleteButton.layer setBorderWidth:kButtonBorderWidth];
    [beleteButton.layer setBorderColor:kBlueColor.CGColor];
    [beleteButton.layer setCornerRadius:kButtonCornerRadius];
    [beleteButton setTitleColor:kBlueColor forState:UIControlStateNormal];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dictBuddy = arrayBuddies[indexPath.row];
    ViewProfileViewController * viewProfile = [[ViewProfileViewController alloc]initWithNibName:@"ViewProfileViewController" bundle:nil];
    viewProfile.editProfile = YES;
    viewProfile.isViewProfile = YES;

    [viewProfile setBuddyId:[dictBuddy objectForKeyNonNull:kBuddyId]];
    [self.navigationController pushViewController:viewProfile animated:YES];
}

#pragma mark = button naction
-(void)btnAcceptAction:(UIButton  *) sender
{
    
    [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"Are you sure you want to accept this request?" leftButtonTitle:@"OK" rightButtonTitle:@"Cancel" selectedButton:^(NSInteger selected, UIAlertView *aView)
     {
         if (selected == 0)
         {
             tempDict = [arrayBuddies objectAtIndex:sender.tag];
             NSString * BuddyId =[tempDict objectForKeyNonNull:@"buddyId"];
             NSLog(@"%@",BuddyId);
             
             NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [defaults objectForKey:kUserId],kUserId,
                                       BuddyId,kBuddyId,
                                       @"true",kIsAccepted,
                                       nil];
             
             [Utils startLoaderWithMessage:@""];
             [Connection callServiceWithName:kRespondInvitation postData:dictSend callBackBlock:^(id response, NSError *error)
              {
                  [Utils stopLoader];
                  if (response)
                  {
                      if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
                      {
                          NSLog(@"Now You are friend");
                          [self callAPIFindBuddies];
                      }
                  }
              }];
         }
     }];
    
    
}


-(void)btnDeleteAction:(UIButton  *) sender
{
    [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"Are you sure you want to reject this request?" leftButtonTitle:@"OK" rightButtonTitle:@"Cancel" selectedButton:^(NSInteger selected, UIAlertView *aView)
     {
         if (selected == 0)
         {
             tempDict = [arrayBuddies objectAtIndex:sender.tag];
             NSString * BuddyId =[tempDict objectForKeyNonNull:@"buddyId"];
             NSLog(@"%@",BuddyId);
             NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [defaults objectForKey:kUserId],kUserId,
                                       BuddyId,kBuddyId,
                                       @"false",kIsAccepted,
                                       nil];
             
             [Utils startLoaderWithMessage:@""];
             [Connection callServiceWithName:kRespondInvitation postData:dictSend callBackBlock:^(id response, NSError *error)
              {
                  [Utils stopLoader];
                  if (response)
                  {
                      if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
                      {
                          [self callAPIFindBuddies];
                          NSLog(@"Now You are not friend");
                      }
                  }
              }];
         }
     }];
    
}
@end
