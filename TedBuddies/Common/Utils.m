//
//  Utils.m
//  TedBuddies
//
//  Created by Mayank Pahuja on 12/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import "Utils.h"
#include <sys/xattr.h>
#import "UIImage+animatedGIF.h"

@implementation Utils

+(Utils *)sharedInstance
{
    static Utils *_sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[Utils alloc] init];
    });
    
    return _sharedInstance;
}



#pragma mark - alertasur
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message leftButtonTitle:(NSString *)left rightButtonTitle:(NSString *)right selectedButton:(void(^)(NSInteger selected, UIAlertView *aView))block
{
    self.selectedAlertButtonBlock = block;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:[Utils sharedInstance] cancelButtonTitle:left otherButtonTitles:right, nil];
	[alert show];
}
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message buttonArray:(NSArray *)buttonArray selectedButton:(void(^)(NSInteger selected, UIAlertView *aView))block
{
    self.selectedAlertButtonBlock = block;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:[Utils sharedInstance] cancelButtonTitle:nil otherButtonTitles: nil];
    for (NSString *title in buttonArray) {
        [alert addButtonWithTitle:title];
    }
	[alert show];
}

- (void)showAlertWithTextFieldWithTitle:(NSString *)title message:(NSString *)message leftButtonTitle:(NSString *)left rightButtonTitle:(NSString *)right selectedButton:(void(^)(NSInteger selected, UIAlertView *aView))block
{
    self.selectedAlertButtonBlock = block;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:[Utils sharedInstance] cancelButtonTitle:left otherButtonTitles:right,nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.keyboardType = UIKeyboardTypeEmailAddress;
    dispatch_async(dispatch_get_main_queue(), ^{
        [alertView show];
    });
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.selectedAlertButtonBlock)
    {
        self.selectedAlertButtonBlock(buttonIndex,alertView);
    }
}




+ (void)showAlertViewWithMessage:(NSString*)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAPPNAME message:msg delegate:nil
										  cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
}

+ (NSInteger)ageFromDOB:(NSString*)dateOfBirth
{
    NSDateFormatter *dateFormattter = [[NSDateFormatter alloc] init];
    [dateFormattter setDateFormat:@"dd/MM/yyyy"];
    
    NSDate *birthDate = [dateFormattter dateFromString:dateOfBirth];
    
    NSDate *today = [NSDate date];
    NSDateComponents *ageComponents = [[NSCalendar currentCalendar]
                                       components:NSYearCalendarUnit
                                       fromDate:birthDate
                                       toDate:today
                                       options:0];
    return ageComponents.year;
}
#pragma mark - image blur

+ (UIImage*) blur:(UIImage*)theImage withBlurIntensity:(CGFloat)blurIntensity
{
    // ***********If you need re-orienting (e.g. trying to blur a photo taken from the device camera front facing camera in portrait mode)
    // theImage = [self reOrientIfNeeded:theImage];
    
    // create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    
    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:15] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];//create a UIImage for this function to "return" so that ARC can manage the memory of the blur... ARC can't manage CGImageRefs so we need to release it before this function "returns" and ends.
    CGImageRelease(cgImage);//release CGImageRef because ARC doesn't manage this on its own.
    
    return returnImage;
    
}

#pragma mark - Action Sheet
- (void)showActionSheetWithTitle:(NSString *)title buttonArray:(NSArray *)buttonArray selectedButton:(void(^)(NSInteger selected))block
{
    self.selectedActionSheetButtonBlock = block;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (NSString *buttonTitle in buttonArray)
    {
        [actionSheet addButtonWithTitle:buttonTitle];
    }
    
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = buttonArray.count;
    
    [actionSheet showInView:SharedAppDelegate.window.rootViewController.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.selectedActionSheetButtonBlock) {
        self.selectedActionSheetButtonBlock(buttonIndex);
    }
}

#pragma mark-color form hex
+ (UIColor *) colorWithHexString: (NSString *) hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}


#pragma mark - conversion methods

+ (NSString*)convertCentimetersToFeetAndInches:(NSString*)centimeters
{
    CGFloat inch = [centimeters floatValue]*0.393701;
    NSInteger inchInterger = (NSInteger)inch % 12;
    NSInteger feet = (NSInteger)inch / 12;
    return [NSString stringWithFormat:@"%i'%i",feet,inchInterger];
}

