//
//  CreateProfileViewController.m
//  TedBuddies
//
//  Created by Sunil on 08/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import "CreateProfileViewController.h"
#import "PreferenceSettingViewController.h"
#import "HomeViewController.h"
#import "ScheduleClassViewController.h"
#import "UIImage+ImageEffects.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIImage+Utility.h"
#import "Shared.h"
#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>
#import <AWSS3/AWSS3.h>
#import "AWSS3TransferManager.h"


@interface CreateProfileViewController ()
{
    NSMutableArray *arrImages;
}
@property (nonatomic , strong) UIImage *selectedImage;

@property(nonatomic,retain) NSMutableArray *arrayUniversityTemp,*arrayMajorTemp,*arrayCollegeYearTemp;
@property(nonatomic,retain) NSArray *arrayUniversity,*arrayMajor,*arrayCollegeYear;
@property (nonatomic , assign) BOOL uploadSchedule;
@end

@implementation CreateProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.stringA = [[NSString alloc] initWithFormat:@"%@",@"The first NSString A"];
    
    _btnClassSchedule.layer.cornerRadius=3;
    _btnClassSchedule.clipsToBounds=YES;
    
    self.stringB = _stringA;
    NSLog(@"stringB = %@", _stringB); ///// turn on/off this line will make the print out results different
    
    self.stringA = @"The second NSString B";
    NSLog(@"stringB = %@", _stringB);
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                                          
                                                          initWithRegionType:AWSRegionUSEast1
                                                          
                                                          identityPoolId:@"us-east-1:c3570e51-9f71-46d4-82ce-dbf2cca46189"];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc]
                                              
                                              initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;

    isViewDidLoad = YES;
    
   
    //add tutorial screen
