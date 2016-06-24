//
//  HomeViewController.m
//  TedBuddies
//
//  Created by Sunil on 08/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import "HomeViewController.h"
#import "PreferenceSettingViewController.h"
#import "LoginViewController.h"
#import "FindBuddiesViewController.h"
#import "PostViewController.h"
#import "MarketPlaceViewController.h"
#import "MessagesViewController.h"
#import "ListingDaetailsViewController.h"
#import "PendingRequestsViewController.h"
#import "ScheduleListViewController.h"
#import "ViewProfileViewController.h"
#import "SettingViewController.h"
#import "Shared.h"
#import "SWRevealViewController.h"
#import "UITabBarController+HideTabBar.h"
#import "MIBadgeButton.h"
#import "CustomIOSAlertView.h"

typedef void(^myCompletion)(BOOL);

@interface HomeViewController ()
{
    SWRevealViewController *revealController;
}
// Adding right pane controller
@property (nonatomic, assign) BOOL showingLeftPanel;
@property (nonatomic, assign) BOOL showingRightPanel;
@property (nonatomic, assign) BOOL showPanel;
@property (nonatomic, assign) CGPoint preVelocity;
@property (nonatomic , strong) PreferenceSettingViewController *preferenceStngObj;
@property (nonatomic , assign) NSInteger tagOfButtonTapped;
@property (nonatomic , assign) BOOL oneTime;
@end

@implementation HomeViewController



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
    [self.btnCircleDot setHidden:YES];
    _oneTime = FALSE;
    
    
    //[_btnCircleDot setHidden:YES];
    revealController = [self revealViewController];
    //self.hidesBottomBarWhenPushed = YES;
    self.tabBarController.tabBarHidden = YES;
    //http://nickwaynik.com/iphone/hide-tabbar-in-an-ios-app/
    [self setFont];
    
    
 
  
   
    

    // Do any additional setup after loading the view from its nib.
}
- (void) configureButton:(MIBadgeButton *) button withBadge:(NSString *) badgeString {
    //[button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    // optional to change the default position of the badge
    [button setBadgeEdgeInsets:UIEdgeInsetsMake(8, 5, 0, 8)];
    button.badgeBackgroundColor = [UIColor redColor];
    [button setBadgeString:badgeString];
}

-(void)doAnimation
{
    __weak HomeViewController *weakSelf = self;

    [self bringViewButtons:_btnBuddies completion:^{
        [weakSelf animateUIComponent:_btnBuddies];
    }];
    [self bringViewButtons:_btnMarketPlace completion:^{
        [weakSelf animateUIComponent:_btnMarketPlace];
    }];
    [self bringViewButtons:_btnPost completion:^{
        [weakSelf animateUIComponent:_btnPost];
    }];
    [self bringViewButtons:_btnMessage completion:^{
        [weakSelf animateUIComponent:_btnMessage];
    }];
    [self bringViewButtons:_btnPendingRequest completion:^{
        [weakSelf animateUIComponent:_btnPendingRequest];
    }];
    [self bringViewButtons:_btnSchedule completion:^{
        [weakSelf animateUIComponent:_btnSchedule];
    }];
}

// first call to hide circledot button as soon as removeanimation is tapped.
// remove dotted circle

