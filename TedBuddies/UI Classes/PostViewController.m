//
//  PostViewController.m
//  TedBuddies
//
//  Created by Mayank Pahuja on 27/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import "PostViewController.h"
#import "PreferenceSettingViewController.h"
#import "CreatePostViewController.h"
#import "AppDelegate.h"
#import "MHFacebookImageViewer.h"
#import "UIImageView+MHFacebookImageViewer.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SWRevealViewController.h"
#import "ViewProfileViewController.h"
#import "UITabBarController+HideTabBar.h"
#import "HMSegmentedControl.h"
#import "KILabel.h"


@interface PostViewController ()
{
    SWRevealViewController *revealController;
    UIImageView *overlay ;
    NSInteger selectedSegment;
    HMSegmentedControl *segmentedControl;
}

@end

@implementation PostViewController

#pragma mark View Life Cycle Method/Users/sunidhi/Desktop/iPhoneProject/CompanyProject/TedBuddy/ios/TedBuddies/TedBuddies.xcodeproj

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
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [SharedAppDelegate callAPIPendingRequests];
    [SharedAppDelegate callAPIRecentChats];
    
    revealController = [self revealViewController];
    arrayPostList = [[NSMutableArray alloc]init];
    arrayFilteredPostList = [[NSMutableArray alloc]init];
    arrayCommentsList = [[NSMutableArray alloc]init];
    
    _searchBar.delegate=self;
    
    _tblViewComments.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
    
    
