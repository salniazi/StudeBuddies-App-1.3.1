//
//  BuddiesViewController.h
//  TedBuddies
//
//  Created by Sunidhi Gupta on 26/11/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface BuddiesViewController : GAITrackedViewController <UIActionSheetDelegate>
{
    
}

@property (strong, nonatomic) IBOutlet UILabel *lblNavBar;



- (IBAction)backButtonClick:(UIButton *)sender;

- (IBAction)myBuddiesButtonClick:(UIButton *)sender;
- (IBAction)suggestedBuddiesButtonClick:(UIButton *)sender;
- (IBAction)inviteBuddiesButtonClick:(UIButton *)sender;

@end