-(void)removeAnimation:(UIButton *)btn
{
    // instantaneously make the image view small (scaled to 1% of its actual size)
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // bring Closer and in completion reset to original frame.
        //Animations
        if ((UIButton *)btn == _btnMessage) {
            // you have clicked button 1
            btn.center = CGPointMake(self.view.center.x - 50, self.view.center.y - 50);
        }
        if ((UIButton *)btn == _btnMarketPlace) {
            // you have clicked button 1
            NSLog(@"hereinmarketPlace");
            btn.center = CGPointMake(self.view.center.x - 10,self.view.center.y  + 50);
        }
        if ((UIButton *)btn == _btnPendingRequest) {
            // you have clicked button 1
            btn.center = CGPointMake(self.view.center.x + 0, self.view.center.y +50);
        }

        if ((UIButton *)btn == _btnBuddies) {
            // you have clicked button 1
            btn.center = CGPointMake(self.view.center.x, self.view.center.y);
        }
        if ((UIButton *)btn == _btnSchedule) {
            // you have clicked button 1
            btn.center = CGPointMake(self.view.center.x - 50,self.view.center.y +40);
        }
        if ((UIButton *)btn == _btnPost) {
            // you have clicked button 1
            btn.center = CGPointMake(self.view.center.x +50, self.view.center.y);
        }
        } completion:^(BOOL finished){
        //btn.transform = CGAffineTransformMakeScale(0.01, 0.01);

        [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            //Animations
            if ((UIButton *)btn == _btnMessage) {
                // you have clicked button 1
                btn.center = CGPointMake(-53.00, 271);
            }
            if ((UIButton *)btn == _btnBuddies) {
                // you have clicked button 1
                btn.center = CGPointMake(84.50, 649.50);
            }
            if ((UIButton *)btn == _btnSchedule) {
                // you have clicked button 1
                btn.center = CGPointMake(-59.50,384.00);
            }
            if ((UIButton *)btn == _btnPost) {
                // you have clicked button 1
                btn.center = CGPointMake(390.00,270.00);
            }
            if ((UIButton *)btn == _btnMarketPlace) {
                // you have clicked button 1
                NSLog(@"hereinmarketPlaceremoved");
                btn.center = CGPointMake(365.00,635.00);
            }
            if ((UIButton *)btn == _btnPendingRequest) {
                // you have clicked button 1
                btn.center = CGPointMake(396.00,409.00);
            }

        } completion:^(BOOL finished){
            if(finished)
            {
                
                if(_tagOfButtonTapped == 95)
                {
                    NSLog(@"finished buddy");
                    NSLog(@"_btnBuddieshere");
                    if([[defaults objectForKey:kUserId] isEqualToString:@"0"])
                    {
                        [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"Kindly login to use this feature" leftButtonTitle:@"OK" rightButtonTitle:@"Cancel" selectedButton:^(NSInteger selected, UIAlertView *aView)
                         {
                             if (selected == 0)
                             {
                                 [SharedAppDelegate removeTabBarScreen];
                             }
                         }];
                    }
                    else
                    {
                        [self.tabBarController setSelectedIndex:1];
                        [Utils setTabBarImage:@"tab2.png"];

                    }
                    
                    

                }
                if(_tagOfButtonTapped == 97)
                {
                    
                    NSLog(@"_btnPostHere");
                    if([[defaults objectForKey:kUserId] isEqualToString:@"0"])
                    {
                        [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"Kindly login to use this feature" leftButtonTitle:@"OK" rightButtonTitle:@"Cancel" selectedButton:^(NSInteger selected, UIAlertView *aView)
                         {
                             if (selected == 0)
                             {
                                 [SharedAppDelegate removeTabBarScreen];
                             }
                         }];
                    }
                    else
                    {
                        [self.tabBarController setSelectedIndex:0];
                        [Utils setTabBarImage:@"tab1.png"];

                    }
                 
                    
                }
                if(_tagOfButtonTapped == 98)
                {
                    //[self defaultBtnState];
                    if([[defaults objectForKey:kUserId] isEqualToString:@"0"])
                    {
                        [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"Kindly login to use this feature" leftButtonTitle:@"OK" rightButtonTitle:@"Cancel" selectedButton:^(NSInteger selected, UIAlertView *aView)
                         {
                             if (selected == 0)
                             {
                                 [SharedAppDelegate removeTabBarScreen];
                             }
                         }];
                    }
                    else
                    {
                        if(!_oneTime)
                        {
                            _oneTime = TRUE;
                            PendingRequestsViewController *pendingRequest = [[PendingRequestsViewController alloc] initWithNibName:@"PendingRequestsViewController" bundle:nil];
                            pendingRequest.hidesBottomBarWhenPushed=YES;
                            [self.navigationController pushViewController:pendingRequest animated:YES];
                        }
                        
                    }
                }
                if(_tagOfButtonTapped == 93)
                {
                   
                    [self.tabBarController setSelectedIndex:3];
                    [Utils setTabBarImage:@"tab4.png"];

                    
                }
                if(_tagOfButtonTapped == 92)
                {
                    //[self defaultBtnState];
                    if([[defaults objectForKey:kUserId] isEqualToString:@"0"])
                    {
                        [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"Kindly login to use this feature" leftButtonTitle:@"OK" rightButtonTitle:@"Cancel" selectedButton:^(NSInteger selected, UIAlertView *aView)
                         {
                             if (selected == 0)
                             {
                                 [SharedAppDelegate removeTabBarScreen];
                             }
                         }];
                    }
                    else
                    {
                        if(!_oneTime)
                        {
                            _oneTime = TRUE;
                            ScheduleListViewController *scheduleClassList = [[ScheduleListViewController alloc] initWithNibName:@"ScheduleListViewController" bundle:nil];
                            [scheduleClassList setHidesBottomBarWhenPushed:YES];
                            // [scheduleClassList setIsOnlySchedule:YES];
                            [self.navigationController pushViewController:scheduleClassList animated:YES];
                        }
                        
                        
                    }

                }
                if(_tagOfButtonTapped == 96)
                {
                   
                    if([[defaults objectForKey:kUserId] isEqualToString:@"0"])
                    {
                        [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"Kindly login to use this feature" leftButtonTitle:@"OK" rightButtonTitle:@"Cancel" selectedButton:^(NSInteger selected, UIAlertView *aView)
                         {
                             if (selected == 0)
                             {
                                 [SharedAppDelegate removeTabBarScreen];
                             }
                         }];
                    }
                    else
                    {
                        [self.tabBarController setSelectedIndex:4];
                        [Utils setTabBarImage:@"tab5.png"];

                    }
                  
                    
                }
                
            }
                 
        }];
        
        // if you want to do something once the animation finishes, put it here
        //First block completion
       //btn.transform = CGAffineTransformIdentity;
    }];
}

