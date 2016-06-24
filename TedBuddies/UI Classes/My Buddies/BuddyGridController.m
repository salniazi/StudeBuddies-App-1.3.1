//
//  BuddyGridController.m
//  TedBuddies
//
//  Created by Sourabh on 15/05/15.
//  Copyright (c) 2015 Mayank Pahuja. All rights reserved.
//

#import "BuddyGridController.h"
#import "BuddyCollectionViewCell.h"
#import "ViewProfileViewController.h"
#import "FindBuddiesViewController.h"
#import "HomeViewController.h"
#import "ChatScreenViewController.h"
#import "MyWebSocket.h"
#import "UITabBarController+HideTabBar.h"
#import "AddFacebookFriendsViewController.h"
#import "AddContactFriendsViewController.h"
#import "MHFacebookImageViewer.h"
#import "UIImageView+MHFacebookImageViewer.h"
#import "ModalProfilePic.h"
#import "SWRevealViewController.h"
#import "HMSegmentedControl.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>




@interface BuddyGridController () <SBCollectionCellTappedDelegate,SWRevealViewControllerDelegate,FBSDKSharingDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate>
@property (nonatomic , assign) BOOL suggestedBuddies;
@property(nonatomic , strong) NSMutableArray *arrayProfileDetails;
@property (strong,nonatomic) NSMutableDictionary * dictGetEditProfileDetails;
@property (strong , nonatomic) NSMutableArray *photos;
@property (strong , nonatomic) NSMutableArray *thumbs;
@property (weak, nonatomic) IBOutlet UIButton *btnMyBuddies;
@property (weak, nonatomic) IBOutlet UIButton *btnSuggestedBuddies;
@property (weak, nonatomic) IBOutlet UIButton *btnSendInviteButton;


@end

