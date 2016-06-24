//
//  GroupMembersTableViewCell.h
//  TedBuddies
//
//  Created by Mac on 27/04/16.
//  Copyright © 2016 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupMembersTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imgMemberProfile;
@property (weak, nonatomic) IBOutlet UILabel *lblMemberName;

@end
