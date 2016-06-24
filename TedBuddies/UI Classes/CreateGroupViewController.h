//
//  CreateGroupViewController.h
//  TedBuddies
//
//  Created by Mayank Pahuja on 24/09/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatScreenViewController.h"
#import "JSTokenField.h"


@interface CreateGroupViewController : UIViewController<JSTokenFieldDelegate>
{
    NSMutableArray *arrayBuddies;
    NSMutableArray *arrGroupMembers;
    NSMutableArray *searchBuddys;
    NSDictionary *dictSelectedUser;
    NSMutableArray *feedArray;
    NSMutableArray *seldata;
    NSMutableArray *dataArray;
    NSMutableArray *arryIndex;
    BOOL isSearch;
}

@property (strong, nonatomic) IBOutlet UIImageView *imgViewTextFieldBg;
@property (strong, nonatomic) IBOutlet UITextField *txtFieldGroupName;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UILabel *lblNavBar;
@property (strong, nonatomic) IBOutlet UITableView *tblViewGroupMembers;

@property (strong, nonatomic) IBOutlet UIImageView *imgViewMemberNameBg;
@property (strong, nonatomic) IBOutlet UIButton *btnCreate;


- (IBAction)btnBackTapped:(UIButton *)sender;
- (IBAction)btnCreateTapped:(UIButton *)sender;
@end
