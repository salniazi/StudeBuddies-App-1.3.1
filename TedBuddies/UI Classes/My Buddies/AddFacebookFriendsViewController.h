//
//  AddFacebookFriendsViewController.h
//  TedBuddies
//
//  Created by Mayank Pahuja on 17/11/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNMBottomPullToRefreshManager.h"

@interface AddFacebookFriendsViewController : UIViewController
{
    NSInteger page;
    NSMutableArray * arrayBuddies;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *lblNavBar;

- (IBAction)btnBackTapped:(UIButton *)sender;
@end
