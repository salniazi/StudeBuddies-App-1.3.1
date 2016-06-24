//
//  PreferenceSettingViewController.h
//  TedBuddies
//
//  Created by Sunil on 08/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreferenceSettingViewController : UIViewController
{
    NSArray *arrSettingOptions;
}

@property (assign)BOOL isFirstTime;

@property (strong, nonatomic) IBOutlet UISwitch *switchMajor;
@property (strong, nonatomic) IBOutlet UISwitch *switchSchool;
@property (strong, nonatomic) IBOutlet UISwitch *switchClassTitle;
@property (strong, nonatomic) IBOutlet UISwitch *switchTime;
@property (strong, nonatomic) IBOutlet UISwitch *switchCoursePrefix;
@property (weak, nonatomic) IBOutlet UIButton *btnClassSchedule;

@property (strong, nonatomic) IBOutlet UIView *viewReportMessage;

@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;

@property (weak, nonatomic) IBOutlet UITextField *txtFieldReportMessage;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


- (IBAction)closeButtonClick:(id)sender;
- (IBAction)sendButtonClick:(id)sender;
- (IBAction)btnViewProfileTapped:(UIButton *)sender;
- (IBAction)switchMajorAction:(UISwitch *)sender;
- (IBAction)switchSchoolAction:(UISwitch *)sender;
- (IBAction)switchClassTitleAction:(UISwitch *)sender;
- (IBAction)switchTimeAction:(UISwitch *)sender;
- (IBAction)switchCoursePrefixAction:(UISwitch *)sender;
- (IBAction)btnSaveTapped:(UIButton *)sender;
- (IBAction)btnBackTapped:(UIButton *)sender;
- (IBAction)btnReportAProblemTapped:(UIButton *)sender;
- (IBAction)btnPrivacyPolicyTapped:(UIButton *)sender;
- (IBAction)btnTermsAndConditionTapped:(UIButton *)sender;
- (IBAction)btnLogOutTapped:(UIButton *)sender;
- (IBAction)btnSchedulTapped:(id)sender;
@end
