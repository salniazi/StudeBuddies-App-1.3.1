//
//  BuddyGridController.h
//  TedBuddies
//
//  Created by Sourabh on 15/05/15.
//  Copyright (c) 2015 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"

typedef enum
{
    COMINGFROM_MYBUDDIES = 0,
    COMINGFROM_SUGGESTEDBUDDIES = 1,
} ComingFromScene;

@interface BuddyGridController : UIViewController<UICollectionViewDelegate,UICollectionViewDataSource,MWPhotoBrowserDelegate,UIActionSheetDelegate,UIScrollViewDelegate>
{
    NSArray *arrayBuddies;
    NSArray *suggestedBuddies;
    NSMutableArray *_selections;
    
  

}
@property (weak, nonatomic) IBOutlet UICollectionView *buddyCollectionView;

@property (nonatomic, assign) ComingFromScene fromScene;
@property (strong, nonatomic) NSString *buddyId;

@property (weak, nonatomic) IBOutlet UIView *viewSegement;
@property (weak, nonatomic) IBOutlet UILabel *buddiesHeaderLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIView *viewInner;
@property (weak, nonatomic) IBOutlet UIView *viewPopUp;
@property (weak, nonatomic) IBOutlet UIButton *tapClose;
- (IBAction)settingButtonClick:(id)sender;

@end