//    self.btnNewYapper.layer.borderWidth = 2.0f;
//    self.btnNewYapper.layer.borderColor = [[UIColor blackColor] CGColor];
//    self.btnHotYapper.layer.borderWidth = 2.0f;
//    self.btnHotYapper.layer.borderColor = [[UIColor blackColor] CGColor];
//    self.btnClassYapper.layer.borderWidth = 2.0f;
//    self.btnClassYapper.layer.borderColor = [[UIColor blackColor] CGColor];
//    
//    self.imgSearchTextbox.layer.borderWidth = 2.0f;
//    self.imgSearchTextbox.layer.borderColor = [[UIColor blackColor] CGColor];
//    
    
    self.webParamBlog = @"";
    self.txtFieldSearch.text = @"";
    self.searchText = @"";
    
    segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Yappers", @"Class Yappers"]];
    segmentedControl.frame = CGRectMake(0, 0, self.viewSegment.frame.size.width-5, self.viewSegment.frame.size.height);
    segmentedControl.selectionIndicatorHeight = 3.0f;
    segmentedControl.backgroundColor = [UIColor clearColor];
    segmentedControl.selectedTitleTextAttributes =@{NSForegroundColorAttributeName : [self getColor]};
    segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 0, 0, 0);
    segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    segmentedControl.selectionIndicatorColor= [self getColor];
    [segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.viewSegment addSubview:segmentedControl];
    
    

    
    pullToRefreshManagerPost = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:self.tableView withClient:self];
    pullToRefreshManagerComment = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:50.0f tableView:self.tblViewComments withClient:self];
    
   if (![defaults boolForKey:kMarketPlaceTutorial])
    {
        overlay =[[UIImageView alloc]initWithFrame:SharedAppDelegate.window.rootViewController.view.bounds];
        overlay.backgroundColor =  [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        [overlay setUserInteractionEnabled:YES];
        [SharedAppDelegate.window.rootViewController.view addSubview:overlay];
        [overlay setImage:[UIImage imageNamed:@"tutorialMarketPlace.png"]];
        
    
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)];
        tapGesture.numberOfTapsRequired = 1;
        [overlay addGestureRecognizer:tapGesture];
    }
    
    pageNumber = 0;
    isNewDataArrive = TRUE;
    [arrayPostList removeAllObjects];
    [arrayFilteredPostList removeAllObjects];
    [arrayCommentsList removeAllObjects];
    [self callAPIGetAllPostBlogListingWithSearchText:self.searchText Loading:YES];

}
- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl1
{
    
    selectedSegment=segmentedControl1.selectedSegmentIndex;
    
    if (selectedSegment==0)
    {
        
        [tempTxtField resignFirstResponder];
        [self.btnNewYapper setTitleColor:[self getColor] forState:UIControlStateNormal];
        [self.btnHotYapper setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.btnClassYapper setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
        //    [self.btnNewYapper setSelected:YES];
        //    [self.btnHotYapper setSelected:NO];
        //    [self.btnClassYapper setSelected:NO];
        
        [_searchBar resignFirstResponder];
        _searchBar.text = @"";
        [_searchBar setShowsCancelButton:NO animated:NO];
        
        
        self.txtFieldSearch.text = @"";
        self.searchText = @"";
        pageNumber = 0;
        isNewDataArrive = TRUE;
        self.webParamBlog = @"";
        [self callAPIGetAllPostBlogListingWithSearchText:self.searchText Loading:YES];
        
    }
//    else if (selectedSegment==1)
//    {
//        [tempTxtField resignFirstResponder];
//        [self.btnNewYapper setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//        [self.btnHotYapper setTitleColor:[self getColor] forState:UIControlStateNormal];
//        [self.btnClassYapper setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//        //    [self.btnNewYapper setSelected:NO];
//        //    [self.btnHotYapper setSelected:YES];
//        //    [self.btnClassYapper setSelected:NO];
//        
//        [_searchBar resignFirstResponder];
//        _searchBar.text = @"";
//        [_searchBar setShowsCancelButton:NO animated:NO];
//        
//        self.txtFieldSearch.text = @"";
//        self.searchText = @"";
//        pageNumber = 0;
//        isNewDataArrive = TRUE;
//        self.webParamBlog = @"False";
//        [self callAPIGetAllPostBlogListingWithSearchText:self.searchText Loading:YES];
//
//        
//    }
    else if (selectedSegment==1)
    {
       
        [tempTxtField resignFirstResponder];
        [self.btnNewYapper setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.btnHotYapper setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [self.btnClassYapper setTitleColor:[self getColor] forState:UIControlStateNormal];
        //    [self.btnNewYapper setSelected:NO];
        //    [self.btnHotYapper setSelected:NO];
        //    [self.btnClassYapper setSelected:YES];
        
        [_searchBar resignFirstResponder];
        _searchBar.text = @"";
        [_searchBar setShowsCancelButton:NO animated:NO];
        
        self.txtFieldSearch.text = @"";
        self.searchText = @"";
        pageNumber = 0;
        isNewDataArrive = TRUE;
        self.webParamBlog = @"True";
        [self callAPIGetAllPostBlogListingWithSearchText:self.searchText Loading:YES];

    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 [self.tabBarController setTabBarHidden:NO animated:NO];
    [self.tabBarController.tabBar setHidden:NO];
    
    if (SharedAppDelegate.isCreateYap)
    {
        selectedSegment=0;
        segmentedControl.selectedSegmentIndex=0;
        self.txtFieldSearch.text = @"";
        self.searchText = @"";
        pageNumber = 0;
        isNewDataArrive = TRUE;
        self.webParamBlog = @"";
        [self callAPIGetAllPostBlogListingWithSearchText:self.searchText Loading:YES];

        SharedAppDelegate.isCreateYap=false;
    }
    
    

}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
   
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
        self.txtFieldSearch.text = @"";
        self.searchText = @"";
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

   // [self.tabBarController.tabBar setHidden:NO];
    [self inisialiseView];
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - gesture recognizer delegates
- (void)tapView
{
   
    [defaults setBool:true forKey:kMarketPlaceTutorial];
    overlay.alpha=0;
    
    if (![defaults boolForKey:kYapTutorial])
    {
        overlay.alpha=1;
        [overlay setImage:[UIImage imageNamed:@"tutorialYap.png"]];
        
    }
    [defaults setBool:true forKey:kYapTutorial];
}

#pragma mark -
-(void)reloadTableViewData
{
    [self.tableView reloadData];
    [pullToRefreshManagerPost tableViewReloadFinished];
}

#pragma mark - IBAction Method

- (IBAction)backButtonClick:(UIButton *)sender
{
    //[self.tabBarController setSelectedIndex:2];
    ViewProfileViewController * viewProfile = [[ViewProfileViewController alloc]initWithNibName:@"ViewProfileViewController" bundle:nil];
    viewProfile.inviteButtonHidden = YES;
    viewProfile.editProfile = NO;
    [self.tabBarController.tabBar setHidden:YES];
    [viewProfile setHidesBottomBarWhenPushed:NO];
    [viewProfile setBuddyId:[defaults objectForKey:kUserId]];
    [self.navigationController pushViewController:viewProfile animated:YES];

}

- (IBAction)addButtonClick:(id)sender
{
    [tempTxtField resignFirstResponder];
    CreatePostViewController * createPostView = [[CreatePostViewController alloc] initWithNibName:@"CreatePostViewController" bundle:nil];
    [self.navigationController pushViewController:createPostView animated:YES];
    
}

- (IBAction)settingButtonClick:(id)sender
{
    [tempTxtField resignFirstResponder];
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

- (IBAction)newYapperButtonClick:(UIButton *)sender
{
    [tempTxtField resignFirstResponder];
    [self.btnNewYapper setTitleColor:[self getColor] forState:UIControlStateNormal];
    [self.btnHotYapper setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.btnClassYapper setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];

//    [self.btnNewYapper setSelected:YES];
//    [self.btnHotYapper setSelected:NO];
//    [self.btnClassYapper setSelected:NO];
    
    [_searchBar resignFirstResponder];
    _searchBar.text = @"";
    [_searchBar setShowsCancelButton:NO animated:NO];
   

    self.txtFieldSearch.text = @"";
    self.searchText = @"";
    pageNumber = 0;
    isNewDataArrive = TRUE;
    self.webParamBlog = @"";
    [self callAPIGetAllPostBlogListingWithSearchText:self.searchText Loading:YES];
}

- (IBAction)hotYapperButtonClick:(UIButton *)sender
{
    [tempTxtField resignFirstResponder];
    [self.btnNewYapper setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.btnHotYapper setTitleColor:[self getColor] forState:UIControlStateNormal];
    [self.btnClassYapper setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//    [self.btnNewYapper setSelected:NO];
//    [self.btnHotYapper setSelected:YES];
//    [self.btnClassYapper setSelected:NO];
    
    [_searchBar resignFirstResponder];
    _searchBar.text = @"";
    [_searchBar setShowsCancelButton:NO animated:NO];
    
    self.txtFieldSearch.text = @"";
    self.searchText = @"";
    pageNumber = 0;
    isNewDataArrive = TRUE;
    self.webParamBlog = @"False";
    [self callAPIGetAllPostBlogListingWithSearchText:self.searchText Loading:YES];
}

- (IBAction)classYapperButtonClick:(UIButton *)sender
{
    [tempTxtField resignFirstResponder];
    [self.btnNewYapper setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.btnHotYapper setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.btnClassYapper setTitleColor:[self getColor] forState:UIControlStateNormal];
//    [self.btnNewYapper setSelected:NO];
//    [self.btnHotYapper setSelected:NO];
//    [self.btnClassYapper setSelected:YES];
    
    [_searchBar resignFirstResponder];
    _searchBar.text = @"";
    [_searchBar setShowsCancelButton:NO animated:NO];
    
    self.txtFieldSearch.text = @"";
    self.searchText = @"";
    pageNumber = 0;
    isNewDataArrive = TRUE;
    self.webParamBlog = @"True";
    [self callAPIGetAllPostBlogListingWithSearchText:self.searchText Loading:YES];
}

- (IBAction)searchButtonClick:(UIButton *)sender
{
    [tempTxtField resignFirstResponder];
    pageNumber = 0;
    isNewDataArrive = TRUE;
    self.searchText = self.txtFieldSearch.text;
    [self callAPIGetAllPostBlogListingWithSearchText:self.searchText Loading:YES];
}

- (IBAction)closeDescriptionButtonClick:(UIButton *)sender
{
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

- (IBAction)closeFullImageButtonClick:(UIButton *)sender
{
    [tempTxtField resignFirstResponder];
    [self.viewFullImage removeFromSuperview];
}

- (IBAction)closeEditCommentButtonClick:(UIButton *)sender
{
    [tempTxtField resignFirstResponder];
    [self.viewEditComment removeFromSuperview];
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

- (IBAction)btnSearchTapped:(id)sender
{
    _searchBar.alpha=1.0f;
    [_searchBar becomeFirstResponder];
    
    [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, 145, _tableView.frame.size.width, _tableView.frame.size.height-_searchBar.frame.size.height)];
    
    [_viewTable setFrame:CGRectMake(_viewTable.frame.origin.x, 145, _viewTable.frame.size.width, _viewTable.frame.size.height-_searchBar.frame.size.height)];
}

- (IBAction)closeCommentsButtonClick:(UIButton *)sender
{
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
                             
                             NSMutableDictionary *tempDic = [[arrayFilteredPostList objectAtIndex:selectedIndex] mutableCopy];
                             [tempDic setObject:[NSString stringWithFormat:@"%lu",(unsigned long)[arrayCommentsList count]] forKey:@"commentCount"];
                             [arrayFilteredPostList replaceObjectAtIndex:selectedIndex withObject:tempDic];
                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                 [self reloadTableViewData];
                             });
                         }
                     }];
    
}

- (void)commentButtonClick:(UIButton *)btn
{
    [tempTxtField resignFirstResponder];
    self.viewComments.frame = CGRectMake(0, 568, self.viewComments.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:self.viewComments];
    self.viewToChangeInCOmments.layer.cornerRadius = 5.0f;
    
    
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


#pragma mark - UITableView Delegate/DataSource Method

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

//    
//    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    NSDictionary *tempDict = arrayFilteredPostList[indexPath.row];
//    STTweetLabel *lblDescription=(STTweetLabel *)[cell.contentView viewWithTag:15];
//    lblDescription.text = [tempDict objectForKeyNonNull:@"postDesc"];
    if(tableView == self.tableView)
    {
        return [self calculateHeightForPostRow:indexPath];

    }
    else
    {
        return 61;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView == self.tableView)
        return [arrayFilteredPostList count];
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
        
    
    NSDictionary *tempDict = arrayFilteredPostList[indexPath.row];
    
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
        else if([[[arrayFilteredPostList objectAtIndex:selectedIndex] objectForKeyNonNull:@"createdById"] isEqualToString:[defaults objectForKey:kUserId]])
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
    //textField.autocorrectionType = UITextAutocorrectionTypeYes;
    tempTxtField = textField;
    if(textField != self.txtFieldSearch)
        [self setViewMovedUp:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField              // called when 'return' key pressed.
{
    [tempTxtField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField != self.txtFieldSearch)
        [self setViewMovedUp:NO];
}

#pragma mark Button Action Method

- (void)moreButtonClick:(UIButton *)btn
{
    [tempTxtField resignFirstResponder];
    self.descriptionToChangeView.layer.cornerRadius = 5.0f;
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
                             NSLog(@"Done!");
                             NSDictionary *tempDic = [arrayFilteredPostList objectAtIndex:btn.tag-10 ];
                             UITextView *txtViewDescription = ((UITextView *)[self.viewDescription viewWithTag:10]);
                             txtViewDescription.text = [tempDic objectForKeyNonNull:@"postDesc"];
                             CGSize  currentSize = [[tempDic objectForKey:@"postDesc"] sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:CGSizeMake(self.view.frame.size.width-60, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
                             float height = currentSize.height+20.0;
                             if(height > self.view.frame.size.height-165-70)
                                 height = self.view.frame.size.height-165-70;
                             txtViewDescription.frame =CGRectMake(txtViewDescription.frame.origin.x, txtViewDescription.frame.origin.y, txtViewDescription.frame.size.width,height);
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
    _searchBar.alpha=1.0f;
    
    [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, 145, _tableView.frame.size.width, _tableView.frame.size.height-_searchBar.frame.size.height)];
    
    [_viewTable setFrame:CGRectMake(_viewTable.frame.origin.x, 145, _viewTable.frame.size.width, _viewTable.frame.size.height-_searchBar.frame.size.height)];
     [_searchBar setShowsCancelButton:NO animated:NO];
     [tempTableView resignFirstResponder];
    [_searchBar resignFirstResponder];
   
    _searchBar.text = str;
    self.searchText = str;
    pageNumber = 0;
    isNewDataArrive = TRUE;
    [arrayPostList removeAllObjects];
    [arrayFilteredPostList removeAllObjects];
    _isSearchButtonCkick=YES;
    [self callAPIGetAllPostBlogListingWithSearchText:self.searchText Loading:YES];
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
 
    
    if ([[[arrayFilteredPostList objectAtIndex:indexPath.row] objectForKey:kCreatedById] isEqualToString:[defaults objectForKey:kUserId]])
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
   
    NSDictionary *tempDict = [arrayFilteredPostList objectAtIndex:indexPath.row];
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

    NSDictionary *tempDict = [arrayFilteredPostList objectAtIndex:indexPath.row];
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
    
    NSDictionary *tempDict = [arrayFilteredPostList objectAtIndex:indexPath.row];
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

#pragma mark - Web Service

- (void)callAPIGetAllPostBlogListingWithSearchText:(NSString*)searchText Loading:(BOOL)isLoading
{
    NSDictionary *dictSend;
    
        dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                    [defaults objectForKey:kUserId],kUserId,
                    [NSString stringWithFormat:@"%d",pageNumber],kPage,
                    self.webParamBlog,@"isBlog",
                    searchText,kSearchText,
                    nil];

          if(isLoading)
        [Utils startLoaderWithMessage:@""];
    
    [Connection callServiceWithName:kGetAllPostBlogListing postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         
         [Utils stopLoader];
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 pageNumber++;
                 if(isNewDataArrive)
                 {
                     [arrayFilteredPostList removeAllObjects];
                     [arrayFilteredPostList addObjectsFromArray:[response objectForKeyNonNull:kResult]];
                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                         [self reloadTableViewData];
                         //self.tableView.contentOffset = CGPointMake(0, 0);
                        
                     });
                     
                 }
                 else
                 {
                     [arrayFilteredPostList addObjectsFromArray:[[response objectForKey:kResult] mutableCopy]];
                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                         [self reloadTableViewData];
                     });
                 }
             }
             if(self.searchText.length == 0)
             {
             if([arrayFilteredPostList count] == 0)
             {
                 
                 [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"Use \"+\" to post new yap" leftButtonTitle:@"Yes" rightButtonTitle:@"No" selectedButton:^(NSInteger selected, UIAlertView *aView)
                  {
                      if(selected == 0)
                      {
                          CreatePostViewController *createPostAndBlogViewController = [[CreatePostViewController alloc] initWithNibName:@"CreatePostViewController" bundle:nil];
                          [self.navigationController pushViewController:createPostAndBlogViewController animated:YES];
                      }
                      if(selected == 1)
                      {
                      }
                  }];
             }
             }
        }
        [pullToRefreshManagerPost tableViewReloadFinished];
        [pullToRefreshManagerComment tableViewReloadFinished];
    }];
}