-(void)bringViewButtons:(UIButton *)viewButtons completion:(void (^)(void))completionBlock
{
    //CGFloat dampingValue;
    // instantaneously make the image view small (scaled to 1% of its actual size)
    viewButtons.transform = CGAffineTransformMakeScale(0.01, 0.01);
//    if ((UIButton *)viewButtons == _btnBuddies) {
//        dampingValue = 0.8;
//    }
//    else
//        dampingValue = 0.8;
    
    [UIView animateWithDuration:2.0
                          delay:0.0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.8
                        options:0 animations:^{
                            //Animations
                            if ((UIButton *)viewButtons == _btnMessage) {
                                // you have clicked button 1
                                viewButtons.center = CGPointMake(90.00, 230.00);
                            }
                            if ((UIButton *)viewButtons == _btnBuddies) {
                                // you have clicked button 1
                                viewButtons.center = CGPointMake(165.00, 314.00);
                            }
                            if ((UIButton *)viewButtons == _btnSchedule) {
                                // you have clicked button 1
                                viewButtons.center = CGPointMake(64.50, 350.00);
                                //[_btnCircleDot setHidden:NO];
                            }
                            if ((UIButton *)viewButtons == _btnPost) {
                                // you have clicked button 1
                                viewButtons.center = CGPointMake(240.00, 233.00);
                            }
                            if ((UIButton *)viewButtons == _btnMarketPlace) {
                                // you have clicked button 1
                                viewButtons.center = CGPointMake(151.00, 432.00);
                            }
                            if ((UIButton *)viewButtons == _btnPendingRequest) {
                                // you have clicked button 1
                                viewButtons.center = CGPointMake(250.00, 359.00);
                            }

                            // animate it to the identity transform (100% scale)
                            viewButtons.transform = CGAffineTransformIdentity;

                        }
                     completion:^(BOOL finished) {
//                         if ((UIButton *)viewButtons == _btnMessage) {
//                             [self animateUIComponent:_btnBuddies];
//                             [self animateUIComponent:_btnMarketPlace];
//                             [self animateUIComponent:_btnPost];
//                             [self animateUIComponent:_btnMessage];
//                             [self animateUIComponent:_btnPendingRequest];
//                             [self animateUIComponent:_btnSchedule];
//
//                         }
//                         //Completion Block
//                         NSLog(@"centre of message button x= %f and y =%f",self.btnMessage.center.x,self.btnMessage.center.y);
//                         NSLog(@"centre of buddies button x= %f and y =%f",self.btnBuddies.center.x,self.btnBuddies.center.y);
//                         NSLog(@"centre of post button x= %f and y =%f",self.btnPost.center.x,self.btnPost.center.y);
//                         NSLog(@"centre of btnSchedule button x= %f and y =%f",self.btnSchedule.center.x,self.btnSchedule.center.y);
//                         NSLog(@"centre of btnMarketPlace button x= %f and y =%f",self.btnMarketPlace.center.x,self.btnMarketPlace.center.y);
//                         NSLog(@"centre of btnPendingRequest button x= %f and y =%f",self.btnPendingRequest.center.x,self.btnPendingRequest.center.y);

                     }];

    
}
- (void)viewWillDisappear:(BOOL)animated {
    self.tabBarController.tabBarHidden = NO;

    _oneTime = FALSE;
    if(_btnMessage.frame.origin.x > 0)
    {
        // removingAfterDissapearcall
        [self removeAnimationFromViewwithcompletion:^(BOOL finished) {
            if(finished)
                _oneTime = FALSE;
        }];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    _tagOfButtonTapped = 0;

    self.hidesBottomBarWhenPushed = YES;
    [self performSelector:@selector(doAnimation) withObject:nil afterDelay:0.0];

    [self.tabBarController setTabBarHidden:YES animated:NO];

    // FOR GOOGLE ANALYTICS
    
    self.screenName = @"Home Screen";
    
    
    
    //set tutorials screens
    if (![defaults boolForKey:kMarketPlaceTutorial]) {
        
        [[Shared sharedInst] showImageWithImageName:@"tutorialMarketPlace"];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
        tapGesture.numberOfTapsRequired = 1;
        [[Shared sharedInst].viewImg addGestureRecognizer:tapGesture];
    }
//    CGRect biggerFrame = self.tabBarController.view.frame;
//    biggerFrame.size.height += self.tabBarController.tabBar.frame.size.height;
//    self.tabBarController.view.frame = biggerFrame ;
    //[self.tabBarController.tabBar setHidden:YES];
    CGRect rect=self.view.frame;
    rect.size.height+=44;
    self.view.frame=rect;
    
    //[Utils setTabBarImage:@"tab_bar_three.png"];
    [self callAPIPendingRequests];
    [self callAPIRecentChats];
}

-(void)animateUIComponent:(MIBadgeButton *)componentButtons
{
    // Add animation on buttons
    //create an animation to follow a circular path
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    //interpolate the movement to be more smooth
    pathAnimation.calculationMode = kCAAnimationPaced;
    //apply transformation at the end of animation (not really needed since it runs forever)
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    //run forever
    pathAnimation.repeatCount = INFINITY;
    //no ease in/out to have the same speed along the path
    pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    pathAnimation.duration = 15.0;
    
    //The circle to follow will be inside the circleContainer frame.
    //it should be a frame around the center of your view to animate.
    //do not make it to large, a width/height of 3-4 will be enough.
    // chnage the 23,23 according to size
    //increase to reduce size.
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGRect circleContainer;
    if(componentButtons.tag == 95)
    {
        circleContainer = CGRectInset(componentButtons.frame, 80 , 80);
    }
    else
    {
        circleContainer = CGRectInset(componentButtons.frame, 65 , 65);
    }
    CGPathAddEllipseInRect(curvedPath, NULL, circleContainer);
    
    //add the path to the animation
    pathAnimation.path = curvedPath;
    //release path
    CGPathRelease(curvedPath);
    //add animation to the view's layer
    [componentButtons.layer addAnimation:pathAnimation forKey:@"myCircleAnimation"];
    
    
    //create an animation to scale the width of the view
    CAKeyframeAnimation *scaleX = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.x"];
    //set the duration
    scaleX.duration = 1;
    //it starts from scale factor 1, scales to 1.05 and back to 1
    scaleX.values = @[@1.0, @1.05, @1.0];
    //time percentage when the values above will be reached.
    //i.e. 1.05 will be reached just as half the duration has passed.
    scaleX.keyTimes = @[@0.0, @0.5, @1.0];
    //keep repeating
    scaleX.repeatCount = INFINITY;
    //play animation backwards on repeat (not really needed since it scales back to 1)
    scaleX.autoreverses = YES;
    //ease in/out animation for more natural look
    scaleX.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    //add the animation to the view's layer
    [componentButtons.layer addAnimation:scaleX forKey:@"scaleXAnimation"];
    
    //create the height-scale animation just like the width one above
    //but slightly increased duration so they will not animate synchronously
    CAKeyframeAnimation *scaleY = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.y"];
    scaleY.duration = 1.5;
    scaleY.values = @[@1.0, @1.05, @1.0];
    scaleY.keyTimes = @[@0.0, @0.5, @1.0];
    scaleY.repeatCount = INFINITY;
    scaleY.autoreverses = YES;
    scaleX.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [componentButtons.layer addAnimation:scaleY forKey:@"scaleYAnimation"];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - gesture recognizer delegates
- (void)tapView:(UITapGestureRecognizer*)gesture
{
    [[Shared sharedInst] removeView];
    [defaults setBool:true forKey:kMarketPlaceTutorial];
    
    if(![defaults boolForKey:kYapTutorial]) {
        [[Shared sharedInst] showImageWithImageName:@"tutorialYap"];
      
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
        tapGesture.numberOfTapsRequired = 1;
        [[Shared sharedInst].viewImg addGestureRecognizer:tapGesture];
    }
    [defaults setBool:true forKey:kYapTutorial];
}


-(void) setFont
{
//    [_btnMessage.layer setCornerRadius:42];
//    [_btnMessage setClipsToBounds:YES];
//    
//    
//    [_btnPost.layer setCornerRadius:46];
//    [_btnPost setClipsToBounds:YES];
//    
//    [_btnSchedule.layer setCornerRadius:46];
//    [_btnSchedule setClipsToBounds:YES];
//    
//    [_btnPendingRequest.layer setCornerRadius:46];
//    [_btnPendingRequest setClipsToBounds:YES];
//    
//    [_btnMarketPlace.layer setCornerRadius:46];
//    [_btnMarketPlace setClipsToBounds:YES];
//    
//    [_btnBuddies.layer setCornerRadius:150];
//    [_btnBuddies setClipsToBounds:YES];
    
    [_lblNotification.layer setCornerRadius:12.5];
    [_lblNotification setClipsToBounds:YES];
    
    [_lblChatNotification.layer setCornerRadius:12.5];
    [_lblChatNotification setClipsToBounds:YES];
    
    //[self defaultBtnState];
    
}

- (void)callAPIRecentChats
{
    NSDictionary *dictSend = @{kUserId:[defaults objectForKey:kUserId]};
    //SOurabh
    // change to show animation clearly
    //[Utils startLoaderWithMessage:@""];
    
    [Connection callServiceWithName:kGetRecentChatHistory postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         [Utils stopLoader];
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {

                 NSInteger totalUnread = 0;
                 for (NSDictionary *dict in [response objectForKeyNonNull:kResult])
                 {
                     totalUnread = totalUnread + [[dict objectForKey:kUnreadCount] intValue];
                 }
                 
                 if (totalUnread > 0)
                 {
                     [_lblChatNotification setText:[NSString stringWithFormat:@"%ld",(long)totalUnread]];
                     [_lblChatNotification setHidden:YES];
                     [self configureButton:_btnMessage withBadge:[NSString stringWithFormat:@"%ld",(long)totalUnread]];
                 }
                 else
                 {
                     [self configureButton:_btnMessage withBadge:nil];
                     [_lblChatNotification setHidden:YES];
                 }
                 
             }
         }
     }];
}

