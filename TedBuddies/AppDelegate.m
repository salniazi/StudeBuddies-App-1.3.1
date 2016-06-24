//
//  AppDelegate.m
//  TedBuddies
//
//  Created by Mayank Pahuja on 08/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.

// com.StudEBuddies.sal

#import "AppDelegate.h"
#import "SplashViewController.h"
#import "LoginViewController.h"
#import "PostViewController.h"
#import "MyBuddiesViewController.h"
#import "MessagesViewController.h"
#import "MyWebSocket.h"
#import "PendingRequestsViewController.h"
#import "MessagesViewController.h"
#import "ChatScreenViewController.h"
#import "Shared.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "PreferenceSettingViewController.h"
#import "SWRevealViewController.h"
#import "HomeViewController.h"
#import "RootViewController.h"
#import "CustomIOSAlertView.h"

#import <AWSCore/AWSCore.h>
#import <AWSS3/AWSS3.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import <AWSSQS/AWSSQS.h>
#import <AWSSNS/AWSSNS.h>
#import <AWSCognito/AWSCognito.h>
#import "AWSS3TransferManager.h"

#import "UITabBarController+HideTabBar.h"
#import "UITabBar+CustomBadge.h"

#import <DropboxSDK/DropboxSDK.h>
#import "TPKeyboardAvoidingScrollView.h"
#import "ScheduleClassViewController.h"
#import "TTTAttributedLabel.h"
#import "TermsAndPrivacyViewController.h"




@interface AppDelegate()<SWRevealViewControllerDelegate,DBSessionDelegate, DBNetworkRequestDelegate,TTTAttributedLabelDelegate>
{
    CustomIOSAlertView *alertView ;
    NSString *relinkUserId;
    UIView *popUpView;
    UITextField *txtID;
    UITextField *txtPwd;
}

@end

@implementation AppDelegate