@implementation BuddyGridController
{
    SWRevealViewController *revealController;
  
    NSInteger pageSuggestBuddy;
    
    NSMutableArray *SuggestBuddy;
    
     NSInteger selectedSegment;
    HMSegmentedControl *segmentedControl;
   
}
- (void)viewDidLoad {
    [super viewDidLoad];
   
     SuggestBuddy=[[NSMutableArray alloc] init];
    pageSuggestBuddy=1;
    _suggestedBuddies = FALSE;
    revealController = [self revealViewController];
    revealController.delegate=self;
    // Clear cache for testing
    // Do any additional setup after loading the view from its nib.
    [self.buddyCollectionView registerNib:[UINib nibWithNibName:@"MYBuddyCells" bundle:nil] forCellWithReuseIdentifier:@"BuddyCell"];
    [[MyWebSocket sharedInstance] connectSocket];
    //[self.tabBarController.tabBar setHidden:NO];
    //[self setFonts];
    if(_fromScene == COMINGFROM_MYBUDDIES)
    {
        [self callAPIMyBuddies];
    }
    else
    {
        self.buddiesHeaderLabel.text = @"Suggested Buddies";
        [self callAPIFindBuddies];
    }
    [self.btnMyBuddies setTitleColor:[self getColor] forState:UIControlStateNormal];
    
    
    segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Suggested", @"My Buddies", @"Invite"]];
    segmentedControl.frame = CGRectMake(0, 0, self.viewSegement.frame.size.width, self.viewSegement.frame.size.height);
    segmentedControl.selectedSegmentIndex=1;
    segmentedControl.selectionIndicatorHeight = 3.0f;
    segmentedControl.backgroundColor = [UIColor clearColor];
    segmentedControl.selectedTitleTextAttributes =@{NSForegroundColorAttributeName : [self getColor]};
    segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 0, 0, 0);
    segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    segmentedControl.selectionIndicatorColor= [self getColor];
    [segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.viewSegement addSubview:segmentedControl];

    
    /*
     [self.btnNewYapper setTitleColor:[self getColor] forState:UIControlStateNormal];
     [self.btnHotYapper setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
     [self.btnClassYapper setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
     */
    
    
}
- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl
{
    
    selectedSegment=segmentedControl.selectedSegmentIndex;
    
    if (selectedSegment==0)
    {
        pageSuggestBuddy=1;
        _suggestedBuddies = TRUE;
        self.buddiesHeaderLabel.text = @"Suggested Buddies";
        [self callAPIFindBuddies];
        [self.buddyCollectionView setHidden:NO];
        [self.btnSuggestedBuddies setTitleColor:[self getColor] forState:UIControlStateNormal];
        [self.btnSendInviteButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.btnMyBuddies setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];

    }
    if (selectedSegment==1)
    {
        _suggestedBuddies = FALSE;
        self.buddiesHeaderLabel.text = @"My Buddies";
        [self callAPIMyBuddies];
        [self.buddyCollectionView setHidden:NO];
        [self.btnSuggestedBuddies setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.btnSendInviteButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.btnMyBuddies setTitleColor:[self getColor] forState:UIControlStateNormal];

    }
    if (selectedSegment==2)
    {
        _suggestedBuddies = FALSE;
        [self.buddyCollectionView setHidden:YES];
        [self.btnSuggestedBuddies setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.btnSendInviteButton setTitleColor:[self getColor] forState:UIControlStateNormal];
        [self.btnMyBuddies setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
          UIActionSheet *inviteActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Invite by text",@"Invite by email",@"Share on Facebook",nil];
        inviteActionSheet.delegate = self;
        [inviteActionSheet showFromTabBar:SharedAppDelegate.tabBarController.tabBar];

    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float endScrolling = (scrollView.contentOffset.y + scrollView.frame.size.height);
    if (endScrolling >= scrollView.contentSize.height)
    {
        if(_suggestedBuddies)
        {
            pageSuggestBuddy=pageSuggestBuddy+1;
            [self callAPIFindBuddies];
        }
        
        
        
    }
    

  }
-(UIColor *)getColor
{
    return [UIColor colorWithRed:(119.0f/255.0f) green:(190.0f/255.0f) blue:(145.0f/255.0f) alpha:1];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController setTabBarHidden:NO animated:NO];
    [self.tabBarController.tabBar setHidden:NO];
    
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
     if (SharedAppDelegate.isChangePreference)
    {
        pageSuggestBuddy=1;
        [self callAPIFindBuddies];
    }

    [self setFonts];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

- (IBAction)btnSuggestedClicked:(id)sender
{
    _suggestedBuddies = TRUE;
    self.buddiesHeaderLabel.text = @"Suggested Buddies";
    [self callAPIFindBuddies];
    [self.buddyCollectionView setHidden:NO];
    [self.btnSuggestedBuddies setTitleColor:[self getColor] forState:UIControlStateNormal];
    [self.btnSendInviteButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.btnMyBuddies setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
}

- (IBAction)btnInviteClicked:(id)sender
{
    _suggestedBuddies = FALSE;
    [self.buddyCollectionView setHidden:YES];
    [self.btnSuggestedBuddies setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.btnSendInviteButton setTitleColor:[self getColor] forState:UIControlStateNormal];
    [self.btnMyBuddies setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    UIActionSheet *inviteActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Invite by text",@"Invite by email",@"Share on Facebook",nil];
    inviteActionSheet.delegate = self;
    [inviteActionSheet showFromTabBar:SharedAppDelegate.tabBarController.tabBar];
}

- (IBAction)btnMyBuddiesClicked:(id)sender
{
    _suggestedBuddies = FALSE;
    self.buddiesHeaderLabel.text = @"My Buddies";
    [self callAPIMyBuddies];
    [self.buddyCollectionView setHidden:NO];
    [self.btnSuggestedBuddies setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.btnSendInviteButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.btnMyBuddies setTitleColor:[self getColor] forState:UIControlStateNormal];

}
#pragma mark- Mail Delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
   
    [controller dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark- Mail Delegate
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
     [controller dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
//        AddContactFriendsViewController *addContactFriendsViewController = [[AddContactFriendsViewController alloc]initWithNibName:@"AddContactFriendsViewController" bundle:nil];
//        addContactFriendsViewController.isText=true;
//        [self.navigationController pushViewController:addContactFriendsViewController animated:YES];
        
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init] ;
        if([MFMessageComposeViewController canSendText])
        {
            controller.body = @"I make extra cash with STUD-E-BUDDIES, you should too! Download it from my link so we can both get a free laptop. Find your next study buddy and sell your notes here.\n iOS App - https://itunes.apple.com/in/app/studebuddies/id983872682?mt=8 \n OR \n Sign Up at www.studebuddies.com";
            controller.messageComposeDelegate = self;
            [self presentViewController:controller animated:YES completion:nil];
        }
        else
        {
            [Utils showAlertViewWithMessage:@"This device is not configured to send Text Message.!"];
        }
    }
    else if (buttonIndex == 1)
    {
//        AddContactFriendsViewController *addContactFriendsViewController = [[AddContactFriendsViewController alloc]initWithNibName:@"AddContactFriendsViewController" bundle:nil];
//        addContactFriendsViewController.isText=false;
//        [self.navigationController pushViewController:addContactFriendsViewController animated:YES];
        
        if([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
            mailCont.mailComposeDelegate = self;
            [mailCont setSubject:@"A new App I liked"];
            [mailCont setMessageBody:[@"I’ve been using STUD-E-BUDDIES and think you’d really like it too! It allows you to connect and share with your classmates in a fun and social way; it’s the smartest way to connect. If you download from my links below, we’ll both have a chance in getting a laptop they are giving away. \n Download the iOS app: https://itunes.apple.com/in/app/studebuddies/id983872682?mt=8 \n Or \n Sign Up at www.studebuddies.com" stringByAppendingString:@""] isHTML:NO];
            [self presentViewController:mailCont animated:YES completion:nil];
        }
        else
        {
            [Utils showAlertViewWithMessage:@"This device is not configured to send Mail.!"];
        }

    }
    else if(buttonIndex == 2)
    {
        
//        FBSDKAppInviteContent *content1 =[[FBSDKAppInviteContent alloc] init];
//        content1.appLinkURL = [NSURL URLWithString:@"https://fb.me/1541783576124611"];
//        //optionally set previewImageURL
//        content1.appInvitePreviewImageURL = [NSURL URLWithString:@"http://studebuddies.com/Assets/Css/images/login_Logo.png"];
//        
//        // present the dialog. Assumes self implements protocol `FBSDKAppInviteDialogDelegate`
//        [FBSDKAppInviteDialog showFromViewController:self withContent:content1 delegate:self];
        
        
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        content.contentURL = [NSURL URLWithString:@"https://itunes.apple.com/in/app/studebuddies/id983872682?mt=8"];
      //  content.contentURL= [NSURL URLWithString:@"www.studebuddies.com"];
        content.quote =@"www.studebuddies.com" ;
        content.contentDescription=@"A smarter way to connect! Download the app.";
        content.contentTitle=@"Studebuddies";
        
        FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
        dialog.fromViewController = self;
        dialog.shareContent = content;
        dialog.mode = FBSDKShareDialogModeFeedWeb;
        dialog.delegate=self;
        [dialog show];
//        [FBSDKShareDialog showFromViewController:self
//                                     withContent:content
//                                        delegate:nil];
        
        
//        AddFacebookFriendsViewController *addFacebookFriendsViewController = [[AddFacebookFriendsViewController alloc]initWithNibName:@"AddFacebookFriendsViewController" bundle:nil];
//        [self.navigationController pushViewController:addFacebookFriendsViewController animated:YES];
    }
    else
    {
        self.buddiesHeaderLabel.text = @"My Buddies";
        [self callAPIMyBuddies];
        [self.buddyCollectionView setHidden:NO];
        segmentedControl.selectedSegmentIndex=1;
        [self.btnSuggestedBuddies setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.btnSendInviteButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.btnMyBuddies setTitleColor:[self getColor] forState:UIControlStateNormal];
    }
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
}
#pragma mark - FBSDKSharingDelegate
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    [Utils showAlertViewWithMessage:@"Facebook post shared.!"];
}
- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    [Utils showAlertViewWithMessage:@"Fail to share post.!"];
}
- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    
}

#pragma mark - Private Methods

- (void)setFonts
{
    //_viewPopUp.layer.cornerRadius = 5;
//    UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backSwipeAction)];
//    [backSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
//    [self.view addGestureRecognizer:backSwipe];
    
    [_buddiesHeaderLabel setFont:FONT_REGULAR(kNavigationFontSize)];
    
}

- (IBAction)backButtonClicked:(id)sender
{
    //[self.tabBarController setSelectedIndex:2];
    
    ViewProfileViewController * viewProfile = [[ViewProfileViewController alloc]initWithNibName:@"ViewProfileViewController" bundle:nil];
    viewProfile.inviteButtonHidden = YES;
    viewProfile.editProfile = NO;
    [self.tabBarController.tabBar setHidden:YES];
    [viewProfile setHidesBottomBarWhenPushed:NO];
    [viewProfile setBuddyId:[defaults objectForKey:kUserId]];
    [self.navigationController pushViewController:viewProfile animated:YES];


    //[self.navigationController popViewControllerAnimated:YES];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Collection view delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return arrayBuddies.count;
}


// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (BuddyCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *cellIdentifier = @"BuddyCell";
    
   BuddyCollectionViewCell *cell = (BuddyCollectionViewCell *)[self.buddyCollectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.collectionCellDelegate = self;
    cell.layer.cornerRadius=5;
    cell.clipsToBounds=YES;

    if(!_suggestedBuddies)//(_fromScene == COMINGFROM_MYBUDDIES)
    {
        [cell changeButtons:YES];
    }
    else
    {
        [cell changeButtons:NO];
    }
    NSDictionary *tempDict = arrayBuddies[indexPath.row];

    NSString *imgname=[NSString stringWithFormat:@"%@",[tempDict objectForKeyNonNull:kBuddyImage]];
    [cell.mainImageview setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImageURl,imgname]]placeholderImage:[UIImage imageNamed:@"gaust_user.png"]];
    
    [cell.nameLabel setText:[tempDict objectForKeyNonNull:kBuddyName]];
    
    if ([[tempDict objectForKeyNonNull:@"isBlock"] isEqualToString:@"True"])
    {
        [cell.blockButton setImage:[UIImage imageNamed:@"block_red"] forState:UIControlStateNormal];
    }
    else
    {
        [cell.blockButton setImage:[UIImage imageNamed:@"ic_block"] forState:UIControlStateNormal];
    }
    
