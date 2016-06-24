//
//  SplashViewController.m
//  TedBuddies
//
//  Created by Mayank Pahuja on 08/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import "SplashViewController.h"
#import "LoginViewController.h"

@interface SplashViewController ()

@end

@implementation SplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self performSelector:@selector(unloadSplash) withObject:nil afterDelay:3.0];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - methods

- (void)unloadSplash
{
    LoginViewController *loginViewC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [self.navigationController pushViewController:loginViewC animated:NO];
}

@end