#pragma mark - application delegates
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    
    
    DBSession *dbSession = [[DBSession alloc]
                            initWithAppKey:@"21gy3vix35xcc6i"
                            appSecret:@"zy1eejh2w561r5p"
                            root:@"dropbox"]; // either kDBRootAppFolder or kDBRootDropbox
    [DBSession setSharedSession:dbSession];
    
    self.window=[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //Aws3 configration
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                                          
                                                          initWithRegionType:AWSRegionUSEast1
                                                          
                                                          identityPoolId:@"us-east-1:c3570e51-9f71-46d4-82ce-dbf2cca46189"];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc]
                                              
                                              initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    
    NSString *identifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"identifierForVendor = %@",identifier);
    
    NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:4*1024*1024
                                                      diskCapacity:32*1024*1024
                                                          diskPath:@"app_cache"];
    
    // Set the shared cache to our new instance
    [NSURLCache setSharedURLCache:cache];
    
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    // Override point for customization after application launch.
//    self.window.backgroundColor = [UIColor whiteColor];
//    [self.window makeKeyAndVisible];
  
    // GOOGLE ANALYTICS
    
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    
    // Optional: set Logger to VERBOSE for debug information.
    [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker. Replace with your tracking ID.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-62697142-1"];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    // Enable IDFA collection.
    tracker.allowIDFACollection = YES;
    
    [[GAI sharedInstance] setTrackUncaughtExceptions:YES];
    
    
  //add crashlytics
  [Fabric with:@[CrashlyticsKit]];

    if([defaults boolForKey:kIsLoggedIn])
    {
        [self callAPIPendingRequests];
        [self callAPIRecentChats];
    }
    //set tutorial screens keys
    if (![defaults boolForKey:kSignInTutorial]) {
        [defaults setBool:false forKey:kSignInTutorial];
        [defaults synchronize];
    }
    
    if (![defaults boolForKey:kCreateProfileTutorial]) {
        [defaults setBool:false forKey:kCreateProfileTutorial];
        [defaults synchronize];
    }
    
    if (![defaults boolForKey:kClassTitleTutorial]) {
        [defaults setBool:false forKey:kClassTitleTutorial];
        [defaults synchronize];
    }
    
    if (![defaults boolForKey:kCoursePrefixTutorial]) {
        [defaults setBool:false forKey:kCoursePrefixTutorial];
        [defaults synchronize];
    }
    
    if (![defaults boolForKey:kMarketPlaceTutorial]) {
        [defaults setBool:false forKey:kMarketPlaceTutorial];
        [defaults synchronize];
    }
    
    if (![defaults boolForKey:kYapTutorial]) {
        [defaults setBool:false forKey:kYapTutorial];
        [defaults synchronize];
    }
    
    if (![defaults boolForKey:kPreferenceSettingsTutorial]) {
        
        [defaults setBool:false forKey:kPreferenceSettingsTutorial];
        [defaults synchronize];
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    //    [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    //    [[UIApplication sharedApplication] registerForRemoteNotificationTypes: UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
    
    [self setupNotification];
    
   if ([defaults boolForKey:kIsLoggedIn] == YES)
    {
        [self addTabBarScreen];
    }
    else
    {
        if (![defaults boolForKey:kShowTutorial]) {
            [defaults setBool:TRUE forKey:kShowTutorial];
            [defaults synchronize];
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"TutorialStoryboard" bundle:[NSBundle mainBundle]];
            
            UIViewController *initialViewController = [mainStoryboard instantiateInitialViewController];
            self.window.rootViewController = initialViewController;
        }
        else
        {
            [self addSplashScreen];
        }
        

        
    }
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    
    [application setStatusBarHidden:NO];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    
    NSDictionary *remoteNotifiInfo = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    
    //Accept push notification when app is not open
    if (remoteNotifiInfo) {
        [self application:application didReceiveRemoteNotification:remoteNotifiInfo];
    }
    
    //    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    //    {
    //        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0,320, 20)];
    //        view.backgroundColor=[UIColor whiteColor];
    //        [self.window.rootViewController.view addSubview:view];
    //    }
    
    
    if ([defaults objectForKey:kDeviceToken])
    {
        NSMutableDictionary *dictSend = [[NSMutableDictionary alloc] init];
        [dictSend setObject:[defaults objectForKey:kDeviceToken] forKey:kDeviceToken];
        
        [Connection callServiceWithName:kUpdateBadgeCounter postData:dictSend callBackBlock:^(id response, NSError *error)
         {
             [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
         }];
    }
    // here we have to show alert for uploading schedule
    [self updateAlert];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [SharedAppDelegate.window endEditing:YES];
    
     [popUpView removeFromSuperview];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChatScreenDisappear" object:nil];
    
    
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
    
    if([defaults boolForKey:kIsLoggedIn])
    {
        [self callAPIPendingRequests];
        [self callAPIRecentChats];
    }
    
    [[MyWebSocket sharedInstance] connectSocket];
    
    if ([defaults objectForKey:kDeviceToken])
    {
        NSMutableDictionary *dictSend = [[NSMutableDictionary alloc] init];
        [dictSend setObject:[defaults objectForKey:kDeviceToken] forKey:kDeviceToken];
        
        [Connection callServiceWithName:kUpdateBadgeCounter postData:dictSend callBackBlock:^(id response, NSError *error)
         {
             [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
         }];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChatReceived" object:Nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChatScreenAppear" object:nil];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    // here we have to show alert for uploading schedule
    
   
       [self updateAlert];
    
   
}
-(void)setPopUpView
{
    popUpView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.window.width, self.window.height)];
    popUpView.backgroundColor=[UIColor clearColor];
    popUpView.alpha=0.0;
    
    UIImageView *popUpImg=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.window.width, self.window.height)];
    popUpImg.backgroundColor=[UIColor blackColor];
    popUpImg.alpha=0.5;
    
    TPKeyboardAvoidingScrollView *popUpScrollView=[[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 0, self.window.width, self.window.height)];
    popUpScrollView.backgroundColor=[UIColor clearColor];
    
    UIView *innerPopUpView=[[UIView alloc] initWithFrame:CGRectMake(25, 100, self.window.width-50, 250)];
    innerPopUpView.backgroundColor=[UIColor whiteColor];
    [innerPopUpView.layer setShadowOpacity:0.9];
    [innerPopUpView.layer setShadowRadius:2.0];
    [innerPopUpView.layer setCornerRadius:7];
    [innerPopUpView setClipsToBounds:YES];
    [innerPopUpView.layer setShadowOffset:CGSizeMake(0.5, 0.5)];
    innerPopUpView.center = CGPointMake(popUpView.frame.size.width  / 2,(popUpView.frame.size.height / 2)-50);
    
    
    
    UIButton  * btnclose = [[UIButton alloc] initWithFrame:CGRectMake(innerPopUpView.width-25,0, 25, 25)];
    [btnclose addTarget:self action:@selector(btnClosePopUpTapped:) forControlEvents: UIControlEventTouchUpInside];
    [btnclose setBackgroundImage:[UIImage imageNamed:@"crossbtn_grey"] forState:UIControlStateNormal];
    [innerPopUpView addSubview:btnclose];
    
    
    
    UILabel *lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(20, 8,innerPopUpView.width-40, 20)];
    [lblTitle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
    lblTitle.textAlignment = NSTextAlignmentCenter;
    lblTitle.text=@"University Credentials";
    [innerPopUpView addSubview:lblTitle];
    
    
    txtID=[[UITextField alloc] initWithFrame:CGRectMake(20, 35,innerPopUpView.width-40, 30)];
    [txtID setFont:[UIFont systemFontOfSize: 13]];
    txtID.autocorrectionType=UITextAutocorrectionTypeNo;
    txtID.placeholder=@"Enter your ID";
    [txtID setBorderStyle:UITextBorderStyleBezel];
    [innerPopUpView addSubview:txtID];
    
    txtPwd=[[UITextField alloc] initWithFrame:CGRectMake(20, 71,innerPopUpView.width-40, 30)];
    [txtPwd setFont:[UIFont systemFontOfSize: 13]];
    txtPwd.secureTextEntry = YES;
    txtPwd.placeholder=@"Enter your password";
    [txtPwd setBorderStyle:UITextBorderStyleBezel];
    [innerPopUpView addSubview:txtPwd];
    
    UIButton  * btnSignIn = [[UIButton alloc] initWithFrame:CGRectMake(20,111, innerPopUpView.width-40, 35)];
    [btnSignIn setBackgroundColor:[UIColor colorWithRed:103/255.0f green:163/255.0f blue:201/255.0f alpha:1]];
    [btnSignIn setTitle:@"Sign In" forState:UIControlStateNormal];
    //[btnSignIn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btnSignIn.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
    [btnSignIn addTarget:self action:@selector(btnSignInTapped:) forControlEvents: UIControlEventTouchUpInside];
    btnSignIn.layer.cornerRadius=3;
    btnSignIn.clipsToBounds=YES;
    [innerPopUpView addSubview:btnSignIn];
    
    
//    UILabel *lblPrivancy=[[UILabel alloc] initWithFrame:CGRectMake(20, 151,innerPopUpView.width-40, 50)];
//    [lblPrivancy setFont:[UIFont fontWithName:@"Helvetica" size:12]];
//    lblPrivancy.text=@"StudEbuddies will only access your class schedule. We protect your Privacy everyday!";
//   // lblPrivancy.textColor=[UIColor grayColor];
//    lblPrivancy.lineBreakMode = NSLineBreakByWordWrapping;
//    lblPrivancy.numberOfLines = 3;
//    [innerPopUpView addSubview:lblPrivancy];
    
    
    TTTAttributedLabel *lblPrivancy = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(20, 151,innerPopUpView.width-40, 50)];
    lblPrivancy.delegate=self;
    [lblPrivancy setFont:[UIFont fontWithName:@"Helvetica" size:11]];
    lblPrivancy.lineBreakMode = NSLineBreakByWordWrapping;
    lblPrivancy.numberOfLines = 3;
    NSString *labelText = @"StudEbuddies will only access your class schedule. We protect your Privacy everyday!";
    lblPrivancy.text = labelText;
    NSRange r = [labelText rangeOfString:@"Privacy"];
    [lblPrivancy addLinkToURL:[NSURL URLWithString:@"action://show-Privacy"] withRange:r];
    [innerPopUpView addSubview:lblPrivancy];
    
    UILabel *lblOr=[[UILabel alloc] initWithFrame:CGRectMake(20, 196,innerPopUpView.width-40, 20)];
    [lblOr setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]];
    lblOr.textAlignment = NSTextAlignmentCenter;
    lblOr.text=@"OR";
    [innerPopUpView addSubview:lblOr];
    
    
    
    
    
    TTTAttributedLabel *lblManuallyEnter = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(20, 221,innerPopUpView.width-40, 20)];
    lblManuallyEnter.delegate=self;
    [lblManuallyEnter setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    labelText = @"Click here to select your courses.";
    lblManuallyEnter.text = labelText;
    r = [labelText rangeOfString:@"Click here"];
    [lblManuallyEnter addLinkToURL:[NSURL URLWithString:@"action://show-classSchedule"] withRange:r];
    [innerPopUpView addSubview:lblManuallyEnter];

//     UIButton  * btnSchedule = [[UIButton alloc] initWithFrame:CGRectMake(20,221,60, 20)];
//    [btnSchedule setTitle:@"Click here" forState:UIControlStateNormal];
//    btnSchedule.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
//    [btnSchedule setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    [btnSchedule addTarget:self action:@selector(btnManuallyScheduleTapped:) forControlEvents: UIControlEventTouchUpInside];
//    [innerPopUpView addSubview:btnSchedule];
//    
//    UILabel *lblManuallyEnter=[[UILabel alloc] initWithFrame:CGRectMake(80, 221,innerPopUpView.width-40, 20)];
//    [lblManuallyEnter setFont:[UIFont fontWithName:@"Helvetica" size:12]];
//    //lblManuallyEnter.textColor=[UIColor grayColor];
//    lblManuallyEnter.text=@"to manually enter class details.";
//    [innerPopUpView addSubview:lblManuallyEnter];
    
    [popUpScrollView addSubview:innerPopUpView];
    
    [popUpView addSubview:popUpImg];
    [popUpView addSubview:popUpScrollView];
    
    UINavigationController *navController = (UINavigationController *)self.tabBarController.selectedViewController;
    [navController.visibleViewController.view addSubview:popUpView];
   // [self.window addSubview:popUpView];
    //[self.tabBarController.selectedViewController.view addSubview:popUpView];
}
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    if ([[url scheme] hasPrefix:@"action"]) {
        if ([[url host] hasPrefix:@"show-Privacy"])
        {
            UINavigationController *navController = (UINavigationController *)self.tabBarController.selectedViewController;
            TermsAndPrivacyViewController *vcTermsAndPrivacy = [[TermsAndPrivacyViewController alloc] initWithNibName:@"TermsAndPrivacyViewController" bundle:nil];
            vcTermsAndPrivacy.headingName = @"Privacy Policy";
            vcTermsAndPrivacy.hidesBottomBarWhenPushed=YES;
            [navController presentViewController:vcTermsAndPrivacy animated:YES completion:nil];
        }

        else
        {
            UINavigationController *navController = (UINavigationController *)self.tabBarController.selectedViewController;
            ScheduleClassViewController *vcScheduleClass = [[ScheduleClassViewController alloc] initWithNibName:@"ScheduleClassViewController" bundle:nil];
            vcScheduleClass.hidesBottomBarWhenPushed=YES;
            [navController pushViewController:vcScheduleClass animated:YES];
        }
    }
}
   -(IBAction)btnClosePopUpTapped:(id)sender
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [popUpView removeFromSuperview];
    [UIView commitAnimations];
    [self.window endEditing:TRUE];

}
-(IBAction)btnSignInTapped:(id)sender
{
    if ([self isValidation])
    {
        NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [defaults objectForKey:kUserId],kUserId,
                                  txtID.text,@"emailId",
                                  txtPwd.text,@"password",
                                  [defaults objectForKey:kUniversityName],kUniversityName,
                                  nil];
        
        [Utils startLoaderWithMessage:@""];
        [Connection callServiceWithName:kCheckUniversityCredentials postData:dictSend callBackBlock:^(id response, NSError *error)
         {
             [Utils stopLoader];
             if (response)
             {
                
                 if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
                 {
                     
                     [UIView beginAnimations:nil context:nil];
                     [UIView setAnimationDuration:0.5];
                     [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                     popUpView.alpha = 0.0;
                     [UIView commitAnimations];
                     [self.window endEditing:TRUE];
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
                         popUpView.alpha = 0.0;
                         [UIView commitAnimations];
                         [self.window endEditing:TRUE];
                         
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
                [Utils showAlertViewWithMessage:[error localizedDescription]];
             }
         }];

    }
   
}

-(BOOL)isValidation
{
    if ([txtID.text isEqualToString:@""])
    {
        [Utils showAlertViewWithMessage:@"Don't forget to enter your University ID and Passaword.!"];
        return false;
    }
    if ([txtPwd.text isEqualToString:@""])
    {
        [Utils showAlertViewWithMessage:@"Don't forget to enter your University Passaword.!"];
        return false;
    }
    return YES;
}
-(IBAction)btnScheduleTapped:(id)sender
{
    [alertView close];
    
    [self setPopUpView];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    popUpView.alpha = 1.0;
    [UIView commitAnimations];
    [self.window endEditing:TRUE];
    
    
    
    
    
    
//    NSLog(@"%ld", (long)_viewController.frontViewPosition);
//          _uploadSchedule = TRUE;
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
    
    [self.window.rootViewController presentViewController:_imagePicker animated:YES completion:NULL];
}

- (void)openImageCamera
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        DLog(@"Camera not available");
        return;
    }
    _imagePicker = nil;
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _imagePicker.editing = NO;
    _imagePicker.delegate = self;
    
    [self.window.rootViewController presentViewController:_imagePicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:NULL];
    
    
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
    if (_viewController.frontViewPosition==2)
    {
        [_viewController rightRevealToggleAnimated:NO];
    }

    
    if(_uploadSchedule)
    {
        if(_selectedImage != nil){
            ImageCropViewController *controller = [[ImageCropViewController alloc] initWithImage:_selectedImage];
            self.navController.navigationBarHidden = NO;
            controller.delegate = self;
            controller.blurredBackground = YES;
            _tabBarController.tabBar.hidden=YES;
              UINavigationController *navController = (UINavigationController *)self.tabBarController.selectedViewController;
            [navController pushViewController:controller animated:YES];
            
        }
    }
   }