- (void)callAPIPendingRequests
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
                              nil];
    //SOurabh
    // change to show animation clearly
    //[Utils startLoaderWithMessage:@""];
    [Connection callServiceWithName:kGetPendingRequest postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         [Utils stopLoader];
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 
                 NSArray *arrayBuddies = [[NSArray alloc] initWithArray:[response objectForKeyNonNull:kResult]];
                 
                 if (arrayBuddies.count > 0)
                 {
                     [_lblNotification setHidden:YES];
                     [_lblNotification setText:[NSString stringWithFormat:@"%lu",(unsigned long)arrayBuddies.count]];
                      [self configureButton:_btnPendingRequest withBadge:[NSString stringWithFormat:@"%lu",(unsigned long)arrayBuddies.count]];
                 }
                 else
                 {
                     [self configureButton:_btnPendingRequest withBadge:nil];
                     [_lblNotification setHidden:YES];
                 }
             }
         }
     }];
}

#pragma mark - button action

- (IBAction)btnProfileTapped:(UIButton *)sender
{
    ViewProfileViewController * viewProfile = [[ViewProfileViewController alloc]initWithNibName:@"ViewProfileViewController" bundle:nil];
    viewProfile.inviteButtonHidden = YES;
    viewProfile.editProfile = NO;
    [self.tabBarController.tabBar setHidden:YES];
    [viewProfile setHidesBottomBarWhenPushed:NO];
    [viewProfile setBuddyId:[defaults objectForKey:kUserId]];
    [self.navigationController pushViewController:viewProfile animated:YES];
    
}

