//
//  MyBuddiesViewController.m
//  TedBuddies
//
//  Created by Mayank Pahuja on 03/09/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import "MyBuddiesViewController.h"
#import "ViewProfileViewController.h"
#import "FindBuddiesViewController.h"
#import "HomeViewController.h"
#import "ChatScreenViewController.h"
#import "MyWebSocket.h"
#import "AddFacebookFriendsViewController.h"
#import "AddContactFriendsViewController.h"
#import "MHFacebookImageViewer.h"
#import "UIImageView+MHFacebookImageViewer.h"

@interface MyBuddiesViewController ()
{
    UIImageView *imgProfile;
    NSURL *profileURL;
}
@end

@implementation MyBuddiesViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [[MyWebSocket sharedInstance] connectSocket];
    [self.tabBarController.tabBar setHidden:NO];
    [self setFonts];
    [self callAPIMyBuddies];
}

- (void)setFonts
{
    _viewPopUp.layer.cornerRadius = 5;
    UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backSwipeAction)];
    [backSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:backSwipe];
    
    [_lblNavBar setFont:FONT_REGULAR(kNavigationFontSize)];
    
}

#pragma mark - gesture recognizer action

- (void)backSwipeAction
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self calculateHeightForPostRow:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayBuddies count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"MyBuddyCell" owner:self options:nil] lastObject];
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MyBuddyCell" owner:self options:nil];
    cell = [nib objectAtIndex:0];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    imgProfile = (UIImageView *)[cell.contentView viewWithTag:10];
    imgProfile.userInteractionEnabled = YES;
    imgProfile.contentMode = UIViewContentModeScaleAspectFill;

    UILabel *lblName = (UILabel *)[cell.contentView viewWithTag:11];
    UILabel *lblUniversity = (UILabel *)[cell.contentView viewWithTag:25];
    lblUniversity.hidden = YES;
    
    NSDictionary *tempDict = arrayBuddies[indexPath.row];
    
    if (indexPath.row % 2 == 0)
    {
        [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    }
    else
    {
        [cell.contentView setBackgroundColor:kGrayGolor];
    }
    NSString *imgname=[NSString stringWithFormat:@"%@",[tempDict objectForKeyNonNull:kBuddyImage]];
    [imgProfile setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImageURl,imgname]]placeholderImage:[UIImage imageNamed:@"gaust_user.png"]];
    [imgProfile setupImageViewerWithImageURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImageURl,imgname]]];    
    imgProfile.clipsToBounds = YES;

    
    UIButton *btnMessage = (UIButton*)[cell.contentView viewWithTag:12];
    [btnMessage addTarget:self action:@selector(btnMessageTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btnBlockBuddies = (UIButton*)[cell.contentView viewWithTag:13];
    [btnBlockBuddies addTarget:self action:@selector(btnBlockBuddiesTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[tempDict objectForKeyNonNull:@"isBlock"] isEqualToString:@"True"])
    {
        [btnBlockBuddies setSelected:YES];
    }
    
    [lblName setText:[tempDict objectForKeyNonNull:kBuddyName]];
    [lblName setFont:FONT_REGULAR(14)];
    
    [imgProfile.layer setCornerRadius:22];
    [imgProfile setClipsToBounds:YES];
    
    /************/
    
    /*
     "isCourseNoCommon" : "0",
     "isMajorCommon" : "1",
     "isClassTitleCommon" : "1",
     "isSectionCommon" : "1",
     "isUniversityCommon" : "1"
     */
    CGRect frame = lblUniversity.frame;
    
    if ([[tempDict objectForKeyNonNull:@"isMatched"] integerValue]>0) {
        
        //lblUniversity.hidden = NO;
        
        UILabel *lblMatched = [[UILabel alloc] initWithFrame:frame];
        
        UIFont * labelFont = FONT_BOLD(12);
        NSAttributedString *labelText = [[NSAttributedString alloc] initWithString : @"Matched : " attributes : @{NSFontAttributeName : labelFont,NSForegroundColorAttributeName : kBlueColor}];
        
        [lblMatched setAttributedText:labelText];
        [lblMatched sizeToFit];
        [cell addSubview:lblMatched];
        
        frame.origin.y = lblMatched.frame.size.height + lblMatched.frame.origin.y+5;
        
        if ([[tempDict objectForKeyNonNull:@"isMajorCommon"] integerValue] > 0) {
            UILabel *lblMajor = [[UILabel alloc] initWithFrame:frame];
            NSString *strMajor = @"Major : ";
            UIFont * labelFont = FONT_BOLD(12);
            
            NSMutableAttributedString *labelText = [[NSMutableAttributedString alloc] initWithString : strMajor attributes : @{NSFontAttributeName : labelFont, NSForegroundColorAttributeName : kLightGrayColor}];
            
            labelFont = FONT_REGULAR(12);
            NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString : [tempDict objectForKeyNonNull:@"major"] attributes : @{NSFontAttributeName : labelFont, NSForegroundColorAttributeName : [UIColor blackColor]}];
            
            [labelText appendAttributedString:attributedStr];
            
            [lblMajor setAttributedText:labelText];
            [lblMajor sizeToFit];
            [cell addSubview:lblMajor];
            frame.origin.y = lblMajor.frame.size.height + lblMajor.frame.origin.y+5;
        }
        
        if ([[tempDict objectForKeyNonNull:@"isUniversityCommon"] integerValue] > 0) {
            UILabel *labelUniversity = [[UILabel alloc] initWithFrame:frame];
            NSString *strUniversity = @"University : ";
            UIFont * labelFont = FONT_BOLD(12);
            
            NSMutableAttributedString *labelText = [[NSMutableAttributedString alloc] initWithString : strUniversity attributes : @{NSFontAttributeName : labelFont, NSForegroundColorAttributeName : kLightGrayColor}];
            
            labelFont = FONT_REGULAR(12);
            NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString : [tempDict objectForKeyNonNull:@"university"] attributes : @{NSFontAttributeName : labelFont, NSForegroundColorAttributeName : [UIColor blackColor]}];
            
            [labelText appendAttributedString:attributedStr];
            
            
            [labelUniversity setAttributedText:labelText];
            [labelUniversity sizeToFit];
            [cell addSubview:labelUniversity];
            frame.origin.y = labelUniversity.frame.size.height + labelUniversity.frame.origin.y+5;
        }
        
        if ([[tempDict objectForKeyNonNull:@"classCount"] integerValue]>0) {
            
            UILabel *lblClasses = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y+5, frame.size.width, frame.size.height)];
            
            NSString *strClasses = @"Classes : ";
            UIFont * labelFont = FONT_BOLD(12);
            
            NSAttributedString *labelText = [[NSAttributedString alloc] initWithString : strClasses attributes : @{NSFontAttributeName : labelFont, NSForegroundColorAttributeName : kLightGrayColor}];
            [lblClasses setAttributedText:labelText];
            [lblClasses sizeToFit];
            [cell addSubview:lblClasses];
            
            frame.origin.x = lblClasses.frame.size.width + frame.origin.x;
            
            UIButton *btnClassCount = [[UIButton alloc] initWithFrame:CGRectMake(frame.origin.x, lblClasses.frame.origin.y-5, 30, 20)];
            [btnClassCount setTitle:[tempDict objectForKeyNonNull:@"classCount"] forState:UIControlStateNormal];
            [btnClassCount addTarget:self action:@selector(btnClassCountTapped:) forControlEvents:UIControlEventTouchUpInside];
            [btnClassCount setBackgroundColor:kBlueColor];
            
            btnClassCount.layer.cornerRadius = 5;
            [btnClassCount setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btnClassCount.titleLabel setFont:FONT_BOLD(12)];
            
            //[btnClassCount sizeToFit];
            
            CGPoint centerPoint = btnClassCount.center;
            centerPoint.y = lblClasses.center.y;
            [btnClassCount setCenter:centerPoint];
            
            [cell addSubview:btnClassCount];
            
            frame.origin.y = lblClasses.frame.size.height + lblClasses.frame.origin.y+10;
        }
    } else {
      frame.origin.y = 59;
    }
    
    UIImageView *seperator = (UIImageView *)[cell.contentView viewWithTag:30];
    seperator.yOrigin = frame.origin.y ;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *tempDict = arrayBuddies[indexPath.row];
    ViewProfileViewController * viewProfile = [[ViewProfileViewController alloc]initWithNibName:@"ViewProfileViewController" bundle:nil];
    viewProfile.isViewProfile = YES;
    
    viewProfile.editProfile = YES;
    viewProfile.inviteButtonHidden = YES;
    [viewProfile setBuddyId:[tempDict objectForKeyNonNull:kBuddyId]];
    [self.navigationController pushViewController:viewProfile animated:YES];
    
}

