//
//  ViewProfileViewController.m
//  TedBuddies
//
//  Created by Sunil on 08/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import "ViewProfileViewController.h"
#import "AcceptAndDenyViewController.h"
#import "CreateProfileViewController.h"
#import "CreatePostViewController.h"
#import "PostViewController.h"
#import "MHFacebookImageViewer.h"
#import "UIImageView+MHFacebookImageViewer.h"
#import "PagedImageScrollView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "KILabel.h"

@interface ViewProfileViewController ()
{
    PagedImageScrollView *pageScrollView ;
}

@end

@implementation ViewProfileViewController

#pragma mark View Life Cycle Method

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self)
  {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

    
    SharedAppDelegate.isProfileUpdate=true;
    
    //AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    //[appDelegate.tabBarController.tabBar setHidden:YES];
    //self.tabBarController.tabBar.hidden = YES;
    _tableView.sectionFooterHeight = 0.0;

    _lblName.textAlignment = NSTextAlignmentCenter;
    _lblUniversity.textAlignment = NSTextAlignmentCenter;
    
    
    [_lineLabel1 setHidden:YES];
    [_lineLabel2 setHidden:YES];
  [_btnSendInvite setHidden:_inviteButtonHidden];
  [_btnEditProfile setHidden:_editProfile];
  arrayPostList = [[NSMutableArray alloc]init];
  arrayCommentsList = [[NSMutableArray alloc]init];
  
  pullToRefreshManagerPost = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:self.tableView withClient:self];
  pullToRefreshManagerComment = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:self.tblViewComments withClient:self];
    
    //new changes
    _scrollViewImages.layer.cornerRadius = _scrollViewImages.frame.size.width / 2;
    _scrollViewImages.clipsToBounds = YES;

    [self.view bringSubviewToFront:_lblName];
    [self.view bringSubviewToFront:_lblUniversity];
    
     [self.tabBarController.tabBar setHidden:YES];
  
}

-(void)editButtonClick:(UIButton *)sender
{
    [self.view bringSubviewToFront:self.btnEditProfile];
    [self.view bringSubviewToFront:self.btnSendInvite];
}
- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
    if (SharedAppDelegate.isProfileUpdate)
    {
        [_tableView setTableHeaderView:_viewProfile];
        [self inisialiseView];
        pageNumber = 0;
        isNewDataArrive = TRUE;
        [arrayPostList removeAllObjects];
        [arrayCommentsList removeAllObjects];
        [self callAPIViewProfile];
        SharedAppDelegate.isProfileUpdate=false;

    }
  
}

- (void)viewWillAppear:(BOOL)animated
{
    //[self.tabBarController.tabBar setHidden:YES];

    [super viewWillAppear:animated];
    
    // FOR GOOGLE ANALYTICS
    
    self.screenName = @"Profile Screen";
}
- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction Method

- (IBAction)btnBackTapped:(id)sender
{
  [self backSwipeAction];
}

- (IBAction)btnSendInviteTapped:(id)sender
{
  if ([_btnSendInvite.titleLabel.text isEqualToString:@"Respond"])
  {
    [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"" buttonArray:@[@"Accept",@"Reject",@"Cancel"] selectedButton:^(NSInteger selected, UIAlertView *aView) {
      if (selected == 0)
      {
        [self callAPIAcceptRequest];
      }
      else if (selected == 1)
      {
        [self callAPIRejectRequest];
      }
    }];
  }
  else
  {
    [self callAPISendInvite];
  }
}

- (IBAction)btnEditProfileTapped:(id)sender
{
  CreateProfileViewController * createView = [[CreateProfileViewController alloc]initWithNibName:@"CreateProfileViewController" bundle:nil];
  createView.isEditProfile = YES;
  
  createView.dictGetEditProfileDetails = _dictGetEditProfileDetails;
  [self.navigationController pushViewController:createView animated:YES];
}