- (void)ImageCropViewController:(ImageCropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage{
    _selectedImage = croppedImage;
    
    
    UINavigationController *navController = (UINavigationController *)self.tabBarController.selectedViewController;
    navController.navigationBarHidden = YES;
    
    [navController popViewControllerAnimated:YES];
    
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

            NSLog(@"%@",[defaults objectForKey:kUniversityId]);
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
            
            __weak AppDelegate *weakSelf = self;
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
                        blueCircalTick.center = self.window.center;
                        
                        [self.window addSubview:blueCircalTick];
                        
                        [self.window bringSubviewToFront:blueCircalTick];
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            
                            [blueCircalTick removeFromSuperview];
                        });

                        
                    }
                    else
                    {
                        
                        [Utils showAlertViewWithMessage:[NSString stringWithFormat:@"Congrats!! You have been selected to unlock %@. Give us 24 hrs to review and accept your %@ class schedule!",[defaults objectForKey:kUniversityName],[defaults objectForKey:kUniversityName]]];
                    }

                    //[Utils showAlertViewWithMessage:@"Your schedule upload successfully.."];
//                     NSLog(@"%d",[defaults boolForKey:kiisclassuploaded]);
//                    [defaults setObject:@"True" forKey:kiisclassuploaded];
//                     NSLog(@"%d",[defaults boolForKey:kiisclassuploaded]);
//                    
                });
                return nil;
            }];
        });
        
    
    
    
}

