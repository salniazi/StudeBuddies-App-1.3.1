//
//  GroupMemberListViewController.h
//  TedBuddies
//
//  Created by Mac on 27/04/16.
//  Copyright © 2016 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupMemberListViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic)NSMutableDictionary *dictMembers;

@property (weak, nonatomic) IBOutlet UITableView *membersTableView;

@property (weak, nonatomic) IBOutlet UIButton *btnLeaveJoin;

@property (weak, nonatomic) IBOutlet UISwitch *muteSwitch;
@property (assign)bool isLeft;
@property (assign)bool isMute;
@property (assign)bool isClass;
@property (weak, nonatomic) IBOutlet UILabel *lblTittle;

- (IBAction)btnBackTapped:(id)sender;
- (IBAction)MuteSwitchClick:(id)sender;
- (IBAction)btnLeaveclick:(id)sender;

@end
