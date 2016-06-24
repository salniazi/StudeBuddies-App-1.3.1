//
//  MyBuddiesViewController.h
//  TedBuddies
//
//  Created by Mayank Pahuja on 03/09/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyBuddiesViewController : UIViewController
{
    NSArray *arrayBuddies;
}
@property (strong, nonatomic) IBOutlet UILabel *lblNavBar;
@property (strong, nonatomic) IBOutlet UITableView *tblViewMyBuddies;
@property (weak, nonatomic) IBOutlet UIView *viewPopUp;
@property (weak, nonatomic) IBOutlet UIView *viewInner;

- (IBAction)btnBacktapped:(id)sender;
- (IBAction)btnFindBuddiesTapped:(UIButton *)sender;
- (IBAction)tapClose:(id)sender;

@end
