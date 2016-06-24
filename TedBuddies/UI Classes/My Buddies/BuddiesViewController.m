//
//  BuddiesViewController.m
//  TedBuddies
//
//  Created by Sunidhi Gupta on 26/11/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import "BuddiesViewController.h"
#import "MyBuddiesViewController.h"
#import "FindBuddiesViewController.h"
#import "AddContactFriendsViewController.h"
#import "AddFacebookFriendsViewController.h"
#import "BuddyGridController.h"

@interface BuddiesViewController ()

@end

@implementation BuddiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    BuddyGridController *grid = [[BuddyGridController alloc] initWithNibName:@"BuddyGridController" bundle:nil];
    grid.fromScene = COMINGFROM_MYBUDDIES;
    //MyBuddiesViewController * myBuddiesViewController = [[MyBuddiesViewController alloc]initWithNibName:@"MyBuddiesViewController" bundle:nil];
    [self.navigationController pushViewController:grid animated:NO];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tabBarController.tabBar setHidden:NO];
    [self setFonts];
    
    UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backSwipeAction)];
    [backSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:backSwipe];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // FOR GOOGLE ANALYTICS
    
    self.screenName = @"Buddies Screen";
}
- (void)setFonts
{
    [_lblNavBar setFont:FONT_REGULAR(kNavigationFontSize)];
}

- (IBAction)backButtonClick:(UIButton *)sender
{
    [self backSwipeAction];
}

- (void)backSwipeAction
{
    [self.tabBarController setSelectedIndex:2];
}

- (IBAction)myBuddiesButtonClick:(UIButton *)sender
{
    
    BuddyGridController *grid = [[BuddyGridController alloc] initWithNibName:@"BuddyGridController" bundle:nil];
    grid.fromScene = COMINGFROM_MYBUDDIES;
    //MyBuddiesViewController * myBuddiesViewController = [[MyBuddiesViewController alloc]initWithNibName:@"MyBuddiesViewController" bundle:nil];
    [self.navigationController pushViewController:grid animated:YES];
}

- (IBAction)suggestedBuddiesButtonClick:(UIButton *)sender
{
    BuddyGridController *grid = [[BuddyGridController alloc] initWithNibName:@"BuddyGridController" bundle:nil];
    grid.fromScene = COMINGFROM_SUGGESTEDBUDDIES;
    //MyBuddiesViewController * myBuddiesViewController = [[MyBuddiesViewController alloc]initWithNibName:@"MyBuddiesViewController" bundle:nil];
    [self.navigationController pushViewController:grid animated:YES];
//    FindBuddiesViewController *findBuddiesViewController = [[FindBuddiesViewController alloc]initWithNibName:@"FindBuddiesViewController" bundle:nil];
//    [self.navigationController pushViewController:findBuddiesViewController animated:YES];
}

- (IBAction)inviteBuddiesButtonClick:(UIButton *)sender
{
    UIActionSheet *inviteActionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Invite from contacts",@"Invite from facebook",nil];
    inviteActionSheet.delegate = self;
    [inviteActionSheet showFromTabBar:SharedAppDelegate.tabBarController.tabBar];
}

#pragma mark ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        AddContactFriendsViewController *addContactFriendsViewController = [[AddContactFriendsViewController alloc]initWithNibName:@"AddContactFriendsViewController" bundle:nil];
        [self.navigationController pushViewController:addContactFriendsViewController animated:YES];
    }
    else if(buttonIndex == 1)
    {
        AddFacebookFriendsViewController *addFacebookFriendsViewController = [[AddFacebookFriendsViewController alloc]initWithNibName:@"AddFacebookFriendsViewController" bundle:nil];
        [self.navigationController pushViewController:addFacebookFriendsViewController animated:YES];
    }
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

@end
