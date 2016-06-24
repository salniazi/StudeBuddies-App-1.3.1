//
//  ViewProfileViewController.h
//  TedBuddies
//
//  Created by Sunil on 08/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//https://github.com/mwaterfall/MWPhotoBrowser

#import <UIKit/UIKit.h>
#import "MNMBottomPullToRefreshManager.h"
#import "GAITrackedViewController.h"

//@class ViewProfileViewController;
//@protocol ControllerPoppedDelegate <NSObject>
//
//@optional
//
//-(void)buttonTappedToPop:(NSInteger )senderTag;
//
//@end


@interface ViewProfileViewController : GAITrackedViewController<UIScrollViewDelegate,MNMBottomPullToRefreshManagerClient>
{
    NSMutableArray *arrayPrifleDetails;
    NSMutableArray *arrayPostList;
    NSArray *arrImagesSwipe;
    NSInteger index;
    
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
@property (weak, nonatomic) IBOutlet UIView *moreDecriptionView;

//@property (assign , nonatomic) id <ControllerPoppedDelegate> popDelegate;
@property (weak, nonatomic) IBOutlet UIView *commentsBackView;

@property (weak, nonatomic) IBOutlet UILabel *lblNavBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *viewProfile;

@property (weak, nonatomic) IBOutlet UIImageView *imgBlurImage;
@property (weak, nonatomic) IBOutlet UIImageView *imgProfile1;
@property (strong, nonatomic) IBOutlet UILabel *lblName;
@property (strong, nonatomic) IBOutlet UILabel *lblUniversity;
@property (weak, nonatomic) IBOutlet UIButton *btnSendInvite;
@property (weak, nonatomic) IBOutlet UIButton *btnEditProfile;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewImages;
@property (weak, nonatomic) IBOutlet UILabel *yapsLabel;

@property (weak, nonatomic) IBOutlet UILabel *buddyLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineLabel1;
@property (weak, nonatomic) IBOutlet UILabel *lineLabel2;
@property (weak, nonatomic) IBOutlet UILabel *majorLabel;

@property (weak, nonatomic) IBOutlet UILabel *lblYaps;
@property (weak, nonatomic) IBOutlet UILabel *lblBuddies;

@property (strong, nonatomic) IBOutlet UIView *viewDescription;

@property (strong, nonatomic) IBOutlet UIView *viewComments;
@property (weak, nonatomic) IBOutlet UITableView *tblViewComments;
@property (weak, nonatomic) IBOutlet UIView *viewSendComments;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldComments;

@property (strong, nonatomic) IBOutlet UIView *viewFullImage;

@property (strong, nonatomic) IBOutlet UIView *viewEditComment;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldEditComment;


@property (strong,nonatomic) NSMutableDictionary * dictGetEditProfileDetails;
@property (strong, nonatomic) NSString *buddyId;
@property (nonatomic) BOOL inviteButtonHidden;
@property (nonatomic) BOOL editProfile;
@property (nonatomic) BOOL isPendingRequest;
@property (nonatomic) BOOL isViewProfile;

- (IBAction)btnBackTapped:(id)sender;
- (IBAction)btnSendInviteTapped:(id)sender;
- (IBAction)btnEditProfileTapped:(id)sender;

- (IBAction)closeDescriptionButtonClick:(UIButton *)sender;

- (IBAction)closeCommentsButtonClick:(UIButton *)sender;
- (IBAction)sendCommentButtonClick:(UIButton *)sender;

- (IBAction)closeFullImageButtonClick:(UIButton *)sender;

- (IBAction)closeEditCommentButtonClick:(UIButton *)sender;
- (IBAction)editSendCommentButtonClick:(UIButton *)sender;


@end