-(void)update
{
    [_progresslabel setText:[NSString stringWithFormat:@"Uploading : %.0f%%",((float)self.amountUploaded/(float)self.fileSize) * 100]];
}

-(void)createProgressUploadingView
{
    _loadingBg = [[UIView alloc] initWithFrame:self.window.rootViewController.view.frame];
    [ _loadingBg setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:.5]];
    [self.window.rootViewController.view addSubview:_loadingBg];
    
    _progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 50)];
    _progressView.center = self.window.rootViewController.view.center;
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
    if (_viewController.frontViewPosition==2)
    {
        [_viewController rightRevealToggleAnimated:NO];
    }
    
    UINavigationController *navController = (UINavigationController *)self.tabBarController.selectedViewController;
    navController.navigationBarHidden = YES;
    
    [navController popViewControllerAnimated:YES];
    
}

-(void)updateAlert
{
    
    
//    NSInteger value1 = [[defaults objectForKey:kTimesAppOpened] integerValue];
//    [defaults setObject:[NSString stringWithFormat:@"%ld",value1+1] forKey:kTimesAppOpened];
//    [defaults synchronize];
//    
//    NSLog(@"value = %ld",[[defaults objectForKey:kTimesAppOpened] integerValue]);

    
        if([defaults boolForKey:kIsLoggedIn])
        {
            if([defaults boolForKey:kisCreated])
            {
                NSLog(@"%d",[defaults boolForKey:kiisclassuploaded]);
                if(![defaults boolForKey:kiisclassuploaded])
                {

          //  NSInteger value = [[defaults objectForKey:kTimesAppOpened] integerValue];
         //  if ((value%3) == 0)
          //  {
                if (_viewController.frontViewPosition==2)
                {
                    [_viewController rightRevealToggleAnimated:YES];
                }

                    alertView = [[CustomIOSAlertView alloc] init];
                    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:@"Cancel", nil]];
                    [alertView setUseMotionEffects:TRUE];
                    
                    
                    UIView *views =[[UIView alloc] initWithFrame:CGRectMake(0,0,270,110)];
                    
                    UILabel  * lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 270, 20)];
                    lblTitle.text=@"StudEBuddies";
                    lblTitle.textAlignment = NSTextAlignmentCenter;
                    [lblTitle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
                    
                    UILabel  * lblMessage = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, 230, 30)];
                    [lblMessage setFont:[UIFont fontWithName:@"Helvetica" size:12]];
                    lblMessage.textAlignment = NSTextAlignmentCenter;
                    lblMessage.numberOfLines=2;
                    
                    UIButton  * btnSchedule = [[UIButton alloc] initWithFrame:CGRectMake(95, 75, 80, 30)];
                    [btnSchedule setBackgroundColor:[UIColor colorWithRed:103/255.0f green:163/255.0f blue:201/255.0f alpha:1]];
                    [btnSchedule setTitle:@"Sign In" forState:UIControlStateNormal];
                    btnSchedule.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:13];
                    [btnSchedule addTarget:self action:@selector(btnScheduleTapped:) forControlEvents: UIControlEventTouchUpInside];
                    btnSchedule.layer.cornerRadius=3;
                    btnSchedule.clipsToBounds=YES;
                    
                    
                    lblMessage.text=@"Sign in with your university credentials to connect with your classroom buddies!";
                    
                    [views addSubview:lblTitle];
                    [views addSubview:lblMessage];
                    [views addSubview:btnSchedule];
                    
                    [alertView setContainerView:views];
                    
                    [alertView show];
                    

              
                    
                    // }
            }

            }
        }
    
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - push methods

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken");
    NSString *dt = [[devToken description] stringByTrimmingCharactersInSet:	[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    dt = [dt stringByReplacingOccurrencesOfString:@" " withString:@""];
    //	   //DeviceToken = dt;
    
   // [Utils showAlertViewWithMessage:dt];
    
    [defaults setObject:dt forKey:kDeviceToken];
    [defaults synchronize];
    
    
    
    NSLog(@"device:%@",[defaults objectForKey:kDeviceToken]);
   // [Utils showAlertViewWithMessage:dt];
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError");
    [defaults setObject:@"1234" forKey:kDeviceToken];
    [defaults synchronize];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    for (int i=0; i<userInfo.count; i++)
    {
        
    }
    
    //    NSInteger push = [[[userInfo objectForKeyNonNull:@"aps"] objectForKeyNonNull:@"pushType"] integerValue];
    if ([userInfo objectForKey:@"aps"])
    {
        if ([[[userInfo objectForKey:@"aps"] objectForKey:@"Tag"] integerValue] == 1)
        {
            [self callAPIPendingRequests];
            [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] buttonArray:[NSArray arrayWithObjects:@"View",@"Cancel",nil] selectedButton:^(NSInteger selected, UIAlertView *aView)
             {
                 if (selected == 0)
                 {
                     
                     UINavigationController *navController = (UINavigationController *)self.tabBarController.selectedViewController;
                     NSInteger flag = 0;
                     for (id ViewC in [navController viewControllers])
                     {
                         if ([ViewC isKindOfClass:[PendingRequestsViewController class]])
                         {
                             flag = 1;
                             PendingRequestsViewController *pendinfViewC = (PendingRequestsViewController*)ViewC;
                             [navController popToViewController:pendinfViewC animated:YES];
                             break;
                         }
                     }
                     if (flag == 0)
                     {
                         PendingRequestsViewController *pendingRequest = [[PendingRequestsViewController alloc] initWithNibName:@"PendingRequestsViewController" bundle:nil];
                         pendingRequest.hidesBottomBarWhenPushed=YES;
                         [navController pushViewController:pendingRequest animated:YES];
                         
                     }
                 }
                 else
                 {
                     
                     UINavigationController *navController = (UINavigationController *)self.tabBarController.selectedViewController;
                     for (id ViewC in [navController viewControllers])
                     {
                         if ([ViewC isKindOfClass:[PendingRequestsViewController class]])
                         {
                            
                             PendingRequestsViewController *pendingRequest=(PendingRequestsViewController*)ViewC;
                             [pendingRequest viewDidAppear:NO];
                             break;
                         }
                     }

                 }
                 //            [_tabBarController setSelectedIndex:2];
                 //            [_tabBarController.navigationController pushViewController:<#(UIViewController *)#> animated:<#(BOOL)#>]
             }];
        }
        else if ([[[userInfo objectForKey:@"aps"] objectForKey:@"Tag"] integerValue] == 2)
        {
            [self callAPIRecentChats];
            UINavigationController *navController = (UINavigationController *)self.tabBarController.selectedViewController;
            if ([[[navController viewControllers] lastObject] isKindOfClass:[ChatScreenViewController class]])
            {
                return;
            }
            [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] buttonArray:[NSArray arrayWithObjects:@"View",@"Cancel",nil] selectedButton:^(NSInteger selected, UIAlertView *aView)
             {
                 if (selected == 0)
                 {
                    
                     UINavigationController *navController = (UINavigationController *)self.tabBarController.selectedViewController;
                     NSInteger flag = 0;
                     if ([[[navController viewControllers] lastObject] isKindOfClass:[ChatScreenViewController class]])
                     {
                         
                     }
                     else
                     {
                         if ([[[navController viewControllers] lastObject] isKindOfClass:[MessagesViewController class]])
                         {
                             MessagesViewController *messagesViewC = (MessagesViewController*)[[navController viewControllers] lastObject];
                             [messagesViewC setIsFromPush:YES];
                             [messagesViewC viewDidAppear:YES];
                         }
                         for (id ViewC in [navController viewControllers])
                         {
                             if ([ViewC isKindOfClass:[MessagesViewController class]])
                             {
                                 flag = 1;
                                 MessagesViewController *messagesViewC = (MessagesViewController*)ViewC;
                                 [messagesViewC setIsFromPush:YES];
                                 [navController popToViewController:messagesViewC animated:YES];
                                 break;
                             }
                         }
                         if (flag == 0)
                         {
                             MessagesViewController *messagesViewC = [[MessagesViewController alloc] initWithNibName:@"MessagesViewController" bundle:nil];
                             messagesViewC.hidesBottomBarWhenPushed=YES;
                             [messagesViewC setIsFromPush:YES];
                             [navController pushViewController:messagesViewC animated:YES];
                             
                         }
                     }
                 }
                 else
                 {
                     
                     
                    UINavigationController *navController = (UINavigationController *)self.tabBarController.selectedViewController;
                     for (id ViewC in [navController viewControllers])
                     {
                        if ([ViewC isKindOfClass:[MessagesViewController class]])
                         {
                             
                             MessagesViewController *message=(MessagesViewController*)ViewC;
                             [message viewDidAppear:NO];
                             break;
                         }
                     }
                     
                 }

             }];
            
        }
        else
        {
            [Utils showAlertViewWithMessage:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
        }
    }
    
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    NSString *urlString = [url absoluteString];
    
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithName:@"StudEBuddies"
                                                        trackingId:@"UA-62697142-1"];
    
    // setCampaignParametersFromUrl: parses Google Analytics campaign ("UTM")
    // parameters from a string url into a Map that can be set on a Tracker.
    GAIDictionaryBuilder *hitParams = [[GAIDictionaryBuilder alloc] init];
    
    // Set campaign data on the map, not the tracker directly because it only
    // needs to be sent once.
    [[hitParams setCampaignParametersFromUrl:urlString] build];
    
    // Campaign source is the only required campaign field. If previous call
    // did not set a campaign source, use the hostname as a referrer instead.
