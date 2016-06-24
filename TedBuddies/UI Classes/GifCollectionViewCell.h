//
//  GifCollectionViewCell.h
//  GiphyClient
//
//  Created by Jared Halpern on 9/16/15.
//  Copyright (c) 2015 byteMason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
//#import <MBProgressHUD/MBProgressHUD.h>

@interface GifCollectionViewCell : UICollectionViewCell <MBProgressHUDDelegate>
- (void)setImageURL:(NSURL *)imageURL;
@end