#pragma mark - button action


- (float) calculateHeightForPostRow:(NSIndexPath*)index
{
    
    UITableViewCell *cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"MyBuddyCell" owner:self options:nil] lastObject];
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MyBuddyCell" owner:self options:nil];
    cell = [nib objectAtIndex:0];
    UILabel *lblUniversity = (UILabel *)[cell.contentView viewWithTag:25];
    NSDictionary *tempDict = arrayBuddies[index.row];
    CGRect frame = lblUniversity.frame;
    NSInteger cellHeight = 65;
  
    if ([[tempDict objectForKeyNonNull:@"isMatched"] integerValue]>0) {
        
        UILabel *lblMatched = [[UILabel alloc] initWithFrame:frame];
        
        UIFont * labelFont = FONT_BOLD(12);
        NSAttributedString *labelText = [[NSAttributedString alloc] initWithString : @"Matched : " attributes : @{NSFontAttributeName : labelFont,NSForegroundColorAttributeName : kBlueColor}];
        
        [lblMatched setAttributedText:labelText];
        [lblMatched sizeToFit];
        [cell addSubview:lblMatched];
        
        frame.origin.y = lblMatched.frame.size.height + lblMatched.frame.origin.y+5;
        
        if ([[tempDict objectForKeyNonNull:@"isMajorCommon"] integerValue] > 0) {
            UILabel *lblMajor = [[UILabel alloc] initWithFrame:frame];
            NSString *strMajor = @"Major : ";
            
            UIFont * labelFont = FONT_BOLD(12);
            NSMutableAttributedString *labelText = [[NSMutableAttributedString alloc] initWithString : strMajor attributes : @{NSFontAttributeName : labelFont, NSForegroundColorAttributeName : kLightGrayColor}];
            
            labelFont = FONT_REGULAR(12);
            NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString : [tempDict objectForKeyNonNull:@"major"] attributes : @{NSFontAttributeName : labelFont, NSForegroundColorAttributeName : [UIColor blackColor]}];
            
            [labelText appendAttributedString:attributedStr];
            
            [lblMajor setAttributedText:labelText];
            [lblMajor sizeToFit];
            [cell addSubview:lblMajor];
            frame.origin.y = lblMajor.frame.size.height + lblMajor.frame.origin.y+5;
        }
        
        if ([[tempDict objectForKeyNonNull:@"isUniversityCommon"] integerValue] > 0) {
            UILabel *labelUniversity = [[UILabel alloc] initWithFrame:frame];
            NSString *strUniversity = @"University : ";
            
            UIFont * labelFont = FONT_BOLD(12);
            NSMutableAttributedString *labelText = [[NSMutableAttributedString alloc] initWithString : strUniversity attributes : @{NSFontAttributeName : labelFont, NSForegroundColorAttributeName : kLightGrayColor}];
            
            labelFont = FONT_REGULAR(12);
            NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString : [tempDict objectForKeyNonNull:@"university"] attributes : @{NSFontAttributeName : labelFont, NSForegroundColorAttributeName : [UIColor blackColor]}];
            
            [labelText appendAttributedString:attributedStr];
            
            
            [labelUniversity setAttributedText:labelText];
            [labelUniversity sizeToFit];
            [cell addSubview:labelUniversity];
            frame.origin.y = labelUniversity.frame.size.height + labelUniversity.frame.origin.y+5;
        }
        
        if ([[tempDict objectForKeyNonNull:@"classCount"] integerValue]>0) {
            
            UILabel *lblClasses = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y+5, frame.size.width, frame.size.height)];
            
            NSString *strClasses = @"Classes : ";
            UIFont * labelFont = FONT_BOLD(12);
            NSAttributedString *labelText = [[NSAttributedString alloc] initWithString : strClasses attributes : @{NSFontAttributeName : labelFont, NSForegroundColorAttributeName : kGrayGolor}];
            [lblClasses setAttributedText:labelText];
            [lblClasses sizeToFit];
            [cell addSubview:lblClasses];
            
            frame.origin.x = lblClasses.frame.size.width + frame.origin.x;
            
            UIButton *btnClassCount = [[UIButton alloc] initWithFrame:CGRectMake(frame.origin.x, lblClasses.frame.origin.y-5, 30,20)];
            [btnClassCount setTitle:[tempDict objectForKeyNonNull:@"classCount"] forState:UIControlStateNormal];
            [btnClassCount addTarget:self action:@selector(btnClassCountTapped:) forControlEvents:UIControlEventTouchUpInside];
            btnClassCount.layer.cornerRadius = 5;
            // [btnClassCount sizeToFit];
            
            CGPoint centerPoint = btnClassCount.center;
            centerPoint.y = lblClasses.center.y;
            [btnClassCount setCenter:centerPoint];
            
            [cell addSubview:btnClassCount];
            
            frame.origin.y = lblClasses.frame.size.height + lblClasses.frame.origin.y+10;
        }
      
      
      cellHeight = frame.origin.y;
    } else {
      cellHeight = 60;
    }
    
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    cell = nil;
    
    return cellHeight;
    
}

