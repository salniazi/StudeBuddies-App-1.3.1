//
//  AddFacebookFriendsViewController.m
//  TedBuddies
//
//  Created by Mayank Pahuja on 17/11/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import "AddFacebookFriendsViewController.h"
#import "ViewProfileViewController.h"
#import "PendingRequestsViewController.h"
#import "ChatScreenViewController.h"
#import "TAFacebookHelper.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@interface AddFacebookFriendsViewController ()
{
    NSString *nextURL;
}

@end

@implementation AddFacebookFriendsViewController

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
    
    arrayBuddies = [[NSMutableArray alloc] init];
    //call service
    [self callAPIFindBuddies];
    
    // add ovserver
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tabBarController.tabBar setHidden:NO];
    [self setFonts];
}



- (void)setFonts
{
    //[self callAPIFindBuddies];
    
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

- (void)callAPISendInviteToBuddy:(NSString*)buddyId
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
                              buddyId,kBuddyId,
                              nil];
    
    [Utils startLoaderWithMessage:@""];
    
    [Connection callServiceWithName:KSendInvitaion postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         [Utils stopLoader];
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 
                 
                 NSString *message=[NSString stringWithFormat:@"%@",[response objectForKeyNonNull:kMessage]];
                 [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:message buttonArray:@[@"OK"] selectedButton:^(NSInteger selected, UIAlertView *aView)
                  {
                      [self callAPIFindBuddies];
                      [_tableView reloadData];
                  }];
             }
         }
     }];
    
}

- (void)callAPIFindBuddies
{
    
    NSArray *permissionsArray = [[NSArray alloc] initWithObjects:
                                 @"user_friends",
                                 @"user_photos",
                                 @"email",
                                 nil];
    [Utils startLoaderWithMessage:@""];
    
    [TAFacebookHelper fetchFriendListWithParams:@"" withPermissions:permissionsArray completionHandler:^(id response, NSError *e)
     {
         [Utils stopLoader];
         NSLog(@"response:%@",response);
         if (response)
         {
             NSArray *array = [[NSArray alloc] initWithArray:[response objectForKey:@"data"]];
             nextURL=[[response objectForKey:@"paging"] objectForKey:@"next"];
             
             if (array.count > 0)
             {
                 
                 for (NSDictionary *dict in array)
                 {
                     [arrayBuddies addObject:dict];
                 }
                 [_tableView reloadData];
                 
                 //                 NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                 //                                           [defaults objectForKey:kUserId],kUserId,
                 //                                           arrSendRequest,kContactList,
                 //                                           @"1",kSyncingType,
                 //                                           nil];
                 //                 [Utils startLoaderWithMessage:@""];
                 //                 [Connection callServiceWithName:kGetContactSyncing postData:dictSend callBackBlock:^(id response, NSError *error)
                 //                  {
                 //                      [Utils stopLoader];
                 //                      if (response)
                 //                      {
                 //                          if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
                 //                          {
                 //
                 //                               NSArray *arr = [[NSArray alloc]initWithArray:[response objectForKeyNonNull:kResult]];
                 //
                 //                              [arrayBuddies removeAllObjects];
                 //                              for (NSDictionary *dictReceived in arr)
                 //                              {
                 //                                  if (([[dictReceived objectForKey:kIsBuddy] integerValue] == kStatusNotFriend) && (![[dictReceived objectForKey:kBuddyId] isEqualToString:[defaults objectForKey:kUserId]]))
                 //                                  {
                 //                                      [arrayBuddies addObject:dictReceived];
                 //                                  }
                 //                              }
                 //
                 //
                 //
                 //                              [_tableView reloadData];
                 //                          }
                 //                      }
                 //                  }];
             }
             else
             {
                 
             }
             //             NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
             //                                       [defaults objectForKey:kUserId],kUserId,
             //                                       @"0",kPage,
             //                                       nil];
             //             [Utils startLoaderWithMessage:@""];
             //             [Connection callServiceWithName:kFindBuddies postData:dictSend callBackBlock:^(id response, NSError *error)
             //              {
             //                  [Utils stopLoader];
             //                  if (response)
             //                  {
             //                      if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             //                      {
             //                          arrayBuddies = nil;
             //                          arrayBuddies = [[NSArray alloc] initWithArray:[response objectForKeyNonNull:kResult]];
             //                          [_tableView reloadData];
             //                      }
             //                  }
             //              }];
         }
         else
         {
             [Utils stopLoader];
             [self.navigationController popViewControllerAnimated:YES];
         }
     }];
    
}

#pragma mark - button action

