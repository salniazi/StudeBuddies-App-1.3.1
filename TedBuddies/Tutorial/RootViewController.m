//
//  RootViewController.m
//  TedBuddies
//
//  Created by Sourabh Singh on 29/09/15.
//  Copyright (c) 2015 Mayank Pahuja. All rights reserved.
//

#import "RootViewController.h"
#import "LoginViewController.h"
#import <AppDelegate.h>

@interface RootViewController ()


@end

@implementation RootViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // after creating the UIPageViewController
    
   
    
    EAIntroPage *page1 = [EAIntroPage page];
    page1.title = @"";
    page1.desc = @"";
    page1.bgImage = [UIImage imageNamed:@"slide1"];
    page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title1"]];
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.title = @"";
    page2.desc = @"";
    page2.bgImage = [UIImage imageNamed:@"slide2"];
    page2.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title2"]];
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.title = @"";
    page3.desc = @"";
    page3.bgImage = [UIImage imageNamed:@"slide3"];
    page3.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title3"]];
    
    EAIntroPage *page4 = [EAIntroPage page];
    page4.title = @"";
    page4.desc = @"";
    page4.bgImage = [UIImage imageNamed:@"slide4"];
    page4.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title4"]];
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3,page4]];
    [intro setDelegate:self];
    
     intro.pageControlY = 450.f;
    intro.skipButtonY = 435.f;
    
    [intro showInView:self.view animateDuration:0];

}

#pragma mark - EAIntroView delegate

- (void)introDidFinish:(EAIntroView *)introView {
    NSLog(@"introDidFinish callback");
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate addSplashScreen];
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
