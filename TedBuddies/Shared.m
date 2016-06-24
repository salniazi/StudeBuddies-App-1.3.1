//
//  Shared.m
//
//
//  Created by Vishnu Dayal on 06/01/15.
//  Copyright (c) 2014 TechAhead. All rights reserved.
//

#import "Shared.h"

@implementation Shared

// Shared instance
+(Shared*)sharedInst
{
    static Shared *sharedInstance = nil;
    static dispatch_once_t oncePedicate;
    dispatch_once(&oncePedicate, ^{
        sharedInstance = [[Shared alloc] init];
    });
    
    return sharedInstance;

}


// Initialize objects
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _viewImg = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [_viewImg setBackgroundColor:[UIColor clearColor]];
        CGRect frame = _viewImg.frame;
        frame.origin.y = 0;
        frame.size.height = [UIScreen mainScreen].bounds.size.height;
        _imgView = [[UIImageView alloc] initWithFrame:frame];
        [_imgView setContentMode:UIViewContentModeScaleAspectFit];
        [_viewImg addSubview:_imgView];
        
    }
    return self;
}

- (void)showImageWithImageName:(NSString*)imageName {
    
    _imgView.image = nil;
    [SharedAppDelegate.window.rootViewController.view addSubview:_viewImg];
    [_imgView setImage:[UIImage imageNamed:imageName]];
}

- (void)removeView{
    
    _imgView.image = nil;
    [_viewImg removeFromSuperview];
    
}

- (void)resetEventValues
{
    _img = nil;
}

@end