- (IBAction)closeDescriptionButtonClick:(UIButton *)sender
{
//  [tempTxtField resignFirstResponder];
//  [self.viewDescription removeFromSuperview];
    
    [tempTxtField resignFirstResponder];
    [UIView animateWithDuration:.8
                          delay: .1
                        options: (UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         self.viewDescription.frame = CGRectMake(0, self.viewDescription.frame.origin.y + 568, self.viewDescription.frame.size.width, self.viewDescription.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         if (finished)
                         {
                             NSLog(@"Done!");
                             [self.viewDescription removeFromSuperview];
                             
                         }
                     }];
}

- (IBAction)closeFullImageButtonClick:(UIButton *)sender
{
  [tempTxtField resignFirstResponder];
  [self.viewFullImage removeFromSuperview];
}

- (IBAction)sendCommentButtonClick:(UIButton *)sender
{
  [tempTxtField resignFirstResponder];
  if([[self.txtFieldComments.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
    [Utils showAlertViewWithMessage:@"Please enter comment"];
  else
  {
    [tempTxtField resignFirstResponder];
    [self callAPIAddComment:selectedIndex];
  }
}

- (IBAction)closeCommentsButtonClick:(UIButton *)sender
{
//  [tempTxtField resignFirstResponder];
//  [self.viewComments removeFromSuperview];
//  
//  NSMutableDictionary *tempDic = [[arrayPostList objectAtIndex:selectedIndex] mutableCopy];
//  [tempDic setObject:[NSString stringWithFormat:@"%d",[arrayCommentsList count]] forKey:@"commentCount"];
//  [arrayPostList replaceObjectAtIndex:selectedIndex withObject:tempDic];
//  [self.tableView reloadData];
    
    [tempTxtField resignFirstResponder];
    [UIView animateWithDuration:.8
                          delay: .1
                        options: (UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         self.viewComments.frame = CGRectMake(0, self.viewComments.frame.origin.y + 568, self.viewComments.frame.size.width, self.viewComments.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         if (finished)
                         {
                             [self.viewComments removeFromSuperview];
                             
                             NSMutableDictionary *tempDic = [[arrayPostList objectAtIndex:selectedIndex] mutableCopy];
                             [tempDic setObject:[NSString stringWithFormat:@"%lu",(unsigned long)[arrayCommentsList count]] forKey:@"commentCount"];
                             [arrayPostList replaceObjectAtIndex:selectedIndex withObject:tempDic];
                             [self.tableView reloadData];
                         }
                     }];
}

- (IBAction)editSendCommentButtonClick:(UIButton *)sender
{
  [tempTxtField resignFirstResponder];
  if([[self.txtFieldEditComment.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
    [Utils showAlertViewWithMessage:@"Please enter comment"];
  else
  {
    [self.txtFieldEditComment resignFirstResponder];
    [self callAPIEditComment:selectedIndex CommentId:editCommentId];
  }
}

- (IBAction)closeEditCommentButtonClick:(UIButton *)sender
{
  [tempTxtField resignFirstResponder];
  [self.viewEditComment removeFromSuperview];
}

#pragma mark - UITableView Delegate/DataSource Method

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if(tableView == self.tableView)
  {
    return [self calculateHeightForPostRow:indexPath];
    
  }
  else
  {
    return [self calculateHeightForCommentRow:indexPath];
  }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if(tableView == self.tableView)
    return [arrayPostList count];
  else
    return [arrayCommentsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == self.tableView)
    {
        UITableViewCell *cell = nil;
        static NSString *CellIdentifier = @"Cell";
        
        cell  = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PostViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
            [cell.contentView viewWithTag:112].layer.cornerRadius = 3.0f;
            //cell.backgroundColor = [UIColor clearColor];
            //cell.contentView.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.clipsToBounds = YES;
            
        }
        
        
        NSDictionary *tempDict = arrayPostList[indexPath.row];
        
        UIImageView *imgPostImage = (UIImageView *)[cell.contentView viewWithTag:10];
        UIImageView *imgProfileImage = (UIImageView *)[cell.contentView viewWithTag:11];
        UILabel *lblUserName = (UILabel *)[cell.contentView viewWithTag:12];
        UILabel *lblTime = (UILabel *)[cell.contentView viewWithTag:13];
        // UIView *viewDescription = (UIView *)[cell.contentView viewWithTag:14];
        KILabel *lblDescription = (KILabel *)[cell.contentView viewWithTag:15];
        //  UIButton *btnMore = (UIButton *)[cell.contentView viewWithTag:16];
        UIView *viewBottom = (UIView *)[cell.contentView viewWithTag:1700];
        UIButton *btnLike = (UIButton *)[cell.contentView viewWithTag:1718];
        UILabel *lblLikeCount = (UILabel *)[cell.contentView viewWithTag:1719];
        UIButton *btnDislike = (UIButton *)[cell.contentView viewWithTag:1720];
        UILabel *lblDislikeCount = (UILabel *)[cell.contentView viewWithTag:1721];
        UIButton *btnComment = (UIButton *)[cell.contentView viewWithTag:1722];
        UILabel *lblCommentCount = (UILabel *)[cell.contentView viewWithTag:1723];
        //    UILabel *lblPostHeading = (UILabel *)[cell.contentView viewWithTag:1724];
        UIView *viewClassName = (UIView *)[cell.contentView viewWithTag:26];
        UILabel *lblClassName = (UILabel *)[cell.contentView viewWithTag:27];
        //    UIButton *btnPostHeading = (UIButton *)[cell.contentView viewWithTag:1728];
        UIButton *btnArrow = (UIButton *)[cell.contentView viewWithTag:29];
        UIView *viewArrowSameUser = (UIView *)[cell.contentView viewWithTag:30];
        UIView *viewArrowOtherUser = (UIView *)[cell.contentView viewWithTag:35];
        UIView *viewBackWhite = (UIView *)[cell.contentView viewWithTag:112];
        UILabel *lblLine = (UILabel *)[cell.contentView viewWithTag:143];
        cell.tag = indexPath.row;
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if([[tempDict objectForKeyNonNull:@"postImage"] length])
            {
                if(cell.tag == indexPath.row)
                {
                    [imgPostImage sd_setImageWithURL:[NSURL URLWithString:[tempDict objectForKeyNonNull:@"postImage"]] placeholderImage:[UIImage imageNamed:@"placeholder"]];
                    [imgPostImage setupImageViewer];
                }
                
                
                imgPostImage.layer.cornerRadius = 2.0;
                imgPostImage.userInteractionEnabled = YES;
                //
                imgPostImage.clipsToBounds = YES;
                //SOURABH
                //        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(postImageButtonClick:)];
                //        gesture.numberOfTapsRequired = 1;
                //        [imgPostImage addGestureRecognizer:gesture];
            }
            else
            {
                imgPostImage.hidden = YES;
            }
            
            imgProfileImage.contentMode = UIViewContentModeScaleAspectFill;
            if(cell.tag == indexPath.row)
            {
                [imgProfileImage sd_setImageWithURL:[NSURL URLWithString:[tempDict objectForKeyNonNull:@"profileImage"]] placeholderImage:[UIImage imageNamed:@"appicon.png"]];
                
                [imgProfileImage setupImageViewer];
            }
            
            //setupImageViewerWithImageURL:[NSURL URLWithString:[tempDict objectForKeyNonNull:@"profileImage"]]];
            imgProfileImage.clipsToBounds = YES;
            
            imgProfileImage.layer.cornerRadius = imgProfileImage.frame.size.width/2;
            imgProfileImage.layer.borderWidth = 2.0;
            imgProfileImage.layer.borderColor = [[UIColor whiteColor] CGColor];
            
            lblUserName.text = [tempDict objectForKeyNonNull:@"postUserName"];
            
            lblTime.text = [tempDict objectForKeyNonNull:@"timeAgo"];
            
            
            
            
            if([[tempDict objectForKeyNonNull:@"postDesc"] length])
            {
                lblDescription.text = [tempDict objectForKeyNonNull:@"postDesc"];
                float descHeight=[self getLabelHeight:lblDescription];
                if (descHeight>30)
                {
                    lblDescription.numberOfLines=(descHeight/17)+1;
                    lblDescription.height=descHeight+5;
                }
                
                lblDescription.linkDetectionTypes ^= KILinkTypeOptionURL;
                lblDescription.linkDetectionTypes |= KILinkTypeOptionUserHandle;
                
                lblDescription.hashtagLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
                    
                    [self postHeadingButtonClick:string];
                };

                //        btnMore.tag = indexPath.row+10;
                //        [btnMore addTarget:self action:@selector(moreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                lblDescription.hidden = YES;
            }
            
            if([[tempDict objectForKeyNonNull:@"className"] length])
            {
                lblClassName.text = [tempDict objectForKeyNonNull:@"className"];
            }
            else
            {
                viewClassName.hidden = YES;
            }
            
            if([[tempDict objectForKeyNonNull:@"postImage"] length])
            {
                //        viewDescription.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
                //        lblDescription.textColor = [UIColor whiteColor];
                
                //        viewClassName.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
                //        lblClassName.textColor = [UIColor grayColor];
                
                viewClassName.frame = CGRectMake(viewClassName.frame.origin.x, viewClassName.frame.origin.y , viewClassName.frame.size.width, lblClassName.frame.size.height);
                lblDescription.frame = CGRectMake(lblDescription.frame.origin.x, lblDescription.frame.origin.y , lblDescription.frame.size.width, lblDescription.frame.size.height);
                lblLine.frame = CGRectMake(15, (lblDescription.frame.size.height +lblDescription.frame.origin.y+2) , lblLine.frame.size.width, lblLine.frame.size.height);
                viewBottom.frame = CGRectMake(viewBottom.xOrigin, (lblDescription.frame.size.height +lblDescription.frame.origin.y+10) , viewBottom.frame.size.width, viewBottom.frame.size.height);
                viewArrowOtherUser.frame = CGRectMake(viewArrowOtherUser.frame.origin.x, viewBottom.frame.origin.y-viewArrowOtherUser.frame.size.height , viewArrowOtherUser.frame.size.width, viewArrowOtherUser.frame.size.height);
                viewArrowSameUser.frame = CGRectMake(viewArrowSameUser.frame.origin.x, viewBottom.frame.origin.y-viewArrowSameUser.frame.size.height , viewArrowSameUser.frame.size.width, viewArrowSameUser.frame.size.height);
                viewBackWhite.frame = CGRectMake(viewBackWhite.frame.origin.x, viewBackWhite.frame.origin.y , viewBackWhite.frame.size.width, (viewBottom.frame.size.height +viewBottom.frame.origin.y+1));
            }
            else
            {
                viewClassName.backgroundColor = [UIColor clearColor];
                //lblClassName.textColor = [UIColor darkGrayColor];
                
                // viewDescription.backgroundColor = [UIColor clearColor];
                //lblDescription.textColor = [UIColor blackColor];
                
                if([[tempDict objectForKeyNonNull:@"postDesc"] length] && ![[tempDict objectForKeyNonNull:@"className"] length])
                {
                    //  viewDescription.frame = CGRectMake(10, 40 , viewDescription.frame.size.width, viewDescription.frame.size.height);
                    lblDescription.frame = CGRectMake(lblDescription.frame.origin.x, 45, lblDescription.frame.size.width, lblDescription.frame.size.height);
                    
                    //            lblPostHeading.frame = CGRectMake(15, 70 , lblPostHeading.frame.size.width, lblPostHeading.frame.size.height);
                    //            btnPostHeading.frame = CGRectMake(15, 70 , btnPostHeading.frame.size.width, btnPostHeading.frame.size.height);
                    
                    lblLine.frame = CGRectMake(15, (lblDescription.frame.size.height +lblDescription.frame.origin.y+2) , lblLine.frame.size.width, lblLine.frame.size.height);
                    
                    viewBottom.frame = CGRectMake(viewBottom.frame.origin.x, (lblDescription.frame.size.height +lblDescription.frame.origin.y+10), viewBottom.frame.size.width, viewBottom.frame.size.height);
                    viewArrowOtherUser.frame = CGRectMake(viewArrowOtherUser.frame.origin.x, viewBottom.frame.origin.y-viewArrowOtherUser.frame.size.height , viewArrowOtherUser.frame.size.width, viewArrowOtherUser.frame.size.height);
                    viewArrowSameUser.frame = CGRectMake(viewArrowSameUser.frame.origin.x, viewBottom.frame.origin.y-viewArrowSameUser.frame.size.height , viewArrowSameUser.frame.size.width, viewArrowSameUser.frame.size.height);
                    
                    viewBackWhite.frame = CGRectMake(viewBackWhite.frame.origin.x, viewBackWhite.frame.origin.y , viewBackWhite.frame.size.width, (viewBottom.frame.size.height +viewBottom.frame.origin.y+1));
                }
                else if([[tempDict objectForKeyNonNull:@"postDesc"] length] && [[tempDict objectForKeyNonNull:@"className"] length])
                {
                    viewClassName.frame = CGRectMake(10, 45 , viewClassName.frame.size.width, viewClassName.frame.size.height);
                    //         viewDescription.frame = CGRectMake(10, 65 , viewDescription.frame.size.width, viewDescription.frame.size.height);
                    lblDescription.frame = CGRectMake(lblDescription.frame.origin.x, 65, lblDescription.frame.size.width, lblDescription.frame.size.height);
                    
                    //            lblPostHeading.frame = CGRectMake(15, 90 , lblPostHeading.frame.size.width, lblPostHeading.frame.size.height);
                    //            btnPostHeading.frame = CGRectMake(15, 90 , btnPostHeading.frame.size.width, btnPostHeading.frame.size.height);
                    
                    lblLine.frame = CGRectMake(15, (lblDescription.frame.size.height +lblDescription.frame.origin.y+2) , lblLine.frame.size.width, lblLine.frame.size.height);
                    
                    viewBottom.frame = CGRectMake(viewBottom.frame.origin.x, (lblDescription.frame.size.height +lblDescription.frame.origin.y+10), viewBottom.frame.size.width, viewBottom.frame.size.height);
                    
                    viewArrowOtherUser.frame = CGRectMake(viewArrowOtherUser.frame.origin.x,viewBottom.frame.origin.y-viewArrowOtherUser.frame.size.height , viewArrowOtherUser.frame.size.width, viewArrowOtherUser.frame.size.height);
                    viewArrowSameUser.frame = CGRectMake(viewArrowSameUser.frame.origin.x, viewBottom.frame.origin.y-viewArrowSameUser.frame.size.height , viewArrowSameUser.frame.size.width, viewArrowSameUser.frame.size.height);
                    
                    viewBackWhite.frame = CGRectMake(viewBackWhite.frame.origin.x, viewBackWhite.frame.origin.y , viewBackWhite.frame.size.width, (viewBottom.frame.size.height +viewBottom.frame.origin.y+1));
                }
                else if (![[tempDict objectForKeyNonNull:@"postDesc"] length] && [[tempDict objectForKeyNonNull:@"className"] length])
                {
                    viewClassName.frame = CGRectMake(10, 45 , viewClassName.frame.size.width, viewClassName.frame.size.height);
                    
                    //            lblPostHeading.frame = CGRectMake(15, 70 , lblPostHeading.frame.size.width, lblPostHeading.frame.size.height);
                    //            btnPostHeading.frame = CGRectMake(15, 70 , btnPostHeading.frame.size.width, btnPostHeading.frame.size.height);
                    
                    lblLine.frame = CGRectMake(15, (lblDescription.frame.size.height +lblDescription.frame.origin.y+2) , lblLine.frame.size.width, lblLine.frame.size.height);
                    
                    viewBottom.frame = CGRectMake(viewBottom.frame.origin.x, (lblDescription.frame.size.height +lblDescription.frame.origin.y+10), viewBottom.frame.size.width, viewBottom.frame.size.height);
                    viewArrowOtherUser.frame = CGRectMake(viewArrowOtherUser.frame.origin.x, viewBottom.frame.origin.y-viewArrowOtherUser.frame.size.height , viewArrowOtherUser.frame.size.width, viewArrowOtherUser.frame.size.height);
                    viewArrowSameUser.frame = CGRectMake(viewArrowSameUser.frame.origin.x, viewBottom.frame.origin.y-viewArrowSameUser.frame.size.height , viewArrowSameUser.frame.size.width, viewArrowSameUser.frame.size.height);
                    
                    viewBackWhite.frame = CGRectMake(viewBackWhite.frame.origin.x, viewBackWhite.frame.origin.y , viewBackWhite.frame.size.width, (viewBottom.frame.size.height +viewBottom.frame.origin.y+1));
                }
                else
                {
                    //            lblPostHeading.frame = CGRectMake(10, 60 , lblPostHeading.frame.size.width, lblPostHeading.frame.size.height);
                    //            btnPostHeading.frame = CGRectMake(10, 60 , btnPostHeading.frame.size.width, btnPostHeading.frame.size.height);
                    lblLine.frame = CGRectMake(15, 70 , lblLine.frame.size.width, lblLine.frame.size.height);
                    
                    viewBottom.frame = CGRectMake(viewBottom.frame.origin.x, 75, viewBottom.frame.size.width, viewBottom.frame.size.height);
                    
                    viewArrowOtherUser.frame = CGRectMake(viewArrowOtherUser.frame.origin.x, viewBottom.frame.origin.y-viewArrowOtherUser.frame.size.height , viewArrowOtherUser.frame.size.width, viewArrowOtherUser.frame.size.height);
                    viewArrowSameUser.frame = CGRectMake(viewArrowSameUser.frame.origin.x, viewBottom.frame.origin.y-viewArrowSameUser.frame.size.height , viewArrowSameUser.frame.size.width, viewArrowSameUser.frame.size.height);
                    
                    viewBackWhite.frame = CGRectMake(viewBackWhite.frame.origin.x, viewBackWhite.frame.origin.y , viewBackWhite.frame.size.width, (viewBottom.frame.size.height +viewBottom.frame.origin.y+1));
                }
                
            }
            
            
            if([[tempDict objectForKeyNonNull:@"isLike"] isEqualToString:@"True"])
            {
                [btnLike setSelected:YES];
                [btnDislike setSelected:NO];
            }
            else if([[tempDict objectForKeyNonNull:@"isLike"] isEqualToString:@"False"])
            {
                [btnLike setSelected:NO];
                [btnDislike setSelected:YES];
            }
            else
            {
                [btnLike setSelected:NO];
                [btnDislike setSelected:NO];
            }
            
            lblLikeCount.text = [tempDict objectForKeyNonNull:@"likeCount"];
            btnLike.tag = indexPath.row+10;
            [btnLike addTarget:self action:@selector(likeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            
            lblDislikeCount.text = [tempDict objectForKeyNonNull:@"unLikeCount"];
            btnDislike.tag = indexPath.row+10;
            [btnDislike addTarget:self action:@selector(dislikeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            
            lblCommentCount.text = [tempDict objectForKeyNonNull:@"commentCount"];
            btnComment.tag = indexPath.row+10;
            [btnComment addTarget:self action:@selector(commentButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            
            //    lblPostHeading.text = [NSString stringWithFormat:@"%@",[tempDict objectForKeyNonNull:@"postHeading"]];
            //        lblPostHeading.textColor = [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8];
            //    if([[tempDict objectForKeyNonNull:@"isLink"] isEqualToString:@"True"])
            //    {
            //        btnPostHeading.tag = indexPath.row+10;
            //        [btnPostHeading addTarget:self action:@selector(postHeadingButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            //    }
            
            viewArrowSameUser.hidden = YES;
            viewArrowOtherUser.hidden = YES;
            
            [btnArrow addTarget:self action:@selector(arrowButtonClick:event:) forControlEvents:UIControlEventTouchUpInside];
            
            
            NSLog(@"lblusername = %@",lblUserName.text);
            
        });
        return cell;
    }
    else
    {
        UITableViewCell *cell = nil;
        static NSString *CellIdentifier = @"Cell";
        cell  = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if(cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PostViewCell" owner:self options:nil];
            cell = [nib objectAtIndex:1];
            //Sourabh
            //cell.backgroundColor = [UIColor clearColor];
            //cell.contentView.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.clipsToBounds = YES;
            
        }
        
        cell.tag = indexPath.row;
        NSDictionary *tempDict = [arrayCommentsList objectAtIndex:indexPath.row];
        
        UIImageView *imgProfileImage = (UIImageView *)[cell.contentView viewWithTag:10];
        UILabel *lblUserName = (UILabel *)[cell.contentView viewWithTag:11];
        UILabel *lblTime = (UILabel *)[cell.contentView viewWithTag:12];
        UITextView *txtViewComment = (UITextView *)[cell.contentView viewWithTag:13];
        UILabel *lblSaperator = (UILabel *)[cell.contentView viewWithTag:14];
        UIButton *btnEdit = (UIButton *)[cell.contentView viewWithTag:15];
        UIButton *btnDelete = (UIButton *)[cell.contentView viewWithTag:16];
        //imgProfileImage.image = [UIImage imageNamed:@"placeholder"];
        //[imgProfileImage sd_setImageWithURL:[NSURL URLWithString:[tempDict objectForKeyNonNull:@"profilePicture"]] placeholderImage:[UIImage imageNamed:@"fb"]];
        if(cell.tag == indexPath.row)
        {
            [imgProfileImage sd_setImageWithURL:[NSURL URLWithString:[tempDict objectForKeyNonNull:@"profilePicture"]] placeholderImage:[UIImage imageNamed:@"appicon.png"]];
            [imgProfileImage setupImageViewer];
            [cell setNeedsLayout];
        }
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            imgProfileImage.layer.cornerRadius = imgProfileImage.frame.size.width/2;
            imgProfileImage.layer.borderWidth = 2.0;
            imgProfileImage.layer.borderColor = [[UIColor whiteColor] CGColor];
            
            lblUserName.text = [tempDict objectForKeyNonNull:@"userName"];
            lblTime.text = [Utils timeAgo:[tempDict objectForKeyNonNull:@"commentDate"] withFormat:@"MM/dd/yyyy hh:mm:ss a" ];
            
            txtViewComment.text = [tempDict objectForKeyNonNull:@"postComment"];
            //        CGSize  currentSize = [[tempDict objectForKey:@"postComment"] sizeWithFont:[UIFont systemFontOfSize:10.0] constrainedToSize:CGSizeMake(220, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
            //        float height = currentSize.height+10;
            //        txtViewComment.frame = CGRectMake(txtViewComment.frame.origin.x, txtViewComment.frame.origin.y, txtViewComment.frame.size.width,height);
            //        lblSaperator.frame = CGRectMake(lblSaperator.frame.origin.x, txtViewComment.frame.origin.y+height+10, lblSaperator.frame.size.width,lblSaperator.frame.size.height);
            
            
            if([[tempDict objectForKeyNonNull:@"userId"] isEqualToString:[defaults objectForKey:kUserId]] )
            {
                btnEdit.tag = indexPath.row+10;
                [btnEdit addTarget:self action:@selector(editCommentButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                
                btnDelete.tag = indexPath.row+10;
                [btnDelete addTarget:self action:@selector(deleteCommentButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            }
            else if([[[arrayPostList objectAtIndex:selectedIndex] objectForKeyNonNull:@"createdById"] isEqualToString:[defaults objectForKey:kUserId]])
            {
                btnDelete.tag = indexPath.row+10;
                [btnDelete addTarget:self action:@selector(deleteCommentButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                
                btnEdit.hidden = YES;
            }
            else
            {
                btnEdit.hidden = YES;
                btnDelete.hidden = YES;
            }
            
            
        });
        return cell;
    }
    
}

#pragma mark Textfield Delegate Method

- (void)textFieldDidBeginEditing:(UITextField *)textField          // became first responder
{
  tempTxtField = textField;
  [self setViewMovedUp:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField              // called when 'return' key pressed.
{
  [tempTxtField resignFirstResponder];
  return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
  [self setViewMovedUp:NO];
}

#pragma mark Button Action Method

- (void)moreButtonClick:(UIButton *)btn
{
//  [tempTxtField resignFirstResponder];
//  self.viewDescription.frame = CGRectMake(0, 0, self.viewDescription.frame.size.width, self.view.frame.size.height);
//  [self.view addSubview:self.viewDescription];
//  NSDictionary *tempDic = [arrayPostList objectAtIndex:btn.tag-10 ];
//  UITextView *txtViewDescription = ((UITextView *)[self.viewDescription viewWithTag:10]);
//  txtViewDescription.text = [tempDic objectForKeyNonNull:@"postDesc"];
//  CGSize  currentSize = [[tempDic objectForKey:@"postDesc"] sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(self.view.frame.size.width-60, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
//  float height = currentSize.height+20.0;
//  if(height > self.view.frame.size.height-165-70)
//    height = self.view.frame.size.height-165-70;
//  txtViewDescription.frame =CGRectMake(txtViewDescription.frame.origin.x, txtViewDescription.frame.origin.y, txtViewDescription.frame.size.width,height);
    
    [tempTxtField resignFirstResponder];
    self.commentsBackView.layer.cornerRadius = 5.0f;
    self.viewDescription.frame = CGRectMake(0, 568, self.viewDescription.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:self.viewDescription];
    
    [UIView animateWithDuration:.8
                          delay: .1
                        options: (UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         self.viewDescription.frame = CGRectMake(0, self.viewDescription.frame.origin.y - 568, self.viewDescription.frame.size.width, self.viewDescription.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         if (finished)
                         {
//                             NSLog(@"Done!");
//                             NSDictionary *tempDic = [arrayPostList objectAtIndex:btn.tag-10 ];
//                             STTweetLabel *lblDescription = ((STTweetLabel *)[self.viewDescription viewWithTag:10]);
//                             lblDescription.text = [tempDic objectForKeyNonNull:@"postDesc"];
//                             
//                             
//                             
//                             lblDescription.detectionBlock = ^(STTweetHotWord hotWord, NSString *string, NSString *protocol, NSRange range) {
//                                 
//                                 NSArray *hotWords = @[@"Handle", @"Hashtag", @"Link"];
//                                 NSLog(@"%@",[NSString stringWithFormat:@"%@ [%d,%d]: %@%@", hotWords[hotWord], (int)range.location, (int)range.length, string, (protocol != nil) ? [NSString stringWithFormat:@" *%@*", protocol] : @""]);
//                             };
//                             
//                             UIScrollView *scrollview=(UIScrollView *)[self.viewDescription viewWithTag:11];
//                             [scrollview setContentSize:CGSizeMake(scrollview.width, lblDescription.height+20)];
//                             CGSize  currentSize = [[tempDic objectForKey:@"postDesc"] sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(self.view.frame.size.width-60, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
//                             float height = currentSize.height+20.0;
//                             if(height > self.view.frame.size.height-165-70)
//                                 height = self.view.frame.size.height-165-70;
//                             txtViewDescription.frame =CGRectMake(txtViewDescription.frame.origin.x, txtViewDescription.frame.origin.y, txtViewDescription.frame.size.width,height);
                         }
                     }];
    
    
}

- (void)likeButtonClick:(UIButton *)btn
{
  [tempTxtField resignFirstResponder];
  [self callAPISetLikeOrDislike:btn.isSelected ? @"":@"True" Index:btn.tag-10 Superview:btn.superview];
  
}

- (void)dislikeButtonClick:(UIButton *)btn
{
  [tempTxtField resignFirstResponder];
  [self callAPISetLikeOrDislike:btn.isSelected ? @"":@"False" Index:btn.tag-10 Superview:btn.superview];
}

- (void)commentButtonClick:(UIButton *)btn
{
//  [tempTxtField resignFirstResponder];
//  self.viewComments.frame = CGRectMake(0, 0, self.viewComments.frame.size.width, self.view.frame.size.height);
//  [self.view addSubview:self.viewComments];
//  selectedIndex = btn.tag - 10;
//  pageNumberForComments = 0;
//  isNewDataArriveForComment = YES;
//  [self callAPIGetComments:selectedIndex Loading:YES];
    
    [tempTxtField resignFirstResponder];
    self.viewComments.frame = CGRectMake(0, 568, self.viewComments.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:self.viewComments];
    self.commentsBackView.layer.cornerRadius = 5.0f;
    

    
    
    [UIView animateWithDuration:.8
                          delay: .1
                        options: (UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         self.viewComments.frame = CGRectMake(0, self.viewComments.frame.origin.y - 568, self.viewComments.frame.size.width, self.viewComments.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         if (finished)
                         {
                             NSLog(@"Done!");
                             selectedIndex = btn.tag - 10;
                             pageNumberForComments = 0;
                             isNewDataArriveForComment = YES;
                             [self callAPIGetComments:selectedIndex Loading:YES];
                         }
                     }];
  
}

- (void)postImageButtonClick:(UITapGestureRecognizer *)gesture
{
  [tempTxtField resignFirstResponder];
  CGPoint location = [gesture locationInView:self.view];
  
  if (CGRectContainsPoint([self.view convertRect:self.tableView.frame fromView:self.tableView.superview], location))
  {
    self.viewFullImage.frame = CGRectMake(0, 0, self.viewFullImage.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:self.viewFullImage];
    UIImageView *imgView = (UIImageView *)[self.viewFullImage viewWithTag:11];
    [imgView setImage:((UIImageView *)gesture.view).image];
    return;
  }
}

- (void)editCommentButtonClick:(UIButton *)btn
{
  [tempTxtField resignFirstResponder];
  self.viewEditComment.frame = CGRectMake(0, 0, self.viewEditComment.frame.size.width, self.view.frame.size.height);
  [self.view addSubview:self.viewEditComment];
  editCommentId = [[arrayCommentsList objectAtIndex:btn.tag-10] objectForKeyNonNull:@"commentId"];
  self.txtFieldEditComment.text = [[arrayCommentsList objectAtIndex:btn.tag-10] objectForKeyNonNull:@"postComment"];
}

- (void)deleteCommentButtonClick:(UIButton *)btn
{
  [tempTxtField resignFirstResponder];
  [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"Are you sure you want to delete this comment?" leftButtonTitle:@"Yes" rightButtonTitle:@"No" selectedButton:^(NSInteger selected, UIAlertView *aView)
   {
     if(selected == 0)
     {
       [self callAPIDeleteComment:btn.tag-10];
     }
   }];
}

- (void)postHeadingButtonClick:(NSString *)str
{
  [tempTxtField resignFirstResponder];
  
  UINavigationController *navC = [SharedAppDelegate.tabBarController.viewControllers objectAtIndex:0];
  [navC popToRootViewControllerAnimated:YES];
  PostViewController *postViewC = [navC.viewControllers objectAtIndex:0];
    
    [postViewC postHeadingButtonClick:str];
  [self.tabBarController setSelectedIndex:0];
}

- (void)arrowButtonClick:(id)sender event:(id)event
{
  [tempTxtField resignFirstResponder];
  NSSet *touches = [event allTouches];
  UITouch *touch = [touches anyObject];
  CGPoint currentTouchPosition = [touch locationInView:self.tableView];
  NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:currentTouchPosition];
  UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
  
  UIView *viewSameUser = (UIView *)[cell.contentView viewWithTag:30];
  UIButton *btnEdit = (UIButton *)[cell.contentView viewWithTag:32];
  UIButton *btnDelete = (UIButton *)[cell.contentView viewWithTag:34];
  
  UIView *viewOtherUser = (UIView *)[cell.contentView viewWithTag:35];
  UIButton *btnReportAbuse = (UIButton *)[cell.contentView viewWithTag:37];
  
  
  if ([[[arrayPostList objectAtIndex:indexPath.row] objectForKey:kCreatedById] isEqualToString:[defaults objectForKey:kUserId]])
  {
    if(viewSameUser.hidden == YES)
    {
      viewSameUser.hidden = NO;
    }
    else
    {
      viewSameUser.hidden = YES;
    }
    viewOtherUser.hidden = YES;
    
    [btnEdit addTarget:self action:@selector(editButtonClick:event:) forControlEvents:UIControlEventTouchUpInside];
    [btnDelete addTarget:self action:@selector(deleteButtonClick:event:) forControlEvents:UIControlEventTouchUpInside];
  }
  else
  {
    if(viewOtherUser.hidden == YES)
    {
      viewOtherUser.hidden = NO;
    }
    else
    {
      viewOtherUser.hidden = YES;
    }
    viewSameUser.hidden = YES;
    
    [btnReportAbuse addTarget:self action:@selector(reportAbuseButtonClick:event:) forControlEvents:UIControlEventTouchUpInside];
  }
}

- (void)editButtonClick:(id)sender event:(id)event
{
  
  NSSet *touches = [event allTouches];
  UITouch *touch = [touches anyObject];
  CGPoint currentTouchPosition = [touch locationInView:self.tableView];
  NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
  
  UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
  UIView *view = [cell.contentView viewWithTag:30];
  view.hidden = YES;
  
  NSDictionary *tempDict = [arrayPostList objectAtIndex:indexPath.row];
  if ([[tempDict objectForKey:kCreatedById] isEqualToString:[defaults objectForKey:kUserId]])
  {
    CreatePostViewController * createVxiew = [[CreatePostViewController alloc]initWithNibName:@"CreatePostViewController" bundle:nil];
    createVxiew.isAlive = YES;
    createVxiew.dictEditPostBlob = tempDict;
    [self.navigationController pushViewController:createVxiew animated:YES];
  }
  else
  {
    [Utils showAlertViewWithMessage:@"You can not edit other user yap."];
  }
}

- (void)reportAbuseButtonClick:(id)sender event:(id)event
{
  NSSet *touches = [event allTouches];
  UITouch *touch = [touches anyObject];
  CGPoint currentTouchPosition = [touch locationInView:self.tableView];
  NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
  
  UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
  UIView *view = [cell.contentView viewWithTag:35];
  view.hidden = YES;
  
  NSDictionary *tempDict = [arrayPostList objectAtIndex:indexPath.row];
  if (![[tempDict objectForKey:kCreatedById] isEqualToString:[defaults objectForKey:kUserId]])
  {
    [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"Are you sure you want to report abuse this yap?" leftButtonTitle:@"Yes" rightButtonTitle:@"No" selectedButton:^(NSInteger selected, UIAlertView *aView)
     {
       if(selected == 0)
       {
         [self callAPISendReport:indexPath.row];
       }
     }];
  }
  else
  {
    [Utils showAlertViewWithMessage:@"You can not report abuse own yap."];
  }
  
}

- (void)deleteButtonClick:(id)sender event:(id)event
{
  NSSet *touches = [event allTouches];
  UITouch *touch = [touches anyObject];
  CGPoint currentTouchPosition = [touch locationInView:self.tableView];
  NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
  
  UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
  UIView *view = [cell.contentView viewWithTag:30];
  view.hidden = YES;
  
  NSDictionary *tempDict = [arrayPostList objectAtIndex:indexPath.row];
  if ([[tempDict objectForKey:kCreatedById] isEqualToString:[defaults objectForKey:kUserId]])
  {
    [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"Are you sure you want to delete this yap?" leftButtonTitle:@"Yes" rightButtonTitle:@"No" selectedButton:^(NSInteger selected, UIAlertView *aView)
     {
       if(selected == 0)
       {
         [self callAPIDeleteBlog:indexPath.row];
       }
     }];
  }
  else
  {
    [Utils showAlertViewWithMessage:@"You can not delete other user yap."];
  }
  
}

#pragma mark - Web Service Method

- (void)callAPIViewProfile
{
  NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                            [defaults objectForKey:kUserId],kUserId,
                            _buddyId,kBuddyId,
                            nil];
  
  [Utils startLoaderWithMessage:@""];
  
  [Connection callServiceWithName:kGetBuddyProfileDetail postData:dictSend callBackBlock:^(id response, NSError *error)
   {
     [Utils stopLoader];
     if (response)
     {
       if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
       {
         arrayPrifleDetails = nil;
         arrayPrifleDetails = [[NSMutableArray alloc]initWithArray:[[response objectForKeyNonNull:kResult] objectForKeyNonNull:kProfilePicture]];
         
         _dictGetEditProfileDetails =[response objectForKeyNonNull:kResult];
         
         [self setUserDataWithDictionary:[response objectForKeyNonNull:kResult]];
         [self callAPIPostBlogList];
         //[_tableView reloadData];
       }
     }
   }];
}

- (void)callAPISendInvite
{
  NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                            [defaults objectForKey:kUserId],kUserId,
                            _buddyId,kBuddyId,
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
         [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:message buttonArray:@[@"OK"] selectedButton:^(NSInteger selected, UIAlertView *aView) {
           [self.navigationController popViewControllerAnimated:YES];
         }];
       }
     }
   }];
  
}

- (void)callAPIPostBlogList
{
  if(!_isViewProfile)
  {
    
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
                              [NSNumber numberWithInteger:pageNumber],kPage,
                              nil];
    
    [Utils startLoaderWithMessage:@""];
    
    [Connection callServiceWithName:kGetPostBlogList postData:dictSend callBackBlock:^(id response, NSError *error)
     {
       [Utils stopLoader];
       if (response)
       {
         if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
         {
           pageNumber++;
           if(isNewDataArrive)
           {
             
             [arrayPostList removeAllObjects];
             [arrayPostList addObjectsFromArray:[response objectForKeyNonNull:kResult]];
             [self.tableView reloadData];
             self.tableView.contentOffset = CGPointMake(0, 0);
           }
           else
           {
             [arrayPostList addObjectsFromArray:[[response objectForKey:kResult] mutableCopy]];
             [self.tableView reloadData];
           }
           
         }
           dispatch_async(dispatch_get_main_queue(), ^{
             
                   if (arrayPostList.count<=1)
                   {
                       _lblYaps.text=@"Yap";
                   }
                   else
                   {
                       _lblYaps.text=@"Yaps";
                   }
                   // Adding the code to show umber of yaps.
                   [_yapsLabel setText:[NSString stringWithFormat:@"%lu",(unsigned long)[arrayPostList count]]];
              
           });
           
           
       }
       [pullToRefreshManagerPost tableViewReloadFinished];
       [pullToRefreshManagerComment tableViewReloadFinished];
     }];
    
  }
  
  else
  {
    
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              _buddyId,kUserId,
                              pageNumber,kPage,
                              nil];
    
    [Utils startLoaderWithMessage:@""];
    
    [Connection callServiceWithName:kGetPostBlogList postData:dictSend callBackBlock:^(id response, NSError *error)
     {
       [Utils stopLoader];
       if (response)
       {
         if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
         {
           arrayPostList =nil;
           arrayPostList = [[NSMutableArray alloc] initWithArray:[response objectForKeyNonNull:kResult]];
             dispatch_async(dispatch_get_main_queue(), ^{
                  // Adding the code to show umber of yaps.
                 
                 if (arrayPostList.count<=1)
                 {
                     _lblYaps.text=@"Yap";
                 }
                 else
                 {
                     _lblYaps.text=@"Yaps";
                 }
                     [_yapsLabel setText:[NSString stringWithFormat:@"%lu",(unsigned long)[arrayPostList count]]];
                
             });

           
           [_tableView reloadData];
         }
       }
       [pullToRefreshManagerPost tableViewReloadFinished];
       [pullToRefreshManagerComment tableViewReloadFinished];
     }];
    
    
  }
}

-(void)callAPIAcceptRequest
{
  
  NSString * BuddyId =_buddyId;
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
         [self callAPIViewProfile];
       }
     }
   }];
  
}


-(void)callAPIRejectRequest
{
  
  
  NSString * BuddyId =_buddyId;
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
         [self callAPIViewProfile];
         NSLog(@"Now You are not friend");
       }
     }
   }];
  
}

- (void)callAPIGetComments:(NSInteger)index1 Loading:(BOOL)isLoading
{
  NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                            [defaults objectForKey:kUserId],kUserId,
                            [NSString stringWithFormat:@"%d",pageNumberForComments],kPage,
                            [[arrayPostList objectAtIndex:index1] objectForKeyNonNull:@"postId"],@"postId",
                            nil];
  if(isLoading)
    [Utils startLoaderWithMessage:@""];
  
  [Connection callServiceWithName:kGetCommentsBlogWise postData:dictSend callBackBlock:^(id response, NSError *error)
   {
     
     [Utils stopLoader];
     if (response)
     {
       if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
       {
         pageNumberForComments++;
         if(isNewDataArriveForComment)
         {
           
           [arrayCommentsList removeAllObjects];
           [arrayCommentsList addObjectsFromArray:[response objectForKeyNonNull:kResult]];
           [self.tblViewComments reloadData];
         }
         else
         {
           [arrayCommentsList addObjectsFromArray:[[response objectForKey:kResult] mutableCopy]];
           [self.tblViewComments reloadData];
         }
       }
     }
     [pullToRefreshManagerPost tableViewReloadFinished];
     [pullToRefreshManagerComment tableViewReloadFinished];
   }];
}

