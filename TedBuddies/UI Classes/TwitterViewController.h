//
//  TwitterViewController.h
//  TedBuddies
//
//  Created by Sunil on 02/09/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwitterViewController : UIViewController

- (IBAction)btnBackTapped:(id)sender;

- (IBAction)btnTweetTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UITextView *txtFieldPost;

@property (weak, nonatomic) IBOutlet UILabel *lblNavBar;


@end

