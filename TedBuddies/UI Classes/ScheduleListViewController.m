//
//  ScheduleListViewController.m
//  TedBuddies
//
//  Created by Sunil on 09/09/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import "ScheduleListViewController.h"
#import "ScheduleClassViewController.h"
#import "UITabBarController+HideTabBar.h"
#import "UIImage+animatedGIF.h"



@interface ScheduleListViewController ()

@end

@implementation ScheduleListViewController

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
    self.tblViewScheduleList.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
    [self setFonts];
    

    
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController setTabBarHidden:YES];

}

- (void)viewDidAppear:(BOOL)animated
{
    [self callAPtAllScheduledClassList];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - other methods

- (void)setFonts
{
    UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backSwipeAction)];
    [backSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:backSwipe];
}

#pragma mark - gesture recognizer action

- (void)backSwipeAction
{
    //[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Web Service

- (void)callAPtAllScheduledClassList
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
                              nil];
    
    [self startLoad];
    [Connection callServiceWithName:kGetAllScheduledClassList postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         [self stopLoad];
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 arrayScheduleList =nil;
                 arrayScheduleList = [[NSArray alloc] initWithArray:[response objectForKeyNonNull:kResult]];
                NSLog(@"%d",[defaults boolForKey:kiisclassuploaded]);
                 if (arrayScheduleList.count!=0)
                 {
                   
                    [defaults setObject:@"True" forKey:kiisclassuploaded];
                     NSLog(@"%d",[defaults boolForKey:kiisclassuploaded]);
                     
                 }
                else
                {
                       [Utils showAlertViewWithMessage:@"No Class Schedule Uploaded Yet!!"];
                }

                [_tblViewScheduleList reloadData];
             }
         }
     }];
}

#pragma mark - Tabel View Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayScheduleList count];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"ScheduleListCell" owner:self options:nil] lastObject];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _tempDict = arrayScheduleList[indexPath.row];
    
//    UILabel *lblClassName = (UILabel *)[cell.contentView viewWithTag:11];
//    lblClassName.text=[_tempDict objectForKey:@"classTitle"];
//    
    
    UILabel *lblProfessor = (UILabel *)[cell.contentView viewWithTag:15];
    NSString * strProfessor = [NSString stringWithFormat:@"%@",[_tempDict objectForKey:kCourseNo]];
    lblProfessor.text=strProfessor;
 
    
    UILabel *lblSection = (UILabel *)[cell.contentView viewWithTag:14];
    NSString * strSection=[_tempDict objectForKey:@"sectionName"];
    if ([strSection isEqual: [NSNull null]])
    {
         strSection = [NSString stringWithFormat:@"Section - "];
    }
   else
   {
       strSection = [NSString stringWithFormat:@"Section %@",[_tempDict objectForKey:@"sectionName"]];
   }
    lblSection.text = strSection;
 

     UIButton *btnEdit = (UIButton*)[cell.contentView viewWithTag:16];
     UIButton *btnDelete = (UIButton*)[cell.contentView viewWithTag:17];
    
    if([arrayScheduleList count] == 1 )
    {
        btnDelete.hidden = YES;
        
    }
    
    btnEdit.tag = indexPath.row+10;
    [btnEdit addTarget:self action:@selector(editClassButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    btnDelete.tag = indexPath.row+10;
    [btnDelete addTarget:self action:@selector(deleteClassButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - button action

- (IBAction)btnCreateScheduleTapped:(id)sender
{
    ScheduleClassViewController *scheduleClass = [[ScheduleClassViewController alloc]initWithNibName:@"ScheduleClassViewController" bundle:Nil];
    
    [scheduleClass setIsOnlySchedule:YES];
    [scheduleClass setScheduledClassId:@""];
    
    [self.navigationController pushViewController:scheduleClass animated:YES];
}

- (IBAction)btnBackTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)editClassButtonClick:(UIButton *)btn
{
    ScheduleClassViewController *scheduleClass = [[ScheduleClassViewController alloc]initWithNibName:@"ScheduleClassViewController" bundle:Nil];
    [scheduleClass setIsOnlySchedule:YES];
    [scheduleClass setScheduledClassId:[[arrayScheduleList objectAtIndex:btn.tag-10] objectForKeyNonNull:@"ShedClsId"]];
    [scheduleClass setDictScheduleClass:[arrayScheduleList objectAtIndex:btn.tag-10]];
    scheduleClass.isAlive = TRUE;
    scheduleClass.dictEditScheduleClass = [arrayScheduleList objectAtIndex:btn.tag-10];
    [self.navigationController pushViewController:scheduleClass animated:YES];
}

- (void)deleteClassButtonClick:(UIButton *)btn
{
    [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"Are you sure you want to delete this schedule class?" leftButtonTitle:@"Yes" rightButtonTitle:@"No" selectedButton:^(NSInteger selected, UIAlertView *aView)
     {
         if(selected == 0)
         {
             [self callAPIDeleteClass:btn.tag-10];
         }
     }];
}

- (void)callAPIDeleteClass:(int)index1
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"1",@"Type",
                              [[arrayScheduleList objectAtIndex:index1] objectForKeyNonNull:@"ShedClsId"],@"ShedClsId",
                              nil];
    
    [self startLoad];
    
    [Connection callServiceWithName:kSchedClassAction postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         
         [self stopLoad];
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 [self callAPtAllScheduledClassList];
             }
         }
     }];
}
#pragma mark - Loader
- (void)startLoad
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

- (void)stopLoad
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