- (void)callAPISetLikeOrDislike:(NSString*)isLike Index:(int)index1 Superview:(UIView *)view
{
  NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                            [defaults objectForKey:kUserId],kUserId,
                            [[arrayPostList objectAtIndex:index1] objectForKeyNonNull:@"postId"],@"postId",
                            isLike,@"isLike",
                            nil];
  
  [Utils startLoaderWithMessage:@""];
  
  [Connection callServiceWithName:kBlogLike postData:dictSend callBackBlock:^(id response, NSError *error)
   {
     
     [Utils stopLoader];
     if (response)
     {
       if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
       {
         UIButton *btnLike =  (UIButton*)[view viewWithTag:1718];
         UILabel *lblLike =  (UILabel*)[view viewWithTag:1719];
         UIButton *btnDislike =  (UIButton*)[view viewWithTag:1720];
         UILabel *lblDislike =  (UILabel*)[view viewWithTag:1721];
         
         lblLike.text = [[response objectForKeyNonNull:kResult] objectForKeyNonNull:@"likeCount"];
         lblDislike.text = [[response objectForKeyNonNull:kResult] objectForKeyNonNull:@"unLikeCount"];
         
         if([[[response objectForKeyNonNull:kResult] objectForKeyNonNull:@"isLike"] isEqualToString:@"True"])
         {
           [btnLike setSelected:YES];
           [btnDislike setSelected:NO];
         }
         else if([[[response objectForKeyNonNull:kResult] objectForKeyNonNull:@"isLike"] isEqualToString:@"False"])
         {
           [btnLike setSelected:NO];
           [btnDislike setSelected:YES];
         }
         else
         {
           [btnLike setSelected:NO];
           [btnDislike setSelected:NO];
         }
         
         NSMutableDictionary *tempDic = [[arrayPostList objectAtIndex:index1] mutableCopy];
         [tempDic setObject:[[response objectForKeyNonNull:kResult] objectForKeyNonNull:@"likeCount"] forKey:@"likeCount"];
         [tempDic setObject:[[response objectForKeyNonNull:kResult] objectForKeyNonNull:@"unLikeCount"] forKey:@"unLikeCount"];
         [tempDic setObject:[[response objectForKeyNonNull:kResult] objectForKeyNonNull:@"isLike"] forKey:@"isLike"];
         [arrayPostList replaceObjectAtIndex:index1 withObject:tempDic];
           
         [self.tableView reloadData];
           
          
       }
     }
   }];
}


