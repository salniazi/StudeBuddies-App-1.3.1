//
//  DropBoxViewController.h
//  TedBuddies
//
//  Created by Mac on 30/03/16.
//  Copyright © 2016 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MIBadgeButton.h"

@interface DropBoxViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *btnSignOut;
@property (weak, nonatomic) IBOutlet MIBadgeButton *btnCancelAndImport;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UILabel *lblNote;
@property (weak, nonatomic) IBOutlet UIButton *btnLink;
@property (weak, nonatomic) IBOutlet UILabel *lblNavTitle;
@property (assign)bool isCreateAds;

- (IBAction)btnSignOutClick:(id)sender;
- (IBAction)btnCancelAndImportClick:(id)sender;
- (IBAction)btnLinkClick:(id)sender;

@end