//
//    if (![defaults boolForKey:kCreateProfileTutorial]) {
//        
//        [[Shared sharedInst] showImageWithImageName:@"tutorialCreateprofile"];
//        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
//        tapGesture.numberOfTapsRequired = 1;
//        [[Shared sharedInst].viewImg addGestureRecognizer:tapGesture];
//    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden=YES;
   // [self.tabBarController setTabBarHidden:YES];
}
- (void)viewDidAppear:(BOOL)animated
{
    if (isViewDidLoad)
    {
        isViewDidLoad = NO;
        arrayEditImage = [[NSMutableArray alloc]init];
        [self setFonts];
        _library = [[ALAssetsLibrary alloc]init];
        // Do any additional setup after loading the view from its nib.
        [self.tabBarController.tabBar setHidden:YES];
        
        dictClassScheduleData = [[NSMutableDictionary alloc] init];
        [Utils startLoaderWithMessage:kPleaseWait];
        [self callAPIMajorUniversityList:@""];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - gesture recognizer delegates

//- (void)tapView:(UITapGestureRecognizer*)gesture
//{
//    [self.view endEditing:YES];
//    [[Shared sharedInst] removeView];
//    [defaults setBool:true forKey:kCreateProfileTutorial];
//}

-(void)viewDidDisappear:(BOOL)animated
{
    //_uploadSchedule = FALSE;
}
#pragma mark - Other Methods..

-(void) editProfileDetails
{
    
    if (_isEditProfile)
    {
        _txtFieldName.text = [_dictGetEditProfileDetails objectForKeyNonNull:@"buddyName"];
        _txtFieldDob.text = [_dictGetEditProfileDetails objectForKeyNonNull:@"dbo"];
        _txtFieldUniversity.text = [_dictGetEditProfileDetails objectForKeyNonNull:@"university"];
        _txtFieldDegree.text = [_dictGetEditProfileDetails objectForKeyNonNull:@"major"];
//        _txtFieldCollege.text = [_dictGetEditProfileDetails objectForKeyNonNull:@"yearOfCollage"];
        majorId = [_dictGetEditProfileDetails objectForKeyNonNull:@"majorId"];
        universityId = [_dictGetEditProfileDetails objectForKeyNonNull:@"universityId"];
        
        _buddyId = [_dictGetEditProfileDetails objectForKeyNonNull:@"buddyId"];
        
        NSArray *arrProfilePic = [_dictGetEditProfileDetails objectForKeyNonNull:kProfilePicture];
        NSMutableArray *arrEachProfilePic=[[NSMutableArray alloc]init];
        for (NSDictionary *dictProfileImage in arrProfilePic)
        {
            [arrEachProfilePic addObject:[dictProfileImage objectForKey:@"image"]];
        }
        
        imgProfilePic.layer.cornerRadius=imgProfilePic.frame.size.height/2;
        for (int i =0 ; i<[arrEachProfilePic count]; i++)
        {
            UIImageView *imgViewProfileImage = [[UIImageView alloc] initWithFrame:CGRectMake(_scrlViewProfileImages.contentSize.width, 0, 98, 98)];
            [imgViewProfileImage setImageWithURL:[NSURL URLWithString:[arrEachProfilePic objectAtIndex:i]]];
            if (imgViewProfileImage.image) {
                [_scrlViewProfileImages addSubview:imgViewProfileImage];
            }
           for (UIImageView *imgView in _scrlViewProfileImages.subviews)
            {
                if (imgView.xOrigin == _scrlViewProfileImages.contentOffset.x)
                {
//                    _imgCoverBlurImage.image = imgView.image;
                  [self blurImage:imgView.image];
                }
            }
            
            [imgViewProfileImage setContentMode:UIViewContentModeScaleAspectFill];
            [imgViewProfileImage setClipsToBounds:YES];
            [_scrlViewProfileImages setContentSize:CGSizeMake(_scrlViewProfileImages.contentSize.width+98, 98)];
            [_pageControlImages setNumberOfPages:_scrlViewProfileImages.contentSize.width/98];
            [_pageControlImages setCurrentPageIndicatorTintColor:[UIColor darkGrayColor]];
        }
        if (arrEachProfilePic.count > 0)
        {
            [_btnRemoveImage setHidden:NO];
        }
        else
        {
            [_btnRemoveImage setHidden:YES];
        }
//            NSURL *url_img = [NSURL URLWithString:[arrEachProfilePic objectAtIndex:i]];
//            NSLog(@"Show: url_img %@",url_img);
//            // imgProfilePic.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url_img]];
//            //  [imgProfilePic setContentMode:UIViewContentModeScaleAspectFill];
//            imgProfilePic.hidden=true;
//            
//            //
//            UIImageView *imgViewProfileImage = [[UIImageView alloc] initWithFrame:CGRectMake(_scrlViewProfileImages.contentSize.width, 0, 98, 98)];
//            //[[UIImageView alloc] initWithFrame:CGRectMake(_scrlViewProfileImages.contentSize.width, 0, 98, 98)];
//            imgViewProfileImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url_img]];
//            [imgViewProfileImage setClipsToBounds:YES];
//            //imgViewProfileImage.image = [[UIImage imageWithData:[NSData dataWithContentsOfURL:url_img]] applyDarkEffect];
//            
//            
//            [_scrlViewProfileImages addSubview:imgViewProfileImage];
//            
//            
//            [imgViewProfileImage setContentMode:UIViewContentModeScaleAspectFill];
//            [_scrlViewProfileImages setContentSize:CGSizeMake(_scrlViewProfileImages.contentSize.width+98, 98)];
//            [_pageControlImages setNumberOfPages:_scrlViewProfileImages.contentSize.width/98];
//            [_pageControlImages setCurrentPageIndicatorTintColor:kBlueColor];
//            
//            
//            
//            
//            
//            // working code
//        }
        
    }
}


- (void)setFonts
{

    // set Font size
    //[_btnClassSchedule setHidden:_isEditProfile];
    //[_lblClassSchedule setHidden:_isEditProfile];
    [_imgScheduleClassImage setHidden:_isEditProfile];
    [_imgArrow setHidden:_isEditProfile];
    
    [_txtFieldName setFont:FONT_REGULAR(14)];
    [_txtFieldUniversity setFont:FONT_REGULAR(14)];
    [_txtFieldDob setFont:FONT_REGULAR(14)];
    [_txtFieldDegree setFont:FONT_REGULAR(14)];
    [_txtFieldCollege setFont:FONT_REGULAR(14)];
    
//    [_btnRemoveImage.layer setCornerRadius:15];
//    [_btnRemoveImage.layer setBorderColor:[UIColor redColor].CGColor];
//    [_btnRemoveImage.layer setBorderWidth:kButtonBorderWidth];
    
    // set button color
    
   // [_btnClassSchedule.titleLabel setFont:FONT_REGULAR(14)];
    [_btnCreateProfile setTitle:@"Create Profile" forState:UIControlStateNormal];
    [_btnCreateProfile.titleLabel setFont:FONT_REGULAR(14)];
    
    if (_isEditProfile)
    {
        [_btnCreateProfile setTitle:@"Update Profile" forState:UIControlStateNormal];
    }
    
    // scroll View for image
    
    [_scrlViewProfileImages.layer setCornerRadius:49];
    [_scrlViewProfileImages clipsToBounds];
    [_scrlViewProfileImages setPagingEnabled:YES];
    [_scrlViewProfileImages setContentSize:CGSizeMake(0, 0)];
    
    [_btnUploadPic.layer setCornerRadius:_btnUploadPic.frame.size.width/2 ];
    [_btnUploadPic.layer setBorderColor:[UIColor whiteColor].CGColor];
    [_btnUploadPic.layer setBorderWidth:2];
    [_btnUploadPic setClipsToBounds:YES];
    
    
    // set placeholder color
    
    NSAttributedString *strName = [[NSAttributedString alloc] initWithString:@"Name" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
    self.txtFieldName.attributedPlaceholder = strName;
    
    NSAttributedString *strDOB = [[NSAttributedString alloc] initWithString:@"Date Of Birth" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
    self.txtFieldDob.attributedPlaceholder = strDOB;
    NSAttributedString *strUniversity = [[NSAttributedString alloc] initWithString:@"Select University" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
    self.txtFieldUniversity.attributedPlaceholder = strUniversity;
    
    NSAttributedString *strDegree = [[NSAttributedString alloc] initWithString:@"Select Major" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
    self.txtFieldDegree.attributedPlaceholder = strDegree;
    
    //NSAttributedString *strYearOfCollege = [[NSAttributedString alloc] initWithString:@"Upload ClassSchedule" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
    //self.lblClassSchedule.text = strYearOfCollege;
    
    
    // Set BackSwipe Event
    
    UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backSwipeAction)];
    [backSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:backSwipe];
    
    
    
    // Set Default values while loggin in from facebook or twitter
    
    [_txtFieldName setText:[_dictReceivedDetails objectForKey:kName]];
    
    if ([_dictReceivedDetails objectForKey:kAddionalProfilePicture] && [[_dictReceivedDetails objectForKey:kAddionalProfilePicture] isKindOfClass:[NSMutableArray class]])
    {
        
        NSMutableArray *arrAddtionalImg = [[NSMutableArray alloc]initWithArray:[_dictReceivedDetails objectForKey:kAddionalProfilePicture]];
        [_scrlViewProfileImages setContentSize:CGSizeMake(arrAddtionalImg.count*98, 98)];
        
        if ([arrAddtionalImg count]==0) {
            [arrAddtionalImg addObject:[_dictReceivedDetails objectForKey:kProfileImage]];
        }
        arrImages=[[NSMutableArray alloc]init];
        for (int i=0; i<[arrAddtionalImg count]; i++)
        {

            [arrImages addObject:@""];
        
        }
        for (int i=0; i<[arrAddtionalImg count]; i++)
        {
            //        [imgViewProfileImage setImageWithURL:[NSURL URLWithString:[_dictReceivedDetails objectForKey:kProfileImage]]];
            NSString *imgURL=[NSString stringWithFormat:@"%@?%d",[arrAddtionalImg objectAtIndex:i],i];
            
           // [Utils downloadImageForURL:[arrAddtionalImg objectAtIndex:i] completion:^(UIImage *image)
             [Utils downloadImageForProfileURL:imgURL completion:^(UIImage *image, NSString *index) {
                 
                 [arrImages replaceObjectAtIndex:[index intValue] withObject:image];
                 UIImageView *imgViewProfileImage = [[UIImageView alloc] initWithFrame:CGRectMake([index integerValue]*98, 0, 98, 98)];
                 [imgViewProfileImage setImage:image];
                 [_scrlViewProfileImages addSubview:imgViewProfileImage];
                 [imgViewProfileImage setContentMode:UIViewContentModeScaleAspectFill];
                 [imgViewProfileImage setClipsToBounds:YES];
                                  [_pageControlImages setNumberOfPages:_scrlViewProfileImages.contentSize.width/98];
                 [_pageControlImages setCurrentPageIndicatorTintColor:[UIColor darkGrayColor]];
                 for (UIImageView *imgView in _scrlViewProfileImages.subviews)
                 {
                     if (imgView.xOrigin == _scrlViewProfileImages.contentOffset.x)
                     {
                         //                    _imgCoverBlurImage.image = imgView.image;
                         [self blurImage:imgView.image];
                     }
                 }
             }];
            
        }
    }else
    {
        UIImageView *imgViewProfileImage = [[UIImageView alloc] initWithFrame:CGRectMake(_scrlViewProfileImages.contentSize.width, 0, 98, 98)];
        if ([_dictReceivedDetails objectForKey:kProfileImage] && ![[_dictReceivedDetails objectForKey:kProfileImage] isEqualToString:@""])
        {
            //        [imgViewProfileImage setImageWithURL:[NSURL URLWithString:[_dictReceivedDetails objectForKey:kProfileImage]]];
            [Utils downloadImageForURL:[_dictReceivedDetails objectForKey:kProfileImage] completion:^(UIImage *image)
             {
                 [imgViewProfileImage setImage:image];
                 [_scrlViewProfileImages addSubview:imgViewProfileImage];
                 [imgViewProfileImage setContentMode:UIViewContentModeScaleAspectFill];
                 [imgViewProfileImage setClipsToBounds:YES];
                 [_scrlViewProfileImages setContentSize:CGSizeMake(_scrlViewProfileImages.contentSize.width+98, 98)];
                 [_pageControlImages setNumberOfPages:_scrlViewProfileImages.contentSize.width/98];
                 [_pageControlImages setCurrentPageIndicatorTintColor:[UIColor darkGrayColor]];
                 for (UIImageView *imgView in _scrlViewProfileImages.subviews)
                 {
                     if (imgView.xOrigin == _scrlViewProfileImages.contentOffset.x)
                     {
                         //                    _imgCoverBlurImage.image = imgView.image;
                         [self blurImage:imgView.image];
                     }
                 }
             }];
            
        }

    }
   

    
    

}

// Apply Validation

- (BOOL)isValid
{
    
    if(_txtFieldName.text.length == 0)
    {
        msgString = @"Don't forget to enter your name";
        return NO;
    }
    
    else if(_txtFieldDob.text.length == 0)
    {
        msgString = @"Don't forget to enter your DOB";
        return NO;
    }
    
    else if(_txtFieldUniversity.text.length == 0)
    {
        msgString = @"Don't forget to enter your University";
        return NO;
    }
    
    else if(_txtFieldDegree.text.length == 0)
    {
        msgString = @"Don't forget to enter your Major";
        return NO;
    }
    //newchange
//    else if(_txtFieldCollege.text.length == 0)
//    {
//        msgString = @"Don't forget to enter year of college";
//        return NO;
//    }
    
//    if (dictScheduleDetails == nil && !_isEditProfile)
//    {
//        msgString = @"Don't forget to schedule a class";
//        return NO;
//    }
    
    // Load All Profile Pic in Array/........
    
    NSMutableArray *arrImages = [[NSMutableArray alloc] init];
    for (UIImageView *imgView in _scrlViewProfileImages.subviews)
    {
        if (imgView.image)
        {
            [arrImages addObject:imgView.image];
        }
        
    }
    if (arrImages.count == 0)
    {
        msgString = @"Please choose atleast one image.";
        return NO;
    }
    return YES;
}


- (void)blurImage:(UIImage*)img
{
  CIContext *context = [CIContext contextWithOptions:nil];
  CIImage *inputImage = [CIImage imageWithCGImage:img.CGImage];
  
  // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
  CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
  if (inputImage != nil)
    [filter setValue:inputImage forKey:kCIInputImageKey];
  [filter setValue:[NSNumber numberWithFloat:5.0] forKey:@"inputRadius"];
  CIImage *result = [filter valueForKey:kCIOutputImageKey];
  
  // CIGaussianBlur has a tendency to shrink the image a little,
  // this ensures it matches up exactly to the bounds of our original image
  CGImageRef cgImage = nil;
  @try
  {
    if (result != nil && inputImage!= nil && context!= nil)
    {
      cgImage  = [context createCGImage:result fromRect:[inputImage extent]];
      
    }else
      cgImage = nil;
    
  }
  @catch (NSException *exception) {
    cgImage = nil;
  }
  @finally {
    
  }
  
  UIImage *imgRef = nil;
  if (cgImage != nil)
  {
    imgRef = [[UIImage alloc]initWithCGImage:cgImage];
    self.imgCoverBlurImage.image = imgRef;
    CGImageRelease(cgImage);
    
    
  }
  else
  {
    self.imgCoverBlurImage.image = imgRef;
  }
}

#pragma mark - gesture recognizer action

- (void)backSwipeAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tappedView
{
    [self.view endEditing:YES];
}

#pragma mark - textfield

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [_scrlViewMain setContentSize:CGSizeMake(320, _scrlViewMain.height+200)];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    if (textField.frame.origin.y+textField.frame.size.height > _scrlViewMain.frame.size.height-360)
    {
        isTextField = YES;
        [_scrlViewMain setTransform:CGAffineTransformMakeTranslation(0, -(textField.frame.origin.y+textField.frame.size.height - _scrlViewMain.frame.size.height+360))];
    }
    [UIView commitAnimations];
    
    if ([textField isEqual:_txtFieldDob])
    {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] ;
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setYear:1990];
        [components setMonth:1];
        [components setDay:1];
        NSDate *defualtDate = [calendar dateFromComponents:components];
        _datePicker.date = defualtDate;
        _datePicker.maximumDate = [NSDate date];
        textField.inputView = _datePicker;
        textField.inputAccessoryView = _toolBarPicker;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [_scrlViewMain setContentSize:CGSizeMake(320, _scrlViewMain.height)];
    
    isTextField = NO;
    
    if (textField == _txtFieldDegree)
    {
        [_tblViewMajor setHidden:YES];
    }
    
    if (textField == _txtFieldUniversity)
    {
        [_tblViewUniversity setHidden:YES];
    }
    
    if(textField == _txtFieldCollege)
    {
        [_tblCollegeYear setHidden:YES];
    }
    
    [self performSelector:@selector(resignTextFields) withObject:nil afterDelay:0.1];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if (textField == _txtFieldUniversity)
    {
        isMajor = NO;
        NSString *universityName = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (universityName.length > 0)
        {
            //[self callAPIMajorUniversityList:universityName];
        }
        [self searchFilter:textField string:universityName];
        
        
    }
    
    else if (textField == _txtFieldDegree)
    {
        isMajor = YES;
        NSString *majorName = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (majorName.length > 0)
        {
            //[self callAPIMajorUniversityList:majorName];
        }
        [self searchFilter:textField string:majorName];
        
    }
//    else if (textField == _txtFieldCollege)
//    {
//        isMajor = YES;
//        NSString * collegeYear = [textField.text stringByReplacingCharactersInRange:range withString:string];
//        [self searchFilter:textField string:collegeYear];
//    }
    return YES;
}

- (void)resignTextFields
{
    if (!isTextField)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.4];
        
        [_scrlViewMain setTransform:CGAffineTransformIdentity];
        [UIView commitAnimations];
    }
}

