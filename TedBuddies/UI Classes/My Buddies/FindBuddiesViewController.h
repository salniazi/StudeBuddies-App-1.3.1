//
//  FindBuddiesViewController.h
//  TedBuddies
//
//  Created by Sunil on 08/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindBuddiesViewController : UIViewController
{
    NSInteger page;
    NSArray * arrayBuddies;
}

- (IBAction)btnBackTapped:(id)sender;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lblNavBar;
@property (weak, nonatomic) IBOutlet UIView *viewPopUp;
@property (weak, nonatomic) IBOutlet UIView *viewInner;

- (IBAction)tapClose:(id)sender;

@end