+ (NSString*)convertKgToPound:(NSString*)kilograms
{
    
    
    CGFloat pounds = [kilograms floatValue]*2.20462;
    return [NSString stringWithFormat:@"%f",pounds];
}

+ (NSString*)convertFeetAndInchesToCentimeters:(NSString*)feetAndInches
{
    NSArray *feetInchArray = [feetAndInches componentsSeparatedByString:@"'"];
    CGFloat inch = [[feetInchArray objectAtIndex:0] floatValue]*12 + [[feetInchArray objectAtIndex:1] floatValue];
    CGFloat cms = inch * 2.54;
    
    return [NSString stringWithFormat:@"%f",cms];
}

+ (NSString*)convertPoundToKgs:(NSString*)pound
{
    CGFloat kgs = [pound floatValue]*0.453592;
    return [NSString stringWithFormat:@"%f",kgs];
}

#pragma mark - viewcontroller
+ (NSString*) viewControllerBase:(NSString*)baseName
{
    if ([[UIScreen mainScreen] bounds].size.height==568)
    {
        return [NSString stringWithFormat:@"%@",baseName];
    }
    else
    {
        return [NSString stringWithFormat:@"%@_iPhone4",baseName];
    }
}

#pragma mark - validatation
+(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
    
    //
}

+ (BOOL)NSStringIsValidExpression:(NSString *)checkString
{   //@"[A-Z0-9a-z]{4}+ ([0-9]{1,5})";
    NSString *stricterFilterString = @"[A-Za-z]{4}+ ([0-9]{1,5})";
    NSString *emailRegex = stricterFilterString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

+ (BOOL)validateForFloat:(UITextField *)textField string:(NSString *)string allowDigitsBeforeDot:(NSInteger)before allowDigitsAfterDot:(NSInteger)after
{
    
    NSString *charSet = [NSString stringWithFormat:@"0123456789."];
    NSCharacterSet *s = [NSCharacterSet characterSetWithCharactersInString:charSet];
    s = [s invertedSet];
    NSRange r = [string rangeOfCharacterFromSet:s];
    if (r.location == NSNotFound) //Valid as per given set
    {
        NSArray *arrPart = [string componentsSeparatedByString:@"."];
        if (arrPart.count > 2)
        {
            return NO;
        }
        
        NSString *strBeforeDot = [arrPart objectAtIndex:0];
        NSString *strAfterDot = nil;
        if (arrPart.count > 1)
        {
            strAfterDot = [arrPart objectAtIndex:1];
        }
        
        if (strBeforeDot.length > before)
        {
            return NO;
        }
        
        if (strAfterDot.length > after)
        {
            return NO;
        }
        
        return YES;
    }
    return NO;
}

+ (BOOL)isValidNumber:(NSString *)str
{
    BOOL valid;
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:str];
    valid = [alphaNums isSupersetOfSet:inStringSet];
    
    return valid;
}

+ (BOOL)isValidDecimalNumber:(NSString *)str
{
    BOOL valid;
    NSCharacterSet *alphaNums = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:str];
    valid = [alphaNums isSupersetOfSet:inStringSet];
    
    return valid;
}


#pragma mark - Activity Indicator
+ (void)startActivityIndicatorInView:(UIView*)aView withMessage:(NSString*)aMessage
{
    MBProgressHUD *_hud = [MBProgressHUD showHUDAddedTo:aView animated:YES];
    _hud.dimBackground  = NO;
    _hud.labelText      = aMessage;
    //_hud.color = [UIColor colorWithRed:0/255.0f green:114/255.0f blue:184/255.0f alpha:1];
}

+ (void)stopActivityIndicatorInView:(UIView*)aView
{
    [MBProgressHUD hideHUDForView:aView animated:YES];
}