- (void)btnClassCountTapped:(UIButton*)sender
{
    [_viewInner setHidden:NO];
    UITableViewCell *cell;
    
    if (SYSTEM_VERSION_LESSER_THAN(@"7.0") || SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        cell = (UITableViewCell *)sender.superview;
        NSLog(@"iOS Version not equal to 7");
    }
    else
    {
        cell = (UITableViewCell *)sender.superview.superview;
        NSLog(@"iOS Version  7");
    }
    NSIndexPath *indexPath = [_tblViewMyBuddies indexPathForCell:cell];
    
    NSDictionary *tempDict = arrayBuddies[indexPath.row];
    NSLog(@"\n\n\nAt Index %ld ,\n Temp Dict : %@\n\n\n",(long)indexPath.row,tempDict);
    NSString *strClassTitle = [tempDict objectForKeyNonNull:@"classTitles"];
    NSString *strCourse = [tempDict objectForKeyedSubscript:@"courseNumbers"];
    NSString *strSection = [tempDict objectForKeyNonNull:@"sections"];
    
    
    CGRect frame = CGRectMake(0, 30, _viewPopUp.frame.size.width - 40, 10);
    
    if (![strClassTitle isEqualToString:@""]) {
        frame.origin.x = _viewPopUp.frame.origin.x;
        UILabel *lblClassTitles = [[UILabel alloc] initWithFrame:CGRectMake(10, frame.origin.y, frame.size.width, frame.size.height)];
        lblClassTitles.numberOfLines = 0;
        NSString *strClassTitles = @"ClassTitle : ";
        
        UIFont * labelFont = FONT_BOLD(12);
        NSMutableAttributedString *labelText = [[NSMutableAttributedString alloc] initWithString : strClassTitles attributes : @{NSFontAttributeName : labelFont, NSForegroundColorAttributeName : kLightGrayColor}];
        
        
        [lblClassTitles setAttributedText:labelText];
        [lblClassTitles sizeToFit];
        [_viewPopUp addSubview:lblClassTitles];
        
        frame.origin.x = lblClassTitles.frame.origin.x + lblClassTitles.frame.size.width;
        frame.size.width = _viewPopUp.frame.size.width - lblClassTitles.frame.size.width - 15;
        UILabel *lblClassTitleValues = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
        lblClassTitleValues.lineBreakMode = NSLineBreakByWordWrapping;
        lblClassTitleValues.numberOfLines = 0;
        
        
        labelFont = FONT_REGULAR(12);
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString : [tempDict objectForKeyNonNull:@"classTitles"] attributes : @{NSFontAttributeName : labelFont, NSForegroundColorAttributeName : [UIColor blackColor]}];
        
        // [labelText appendAttributedString:attributedStr];
        
        [lblClassTitleValues setAttributedText:attributedStr];
        [lblClassTitleValues sizeToFit];
        [_viewPopUp addSubview:lblClassTitleValues];
        
        frame.origin.y = lblClassTitleValues.frame.size.height + lblClassTitleValues.frame.origin.y+15;
        
        UILabel *lblSeperator = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.origin.y, _viewPopUp.frame.size.width, 1)];
        [lblSeperator setBackgroundColor:kLightGrayColor];
        [_viewPopUp addSubview:lblSeperator];
        frame.origin.y = lblSeperator.frame.size.height + lblSeperator.frame.origin.y+10;
        _viewPopUp.frame = CGRectMake(_viewPopUp.frame.origin.x, _viewPopUp.frame.origin.y, _viewPopUp.frame.size.width, frame.origin.y);
    }
    
    if (![strCourse isEqualToString:@""]) {
        frame.origin.x = _viewPopUp.frame.origin.x;
        UILabel *lblCourseNumber = [[UILabel alloc] initWithFrame:CGRectMake(10, frame.origin.y, frame.size.width, frame.size.height)];
        lblCourseNumber.numberOfLines = 0;
        NSString *strCourseNumber = @"CourseNumber : ";
        
        UIFont * labelFont = FONT_BOLD(12);
        NSMutableAttributedString *labelText = [[NSMutableAttributedString alloc] initWithString : strCourseNumber attributes : @{NSFontAttributeName : labelFont, NSForegroundColorAttributeName : kLightGrayColor}];
        
        [lblCourseNumber setAttributedText:labelText];
        [lblCourseNumber sizeToFit];
        [_viewPopUp addSubview:lblCourseNumber];
        
        frame.origin.x = lblCourseNumber.frame.origin.x + lblCourseNumber.frame.size.width;
        frame.size.width = _viewPopUp.frame.size.width - lblCourseNumber.frame.size.width - 15;
        UILabel *lblCourseNumberValues = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
        lblCourseNumberValues.lineBreakMode = NSLineBreakByWordWrapping;
        lblCourseNumberValues.numberOfLines = 0;
        
        labelFont = FONT_REGULAR(12);
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString : [tempDict objectForKeyNonNull:@"courseNumbers"] attributes : @{NSFontAttributeName : labelFont, NSForegroundColorAttributeName : [UIColor blackColor]}];
        
        //[labelText appendAttributedString:attributedStr];
        
        [lblCourseNumberValues setAttributedText:attributedStr];
        [lblCourseNumberValues sizeToFit];
        [_viewPopUp addSubview:lblCourseNumberValues];
        
        frame.origin.y = lblCourseNumberValues.frame.size.height + lblCourseNumberValues.frame.origin.y+15;
        
        UILabel *lblSeperator = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.origin.y, _viewPopUp.frame.size.width, 1)];
        [lblSeperator setBackgroundColor:kLightGrayColor];
        [_viewPopUp addSubview:lblSeperator];
        
        frame.origin.y = lblSeperator.frame.size.height + lblSeperator.frame.origin.y+10;
        _viewPopUp.frame = CGRectMake(_viewPopUp.frame.origin.x, _viewPopUp.frame.origin.y, _viewPopUp.frame.size.width, frame.origin.y);
    }
    if (![strSection isEqualToString:@""]) {
        frame.origin.x = _viewPopUp.frame.origin.x;
        UILabel *lblSection = [[UILabel alloc] initWithFrame:CGRectMake(10, frame.origin.y, frame.size.width, frame.size.height)];
        lblSection.numberOfLines = 0;
        NSString *strSections = @"Section : ";
        
        UIFont * labelFont = FONT_BOLD(12);
        NSMutableAttributedString *labelText = [[NSMutableAttributedString alloc] initWithString : strSections attributes : @{NSFontAttributeName : labelFont, NSForegroundColorAttributeName : kLightGrayColor}];
        
        [lblSection setAttributedText:labelText];
        [lblSection sizeToFit];
        [_viewPopUp addSubview:lblSection];
        
        frame.origin.x = lblSection.frame.origin.x + lblSection.frame.size.width;
        frame.size.width = _viewPopUp.frame.size.width - lblSection.frame.size.width - 15;
        
        UILabel *lblSectionValues = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
        lblSectionValues.lineBreakMode = NSLineBreakByWordWrapping;
        lblSectionValues.numberOfLines = 0;
        
        labelFont = FONT_REGULAR(12);
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString : [tempDict objectForKeyNonNull:@"sections"] attributes : @{NSFontAttributeName : labelFont, NSForegroundColorAttributeName : [UIColor blackColor]}];
        
        //[labelText appendAttributedString:attributedStr];
        
        [lblSectionValues setAttributedText:attributedStr];
        [lblSectionValues sizeToFit];
        [_viewPopUp addSubview:lblSectionValues];
        
        frame.origin.y = lblSectionValues.frame.size.height + lblSectionValues.frame.origin.y+15;
        
        UILabel *lblSeperator = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.origin.y, _viewPopUp.frame.size.width, 1)];
        [lblSeperator setBackgroundColor:kLightGrayColor];
        [_viewPopUp addSubview:lblSeperator];
        frame.origin.y = lblSeperator.frame.size.height + lblSeperator.frame.origin.y+10;
        _viewPopUp.frame = CGRectMake(_viewPopUp.frame.origin.x, _viewPopUp.frame.origin.y, _viewPopUp.frame.size.width, frame.origin.y);
    }
}