//    if ([tempDict objectForKeyNonNull:@"buddyMajor"])
//    {
//        [cell.majorlabel setText:[tempDict objectForKeyNonNull:@"buddyMajor"]];
//    }
//    else
//    {
//        [cell.majorlabel setHidden:YES];
//    }

    
    if ([[tempDict objectForKeyNonNull:@"isCourseNoCommon"] integerValue]>0 || [[tempDict objectForKeyNonNull:@"isSectionCommon"] integerValue]>0)
    {
//        [cell configureCellView:NO];

        [cell.classesNumberButton setAlpha:1.0];
        cell.classesNumberButton.layer.cornerRadius=5.0;
        cell.clipsToBounds=YES;
        
//        if ([[tempDict objectForKeyNonNull:@"isMajorCommon"] integerValue] > 0) {
//            [cell.majorlabel setHidden:NO];
//            [cell.majorlabel setText:[tempDict objectForKeyNonNull:@"major"]];
//        }
//        else
//        {
//            cell.majorlabel.hidden=YES;
//            [cell.classesNumberButton setTranslatesAutoresizingMaskIntoConstraints:YES];
//            cell.classesNumberButton.frame=CGRectMake(cell.classesNumberButton.frame.origin.x, cell.majorlabel.frame.origin.y, cell.classesNumberButton.frame.size.width, cell.classesNumberButton.frame.size.height);
//        }
//        
//        
//        if ([[tempDict objectForKeyNonNull:@"classCount"] integerValue]> 0) {
//            [cell.classLabel setHidden:NO];
//            [cell.classesNumberButton setHidden:NO];
//            //[cell.classesNumberButton setTitle:[tempDict objectForKeyNonNull:@"classCount"] forState:UIControlStateNormal];
//            cell.classesNumberButton.layer.cornerRadius = 3.0f;
//        }
//        else
//        {
//            [cell.classLabel setHidden:YES];
//            [cell.classesNumberButton setHidden:YES];
//            [cell.universityLabel setTranslatesAutoresizingMaskIntoConstraints:YES];
//            cell.universityLabel.frame=cell.classesNumberButton.frame;
//        }
//        if ([[tempDict objectForKeyNonNull:@"isUniversityCommon"] integerValue] > 0) {
//            [cell.universityLabel setHidden:NO];
//            [cell.universityLabel setText:[tempDict objectForKeyNonNull:@"university"]];
//        }

    }
    else
    {
        [cell.classesNumberButton setAlpha:0.0];
    }
   
        [cell configureCellView:NO];
        [cell.universityLabel setText:[tempDict objectForKeyNonNull:@"buddyUniversity"]];
        [cell.majorlabel setText:[tempDict objectForKeyNonNull:@"buddyMajor"]];
    
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.buddyCollectionView reloadData];
//        
//    });
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    BuddyCollectionViewCell *cell = (MyCell*)[collectionView cellForItemAtIndexPath:indexPath];
//    NSArray *views = [cell.contentView subviews];
//    UILabel *label = [views objectAtIndex:0];
//    NSLog(@"Select %@",label.text);
}

