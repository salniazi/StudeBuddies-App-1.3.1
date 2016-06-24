//
//  PostViewController.h
//  TedBuddies
//
//  Created by Mayank Pahuja on 27/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNMBottomPullToRefreshManager.h"

@interface PostViewController : UIViewController <MNMBottomPullToRefreshManagerClient,UIScrollViewDelegate,UIViewControllerTransitioningDelegate, UINavigationControllerDelegate, UITabBarControllerDelegate,UISearchBarDelegate>
{
    NSMutableArray * arrayPostList;
    NSMutableArray *arrayFilteredPostList;
    NSInteger pageNumber;
    BOOL isNewDataArrive;
    MNMBottomPullToRefreshManager *pullToRefreshManagerPost;
    
    NSMutableArray * arrayCommentsList;
    NSInteger pageNumberForComments;
    BOOL isNewDataArriveForComment;
    MNMBottomPullToRefreshManager *pullToRefreshManagerComment;
   
    UITableView *tempTableView;
    
    NSInteger selectedIndex;
    
    NSString *editCommentId;
    
    UITextField *tempTxtField;
    
}

@property (nonatomic , strong) NSString *globalBuddyId;



@property (weak, nonatomic) IBOutlet UIView *viewSegment;
@property (strong, nonatomic) IBOutlet UILabel *lblNavBar;
@property (strong, nonatomic) IBOutlet UIButton *btnNewYapper;
@property (strong, nonatomic) IBOutlet UIButton *btnHotYapper;
@property (strong, nonatomic) IBOutlet UIButton *btnClassYapper;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldSearch;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *descriptionToChangeView;

@property (strong, nonatomic) IBOutlet UIView *viewDescription;

@property (strong, nonatomic) IBOutlet UIView *viewComments;
@property (weak, nonatomic) IBOutlet UIView *viewToChangeInCOmments;

@property (weak, nonatomic) IBOutlet UITableView *tblViewComments;
@property (weak, nonatomic) IBOutlet UIView *viewSendComments;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldComments;

@property (strong, nonatomic) IBOutlet UIView *viewFullImage;

@property (strong, nonatomic) IBOutlet UIView *viewEditComment;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldEditComment;

@property (retain, nonatomic) NSString *webParamBlog;
@property (retain, nonatomic) NSString *searchText;

@property (weak, nonatomic) IBOutlet UIImageView *imgSearchTextbox;

@property (weak, nonatomic) IBOutlet UIView *viewTable;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (assign) bool isSearchButtonCkick;
-(UIColor *)getColor;

- (IBAction)addButtonClick:(id)sender;
- (IBAction)settingButtonClick:(id)sender;
- (IBAction)backButtonClick:(UIButton *)sender;
- (IBAction)newYapperButtonClick:(UIButton *)sender;
- (IBAction)hotYapperButtonClick:(UIButton *)sender;
- (IBAction)classYapperButtonClick:(UIButton *)sender;
- (IBAction)searchButtonClick:(UIButton *)sender;

- (IBAction)closeDescriptionButtonClick:(UIButton *)sender;

- (IBAction)closeCommentsButtonClick:(UIButton *)sender;
- (IBAction)sendCommentButtonClick:(UIButton *)sender;

- (IBAction)closeFullImageButtonClick:(UIButton *)sender;

- (IBAction)closeEditCommentButtonClick:(UIButton *)sender;
- (IBAction)editSendCommentButtonClick:(UIButton *)sender;
- (IBAction)btnSearchTapped:(id)sender;

- (void)postHeadingButtonClick:(NSString *)str;

@end