#pragma mark - button action

- (IBAction)btnPrefSetting:(id)sender
{
    PreferenceSettingViewController *settingViewC = [[PreferenceSettingViewController alloc]initWithNibName:@"PreferenceSettingViewController" bundle:nil];
    settingViewC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:settingViewC animated:YES];
}


- (IBAction)btnShowYearTapped:(UIButton *)sender
{
    [_tblCollegeYear setHidden:NO];
}

- (IBAction)btnScheduleClassTapped:(UIButton *)sender
{
    [self.view endEditing:YES];
   
//    _uploadSchedule = TRUE;
//    [self openActionSheet];
//    ScheduleClassViewController *scheduleClass = [[ScheduleClassViewController alloc] initWithNibName:@"ScheduleClassViewController" bundle:Nil];
//    scheduleClass.delegate = self;
//    [scheduleClass setDictClassScheduleData:[dictScheduleDetails mutableCopy]];
//    //    scheduleClass.dictClassScheduleData = [dictScheduleDetails mutableCopy];
//    [self.navigationController pushViewController:scheduleClass animated:YES];
    
    
    
    
}


- (IBAction)btnCreateProfileTapped:(UIButton *)sender
{
    [self.view endEditing:YES];
    if ([self isValid])
    {
        NSString* userID = [defaults objectForKey:kUserId];
        [dictClassScheduleData setObject:userID forKey:kUserId];
        NSLog(@"%@",_dictReceivedDetails);
//        NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
//                                  
//                                  majorId,kMajorId,
//                                  _txtFieldDegree.text,kMajorName,
//                                  _isEditProfile?@"":[dictScheduleDetails objectForKeyNonNull:kSectionName],kSectionName,
//                                  _isEditProfile?@"":[dictScheduleDetails objectForKeyNonNull:kSectionId],kSectionId,
//                                  universityId,kUniversityId,
//                                  _txtFieldUniversity.text,kUniversityName,
//                                  _txtFieldName.text,kName,
//                                  _txtFieldDob.text,kDob,
//                                  collegeYearId,kYearofCollage,
//                                  _isEditProfile?@"":[dictScheduleDetails objectForKeyNonNull:kCourseId],kCourseId,
//                                  _isEditProfile?@"":[dictScheduleDetails objectForKeyNonNull:kCourseNo],kCourseNo,
//                                  _isEditProfile?[[NSDictionary alloc] init]:dictScheduleDetails,kObjSchecdule,
//                                  userID,kUserId,
//                                  
//                                  nil];
        bool isSeduale;
        if (dictScheduleDetails)
        {
            isSeduale=YES;
        }
        else
        {
            isSeduale=NO;
        }
        NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                                  
                                  majorId?majorId:@"4",kMajorId,
                                  _txtFieldDegree.text,kMajorName,
                                  _isEditProfile?@"":isSeduale?[dictScheduleDetails objectForKeyNonNull:kSectionName]:@"",kSectionName,
                                  _isEditProfile?@"":isSeduale?[dictScheduleDetails objectForKeyNonNull:kSectionId]:@"",kSectionId,
                                  universityId?universityId:@"4",kUniversityId,
                                  _txtFieldUniversity.text,kUniversityName,
                                  _txtFieldName.text,kName,
                                  _txtFieldDob.text,kDob,
                                  collegeYearId?collegeYearId:@"4",kYearofCollage,
                                  _isEditProfile?@"":isSeduale?[dictScheduleDetails objectForKeyNonNull:kCourseId]:@"",kCourseId,
                                  _isEditProfile?@"":isSeduale?[dictScheduleDetails objectForKeyNonNull:kCourseNo]:@"",kCourseNo,
                                  _isEditProfile?[[NSDictionary alloc] init]:isSeduale?dictScheduleDetails:[[NSDictionary alloc] init],kObjSchecdule,
                                  userID,kUserId,
                                  
                                  nil];
        
        [defaults setValue:universityId forKey:kUniversityId];
        [defaults setValue:_txtFieldUniversity.text forKey:kUniversityName];


        [self callAPICreateProfile:dictSend];
        
        
    }
    else
    {
        [Utils showAlertViewWithMessage:msgString];
    }
    
}

