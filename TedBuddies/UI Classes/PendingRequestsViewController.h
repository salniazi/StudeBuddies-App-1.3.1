//
//  PendingRequestsViewController.h
//  TedBuddies
//
//  Created by Sunil on 08/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PendingRequestsViewController : UIViewController
{
    NSInteger page;
    NSArray * arrayBuddies;
    NSDictionary *tempDict;
    NSString * buddyId;
}

- (IBAction)btnBackTapped:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lblNavBar;
- (IBAction)settingButtonClick:(id)sender;
@end
