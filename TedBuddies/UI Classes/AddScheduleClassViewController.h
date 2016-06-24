//
//  AddScheduleClassViewController.h
//  TedBuddies
//
//  Created by Mayank Pahuja on 22/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddScheduleDelegate <NSObject>

- (void)scheduleDetails:(NSDictionary*)dictSendInfo;

@end


@interface AddScheduleClassViewController : UIViewController
{
    BOOL isFromTime;
    BOOL isTextField;
    
    NSArray *arrayProfessorName;
    NSArray *arrayClassTitle;
    NSArray *arraySectionName;
    NSArray * arrayUniversity;
    NSArray * arrayMajor;
    NSString *professorId;
    NSString *classId;
    NSString *sectionId;
    NSString *universityId;
    NSString *majorId;

    NSString *msgString;
    BOOL isMajor;
}
@property (nonatomic, assign) BOOL isOnlySchedule;
@property (nonatomic, strong)id <AddScheduleDelegate> delegate;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldDate;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldTime;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldProfessorName;
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
@property (weak, nonatomic) IBOutlet UITextField *txtFieldSelectUniversity;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldSelectDegree;
@property (weak, nonatomic) IBOutlet UITableView *tblViewSelectUniversity;
@property (weak, nonatomic) IBOutlet UITableView *tblViewSelectDegree;


- (IBAction)btnBackTapped:(UIButton *)sender;
- (IBAction)btnAddScheduleTapped:(UIButton *)sender;
- (IBAction)pickerTimeChanged:(UIDatePicker *)sender;

@end