- (void)callAPIGetComments:(int)index Loading:(BOOL)isLoading
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
                              [NSString stringWithFormat:@"%d",pageNumberForComments],kPage,
                              [[arrayFilteredPostList objectAtIndex:index ] objectForKeyNonNull:@"postId"],@"postId",
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
                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                         [self.tblViewComments reloadData];
                     });
                 }
                 else
                 {
                     [arrayCommentsList addObjectsFromArray:[[response objectForKey:kResult] mutableCopy]];
                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                         [self.tblViewComments reloadData];
                     });
                 }
             }
         }
         [pullToRefreshManagerPost tableViewReloadFinished];
         [pullToRefreshManagerComment tableViewReloadFinished];
     }];
}

- (void)callAPISetLikeOrDislike:(NSString*)isLike Index:(int)index Superview:(UIView *)view
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
                              [[arrayFilteredPostList objectAtIndex:index ] objectForKeyNonNull:@"postId"],@"postId",
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

                 NSMutableDictionary *tempDic = [[arrayFilteredPostList objectAtIndex:index] mutableCopy];
                 [tempDic setObject:[[response objectForKeyNonNull:kResult] objectForKeyNonNull:@"likeCount"] forKey:@"likeCount"];
                 [tempDic setObject:[[response objectForKeyNonNull:kResult] objectForKeyNonNull:@"unLikeCount"] forKey:@"unLikeCount"];
                 [tempDic setObject:[[response objectForKeyNonNull:kResult] objectForKeyNonNull:@"isLike"] forKey:@"isLike"];
                 [arrayFilteredPostList replaceObjectAtIndex:index withObject:tempDic];
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                     [self reloadTableViewData];
                 });
             }
         }
     }];
}


