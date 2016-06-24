//
//  MarketPlaceViewController.h
//  TedBuddies
//
//  Created by Mayank Pahuja on 27/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"


@interface MarketPlaceViewController : GAITrackedViewController <UIWebViewDelegate>
{
    NSMutableArray * arrayMarketPlace ;
    NSArray *arrayMarketPlace1;
    NSInteger counter;
    NSMutableArray * arrayFilteredContentList;
    BOOL isSearching;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lblNavBar;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBarMarketPlace;
@property (weak, nonatomic) IBOutlet UILabel *lblErrMsg;

- (IBAction)btnAddTapped:(id)sender;
- (IBAction)btnSettingTapped:(id)sender;
- (IBAction)btnBackPapped:(id)sender;
- (IBAction)btnSearchTapped:(id)sender;

@end


// make ui clean