+ (void)startLoaderWithMessage:(NSString *)message
{
//    UIView *view = SharedAppDelegate.window.rootViewController.view;
//    MBProgressHUD *_hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
//    _hud.dimBackground  = NO;
//    _hud.labelText      = message;
    
     [Utils stopLoader];
      UIView *view = SharedAppDelegate.window.rootViewController.view;
     UIImageView *imgViewLoader = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
      NSURL *url = [[NSBundle mainBundle] URLForResource:@"waitLoading" withExtension:@"gif"];
        imgViewLoader.image=[UIImage animatedImageWithAnimatedGIFURL:url];
        [imgViewLoader.layer setCornerRadius:10];
        [imgViewLoader setClipsToBounds:YES];
//        innerPopUpView.backgroundColor=[UIColor whiteColor];
//        [innerPopUpView.layer setShadowOpacity:0.9];
//        [innerPopUpView.layer setShadowRadius:2.0];
    
        [view addSubview:imgViewLoader];
        imgViewLoader.center = view.center;
        imgViewLoader.tag = 30000;
       [view setUserInteractionEnabled:NO];

    
//    [imgViewLoader setImage:[UIImage imageNamed:@"iconApp40.png"]];
//    [imgViewLoader setContentMode:UIViewContentModeScaleAspectFill];
//    [imgViewLoader.layer setCornerRadius:30];
//    [imgViewLoader setClipsToBounds:YES];
//    [view addSubview:imgViewLoader];
//    imgViewLoader.center = view.center;
//    CABasicAnimation *rotation;
//    rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
//    rotation.fromValue = [NSNumber numberWithFloat:0];
//    rotation.toValue = [NSNumber numberWithFloat:( 2 * M_PI)];
//    rotation.duration = 1; // Speed
//    rotation.repeatCount = HUGE_VALF; // Repeat forever. Can be a finite number.
//    [imgViewLoader.layer addAnimation:rotation forKey:@"Spin"];
//    imgViewLoader.tag = 30000;
//    [view setUserInteractionEnabled:NO];
    
   // [Utils startActivityIndicatorInView:view withMessage:@""];

}

+ (void)stopLoader
{
//    UIView *view = SharedAppDelegate.window.rootViewController.view;
//    [MBProgressHUD hideHUDForView:view animated:YES];
    
    UIView *view = SharedAppDelegate.window.rootViewController.view;
    UIImageView *imgViewLoader = (UIImageView*)[view viewWithTag:30000];
    [imgViewLoader removeFromSuperview];
    imgViewLoader = nil;
    [view setUserInteractionEnabled:YES];
    
   // [Utils stopActivityIndicatorInView:view];
}


- (void)startProgressLoaderWithMessage:(NSString *)message progress:(float)progress
{
    if (_progressLoader == nil)
    {
        UIView *view = SharedAppDelegate.window.rootViewController.view;
        _progressLoader = [[MBProgressHUD alloc] initWithView:view];
        [view addSubview:_progressLoader];
        _progressLoader.mode = MBProgressHUDModeDeterminate;
        _progressLoader.dimBackground  = NO;
        [_progressLoader show:YES];
    }
    
    _progressLoader.labelText      = message;
    _progressLoader.progress = progress;
}

- (void)stopProgressLoader
{
    [_progressLoader removeFromSuperview];
    _progressLoader = nil;
}

#pragma mark - Function
+(NSString *)errorMessageForCode:(NSInteger)codeVal
{
    int code = abs(codeVal);
    
    switch (code) {
        case 1:
        {
            return @"Check your internet connection.";
        }
            break;
            
        case 1001:
        {
            return @"The request timed out.";
        }
            break;
            
        default:
            return nil;
            break;
    }
    
    return nil;
}



+ (void)setLeftPadding:(NSArray*)arrayTxt
{
    for (NSInteger i = 0; i < arrayTxt.count; i ++) {
        UITextField *txtField = [arrayTxt objectAtIndex:i];
        UIView *viewLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, txtField.frame.size.height)];
        [txtField setLeftView:viewLeft];
        [txtField setLeftViewMode:UITextFieldViewModeAlways];
    }
}

+ (NSString *)getServerPointMessageInInteger:(NSString *)message
{
    //This case means we have come from new challenge screen
    NSString *numberString;
    
    NSScanner *scanner = [NSScanner scannerWithString:message];
    NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@".0123456789"];
    // Throw away characters before the first number.
    [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
    // Collect numbers.
    [scanner scanCharactersFromSet:numbers intoString:&numberString];
    
    // Result.
    int number = [numberString doubleValue];
    NSString *newMsg = [message stringByReplacingOccurrencesOfString:numberString withString:[@(number) stringValue]];
    
    return newMsg;
}

#pragma mark Date Related Functions