- (IBAction)btnUploadImageTapped:(UIButton *)sender
{
    [self.view endEditing:YES];
    if (_scrlViewProfileImages.contentSize.width >= 98*5)
    {
        [Utils showAlertViewWithMessage:@"You have already uploaded 5 Images."];
    }
    else
    {
        _uploadSchedule = FALSE;
        [self performSelector:@selector(openActionSheet) withObject:nil afterDelay:0.2];
    }
}

- (IBAction)btnRemoveImageTapped:(UIButton *)sender
{
    [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"Are you sure you want to delete this picture?" leftButtonTitle:@"Delete" rightButtonTitle:@"Cancel" selectedButton:^(NSInteger selected, UIAlertView *aView)
    {
        if (selected == 0)
        {
            NSInteger indexProfileImage = _scrlViewProfileImages.contentOffset.x/_scrlViewProfileImages.width;
            NSInteger currentIndex = 0;
            for (UIImageView *imgView in _scrlViewProfileImages.subviews)
            {
                
                if (currentIndex > indexProfileImage)
                {
                    imgView.xOrigin = imgView.xOrigin-_scrlViewProfileImages.width;
                }
                currentIndex ++;
                
            }
            currentIndex = 0;
            for (UIImageView *imgView in _scrlViewProfileImages.subviews)
            {
                if (currentIndex == indexProfileImage)
                {
                    [imgView removeFromSuperview];
                    break;
                }
                currentIndex ++;
                
            }
            _scrlViewProfileImages.contentSize = CGSizeMake(_scrlViewProfileImages.contentSize.width-_scrlViewProfileImages.width,_scrlViewProfileImages.height);
            _scrlViewProfileImages.contentOffset = CGPointMake(0, 0);
            [_pageControlImages setNumberOfPages:_scrlViewProfileImages.contentSize.width/98];
            [_pageControlImages setCurrentPage:0];
            
            for (UIImageView *imgView in _scrlViewProfileImages.subviews)
            {
                if (imgView.xOrigin == _scrlViewProfileImages.contentOffset.x)
                {
//                    _imgCoverBlurImage.image = imgView.image;
                  [self blurImage:imgView.image];
                }
            }
            
            if (_scrlViewProfileImages.contentSize.width < _scrlViewProfileImages.width)
            {
                [_btnRemoveImage setHidden:YES];
                _imgCoverBlurImage.image = nil;
            }
            
        }
        
    }];
}

