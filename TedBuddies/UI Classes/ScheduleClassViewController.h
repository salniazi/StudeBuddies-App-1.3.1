//
//  ScheduleClassViewController.h
//  TedBuddies
//
//  Created by Mayank Pahuja on 22/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageCropView.h"
#import <RSKImageCropper/RSKImageCropper.h>
#import "MPGTextField.h"

@protocol ScheduleDelegate <NSObject>

- (void)scheduleDetails:(NSDictionary*)dictSendInfo;

@end


@interface ScheduleClassViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate,ScheduleDelegate,ImageCropViewControllerDelegate,RSKImageCropViewControllerDelegate,MPGTextFieldDelegate,UIAlertViewDelegate>

{
    BOOL isFromTime;
    BOOL isTextField;
    
    NSArray *arrayCoursePrefix;
    NSArray *arrayClassTitle;
    NSArray *arraySectionName;
    
    NSInteger selectedTextField;

    NSString *professorId;
    NSString *classId;
    NSString *sectionId;
    NSString *msgString;
    
    NSString *courseId;
    NSString *courseNo;
    
    
}

typedef enum SelectedField
{
    kSelectedFieldDate = 0,
    kSelectedFieldFromTime,
    kSelectedFieldToTime
}kSelectedField;

@property (nonatomic, assign) BOOL isAlive;
@property (weak, nonatomic) IBOutlet UIButton *btnSaveSchedule;

@property (nonatomic, assign) BOOL isOnlySchedule;
@property (nonatomic, strong)id <ScheduleDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldDate;
@property (weak, nonatomic) IBOutlet MPGTextField *txtFieldCoursePrefix;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldTime;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldClassTitle;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldClassSection;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldToTime;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBarPicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonToolBar;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *pickerTime;
@property (weak, nonatomic) IBOutlet UITableView *tblViewProfessorName;
@property (weak, nonatomic) IBOutlet UITableView *tblViewClassTitle;
@property (weak, nonatomic) IBOutlet UITableView *tblViewSectionName;
@property (weak, nonatomic) IBOutlet UILabel *lblScheduleTitle;
@property (strong, nonatomic) NSString *scheduledClassId;
@property (strong,nonatomic) NSDictionary * dictEditScheduleClass;
@property (strong, nonatomic) NSDictionary *dictScheduleClass;
@property (strong, nonatomic) NSMutableDictionary *dictClassScheduleData;
@property (weak, nonatomic) IBOutlet UIImageView *imgTutorial;
@property (weak, nonatomic) IBOutlet UIButton *btnUniCredentials;
@property (weak, nonatomic) IBOutlet UITextField *txtID;
@property (weak, nonatomic) IBOutlet UITextField *txtPwd;
@property (weak, nonatomic) IBOutlet UIButton *btnSignIn;


@property (weak, nonatomic) IBOutlet UIView *popUpView;
@property (weak, nonatomic) IBOutlet UIView *innerPopUpView;

- (IBAction)btnBackTapped:(UIButton *)sender;
- (IBAction)btnAddScheduleTapped:(UIButton *)sender;
- (IBAction)pickerTimeChanged:(UIDatePicker *)sender;
- (IBAction)btnUniCredentialsTapped:(id)sender;
- (IBAction)btnSignInTapped:(id)sender;




@end