//    if(![hitParams valueForKey:kGAICampaignSource] && [url host].length !=0) {
//        // Set campaign data on the map, not the tracker.
//        [hitParams set:@"referrer" forKey:kGAICampaignMedium];
//        [hitParams set:[url host] forKey:kGAICampaignSource];
//    }
    
    
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
            // At this point you can start making API calls
        }
        return YES;
    }
    
    return [FBSession.activeSession handleOpenURL:url];
}
#pragma mark - Web services

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
                  
                     [self.tabBarController.tabBar setBadgeStyle:kCustomBadgeStyleNumber value:totalUnread atIndex:2];
                  
                 }
                 else
                 {
                        [self.tabBarController.tabBar setBadgeStyle:kCustomBadgeStyleNone value:totalUnread atIndex:2];
                     
                     
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
                     
                   [self.tabBarController.tabBar setBadgeStyle:kCustomBadgeStyleNumber value:arrayBuddies.count atIndex:4];
                }
                 else
                 {
                     
                    [self.tabBarController.tabBar setBadgeStyle:kCustomBadgeStyleNone value:arrayBuddies.count atIndex:4];
                    
                 }
             }
         }
     }];
}


#pragma mark - custom view methods

- (void)addSplashScreen
{
    [_tabBarController.view removeFromSuperview];
    //SplashViewController *splashViewC = [[SplashViewController alloc] initWithNibName:@"SplashViewController" bundle:nil];
    LoginViewController *loginViewC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    _navController = [[UINavigationController alloc] initWithRootViewController:loginViewC];
    [_navController.navigationBar setTintColor:[UIColor blueColor]];
    [_navController setNavigationBarHidden:YES];

    [self.window setRootViewController:_navController];
    
}