- (IBAction)btnScheduleTapped:(id)sender
{
        
    [self.view endEditing:YES];
     [SharedAppDelegate btnScheduleTapped:sender];
//    _uploadSchedule = TRUE;
//    [self openActionSheet];
}

- (IBAction)pickerDateChanged:(UIDatePicker *)sender
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSString *dob = [formatter stringFromDate:sender.date];
    
    _txtFieldDob.text = dob;
}

- (IBAction)pickerDoneTapped:(UIBarButtonItem *)sender
{
    [self.view endEditing:YES];
}

- (void)openActionSheet
{
    [[Utils sharedInstance] showActionSheetWithTitle:@"" buttonArray:@[@"Camera",@"Photo Library"]     selectedButton:^(NSInteger selected)
     {
         
         DLog(@"Selected Action sheet button = %ld",(long)selected);
         switch (selected)
         {
             case 0:
             {
                 [self openImageCamera];
             }
                 break;
             case 1:
             {
                 [self openPhotoLibrary];
             }
                 break;
                 
             default:
                 break;
         }
         
     }];
}

#pragma mark - web service

- (void)callAPIMajorUniversityList:(NSString*)name
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              name,kSearchText,
                              nil];
    
    [Connection callServiceWithName:kGetMajorUniversityList postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         [Utils stopLoader];
         if (response)
         {
             [self callAPIGetCollageYear:@""];
             
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 //if (isMajor)
                 // {
                 _arrayMajor = nil;
                 _arrayMajor = [[NSArray alloc] initWithArray:[[response objectForKeyNonNull:kResult] objectForKeyNonNull:kLstMajor]];
                 _arrayMajorTemp=[NSMutableArray arrayWithArray:_arrayMajor];
                 
                 
                 // [_tblViewMajor reloadData];
                 //}
                 //else
                 //{
                 _arrayUniversity = nil;
                 _arrayUniversity = [[NSArray alloc] initWithArray:[[response objectForKeyNonNull:kResult] objectForKeyNonNull:kLstUniversity]];
                 //[_tblViewUniversity setHidden:NO];
                 //[_tblViewUniversity reloadData];
                 _arrayUniversityTemp=[NSMutableArray arrayWithArray:_arrayUniversity];
                 
                 // }
                 

             }
         }
     }];
}

