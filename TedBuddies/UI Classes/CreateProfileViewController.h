//
//  CreateProfileViewController.h
//  TedBuddies
//
//  Created by Sunil on 08/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMTime.h>
#import "ScheduleClassViewController.h"
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "ImageCropView.h"
#import <RSKImageCropper/RSKImageCropper.h>
@interface CreateProfileViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate,ScheduleDelegate,ImageCropViewControllerDelegate,RSKImageCropViewControllerDelegate>
{
    NSDictionary *dictScheduleDetails;
    NSMutableDictionary *dictClassScheduleData;
    NSString *universityId;
    NSString *collegeYearId;
    NSString *majorId;
    BOOL isMajor;
    BOOL isTextField;
    BOOL isViewDidLoad;
    NSString *msgString;
    NSMutableArray * arrayEditImage;
    IBOutlet UIImageView* imgProfilePic;
 
}
@property (strong, nonatomic) IBOutlet UIScrollView *scrlViewMain;
@property (weak, nonatomic) IBOutlet UIImageView *imgScheduleClassImage;
@property (weak, nonatomic) IBOutlet UIImageView *imgArrow;
@property (weak, nonatomic) IBOutlet UITableView *tblCollegeYear;

@property (weak, nonatomic) IBOutlet UIImageView *imgCoverBlurImage;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControlImages;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldName;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldDob;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldUniversity;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldDegree;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldCollege;
@property (strong, nonatomic) IBOutlet UIScrollView *scrlViewProfileImages;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) IBOutlet UIButton *btnUploadPic;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBarPicker;
@property (weak, nonatomic) IBOutlet UILabel *lblClassSchedule;
@property (strong,nonatomic) NSString * buddyId;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonToolBar;
@property (strong, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITableView *tblViewUniversity;
@property (weak, nonatomic) IBOutlet UITableView *tblViewMajor;
@property (strong, nonatomic) NSString* userID;
@property (weak, nonatomic) IBOutlet UIButton *btnClassSchedule;
@property (weak, nonatomic) IBOutlet UIButton *btnCreateProfile;
@property (nonatomic, strong) ALAssetsLibrary *library;
@property (nonatomic) BOOL isEditProfile;
@property (strong, nonatomic) NSMutableDictionary * dictGetEditProfileDetails;
@property (nonatomic, strong) NSDictionary *dictReceivedDetails;
@property (strong, nonatomic) IBOutlet UIButton *btnRemoveImage;
@property (weak, nonatomic) IBOutlet UIButton *btnShowYear;


//New

@property (nonatomic) uint64_t fileSize;
@property (nonatomic) uint64_t amountUploaded;
@property (nonatomic , strong) UIView *loadingBg;
@property (nonatomic , strong) UIView *progressView;
@property (nonatomic , strong) UILabel *progresslabel;

@property(nonatomic, strong) NSString* stringA;
@property(nonatomic, weak) NSString* stringB;

- (IBAction)btnShowYearTapped:(UIButton *)sender;

- (IBAction)btnScheduleClassTapped:(UIButton *)sender;
- (IBAction)btnCreateProfileTapped:(UIButton *)sender;
- (IBAction)btnUploadImageTapped:(UIButton *)sender;
- (IBAction)btnRemoveImageTapped:(UIButton *)sender;
- (IBAction)btnScheduleTapped:(id)sender;


@end
