//
//  ScheduleClassViewController.m
//  TedBuddies
//
//  Created by Mayank Pahuja on 22/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import "ScheduleClassViewController.h"
#import "HomeViewController.h"
#import "Shared.h"
#import "CreateProfileViewController.h"
#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import <AWSSQS/AWSSQS.h>
#import <AWSSNS/AWSSNS.h>
#import <AWSCognito/AWSCognito.h>
#import "AWSS3TransferManager.h"
#import "Shared.h"
#import "TTTAttributedLabel.h"
#import "TermsAndPrivacyViewController.h"
#import "UIImage+animatedGIF.h"

@interface ScheduleClassViewController ()<TTTAttributedLabelDelegate>
{
    UIButton *btnDoneKeyboard;
    bool isCourseSelect;

    
}
@property (nonatomic , assign) BOOL uploadSchedule;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (nonatomic , strong) UIImage *selectedImage;
@property (nonatomic) uint64_t fileSize;
@property (nonatomic) uint64_t amountUploaded;
@property (nonatomic , strong) UIView *loadingBg;
@property (nonatomic , strong) UIView *progressView;
@property (nonatomic , strong) UILabel *progresslabel;

@property(nonatomic,retain)NSMutableArray *arrayCoursePrefixTemp,*arrayClassTitleTemp,*arraySectionNameTemp;

@end

@implementation ScheduleClassViewController

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
    
    
    [_txtFieldCoursePrefix setDelegate:self];
    [_txtFieldCoursePrefix setBackgroundColor:[UIColor whiteColor]];
    [_txtFieldCoursePrefix setPopoverSize:CGRectMake(15, _txtFieldCoursePrefix.frame.origin.y+40, self.view.width-30, 135.0)];
    _txtFieldCoursePrefix.autocorrectionType=UITextAutocorrectionTypeNo;
    
    UIButton  * btnclose = [[UIButton alloc] initWithFrame:CGRectMake(_innerPopUpView.width-25,0, 25, 25)];
    [btnclose addTarget:self action:@selector(btnClosePopUpTapped:) forControlEvents: UIControlEventTouchUpInside];
    [btnclose setBackgroundImage:[UIImage imageNamed:@"crossbtn_grey"] forState:UIControlStateNormal];
    [_innerPopUpView addSubview:btnclose];
    
    
    TTTAttributedLabel *lblPrivancy = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(20, 151,_innerPopUpView.width-40, 50)];
    lblPrivancy.delegate=self;
    [lblPrivancy setFont:[UIFont fontWithName:@"Helvetica" size:11]];
    lblPrivancy.lineBreakMode = NSLineBreakByWordWrapping;
    lblPrivancy.numberOfLines = 3;
    NSString *labelText = @"StudEbuddies will only access your class schedule. We protect your Privacy everyday!";
    lblPrivancy.text = labelText;
    NSRange r = [labelText rangeOfString:@"Privacy"];
    [lblPrivancy addLinkToURL:[NSURL URLWithString:@"action://show-Privacy"] withRange:r];
    [_innerPopUpView addSubview:lblPrivancy];

    
    [_innerPopUpView.layer setShadowOpacity:0.9];
    [_innerPopUpView.layer setShadowRadius:2.0];
    [_innerPopUpView.layer setCornerRadius:7];
    [_innerPopUpView setClipsToBounds:YES];
    [_innerPopUpView.layer setShadowOffset:CGSizeMake(0.5, 0.5)];
    _innerPopUpView.center = CGPointMake(_popUpView.frame.size.width  / 2,(_popUpView.frame.size.height / 2)-50);
    
    _btnSignIn.layer.cornerRadius=3;
    _btnSignIn.clipsToBounds=YES;
    
    
    
    // Do any additional setup after loading the view from its nib.
}
-(IBAction)btnClosePopUpTapped:(id)sender
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [_popUpView setAlpha:0.0];
    [UIView commitAnimations];
    [self.view endEditing:TRUE];
    
}
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
   
            TermsAndPrivacyViewController *vcTermsAndPrivacy = [[TermsAndPrivacyViewController alloc] initWithNibName:@"TermsAndPrivacyViewController" bundle:nil];
            vcTermsAndPrivacy.headingName = @"Privacy Policy";
            [self presentViewController:vcTermsAndPrivacy animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setFonts];

    //set tutorials screens
//    if (![defaults boolForKey:kClassTitleTutorial])
//    {
//        //[[Shared sharedInst] showImageWithImageName:@"tutorialClassSchedule"];
//        _imgTutorial.alpha=1;
//        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView)];
//        tapGesture.numberOfTapsRequired = 1;
//        [_imgTutorial addGestureRecognizer:tapGesture];
//    }
}