+(NSString *)getLocalTimeFromUtc:(NSString*)dateStr inFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:format];
    NSDate *date=[dateFormatter dateFromString:dateStr];
    [dateFormatter setDateFormat:format];
    
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    return [dateFormatter stringFromDate:date];
    
}

+(NSDate *)getLocalTimeWithDate:(NSDate*)date
{
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: date];
    return [NSDate dateWithTimeInterval:seconds sinceDate: date];
}

+(NSDate *)getUTCTime
{
    NSTimeZone *tz = [NSTimeZone defaultTimeZone];
    NSInteger seconds = -[tz secondsFromGMTForDate: [NSDate date]];
    return [NSDate dateWithTimeInterval: seconds sinceDate: [NSDate date]];
}

+ (NSString *)timeAgo:(NSString *)time withFormat:(NSString*)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    
    NSInteger interval = [[Utils getUTCTime] timeIntervalSinceDate:[formatter dateFromString:time]];
    interval = abs(interval);
    
    if (interval < 60)
    {
        return [NSString stringWithFormat:@"%d sec ago",interval];
    }
    else if(interval>= 60 && interval < 60*60)
    {
        if (interval/60 == 1) {
            return [NSString stringWithFormat:@"%d min ago",interval/60];
        }
        return [NSString stringWithFormat:@"%d mins ago",interval/60];
    }
    else if(interval>= 60*60 && interval < 60*60*24)
    {
        if (interval/60/60 == 1) {
            return [NSString stringWithFormat:@"%d hour ago",interval/60/60];
        }
        return [NSString stringWithFormat:@"%d hours ago",interval/60/60];
    }
    else
    {
        if (interval/60/60/24 == 1) {
            return [NSString stringWithFormat:@"%d day ago",interval/60/60/24];
        }
        return [NSString stringWithFormat:@"%d days ago",interval/60/60/24];
    }
}
+(NSInteger )getCurrentTimeStamp
{
    NSInteger timeInterval=[[NSDate date] timeIntervalSince1970];
    return timeInterval;
}

+ (NSString*)convertSecondsToHoursMinsSecs:(NSString*)secs
{
    if ([secs intValue] > 60)
    {
        if ([secs intValue] > 3600)
        {
            NSInteger minutes = [secs intValue]/60;
            NSInteger seconds = [secs intValue]%60;
            NSInteger hours = minutes / 60;
            minutes = minutes%60;
            return [NSString stringWithFormat:@"%li hrs %li mins %li secs",(long)hours,(long)minutes,(long)seconds];
            
        }
        else
        {
            NSInteger minutes = [secs intValue]/60;
            NSInteger seconds = [secs intValue]%60;
            return [NSString stringWithFormat:@"%li mins %li secs",(long)minutes,(long)seconds];
        }
    }
    else
    {
        return [NSString stringWithFormat:@"%@ secs",secs];
    }
}
+(NSString *)getFormatedTimeForDateString:(NSString *)dateString hourFormat24:(BOOL)hourFormat24
{
    NSDate *givenDate = [Utils dateFromString:dateString];
    givenDate = [Utils getLocalTimeWithDate:givenDate];
//    NSDate *nowDate = [Utils dateFromString:[Utils stringFromDate:[Utils getUTCTime]]];
    NSDate *nowDate = [Utils getLocalTimeWithDate:[NSDate date]];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    //[formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
    
    
    NSDateComponents *components;
    NSInteger days;
    components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit
                                                 fromDate:[formatter dateFromString:[formatter stringFromDate:givenDate]]
                                                   toDate:[formatter dateFromString:[formatter stringFromDate:nowDate]]
                                                  options:0];

    
    days = [components day];
