//
//  TermsAndPrivacyViewController.m
//  TedBuddies
//
//  Created by Sunidhi Gupta on 28/11/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import "TermsAndPrivacyViewController.h"
#import "UIImage+animatedGIF.h"


@interface TermsAndPrivacyViewController ()<UIWebViewDelegate>

@end

@implementation TermsAndPrivacyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.webView.delegate=self;
    
    if([self.headingName isEqualToString:@"Terms Condition"])
    {
        self.lblHeading.text = @"Terms & Conditions";
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@Home/termsapp",kWebsiteURL]]]];
    }
    else
    {
        self.lblHeading.text = @"Privacy Policy";
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@Home/PrivacyPolicyapp",kWebsiteURL] ]]];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tabBarController.tabBar setHidden:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    [self startLoaderWithMessage:@""];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self stopLoader];
}

- (IBAction)backButtonClick:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)startLoaderWithMessage:(NSString *)message
{
    //    UIView *view = SharedAppDelegate.window.rootViewController.view;
    //    MBProgressHUD *_hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    //    _hud.dimBackground  = NO;
    //    _hud.labelText      = message;
    
    [Utils stopLoader];
    UIView *view = self.view;
    UIImageView *imgViewLoader = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"waitLoading" withExtension:@"gif"];
    imgViewLoader.image=[UIImage animatedImageWithAnimatedGIFURL:url];
    [imgViewLoader.layer setCornerRadius:10];
    [imgViewLoader setClipsToBounds:YES];
    //        innerPopUpView.backgroundColor=[UIColor whiteColor];
    //        [innerPopUpView.layer setShadowOpacity:0.9];
    //        [innerPopUpView.layer setShadowRadius:2.0];
    
    [view addSubview:imgViewLoader];
    imgViewLoader.center = view.center;
    imgViewLoader.tag = 30000;
    [view setUserInteractionEnabled:NO];
    
    
    //    [imgViewLoader setImage:[UIImage imageNamed:@"iconApp40.png"]];
    //    [imgViewLoader setContentMode:UIViewContentModeScaleAspectFill];
    //    [imgViewLoader.layer setCornerRadius:30];
    //    [imgViewLoader setClipsToBounds:YES];
    //    [view addSubview:imgViewLoader];
    //    imgViewLoader.center = view.center;
    //    CABasicAnimation *rotation;
    //    rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    //    rotation.fromValue = [NSNumber numberWithFloat:0];
    //    rotation.toValue = [NSNumber numberWithFloat:( 2 * M_PI)];
    //    rotation.duration = 1; // Speed
    //    rotation.repeatCount = HUGE_VALF; // Repeat forever. Can be a finite number.
    //    [imgViewLoader.layer addAnimation:rotation forKey:@"Spin"];
    //    imgViewLoader.tag = 30000;
    //    [view setUserInteractionEnabled:NO];
    
    // [Utils startActivityIndicatorInView:view withMessage:@""];
    
}

- (void)stopLoader
{
    //    UIView *view = SharedAppDelegate.window.rootViewController.view;
    //    [MBProgressHUD hideHUDForView:view animated:YES];
    
    UIView *view = self.view;
    UIImageView *imgViewLoader = (UIImageView*)[view viewWithTag:30000];
    [imgViewLoader removeFromSuperview];
    imgViewLoader = nil;
    [view setUserInteractionEnabled:YES];
    
    // [Utils stopActivityIndicatorInView:view];
}

@end