- (void)viewDidAppear:(BOOL)animated
{
    
    
    //[self callAPIClassTitle:@""];
    [self callAPICoursePrifix];
   // [self callAPISectionName:@""];
   // [self editScheduleClass];
    
    
//    //add observer
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardDidShowNotification
//                                               object:nil];
   
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    dispatch_async(dispatch_get_main_queue(), ^{
         [btnDoneKeyboard removeFromSuperview];
        btnDoneKeyboard.hidden = YES;
        btnDoneKeyboard = nil;
    });
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - MPGTextFieldDelegate

- (NSArray *)dataForPopoverInTextField:(MPGTextField *)textField
{
    if ([textField isEqual:_txtFieldCoursePrefix]) {
        
        if (arrayCoursePrefix.count==0)
        {
           
            [_txtFieldCoursePrefix resignFirstResponder];
            NSString *msg=[NSString stringWithFormat:@"Congratulations, you have been selected to unlock %@. We will be onboarding %@ soon. Stay tuned!",[defaults valueForKey:kUniversityName],[defaults valueForKey:kUniversityName]];
            UIAlertView *alt=[[UIAlertView alloc]initWithTitle:@"StudeBuddies" message:msg delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alt show];
             return nil;
        }
        else
        {
            isCourseSelect=NO;
            return arrayCoursePrefix;
        }
       
    }
    else{
        return nil;
    }
}

- (BOOL)textFieldShouldSelect:(MPGTextField *)textField
{
    return YES;
}

- (void)textField:(MPGTextField *)textField didEndEditingWithSelection:(NSDictionary *)result
{
    //A selection was made - either by the user or by the textfield. Check if its a selection from the data provided or a NEW entry.
    if ([[result objectForKey:@"CustomObject"] isKindOfClass:[NSString class]] && [[result objectForKey:@"CustomObject"] isEqualToString:@"NEW"])
    {
        _txtFieldCoursePrefix.text=@"";
        isCourseSelect=NO;
        [Utils showAlertViewWithMessage:@"Select your Course!"];
    }
    else
    {
        isCourseSelect=YES;
    }
    
    
}
#pragma mark - alert Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex

{
    if (buttonIndex==0)
    {
        NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [defaults valueForKey:kUniversityId],@"Universityid",
                                  nil];
        
        [Connection callServiceWithName:kSendNoCourseNotificationForUniversity postData:dictSend callBackBlock:^(id response, NSError *error)
         {
            
             NSLog(@"response==%@",response);
             
         }];
        
    }
}
#pragma mark - gesture recognizer delegates
- (void)tapView
{
   // [[Shared sharedInst] removeView];
    [defaults setBool:true forKey:kClassTitleTutorial];
    _imgTutorial.alpha=0;
    
    if (![defaults boolForKey:kCoursePrefixTutorial])
    {
        _imgTutorial.alpha=1;
        [_imgTutorial setImage:[UIImage imageNamed:@"tutorialCoursePrefix"]];
      
    }
    [defaults setBool:true forKey:kCoursePrefixTutorial];
}

#pragma mark - other methods

- (void)keyboardWillShow:(NSNotification *)note
{
    if (btnDoneKeyboard)
    {
        [btnDoneKeyboard removeFromSuperview];
        btnDoneKeyboard = nil;
    }
    
    // create custom button
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDoneKeyboard = doneButton;
    doneButton.frame = CGRectMake(0, 175, 1.6, 30);
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneButtonAction)
         forControlEvents:UIControlEventTouchUpInside];
    [doneButton setHidden:YES];
    if ([_txtFieldClassSection isFirstResponder]) {
        [doneButton setHidden:NO];
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIView *keyboardView = [[[[[UIApplication sharedApplication] windows] lastObject] subviews] firstObject];
            [doneButton setFrame:CGRectMake(0, keyboardView.frame.size.height - 45, 106, 30)];
            [keyboardView addSubview:doneButton];
            [keyboardView bringSubviewToFront:doneButton];
            
            [UIView animateWithDuration:[[note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]-.02
                                  delay:.0
                                options:[[note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]
                             animations:^{
                                 self.view.frame = CGRectOffset(self.view.frame, 0, 0);
                             } completion:nil];
        });
    }else {
        // locate keyboard view
        dispatch_async(dispatch_get_main_queue(), ^{
            UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
            UIView* keyboard;
            for(int i=0; i<[tempWindow.subviews count]; i++) {
                keyboard = [tempWindow.subviews objectAtIndex:i];
                // keyboard view found; add the custom button to it
                if([[keyboard description] hasPrefix:@"UIKeyboard"] == YES)
                    [keyboard addSubview:doneButton];
            }
        });
    }
}

