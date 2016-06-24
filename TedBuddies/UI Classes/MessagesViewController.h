//
//  MessagesViewController.h
//  TedBuddies
//
//  Created by Mayank Pahuja on 27/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@interface MessagesViewController : GAITrackedViewController
{
    NSMutableArray *arrRecentChats;
    NSMutableArray *arryClassChat;
    BOOL isSearching;
    NSMutableArray *arrayFilteredContentList;
    NSMutableArray *arrayPerCourse;
}

@property (weak, nonatomic) IBOutlet UILabel *lblNumberOfMessage;
@property (weak, nonatomic) IBOutlet UIView *viewSegment;
- (IBAction)btnAddTapped:(id)sender;

- (IBAction)btnSettingTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)btnBackTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *lblNavBar;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBarMain;
@property (assign, nonatomic) BOOL isFromPush;
- (IBAction)btnSearchTapped:(id)sender;


- (void)callAPIRecentChats;





@end