- (IBAction)btnBackTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)btnMessageFindTapped:(UIButton*)sender withEvent:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint: currentTouchPosition];
    NSDictionary *dictBuddyDetails = @{kBuddyId: [[arrayBuddies objectAtIndex:indexPath.row] objectForKey:kBuddyId],kBuddyName:[[arrayBuddies objectAtIndex:indexPath.row] objectForKey:kBuddyName],kBuddyImage:[[arrayBuddies objectAtIndex:indexPath.row] objectForKey:kBuddyImage]};
    ChatScreenViewController *chatScreenViewC = [[ChatScreenViewController alloc] initWithNibName:@"ChatScreenViewController" bundle:nil];
    [chatScreenViewC setDictBuddyInfo:dictBuddyDetails];
    [chatScreenViewC setHidesBottomBarWhenPushed:YES];
    [chatScreenViewC setIsGroup:NO];
    [self.navigationController pushViewController:chatScreenViewC animated:YES];
}

- (void)btnAddTapped:(UIButton*)sender withEvent:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint: currentTouchPosition];
    NSDictionary *tempDict = arrayBuddies[indexPath.row];
    [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"Add as friend?" buttonArray:[NSArray arrayWithObjects:@"Yes",@"Cancel",nil] selectedButton:^(NSInteger selected, UIAlertView *aView)
     {
         if ( selected == 0)
         {
             [self callAPISendInviteToBuddy:[tempDict objectForKeyNonNull:kBuddyId]];
         }
         else
         {
             
         }
     }];
}


#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayBuddies count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"FindBuddiesCell" owner:self options:nil] lastObject];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView *imgProfile = (UIImageView *)[cell.contentView viewWithTag:10];
    UILabel *lblName = (UILabel *)[cell.contentView viewWithTag:11];
    
    UIButton *btnAddBG = (UIButton*)[cell.contentView viewWithTag:15];
    [btnAddBG.layer setBorderColor:kBlueColor.CGColor];
    [btnAddBG.layer setBorderWidth:kButtonBorderWidth];
    [btnAddBG.layer setCornerRadius:kButtonCornerRadius];
    btnAddBG.hidden=YES;
    
    UIButton *btnInvite = (UIButton*)[cell.contentView viewWithTag:14];
    [btnInvite setTitle:@"Invite" forState:UIControlStateNormal];
    [btnInvite.layer setBorderColor:kBlueColor.CGColor];
    [btnInvite.layer setBorderWidth:kButtonBorderWidth];
    [btnInvite.layer setCornerRadius:kButtonCornerRadius];
    [btnInvite addTarget:self action:@selector(btnInviteTappade:) forControlEvents:UIControlEventTouchUpInside];
    btnInvite.hidden=NO;
    
    
    UIButton *btnInviteCheck = (UIButton*)[cell.contentView viewWithTag:20];
    btnInviteCheck.hidden = YES;
    
    UIButton *btnMessage = (UIButton*)[cell.contentView viewWithTag:12];
    [btnMessage addTarget:self action:@selector(btnMessageFindTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    btnMessage.hidden=YES;
    
    
    
    NSDictionary *tempDict = arrayBuddies[indexPath.row];
    
    
    if (indexPath.row % 2 == 0)
    {
        [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    }
    else
    {
        [cell.contentView setBackgroundColor:kGrayGolor];
    }
    NSString *imgname=[NSString stringWithFormat:@"%@",[[[tempDict objectForKeyNonNull:@"picture"]objectForKeyNonNull:@"data"] objectForKeyNonNull:@"url"]];
    [imgProfile setImageWithURL:[NSURL URLWithString:imgname]placeholderImage:[UIImage imageNamed:@"gaust_user.png"]];
    
    [lblName setText:[tempDict objectForKeyNonNull:@"name"]];
    [lblName setFont:FONT_REGULAR(14)];
    
    [imgProfile.layer setCornerRadius:22];
    [imgProfile setClipsToBounds:YES];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    NSDictionary *tempDict = arrayBuddies[indexPath.row];
    //    ViewProfileViewController * viewProfile = [[ViewProfileViewController alloc]initWithNibName:@"ViewProfileViewController" bundle:nil];
    //    viewProfile.editProfile = YES;
    //    viewProfile.isViewProfile = YES;
    //    
    //    
    //    viewProfile.inviteButtonHidden = NO;
    //    [viewProfile setBuddyId:[tempDict objectForKeyNonNull:kBuddyId]];
    //    [self.navigationController pushViewController:viewProfile animated:YES];
}

-(IBAction)btnInviteTappade:(id)sender{
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    
//    [TAFacebookHelper postText:@"Please download StudeBuddies App." OnFriendsWall:[[arrayBuddies objectAtIndex:indexPath.row] valueForKey:@"id"] completetionHandler:^(id resultSend, NSError *e)
//    {
//        NSLog(@"%@",resultSend);
//    }];

    
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:@"https://itunes.apple.com/in/app/studebuddies/id983872682?mt=8"];
    content.quote = @"Please Download Studebuddies App.";
    [FBSDKShareDialog showFromViewController:self
                                 withContent:content
                                    delegate:nil];
}
@end