#pragma mark - Network Classes

- (void)callAPIMyBuddies
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId
                            ,nil];
    [Utils startLoaderWithMessage:@""];
    
    [Connection callServiceWithName:kGetMyBuddiesList postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         [Utils stopLoader];
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 arrayBuddies = nil;
                 arrayBuddies = [[NSArray alloc] initWithArray:[response objectForKeyNonNull:kResult]];
                 
                 [self.buddyCollectionView reloadData];
                 if([arrayBuddies count] == 0)
                 {
                    
                     [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"You have no buddies yet. \nFind Buddies Now?" leftButtonTitle:@"Yes" rightButtonTitle:@"No" selectedButton:^(NSInteger selected, UIAlertView *aView)
                      {
                          if (selected==0)
                          {
                              segmentedControl.selectedSegmentIndex=0;
                              pageSuggestBuddy=1;
                              _suggestedBuddies = TRUE;
                              self.buddiesHeaderLabel.text = @"Suggested Buddies";
                              [self callAPIFindBuddies];
                              [self.buddyCollectionView setHidden:NO];
                          }
                          
                      }];
                 }
             }
         }
         
     }];
}

- (void)callAPIBlockBuddyWithBuddyId:(NSString*)buddyId blockUser:(BOOL)isBlock
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
                              buddyId,kBuddyId,
                              isBlock?@"True":@"False",kIsBlock,
                              nil];
    [Utils startLoaderWithMessage:@""];
    
    [Connection callServiceWithName:kBlockBuddy postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         [Utils stopLoader];
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 //SOURABH
                 [self callAPIMyBuddies];
                 //DOnt understand why calling again
                 
             }
         }
     }];
}

