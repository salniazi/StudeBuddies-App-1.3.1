//
//  AddScheduleClassViewController.m
//  TedBuddies
//
//  Created by Mayank Pahuja on 22/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import "AddScheduleClassViewController.h"
#import "Shared.h"

@interface AddScheduleClassViewController ()

@end

@implementation AddScheduleClassViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self.tabBarController setHidesBottomBarWhenPushed:YES];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //set tutorials screens
    if (![defaults boolForKey:kClassTitleTutorial]) {
        
        //[[Shared sharedInst] showImageWithImageName:@"tutorialClassSchedule"];
        
    } else if (![defaults boolForKey:kCoursePrefixTutorial]){
        
        //[[Shared sharedInst] showImageWithImageName:@"tutorialCoursePrefix"];
    }
    
    
    // set initial fonts
    [self setFonts];

}
    

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - other methods
- (void)setFonts
{
    
    [_txtFieldClassSection setFont:FONT_REGULAR(14)];
    [_txtFieldClassTitle setFont:FONT_REGULAR(14)];
    [_txtFieldDate setFont:FONT_REGULAR(14)];
    [_txtFieldProfessorName setFont:FONT_REGULAR(14)];
    [_txtFieldTime setFont:FONT_REGULAR(14)];
    [_txtFieldToTime setFont:FONT_REGULAR(14)];
   
    UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backSwipeAction)];
    [backSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:backSwipe];
  
}