- (void)callAPIAddComment:(int)index1
{
  NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                            [defaults objectForKey:kUserId],kUserId,
                            @"",@"commentId",
                            [[arrayPostList objectAtIndex:index1] objectForKeyNonNull:@"postId"],@"postId",self.txtFieldComments.text,@"commentText",
                            nil];
  
  [Utils startLoaderWithMessage:@""];
  
  [Connection callServiceWithName:kAddComment postData:dictSend callBackBlock:^(id response, NSError *error)
   {
     
     [Utils stopLoader];
     if (response)
     {
       if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
       {
         NSLog(@"%@",[defaults objectForKey:kProfilePicture]);
         self.txtFieldComments.text = @"";
         NSMutableDictionary *tempDic = [[response objectForKeyNonNull:kResult] mutableCopy];
         [tempDic setObject:[defaults objectForKey:kName] forKey:@"userName"];
         [tempDic setObject:[defaults objectForKey:kProfilePicture] forKey:@"profilePicture"];
         [arrayCommentsList addObject:tempDic];
         [self.tblViewComments reloadData];
         [self.tblViewComments scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[arrayCommentsList count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
         [pullToRefreshManagerPost tableViewReloadFinished];
         [pullToRefreshManagerComment tableViewReloadFinished];
       }
     }
   }];
}

- (void)callAPIEditComment:(int)index1 CommentId:(NSString *)commentId
{
  NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                            [defaults objectForKey:kUserId],kUserId,commentId
                            ,@"commentId",
                            [[arrayPostList objectAtIndex:index1] objectForKeyNonNull:@"postId"],@"postId",self.txtFieldEditComment.text,@"commentText",
                            nil];
  
  [Utils startLoaderWithMessage:@""];
  
  [Connection callServiceWithName:kAddComment postData:dictSend callBackBlock:^(id response, NSError *error)
   {
     
     [Utils stopLoader];
     if (response)
     {
       if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
       {
         [self.viewEditComment removeFromSuperview];
         pageNumberForComments = 0;
         isNewDataArriveForComment = YES;
         [self callAPIGetComments:selectedIndex Loading:YES];
       }
     }
   }];
}