- (void)setFonts
{
    
    /*
     _isOnlySchedule = when we are just sched
     
     */
    if (_isOnlySchedule && [_scheduledClassId intValue] > 0)
    {
        [_txtFieldDate setText:[_dictScheduleClass objectForKeyNonNull:kClassDate]];
        [_txtFieldTime setText:[_dictScheduleClass objectForKeyNonNull:kClassTimeFrom]];
        [_txtFieldToTime setText:[_dictScheduleClass objectForKeyNonNull:kClassTimeTo]];
        [_txtFieldCoursePrefix setText:[_dictScheduleClass objectForKeyNonNull:kCourseNo]];
        courseId = [_dictScheduleClass objectForKeyNonNull:kCourseId];
        
        [_txtFieldClassTitle setText:[_dictScheduleClass objectForKeyNonNull:kClassTitle]];
        classId = [_dictScheduleClass objectForKeyNonNull:kClassId];
        
        [_txtFieldClassSection setText:[_dictScheduleClass objectForKeyNonNull:kSectionName]];
        sectionId = [_dictScheduleClass objectForKeyNonNull:kSectionId];
    }
    else
    {
        _txtFieldDate.text = [_dictClassScheduleData objectForKey:kClassDate];
        _txtFieldTime.text = [_dictClassScheduleData objectForKey:kClassTimeFrom];
        _txtFieldToTime.text = [_dictClassScheduleData objectForKey:kClassTimeTo];
        _txtFieldCoursePrefix.text = [_dictClassScheduleData objectForKey:kCourseNo];
        courseId = [_dictClassScheduleData objectForKey:kCourseId];
        _txtFieldClassTitle.text = [_dictClassScheduleData objectForKey:kClassTitle];
        classId = [_dictClassScheduleData objectForKey:kClassId];
        _txtFieldClassSection.text = [_dictClassScheduleData objectForKey:kSectionName];
        sectionId = [_dictClassScheduleData objectForKey:kSectionId];
    }
    
    
    
    [_txtFieldClassSection setFont:FONT_REGULAR(14)];
    [_txtFieldClassTitle setFont:FONT_REGULAR(14)];
    [_txtFieldDate setFont:FONT_REGULAR(14)];
    [_txtFieldCoursePrefix setFont:FONT_REGULAR(14)];
    [_txtFieldTime setFont:FONT_REGULAR(14)];
    [_txtFieldToTime setFont:FONT_REGULAR(14)];
    
    // Set Placeholder Color
    
    NSAttributedString *strDate = [[NSAttributedString alloc] initWithString:@"Date" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
    self.txtFieldDate.attributedPlaceholder = strDate;
    
    NSAttributedString *strFromTime = [[NSAttributedString alloc] initWithString:@"Start Time" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
    self.txtFieldTime.attributedPlaceholder = strFromTime;
    
    NSAttributedString *strToTime = [[NSAttributedString alloc] initWithString:@"End Time" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
    self.txtFieldToTime.attributedPlaceholder = strToTime;
    
    NSAttributedString *strCoursePrifix = [[NSAttributedString alloc] initWithString:@"Course: (ACHM 220)" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
    self.txtFieldCoursePrefix.attributedPlaceholder = strCoursePrifix;
    
    NSAttributedString *strClassTitle = [[NSAttributedString alloc] initWithString:@"Class Title: (Organic Chemistry I)" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
    self.txtFieldClassTitle.attributedPlaceholder = strClassTitle;
    
    NSAttributedString *strSection = [[NSAttributedString alloc] initWithString:@"Section: (0001)" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
    self.txtFieldClassSection.attributedPlaceholder = strSection;
    
    
    UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backSwipeAction)];
    [backSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:backSwipe];
    
    _btnUniCredentials.layer.cornerRadius=3;
    _btnUniCredentials.clipsToBounds=YES;
}


-(void) editScheduleClass
{
    courseId = @"0";
    sectionId = @"0";
    if(_isAlive)
    {
        _txtFieldDate.text = [_dictEditScheduleClass objectForKeyNonNull:kClassDate];
        _txtFieldTime.text = [_dictEditScheduleClass objectForKeyNonNull:kClassTimeFrom];
        _txtFieldToTime.text = [_dictEditScheduleClass objectForKeyNonNull:kClassTimeTo];
        _txtFieldCoursePrefix.text = [_dictEditScheduleClass objectForKeyNonNull:kCourseNo];
        _txtFieldClassTitle.text = [_dictEditScheduleClass objectForKeyNonNull:kClassTitle];
        _txtFieldClassSection.text = [_dictEditScheduleClass objectForKeyNonNull:kSectionName];
        courseId = [_dictEditScheduleClass objectForKeyNonNull:kCourseId];
        sectionId = [_dictEditScheduleClass objectForKeyNonNull:kSectionId];
    }
    
}


// set Validation On TextFields........

- (BOOL)isValid
{
    //    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    //
    //    NSString *strDateTime = [_txtFieldDate.text stringByAppendingFormat:@" %@",_txtFieldTime.text];
    //    [formatter setDateFormat:@"MM/dd/yyyy HH:mm"];
    //    NSDate *selectedDate = [formatter dateFromString:strDateTime];
    //    if ([selectedDate compare:[NSDate date]] == NSOrderedAscending)
    //    {
    //        msgString = @"You cannot schedule a class for past date.";
    //        return NO;
    //    }
    //
    //    if (_txtFieldDate.text.length == 0)
    //    {
    //        msgString  = @"Dont forget to fill the date";
    //        return NO;
    //    }
    //    else if (_txtFieldTime.text.length == 0)
    //    {
    //        msgString  = @"Dont forget to fill Start Time";
    //        return NO;
    //    }
    //    else if (_txtFieldToTime.text.length == 0)
    //    {
    //        msgString  = @"Dont forget to fill End Time";
    //        return NO;
    //    }
    //    [formatter setDateFormat:@"HH:mm"];
    //    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    //
    //    NSDate *d1 = [formatter dateFromString:_txtFieldTime.text];
    //    NSDate *d2 = [formatter dateFromString:_txtFieldToTime.text];
    //
    //    if( [d2 timeIntervalSinceDate:d1]/60.0 <= 45.0)
    //    {
    //        msgString = @"Time Interval Must be 45 min.";
    //        return NO;
    //    }
    //
    //    if ([d2 compare:d1] == NSOrderedAscending)
    //    {
    //        msgString = @"End time should be greater than Start time";
    //        return NO;
    //    }
    
//    if (_txtFieldClassTitle.text.length == 0)
//    {
//        msgString  = @"Don't forget to fill Class Title";
//        return NO;
//    }
     if (_txtFieldCoursePrefix.text.length == 0)
    {
       [Utils showAlertViewWithMessage:@"Don't forget to fill Course"];
        return NO;
    }
    if (!isCourseSelect)
    {
        [Utils showAlertViewWithMessage:@"Select your Course!"];
        return false;
    }

//    else if (_txtFieldClassSection.text.length == 0)
//    {
//        msgString  = @"Don't forget to fill Section";
//        return NO;
//    }
//    if (![Utils NSStringIsValidExpression:_txtFieldCoursePrefix.text]) {
//        msgString = @"Restriction: Course should be no more than 4 letters then a SPACE and then no more than 5 numbers.";
//        return NO;
//    }
    
    return YES;
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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonAction)],
                           nil];
    numberToolbar.tintColor = [UIColor blackColor];
    [numberToolbar setBarTintColor:[UIColor colorWithRed:186.0/255.0 green:190.0/255.0 blue:195.0/255.0 alpha:1]];
    [numberToolbar sizeToFit];
   
    if ([textField isEqual:_txtFieldClassSection]) {
        
        textField.inputAccessoryView = numberToolbar;
        
//        //add observer
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(keyboardWillShow:)
//                                                     name:UIKeyboardDidShowNotification
//                                                   object:nil];
//
    }
    //else {
//        
//    }
//    
//    if (![textField isEqual:_txtFieldClassSection]) {
//        btnDoneKeyboard.hidden = YES;
//        
//    } else {
//        btnDoneKeyboard.hidden = NO;
//    }
//
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    
    if (textField.frame.origin.y+textField.frame.size.height > self.view.frame.size.height-360)
    {
        isTextField = YES;
        [self.view setTransform:CGAffineTransformMakeTranslation(0, -(textField.frame.origin.y+textField.frame.size.height - self.view.frame.size.height+360))];
    }
    
    [UIView commitAnimations];
    
    
    
    
    if ([textField isEqual:_txtFieldDate])
    {
        _datePicker.minimumDate = [NSDate date];
        textField.inputView = _datePicker;
        textField.inputAccessoryView = _toolBarPicker;
        selectedTextField = kSelectedFieldDate;
    }
    
    if (textField == _txtFieldTime)
    {
        isFromTime = YES;
        textField.inputView = _pickerTime;
        textField.inputAccessoryView = _toolBarPicker;
        selectedTextField = kSelectedFieldFromTime;
    }
    
    else if (textField == _txtFieldToTime)
    {
        isFromTime = NO;
        textField.inputView = _pickerTime;
        textField.inputAccessoryView = _toolBarPicker;
        selectedTextField = kSelectedFieldToTime;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    isTextField = NO;
    _tblViewSectionName.hidden=YES;
    _tblViewProfessorName.hidden=YES;
    _tblViewClassTitle.hidden=YES;
    
    
    if ([textField isEqual:_txtFieldClassSection]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
    [self performSelector:@selector(resignTextFields) withObject:nil afterDelay:0.1];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
//    [btnDoneKeyboard removeFromSuperview];
//    btnDoneKeyboard = nil;
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
//    if (textField == _txtFieldCoursePrefix)
//    {
//        NSString *CoursePrifix = [textField.text stringByReplacingCharactersInRange:range withString:string];
//        if (CoursePrifix.length > 0)
//        {
//            // [self callAPISectionName:sectionName];
//            // [self searchFilter:textField string:sectionName];
//            
//        }
//        [self searchFilter:textField string:CoursePrifix];
//        
//        NSUInteger oldLength = [textField.text length];
//        NSUInteger replacementLength = [string length];
//        NSUInteger rangeLength = range.length;
//        
//        NSUInteger newLength = oldLength - rangeLength + replacementLength;
//        
//        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
//        
//        return newLength <= 10 || returnKey;
//        
//    }
//    if (textField == _txtFieldClassTitle)
//    {
//        NSString *classTitle = [textField.text stringByReplacingCharactersInRange:range withString:string];
//        
//        if (classTitle.length > 0)
//        {
//            //[self callAPIClassTitle:classTitle];
//            //[self searchFilter:textField string:classTitle];
//            
//        }
//        [self searchFilter:textField string:classTitle];
//        
//    }
//    if (textField == _txtFieldClassSection)
//    {
//        
//        NSString *sectionName = [textField.text stringByReplacingCharactersInRange:range withString:string];
//        
//        if (sectionName.length > 0)
//        {
//            // [self callAPISectionName:sectionName];
//            // [self searchFilter:textField string:sectionName];
//            
//        }
//        [self searchFilter:textField string:sectionName];
//        
//        
//        NSUInteger oldLength = [textField.text length];
//        NSUInteger replacementLength = [string length];
//        NSUInteger rangeLength = range.length;
//        
//        NSUInteger newLength = oldLength - rangeLength + replacementLength;
//        
//        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
//        
//        return newLength <= 4 || returnKey;
//    }
    
    return YES;
}
- (void)resignTextFields
{
    if (!isTextField)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.4];
        
        [self.view setTransform:CGAffineTransformIdentity];
        [UIView commitAnimations];
    }
    
    
}

#pragma mark - web service

- (void)callAPICoursePrifix
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults valueForKey:kUniversityId],@"id",
                              nil];
    [self startLoaderWithMessage:@""];
    [Connection callServiceWithName:kGetProfessorList postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         [self stopLoader];

         if (response)
         {
             
                 arrayCoursePrefix = nil;
             NSArray *arry=[[NSArray alloc] initWithArray:response ];
             NSMutableArray *Dumy=[[NSMutableArray alloc] init];
             for (int i=0; i<[arry count]; i++)
             {
                 NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
                 [dict setValue:[arry objectAtIndex:i] forKey:@"CustomObject"];
                 [dict setValue:[[arry objectAtIndex:i] valueForKey:@"value"] forKey:@"DisplayText"];
                 [Dumy addObject:dict];
             }
             arrayCoursePrefix=[NSArray arrayWithArray:Dumy];

             
                 
                 // [_tblViewProfessorName reloadData];
                 // [_tblViewCoursePrifix setHidden:NO];
             
         }
     }];
}

