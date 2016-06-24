//
//  Shared.h
//  
//
//  Created by Vishnu Dayal on 06/01/15.
//  Copyright (c) 2014 TechAhead. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface Shared : NSObject


// Properties
@property (assign,nonatomic)  BOOL isTrue;
@property (nonatomic, strong) UIImage *img;
@property (nonatomic, strong) UIView *viewImg;
@property (nonatomic, strong) UIImageView *imgView;

// Shared object
+(Shared*)sharedInst;
- (void)showImageWithImageName:(NSString*)imageName;
- (void)resetEventValues;
- (void)removeView;

@end
