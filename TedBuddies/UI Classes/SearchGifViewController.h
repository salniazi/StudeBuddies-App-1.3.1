//
//  SearchGifViewController.h
//  GiphyClient
//
//  Created by Jared Halpern on 9/13/15.
//  Copyright (c) 2015 byteMason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GifDisplayViewController.h"


@interface SearchGifViewController : GifDisplayViewController
- (void)setSearchTerms:(NSString *)searchTerms;
@end
