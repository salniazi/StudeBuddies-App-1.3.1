//
//  GifCollectionViewCell.m
//  GiphyClient
//
//  Created by Jared Halpern on 9/16/15.
//  Copyright (c) 2015 byteMason. All rights reserved.
//

#import "GifCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface GifCollectionViewCell ()
@property (nonatomic, strong) NSURL *imageURL;
@end

@implementation GifCollectionViewCell

- (void)prepareForReuse
{
  [super prepareForReuse];
  _imageURL = nil;
  [self setNeedsLayout];
}

- (void)setImageURL:(NSURL *)imageURL
{
  MBProgressHUD *progressHUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
  progressHUD.mode = MBProgressHUDModeAnnularDeterminate;
  progressHUD.delegate = self;
  [progressHUD show:YES];
  progressHUD.color = kColorLightBlueAlpha;

  _imageURL = imageURL;
  
  UIImageView *imageView = [[UIImageView alloc] init];
  imageView.translatesAutoresizingMaskIntoConstraints = NO;
  
  [imageView sd_setImageWithURL:imageURL
               placeholderImage:kPlaceholderImage
                        options:SDWebImageProgressiveDownload
                       progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                           CGFloat recSize = [[NSNumber numberWithInteger:receivedSize] floatValue];
                           CGFloat expSize = [[NSNumber numberWithInteger:expectedSize] floatValue];
                           CGFloat progress = (recSize / expSize);
                           progressHUD.progress = progress;
                         });
                         
                       } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                         dispatch_async(dispatch_get_main_queue(), ^{
                           [progressHUD hide:YES];
                         });
                         
                         if (error) {
                           NSLog(@"%s - %@", __PRETTY_FUNCTION__, error);
                         }
                       }];
  
  [self.contentView addSubview:imageView];
  
  [self addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                   attribute:NSLayoutAttributeCenterX
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self
                                                   attribute:NSLayoutAttributeCenterX
                                                  multiplier:1.0
                                                    constant:0.0]];
  
  [self addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                   attribute:NSLayoutAttributeCenterY
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self
                                                   attribute:NSLayoutAttributeCenterY
                                                  multiplier:1.0
                                                    constant:0.0]];
  
  [self addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                   attribute:NSLayoutAttributeWidth
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self
                                                   attribute:NSLayoutAttributeWidth
                                                  multiplier:1.0
                                                    constant:0.0]];
  
  [self addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                   attribute:NSLayoutAttributeHeight
                                                   relatedBy:NSLayoutRelationEqual
                                                      toItem:self
                                                   attribute:NSLayoutAttributeHeight
                                                  multiplier:1.0
                                                    constant:0.0]];
  [self setNeedsLayout];
}

@end
