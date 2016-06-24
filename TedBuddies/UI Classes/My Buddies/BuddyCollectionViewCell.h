//
//  BuddyCollectionViewCell.h
//  TedBuddies
//
//  Created by Sourabh on 15/05/15.
//  Copyright (c) 2015 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BuddyCollectionViewCell;
@protocol SBCollectionCellTappedDelegate <NSObject>

@optional

-(void)blockButtonTappedWithCell:(BuddyCollectionViewCell *)cell;
-(void)chatButtonTappedWithCell:(BuddyCollectionViewCell *)cell;
-(void)nameButtonTappedWithCell:(BuddyCollectionViewCell *)cell;
-(void)addButtonTappedWithCell:(BuddyCollectionViewCell *)cell;
-(void)cameraButtonClicked:(BuddyCollectionViewCell *)cell;
-(void)classesButtonTapped:(BuddyCollectionViewCell *)cell;
@end

@interface BuddyCollectionViewCell : UICollectionViewCell

@property (assign , nonatomic) id <SBCollectionCellTappedDelegate> collectionCellDelegate;

@property (weak, nonatomic) IBOutlet UIView *mainBackView;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *classLabel;

@property (weak, nonatomic) IBOutlet UIImageView *mainImageview;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;//4,162,149,20
@property (weak, nonatomic) IBOutlet UIButton *nameButton;
@property (weak, nonatomic) IBOutlet UILabel *majorlabel;//156
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UILabel *picsNumberLabel;
@property (weak, nonatomic) IBOutlet UIButton *classesNumberButton;
@property (weak, nonatomic) IBOutlet UILabel *matchedLabel;

@property (weak, nonatomic) IBOutlet UILabel *universityLabel;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UIButton *blockButton;

@property (weak, nonatomic) IBOutlet UIButton *addButton;
-(void)changeButtons:(BOOL)comingFrom;
-(void)configureCellView:(BOOL )configure;
@end