//    NSLog(@"%d",days);
    
    NSString *finalTime = @"";
    
    if (days == 0) {
        
//        NSLog(@"Time in HH:mm");
        NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
        [dayFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        //[dayFormatter setLocale:[NSLocale currentLocale]];
        
        if (hourFormat24) {
            [dayFormatter setDateFormat:@"HH:mm"];
        }
        else {
            [dayFormatter setDateFormat:@"hh:mm a"];
        }
        
        finalTime = [dayFormatter stringFromDate:givenDate];
//        NSLog(@"timeString = %@",finalTime);

    }
    else if (days == 1) {
        
        finalTime = @"Yesterday";
        
    }else if (days >= 2 && days <= 7) {
        
//        NSLog(@"Time in Week Days");
        
        NSDateFormatter *weekdayFormatter = [[NSDateFormatter alloc] init];
        [weekdayFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        //[weekdayFormatter setLocale:[NSLocale currentLocale]];
        [weekdayFormatter setDateFormat:@"EEEE"];
        finalTime = [weekdayFormatter stringFromDate:givenDate];
//        NSLog(@"timeString:%@",finalTime);

    }
    else {
//        NSLog(@"Time in Day Month");
        
        NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
        [monthFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
        //[monthFormatter setLocale:[NSLocale currentLocale]];
        [monthFormatter setDateFormat:@"d"];
        NSString *dayNumber = [monthFormatter stringFromDate:givenDate];
        
        [monthFormatter setDateFormat:@"MMM"];
        NSString *month = [monthFormatter stringFromDate:givenDate];
        
//        if ([[[NSUserDefaults standardUserDefaults] objectForKey:kDateSetting] isEqualToString:@"Day/Month"]) {
//            finalTime = [NSString stringWithFormat:@"%@ %@",dayNumber, month];
//        }
//        else {
            finalTime = [NSString stringWithFormat:@"%@ %@",month, dayNumber];
//            
//        }
//        NSLog(@"timeString:%@",finalTime);
        

    }
    
    return finalTime;
}
+(NSDate *)dateFromString:(NSString*)aStr
{
//    NSLog(@"Date in String = %@", aStr);
    id dtStr = aStr;
    
    if (dtStr == [NSNull null]) {
        aStr = @"0000-00-00 00:00:00";
    }
	
    if (aStr.length < 19) {
        aStr = [aStr stringByAppendingFormat:@"00:00:00"];
    }
    
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    //[dateFormatter setLocale:[NSLocale currentLocale]];
 	[dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
    NSDate *aDate = [dateFormatter dateFromString:aStr];
//    NSLog(@"Date in NSDate = %@",aDate);
	
	return aDate;
}

+(NSString*)stringFromDate:(NSDate*)date
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    //[dateFormatter setLocale:[NSLocale currentLocale]];
	[dateFormatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
   	NSString *strDateTime = [dateFormatter stringFromDate:date];
	
	return strDateTime;
}
#pragma mark - <File Handling>
+ (BOOL)isFileExistAtFolderPath:(NSString *)folderPath fileName:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *folderP = [documentsDirectory stringByAppendingPathComponent:folderPath];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",folderP,fileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        return NO;
    }
    
    return YES;
}

+ (void)createFolderWithPath:(NSString *)folderPath
{
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:folderPath];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:NO attributes:nil error:&error];
    }
}


/*
 * folderPath - This Path is the path inside Document folder of iPhone.
 */

+ (NSString*)getPathForFolderPath:(NSString *)folderPath withFileName:(NSString*)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    
    //Creates Folder at specified path if not already exist
    [Utils createFolderWithPath:folderPath];
    
    NSString *pathToFolder = [documentsDirectory stringByAppendingPathComponent:folderPath];
    NSString *filePath = [pathToFolder stringByAppendingPathComponent:fileName];
    
    return filePath;
}

/*
 This Function will write NSData to a file at path.
 If folder already exist then it simply saves the file
 else it will create the folder then will save the file.
 */
+ (void)saveFileWithData:(NSData *)fileData withFilePath:(NSString*)filePath
{
    // Add attribute for "do not backup"
    u_int8_t b = 1;
    //#include <sys/xattr.h>
    setxattr([filePath fileSystemRepresentation], "com.apple.MobileBackup", &b, 1, 0, 0);
    [fileData writeToFile:filePath atomically:YES];
}

/*
 This Function will write NSData to a file at specified folder and file.
 If folder already exist then it simply saves the file
 else it will create the folder then will save the file.
 */
+ (void)saveFileWithData:(NSData *)fileData inFolder:(NSString*)folder withFileName:(NSString *)filename
{
    NSString *filePath = [Utils getPathForFolderPath:folder withFileName:filename];
    
    // Add attribute for "do not backup"
    u_int8_t b = 1;
    //#include <sys/xattr.h>
    setxattr([filePath fileSystemRepresentation], "com.apple.MobileBackup", &b, 1, 0, 0);
    BOOL writeFlag = [fileData writeToFile:filePath atomically:YES];
    if (writeFlag == FALSE)
    {
        NSLog(@"Failed to write data on Document dir");
    }
}