- (IBAction)btnSettingsTapped:(UIButton *)sender
{
    if([[defaults objectForKey:kUserId] isEqualToString:@"0"])
    {
        [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"Kindly login to use this feature" leftButtonTitle:@"OK" rightButtonTitle:@"Cancel" selectedButton:^(NSInteger selected, UIAlertView *aView)
         {
             if (selected == 0)
             {
                 [SharedAppDelegate removeTabBarScreen];
             }
         }];
    }
    else
    {
//        SettingViewController *settingViewC = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
//        [settingViewC.btnBack setHidden:YES];
//
//        [self.navigationController pushViewController:settingViewC animated:YES];

        [revealController rightRevealToggle:sender];
      
//        PreferenceSettingViewController *preferenceSettingViewC = [[PreferenceSettingViewController alloc] initWithNibName:@"PreferenceSettingViewController" bundle:nil];
//        preferenceSettingViewC.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:preferenceSettingViewC animated:YES];
    
    
    }
    
}

-(void)removeAnimationFromViewwithcompletion:(myCompletion)compBlock
{
    // Call Method
    [self defaultBtnState];
    
    //[self.btnCircleDot setHidden:YES];
    [self removeAnimation:_btnBuddies];
    [self removeAnimation:_btnPost];
    [self removeAnimation:_btnMessage];
    [self removeAnimation:_btnPendingRequest];
    [self removeAnimation:_btnSchedule];
    [self removeAnimation:_btnMarketPlace];

    
    
    compBlock(YES);
}