- (BOOL)isValid
{
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"HH:mm"];
//    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
//    
//    NSDate *d1 = [formatter dateFromString:_txtFieldTime.text];
//    NSDate *d2 = [formatter dateFromString:_txtFieldToTime.text];
//    
//    if ([d2 compare:d1] == NSOrderedAscending)
//    {
//        msgString = @"To time should be greater than From time";
//        return NO;
//    }
//    
//    NSString *strDateTime = [_txtFieldDate.text stringByAppendingFormat:@" %@",_txtFieldTime.text];
//    [formatter setDateFormat:@"MM/dd/yyyy HH:mm"];
//    NSDate *selectedDate = [formatter dateFromString:strDateTime];
//    if ([selectedDate compare:[NSDate date]] == NSOrderedAscending)
//    {
//        msgString = @"You cannot schedule a class for past date.";
//        return NO;
//    }
//    if (_txtFieldDate.text.length == 0)
//    {
//        msgString  = @"Kindly enter the date";
//        return NO;
//    }
//    else if (_txtFieldTime.text.length == 0)
//    {
//        msgString  = @"Kindly enter From Time";
//        return NO;
//    }
//    else if (_txtFieldToTime.text.length == 0)
//    {
//        msgString  = @"Kindly enter To Time";
//        return NO;
//    }
    if (_txtFieldSelectDegree.text.length == 0)
    {
        msgString  = @"Kindly enter your Major";
        return NO;
    }
    else if (_txtFieldSelectUniversity.text.length == 0)
    {
        msgString  = @"Kindly enter your University";
        return NO;
    }
    else if (_txtFieldClassTitle.text.length == 0)
    {
        msgString  = @"Kindly enter Class Title";
        return NO;
    }
    else if (_txtFieldProfessorName.text.length == 0)
    {
        msgString  = @"Kindly enter CoursePrefix";
        return NO;
    }
    else if (_txtFieldClassSection.text.length == 0)
    {
        msgString  = @"Kindly enter Section";
        return NO;
    }
    
    if (![Utils NSStringIsValidExpression:_txtFieldProfessorName.text]) {
        msgString = @"Restriction: Course Prefix should be no more than 4 letters then a SPACE and then no more than 5 numbers.";
        return NO;
    }
    
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    if (textField.frame.origin.y+textField.frame.size.height > self.view.frame.size.height-300)
    {
        isTextField = YES;
        [self.view setTransform:CGAffineTransformMakeTranslation(0, -(textField.frame.origin.y+textField.frame.size.height - self.view.frame.size.height+300))];
    }
    [UIView commitAnimations];
    
    if ([textField isEqual:_txtFieldDate])
    {
        _datePicker.minimumDate = [NSDate date];
        textField.inputView = _datePicker;
        textField.inputAccessoryView = _toolBarPicker;
    }
    if (textField == _txtFieldTime)
    {
        isFromTime = YES;
        textField.inputView = _pickerTime;
        textField.inputAccessoryView = _toolBarPicker;
    }
    else if (textField == _txtFieldToTime)
    {
        isFromTime = NO;
        textField.inputView = _pickerTime;
        textField.inputAccessoryView = _toolBarPicker;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    isTextField = NO;
    
    if (textField == _txtFieldSelectDegree)
    {
        [_tblViewSelectDegree setHidden:YES];
    }
    
    if (textField == _txtFieldSelectUniversity)
    {
        [_tblViewSelectUniversity setHidden:YES];
    }
    
    if (textField == _txtFieldProfessorName)
    {
        [_tblViewProfessorName setHidden:YES];
    }
    if (textField == _txtFieldClassTitle)
    {
        [_tblViewClassTitle setHidden:YES];
    }
    if (textField == _txtFieldClassSection)
    {
        [_tblViewSectionName setHidden:YES];
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
    if (textField == _txtFieldSelectDegree)
    {
        isMajor = YES;
        NSString *degreeName = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (degreeName.length > 0)
        {
            [self callAPIMajorUniversityList:degreeName];
        }
    }
    if (textField == _txtFieldSelectUniversity)
    {
        isMajor = NO;
        NSString *universityName = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (universityName.length > 0)
        {
            [self callAPIMajorUniversityList:universityName];
        }
        
        
    }
    if (textField == _txtFieldProfessorName)
    {
        NSString *professorName = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (professorName.length > 0)
        {
            [self callAPIProfessorName:professorName];
        }
        
    }
    if (textField == _txtFieldClassTitle)
    {
        NSString *classTitle = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (classTitle.length > 0)
        {
            [self callAPIClassTitle:classTitle];
        }
        
    }
    if (textField == _txtFieldClassSection)
    {
        NSString *sectionName = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if (sectionName.length > 0)
        {
            [self callAPISectionName:sectionName];
        }
        
    }
    
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
- (void)callAPIMajorUniversityList:(NSString*)name
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              name,kSearchText,
                              nil];
    
    [Connection callServiceWithName:kGetMajorUniversityList postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 if (isMajor)
                 {
                     arrayMajor = nil;
                     arrayMajor = [[NSArray alloc] initWithArray:[[response objectForKeyNonNull:kResult] objectForKeyNonNull:kLstMajor]];
                     [_tblViewSelectDegree setHidden:NO];
                     [_tblViewSelectDegree reloadData];
                 }
                 else
                 {
                     arrayUniversity = nil;
                     arrayUniversity = [[NSArray alloc] initWithArray:[[response objectForKeyNonNull:kResult] objectForKeyNonNull:kLstUniversity]];
                     [_tblViewSelectUniversity setHidden:NO];
                     [_tblViewSelectUniversity reloadData];
                 }
             }
         }
     }];
}
- (void)callAPIProfessorName:(NSString*)name
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              name,kSearchText,
                              nil];
    
    [Connection callServiceWithName:kGetProfessorList postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 
                 arrayProfessorName = nil;
                 arrayProfessorName = [[NSArray alloc] initWithArray:[response objectForKeyNonNull:kResult]];
                 [_tblViewProfessorName reloadData];
                 [_tblViewProfessorName setHidden:NO];
             }
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
                 [_tblViewClassTitle reloadData];
                 [_tblViewClassTitle setHidden:NO];
             }
         }
     }];
}
-(void) CallAPIScheduleClasses
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
                              classId,kClassId,
                              _txtFieldClassTitle.text,kClassTitle,
                              professorId,kProfessorId,
                              _txtFieldProfessorName.text,kProfessorName,
                              majorId,kMajorId,
                              _txtFieldSelectDegree.text,kMajorName,
                              _txtFieldClassSection.text,kSectionName,
                              sectionId,kSectionId,
                              @"",kUniversityId,
                              @"",kUniversityName,
                              _txtFieldDate.text,kClassDate,
                              _txtFieldToTime.text,kClassTimeTo,
                              _txtFieldTime.text,kClassTimeFrom,
                              nil];
    
    [Connection callServiceWithName:kScheduleClasses postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 
                 NSLog(@"set Schedule");
                 _txtFieldClassSection.text=@" ";
                 _txtFieldClassTitle.text=@" ";
                 _txtFieldDate.text=@" ";
                 _txtFieldProfessorName.text=@" ";
                 _txtFieldSelectDegree.text=@" ";
                 _txtFieldSelectUniversity.text=@" ";
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
                 _txtFieldProfessorName.text=@" ";
                 _txtFieldSelectDegree.text=@" ";
                 _txtFieldSelectUniversity.text=@" ";
                 _txtFieldTime.text=@" ";
                 _txtFieldToTime.text=@" ";
                 [Utils showAlertViewWithMessage:[response objectForKeyNonNull:kMessage]];
                 [self.view endEditing:YES];
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
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 
                 arraySectionName = nil;
                 arraySectionName = [[NSArray alloc] initWithArray:[response objectForKeyNonNull:kResult]];
                 [_tblViewSectionName reloadData];
                 [_tblViewSectionName setHidden:NO];
             }
         }
     }];
}