- (void)callAPIDeleteComment:(int)index1
{
  NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                            [defaults objectForKey:kUserId],kUserId,
                            [[arrayCommentsList objectAtIndex:index1] objectForKeyNonNull:@"commentId"],@"commentId",
                            nil];
  
  [Utils startLoaderWithMessage:@""];
  
  [Connection callServiceWithName:kDeleteComment postData:dictSend callBackBlock:^(id response, NSError *error)
   {
     
     [Utils stopLoader];
     if (response)
     {
       if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
       {
         pageNumberForComments = 0;
         isNewDataArriveForComment = YES;
         [self callAPIGetComments:selectedIndex Loading:YES];
       }
     }
   }];
}

- (void)callAPISendReport:(int)index1
{
  NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                            [defaults objectForKey:kUserId],kUserId,
                            [[arrayPostList objectAtIndex:index1] objectForKeyNonNull:@"postId"],@"postId",
                            nil];
  
  [Utils startLoaderWithMessage:@""];
  
  [Connection callServiceWithName:kReportAbuse postData:dictSend callBackBlock:^(id response, NSError *error)
   {
     
     [Utils stopLoader];
     if (response)
     {
       if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
       {
         [arrayPostList removeObjectAtIndex:index1];
         [self.tableView reloadData];
       }
     }
   }];
}

