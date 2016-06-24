//
//  InstaViewController.h
//  TedBuddies
//
//  Created by Sourabh Singh on 13/10/15.
//  Copyright © 2015 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectedValueDelegate <NSObject>

-(void )callMethod:(NSArray *)imagesArray;

@end

@interface InstaViewController : UIViewController

@property (assign, nonatomic) id <SelectedValueDelegate> selectedDelegate;
@property (nonatomic, strong) NSArray* images;

@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (nonatomic, strong) NSString* accessToken;

@end
