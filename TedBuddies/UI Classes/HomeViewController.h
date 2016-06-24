//
//  HomeViewController.h
//  TedBuddies
//
//  Created by Sunil on 08/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScheduleClassViewController.h"
#import "GAITrackedViewController.h"
#import "MIBadgeButton.h"



@interface HomeViewController : GAITrackedViewController //<ControllerPoppedDelegate>


@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@property (weak, nonatomic) IBOutlet UIImageView *btnCircleDot;
@property (strong, nonatomic) IBOutlet UILabel *lblChatNotification;

@property (strong, nonatomic) IBOutlet UILabel *lblNotification;
@property (weak, nonatomic) IBOutlet MIBadgeButton *btnMessage;
@property (weak, nonatomic) IBOutlet MIBadgeButton *btnBuddies;
@property (weak, nonatomic) IBOutlet MIBadgeButton *btnPost;
@property (weak, nonatomic) IBOutlet MIBadgeButton *btnMarketPlace;
@property (weak, nonatomic) IBOutlet MIBadgeButton *btnSchedule;
@property (weak, nonatomic) IBOutlet MIBadgeButton *btnPendingRequest;
@property (strong, nonatomic) IBOutlet UILabel *lblNavBar;
- (IBAction)btnProfileTapped:(UIButton *)sender;

- (IBAction)btnSettingsTapped:(UIButton *)sender;
- (IBAction)btnMessagesTapped:(MIBadgeButton *)sender;
- (IBAction)btnFindBuddyTapped:(MIBadgeButton *)sender;
- (IBAction)btnPostBlogTapped:(MIBadgeButton *)sender;
- (IBAction)btnMarketPlaceTapped:(MIBadgeButton *)sender;
- (IBAction)btnScheduleClassTapped:(MIBadgeButton *)sender;
- (IBAction)btnPendingRequestsTapped:(MIBadgeButton *)sender;
- (IBAction)btnPreferencesTapped:(UIButton *)sender;
- (IBAction)btnMessageTouched:(UIButton *)sender;
- (IBAction)btnClassSchduleTapped:(id)sender;
- (IBAction)btnMarketPlaceTouched:(id)sender;
- (IBAction)btnBlogTouched:(id)sender;
- (IBAction)btnPendingTouched:(id)sender;
- (IBAction)btnBuddiesTouched:(id)sender;
- (void)callAPIRecentChats;
@end
