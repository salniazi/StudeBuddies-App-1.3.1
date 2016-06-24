//
//  XOSplashVideoController.m
//  XOSplash
//
//  Created by Ross McFarland on 6/1/12.
//  Copyright (c) 2012 Ross McFarland. All rights reserved.
//

#import "XOSplashVideoController.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation XOSplashVideoController {
    NSURL *_portraitUrl;
    NSString *_portraitImageName;
    NSURL *_landscapeUrl;
    NSString *_landscapeImageName;
    MPMoviePlayerController *_player;
    UIImageView *_playerBackground;
    UIImageView *_backgroundImageView;
    NSString *_loadNotification;
}

@synthesize delegate = _delegate;

- (id)initWithVideoPortraitUrl:(NSURL *)portraitUrl
             portraitImageName:(NSString *)portraitImageName
                  landscapeUrl:(NSURL *)landscapeUrl
            landscapeImageName:(NSString *)landscapeImageName
              delegate:(NSObject<XOSplashVideoDelegate> *)delegate;
{
    self = [super init];
    if (self) {
        _portraitUrl = portraitUrl;
        _portraitImageName = portraitImageName;
        _landscapeUrl = landscapeUrl;
        _landscapeImageName = landscapeImageName;
        _delegate = delegate;
        self.wantsFullScreenLayout = YES;
        self.view.frame = [[UIScreen mainScreen] bounds];
    }
    return self;
}

// from https://gist.github.com/998472
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait) {
        // this won't be called if we're in portrait button bottom, so we need to call it manually
        [self didRotateFromInterfaceOrientation:UIInterfaceOrientationPortrait];
    } else if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")) {
        // on iOS 6 make sure we set the rotation so the splash will start in landscape
        [self didRotateFromInterfaceOrientation:orientation];
    }
}
-(void)viewDidLoad
{
    
}

#pragma mark ROTATION

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait;
    }
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (_player.playbackState == MPMoviePlaybackStatePlaying) {
        // once we've started don't allow rotates
        return NO;
    }
    switch (toInterfaceOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            return _portraitUrl && _portraitImageName;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            return _landscapeUrl && _landscapeImageName;
    }
    return NO;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    UIApplication *application = [UIApplication sharedApplication];
    UIWindow *window = application.delegate.window;

    NSURL *url = _portraitUrl;
    NSString *imageName = _portraitImageName;
    
    UIInterfaceOrientation orientation = [application statusBarOrientation];
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        url = _landscapeUrl;
        imageName = _landscapeImageName;
        
        CGFloat tmp = frame.size.width;
        frame.size.width = frame.size.height;
        frame.size.height = tmp;
        tmp = (frame.size.width - frame.size.height) / 2;
        frame.origin.x = -tmp;
        frame.origin.y = tmp;
        CGFloat rotation = orientation == UIInterfaceOrientationLandscapeLeft ? -M_PI_2 : M_PI_2;
        window.transform = CGAffineTransformMakeRotation(rotation);
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        window.transform = CGAffineTransformMakeRotation(M_PI);
    }

    // put a background image in the window, so that it'll show as soon as the splash
    // goes away, this fixes most of the black flash
    UIImage *image = [UIImage imageNamed:imageName];
    _backgroundImageView = [[UIImageView alloc] initWithImage:image];
    CGRect backgroundFrame = frame;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // shift the background frame down to account for the 20px cut out of the image
        backgroundFrame.origin.y += 20;
        backgroundFrame.size.height -= 20;
    }
    _backgroundImageView.frame = backgroundFrame;
    _backgroundImageView.userInteractionEnabled = NO;
    [window addSubview:_backgroundImageView];

    // init player without a url so we don't miss notifications from it while we're preparing it's state.
    _player = [[MPMoviePlayerController alloc] initWithContentURL:nil];
    // video doesn't need to be shifted down
    _player.view.frame = frame;
    _player.controlStyle = MPMovieControlStyleNone;
    //_player.scalingMode = MPMovieScalingModeNone;
    _player.allowsAirPlay = NO;
    _player.fullscreen = YES;
    _player.scalingMode = MPMovieScalingModeAspectFill;
    // we're going to install it once it's loaded and play it then
    _player.shouldAutoplay = NO;
    // there's still a little bit of black flash left when the player is inserted
    // as it starts to play, adding the splash image to the background of the player
    // will get rid of it
    _playerBackground = [[UIImageView alloc] initWithImage:image];
    CGSize imageSize = image.size;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        _playerBackground.frame = CGRectMake(0, 20, imageSize.width, imageSize.height);
    }
    _player.view.userInteractionEnabled = NO;
    _player.view.frame = [[UIScreen mainScreen] bounds];

    [_player.backgroundView addSubview:_playerBackground];

    // this is the default notification up through iOS 5
    _loadNotification = MPMoviePlayerLoadStateDidChangeNotification;
    if ([_player respondsToSelector:@selector(readyForDisplay)]) {
        // iOS 6, listen for this notification instead
        _loadNotification = MPMoviePlayerReadyForDisplayDidChangeNotification;
    }
    // tell us when the video has loaded
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(splashLoadStateDidChange:)
                                                 name:_loadNotification
                                               object:_player];

    // tell us when the video has finished playing
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(splashPlaybackStateDidChange:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];

    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [_player setContentURL:url];
    [_player prepareToPlay];
}