- (void)callAPIDeleteBlog:(int)index1
{
  NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                            [[arrayPostList objectAtIndex:index1] objectForKeyNonNull:@"postId"],@"id",
                            nil];
  
  [Utils startLoaderWithMessage:@""];
  
  [Connection callServiceWithName:kDeletePost postData:dictSend callBackBlock:^(id response, NSError *error)
   {
     
     [Utils stopLoader];
     if (response)
     {
       if ([[response objectForKeyNonNull:kSuccess] boolValue])
       {
         [arrayPostList removeObjectAtIndex:index1];
         [self.tableView reloadData];
       }
     }
   }];
}

#pragma mark - Gesture Method

- (void)tapOnce:(UIGestureRecognizer *)gesture
{
  NSMutableArray *arrImages = [[NSMutableArray alloc] initWithArray:[_dictGetEditProfileDetails objectForKeyNonNull:kProfilePicture]];
  //    for (UIImageView *imgView in self.scrollViewImages.subviews)
  //    {
  //        [arrImages addObject:imgView.image];
  //    }
  index = _scrollViewImages.contentOffset.x/_scrollViewImages.frame.size.width;
  [SharedAppDelegate.window addSubview:_viewFullImage];
  UIImageView *imgView = (UIImageView *)[self.viewFullImage viewWithTag:11];
  [imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImageURl,[[arrImages objectAtIndex:index] objectForKeyNonNull:kImage]]]];
    [imgView setupImageViewer];
  
  arrImagesSwipe = nil;
  arrImagesSwipe = [[NSArray alloc] initWithArray:arrImages];
}

- (void)swipeImagesLeft:(UISwipeGestureRecognizer*)swipeGesture
{
  
  
  if (index + 1 < arrImagesSwipe.count)
  {
    index = index + 1;
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.3];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromRight];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    UIImageView *imgView = (UIImageView *)[self.viewFullImage viewWithTag:11];
    [[imgView layer] addAnimation:animation forKey:@"SwitchToView"];
  }
  
  UIImageView *imgView = (UIImageView *)[self.viewFullImage viewWithTag:11];
  [imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImageURl,[[arrImagesSwipe objectAtIndex:index] objectForKeyNonNull:kImage]]]];
}
- (void)swipeImagesRight:(UISwipeGestureRecognizer*)swipeGesture
{
  
  if (index - 1 >= 0)
  {
    index = index - 1;
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.3];
    [animation setType:kCATransitionPush];
    
    [animation setSubtype:kCATransitionFromLeft];
    
    
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    UIImageView *imgView = (UIImageView *)[self.viewFullImage viewWithTag:11];
    
    [[imgView layer] addAnimation:animation forKey:@"SwitchToView"];
  }
  UIImageView *imgView = (UIImageView *)[self.viewFullImage viewWithTag:11];
  
  [imgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImageURl,[[arrImagesSwipe objectAtIndex:index] objectForKeyNonNull:kImage]]]];
  
}

