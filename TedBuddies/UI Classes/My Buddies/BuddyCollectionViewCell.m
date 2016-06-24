//
//  BuddyCollectionViewCell.m
//  TedBuddies
//
//  Created by Sourabh on 15/05/15.
//  Copyright (c) 2015 Mayank Pahuja. All rights reserved.
//

#import "BuddyCollectionViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface BuddyCollectionViewCell ()

@property(nonatomic) BOOL doS;

@end

@implementation BuddyCollectionViewCell

-(void)changeButtons:(BOOL)comingFrom
{
    self.bottomView.layer.cornerRadius = 3.0f;
    [self.bottomView setClipsToBounds:YES];
    if(comingFrom)
    {
        // MYBUDDIES
        [self.blockButton setHidden:NO];
        [self.addButton setHidden:YES];
    }
    else
    {
        //SUGGESTED BUDDIES
        [self.blockButton setHidden:YES];
        [self.addButton setHidden:NO];
    }
}

-(void)layoutSubviews
{
    NSLog(@"in layoutsubviews");
    self.mainBackView.layer.cornerRadius = self.mainBackView.frame.size.height /2;
    self.mainBackView.layer.masksToBounds = YES;
    self.mainBackView.layer.borderWidth = 0;
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.majorlabel.textAlignment = NSTextAlignmentCenter;
    self.universityLabel.textAlignment = NSTextAlignmentCenter;
    if(_doS)
    {
        [self.nameLabel setFrame:self.classLabel.frame];
        [self.nameButton setFrame:CGRectMake(self.classLabel.frame.origin.x, self.classLabel.frame.origin.y - 2, self.nameButton.frame.size.width, self.nameButton.frame.size.height)];
    }

}
-(void)configureCellView:(BOOL )configure
{
    if(configure)
    {
        self.doS = configure;
    }
    
    //[self.nameLabel setFrame:self.classLabel.frame];
//    // Set image over layer
//    CAGradientLayer *gradient = [CAGradientLayer layer];
//    gradient.frame = _mainImageview.frame;
//    
//    // Add colors to layer
//    UIColor *centerColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.25];
//    UIColor *endColor = [UIColor grayColor];
//    gradient.colors = [NSArray arrayWithObjects:
//                       (id)[endColor CGColor],
//                       (id)[centerColor CGColor],
//                       (id)[endColor CGColor],
//                       nil];
//    
//    [_mainImageview.layer insertSublayer:gradient atIndex:0];
    
}
- (IBAction)blockButtonClicked:(id)sender
{
    NSLog(@"blockButtonClicked");
    if (self.collectionCellDelegate && [self.collectionCellDelegate conformsToProtocol:@protocol(SBCollectionCellTappedDelegate)])
    {
        if ([self.collectionCellDelegate respondsToSelector:@selector(blockButtonTappedWithCell:)])
        {
            [self.collectionCellDelegate blockButtonTappedWithCell:self];
        }
    }
}

- (IBAction)chatButtonClicked:(id)sender
{
    NSLog(@"chatButtonClicked");
    if (self.collectionCellDelegate && [self.collectionCellDelegate conformsToProtocol:@protocol(SBCollectionCellTappedDelegate)])
    {
        if ([self.collectionCellDelegate respondsToSelector:@selector(chatButtonTappedWithCell:)])
        {
            [self.collectionCellDelegate chatButtonTappedWithCell:self];
        }
    }
}
- (IBAction)nameButtonClicked:(id)sender
{
    NSLog(@"nameButtonClicked");
    if (self.collectionCellDelegate && [self.collectionCellDelegate conformsToProtocol:@protocol(SBCollectionCellTappedDelegate)])
    {
        if ([self.collectionCellDelegate respondsToSelector:@selector(nameButtonTappedWithCell:)])
        {
            [self.collectionCellDelegate nameButtonTappedWithCell:self];
        }
    }
}
- (IBAction)addButtonClicked:(id)sender
{
    NSLog(@"addButtonClicked");
    if (self.collectionCellDelegate && [self.collectionCellDelegate conformsToProtocol:@protocol(SBCollectionCellTappedDelegate)])
    {
        if ([self.collectionCellDelegate respondsToSelector:@selector(addButtonTappedWithCell:)])
        {
            [self.collectionCellDelegate addButtonTappedWithCell:self];
        }
    }
}

- (IBAction)cameraClicked:(id)sender
{
    NSLog(@"cameraClicked");
    if (self.collectionCellDelegate && [self.collectionCellDelegate conformsToProtocol:@protocol(SBCollectionCellTappedDelegate)])
    {
        if ([self.collectionCellDelegate respondsToSelector:@selector(cameraButtonClicked:)])
        {
            [self.collectionCellDelegate cameraButtonClicked:self];
        }
    }
}


- (IBAction)picsNumberButtonClicked:(id)sender
{
    if (self.collectionCellDelegate && [self.collectionCellDelegate conformsToProtocol:@protocol(SBCollectionCellTappedDelegate)])
    {
        if ([self.collectionCellDelegate respondsToSelector:@selector(classesButtonTapped:)])
        {
            [self.collectionCellDelegate classesButtonTapped:self];
        }
    }

}

@end
