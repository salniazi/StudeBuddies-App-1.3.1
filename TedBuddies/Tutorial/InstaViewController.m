//
//  InstaViewController.m
//  TedBuddies
//
//  Created by Sourabh Singh on 13/10/15.
//  Copyright © 2015 Mayank Pahuja. All rights reserved.
//

#import "InstaViewController.h"
#import "CreateProfileViewController.h"
#import "InstagramUserMedia.h"

@interface InstaViewController ()<UIWebViewDelegate>

@end

@implementation InstaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Utils startLoaderWithMessage:@""];

    // Do any additional setup after loading the view from its nib.
    self.webview.scrollView.bounces = NO;
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    
    //self.webview = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webview.delegate = self;
    NSURLRequest* request =
    [NSURLRequest requestWithURL:[NSURL URLWithString:
                                  [NSString stringWithFormat:kAuthenticationEndpoint, kClientId, kRedirectUrl]]];
    [self.webview loadRequest:request];
}

#pragma mark - Web view delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [Utils stopLoader];
}
- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    if(navigationType == 1)
    {
        [Utils startLoaderWithMessage:@""];
    }
    NSLog(@"navigation type = %ld",(long)navigationType);
    
    if ([request.URL.absoluteString rangeOfString:@"#"].location != NSNotFound) {
        NSString* params = [[request.URL.absoluteString componentsSeparatedByString:@"#"] objectAtIndex:1];
        self.accessToken = [params stringByReplacingOccurrencesOfString:@"access_token=" withString:@""];
        //self.webview.hidden = YES;
        [self getUserInfoWithId:@"self" withAccessToken:self.accessToken];
        
        [defaults setObject:self.accessToken forKey:kUserAccessTokenKey];
        [defaults synchronize];
        NSLog(@"Accesstoken = %@",self.accessToken);
        [Utils stopLoader];
        //[self.navigationController popViewControllerAnimated:YES];

//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"locations"
//                                                                                  style:UIBarButtonItemStyleBordered
//                                                                                 target:self
//                                                                                 action:@selector(locationsAction:)];
    }
    else
    {
        //[Utils stopLoader];

    }
    
    return YES;
}


- (void)getUserInfoWithId:(NSString*)userId
           withAccessToken:(NSString *)accessToken
                     //block:(void (^)(NSArray *records))block
{
    NSDictionary* params = [NSDictionary dictionaryWithObject:accessToken forKey:@"access_token"];
    NSString* path = [NSString stringWithFormat:kUserInformation, userId];
    
    
//    {
//        data =     {
//            bio = "";
//            counts =         {
//                "followed_by" = 126;
//                follows = 186;
//                media = 19;
//            };
//            "full_name" = "Sourabh Shekhar";
//            id = 222654714;
//            "profile_picture" = "https://igcdn-photos-h-a.akamaihd.net/hphotos-ak-xft1/t51.2885-19/s150x150/11848987_1036945292991535_2126671743_a.jpg";
//            username = sssuourabh;
//            website = "";
//        };
//        meta =     {
//            code = 200;
//        };
//    }
    
    [[InstagramClient sharedClient] getPath:path
                             parameters:params
                                    success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    NSDictionary* data = [responseObject objectForKey:@"data"];
                                    
                                    NSLog(@"data = %@",data);
                                        NSLog(@"id = %@",[data objectForKey:@"id"]);
                                        [defaults setObject:[data objectForKey:@"id"] forKey:kUserInstagramId];
                                        [defaults setObject:[data objectForKey:@"username"] forKey:kUserInstagramusername];
                                        [defaults setObject:[data objectForKey:@"full_name"] forKey:kUserInstagramFullname];
                                        [defaults setObject:[data objectForKey:@"profile_picture"] forKey:kUserInstagramProfilePicture];
                                        [defaults synchronize];
                                        
                                        [self requestImages];
                                        // Get more images from instagram
                                        
                                        
                                        //[self loginInsta];
                                       

                                }
                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    NSLog(@"error: %@", error.localizedDescription);
                                    [self.navigationController popViewControllerAnimated:YES];


                                }];
}


-(void)loginInsta
{
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    if ([_selectedDelegate respondsToSelector:@selector(callMethod:)])
    {
        [_selectedDelegate callMethod:self.images];
    }
}


#pragma mark - image loading

- (void)requestImages
{
    [InstagramUserMedia getUserMediaWithId:@"self" withAccessToken:self.accessToken block:^(NSArray *records) {
        self.images = records;
        NSLog(@"self.images count = %lu",(unsigned long)[self.images count]);
        for (InstagramUserMedia* media in self.images)
        {
            //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                NSString* thumbnailUrl = media.thumbnailUrl;
                NSLog(@"thumbnailurl = %@",thumbnailUrl);
            //});
           
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

/*
- (void)loadImages
{
    int item = 0;
    
    for (HSInstagramUserMedia* media in self.images) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
            NSString* thumbnailUrl = media.thumbnailUrl;
            NSData* data = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:thumbnailUrl]];
            UIImage* image = [UIImage imageWithData:data];
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                UIButton* button = [self.thumbnails objectAtIndex:item];
                [button setImage:image forState:UIControlStateNormal];
            });
        });
        ++item;
    }
    
}
*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