- (void)btnBlockBuddiesTapped:(UIButton*)sender withEvent:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:_tblViewMyBuddies];
    NSIndexPath *indexPath = [_tblViewMyBuddies indexPathForRowAtPoint: currentTouchPosition];
    if ([[[arrayBuddies objectAtIndex:indexPath.row] objectForKey:kIsBlock] isEqualToString:@"True"])
    {
        [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"Are you sure you want to unblock this user?" leftButtonTitle:@"Yes" rightButtonTitle:@"Cancel" selectedButton:^(NSInteger selected, UIAlertView *aView)
         {
             if (selected == 0)
             {
                 [self callAPIBlockBuddyWithBuddyId:[[arrayBuddies objectAtIndex:indexPath.row] objectForKey:kBuddyId] blockUser:NO];
             }
         }];
    }
    else
    {
        [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"Are you sure you want to block this user?" leftButtonTitle:@"Yes" rightButtonTitle:@"Cancel" selectedButton:^(NSInteger selected, UIAlertView *aView)
         {
             if (selected == 0)
             {
                 [self callAPIBlockBuddyWithBuddyId:[[arrayBuddies objectAtIndex:indexPath.row] objectForKey:kBuddyId] blockUser:YES];
             }
         }];
    }
    
}

- (void)btnMessageTapped:(UIButton*)sender withEvent:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:_tblViewMyBuddies];
    NSIndexPath *indexPath = [_tblViewMyBuddies indexPathForRowAtPoint: currentTouchPosition];
    NSDictionary *dictBuddyDetails = @{kBuddyId: [[arrayBuddies objectAtIndex:indexPath.row] objectForKey:kBuddyId],kBuddyName:[[arrayBuddies objectAtIndex:indexPath.row] objectForKey:kBuddyName],kBuddyImage:[[arrayBuddies objectAtIndex:indexPath.row] objectForKey:kBuddyImage]};
    ChatScreenViewController *chatScreenViewC = [[ChatScreenViewController alloc] initWithNibName:@"ChatScreenViewController" bundle:nil];
    [chatScreenViewC setDictBuddyInfo:dictBuddyDetails];
    [chatScreenViewC setHidesBottomBarWhenPushed:YES];
    [chatScreenViewC setIsGroup:NO];
    [self.navigationController pushViewController:chatScreenViewC animated:YES];
}

