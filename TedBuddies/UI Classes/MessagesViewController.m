//
//  MessagesViewController.m
//  TedBuddies
//
//  Created by Mayank Pahuja on 27/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import "MessagesViewController.h"
#import "PreferenceSettingViewController.h"
#import "MyWebSocket.h"
#import "ChatScreenViewController.h"
#import "CreateGroupViewController.h"
#import "SWRevealViewController.h"
#import "ViewProfileViewController.h"
#import "UITabBarController+HideTabBar.h"
#import "UITabBar+CustomBadge.h"
#import "HMSegmentedControl.h"


@interface MessagesViewController ()
{
    SWRevealViewController *revealController;
    BOOL isFirstTimeLoad;
    HMSegmentedControl *segmentedControl;
    NSInteger selectedSegment;
}
@end

@implementation MessagesViewController

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
    revealController = [self revealViewController];
    selectedSegment=0;
    isFirstTimeLoad=true;
    //[revealController panGestureRecognizer];
    //[revealController tapGestureRecognizer];
  [self setFonts];

    
    segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"DM", @"Per Course"]];
    segmentedControl.frame = CGRectMake(0, 0, self.viewSegment.frame.size.width-5, self.viewSegment.frame.size.height);
    segmentedControl.selectionIndicatorHeight = 3.0f;
    segmentedControl.backgroundColor = [UIColor clearColor];
    segmentedControl.selectedTitleTextAttributes =@{NSForegroundColorAttributeName : [UIColor colorWithRed:(119.0f/255.0f) green:(190.0f/255.0f) blue:(145.0f/255.0f) alpha:1]};
    segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 0, 0, 0);
    segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    segmentedControl.selectionIndicatorColor= [UIColor colorWithRed:(119.0f/255.0f) green:(190.0f/255.0f) blue:(145.0f/255.0f) alpha:1];
    [segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.viewSegment addSubview:segmentedControl];
    

    
  // Do any additional setup after loading the view from its nib.
}
- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl1
{
    
    selectedSegment=segmentedControl1.selectedSegmentIndex;
   
        [self.tableView reloadData];
    
}
- (void)viewDidAppear:(BOOL)animated
{
  [[MyWebSocket sharedInstance] connectSocket];
  
    [self callAPIRecentChats];
}
- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [self.tabBarController setTabBarHidden:NO animated:NO];
    [self.tabBarController.tabBar setHidden:NO];
    // FOR GOOGLE ANALYTICS
    
    self.screenName = @"Messages Screen";
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