- (IBAction)btnMessagesTapped:(MIBadgeButton *)sender
{
    _tagOfButtonTapped = sender.tag;

    [self removeAnimationFromViewwithcompletion:^(BOOL finished) {
        if(finished)
        {
            
        }
    }];
    
    
}

- (IBAction)btnFindBuddyTapped:(MIBadgeButton *)sender
{
    _tagOfButtonTapped = sender.tag;
    
    [self removeAnimationFromViewwithcompletion:^(BOOL finished) {
        if(finished)
        {
        }
    }];

}

- (IBAction)btnPostBlogTapped:(MIBadgeButton *)sender
{
    _tagOfButtonTapped = sender.tag;

    [self removeAnimationFromViewwithcompletion:^(BOOL finished) {
        if(finished)
        {
            
        }
    }];
    
}

- (IBAction)btnMarketPlaceTapped:(MIBadgeButton *)sender
{
    _tagOfButtonTapped = sender.tag;

    [self removeAnimationFromViewwithcompletion:^(BOOL finished) {
        if(finished)
        {
            
        }
    }];
   
}

- (IBAction)btnScheduleClassTapped:(MIBadgeButton *)sender
{
    _tagOfButtonTapped = sender.tag;

    [self removeAnimationFromViewwithcompletion:^(BOOL finished) {
        if(finished)
        {
            
        }
    }];
}