- (void)callAPIFindBuddies
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
                              [NSString stringWithFormat:@"%d",pageSuggestBuddy],kPage,
                              nil];
    [Utils startLoaderWithMessage:@""];
    [Connection callServiceWithName:kFindBuddies postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         [Utils stopLoader];
         if (SharedAppDelegate.isChangePreference)
         {
             SharedAppDelegate.isChangePreference=false;
                     }
         if (pageSuggestBuddy==1)
         {
             [SuggestBuddy removeAllObjects];
             arrayBuddies = nil;

         }

         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 
                 //NSObject *objTemp = [response objectForKeyNonNull:kResult];
                 if ([[response objectForKeyNonNull:kResult] isKindOfClass:[NSArray class]]) {
                     
                     NSArray *array = [[NSArray alloc] initWithArray:[response objectForKeyNonNull:kResult]];
                     if ([array count] > 0) {
                         
                        
                         for (int i=0; i<array.count; i++)
                         {
                             [SuggestBuddy addObject:[array objectAtIndex:i]];
                         }
                         arrayBuddies = nil;
                         arrayBuddies = [[NSArray alloc] initWithArray:SuggestBuddy];
                         DLog(@"Array contains data");
                         
                     } else {
                         if (pageSuggestBuddy==1) {
                             arrayBuddies = nil;
                             [Utils showAlertViewWithMessage:@"No Suggestions Yet!!"];
                             DLog(@"No suggestions");
                         }
                        pageSuggestBuddy=pageSuggestBuddy-1;
                        
                     }
                 } else {
                  
                     pageSuggestBuddy=pageSuggestBuddy-1;
                     if (pageSuggestBuddy==1) {
                         arrayBuddies = nil;
                         [Utils showAlertViewWithMessage:@"No Suggestions Yet!!"];
                         DLog(@"No suggestions");
                     }
                 }
                 
                 [self.buddyCollectionView reloadData];
             }
         }
     }];
}

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
                      pageSuggestBuddy=1;
                      [self callAPIFindBuddies];
                      
                  }];
             }
         }
     }];
    
}


- (void)setUserDataWithDictionary:(NSDictionary*)dict
{
    NSMutableAttributedString *strName = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@, %@",[dict objectForKeyNonNull:kBuddyName],[dict objectForKeyNonNull:@"buddyAge"]]];
    
    [strName addAttribute:NSFontAttributeName value:FONT_REGULAR(14) range:[[NSString stringWithFormat:@"%@, %@",[dict objectForKeyNonNull:kBuddyName],[dict objectForKeyNonNull:@"buddyAge"]] rangeOfString:[dict objectForKeyNonNull:kBuddyName] ]];
    
    [strName addAttribute:NSFontAttributeName value:FONT_LIGHT(13) range:[[NSString stringWithFormat:@"%@, %@",[dict objectForKeyNonNull:kBuddyName],[dict objectForKeyNonNull:@"buddyAge"]] rangeOfString:[dict objectForKeyNonNull:@"buddyAge"] ]];
    
//    [_lblName setAttributedText:strName];
//    [_lblName setTextColor:kBlueColor];
//    _lblUniversity.text = [dict objectForKeyNonNull:kUniversity];
//    
//    
//    // set Image Dictionary to ScrollView
//    
//    [self makeImagesScrollViewWithArray:[dict objectForKeyNonNull:kProfilePicture]];
//    
//    if ([[dict objectForKeyNonNull:kIsBuddy] intValue] == kStatusFriend || [[defaults objectForKey:kUserId] isEqualToString:_buddyId])
//    {
//        [_btnSendInvite setHidden:YES];
//        [_btnSendInvite.titleLabel setFont:FONT_REGULAR(12)];
//    }
//    else if ([[dict objectForKeyNonNull:kIsBuddy] intValue] == KStatusFriendRequestPending)
//    {
//        [_btnSendInvite setTitle:@"Respond" forState:UIControlStateNormal];
//        [_btnSendInvite.titleLabel setFont:FONT_REGULAR(12)];
//    }
//    else if ([[dict objectForKeyNonNull:kIsBuddy] intValue] == kStatusMyRequestPending)
//    {
//        [_btnSendInvite setTitle:@"Pending" forState:UIControlStateNormal];
//        [_btnSendInvite.titleLabel setFont:FONT_REGULAR(12)];
//        [_btnSendInvite setUserInteractionEnabled:NO];
//    }
//    else if ([[dict objectForKeyNonNull:kIsBuddy] intValue] == kStatusNotFriend)
//    {
//        [_btnSendInvite setTitle:@"Send Invite" forState:UIControlStateNormal];
//        [_btnSendInvite.titleLabel setFont:FONT_REGULAR(12)];
//        [_btnSendInvite setUserInteractionEnabled:YES];
//    }
    
}


#pragma mark - SBCollectionCellTappedDelegate Methods

-(void)blockButtonTappedWithCell:(BuddyCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.buddyCollectionView indexPathForCell:cell];
    NSLog(@"indexpath.row = %d",indexPath.row);
    if ([[[arrayBuddies objectAtIndex:indexPath.row] objectForKey:kIsBlock] isEqualToString:@"True"])
    {
        [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"Are you sure you want to unblock this user?" leftButtonTitle:@"Yes" rightButtonTitle:@"Cancel" selectedButton:^(NSInteger selected, UIAlertView *aView)
         {
             if (selected == 0)
             {
                 [self callAPIBlockBuddyWithBuddyId:[[arrayBuddies objectAtIndex:indexPath.row] objectForKey:kBuddyId] blockUser:NO];
             }
         }];
    }
    else
    {
        [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"Are you sure you want to block this user?" leftButtonTitle:@"Yes" rightButtonTitle:@"Cancel" selectedButton:^(NSInteger selected, UIAlertView *aView)
         {
             if (selected == 0)
             {
                 [self callAPIBlockBuddyWithBuddyId:[[arrayBuddies objectAtIndex:indexPath.row] objectForKey:kBuddyId] blockUser:YES];
             }
         }];
    }
}