- (IBAction)btnBacktapped:(id)sender
{
    [self backSwipeAction];
}

- (IBAction)btnFindBuddiesTapped:(UIButton *)sender
{
    //    FindBuddiesViewController *findBuddiesViewController = [[FindBuddiesViewController alloc] initWithNibName:@"FindBuddiesViewController" bundle:nil];
    //
    //    [self.navigationController pushViewController:findBuddiesViewController animated:YES];
    AddContactFriendsViewController *addFriends = [[AddContactFriendsViewController alloc] initWithNibName:@"AddContactFriendsViewController" bundle:nil];
    [self.navigationController pushViewController:addFriends animated:YES];
}

- (IBAction)tapClose:(id)sender {
    [_viewInner setHidden:YES];
    [_viewPopUp.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
}

#pragma mark - web service
- (void)callAPIBlockBuddyWithBuddyId:(NSString*)buddyId blockUser:(BOOL)isBlock
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
                              buddyId,kBuddyId,
                              isBlock?@"True":@"False",kIsBlock,
                              nil];
    [Utils startLoaderWithMessage:@""];
    
    [Connection callServiceWithName:kBlockBuddy postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         [Utils stopLoader];
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 [self callAPIMyBuddies];
             }
         }
     }];
}


- (void)callAPIMyBuddies
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
                              nil];
    [Utils startLoaderWithMessage:@""];
    
    [Connection callServiceWithName:kGetMyBuddiesList postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         [Utils stopLoader];
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 arrayBuddies = nil;
                 arrayBuddies = [[NSArray alloc] initWithArray:[response objectForKeyNonNull:kResult]];
                 [_tblViewMyBuddies reloadData];
                 if([arrayBuddies count] == 0)
                 {
                     [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"You have no buddies yet. \nFind Buddies Now?" leftButtonTitle:@"Yes" rightButtonTitle:@"No" selectedButton:^(NSInteger selected, UIAlertView *aView)
                      {
                          if(selected == 0)
                          {
                              FindBuddiesViewController *findBuddiesViewController = [[FindBuddiesViewController alloc]initWithNibName:@"FindBuddiesViewController" bundle:nil];
                              [self.navigationController pushViewController:findBuddiesViewController animated:YES];
                              //                              FindBuddiesViewController *findBuddiesViewController = [[FindBuddiesViewController alloc] initWithNibName:@"FindBuddiesViewController" bundle:nil];
                              //                              [self.navigationController pushViewController:findBuddiesViewController animated:YES];
                          }
                          if(selected == 1)
                          {
                              //[self.tabBarController setSelectedIndex:2];
                          }
                      }];
                 }
             }
         }
         
     }];
}

- (void)callAPIFindBuddies
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
                              @"0",kPage,
                              nil];
    [Utils startLoaderWithMessage:@""];
    [Connection callServiceWithName:kFindBuddies postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         [Utils stopLoader];
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
               if ([[response objectForKeyNonNull:kResult] isKindOfClass:[NSArray class]])
               {
                 
                 NSArray *array = [[NSArray alloc] initWithArray:[response objectForKeyNonNull:kResult]];
                 if ([array count] > 0)
                 {
                   
                   arrayBuddies = nil;
                   arrayBuddies = [[NSArray alloc] initWithArray:array];
                   
                 }
                 else {
                   [Utils showAlertViewWithMessage:@"No Suggestions Yet!!"];
                 }
               }
                 [_tblViewMyBuddies reloadData];
             }
         }
     }];
}


@end