-(UIColor *)getColor
{
    return [UIColor colorWithRed:(119.0f/255.0f) green:(190.0f/255.0f) blue:(145.0f/255.0f) alpha:1];
    //return [UIColor colorWithRed:(133.0f/255.0f) green:(224.0f/255.0f) blue:(105.0f/255.0f) alpha:1];
}
- (void)addTabBarScreen
{
    [_navController.view removeFromSuperview];
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"TabbarViewController" owner:self options:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    _tabBarController = (UITabBarController *)[array objectAtIndex:0];
    _tabBarController.delegate = self;
    
    self.tabBarController.tabBar.translucent = false;
    self.tabBarController.tabBar.tintColor = [UIColor grayColor];
    self.tabBarController.tabBar.barTintColor = [UIColor whiteColor];
    
    for (UITabBarItem* tabBarItem in [self.tabBarController.tabBar items])
    {
        [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor grayColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"HelveticaNeue" size:11.0f],NSFontAttributeName,  nil] forState:UIControlStateNormal];
        [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[self getColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"HelveticaNeue" size:11.0f],NSFontAttributeName,  nil] forState:UIControlStateSelected];
        
    }
    [Utils setTabBarImage:@"tab1.png"];
    [_tabBarController setSelectedIndex:0];
    
////    [[UITabBarItem appearance] setTitleTextAttributes:@{ UITextAttributeTextColor : [UIColor whiteColor] }
////                                             forState:UIControlStateNormal];
//    [[UITabBarItem appearance] setTitleTextAttributes:@{ UITextAttributeTextColor : [UIColor blueColor] }
//                                             forState:UIControlStateSelected];
    SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:nil frontViewController:_tabBarController];
    revealController.delegate = self;
    
    PreferenceSettingViewController *rightViewController = rightViewController = [[PreferenceSettingViewController alloc] init];
    
    revealController.rightViewController = rightViewController;
    self.viewController = revealController;

    if (_tabBarController.view)
    {
        [self.window setRootViewController:self.viewController];
    }
   
    
}