-(void)chatButtonTappedWithCell:(BuddyCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.buddyCollectionView indexPathForCell:cell];
    NSDictionary *dictBuddyDetails = @{kBuddyId: [[arrayBuddies objectAtIndex:indexPath.row] objectForKey:kBuddyId],kBuddyName:[[arrayBuddies objectAtIndex:indexPath.row] objectForKey:kBuddyName],kBuddyImage:[[arrayBuddies objectAtIndex:indexPath.row] objectForKey:kBuddyImage]};
    ChatScreenViewController *chatScreenViewC = [[ChatScreenViewController alloc] initWithNibName:@"ChatScreenViewController" bundle:nil];
    [chatScreenViewC setDictBuddyInfo:dictBuddyDetails];
    [chatScreenViewC setHidesBottomBarWhenPushed:YES];
    [chatScreenViewC setIsGroup:NO];
    [self.navigationController pushViewController:chatScreenViewC animated:YES];
}

-(void)nameButtonTappedWithCell:(BuddyCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.buddyCollectionView indexPathForCell:cell];
    NSDictionary *tempDict = arrayBuddies[indexPath.row];
    ViewProfileViewController * viewProfile = [[ViewProfileViewController alloc]initWithNibName:@"ViewProfileViewController" bundle:nil];
    viewProfile.isViewProfile = YES;
    
    viewProfile.editProfile = YES;
    viewProfile.inviteButtonHidden = YES;
    [viewProfile setBuddyId:[tempDict objectForKeyNonNull:kBuddyId]];
    [self.navigationController pushViewController:viewProfile animated:YES];
}

-(void)addButtonTappedWithCell:(BuddyCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.buddyCollectionView indexPathForCell:cell];
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

-(void)cameraButtonClicked:(BuddyCollectionViewCell *)cell
{
    NSIndexPath *indexPath = [self.buddyCollectionView indexPathForCell:cell];
    NSDictionary *tempDict = arrayBuddies[indexPath.row];
    _buddyId = [tempDict objectForKeyNonNull:kBuddyId];
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
                              _buddyId,kBuddyId,
                              nil];
    
    [Utils startLoaderWithMessage:@""];
    __block BuddyGridController *blockSelf = self;

    [Connection callServiceWithName:kGetBuddyProfileDetail postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         [Utils stopLoader];
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 _arrayProfileDetails = nil;
                 _arrayProfileDetails = [[NSMutableArray alloc]initWithArray:[[response objectForKeyNonNull:kResult] objectForKeyNonNull:kProfilePicture]];
                 
                 // from Here send the call to show image
                 [blockSelf addControllerWithGridViewWithDatasource:_arrayProfileDetails];
             }
         }
     }];
}

