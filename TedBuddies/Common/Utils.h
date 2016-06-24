//
//  Utils.h
//  TedBuddies
//
//  Created by Mayank Pahuja on 12/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Defines.h"

#import "MBProgressHUD.h"
#import "UIImage+ResizeMagick.h"

typedef void(^SelectedAlertButton)(NSInteger selected, UIAlertView *aView);
typedef void(^SelectedActionSheetButton)(NSInteger selected); //@interface ke upar

@interface Utils : NSObject <UIAlertViewDelegate, UIActionSheetDelegate>
{
}

@property (copy, nonatomic) SelectedAlertButton selectedAlertButtonBlock;
@property (copy, nonatomic) SelectedActionSheetButton selectedActionSheetButtonBlock;
@property (strong, nonatomic) MBProgressHUD *progressLoader;


+ (Utils *)sharedInstance;

//Alert Views
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message leftButtonTitle:(NSString *)left rightButtonTitle:(NSString *)right selectedButton:(void(^)(NSInteger selected, UIAlertView *aView))block;
- (void)showAlertWithTextFieldWithTitle:(NSString *)title message:(NSString *)message leftButtonTitle:(NSString *)left rightButtonTitle:(NSString *)right selectedButton:(void(^)(NSInteger selected, UIAlertView *aView))block;
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message buttonArray:(NSArray *)buttonArray selectedButton:(void(^)(NSInteger selected, UIAlertView *aView))block;
+ (void)showAlertViewWithMessage:(NSString*)msg;

//Action Sheets
- (void)showActionSheetWithTitle:(NSString *)title buttonArray:(NSArray *)buttonArray selectedButton:(void(^)(NSInteger selected))block;

+ (UIColor *) colorWithHexString:(NSString *) hex;
+ (NSString*) viewControllerBase:(NSString*)baseName;
+ (BOOL) NSStringIsValidEmail:(NSString *)checkString;

+ (BOOL)NSStringIsValidExpression:(NSString *)checkString;

+ (BOOL)validateForFloat:(UITextField *)textField string:(NSString *)string allowDigitsBeforeDot:(NSInteger)before allowDigitsAfterDot:(NSInteger)after;
+ (BOOL)isValidNumber:(NSString *)str;
+ (BOOL)isValidDecimalNumber:(NSString *)str;
+ (void)startActivityIndicatorInView:(UIView*)aView withMessage:(NSString*)aMessage;
+ (void)stopActivityIndicatorInView:(UIView*)aView;
+ (void)startLoaderWithMessage:(NSString *)message;
+ (void)stopLoader;
- (void)startProgressLoaderWithMessage:(NSString *)message progress:(float)progress;
- (void)stopProgressLoader;

/*  DATE METHODS */
+ (NSDate *)getLocalTimeWithDate:(NSDate*)date;
+ (NSDate *)getUTCTime;
+ (NSString *)getLocalTimeFromUtc:(NSString*)dateStr inFormat:(NSString *)format;
//- (void)implementAdMobInView:(UIView*)viewShow;

+(NSString *)errorMessageForCode:(NSInteger)codeVal;

+ (NSInteger)ageFromDOB:(NSString*)dateOfBirth;



+ (UIImage*)blur:(UIImage*)theImage withBlurIntensity:(CGFloat)blurIntensity;

+ (void)setLeftPadding:(NSArray*)arrayTxt;
+ (NSString *)timeAgo:(NSString *)time withFormat:(NSString*)format;
+ (NSString*)convertCentimetersToFeetAndInches:(NSString*)centimeters;
+ (NSString*)convertKgToPound:(NSString*)kilograms;
+ (NSString*)convertFeetAndInchesToCentimeters:(NSString*)feetAndInches;
+ (NSString*)convertPoundToKgs:(NSString*)pound;
+ (NSString*)convertSecondsToHoursMinsSecs:(NSString*)secs;

+ (NSString*)getProductIdentifierForWorkoutId:(NSString*)workoutId;

+ (void)downloadImageForURL:(NSString *)url completion:(void (^)(UIImage *image))block;
+ (void)downloadImageForProfileURL:(NSString *)url completion:(void (^)(UIImage *image,NSString *index))block;
#pragma mark - <File Handling>
+ (BOOL)isFileExistAtFolderPath:(NSString *)folderPath fileName:(NSString *)fileName;
+ (void)createFolderWithPath:(NSString *)folderPath;
+ (NSString*)getPathForFolderPath:(NSString *)folderPath withFileName:(NSString*)fileName;
+ (void)saveFileWithData:(NSData *)fileData withFilePath:(NSString*)filePath;
+ (void)saveFileWithData:(NSData *)fileData inFolder:(NSString*)folder withFileName:(NSString *)filename;
+ (void)clearFromFolder:(NSString *)folderName;
+ (NSInteger )getCurrentTimeStamp;
+ (NSString *)getServerPointMessageInInteger:(NSString *)message;


+ (void)saveVideo:(NSURL*)videoURL withName:(NSString*)videoName toFolder:(NSString*)folderName;
+ (void)getDownloadImageForURL:(NSString *)url completion:(void (^)(UIImage *image, BOOL alreadyDownloaded, NSString *filePath))block;
+ (void)showStudEBuddiesLoader;

+(NSString *)getFormatedTimeForDateString:(NSString *)dateString hourFormat24:(BOOL)hourFormat24;
#pragma mark - TabBar Method

+ (void)setTabBarImage :(NSString *)image;

+(NSString*)formatNumber:(NSString*)mobileNumber;
@end
