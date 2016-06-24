//
//  DropBoxTableViewCell.h
//  TedBuddies
//
//  Created by Mac on 30/03/16.
//  Copyright © 2016 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DropBoxTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgFile;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *imgSelect;
@property (weak, nonatomic) IBOutlet UILabel *lblAttribute;
@end
