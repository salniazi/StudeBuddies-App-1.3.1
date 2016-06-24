//
//  CreatePostViewController.h
//  TedBuddies
//
//  Created by Sunil on 29/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CMTime.h>
#import "PHTextView.h"
#import "ImageCropView.h"
#import <RSKImageCropper/RSKImageCropper.h>

@interface CreatePostViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,ImageCropViewControllerDelegate,RSKImageCropViewControllerDelegate>
{
    BOOL isTextField;
    NSInteger userId;
    NSArray * arrClassTitle;
    NSString *msgString;
   
}
@property (strong, nonatomic) IBOutlet UIScrollView *scrlViewMain;
@property (strong, nonatomic) IBOutlet UIButton *btnSetTitle;

@property (weak, nonatomic) IBOutlet UILabel *lblAddImage;

@property (weak, nonatomic) IBOutlet UILabel *lblNavBar;
@property (weak, nonatomic) IBOutlet UIButton *btnPost;
@property (nonatomic, strong) NSString *classId;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UIButton *btnBlog;
@property (weak, nonatomic) IBOutlet UIButton *btnPostData;
@property (weak, nonatomic) IBOutlet UIButton *btnAddImage;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldHeading;
@property (weak, nonatomic) IBOutlet UITextView *txtViewDescription;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *viewClassList;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldClass;
@property (weak, nonatomic) IBOutlet UIImageView *imgPostImage;
@property (nonatomic) BOOL isAlive;
@property (strong,nonatomic) NSDictionary * dictEditPostBlob;

- (IBAction)btnBlogTapped:(id)sender;
- (IBAction)btnPostTapped:(UIButton *)sender;
- (IBAction)btnPostDataTapped:(UIButton *)sender;
- (IBAction)btnScheduleClassesTapped:(UIButton *)sender;
- (IBAction)btnAddImageTapped:(UIButton *)sender;
- (IBAction)btnBackTapped:(UIButton *)sender;

@end