- (void)callAPIAddComment:(int)index
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
                              @"",@"commentId",
                              [[arrayFilteredPostList objectAtIndex:index ] objectForKeyNonNull:@"postId"],@"postId",self.txtFieldComments.text,@"commentText",
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
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                     [self.tblViewComments reloadData];
                 });
                 if (arrayCommentsList.count>3)
                 {
                      [self.tblViewComments scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:arrayCommentsList.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                 }
                
                 [pullToRefreshManagerPost tableViewReloadFinished];
                 [pullToRefreshManagerComment tableViewReloadFinished];
             }
         }
     }];
}

- (void)callAPIEditComment:(int)index CommentId:(NSString *)commentId
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,commentId
                              ,@"commentId",
                              [[arrayFilteredPostList objectAtIndex:index ] objectForKeyNonNull:@"postId"],@"postId",self.txtFieldEditComment.text,@"commentText",
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

- (void)callAPIDeleteComment:(int)index
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
                              [[arrayCommentsList objectAtIndex:index] objectForKeyNonNull:@"commentId"],@"commentId",
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
                              [[arrayFilteredPostList objectAtIndex:index1] objectForKeyNonNull:@"postId"],@"postId",
                              nil];
    
    [Utils startLoaderWithMessage:@""];
    
    [Connection callServiceWithName:kReportAbuse postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         
         [Utils stopLoader];
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue])
             {
                 [arrayFilteredPostList removeObjectAtIndex:index1];
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                     [self reloadTableViewData];
                 });
             }
         }
     }];
}