-(void)setFonts
{
  [_lblNavBar setFont:FONT_REGULAR(kNavigationFontSize)];
  
  [_lblNumberOfMessage.layer setCornerRadius:4];
  [_lblNumberOfMessage setClipsToBounds:YES];
  
  [_searchBarMain setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
  [_searchBarMain setBackgroundImage:nil];
  
}


#pragma mark - button action

- (IBAction)btnAddTapped:(id)sender
{
  //    fromId
  //    toId
  //    isGroup     /// 0 or 1
  //    messageType ///1 for text, 2 for image, 3 for video, 4 for location
  //    deviceTimeStamp
  //    message
  
  //    NSDictionary *dictSend = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:@"1",@"2",@"0",@"1",[Utils getCurrentTimeStamp],@"Hi",nil] forKeys:[NSArray arrayWithObjects:kFromId,kToId,@"isGroup",@"messageType",@"deviceTimeStamp",@"message",nil]];
  //    NSDictionary *dictSend = @{
  //                               kFromId:@"10",
  //                               kToId:@"11",
  //                               @"isGroup":@"0",
  //                               @"messageType":@"1",
  //                               @"deviceTimeStamp":[@([Utils getCurrentTimeStamp]) stringValue],
  //                               @"message":@"Hello"
  //                               };
  
  //    NSDictionary *dictSend = @{
  //                               kFromId:@"10",
  //                               kToId:@"11",
  //                               @"isGroup":@"False",
  //                               };
  //    //    [[MyWebSocket sharedInstance] SendMessage:dictSend];
  //    [[MyWebSocket sharedInstance] SendMessageJson:dictSend];
  
  
  CreateGroupViewController *createGroup = [[CreateGroupViewController alloc] initWithNibName:@"CreateGroupViewController" bundle:Nil];
  [self.navigationController pushViewController:createGroup animated:YES];
}

- (IBAction)btnSettingTapped:(id)sender
{
  if([[defaults objectForKey:kUserId] isEqualToString:@"0"])
  {
    [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"Kindly login to use this feature" leftButtonTitle:@"OK" rightButtonTitle:@"Cancel" selectedButton:^(NSInteger selected, UIAlertView *aView)
     {
       if (selected == 0)
       {
         [SharedAppDelegate removeTabBarScreen];
       }
     }];
  }
  else
  {
      [revealController rightRevealToggle:sender];

//    PreferenceSettingViewController *settingViewC = [[PreferenceSettingViewController alloc] initWithNibName:@"PreferenceSettingViewController" bundle:nil];
//    settingViewC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:settingViewC animated:YES];
  }
  
}

- (IBAction)btnSearchTapped:(id)sender
{
    _searchBarMain.alpha=1.0f;
    [_searchBarMain becomeFirstResponder];
    
    [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, 146, _tableView.frame.size.width, _tableView.frame.size.height-_searchBarMain.frame.size.height)];

}
#pragma mark - webservices
- (void)callAPIRecentChats
{
    
  NSDictionary *dictSend = @{kUserId:[defaults objectForKey:kUserId]};
  
    if (isFirstTimeLoad)
    {
        [Utils startLoaderWithMessage:@""];
    }
  
  
  [Connection callServiceWithName:kGetRecentChatHistory postData:dictSend callBackBlock:^(id response, NSError *error)
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
         
         if ([[response objectForKeyNonNull:kResult] isKindOfClass:[NSArray class]]) {
           
           NSArray *array = [[NSArray alloc] initWithArray:[response objectForKeyNonNull:kResult]];
           if ([array count] > 0)
           {
             
             arrRecentChats = Nil;
             arrRecentChats = [[NSMutableArray alloc] init];
               
               arryClassChat = Nil;
               arryClassChat = [[NSMutableArray alloc] init];

             
             arrayFilteredContentList = Nil;
             arrayFilteredContentList = [[NSMutableArray alloc] init];
             
               arrayPerCourse=nil;
             arrayPerCourse=[[NSMutableArray alloc] init];
               for (int i=0; i<array.count; i++)
               {
                   if ([[[array objectAtIndex:i] valueForKey:kIsClass] boolValue])
                   {
                       [arrayPerCourse addObject:[array objectAtIndex:i]];
                       [arryClassChat addObject:[array objectAtIndex:i]];
                   }
                   else
                   {
                       [arrRecentChats addObject:[array objectAtIndex:i]];
                       [arrayFilteredContentList addObject:[array objectAtIndex:i]];
                   }
               }
             [_tableView reloadData];
             
             NSInteger totalUnread = 0;
             for (NSDictionary *dict in arrRecentChats)
             {
               totalUnread = totalUnread + [[dict objectForKey:kUnreadCount] intValue];
             }
               for (NSDictionary *dict in arrayPerCourse)
               {
                   totalUnread = totalUnread + [[dict objectForKey:kUnreadCount] intValue];
               }
             [_lblNumberOfMessage setText:[NSString stringWithFormat:@"%ld",(long)totalUnread]];
               if (totalUnread ==0)
               {
                   [self.tabBarController.tabBar setBadgeStyle:kCustomBadgeStyleNone value:totalUnread atIndex:2];

               }
               else
               {
                  [self.tabBarController.tabBar setBadgeStyle:kCustomBadgeStyleNumber value:totalUnread atIndex:2];
                  
               }
             
             if (_isFromPush && arrayFilteredContentList.count > 0)
             {
               _isFromPush = NO;
               NSDictionary *dictRow = [array objectAtIndex:0];
                 
                 if ([[dictRow objectForKey:kIsClass] boolValue] == NO)
                 {
                     NSMutableArray *arrGroupmembers = [[NSMutableArray alloc] initWithArray:[dictRow objectForKey:kGroupMember]];
                     NSString *strName = @"";
                     NSString *strId = @"";
                     NSString *imgUrl = @"";
                     if ([[dictRow objectForKey:kIsGroup] boolValue] == NO)
                     {
                         for (NSDictionary *dict in arrGroupmembers)
                         {
                             if (![[dict objectForKey:kUserId] isEqualToString:[defaults objectForKey:kUserId]])
                             {
                                 strName = [dict objectForKey:kUserName];
                                 imgUrl = [dict objectForKey:kProfileImage];
                                 strId = [dict objectForKey:kUserId];
                             }
                         }
                         NSDictionary *dictBuddyDetails = @{kBuddyId: strId,kBuddyName:strName,kBuddyImage:imgUrl,kIsGroup:[NSNumber numberWithBool:NO]};
                         
                         ChatScreenViewController *chatScreenViewC = [[ChatScreenViewController alloc] initWithNibName:@"ChatScreenViewController" bundle:nil];
                         [chatScreenViewC setDictBuddyInfo:dictBuddyDetails];
                         [chatScreenViewC setHidesBottomBarWhenPushed:YES];
                         [chatScreenViewC setIsGroup:NO];
                         [chatScreenViewC setIsClass:NO];
                         [self.navigationController pushViewController:chatScreenViewC animated:YES];
                         
                     }
                     else
                     {
                         
                         NSUInteger index = [arrGroupmembers indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
                             return [[(NSDictionary *)obj objectForKey:kUserId] isEqualToString:[defaults objectForKey:kUserId]];
                         }];
                         
                         if (index != NSNotFound) {
                             [arrGroupmembers removeObjectAtIndex:index];
                         }
                         
                         NSDictionary *dictBuddyDetails = @{kBuddyId: [dictRow objectForKey:kGroupId],kBuddyName:[dictRow objectForKey:kGroupName],kGroupMember:arrGroupmembers,kIsGroup:[NSNumber numberWithBool:YES],kIsmute:[dictRow objectForKey:kIsmute],@"groupId":[dictRow objectForKey:@"groupId"],@"isleft":[dictRow objectForKey:@"isleft"],@"leftDate":[dictRow objectForKey:@"leftDate"]};
                         ChatScreenViewController *chatScreenViewC = [[ChatScreenViewController alloc] initWithNibName:@"ChatScreenViewController" bundle:nil];
                         [chatScreenViewC setDictBuddyInfo:dictBuddyDetails];
                         [chatScreenViewC setHidesBottomBarWhenPushed:YES];
                         [chatScreenViewC setIsGroup:YES];
                         [chatScreenViewC setIsClass:NO];
                         [self.navigationController pushViewController:chatScreenViewC animated:YES];
                         
                     }

                 }
                 else
                 {
                                         NSMutableArray *arrGroupmembers = [[NSMutableArray alloc] initWithArray:[dictRow objectForKey:kGroupMember]];
                     
                     NSUInteger index = [arrGroupmembers indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
                         return [[(NSDictionary *)obj objectForKey:kUserId] isEqualToString:[defaults objectForKey:kUserId]];
                     }];
                     
                     if (index != NSNotFound) {
                         [arrGroupmembers removeObjectAtIndex:index];
                     }
                     
                     NSDictionary *dictBuddyDetails = @{kBuddyId: [dictRow objectForKey:kGroupId],kBuddyName:[dictRow objectForKey:kGroupName],kGroupMember:arrGroupmembers,kIsGroup:[NSNumber numberWithBool:YES],kIsmute:[dictRow objectForKey:kIsmute],@"groupId":[dictRow objectForKey:@"groupId"],@"isleft":[dictRow objectForKey:@"isleft"],@"leftDate":[dictRow objectForKey:@"leftDate"]};
                     ChatScreenViewController *chatScreenViewC = [[ChatScreenViewController alloc] initWithNibName:@"ChatScreenViewController" bundle:nil];
                     [chatScreenViewC setDictBuddyInfo:dictBuddyDetails];
                     [chatScreenViewC setHidesBottomBarWhenPushed:YES];
                     [chatScreenViewC setIsGroup:YES];
                     [chatScreenViewC setIsClass:YES];
                     [self.navigationController pushViewController:chatScreenViewC animated:YES];

                 }
             }
           }
           else
           {
             [Utils showAlertViewWithMessage:@"No Recent Chat found"];
           }
           
         }
         else
         {
           [Utils showAlertViewWithMessage:@"No Recent Chat found"];
         }
       }
       else {
         [Utils showAlertViewWithMessage:@"Server error"];
       }
     }
   }];
}