- (void)removeTabBarScreen
{
    [_tabBarController.view removeFromSuperview];
    
    if (_navController.view)
    {
        [self.window setRootViewController:_navController];
        
        for (UIViewController *viewC in _navController.viewControllers)
        {
            if ([viewC isKindOfClass:[LoginViewController class]])
            {
                [_navController popToViewController:viewC animated:NO];
            }
        }
        
    }
    else
    {
        LoginViewController *loginViewC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:Nil];
        _navController = Nil;
        _navController = [[UINavigationController alloc] initWithRootViewController:loginViewC];
        [_navController setNavigationBarHidden:YES];
        [self.window setRootViewController:_navController];
    }
}

- (void)setupNotification
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
}

#pragma mark - TabBar Delegate
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    UINavigationController *nav = (UINavigationController *)viewController;
    UIViewController *vc = [nav.viewControllers firstObject];
    
    
    if ([vc isKindOfClass:[PostViewController class]] || [vc isKindOfClass:[MessagesViewController class]] || [vc isKindOfClass:[MyBuddiesViewController class]])
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
            return NO;
        }
    }
    
    return YES;
    
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    DLog(@"%lu",(unsigned long)self.tabBarController.selectedIndex);

    if(self.tabBarController.selectedIndex == 4)
    {
        [Utils setTabBarImage:@"tab5.png"];
    }
    else if(self.tabBarController.selectedIndex == 3)
    {
        [Utils setTabBarImage:@"tab4.png"];
    }
    else if(self.tabBarController.selectedIndex == 2)
    {
        [Utils setTabBarImage:@"tab3.png"];
    }
    else if(self.tabBarController.selectedIndex == 1)
    {
        [Utils setTabBarImage:@"tab2.png"];
    }
    else if(self.tabBarController.selectedIndex == 0)
    {
        [Utils setTabBarImage:@"tab1.png"];
    }
    
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