#pragma mark Calculate Height For Tableview Row Method

- (float) calculateHeightForCommentRow:(NSIndexPath*)index1
{
  float y = 15.0;
  CGSize  currentSize = [[[arrayCommentsList objectAtIndex:index1.row] objectForKey:@"postComment"] sizeWithFont:[UIFont systemFontOfSize:10.0] constrainedToSize:CGSizeMake(220, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
  y = y + currentSize.height+10;
  return y+20;
}

- (float) calculateHeightForPostRow:(NSIndexPath*)index1
{
    NSDictionary *tempDict = arrayPostList[index1.row];
    
    UITableViewCell *cell = nil;
    static NSString *CellIdentifier = @"Cell";
    
    cell  = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PostViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    UILabel *lblDescription = (UILabel *)[cell.contentView viewWithTag:15];
    lblDescription.text = [tempDict objectForKeyNonNull:@"postDesc"];
    
    float descHeight=[self getLabelHeight:lblDescription]+5;
    if (descHeight<30)
    {
        descHeight=30;
    }
    
    if([[[arrayPostList objectAtIndex:index1.row] objectForKeyNonNull:@"postImage"] length] && [[arrayPostList objectAtIndex:index1.row] objectForKeyNonNull:@"postDesc"])
        return 247+descHeight;
    
    else if([[[arrayPostList objectAtIndex:index1.row] objectForKeyNonNull:@"postImage"] length] && ![[arrayPostList objectAtIndex:index1.row] objectForKeyNonNull:@"postDesc"])
        return 237;
    
    else if([[[arrayPostList objectAtIndex:index1.row] objectForKeyNonNull:@"postDesc"] length] && ![[[arrayPostList objectAtIndex:index1.row] objectForKeyNonNull:@"className"] length])
        return 93+descHeight;
    else if([[[arrayPostList objectAtIndex:index1.row] objectForKeyNonNull:@"postDesc"] length] && [[[arrayPostList objectAtIndex:index1.row] objectForKeyNonNull:@"className"] length])
        return 113+descHeight;
    else if (![[[arrayPostList objectAtIndex:index1.row] objectForKeyNonNull:@"postDesc"] length] && [[[arrayPostList objectAtIndex:index1.row] objectForKeyNonNull:@"className"] length])
        return 113;
    else
        return 118;

}
- (CGFloat)getLabelHeight:(UILabel*)label
{
    CGSize constraint = CGSizeMake(label.frame.size.width, 20000.0f);
    CGSize size;
    
    NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
    CGSize boundingBox = [label.text boundingRectWithSize:constraint
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:@{NSFontAttributeName:label.font}
                                                  context:context].size;
    
    size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height));
    
    return size.height;
}

#pragma mark MNMBottomPullToRefreshManagerClient

/**
 * This is the same delegate method as UIScrollView but required in MNMBottomPullToRefreshManagerClient protocol
 * to warn about its implementation. Here you have to call [MNMBottomPullToRefreshManager tableViewScrolled]
 *
 * Tells the delegate when the user scrolls the content view within the receiver.
 *
 * @param scrollView: The scroll-view object in which the scrolling occurred.
 */

/**
 * This is the same delegate method as UIScrollView but required in MNMBottomPullToRefreshClient protocol
 * to warn about its implementation. Here you have to call [MNMBottomPullToRefreshManager tableViewReleased]
 *
 * Tells the delegate when dragging ended in the scroll view.
 *
 * @param scrollView: The scroll-view object that finished scrolling the content view.
 * @param decelerate: YES if the scrolling movement will continue, but decelerate, after a touch-up gesture during a dragging operation.
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  
  if(scrollView == self.tableView)
    [pullToRefreshManagerPost tableViewReleased];
  else if(scrollView == self.tblViewComments)
    [pullToRefreshManagerComment tableViewReleased];
}

/**
 * Tells client that refresh has been triggered
 * After reloading is completed must call [MNMBottomPullToRefreshManager tableViewReloadFinished]
 *
 * @param manager PTR manager
 */
- (void)bottomPullToRefreshTriggered:(MNMBottomPullToRefreshManager *)manager {
  
  [self performSelector:@selector(loadTable) withObject:nil afterDelay:1.0f];
}

- (void)viewDidLayoutSubviews {
  
  [super viewDidLayoutSubviews];
  [pullToRefreshManagerPost relocatePullToRefreshView];
  [pullToRefreshManagerComment relocatePullToRefreshView];
}


- (void)loadTable
{
  
  if(tempTableView == self.tableView)
  {
    NSIndexPath *indexPath = [[self.tableView indexPathsForVisibleRows]lastObject];
    
    if([arrayPostList count] > indexPath.row)
    {
      isNewDataArrive = FALSE;
      [self callAPIPostBlogList];
    }
    else
    {
      [pullToRefreshManagerPost tableViewReloadFinished];
      [pullToRefreshManagerComment tableViewReloadFinished];
    }
  }
  else if(tempTableView == self.tblViewComments)
  {
    
    NSIndexPath *indexPath = [[self.tableView indexPathsForVisibleRows]lastObject];
    
    if([arrayCommentsList count] > indexPath.row)
    {
      isNewDataArriveForComment = FALSE;
      [self callAPIGetComments:selectedIndex Loading:NO];
    }
    else
    {
      [pullToRefreshManagerPost tableViewReloadFinished];
      [pullToRefreshManagerComment tableViewReloadFinished];
    }
  }
}

#pragma mark - My Functions

- (void)inisialiseView
{
  [_lblNavBar setFont:FONT_REGULAR(kNavigationFontSize)];
  //[_lblName setFont:FONT_REGULAR(16)];
  //[_lblUniversity setFont:FONT_REGULAR(15)];
  
  // set Back Swipe
  
  UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backSwipeAction)];
  [backSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
  [self.view addGestureRecognizer:backSwipe];
  
  // set the Tap Guesture on Profile Image
  
  UITapGestureRecognizer *tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(tapOnce:)];
  tapOnce.numberOfTapsRequired = 1;
  [self.scrollViewImages addGestureRecognizer:tapOnce];
  
  // set Swipe event Rigth
  
  UISwipeGestureRecognizer *gestureRightSwipeImages = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeImagesRight:)];
  [gestureRightSwipeImages setDirection:UISwipeGestureRecognizerDirectionRight];
  [_viewFullImage addGestureRecognizer:gestureRightSwipeImages];
  
  // set Swipe event Left
  
  UISwipeGestureRecognizer *gestureLeftSwipeImages = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeImagesLeft:)];
  [gestureLeftSwipeImages setDirection:UISwipeGestureRecognizerDirectionLeft];
  [_viewFullImage addGestureRecognizer:gestureLeftSwipeImages];
  
}

-(void)setViewMovedUp:(BOOL)movedUp
{
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:0.3]; // if you want to slide up the view
  
  CGRect rect = self.view.frame;
  if (movedUp)
  {
    // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
    // 2. increase the size of the view so that the area behind the keyboard is covered up.
    rect.origin.y -= 100;
    rect.size.height += 100;
  }
  else
  {
    // revert back to the normal state.
    rect.origin.y += 100;
    rect.size.height -= 100;
  }
  self.view.frame = rect;
  
  [UIView commitAnimations];
}

- (void)setUserDataWithDictionary:(NSDictionary*)dict
{
    
  NSMutableAttributedString *strName = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@, %@",[dict objectForKeyNonNull:kBuddyName],[dict objectForKeyNonNull:@"buddyAge"]]];
  
  [strName addAttribute:NSFontAttributeName value:FONT_BOLD(17) range:[[NSString stringWithFormat:@"%@, %@",[dict objectForKeyNonNull:kBuddyName],[dict objectForKeyNonNull:@"buddyAge"]] rangeOfString:[dict objectForKeyNonNull:kBuddyName] ]];
  
  [strName addAttribute:NSFontAttributeName value:FONT_LIGHT(15) range:[[NSString stringWithFormat:@"%@, %@",[dict objectForKeyNonNull:kBuddyName],[dict objectForKeyNonNull:@"buddyAge"]] rangeOfString:[dict objectForKeyNonNull:@"buddyAge"] ]];
  
    [[strName mutableString] replaceOccurrencesOfString:@"Yrs old" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, strName.string.length)];
  [_lblName setAttributedText:strName];
  [_lblName setTextColor:[UIColor whiteColor]];
  _lblUniversity.text = [dict objectForKeyNonNull:kUniversity];
  

    [_majorLabel setText:[dict objectForKey:@"major"]];
    [_majorLabel setTextColor:[UIColor whiteColor]];
    [_majorLabel setFont:FONT_LIGHT(17)];
    [_buddyLabel setText:[dict objectForKeyNonNull:@"buddycount"]];
    if ([[dict objectForKeyNonNull:@"buddycount"] intValue]<=1)
    {
        _lblBuddies.text=@"Buddy";
    }
    else
    {
        _lblBuddies.text=@"Buddies";
    }
  // set Image Dictionary to ScrollView
  