#pragma  mark - SearchBar Controller Delegate..

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
  [searchBar setShowsCancelButton:YES animated:YES];
  isSearching = YES;
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
  [searchBar setShowsCancelButton:NO animated:NO];
  
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
  [searchBar resignFirstResponder];
  NSLog(@"Cancel clicked");
  isSearching = NO;
    if (selectedSegment==0)
    {
        arrayFilteredContentList = nil;
        arrayFilteredContentList = [[NSMutableArray alloc] initWithArray:arrRecentChats];
    }
    else
    {
        arrayPerCourse = nil;
        arrayPerCourse = [[NSMutableArray alloc] initWithArray:arryClassChat];

    }
   
  [_tableView reloadData];
    
    _searchBarMain.alpha=0.0f;
    
    [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, 102, _tableView.frame.size.width, _tableView.frame.size.height+_searchBarMain.frame.size.height)];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
  NSLog(@"Search Clicked");
  [searchBar resignFirstResponder];
  [self searchTableList];
 
}

- (void)searchTableList
{
  NSString *searchString = _searchBarMain.text;
    
    if (selectedSegment==0)
    {
        arrayFilteredContentList = nil;
        arrayFilteredContentList = [[NSMutableArray alloc] init];

        for (NSDictionary *dictRow in arrRecentChats)
        {
            if ([[dictRow objectForKey:kIsGroup] boolValue] == NO)
            {
                NSString *strName = @"";
                NSArray *arrGroupmembers = [dictRow objectForKey:kGroupMember];
                
                for (NSDictionary *dict in arrGroupmembers)
                {
                    if (![[dict objectForKey:kUserId] isEqualToString:[defaults objectForKey:kUserId]])
                    {
                        strName = [dict objectForKey:kUserName];
                    }
                }
                if ([[strName lowercaseString] rangeOfString:[searchString lowercaseString]].location != NSNotFound)
                {
                    [arrayFilteredContentList addObject:dictRow];
                }
                
            }
            else
            {
                NSString *strName = @"";
                strName = [dictRow objectForKey:kGroupName];
                if ([[strName lowercaseString] rangeOfString:[searchString lowercaseString]].location != NSNotFound)
                {
                    [arrayFilteredContentList addObject:dictRow];
                }
            }
            
        }

    }
    else
    {
        arrayPerCourse = nil;
        arrayPerCourse = [[NSMutableArray alloc] init];

        for (NSDictionary *dictRow in arryClassChat)
        {
                NSString *strName = @"";
                strName = [dictRow objectForKey:kGroupName];
                if ([[strName lowercaseString] rangeOfString:[searchString lowercaseString]].location != NSNotFound)
                {
                    [arrayPerCourse addObject:dictRow];
                }
            
        }

    }
    
[_tableView reloadData];
  NSLog(@"arr:%@",arrayFilteredContentList);
}
#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (selectedSegment==0)
    {
        return arrayFilteredContentList.count;
 
    }
    else if (selectedSegment==1)
        
    {
        return arrayPerCourse.count;
        
    }
    return 0;
  }
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedSegment==0)
    {
        NSDictionary *dictRow = [arrayFilteredContentList objectAtIndex:indexPath.row];
        
        
        if ([[dictRow objectForKey:kIsGroup] boolValue] == NO)
        {
            NSArray *arrGroupmembers = [dictRow objectForKey:kGroupMember];
            UITableViewCell *cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"MessagesViewCell" owner:self options:nil] objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            
            
            UIImageView *imgViewSeperator = (UIImageView *)[cell.contentView viewWithTag:14];
            [imgViewSeperator.layer setBorderWidth:0.5];
            [imgViewSeperator.layer setBorderColor:kGrayGolor.CGColor];
            
            UIImageView *imgProfile = (UIImageView *)[cell.contentView viewWithTag:10];
            
            NSString *strName = @"";
            NSString *imgUrl = @"";
            
            UILabel *lblUnread = (UILabel*)[cell.contentView viewWithTag:15];
            [lblUnread.layer setCornerRadius:9];
            [lblUnread.layer setBorderWidth:2];
            [lblUnread.layer setBorderColor:[UIColor whiteColor].CGColor];
            
            lblUnread.text = [dictRow objectForKey:kUnreadCount];
            if ([[dictRow objectForKey:kUnreadCount] intValue] == 0)
            {
                [lblUnread setHidden:YES];
            }
            
            for (NSDictionary *dict in arrGroupmembers)
            {
                if (![[dict objectForKey:kUserId] isEqualToString:[defaults objectForKey:kUserId]])
                {
                    strName = [dict objectForKey:kUserName];
                    imgUrl = [dict objectForKey:kProfileImage];
                }
            }
            UILabel *lblName = (UILabel *)[cell.contentView viewWithTag:11];
            [lblName setTextColor:[UIColor darkGrayColor]];
            [lblName setText:strName];
            
            UILabel *lblDescription = (UILabel *)[cell.contentView viewWithTag:12];
            [lblDescription setFont:FONT_LIGHT(14)];
            lblDescription.textColor = [UIColor grayColor];
            
            UILabel *lblTime = (UILabel *)[cell.contentView viewWithTag:13];
            [lblTime setFont:FONT_LIGHT(10)];
            [lblTime setNumberOfLines:0];
            [lblTime setText:[[dictRow objectForKey:kCreatedDateChat] isEqualToString:@""]?@"":[Utils getFormatedTimeForDateString:[dictRow objectForKey:kCreatedDateChat] hourFormat24:NO]];
            lblTime.textColor = [UIColor grayColor];
            
            //        NSLog(@"%@",);
            
            [imgProfile.layer setCornerRadius:20];
            [imgProfile setClipsToBounds:YES];
            [imgProfile setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"appicon.png"]];
            
            lblDescription.text=[dictRow objectForKeyNonNull:kMessageSmall];
            [lblDescription setNumberOfLines:0];
            
            return cell;
        }
        else
        {
            NSMutableArray *arrGroupmembers = [[NSMutableArray alloc] initWithArray:[dictRow objectForKey:kGroupMember]];
            
            NSUInteger index = [arrGroupmembers indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
                return [[(NSDictionary *)obj objectForKey:kUserId] isEqualToString:[defaults objectForKey:kUserId]];
            }];
            
            if (index != NSNotFound) {
                [arrGroupmembers removeObjectAtIndex:index];
            }
            
            UITableViewCell *cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"MessagesViewCell" owner:self options:nil] objectAtIndex:(arrGroupmembers.count - 1)<3?(arrGroupmembers.count - 1):3];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            
            
            
            UIImageView *imgViewSeperator = (UIImageView *)[cell.contentView viewWithTag:14];
            [imgViewSeperator.layer setBorderWidth:0.5];
            [imgViewSeperator.layer setBorderColor:kGrayGolor.CGColor];
            
            
            
            NSString *strName = @"";
            strName = [dictRow objectForKey:kGroupName];
            
            UILabel *lblUnread = (UILabel*)[cell.contentView viewWithTag:15];
            [lblUnread.layer setCornerRadius:9];
            [lblUnread.layer setBorderWidth:2];
            [lblUnread.layer setBorderColor:[UIColor whiteColor].CGColor];
            lblUnread.text = [dictRow objectForKey:kUnreadCount];
            if ([[dictRow objectForKey:kUnreadCount] intValue] == 0)
            {
                [lblUnread setHidden:YES];
            }
            if (arrGroupmembers.count>1)
            {
                lblUnread.center = CGPointMake(29, 30);
            }
            
            
            UILabel *lblName = (UILabel *)[cell.contentView viewWithTag:11];
            [lblName setTextColor:[UIColor darkGrayColor]];
            [lblName setText:strName];
            
            UILabel *lblDescription = (UILabel *)[cell.contentView viewWithTag:12];
            [lblDescription setFont:FONT_LIGHT(14)];
            lblDescription.textColor = [UIColor grayColor];
            
            UILabel *lblTime = (UILabel *)[cell.contentView viewWithTag:13];
            [lblTime setFont:FONT_LIGHT(10)];
            [lblTime setNumberOfLines:0];
            [lblTime setText:[[dictRow objectForKey:kCreatedDateChat] isEqualToString:@""]?@"":[Utils getFormatedTimeForDateString:[dictRow objectForKey:kCreatedDateChat] hourFormat24:NO]];
            lblTime.textColor = [UIColor grayColor];
            
            
            NSString *imgUrl = @"";
            if (arrGroupmembers.count <4)
            {
                
                for (int i = 0; i < arrGroupmembers.count; i++)
                {
                    NSDictionary *dict = [arrGroupmembers objectAtIndex:i];
                    imgUrl = [dict objectForKey:kProfileImage];
                    UIImageView *imgProfile = (UIImageView *)[cell.contentView viewWithTag:16+i];
                    [imgProfile.layer setCornerRadius:10];
                    [imgProfile setClipsToBounds:YES];
                    [imgProfile setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"appicon.png"]];
                }
                
            }
            else
            {
                for (int i = 0; i < 4; i++)
                {
                    NSDictionary *dict = [arrGroupmembers objectAtIndex:i];
                    imgUrl = [dict objectForKey:kProfileImage];
                    UIImageView *imgProfile = (UIImageView *)[cell.contentView viewWithTag:16+i];
                    [imgProfile.layer setCornerRadius:10];
                    [imgProfile setClipsToBounds:YES];
                    [imgProfile setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"appicon.png"]];
                }
                UILabel *lblMemberCount = (UILabel*)[cell.contentView viewWithTag:10];
                [lblMemberCount.layer setCornerRadius:10];
                [lblMemberCount setClipsToBounds:YES];
                [lblMemberCount setText:[NSString stringWithFormat:@"+%lu",arrGroupmembers.count-3]];
            }
            
            lblDescription.text=[dictRow objectForKeyNonNull:kMessageSmall];
            [lblDescription setNumberOfLines:0];
            
            return cell;
        }
    }
    else if (selectedSegment==1)
        
    {
        NSMutableDictionary *dictRow=[arrayPerCourse objectAtIndex:indexPath.row];
        NSMutableArray *arrGroupmembers = [[NSMutableArray alloc] initWithArray:[dictRow objectForKey:kGroupMember]];
        
        NSUInteger index = [arrGroupmembers indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
            return [[(NSDictionary *)obj objectForKey:kUserId] isEqualToString:[defaults objectForKey:kUserId]];
        }];
        
        if (index != NSNotFound) {
            [arrGroupmembers removeObjectAtIndex:index];
        }
        
        UITableViewCell *cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"MessagesViewCell" owner:self options:nil] objectAtIndex:(arrGroupmembers.count - 1)<3?(arrGroupmembers.count - 1):3];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        
        
        UIImageView *imgViewSeperator = (UIImageView *)[cell.contentView viewWithTag:14];
        [imgViewSeperator.layer setBorderWidth:0.5];
        [imgViewSeperator.layer setBorderColor:kGrayGolor.CGColor];
        
        
        
        NSString *strName = @"";
        strName = [dictRow objectForKey:kGroupName];
        
        UILabel *lblUnread = (UILabel*)[cell.contentView viewWithTag:15];
        [lblUnread.layer setCornerRadius:9];
        [lblUnread.layer setBorderWidth:2];
        [lblUnread.layer setBorderColor:[UIColor whiteColor].CGColor];
        
        lblUnread.text = [dictRow objectForKey:kUnreadCount];
        if ([[dictRow objectForKey:kUnreadCount] intValue] == 0)
        {
            [lblUnread setHidden:YES];
        }
        
        if (arrGroupmembers.count>1)
        {
            lblUnread.center = CGPointMake(29, 30);
        }
        
        UILabel *lblName = (UILabel *)[cell.contentView viewWithTag:11];
        [lblName setTextColor:[UIColor darkGrayColor]];
        [lblName setText:strName];
        
        UILabel *lblDescription = (UILabel *)[cell.contentView viewWithTag:12];
        [lblDescription setFont:FONT_LIGHT(14)];
        lblDescription.textColor = [UIColor grayColor];
        
        UILabel *lblTime = (UILabel *)[cell.contentView viewWithTag:13];
        [lblTime setFont:FONT_LIGHT(10)];
        [lblTime setNumberOfLines:0];
        [lblTime setText:[[dictRow objectForKey:kCreatedDateChat] isEqualToString:@""]?@"":[Utils getFormatedTimeForDateString:[dictRow objectForKey:kCreatedDateChat] hourFormat24:NO]];
        lblTime.textColor = [UIColor grayColor];
        
        
        NSString *imgUrl = @"";
        if (arrGroupmembers.count <4)
        {
            
            for (int i = 0; i < arrGroupmembers.count; i++)
            {
                NSDictionary *dict = [arrGroupmembers objectAtIndex:i];
                imgUrl = [dict objectForKey:kProfileImage];
                UIImageView *imgProfile = (UIImageView *)[cell.contentView viewWithTag:16+i];
                [imgProfile.layer setCornerRadius:10];
                [imgProfile setClipsToBounds:YES];
                [imgProfile setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"appicon.png"]];
            }
            
        }
        else
        {
            for (int i = 0; i < 4; i++)
            {
                NSDictionary *dict = [arrGroupmembers objectAtIndex:i];
                imgUrl = [dict objectForKey:kProfileImage];
                UIImageView *imgProfile = (UIImageView *)[cell.contentView viewWithTag:16+i];
                [imgProfile.layer setCornerRadius:10];
                [imgProfile setClipsToBounds:YES];
                [imgProfile setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"appicon.png"]];
            }
            UILabel *lblMemberCount = (UILabel*)[cell.contentView viewWithTag:10];
            [lblMemberCount.layer setCornerRadius:10];
            [lblMemberCount setClipsToBounds:YES];
            [lblMemberCount setText:[NSString stringWithFormat:@"+%lu",(unsigned long)arrGroupmembers.count-3]];
        }
        
        lblDescription.text=[dictRow objectForKeyNonNull:kMessageSmall];
        [lblDescription setNumberOfLines:0];
        
        return cell;

    }

    return nil;


}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedSegment==0)
    {
        NSDictionary *dictRow = [arrayFilteredContentList objectAtIndex:indexPath.row];
        NSMutableArray *arrGroupmembers = [[NSMutableArray alloc] initWithArray:[dictRow objectForKey:kGroupMember]];
        NSString *strName = @"";
        NSString *strId = @"";
        NSString *imgUrl = @"";
        if ([[dictRow objectForKey:kIsGroup] boolValue] == NO)
        {
            
            for (NSDictionary *dict in arrGroupmembers)
            {
                if (![[dict objectForKey:kUserId] isEqualToString:[defaults objectForKey:kUserId]])
                {
                    strName = [dict objectForKey:kUserName];
                    imgUrl = [dict objectForKey:kProfileImage];
                    strId = [dict objectForKey:kUserId];
                }
            }
            NSDictionary *dictBuddyDetails = @{kBuddyId: strId,kBuddyName:strName,kBuddyImage:imgUrl,kIsGroup:[NSNumber numberWithBool:NO]};
            
            ChatScreenViewController *chatScreenViewC = [[ChatScreenViewController alloc] initWithNibName:@"ChatScreenViewController" bundle:nil];
            [chatScreenViewC setDictBuddyInfo:dictBuddyDetails];
            [chatScreenViewC setHidesBottomBarWhenPushed:YES];
            [chatScreenViewC setIsGroup:NO];
            [chatScreenViewC setIsClass:NO];
            [self.navigationController pushViewController:chatScreenViewC animated:YES];
        }
        else
        {
            NSUInteger index = [arrGroupmembers indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
                return [[(NSDictionary *)obj objectForKey:kUserId] isEqualToString:[defaults objectForKey:kUserId]];
            }];
            
            if (index != NSNotFound) {
                [arrGroupmembers removeObjectAtIndex:index];
            }
            
            NSDictionary *dictBuddyDetails = @{kBuddyId: [dictRow objectForKey:kGroupId],kBuddyName:[dictRow objectForKey:kGroupName],kGroupMember:arrGroupmembers,kIsGroup:[NSNumber numberWithBool:YES],kIsmute:[dictRow objectForKey:kIsmute],@"groupId":[dictRow objectForKey:@"groupId"],@"isleft":[dictRow objectForKey:@"isleft"],@"leftDate":[dictRow objectForKey:@"leftDate"]};
            ChatScreenViewController *chatScreenViewC = [[ChatScreenViewController alloc] initWithNibName:@"ChatScreenViewController" bundle:nil];
            [chatScreenViewC setDictBuddyInfo:dictBuddyDetails];
            [chatScreenViewC setHidesBottomBarWhenPushed:YES];
            [chatScreenViewC setIsGroup:YES];
             [chatScreenViewC setIsClass:NO];
            [self.navigationController pushViewController:chatScreenViewC animated:YES];
        }

    }
    else if (selectedSegment==1)
        
    {
        NSDictionary *dictRow = [arrayPerCourse objectAtIndex:indexPath.row];
        NSMutableArray *arrGroupmembers = [[NSMutableArray alloc] initWithArray:[dictRow objectForKey:kGroupMember]];
        
        NSUInteger index = [arrGroupmembers indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
            return [[(NSDictionary *)obj objectForKey:kUserId] isEqualToString:[defaults objectForKey:kUserId]];
        }];
        
        if (index != NSNotFound) {
            [arrGroupmembers removeObjectAtIndex:index];
        }
        
        NSDictionary *dictBuddyDetails = @{kBuddyId: [dictRow objectForKey:kGroupId],kBuddyName:[dictRow objectForKey:kGroupName],kGroupMember:arrGroupmembers,kIsGroup:[NSNumber numberWithBool:YES],kIsmute:[dictRow objectForKey:kIsmute],@"groupId":[dictRow objectForKey:@"groupId"],@"isleft":[dictRow objectForKey:@"isleft"],@"leftDate":[dictRow objectForKey:@"leftDate"]};
        ChatScreenViewController *chatScreenViewC = [[ChatScreenViewController alloc] initWithNibName:@"ChatScreenViewController" bundle:nil];
        [chatScreenViewC setDictBuddyInfo:dictBuddyDetails];
        [chatScreenViewC setHidesBottomBarWhenPushed:YES];
        [chatScreenViewC setIsGroup:YES];
         [chatScreenViewC setIsClass:YES];
        [self.navigationController pushViewController:chatScreenViewC animated:YES];


    }
}
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete)
//    {
//        //add code here for when you hit delete
//    }
//}

#pragma mark - button action
- (IBAction)btnBackTapped:(id)sender
{
  //[self.tabBarController setSelectedIndex:2];
  //[self.navigationController popToRootViewControllerAnimated:YES];
    ViewProfileViewController * viewProfile = [[ViewProfileViewController alloc]initWithNibName:@"ViewProfileViewController" bundle:nil];
    viewProfile.inviteButtonHidden = YES;
    viewProfile.editProfile = NO;
    [self.tabBarController.tabBar setHidden:YES];
    [viewProfile setHidesBottomBarWhenPushed:NO];
    [viewProfile setBuddyId:[defaults objectForKey:kUserId]];
    [self.navigationController pushViewController:viewProfile animated:YES];

}
@end