- (void)callAPIClassTitle:(NSString*)name
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              name,kSearchText,
                              nil];
    
    [Connection callServiceWithName:kGetClassesList postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 
                 arrayClassTitle = nil;
                 arrayClassTitle = [[NSArray alloc] initWithArray:[response objectForKeyNonNull:kResult]];
                 _arrayClassTitleTemp=[NSMutableArray arrayWithArray:arrayClassTitle];
                 //[_tblViewClassTitle reloadData];
                 // [_tblViewClassTitle setHidden:NO];
             }
         }
     }];
}


- (void)callAPISectionName:(NSString*)name
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              name,kSearchText,
                              nil];
    
    [Connection callServiceWithName:kGetSectionList postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         [Utils stopLoader];
         
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 
                 arraySectionName = nil;
                 arraySectionName = [[NSArray alloc] initWithArray:[response objectForKeyNonNull:kResult]];
                 _arraySectionNameTemp=[NSMutableArray arrayWithArray:arraySectionName];
                 
                 // [_tblViewSectionName reloadData];
                 //[_tblViewSectionName setHidden:NO];
             }
         }
     }];
}

-(void) CallAPIScheduleClasses
{
    /**********
     
     "ShedClsId": "sample string 1",
     "userId": "sample string 2",
     "classId": "sample string 3",
     "classTitle": "sample string 4",
     "professorId": "sample string 5",
     "professorName": "sample string 6",
     "sectionId": "sample string 7",
     "sectionName": "sample string 8",
     "universityName": "sample string 9",
     "classDate": "sample string 10",
     "classTimeTo": "sample string 11",
     "classTimeFrom": "sample string 12",
     "courseId": "sample string 13",
     "courseNo": "sample string 14"
     
     ******************/
    
    (classId.length==0)?classId=@"0":classId;
    (courseId.length==0)?courseId=@"0":courseId;
    (sectionId.length==0)?sectionId=@"0":sectionId;
    
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
                              classId,kClassId,
                              _txtFieldClassTitle.text,kClassTitle,
                              @"",kMajorId,
                              @"",kMajorName,
                              _txtFieldClassSection.text,kSectionName,
                              sectionId,kSectionId,
                              @"",kUniversityId,
                              @"",kUniversityName,
                              @"",kClassDate,
                              @"",kClassTimeTo,
                              @"",kClassTimeFrom,
                              _scheduledClassId,kShedClsId,
                              courseId,kCourseId,
                              _txtFieldCoursePrefix.text,kCourseNo,
                              nil];
    [self startLoaderWithMessage:@""];
    [Connection callServiceWithName:kScheduleClasses postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         [self stopLoader];
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 
                 NSLog(@"set Schedule");
                 _txtFieldClassSection.text=@" ";
                 _txtFieldClassTitle.text=@" ";
                 _txtFieldDate.text=@" ";
                 _txtFieldCoursePrefix.text=@" ";
                 
                 
                 _txtFieldTime.text=@" ";
                 _txtFieldToTime.text=@" ";
                 [Utils showAlertViewWithMessage:[response objectForKeyNonNull:kMessage]];
                 
             }
             else
             {
                 NSLog(@"set Schedule");
                 _txtFieldClassSection.text=@" ";
                 _txtFieldClassTitle.text=@" ";
                 _txtFieldDate.text=@" ";
                 _txtFieldCoursePrefix.text=@" ";
                 
                 
                 _txtFieldTime.text=@" ";
                 _txtFieldToTime.text=@" ";
                 [Utils showAlertViewWithMessage:[response objectForKeyNonNull:kMessage]];
                 [self.view endEditing:YES];
             }
             [self.navigationController popViewControllerAnimated:YES];
         }
     }];
    
}