-(void)classesButtonTapped:(BuddyCollectionViewCell *)cell
{
    [_viewInner setHidden:NO];
    [self.view bringSubviewToFront:_viewInner];
    NSIndexPath *indexPath = [self.buddyCollectionView indexPathForCell:cell];
    
    _viewPopUp.layer.borderColor=[UIColor blackColor].CGColor;
    _viewPopUp.layer.borderWidth=2.0;
    
    NSDictionary *tempDict = arrayBuddies[indexPath.row];
    NSLog(@"\n\n\nAt Index %ld ,\n Temp Dict : %@\n\n\n",(long)indexPath.row,tempDict);
    NSString *strClassTitle = [tempDict objectForKeyNonNull:@"classTitles"];
    NSString *strCourse = [tempDict objectForKeyedSubscript:@"courseNumbers"];
    NSString *strSection = [tempDict objectForKeyNonNull:@"sections"];

    
    
    CGRect frame = CGRectMake(0, 30, _viewPopUp.frame.size.width - 40, 10);
    
    if (![strClassTitle isEqualToString:@""]) {
        frame.origin.x = _viewPopUp.frame.origin.x;
        UILabel *lblClassTitles = [[UILabel alloc] initWithFrame:CGRectMake(10, frame.origin.y, frame.size.width, frame.size.height)];
        lblClassTitles.numberOfLines = 0;
        NSString *strClassTitles = @"ClassTitle : ";
        
        UIFont * labelFont = FONT_BOLD(12);
        NSMutableAttributedString *labelText = [[NSMutableAttributedString alloc] initWithString : strClassTitles attributes : @{NSFontAttributeName : labelFont, NSForegroundColorAttributeName : kLightGrayColor}];
        
        
        [lblClassTitles setAttributedText:labelText];
        [lblClassTitles sizeToFit];
        [_viewPopUp addSubview:lblClassTitles];
        
        frame.origin.x = lblClassTitles.frame.origin.x + lblClassTitles.frame.size.width;
        frame.size.width = _viewPopUp.frame.size.width - lblClassTitles.frame.size.width - 15;
        UILabel *lblClassTitleValues = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
        lblClassTitleValues.lineBreakMode = NSLineBreakByWordWrapping;
        lblClassTitleValues.numberOfLines = 0;
        
        
        labelFont = FONT_REGULAR(12);
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString : [tempDict objectForKeyNonNull:@"classTitles"] attributes : @{NSFontAttributeName : labelFont, NSForegroundColorAttributeName : [UIColor blackColor]}];
        
        // [labelText appendAttributedString:attributedStr];
        
        [lblClassTitleValues setAttributedText:attributedStr];
        [lblClassTitleValues sizeToFit];
        [_viewPopUp addSubview:lblClassTitleValues];
        
        frame.origin.y = lblClassTitleValues.frame.size.height + lblClassTitleValues.frame.origin.y+15;
        
        UILabel *lblSeperator = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.origin.y, _viewPopUp.frame.size.width, 1)];
        [lblSeperator setBackgroundColor:kLightGrayColor];
        [_viewPopUp addSubview:lblSeperator];
        frame.origin.y = lblSeperator.frame.size.height + lblSeperator.frame.origin.y+10;
        _viewPopUp.frame = CGRectMake(_viewPopUp.frame.origin.x, _viewPopUp.frame.origin.y, _viewPopUp.frame.size.width, frame.origin.y);
    }
    
    if (![strCourse isEqualToString:@""]) {
        frame.origin.x = _viewPopUp.frame.origin.x;
        UILabel *lblCourseNumber = [[UILabel alloc] initWithFrame:CGRectMake(10, frame.origin.y, frame.size.width, frame.size.height)];
        lblCourseNumber.numberOfLines = 0;
        NSString *strCourseNumber = @"CourseNumber : ";
        
        UIFont * labelFont = FONT_BOLD(12);
        NSMutableAttributedString *labelText = [[NSMutableAttributedString alloc] initWithString : strCourseNumber attributes : @{NSFontAttributeName : labelFont, NSForegroundColorAttributeName : kLightGrayColor}];
        
        [lblCourseNumber setAttributedText:labelText];
        [lblCourseNumber sizeToFit];
        [_viewPopUp addSubview:lblCourseNumber];
        
        frame.origin.x = lblCourseNumber.frame.origin.x + lblCourseNumber.frame.size.width;
        frame.size.width = _viewPopUp.frame.size.width - lblCourseNumber.frame.size.width - 15;
        UILabel *lblCourseNumberValues = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
        lblCourseNumberValues.lineBreakMode = NSLineBreakByWordWrapping;
        lblCourseNumberValues.numberOfLines = 0;
        
        labelFont = FONT_REGULAR(12);
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString : [tempDict objectForKeyNonNull:@"courseNumbers"] attributes : @{NSFontAttributeName : labelFont, NSForegroundColorAttributeName : [UIColor blackColor]}];
        
        //[labelText appendAttributedString:attributedStr];
        
        [lblCourseNumberValues setAttributedText:attributedStr];
        [lblCourseNumberValues sizeToFit];
        [_viewPopUp addSubview:lblCourseNumberValues];
        
        frame.origin.y = lblCourseNumberValues.frame.size.height + lblCourseNumberValues.frame.origin.y+15;
        
        UILabel *lblSeperator = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.origin.y, _viewPopUp.frame.size.width, 1)];
        [lblSeperator setBackgroundColor:kLightGrayColor];
        [_viewPopUp addSubview:lblSeperator];
        
        frame.origin.y = lblSeperator.frame.size.height + lblSeperator.frame.origin.y+10;
        _viewPopUp.frame = CGRectMake(_viewPopUp.frame.origin.x, _viewPopUp.frame.origin.y, _viewPopUp.frame.size.width, frame.origin.y);
    }
    if (![strSection isEqualToString:@""]) {
        frame.origin.x = _viewPopUp.frame.origin.x;
        UILabel *lblSection = [[UILabel alloc] initWithFrame:CGRectMake(10, frame.origin.y, frame.size.width, frame.size.height)];
        lblSection.numberOfLines = 0;
        NSString *strSections = @"Section : ";
        
        UIFont * labelFont = FONT_BOLD(12);
        NSMutableAttributedString *labelText = [[NSMutableAttributedString alloc] initWithString : strSections attributes : @{NSFontAttributeName : labelFont, NSForegroundColorAttributeName : kLightGrayColor}];
        
        [lblSection setAttributedText:labelText];
        [lblSection sizeToFit];
        [_viewPopUp addSubview:lblSection];
        
        frame.origin.x = lblSection.frame.origin.x + lblSection.frame.size.width;
        frame.size.width = _viewPopUp.frame.size.width - lblSection.frame.size.width - 15;
        
        UILabel *lblSectionValues = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
        lblSectionValues.lineBreakMode = NSLineBreakByWordWrapping;
        lblSectionValues.numberOfLines = 0;
        
        labelFont = FONT_REGULAR(12);
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString : [tempDict objectForKeyNonNull:@"sections"] attributes : @{NSFontAttributeName : labelFont, NSForegroundColorAttributeName : [UIColor blackColor]}];
        
        //[labelText appendAttributedString:attributedStr];
        
        [lblSectionValues setAttributedText:attributedStr];
        [lblSectionValues sizeToFit];
        [_viewPopUp addSubview:lblSectionValues];
        
        frame.origin.y = lblSectionValues.frame.size.height + lblSectionValues.frame.origin.y+15;
        
        UILabel *lblSeperator = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.origin.y, _viewPopUp.frame.size.width, 1)];
        [lblSeperator setBackgroundColor:kLightGrayColor];
        [_viewPopUp addSubview:lblSeperator];
        frame.origin.y = lblSeperator.frame.size.height + lblSeperator.frame.origin.y+10;
        _viewPopUp.frame = CGRectMake(_viewPopUp.frame.origin.x, _viewPopUp.frame.origin.y, _viewPopUp.frame.size.width, frame.origin.y);
    }

}