- (IBAction)btnPendingRequestsTapped:(MIBadgeButton *)sender
{
    _tagOfButtonTapped = sender.tag;

    [self removeAnimationFromViewwithcompletion:^(BOOL finished) {
        if(finished)
        {
            

        }
    }];
    }

- (IBAction)btnPreferencesTapped:(UIButton *)sender
{
    [self defaultBtnState];

    if([[defaults objectForKey:kUserId] isEqualToString:@"0"])
    {
        [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"Kindly login to use this feature" leftButtonTitle:@"OK" rightButtonTitle:@"Cancel" selectedButton:^(NSInteger selected, UIAlertView *aView)
         {
             if (selected == 0)
             {
                 [SharedAppDelegate removeTabBarScreen];
             }
         }];
    }
    else
    {
        PreferenceSettingViewController *settingViewC = [[PreferenceSettingViewController alloc] initWithNibName:@"PreferenceSettingViewController" bundle:nil];
        settingViewC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:settingViewC animated:YES];
    }
}

- (IBAction)btnMessageTouched:(UIButton *)sender
{
//    [self defaultBtnState];
//    [sender setTransform:CGAffineTransformMakeScale(1.3, 1.3)];
}

- (IBAction)btnClassSchduleTapped:(id)sender
{
//    [self defaultBtnState];
//    UIButton *senderButton = (UIButton*)sender;
//    [senderButton setTransform:CGAffineTransformMakeScale(1.3, 1.3)];

}

- (IBAction)btnMarketPlaceTouched:(id)sender
{
//    [self defaultBtnState];
//    UIButton *senderButton = (UIButton*)sender;
//    [senderButton setTransform:CGAffineTransformMakeScale(1.3, 1.3)];

}

- (IBAction)btnBlogTouched:(id)sender
{
//    [self defaultBtnState];
//    UIButton *senderButton = (UIButton*)sender;
//    [senderButton setTransform:CGAffineTransformMakeScale(1.3, 1.3)];

}

- (IBAction)btnPendingTouched:(id)sender
{
//    [self defaultBtnState];
//    UIButton *senderButton = (UIButton*)sender;
//    [senderButton setTransform:CGAffineTransformMakeScale(1.3, 1.3)];

}

- (IBAction)btnBuddiesTouched:(id)sender
{
//    [self defaultBtnState];
//    UIButton *senderButton = (UIButton*)sender;
//    [senderButton setTransform:CGAffineTransformMakeScale(1.3, 1.3)];

}


#pragma mark - button States

- (void)defaultBtnState
{
//    [_btnBuddies setTransform:CGAffineTransformIdentity];
//    [_btnMarketPlace setTransform:CGAffineTransformIdentity];
//    [_btnMessage setTransform:CGAffineTransformIdentity];
//    [_btnPost setTransform:CGAffineTransformIdentity];
//    [_btnPendingRequest setTransform:CGAffineTransformIdentity];
//    [_btnSchedule setTransform:CGAffineTransformIdentity];
}

#pragma mark - ControllerPoppedDelegate

-(void)buttonTappedToPop:(NSInteger)senderTag
{
    if(senderTag == 667)
    {
        [self.tabBarController setSelectedIndex:0];
        [Utils setTabBarImage:@"tab_bar_one.png"];
    }
    else
    {
        [self.tabBarController setSelectedIndex:1];
        [Utils setTabBarImage:@"tab_bar_two.png"];
    }
}

@end
