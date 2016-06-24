//
//  AppDelegate.h
//  TedBuddies
//
//  Created by Mayank Pahuja on 08/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

//./Fabric.framework/run 83b4548ad3bd1453ef364b695bf04665d271be5f c177df0a06511500ea1e93099cfc0311bc0334ee9b4843a8748d96d04ba2469a

#import <UIKit/UIKit.h>
#import "ImageCropView.h"

@class SWRevealViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,UITabBarControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ImageCropViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navController;
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (strong, nonatomic) SWRevealViewController *viewController;

@property (nonatomic , assign) BOOL uploadSchedule;
@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (nonatomic , strong) UIImage *selectedImage;

@property (nonatomic) uint64_t fileSize;
@property (nonatomic) uint64_t amountUploaded;
@property (nonatomic , strong) UIView *loadingBg;
@property (nonatomic , strong) UIView *progressView;
@property (nonatomic , strong) UILabel *progresslabel;

@property (nonatomic, strong) NSMutableArray *responce;
@property (nonatomic, strong) NSMutableArray *responceGIF;
@property (nonatomic, strong) NSMutableArray *cmResponce;


@property (nonatomic , assign) BOOL isChangePreference;
@property (nonatomic , assign) BOOL isProfileUpdate;
@property (assign)BOOL isCreateYap;
@property (assign)BOOL isLeftGroup;
@property (assign)BOOL isMuteGroup;
@property (assign)BOOL isJoinGroup;


- (void)addSplashScreen;
- (void)addTabBarScreen;
- (void)removeTabBarScreen;
-(IBAction)btnScheduleTapped:(id)sender;
- (void)callAPIRecentChats;
- (void)callAPIPendingRequests;

@end


/*
https://github.com/ariok/TB_TwitterUI
 https://github.com/cwRichardKim/RKNewsFeedController
 Image
 https://github.com/michaelhenry/MHFacebookImageViewer
*/