- (void)splashLoadStateDidChange:(NSNotification *)notification
{
    // we don't need this again
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:_loadNotification
                                                  object:_player];

    // the video has loaded so we can safely add the player to the window now
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [window addSubview:_player.view];
    _loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(20 , 510, 135, 42)];
    [_loginBtn setBackgroundColor:[UIColor whiteColor]];
     //[UIColor colorWithRed:(75.00f/255.00f) green:(126.00f/255) blue:(183.00f/255.00f) alpha:1.0f]];
    _loginBtn.layer.cornerRadius = 5.0f;
    _loginBtn.tag = 11;
    [_loginBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_loginBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
    [_loginBtn setTitle:@"SIGN IN" forState:UIControlStateNormal];
    [_loginBtn addTarget:self action:@selector(btnTapped) forControlEvents:UIControlEventTouchUpInside];
    [_player.view addSubview:_loginBtn];
    
    _signUpBtn = [[UIButton alloc] initWithFrame:CGRectMake(165 , 510, 135, 42)];
    [_signUpBtn setBackgroundColor:kBlueColor];//[UIColor colorWithRed:(75.00f/255.00f) green:(126.00f/255) blue:(183.00f/255.00f) alpha:1.0f]];
    _signUpBtn.layer.cornerRadius = 5.0f;
    _signUpBtn.tag = 12;
    [_signUpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_signUpBtn.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];

    [_signUpBtn setTitle:@"JOIN NOW" forState:UIControlStateNormal];
    [_signUpBtn addTarget:self action:@selector(signUpBtnTapped) forControlEvents:UIControlEventTouchUpInside];
    [_player.view addSubview:_signUpBtn];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(30, 20, 260, 45)];
    [lbl setText:@"Connect with your Classroom Buddies!"];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTextColor:[UIColor blackColor]];
    [lbl setFont:FONT_BOLD(18)];
    [lbl setNumberOfLines:2];
//    [lbl setTextAlignment:NSTextAlignmentCenter];
    [_player.view addSubview:lbl];
    
    // and play it
    [_player play];

    [_playerBackground removeFromSuperview];
    _playerBackground = nil;

    // take the background image out, we're done with it
    [_backgroundImageView removeFromSuperview];
    _backgroundImageView = nil;

    
    // tell the delegate that the video has loaded, running in the background to prevent
    // it from causing studders.
    [_delegate performSelectorInBackground:@selector(splashVideoLoaded:) withObject:self];
}

-(void)btnTapped
{
    [defaults setObject:@"L" forKey:@"registration"];
    [_player stop];
    // tell our delegate that we're done playing
    [_delegate splashVideoComplete:self];

    [UIView animateWithDuration:0.8 animations:^{
        _player.view.alpha = 0;
    } completion:^(BOOL b){

        [_player.view removeFromSuperview];
        _player.view.alpha = 1;
        
        _player = nil;
        
        [UIApplication sharedApplication].delegate.window.transform = CGAffineTransformIdentity;
        
    }];
//    // take our player out of the window, we're done with it
//    [_player.view removeFromSuperview];
//    _player = nil;
//    [UIApplication sharedApplication].delegate.window.transform = CGAffineTransformIdentity;
    
    
}
-(void)signUpBtnTapped
{
    [defaults setObject:@"SignUp" forKey:@"registration"];
    [_player stop];
    // tell our delegate that we're done playing
    [_delegate splashVideoComplete:self];
    
    [UIView animateWithDuration:0.8 animations:^{
        _player.view.alpha = 0;
    } completion:^(BOOL b){
        [_player.view removeFromSuperview];
        _player.view.alpha = 1;

        _player = nil;
        
        [UIApplication sharedApplication].delegate.window.transform = CGAffineTransformIdentity;

    }];
    // take our player out of the window, we're done with it
    
    
}
- (void)splashPlaybackStateDidChange:(NSNotification *)notification
{
    // first time this is called, playback state will be MPMoviePlaybackStatePlaying
    // so we ignore that case.
    // second time, upon finish of playback, state will be MPMoviePlaybackStatePaused
    // if interrupted, state will be MPMoviePlaybackStatePaused
    // both of those cases are treated as if splash playback finished
    // MPMoviePlaybackStateInterrupted, MPMoviePlaybackStateStopped are added
    // to the or condition as a precaution
    if (_player.playbackState == MPMoviePlaybackStatePlaying) {
        return;
    }

    [_player play];
//    // we don't need this again
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:MPMoviePlayerPlaybackStateDidChangeNotification
//                                                  object:_player];
//
//    // we've played so stop us un case we haven't stopped ourselves.
//    [_player stop];
//    // tell our delegate that we're done playing
//    [_delegate splashVideoComplete:self];
//
//    // take our player out of the window, we're done with it
//    [_player.view removeFromSuperview];
//    _player = nil;
//    
//    [UIApplication sharedApplication].delegate.window.transform = CGAffineTransformIdentity;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_backgroundImageView) {
        // we haven't started playing yet, unlikely but just in case, will call play, but 
        // since we're not loaded that's not an issue
        [self splashLoadStateDidChange:nil];
        [self splashPlaybackStateDidChange:nil];
    } else {
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint touchLocation = [touch locationInView:_player.view];
        
        for (UIView *view in _player.view.subviews)
        {
            if ([view isKindOfClass:[UIButton class]] &&
                CGRectContainsPoint(view.frame, touchLocation))
            {
                if(view.tag == 11)
                {
                    [self btnTapped];
                }
                else if(view.tag == 12)
                    [self signUpBtnTapped];
            }
        }

//        if ([touch view] ==  self.loginBtn )
//        {
//            NSLog(@"login tapped");
//            [self btnTapped];
//        }
        
        // we've played so stop us un case we haven't stopped ourselves.
       // [_player stop];
        // ^ will call splashDidFinish for us
    }
}

@end