- (void)callAPICreateProfile:(NSDictionary*)dictSend
{
    if (!arrImages) {
        NSInteger indexProfileImage = _scrlViewProfileImages.contentOffset.x/_scrlViewProfileImages.width;
        arrImages = [[NSMutableArray alloc] init];
        for (UIImageView *imgView in _scrlViewProfileImages.subviews)
        {
            if (imgView.image)
            {
                [arrImages addObject:[imgView.image generatePhoto]];
            }
            
        }
        if (arrImages.count>2)
        {
              [arrImages exchangeObjectAtIndex:0 withObjectAtIndex:indexProfileImage];
        }
        
      
    }
    
    
    
    [Utils startLoaderWithMessage:@""];
    
    [Connection callServiceWithImages:arrImages params:dictSend serviceIdentifier:kCreateProfileApp callBackBlock:^(id response, NSError *error)
     {
         [Utils stopLoader];
         [defaults setObject:_txtFieldUniversity.text forKey:kUniversityName];
         NSLog(@"%@",[defaults valueForKey:kUniversityName]);
         [defaults setValue:universityId forKey:kUniversityId];
          NSLog(@"%@",[defaults valueForKey:kUniversityId]);
         
         
         if (_isEditProfile)
         {
             SharedAppDelegate.isProfileUpdate=true;
             [self.navigationController popViewControllerAnimated:YES];
         }
         else
         {
             if ([[response objectForKey:kSuccess] boolValue] == true)
             {
                 [defaults setBool:YES forKey:kIsLoggedIn];
                 [defaults setBool:YES forKey:kIsFromCreateProfile];
                 [defaults synchronize];
                  [defaults setObject:@"True" forKey:kisCreated];
                 //[SharedAppDelegate addTabBarScreen];
                 PreferenceSettingViewController *vcPreferenceSetting = [[PreferenceSettingViewController alloc] initWithNibName:@"PreferenceSettingViewController" bundle:nil];
                 vcPreferenceSetting.isFirstTime=YES;
                   [self.navigationController pushViewController:vcPreferenceSetting animated:YES];
             }
         }
         
         
         
     }];
}

-(void)callAPIGetCollageYear:(NSString*)name
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
                              nil];
    [Utils startLoaderWithMessage:@""];
    
    [Connection callServiceWithName:kGetCollageYear postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         [Utils stopLoader];
         if (response)
         {
             [self editProfileDetails];
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 _arrayCollegeYear = nil;
                 _arrayCollegeYear = [[NSArray alloc] initWithArray:[response objectForKeyNonNull:kResult]];
                 _arrayCollegeYearTemp=[NSMutableArray arrayWithArray:_arrayCollegeYear];
                 [_tblCollegeYear reloadData];

             }
             if([[_dictGetEditProfileDetails objectForKeyNonNull:@"yearOfCollage"] length] > 0)
             {
             for (int i = 0; i<_arrayCollegeYearTemp.count; i++)
             {
                 if ([[[_arrayCollegeYearTemp objectAtIndex:i] objectForKey:@"yearId"] isEqualToString:[_dictGetEditProfileDetails objectForKeyNonNull:@"yearOfCollage"]])
                 {
                     _txtFieldCollege.text = [[_arrayCollegeYearTemp objectAtIndex:i] objectForKey:@"yearName"];
                     collegeYearId = [[_arrayCollegeYearTemp objectAtIndex:i] objectForKey:@"yearId"];
                 }
             }
                 
            }
         }
     }];
}
#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 21)
    {
        return [_arrayUniversityTemp count];
    }
    if (tableView.tag == 22)
    {
        return [_arrayMajorTemp count];
    }
    if (tableView.tag == 23)
    {
        return [_arrayCollegeYearTemp count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if(tableView == _tblViewUniversity)
    {
        cell.textLabel.text = [[_arrayUniversityTemp objectAtIndex:indexPath.row] objectForKeyNonNull:@"university"];
        
    }
    if(tableView == _tblViewMajor)
    {
        cell.textLabel.text = [[_arrayMajorTemp objectAtIndex:indexPath.row] objectForKeyNonNull:@"major"];
        
    }
    if(tableView == _tblCollegeYear)
    {
        cell.textLabel.text = [[_arrayCollegeYearTemp objectAtIndex:indexPath.row] objectForKeyNonNull:@"yearName"];
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tblViewUniversity)
    {
        [_tblViewUniversity setHidden:YES];
        _txtFieldUniversity.text = [[_arrayUniversityTemp objectAtIndex:indexPath.row] objectForKeyNonNull:@"university"];
        universityId = [[_arrayUniversityTemp objectAtIndex:indexPath.row] objectForKeyNonNull:@"universityId"];
        
    }
    if (tableView == _tblViewMajor)
    {
        [_tblViewMajor setHidden:YES];
        _txtFieldDegree.text = [[_arrayMajorTemp objectAtIndex:indexPath.row] objectForKeyNonNull:@"major"];
        majorId = [[_arrayMajorTemp objectAtIndex:indexPath.row] objectForKeyNonNull:@"majorId"];
        
    }
    if (tableView == _tblCollegeYear)
    {
        [_tblCollegeYear setHidden:YES];
        _txtFieldCollege.text = [[_arrayCollegeYearTemp objectAtIndex:indexPath.row] objectForKeyNonNull:@"yearName"];
        collegeYearId = [[_arrayCollegeYearTemp objectAtIndex:indexPath.row] objectForKeyNonNull:@"yearId"];
        
    }
}

#pragma mark - schedule delegate

- (void)scheduleDetails:(NSDictionary *)dictSendInfo
{
    dictScheduleDetails = [[NSDictionary alloc] initWithDictionary:dictSendInfo];
    [Utils showAlertViewWithMessage:@"You can also schedule multiple classes after profile completion"];
}

#pragma mark - UIImagePicker Functions and Delegate

- (void)openPhotoLibrary
{
    _imagePicker = nil;
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _imagePicker.delegate = self;
    
    [self presentViewController:_imagePicker animated:YES completion:NULL];
}

- (void)openImageCamera
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        DLog(@"Camera not available");
        msgString = @"Camera not available";
        return ;
    }
    _imagePicker = nil;
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imagePicker.editing = NO;
    _imagePicker.delegate = self;
    
    [self presentViewController:_imagePicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    
    _selectedImage = (UIImage*)[info objectForKeyNonNull:UIImagePickerControllerOriginalImage];

    /*
    if ([info valueForKey:UIImagePickerControllerReferenceURL])
    {
        
        ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
        [assetLibrary assetForURL:[info valueForKey:UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            Byte *buffer = (Byte*)malloc(rep.size);
            NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
            NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];//this is NSData may be what you want
            UIImage *image = [UIImage imageWithData:data];
            
            UIImageView *imgViewProfileImage = [[UIImageView alloc] initWithFrame:CGRectMake(_scrlViewProfileImages.contentSize.width, 0, 98, 98)];
            imgViewProfileImage.image = image;
            
//            _imgCoverBlurImage.image = [image applyDarkEffect];
//            _imgCoverBlurImage.image = imgViewProfileImage.image;
          [self blurImage:imgViewProfileImage.image];
            
            [_scrlViewProfileImages addSubview:imgViewProfileImage];
            
            
            [imgViewProfileImage setContentMode:UIViewContentModeScaleAspectFill];
            [imgViewProfileImage setClipsToBounds:YES];
            [_scrlViewProfileImages setContentSize:CGSizeMake(_scrlViewProfileImages.contentSize.width+98, 98)];
            [_scrlViewProfileImages setContentOffset:CGPointMake(_scrlViewProfileImages.contentSize.width-98, 0)];
            [_pageControlImages setNumberOfPages:_scrlViewProfileImages.contentSize.width/98];
            [_pageControlImages setCurrentPage:_scrlViewProfileImages.contentSize.width/98];
            [_pageControlImages setCurrentPageIndicatorTintColor:kBlueColor];
            
            [_btnRemoveImage setHidden:NO];
        }failureBlock:^(NSError *err)
        {
         NSLog(@"Error: %@",[err localizedDescription]);
        }];
    }
    
    else
    {
        

//        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
//        dispatch_async(queue, ^{
//            [_library saveImage:image toAlbum:kAPPNAME withCompletionBlock:^(NSError *error)
//             {
//                 
//             }];
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//                // do your main thread task here
//            });
//        });
        
        
    }
    */
    
    
    if(_uploadSchedule)
    {
        if(_selectedImage != nil){
            ImageCropViewController *controller = [[ImageCropViewController alloc] initWithImage:_selectedImage];
            self.navigationController.navigationBarHidden = NO;
            controller.delegate = self;
            controller.blurredBackground = YES;
            [self.navigationController pushViewController:controller animated:NO];
        }
    }
    else
    {
        
        
        RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:_selectedImage];
        imageCropVC.delegate = self;
        [self.navigationController pushViewController:imageCropVC animated:NO];
        
//        ImageCropViewController *controller = [[ImageCropViewController alloc] initWithImage:_selectedImage];
//        self.navigationController.navigationBarHidden = NO;
//        controller.delegate = self;
//        controller.blurredBackground = YES;
//        [self.navigationController pushViewController:controller animated:NO];

    }
}
// Crop image has been canceled.
- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