+ (void)saveVideo:(NSURL*)videoURL withName:(NSString*)videoName toFolder:(NSString*)folderName
{
    [Utils createFolderWithPath:folderName];
    NSData *videoData = [NSData dataWithContentsOfURL:videoURL];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedVideoPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@.mp4",folderName,videoName]];
    
    BOOL success = [videoData writeToFile:savedVideoPath atomically:NO];
    if (success)
    {
        
    }
}
+ (void)clearFromFolder:(NSString *)folderName
{
    NSString *filePath = [Utils getPathForFolderPath:folderName withFileName:@""];
    NSArray *array=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:nil];
    for (NSString *insidePath in array) {
        
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@",filePath,insidePath];
        [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
    }
}

#pragma mark - download image
+ (void)downloadImageForProfileURL:(NSString *)url completion:(void (^)(UIImage *image,NSString *index))block
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        
        NSString *newURL = [url substringToIndex:[url length] - 2];
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:newURL]];
        UIImage *image = [UIImage imageWithData:data];
        NSString *returnIndex=[url substringFromIndex:[url length] - 1];
        //perform task in bg
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //perform in main thread
            
            if (image) {
                block (image,returnIndex);
                
            }
            else
            {
                block (nil,nil);
            }
            
        });
    });
}
+ (void)downloadImageForURL:(NSString *)url completion:(void (^)(UIImage *image))block
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        UIImage *image = [UIImage imageWithData:data];
        
        //perform task in bg
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //perform in main thread
            
            if (image) {
                block (image);
            }
            else
            {
                block (nil);
            }
            
        });
    });
}

+ (void)getDownloadImageForURL:(NSString *)url completion:(void (^)(UIImage *image, BOOL alreadyDownloaded, NSString *filePath))block
{
    
    NSArray *arrComponents = [url componentsSeparatedByString:@"/"];
    NSString *imageName = [arrComponents lastObject];
    
    NSString *path = [Utils getPathForFolderPath:@"Attachment" withFileName:imageName];

    
    if ([[url pathExtension] isEqualToString:@"gif"])
    {
        if ([url containsString:@"giphy.com"])
        {
            imageName=[arrComponents lastObject];
            imageName=[NSString stringWithFormat:@"%@_%@",[arrComponents objectAtIndex:(arrComponents.count-2)],imageName];
            path = [Utils getPathForFolderPath:@"Attachment" withFileName:imageName];
        }
    }
    

    
      UIImage *image = [UIImage imageWithContentsOfFile:path];

    
    if (image)
    {
        block(image, YES, path);
    }
    else
    {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            
            NSString *strURL = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:strURL]];
            [Utils saveFileWithData:data inFolder:@"Attachment" withFileName:imageName];
            UIImage *image = [UIImage imageWithData:data];
            
            //perform task in bg
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //perform in main thread
                
                if (image)
                {
                    block (image,NO,path);
                }
                else
                {
                    block (nil,NO,nil);
                }
            });
        });
    }
}



#pragma mark - TabBar Function

+ (void)setTabBarImage :(NSString *)image
{
    for(UIView *view in SharedAppDelegate.tabBarController.tabBar.subviews)
    {
        if([view isKindOfClass:[UIImageView class]])
        {
            [view removeFromSuperview];
        }
    }
    
    UIImage *img = [UIImage imageNamed:image];
    UIImageView *imgViewTabbar = [[UIImageView alloc] initWithImage:img];
    [SharedAppDelegate.tabBarController.tabBar insertSubview:imgViewTabbar atIndex:0];
}






#pragma mark - in app wale

+ (NSString*)getProductIdentifierForWorkoutId:(NSString*)workoutId
{
    NSString *string = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"products" withExtension:@"json"] encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[string dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    return [dict objectForKey:[NSString stringWithFormat:@"%@",workoutId]];
}

+(NSString*)formatNumber:(NSString*)mobileNumber
{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    NSLog(@"%@", mobileNumber);
    
    int length = [mobileNumber length];
    if(length > 10)
    {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
        NSLog(@"%@", mobileNumber);
        
    }
    
    
    return mobileNumber;
}

@end
