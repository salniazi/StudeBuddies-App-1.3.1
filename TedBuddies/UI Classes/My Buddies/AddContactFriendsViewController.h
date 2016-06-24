//
//  AddContactFriendsViewController.h
//  TedBuddies
//
//  Created by Mayank Pahuja on 17/11/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddContactFriendsViewController : UIViewController
{
    NSInteger page;
    NSMutableArray * arrayBuddies;
    NSMutableArray * arrayBuddiesResponse;
    NSMutableArray * arrayTempBuddies;
}

@property(assign)bool isText;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *lblNavBar;
@property (weak, nonatomic) IBOutlet UIButton *btnNewUsers;
@property (weak, nonatomic) IBOutlet UIButton *btnRegisteredUsers;

@property (weak, nonatomic) IBOutlet UIView *viewSegment;


- (IBAction)btnBackTapped:(UIButton *)sender;
- (IBAction)btnRegisteredUsersTapped:(UIButton *)sender;
- (IBAction)btnNewUsersTapped:(UIButton *)sender;
@end
