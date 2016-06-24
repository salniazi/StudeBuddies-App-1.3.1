//
//  UIImage+Utility.h
//  PhoniCam
//
//  Created by Ashish Chauhan on 05/06/14.
//  Copyright (c) 2014 TechAhead Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utility)

+ (UIImage *)scaleImage:(UIImage *)image maxWidth:(int)maxWidth maxHeight:(int)maxHeight;

- (UIImage *)generatePhoto;
- (UIImage *)cropImageKeepingFixedwidth:(CGFloat)fWidth;
- (UIImage *)squareImageWithSize:(CGSize)newSize;
- (UIImage *)resizeImageWithSize:(CGSize)newSize;
- (UIImage*)rotateImage;
- (CGFloat) radians:(int)degrees;
- (UIImage *)generateWatermark;
- (UIImage *)croppingimageToRect:(CGRect)rect;
- (UIImage*)imageScaledToSize:(CGSize) newSize;

@end