#define LogDelegates 0

#if LogDelegates
- (NSString*)stringFromFrontViewPosition:(FrontViewPosition)position
{
    NSString *str = nil;
    if ( position == FrontViewPositionLeftSideMostRemoved ) str = @"FrontViewPositionLeftSideMostRemoved";
    if ( position == FrontViewPositionLeftSideMost) str = @"FrontViewPositionLeftSideMost";
    if ( position == FrontViewPositionLeftSide) str = @"FrontViewPositionLeftSide";
    if ( position == FrontViewPositionLeft ) str = @"FrontViewPositionLeft";
    if ( position == FrontViewPositionRight ) str = @"FrontViewPositionRight";
    if ( position == FrontViewPositionRightMost ) str = @"FrontViewPositionRightMost";
    if ( position == FrontViewPositionRightMostRemoved ) str = @"FrontViewPositionRightMostRemoved";
    return str;
}

- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position
{
    NSLog( @"%@: %@", NSStringFromSelector(_cmd), [self stringFromFrontViewPosition:position]);
}

- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    NSLog( @"%@: %@", NSStringFromSelector(_cmd), [self stringFromFrontViewPosition:position]);
}

- (void)revealController:(SWRevealViewController *)revealController animateToPosition:(FrontViewPosition)position
{
    NSLog( @"%@: %@", NSStringFromSelector(_cmd), [self stringFromFrontViewPosition:position]);
}

- (void)revealControllerPanGestureBegan:(SWRevealViewController *)revealController;
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
}

- (void)revealControllerPanGestureEnded:(SWRevealViewController *)revealController;
{
    NSLog( @"%@", NSStringFromSelector(_cmd) );
}

- (void)revealController:(SWRevealViewController *)revealController panGestureBeganFromLocation:(CGFloat)location progress:(CGFloat)progress
{
    NSLog( @"%@: %f, %f", NSStringFromSelector(_cmd), location, progress);
}

- (void)revealController:(SWRevealViewController *)revealController panGestureMovedToLocation:(CGFloat)location progress:(CGFloat)progress
{
    NSLog( @"%@: %f, %f", NSStringFromSelector(_cmd), location, progress);
}

- (void)revealController:(SWRevealViewController *)revealController panGestureEndedToLocation:(CGFloat)location progress:(CGFloat)progress
{
    NSLog( @"%@: %f, %f", NSStringFromSelector(_cmd), location, progress);
}

- (void)revealController:(SWRevealViewController *)revealController willAddViewController:(UIViewController *)viewController forOperation:(SWRevealControllerOperation)operation animated:(BOOL)animated
{
    NSLog( @"%@: %@, %d", NSStringFromSelector(_cmd), viewController, operation);
}

- (void)revealController:(SWRevealViewController *)revealController didAddViewController:(UIViewController *)viewController forOperation:(SWRevealControllerOperation)operation animated:(BOOL)animated
{
    NSLog( @"%@: %@, %d", NSStringFromSelector(_cmd), viewController, operation);
}

#endif



@end