#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 21)
    {
        return [_arrayCoursePrefixTemp count];
    }
    if (tableView.tag == 22)
    {
        return [_arrayClassTitleTemp count];
    }
    if (tableView.tag == 23)
    {
        return [_arraySectionNameTemp count];
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
    if(tableView == _tblViewProfessorName)
    {
        cell.textLabel.text = [[_arrayCoursePrefixTemp objectAtIndex:indexPath.row] objectForKeyNonNull:@"courseNo"];
        
    }
    if(tableView == _tblViewClassTitle)
    {
        cell.textLabel.text = [[_arrayClassTitleTemp objectAtIndex:indexPath.row] objectForKeyNonNull:@"className"];
        
    }
    if(tableView == _tblViewSectionName)
    {
        cell.textLabel.text = [[_arraySectionNameTemp objectAtIndex:indexPath.row] objectForKeyNonNull:@"section"];
        
    }
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tblViewProfessorName)
    {
        [_tblViewProfessorName setHidden:YES];
        _txtFieldCoursePrefix.text = [[_arrayCoursePrefixTemp objectAtIndex:indexPath.row] objectForKeyNonNull:@"courseNo"];
//        courseId = [[_arrayCoursePrefixTemp objectAtIndex:indexPath.row] objectForKeyNonNull:@"courseId"];
        
    }
    
    if (tableView == _tblViewClassTitle)
    {
        [_tblViewClassTitle setHidden:YES];
        _txtFieldClassTitle.text = [[_arrayClassTitleTemp objectAtIndex:indexPath.row] objectForKeyNonNull:@"className"];
        classId = [[_arrayClassTitleTemp objectAtIndex:indexPath.row] objectForKeyNonNull:@"classId"];
    }
    
    if (tableView == _tblViewSectionName)
    {
        [_tblViewSectionName setHidden:YES];
        
        NSString *strSection = [[_arraySectionNameTemp objectAtIndex:indexPath.row] objectForKeyNonNull:@"section"];
        if (strSection.length <= 4)
        {
            
            _txtFieldClassSection.text = [[_arraySectionNameTemp objectAtIndex:indexPath.row] objectForKeyNonNull:@"section"];
            sectionId = [[_arraySectionNameTemp objectAtIndex:indexPath.row] objectForKeyNonNull:kSectionId];
        
        }
    }
}
#pragma mark - button action