- (void)callAPIDeleteBlog:(int)index1
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [[arrayFilteredPostList objectAtIndex:index1] objectForKeyNonNull:@"postId"],@"id",
                              nil];
    
    [Utils startLoaderWithMessage:@""];
    
    [Connection callServiceWithName:kDeletePost postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         
         [Utils stopLoader];
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue])
             {
                 [arrayFilteredPostList removeObjectAtIndex:index1];
                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                     [self reloadTableViewData];
                 });
             }
         }
     }];
}

#pragma mark Calculate Height For Tableview Row Method

- (float) calculateHeightForCommentRow:(NSIndexPath*)index
{
    float y = 24;
    CGSize  currentSize = [[[arrayCommentsList objectAtIndex:index.row] objectForKey:@"postComment"] sizeWithFont:[UIFont systemFontOfSize:10.0] constrainedToSize:CGSizeMake(220, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    y = y + currentSize.height+50;
    return y+20;
}

- (float) calculateHeightForPostRow:(NSIndexPath*)index
{
     NSDictionary *tempDict = arrayFilteredPostList[index.row];
    
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
    
    if([[[arrayFilteredPostList objectAtIndex:index.row] objectForKeyNonNull:@"postImage"] length] && [[arrayFilteredPostList objectAtIndex:index.row] objectForKeyNonNull:@"postDesc"])
        return 247+descHeight;
    
     else if([[[arrayFilteredPostList objectAtIndex:index.row] objectForKeyNonNull:@"postImage"] length] && ![[arrayFilteredPostList objectAtIndex:index.row] objectForKeyNonNull:@"postDesc"])
         return 237;
    
    else if([[[arrayFilteredPostList objectAtIndex:index.row] objectForKeyNonNull:@"postDesc"] length] && ![[[arrayFilteredPostList objectAtIndex:index.row] objectForKeyNonNull:@"className"] length])
        return 93+descHeight;
    else if([[[arrayFilteredPostList objectAtIndex:index.row] objectForKeyNonNull:@"postDesc"] length] && [[[arrayFilteredPostList objectAtIndex:index.row] objectForKeyNonNull:@"className"] length])
        return 113+descHeight;
    else if (![[[arrayFilteredPostList objectAtIndex:index.row] objectForKeyNonNull:@"postDesc"] length] && [[[arrayFilteredPostList objectAtIndex:index.row] objectForKeyNonNull:@"className"] length])
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
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    tempTableView = (UITableView*)scrollView;
    if(scrollView == self.tableView)
        [pullToRefreshManagerPost tableViewScrolled];
    else if(scrollView == self.tblViewComments)
        [pullToRefreshManagerComment tableViewScrolled];
}

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

        if([arrayFilteredPostList count] > indexPath.row)
        {
            isNewDataArrive = FALSE;
            [self callAPIGetAllPostBlogListingWithSearchText:self.searchText Loading:NO];
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
    if([self.webParamBlog isEqualToString:@""])
    {
        [self.btnNewYapper setTitleColor:[self getColor] forState:UIControlStateNormal];
        //[self.btnNewYapper setSelected:YES];
        //[self.btnHotYapper setSelected:NO];
        //[self.btnClassYapper setSelected:NO];
    }
    else if([self.webParamBlog isEqualToString:@"False"])
    {
//        [self.btnNewYapper setSelected:NO];
//        [self.btnHotYapper setSelected:YES];
//        [self.btnClassYapper setSelected:NO];
    }
    else
    {
//        [self.btnNewYapper setSelected:NO];
//        [self.btnHotYapper setSelected:NO];
//        [self.btnClassYapper setSelected:YES];
    }
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
#pragma  mark - SearchBar Controller Delegate..

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    NSLog(@"Cancel clicked");
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:NO];
    if (_isSearchButtonCkick)
    {
        _isSearchButtonCkick=NO;
        self.searchText=@" ";
        pageNumber = 0;
        isNewDataArrive = TRUE;
        [self callAPIGetAllPostBlogListingWithSearchText:self.searchText Loading:YES];

    }
    _searchBar.alpha=0.0f;
    
    [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, 102, _tableView.frame.size.width, _tableView.frame.size.height+_searchBar.frame.size.height)];
    
    [_viewTable setFrame:CGRectMake(_viewTable.frame.origin.x, 102, _viewTable.frame.size.width, _viewTable.frame.size.height+_searchBar.frame.size.height)];

    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Search Clicked");
    _isSearchButtonCkick=YES;
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:NO];
    pageNumber = 0;
    isNewDataArrive = TRUE;
    self.searchText =searchBar.text;
    [self callAPIGetAllPostBlogListingWithSearchText:self.searchText Loading:YES];

}

@end