// The original image has been cropped.
- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect
{
    UIImageView *imgViewProfileImage = [[UIImageView alloc] initWithFrame:CGRectMake(_scrlViewProfileImages.contentSize.width, 0, 98, 98)];
    imgViewProfileImage.image = croppedImage;
    //        _imgCoverBlurImage.image = [image applyDarkEffect];
    //        _imgCoverBlurImage.image = imgViewProfileImage.image;
    [self blurImage:imgViewProfileImage.image];
    [_scrlViewProfileImages addSubview:imgViewProfileImage];
    [imgViewProfileImage setContentMode:UIViewContentModeScaleAspectFill];
    [imgViewProfileImage setClipsToBounds:YES];
    [_scrlViewProfileImages setContentSize:CGSizeMake(_scrlViewProfileImages.contentSize.width+98, 98)];
    [_scrlViewProfileImages setContentOffset:CGPointMake(_scrlViewProfileImages.contentSize.width-98, 0)];
    [_pageControlImages setNumberOfPages:_scrlViewProfileImages.contentSize.width/98];
    [_pageControlImages setCurrentPage:_scrlViewProfileImages.contentSize.width/98];
    [_pageControlImages setCurrentPageIndicatorTintColor:[UIColor darkGrayColor]];
    [_btnRemoveImage setHidden:NO];

   
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)ImageCropViewController:(ImageCropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage{
    _selectedImage = croppedImage;
    
    if (!_uploadSchedule)
    {
        UIImageView *imgViewProfileImage = [[UIImageView alloc] initWithFrame:CGRectMake(_scrlViewProfileImages.contentSize.width, 0, 98, 98)];
        imgViewProfileImage.image = croppedImage;
        //        _imgCoverBlurImage.image = [image applyDarkEffect];
        //        _imgCoverBlurImage.image = imgViewProfileImage.image;
        [self blurImage:imgViewProfileImage.image];
        [_scrlViewProfileImages addSubview:imgViewProfileImage];
        self.navigationController.navigationBarHidden = YES;
        
        [[self navigationController] popViewControllerAnimated:YES];

    }
    else
    {
        self.navigationController.navigationBarHidden = YES;
        
        [[self navigationController] popViewControllerAnimated:YES];
        double delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSLog(@"Do some work");
            
            // creating naem of image
            NSDate *now = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
            
            dateFormatter.dateFormat = @"MM-dd-yyy";
            NSString *dates=[dateFormatter stringFromDate:now];
            
            dateFormatter.dateFormat = @"hh-mm-ss";
            NSString *times=[dateFormatter stringFromDate:now];
            
            
            NSString *imageName = [NSString stringWithFormat:@"%@_%@_%@_%@.jpg",[defaults objectForKey:kUserId],[defaults objectForKey:kUniversityId],dates,times];

            
            [self createProgressUploadingView];
            
            NSString *uploadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:imageName];
            NSData *imageData = UIImagePNGRepresentation(croppedImage);
            [imageData writeToFile:uploadingFilePath atomically:YES];
            NSURL *uploadingFileURL = [NSURL fileURLWithPath:uploadingFilePath];
            AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
            AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
            uploadRequest.bucket = @"s3-uploadschedule";
            //uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
           uploadRequest.key = [NSString stringWithFormat:@"Schedule_iOSApp/%@",imageName];
            uploadRequest.body = uploadingFileURL;
            //uploadRequest.contentLength = [NSNumber numberWithUnsignedLongLong:fileSize];
            uploadRequest.contentType = @"image/jpg";
            
            __weak CreateProfileViewController *weakSelf = self;
            uploadRequest.uploadProgress = ^(int64_t bytesSent , int64_t totalBytesSent , int64_t totalBytesExpectedToSent)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    weakSelf.amountUploaded = totalBytesSent;
                    weakSelf.fileSize = totalBytesExpectedToSent;
                    [weakSelf update];
                });
                
            };
            [[transferManager upload:uploadRequest] continueWithBlock:^id(AWSTask *task) {
                // Do something with the response
                NSLog(@"task = %@",task);
                NSLog(@"https://s3.amazonaws.com/s3-uploadschedule/");
                dispatch_async(dispatch_get_main_queue(), ^{
                    //_uploadSchedule = FALSE;
                    [self removeProgressUploadingView];
                    if([defaults boolForKey:kiisclassuploaded])
                    {
                        UIImageView  *blueCircalTick = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
                        [blueCircalTick setImage:[UIImage imageNamed:@"BlueCircleTick"]];
                        blueCircalTick.backgroundColor=[UIColor whiteColor];
                        blueCircalTick.layer.cornerRadius=75;
                        blueCircalTick.clipsToBounds=YES;
                        blueCircalTick.center = self.view.center;
                        
                        [self.view addSubview:blueCircalTick];
                        
                        [self.view bringSubviewToFront:blueCircalTick];
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            
                            [blueCircalTick removeFromSuperview];
                        });

                    }
                    else
                    {
                        
                        [Utils showAlertViewWithMessage:[NSString stringWithFormat:@"Congrats!! You have been selected to unlock %@. Give us 24 hrs to review and accept your %@ class schedule!",_txtFieldUniversity.text,_txtFieldUniversity.text]];
                    }
                   //[defaults setBool:TRUE forKey:kShowUploadSchedule];
                });
                return nil;
            }];
        });

    }
    

}