//Now for  PAgedImageScrollView // Sourabh here to make small image callback
     //completion:(void (^)(void))completionBlock
  [self makeImagesScrollViewWithArray:[dict objectForKeyNonNull:kProfilePicture]];
  
  if ([[dict objectForKeyNonNull:kIsBuddy] intValue] == kStatusFriend || [[defaults objectForKey:kUserId] isEqualToString:_buddyId])
  {
    [_btnSendInvite setHidden:YES];
    [_btnSendInvite.titleLabel setFont:FONT_REGULAR(12)];
  }
  else if ([[dict objectForKeyNonNull:kIsBuddy] intValue] == KStatusFriendRequestPending)
  {
    [_btnSendInvite setTitle:@"Respond" forState:UIControlStateNormal];
    [_btnSendInvite.titleLabel setFont:FONT_REGULAR(12)];
  }
  else if ([[dict objectForKeyNonNull:kIsBuddy] intValue] == kStatusMyRequestPending)
  {
    [_btnSendInvite setTitle:@"Pending" forState:UIControlStateNormal];
    [_btnSendInvite.titleLabel setFont:FONT_REGULAR(12)];
    [_btnSendInvite setUserInteractionEnabled:NO];
  }
  else if ([[dict objectForKeyNonNull:kIsBuddy] intValue] == kStatusNotFriend)
  {
    [_btnSendInvite setTitle:@"Send Invite" forState:UIControlStateNormal];
    [_btnSendInvite.titleLabel setFont:FONT_REGULAR(12)];
    [_btnSendInvite setUserInteractionEnabled:YES];
  }
    
    [_lineLabel1 setHidden:NO];
    [_lineLabel2 setHidden:NO];
  
}

- (void)makeImagesScrollViewWithArray:(NSArray*)arrImages
{
    UIView *view = [_viewProfile viewWithTag:111];
    pageScrollView = [[PagedImageScrollView alloc] initWithFrame:view.frame];
    pageScrollView.scrollView.delegate=self;
    pageScrollView.pageControl.currentPageIndicatorTintColor=[UIColor whiteColor];
    pageScrollView.pageControl.pageIndicatorTintColor=kBlueColor;
    NSMutableArray *localArr = [NSMutableArray array];
    // Now for PagedImageScrollview
    for (int i = 0;  i< arrImages.count; i++)
    {
        UIImageView *imgViewProfile = [[UIImageView alloc] init ];
        [imgViewProfile sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImageURl,[[arrImages objectAtIndex:i] objectForKeyNonNull:kImage]]]];
        [localArr addObject:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImageURl,[[arrImages objectAtIndex:i] objectForKeyNonNull:kImage]]]];
    }
    
    [pageScrollView setScrollViewContents:localArr];
    
     //easily setting pagecontrol pos, see PageControlPosition defination in PagedImageScrollView.h
    pageScrollView.pageControlPos = PageControlPositionCenterBottom;
    [self.viewProfile addSubview:pageScrollView];

    UIView *backView = [[UIView alloc] initWithFrame:pageScrollView.frame];
    [backView setBackgroundColor:[UIColor blackColor]];
    backView.alpha = 0.6;
    [pageScrollView addSubview:backView];
    
    [self.viewProfile addSubview:_btnEditProfile];
    [self.viewProfile addSubview:_btnSendInvite];
    [self.viewProfile addSubview:_scrollViewImages];
    [self.viewProfile bringSubviewToFront:_scrollViewImages];
    [self.viewProfile addSubview:_lblName];
    [self.viewProfile bringSubviewToFront:_lblName];
    [self.viewProfile addSubview:_lblUniversity];
    [self.viewProfile bringSubviewToFront:_lblUniversity];

    [self addSmallImageview:arrImages];

}

-(void)addSmallImageview:(NSArray *)arrImg
{
        NSInteger isActiveIndex = 0;
      for (int i = 0;  i< arrImg.count; i++)
      {
        UIImageView *imgViewProfile = [[UIImageView alloc] initWithFrame:CGRectMake(i*_scrollViewImages.frame.size.width, 0, _scrollViewImages.frame.size.width, _scrollViewImages.frame.size.height)];
        [imgViewProfile setContentMode:UIViewContentModeScaleAspectFill];
        [imgViewProfile setClipsToBounds:YES];
    
        [imgViewProfile sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImageURl,[[arrImg objectAtIndex:i] objectForKeyNonNull:kImage]]]];
        //        [imgViewProfile.layer setBorderWidth:2];
        //        [imgViewProfile.layer setBorderColor:(__bridge CGColorRef)([UIColor whiteColor])];
        [imgViewProfile.layer setCornerRadius:5];
        [_scrollViewImages addSubview:imgViewProfile];
        [_scrollViewImages.layer setBorderWidth:2];
        [_scrollViewImages.layer setBorderColor:[UIColor whiteColor].CGColor];
        if ([[[arrImg objectAtIndex:i] objectForKeyNonNull:@"isActive"] boolValue] == YES)
        {
          isActiveIndex = i;
          if ([_buddyId isEqualToString:[defaults objectForKey:kUserId]])
          {
            [defaults setObject:[[arrImg objectAtIndex:i] objectForKeyNonNull:kImage] forKey:kProfilePicture];
            [defaults synchronize];
          }
    
        }
      }
    
      [_scrollViewImages setContentSize:CGSizeMake(_scrollViewImages.frame.size.width*arrImg.count, _scrollViewImages.frame.size.height)];
      [_scrollViewImages.layer setCornerRadius:_scrollViewImages.frame.size.width/2];
      [_scrollViewImages setClipsToBounds:YES];
      [_scrollViewImages setPagingEnabled:YES];
      [_scrollViewImages setContentOffset:CGPointMake(isActiveIndex*_scrollViewImages.frame.size.width, 0)];
    
      //[self setCoverImage];
       // [_imgBlurImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImageURl,[[arrImages objectAtIndex:0] objectForKeyNonNull:kImage]]]];
}
- (void)setCoverImage
{
  for (UIImageView *imgView in _scrollViewImages.subviews)
  {
    if (imgView.frame.origin.x == _scrollViewImages.contentOffset.x)
    {
        //self.imgProfile1.image = imgView.image;
      [_imgProfile1 setImage:imgView.image];
        [_imgBlurImage setImage:imgView.image];
      //[self blurImage:imgView.image];
      
    }
  }
  
}

- (NSString*)setDate:(NSString*)datePost
{
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
  [dateFormatter setDateFormat:@"MM/dd/yyyy"];
  NSDate *date = [dateFormatter dateFromString:datePost];
  [dateFormatter setDateFormat:@"MMM dd"];
  NSLog(@"date:%@",[dateFormatter stringFromDate:date]);
  return [dateFormatter stringFromDate:date];
}

- (void)backSwipeAction
{
    [self.tabBarController.tabBar setHidden:YES];
  [self.navigationController popViewControllerAnimated:YES];
}


- (void)blurImage:(UIImage*)img
{
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:img.CGImage];
    
    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    if (inputImage != nil)
        [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:6.0] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = nil;
    @try
    {
        if (result != nil && inputImage!= nil && context!= nil)
        {
            cgImage  = [context createCGImage:result fromRect:[inputImage extent]];
            
        }else
            cgImage = nil;
        
    }
    @catch (NSException *exception) {
        cgImage = nil;
    }
    @finally {
        
    }
    
    UIImage *imgRef = nil;
    if (cgImage != nil)
    {
        imgRef = [[UIImage alloc]initWithCGImage:cgImage];
        self.imgProfile1.image = imgRef;
        CGImageRelease(cgImage);
        
        
    }
    else
    {
        self.imgProfile1.image = imgRef;
    }
}

#pragma mark - Scrollview Delegate Method

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
  NSLog(@"cal");
  [self setCoverImage];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   
    
        
    tempTableView = (UITableView*)scrollView;
    if(scrollView == self.tableView)
            [pullToRefreshManagerPost tableViewScrolled];
    else if(scrollView == self.tblViewComments)
            [pullToRefreshManagerComment tableViewScrolled];
    else
    {
        CGFloat pageWidth = scrollView.frame.size.width;
        //switch page at 50% across
        int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        pageScrollView.pageControl.currentPage = page;
        
    }
    

    
   
}
// buddies clickable button

- (IBAction)buddiesNumberClicked:(id)sender
{
//    if([sender tag] == 667)
//    {
//        [_tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
//        
//        
//    }
//    else
//    {
//        [self.tabBarController setSelectedIndex:1];
//        [Utils setTabBarImage:@"tab_bar_two.png"];
//    }

}

@end