-(void)addControllerWithGridViewWithDatasource:(NSMutableArray *)datasourceArray
{
    MWPhoto *mwPhoto;
    NSMutableArray *arr = [NSMutableArray array];
    // Itereate through array using dict
    for(NSDictionary *dict in datasourceArray)
    {
        ModalProfilePic *profilePicDetails = [[ModalProfilePic alloc] initWithDictionary:dict];
        mwPhoto = [MWPhoto photoWithURL:profilePicDetails.imageURL];
        [arr addObject:mwPhoto];
    }
    self.photos = arr;
    self.thumbs = arr;
    //MWPhoto *photo;
    BOOL displayActionButton = YES;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = NO;
    BOOL enableGrid = YES;
    BOOL startOnGrid = NO;
    // Create browser
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    [browser.navigationController.navigationBar setBarTintColor:[UIColor blueColor]];
    browser.displayActionButton = displayActionButton;
    browser.displayNavArrows = displayNavArrows;
    browser.displaySelectionButtons = displaySelectionButtons;
    browser.alwaysShowControls = displaySelectionButtons;
    browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    browser.wantsFullScreenLayout = YES;
#endif
    browser.enableGrid = enableGrid;
    browser.startOnGrid = YES;
    browser.enableSwipeToDismiss = YES;
    [browser setCurrentPhotoIndex:0];
    
    // Reset selections
    if (displaySelectionButtons) {
        _selections = [NSMutableArray new];
        for (int i = 0; i < datasourceArray.count; i++) {
            [_selections addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
            // Push
        [self.navigationController pushViewController:browser animated:YES];
        // Release
    
    // Deselect
    //[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Test reloading of data after delay
    double delayInSeconds = 3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        //        // Test removing an object
        //        [_photos removeLastObject];
        //        [browser reloadData];
        //
        //        // Test all new
        //        [_photos removeAllObjects];
        //        [_photos addObject:[MWPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"photo3" ofType:@"jpg"]]];
        //        [browser reloadData];
        //
        //        // Test changing photo index
        //        [browser setCurrentPhotoIndex:9];
        
        //        // Test updating selections
        //        _selections = [NSMutableArray new];
        //        for (int i = 0; i < [self numberOfPhotosInPhotoBrowser:browser]; i++) {
        //            [_selections addObject:[NSNumber numberWithBool:YES]];
        //        }
        //        [browser reloadData];
        
    });

}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index {
//    MWPhoto *photo = [self.photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return [captionView autorelease];
//}

//- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"ACTION!");
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    NSLog(@"Did start viewing photo at index %lu", (unsigned long)index);
}

- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index {
    return [[_selections objectAtIndex:index] boolValue];
}

//- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
//    return [NSString stringWithFormat:@"Photo %lu", (unsigned long)index+1];
//}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected {
    [_selections replaceObjectAtIndex:index withObject:[NSNumber numberWithBool:selected]];
    NSLog(@"Photo at index %lu selected %@", (unsigned long)index, selected ? @"YES" : @"NO");
}

- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tapClose:(id)sender
{
    [_viewInner setHidden:YES];
    [_viewPopUp.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
}
#pragma mark -Revale
- (NSString*)stringFromFrontViewPosition:(FrontViewPosition)position
{
    NSString *str = nil;
    if ( position == FrontViewPositionLeftSideMostRemoved ) str = @"FrontViewPositionLeftSideMostRemoved";
    if ( position == FrontViewPositionLeftSideMost) str = @"FrontViewPositionLeftSideMost";
    if ( position == FrontViewPositionLeftSide) str = @"FrontViewPositionLeftSide";
    if ( position == FrontViewPositionLeft ) str = @"FrontViewPositionLeft";
    if ( position == FrontViewPositionRight ) str = @"FrontViewPositionRight";
    if ( position == FrontViewPositionRightMost ) str = @"FrontViewPositionRightMost";
    if ( position == FrontViewPositionRightMostRemoved ) str = @"FrontViewPositionRightMostRemoved";
    return str;
}


- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    NSLog( @"%@: %@", NSStringFromSelector(_cmd), [self stringFromFrontViewPosition:position]);
    if ( NSStringFromSelector(_cmd), [[self stringFromFrontViewPosition:position] isEqualToString:@"FrontViewPositionLeft"])
    {
        if (SharedAppDelegate.isChangePreference)
        {
           
            if (_suggestedBuddies)
            {
                pageSuggestBuddy=1;
                [self callAPIFindBuddies];
            }
           
        }
  
    }
}


@end