#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 21)
    {
        return [arrayProfessorName count];
    }
    if (tableView.tag == 22)
    {
        return [arrayClassTitle count];
    }
    if (tableView.tag == 23)
    {
        return [arraySectionName count];
    }
    if (tableView.tag == 24)
    {
        return [arrayUniversity count];
    }
    if (tableView.tag == 25)
    {
        return [arrayMajor count];
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
    if(tableView == _tblViewSelectDegree)
    {
        cell.textLabel.text = [[arrayMajor objectAtIndex:indexPath.row] objectForKeyNonNull:@"major"];
        
    }
    if(tableView == _tblViewSelectUniversity)
    {
        cell.textLabel.text = [[arrayUniversity objectAtIndex:indexPath.row] objectForKeyNonNull:@"university"];
        
    }
    if(tableView == _tblViewProfessorName)
    {
        cell.textLabel.text = [[arrayProfessorName objectAtIndex:indexPath.row] objectForKeyNonNull:@"professor"];
        
    }
    if(tableView == _tblViewClassTitle)
    {
        cell.textLabel.text = [[arrayClassTitle objectAtIndex:indexPath.row] objectForKeyNonNull:@"className"];
        
    }
    if(tableView == _tblViewSectionName)
    {
        cell.textLabel.text = [[arraySectionName objectAtIndex:indexPath.row] objectForKeyNonNull:@"section"];
        
    }
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tblViewProfessorName)
    {
        [_tblViewProfessorName setHidden:YES];
        _txtFieldProfessorName.text = [[arrayProfessorName objectAtIndex:indexPath.row] objectForKeyNonNull:@"professor"];
        professorId = [[arrayProfessorName objectAtIndex:indexPath.row] objectForKeyNonNull:@"professorId"];
        
    }
    if (tableView == _tblViewClassTitle)
    {
        [_tblViewClassTitle setHidden:YES];
        _txtFieldClassTitle.text = [[arrayClassTitle objectAtIndex:indexPath.row] objectForKeyNonNull:@"className"];
        classId = [[arrayClassTitle objectAtIndex:indexPath.row] objectForKeyNonNull:@"classId"];
        
    }
    if (tableView == _tblViewSectionName)
    {
        [_tblViewSectionName setHidden:YES];
        _txtFieldClassSection.text = [[arraySectionName objectAtIndex:indexPath.row] objectForKeyNonNull:@"section"];
        sectionId = [[arraySectionName objectAtIndex:indexPath.row] objectForKeyNonNull:@"sectionId"];
        
    }
    if (tableView == _tblViewSelectUniversity)
    {
        [_tblViewSelectUniversity setHidden:YES];
        _txtFieldSelectUniversity.text = [[arrayUniversity objectAtIndex:indexPath.row] objectForKeyNonNull:@"university"];
        universityId = [[arrayUniversity objectAtIndex:indexPath.row] objectForKeyNonNull:@"universityId"];
        
        
        
    }
    if (tableView == _tblViewSelectDegree)
    {
        [_tblViewSelectDegree setHidden:YES];
        _txtFieldSelectDegree.text = [[arrayMajor objectAtIndex:indexPath.row] objectForKeyNonNull:@"major"];
        majorId = [[arrayMajor objectAtIndex:indexPath.row] objectForKeyNonNull:@"majorId"];
        
        
        
    }
}
#pragma mark - button action

- (IBAction)btnBackTapped:(UIButton *)sender
{
    [self backSwipeAction];
}

- (IBAction)btnAddScheduleTapped:(UIButton *)sender
{
    if ([self isValid])
    {
        [self CallAPIScheduleClasses];
    }
    else
    {
        [Utils showAlertViewWithMessage:msgString];
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
- (IBAction)pickerDateChanged:(UIDatePicker *)sender
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy"];
    NSString *dob = [formatter stringFromDate:sender.date];
    
    _txtFieldDate.text = dob;
}

- (IBAction)pickerDoneTapped:(UIBarButtonItem *)sender
{
    [self.view endEditing:YES];
}


@end