- (void)doneButtonAction
{
    [btnDoneKeyboard removeFromSuperview];
    btnDoneKeyboard.hidden = YES;
    btnDoneKeyboard = nil;
    [self.view endEditing:YES];
   
    
}


- (IBAction)btnBackTapped:(UIButton *)sender
{
    [self backSwipeAction];
    [btnDoneKeyboard removeFromSuperview];
    btnDoneKeyboard.hidden = YES;
    btnDoneKeyboard = nil;
}

- (IBAction)btnAddScheduleTapped:(UIButton *)sender
{
    
    
    if ([self isValid])
    {
        NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                                  classId,kClassId,
                                  @"",kClassTitle,
                                 @"",kMajorId,
                                  @"",kMajorName,
                                  @"",kSectionName,
                                  sectionId,kSectionId,
                                  @"",kUniversityName,
                                  @"",kClassDate,
                                  @"",kClassTimeTo,
                                  @"",kClassTimeFrom,
                                  courseId,kCourseId,
                                  _txtFieldCoursePrefix.text,kCourseNo,
                                  [defaults objectForKey:kUserId],kUserId,
                                  nil];
    
        if (_isOnlySchedule)
        {
            [self CallAPIScheduleClasses];
            
        }
        else
        {
            [_delegate scheduleDetails:dictSend];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (IBAction)pickerTimeChanged:(UIDatePicker *)sender
{
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH:mm"];
    
    if (isFromTime)
    {
        [_txtFieldTime setText:[outputFormatter stringFromDate:sender.date]];
    }
    else
    {
        [_txtFieldToTime setText:[outputFormatter stringFromDate:sender.date]];
    }
}

- (IBAction)btnUniCredentialsTapped:(id)sender
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [_popUpView setAlpha:1.0];
    [UIView commitAnimations];
    [self.view endEditing:TRUE];

}

- (IBAction)btnSignInTapped:(id)sender
{
    if ([self isValidation])
    {
        NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [defaults objectForKey:kUserId],kUserId,
                                  _txtID.text,@"emailId",
                                  _txtPwd.text,@"password",
                                  [defaults objectForKey:kUniversityName],kUniversityName,
                                  nil];
        
        [self startLoaderWithMessage:@""];
        [Connection callServiceWithName:kCheckUniversityCredentials postData:dictSend callBackBlock:^(id response, NSError *error)
         {
             [self stopLoader];
             if (response)
             {
                 
                 if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
                 {
                     
                     [UIView beginAnimations:nil context:nil];
                     [UIView setAnimationDuration:0.5];
                     [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                     _popUpView.alpha = 0.0;
                     [UIView commitAnimations];
                     [self.view endEditing:TRUE];
                     
                     [defaults setObject:@"True" forKey:kiisclassuploaded];
                     NSLog(@"%d",[defaults boolForKey:kiisclassuploaded]);
                     
                     [Utils showAlertViewWithMessage:[NSString stringWithFormat:@"You have successfully uploaded your class schedule for %@",[defaults objectForKey:kUniversityName]]];
                     
                     
                 }
                 else
                 {
                     if ([[response objectForKeyNonNull:@"Result"] isEqualToString:@"newuniversity"])
                     {
                         [UIView beginAnimations:nil context:nil];
                         [UIView setAnimationDuration:0.5];
                         [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                         _popUpView.alpha = 0.0;
                         [UIView commitAnimations];
                         [self.view endEditing:TRUE];
                         
                         [Utils showAlertViewWithMessage:[NSString stringWithFormat:@"Congrats!! You have been selected to unlock %@ Give us 24 hrs to review and accept your %@ class schedule!.",[defaults objectForKey:kUniversityName],[defaults objectForKey:kUniversityName]]];
                         
                     }
                     else
                     {
                         [Utils showAlertViewWithMessage:@"Invalid credentials, please try again!!"];
                     }
                     
                 }
             }
             else
             {
                 [Utils showAlertViewWithMessage:@"Invalid credentials, please try again!!"];
             }
         }];

    }
   
}
-(BOOL)isValidation
{
    if ([_txtID.text isEqualToString:@""])
    {
        [Utils showAlertViewWithMessage:@"Don't forget to enter your University ID and Passaword.!"];
        return false;
    }
    if ([_txtPwd.text isEqualToString:@""])
    {
        [Utils showAlertViewWithMessage:@"Don't forget to enter your University Passaword.!"];
        return false;
    }
        return YES;
}


- (IBAction)btnClassSchedule:(id)sender
{
//    [self.view endEditing:YES];
//    _uploadSchedule = TRUE;
//    [self openActionSheet];
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


- (void)ImageCropViewController:(ImageCropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage{
    _selectedImage = croppedImage;
    
    if (!_uploadSchedule)
    {
       
      
        
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
            
            __weak ScheduleClassViewController *weakSelf = self;
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
                        
                        [Utils showAlertViewWithMessage:[NSString stringWithFormat:@"Congrats!! You have been selected to unlock %@. Give us 24 hrs to review and accept your %@ class schedule!",[defaults objectForKey:kUniversityName],[defaults objectForKey:kUniversityName]]];
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
    
    self.navigationController.navigationBarHidden = YES;
    
    [[self navigationController] popViewControllerAnimated:YES];
    
}

- (IBAction)pickerDateChanged:(UIDatePicker *)sender
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSString *dob = [formatter stringFromDate:sender.date];
    
    _txtFieldDate.text = dob;
}

- (IBAction)pickerDoneTapped:(UIBarButtonItem *)sender
{
    switch (selectedTextField)
    {
        case kSelectedFieldDate:
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MM/dd/yyyy"];
            NSString *dob = [formatter stringFromDate:[_datePicker date]];
            _txtFieldDate.text = dob;
        }
            
            break;
            
        case kSelectedFieldFromTime:
        {
            NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
            [outputFormatter setDateFormat:@"HH:mm"];
            [_txtFieldTime setText:[outputFormatter stringFromDate:[_pickerTime date]]];
        }
            break;
            
        case kSelectedFieldToTime:
        {
            NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
            [outputFormatter setDateFormat:@"HH:mm"];
            [_txtFieldToTime setText:[outputFormatter stringFromDate:[_pickerTime date]]];
        }
            break;
            
        default:
            break;
    }
    [self.view endEditing:YES];
}


#pragma mark Search

-(void)searchFilter:(UITextField *)textField string:(NSString *)string
{
    _arrayCoursePrefixTemp=[NSMutableArray arrayWithArray:arrayCoursePrefix];
    _arrayClassTitleTemp=[NSMutableArray arrayWithArray:arrayClassTitle];
    _arraySectionNameTemp=[NSMutableArray arrayWithArray:arraySectionName];
    
    if(string.length==0)
    {
        [_tblViewProfessorName reloadData];
        [_tblViewClassTitle reloadData];
        [_tblViewSectionName reloadData];
        return;
    }
    if(textField==_txtFieldCoursePrefix)
    {
        NSPredicate *predicate = [NSPredicate
                                  predicateWithFormat:@"CourseNo CONTAINS[cd] %@ ",
                                  string
                                  ];
        
        [_arrayCoursePrefixTemp filterUsingPredicate:predicate];
        
        if(_arrayCoursePrefixTemp.count>0)
        {
            _tblViewProfessorName.hidden=NO;
            
        }
        else
        {
            _tblViewProfessorName.hidden=YES;
            
        }
        [_tblViewProfessorName reloadData];
        
    }
    else if (textField==_txtFieldClassTitle)
    {
        NSPredicate *predicate = [NSPredicate
                                  predicateWithFormat:@"className CONTAINS[cd] %@ ",
                                  string
                                  ];
        _tblViewClassTitle.hidden=NO;
        [_arrayClassTitleTemp filterUsingPredicate:predicate];
        
        
        if(_arrayClassTitleTemp.count>0)
        {
            _tblViewClassTitle.hidden=NO;
        }
        else
        {
            _tblViewClassTitle.hidden=YES;
        }
        [_tblViewClassTitle reloadData];
        
        
    }
    else if (textField==_txtFieldClassSection)
    {
        NSPredicate *predicate = [NSPredicate
                                  predicateWithFormat:@"section CONTAINS[cd] %@ ",
                                  string
                                  ];
        _tblViewSectionName.hidden=NO;
        [_arraySectionNameTemp filterUsingPredicate:predicate];
        
        
        if(_arraySectionNameTemp.count>0)
        {
            _tblViewSectionName.hidden=NO;
            
        }
        else
        {
            _tblViewSectionName.hidden=YES;
            
        }
        [_tblViewSectionName reloadData];
        
    }
}


- (void)startLoaderWithMessage:(NSString *)message
{
    //    UIView *view = SharedAppDelegate.window.rootViewController.view;
    //    MBProgressHUD *_hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    //    _hud.dimBackground  = NO;
    //    _hud.labelText      = message;
    
    [Utils stopLoader];
    UIView *view = self.view;
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

- (void)stopLoader
{
    //    UIView *view = SharedAppDelegate.window.rootViewController.view;
    //    [MBProgressHUD hideHUDForView:view animated:YES];
    
    UIView *view = self.view;
    UIImageView *imgViewLoader = (UIImageView*)[view viewWithTag:30000];
    [imgViewLoader removeFromSuperview];
    imgViewLoader = nil;
    [view setUserInteractionEnabled:YES];
    
    // [Utils stopActivityIndicatorInView:view];
}

@end