-(void)update
{
    [_progresslabel setText:[NSString stringWithFormat:@"Uploading : %.0f%%",((float)self.amountUploaded/(float)self.fileSize) * 100]];
}

-(void)createProgressUploadingView
{
    _loadingBg = [[UIView alloc] initWithFrame:self.view.frame];
   [ _loadingBg setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.5]];
    [self.view addSubview:_loadingBg];
    
    _progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 50)];
    _progressView.center = self.view.center;
    [_progressView setBackgroundColor:[UIColor whiteColor]];
    [_loadingBg addSubview:_progressView];
    
    _progresslabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 50)];
    [_progresslabel setTextAlignment:NSTextAlignmentCenter];
    [_progressView addSubview:_progresslabel];
    
    [_progresslabel setText:@"Uploading :"];
    
}

-(void)removeProgressUploadingView
{
    [_loadingBg removeFromSuperview];
    
}

- (void)ImageCropViewControllerDidCancel:(ImageCropViewController *)controller{
    if(!_uploadSchedule)
    {
        UIImageView *imgViewProfileImage = [[UIImageView alloc] initWithFrame:CGRectMake(_scrlViewProfileImages.contentSize.width, 0, 98, 98)];
        imgViewProfileImage.image = _selectedImage;
        //        _imgCoverBlurImage.image = [image applyDarkEffect];
        //        _imgCoverBlurImage.image = imgViewProfileImage.image;
        [self blurImage:imgViewProfileImage.image];
        [_scrlViewProfileImages addSubview:imgViewProfileImage];
    }
    
    self.navigationController.navigationBarHidden = YES;
    
    [[self navigationController] popViewControllerAnimated:YES];
    
}

#pragma mark - scrollview methods
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == _scrlViewProfileImages)
    {
        [_pageControlImages setCurrentPage:scrollView.contentOffset.x/98];
        
        for (UIImageView *imgView in scrollView.subviews)
        {
            if (imgView.xOrigin == scrollView.contentOffset.x)
            {
//                _imgCoverBlurImage.image = imgView.image;
              [self blurImage:imgView.image];
            }
        }

        
    }
    
}

#pragma mark Search

-(void)searchFilter:(UITextField *)textField string:(NSString *)string
{
    _arrayMajorTemp=[NSMutableArray arrayWithArray:_arrayMajor];
    _arrayUniversityTemp=[NSMutableArray arrayWithArray:_arrayUniversity];
    
    if(string.length==0)
    {
        [_tblViewMajor reloadData];
        [_tblViewUniversity reloadData];
        return;
    }
    
    if(textField==_txtFieldUniversity)
    {
        NSPredicate *predicate = [NSPredicate
                                  predicateWithFormat:@"university CONTAINS[cd] %@ ",
                                  string
                                  ];
        
        [_arrayUniversityTemp filterUsingPredicate:predicate];
        
        if(_arrayUniversityTemp.count>0)
        {
            _tblViewUniversity.hidden=NO;
            
        }
        else
        {
            _tblViewUniversity.hidden=YES;
            
        }
        [_tblViewUniversity reloadData];
        
    }
    
    else if (textField==_txtFieldDegree)
    {
        NSPredicate *predicate = [NSPredicate
                                  predicateWithFormat:@"major CONTAINS[cd] %@ ",
                                  string
                                  ];
        _tblViewMajor.hidden=NO;
        [_arrayMajorTemp filterUsingPredicate:predicate];
        
        
        if(_arrayMajorTemp.count>0)
        {
            _tblViewMajor.hidden=NO;
            
        }
        else
        {
            _tblViewMajor.hidden=YES;
            
        }
        
        [_tblViewMajor reloadData];
    }
}
@end
