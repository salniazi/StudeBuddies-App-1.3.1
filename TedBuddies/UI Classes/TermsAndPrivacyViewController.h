//
//  TermsAndPrivacyViewController.h
//  TedBuddies
//
//  Created by Sunidhi Gupta on 28/11/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TermsAndPrivacyViewController : UIViewController
{
    
}

@property (retain, nonatomic) NSString *headingName;

@property (weak, nonatomic) IBOutlet UILabel *lblHeading;
@property (weak, nonatomic) IBOutlet UIWebView *webView;


- (IBAction)backButtonClick:(UIButton *)sender;

@end
