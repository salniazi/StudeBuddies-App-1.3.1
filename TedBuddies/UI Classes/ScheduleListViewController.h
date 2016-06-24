//
//  ScheduleListViewController.h
//  TedBuddies
//
//  Created by Sunil on 09/09/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleListViewController : UIViewController
{
    NSArray * arrayScheduleList;
}
@property (weak, nonatomic) IBOutlet UITableView *tblViewScheduleList;
@property (weak, nonatomic) IBOutlet UILabel *lblNavBar;
@property (strong,nonatomic) NSDictionary *tempDict;
- (IBAction)btnCreateScheduleTapped:(id)sender;
- (IBAction)btnBackTapped:(id)sender;

@end
