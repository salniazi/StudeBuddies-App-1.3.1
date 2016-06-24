//
//  SettingViewController.h
//  TedBuddies
//
//  Created by Sunidhi Gupta on 28/11/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController
{
    NSArray *arraySettingOption;
}

@property (strong, nonatomic) IBOutlet UIView *viewReportMessage;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldReportMessage;

- (IBAction)backButtonClick:(UIButton *)sender;
- (IBAction)closeButtonClick:(id)sender;
- (IBAction)sendButtonClick:(id)sender;

@end
