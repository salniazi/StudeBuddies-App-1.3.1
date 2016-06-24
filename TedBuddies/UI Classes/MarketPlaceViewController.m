//
//  MarketPlaceViewController.m
//  TedBuddies
//
//  Created by Mayank Pahuja on 27/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import "MarketPlaceViewController.h"
#import "CreateMarketPlaceViewController.h"
#import "PreferenceSettingViewController.h"
#import "ListingDaetailsViewController.h"
#import "SWRevealViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ViewProfileViewController.h"
#import "UITabBarController+HideTabBar.h"
#import <CoreLocation/CoreLocation.h>
#import "UIImage+PDF.h"

@interface MarketPlaceViewController ()<CLLocationManagerDelegate>

{
    SWRevealViewController *revealController;
    BOOL isFirstTimeLoad;
   
    
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    
    NSString *latitude;
    NSString *longitude;
    
    int cuntr;

}

@property (weak, nonatomic) IBOutlet UIWebView *amazonWebview;

@end

@implementation MarketPlaceViewController

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
    
    locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    
    locationManager.distanceFilter = 100;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        NSUInteger code1 = [CLLocationManager authorizationStatus];
        if (code1 == kCLAuthorizationStatusNotDetermined && ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])) {
            // choose one request according to your business.
            if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]){
                [locationManager requestAlwaysAuthorization];
            } else if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
                [locationManager  requestWhenInUseAuthorization];
            } else {
                NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
            }
        }
    }
    
    [locationManager startUpdatingLocation];

    
    
    isFirstTimeLoad=true;
    
      for (UIView *subview in _searchBarMarketPlace.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [subview removeFromSuperview];
            break;
        }
    }
    self.searchBarMarketPlace.backgroundColor = [UIColor clearColor];
    revealController = [self revealViewController];
    [self.amazonWebview setScalesPageToFit:YES];
    self.amazonWebview.delegate = self;
    self.amazonWebview.scrollView.bounces = NO;
    
    cuntr=0;
    
    arrayMarketPlace=[[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated
{
      [self setFonts];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController setTabBarHidden:NO animated:NO];
    [self.tabBarController.tabBar setHidden:NO];
        // FOR GOOGLE ANALYTICS
    isSearching = NO;
    self.screenName = @"MarketPlace Screen";
    [self callAPIGetMarketPlace];
}
-(void)viewWillDisappear:(BOOL)animated
{
    _tableView.alpha=1.0;
    _amazonWebview.alpha=0.0;
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)setFonts
{
    
    [_lblNavBar setFont:FONT_REGULAR(kNavigationFontSize)];
    UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backSwipeAction)];
    [backSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:backSwipe];
    _searchBarMarketPlace.placeholder = @"Search marketplace...";
    counter= 0;
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    currentLocation = [locations objectAtIndex:0];
    // [locationManager stopUpdatingLocation];
    NSLog(@"Detected Location : %f, %f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    
    latitude=[NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
    longitude=[NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
    
    [locationManager stopUpdatingLocation];
    
}

#pragma mark - gesture recognizer action

- (void)backSwipeAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Web Service

- (void)callAPIGetMarketPlace
{
    
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
                              nil];
    if (isFirstTimeLoad)
    {
        [Utils startLoaderWithMessage:@""];
    }
    
    [Connection callServiceWithName:kGetAllMarketPlace postData:dictSend callBackBlock:^(id response, NSError *error)
     {
        
         if (response)
         {
          //   NSLog(@"All Market Place  %@",response);
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 arrayMarketPlace1 = nil;
                 arrayMarketPlace1 = [[NSArray alloc] initWithArray:[response objectForKeyNonNull:kResult]];
                 
                 arrayFilteredContentList = nil;
                 arrayFilteredContentList = [[NSMutableArray alloc] initWithArray:arrayMarketPlace1];
                 
                 cuntr=0;

                
                 for (int i=0; i<arrayFilteredContentList.count; i++)
                 {
                    
                     
                     
                     float lati=[[[arrayFilteredContentList objectAtIndex:i] objectForKey:@"latitude"] floatValue];
                     float longi=[[[arrayFilteredContentList objectAtIndex:i] objectForKey:@"longitude"] floatValue];
                     CLLocation *LocationAtual = [[CLLocation alloc] initWithLatitude:lati longitude:longi];
                     
                     
                     
                     
                   
                     
                     
                     CLGeocoder *geocoder=[[CLGeocoder alloc]init];
                     [geocoder reverseGeocodeLocation:LocationAtual completionHandler:^(NSArray *placemarks, NSError *error)
                      {
                          if (cuntr !=arrayFilteredContentList.count)
                          {
                              CLPlacemark *placemark = placemarks[0];
                              NSString *city = placemark.addressDictionary[@"City"];
                              NSString *state = placemark.addressDictionary[@"State"];
                              
                              NSMutableDictionary *tepm=[[NSMutableDictionary alloc] initWithDictionary:[arrayFilteredContentList objectAtIndex:cuntr]];
                              
                              float lati1=[[tepm objectForKey:@"latitude"] floatValue];
                              float longi1=[[tepm objectForKey:@"longitude"] floatValue];
                              CLLocation *LocationAtual1 = [[CLLocation alloc] initWithLatitude:lati1 longitude:longi1];
                              
                              CLLocationDistance meters = [LocationAtual1 distanceFromLocation:currentLocation]* 0.000621371;
                              
                              [tepm setObject:[NSString stringWithFormat:@"%.2f", meters] forKey:@"miles"];
                              [tepm setObject:[NSString stringWithFormat:@" %@, %@ ",city,state] forKey:@"s_c"];
                              [arrayFilteredContentList replaceObjectAtIndex:cuntr withObject:tepm];
                              cuntr++;

                          }
                          if (cuntr==arrayFilteredContentList.count)
                          {
                              if (isFirstTimeLoad)
                              {
                                  [Utils stopLoader];
                              }
                              isFirstTimeLoad=false;
                              [_tableView reloadData];
                          }
                          else
                          {
                              
                          }
                          
                          
                          
                          
                      }];
                     

                 }
                 

                 
             }
         }
     }];
}


#pragma  mark - SearchBar Controller Delegate..

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    isSearching = YES;
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    NSLog(@"Cancel clicked");
    isSearching = NO;
    
//    arrayFilteredContentList = nil;
//    arrayFilteredContentList = [[NSMutableArray alloc] initWithArray:arrayMarketPlace];
   [self.amazonWebview setAlpha:0];
     [self.lblErrMsg setAlpha:0.0];
    [self.tableView setAlpha:1];
    [_tableView reloadData];
    searchBar.text = @"";
     [searchBar setShowsCancelButton:NO animated:NO];
    _searchBarMarketPlace.alpha=0.0f;
    [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, 65, _tableView.frame.size.width, _tableView.frame.size.height+_searchBarMarketPlace.frame.size.height)];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"Search Clicked");
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:NO];
    [self searchTableList:searchBar.text];
}

- (void)searchTableList:(NSString *)str
{
    // SOURABH
    /*
    NSString *searchString = _searchBarMarketPlace.text;
    arrayFilteredContentList = nil;
    arrayFilteredContentList = [[NSMutableArray alloc] init];
    for (NSDictionary *tempDict in arrayMarketPlace)
    {
        if ([[[tempDict objectForKey:@"mpName"] lowercaseString] rangeOfString:[searchString lowercaseString]].location != NSNotFound)
        {
            [arrayFilteredContentList addObject:tempDict];
        }
    }
    [_tableView reloadData];
    NSLog(@"arr:%@",arrayFilteredContentList);
     */
   
    [arrayMarketPlace removeAllObjects];
    NSInteger i=0;
    for (NSMutableArray *arry in arrayFilteredContentList) {
        
        NSString *tempStr=[[arrayFilteredContentList objectAtIndex:i]objectForKey:@"mpName"];
        NSString *tempStr1=[[arrayFilteredContentList objectAtIndex:i]objectForKey:@"isbn"]?[[arrayFilteredContentList objectAtIndex:i]objectForKey:@"isbn"]:@"";
        i++;

        if ([tempStr containsString:str] || [tempStr1 containsString:str])
        {
            [arrayMarketPlace addObject:arry];
        }
        NSLog(@"filter==%@",arrayMarketPlace);
    }
    
    if (arrayMarketPlace.count==0)
    {
        [self.lblErrMsg setAlpha:1.0];
        [self.amazonWebview setAlpha:1];
        [self.tableView  setAlpha:0];
        NSString *urlAddress = [NSString stringWithFormat:@"%@Home/AmazoneMarketPlace?search=%@",kWebsiteURL,str];
        NSString *encodedString = [urlAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:encodedString];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        [self.amazonWebview loadRequest:requestObj];

    }
    else
    {
        [self.amazonWebview setAlpha:0];
        [self.lblErrMsg setAlpha:0.0];

        [self.tableView  setAlpha:1];
        [_tableView reloadData];
    }

    
    
    
}
#pragma mark -
- (void)webViewDidFinishLoad:(UIWebView *)theWebView
{
    /*CGSize contentSize = theWebView.scrollView.contentSize;
    CGSize viewSize = theWebView.bounds.size;
    
    float rw = viewSize.width / contentSize.width;*/
    
    //theWebView.scrollView.minimumZoomScale = 2.0;
    //theWebView.scrollView.maximumZoomScale = 2.0;
    //theWebView.scrollView.zoomScale = 2.0;
   [theWebView.scrollView setZoomScale:2.0 animated:YES];
   [theWebView.scrollView setContentOffset:CGPointZero animated:NO];
    [theWebView setNeedsDisplay];
}

#pragma mark - UITableView


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isSearching)
    {
        if ([arrayMarketPlace count]%2 == 0)
        {
            return [arrayMarketPlace count]/2;
        }
        else
        {
            return 1+[arrayMarketPlace count]/2;
        }
        
    }
    else
    {
        if ([arrayFilteredContentList count]%2 == 0)
        {
            return [arrayFilteredContentList count]/2;
        }
        else
        {
            return 1+[arrayFilteredContentList count]/2;
        }
        
    }
    
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    UITableViewCell *cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"MarketPlaceCell" owner:self options:nil] lastObject];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell.contentView viewWithTag:11].layer.cornerRadius = 3.0f;
    [cell.contentView viewWithTag:12].layer.cornerRadius = 3.0f;
    
    if (isSearching)
    {
        
        for (int i = 0; i < 2; i++)
        {
            UIView *viewBg = (UIView*)[cell.contentView viewWithTag:11+i];
            UIImageView *imgView = (UIImageView*)[cell.contentView viewWithTag:21+i];
            UILabel *lblContent = (UILabel*)[cell.contentView viewWithTag:31+i];
            UILabel *lblPrice = (UILabel*)[cell.contentView viewWithTag:41+i];
            UIImageView *imgBookmark = (UIImageView*)[cell.contentView viewWithTag:61+i];
             UILabel *lblCourse = (UILabel*)[cell.contentView viewWithTag:71+i];
             UILabel *lblDist = (UILabel*)[cell.contentView viewWithTag:81+i];
           
            
            UIButton * btnEditMarketPlace = (UIButton *) [cell.contentView viewWithTag:51+i];
            if (2*indexPath.row+i < [arrayMarketPlace count])
            {
                NSDictionary *tempDict = arrayMarketPlace[2*indexPath.row+i];
               
                [lblContent setText:[tempDict objectForKeyNonNull:@"mpName"]];
                [lblPrice setText:[NSString stringWithFormat:@" $ %@ ",[tempDict objectForKeyNonNull:@"mpPrice"]]];
                lblPrice.layer.cornerRadius=3.0;
                lblPrice.clipsToBounds=YES;
                [lblPrice sizeToFit];
                
                if ([[tempDict objectForKeyNonNull:@"miles"] floatValue]<15)
                {
                    lblDist.text=[NSString stringWithFormat:@" %@ miles away ", [tempDict objectForKeyNonNull:@"miles"] ];
                    [lblDist sizeToFit];
                }
                else
                {
                    lblDist.text=[NSString stringWithFormat:@"%@", [tempDict objectForKeyNonNull:@"UserUniversityName"]];
                    
                }

                if ([[tempDict objectForKeyNonNull:@"type"] isEqualToString:@"1" ])
                {
                    [imgBookmark setHidden:YES];
                    [lblCourse setHidden:NO];
                    [lblCourse setText:[tempDict objectForKeyNonNull:@"isbn"]];
                     [imgView setImageWithURL:[NSURL URLWithString:[tempDict objectForKeyNonNull:@"mpImage"]] placeholderImage:[UIImage imageNamed:@"default_marketplace@2x.png"]];
                }
                if ([[tempDict objectForKeyNonNull:@"type"] isEqualToString:@"2" ])
                {

                    [lblCourse setHidden:NO];
                    [lblCourse setText:[tempDict objectForKeyNonNull:@"fkcourseId"]];
                    NSMutableArray *imeges=[[NSMutableArray alloc] initWithArray:[tempDict objectForKeyNonNull:@"mpImages"]];
                    for (int i=0; i<imeges.count; i++)
                    {
                        if ([[[imeges objectAtIndex:i] valueForKey:@"isActive"] boolValue])
                        {
                            if (!([[[[imeges objectAtIndex:i] valueForKey:@"image"] pathExtension] isEqualToString:@"jpg"] || [[[[imeges objectAtIndex:i] valueForKey:@"image"] pathExtension] isEqualToString:@"png"] || [[[[imeges objectAtIndex:i] valueForKey:@"image"] pathExtension] isEqualToString:@"jpeg"]))
                            {
                                [imgView setImage:[UIImage imageWithPDFURL:[NSURL URLWithString:[[imeges objectAtIndex:i] valueForKey:@"image"]] atSize:CGSizeMake( imgView.width, imgView.height ) atPage:1 ]];
                                //[doc addObject:[[[imeges objectAtIndex:i] valueForKey:@"image"] objectAtIndex:i]];
                            }
                            else
                            {
                                
                                [imgView setImageWithURL:[NSURL URLWithString:[[imeges objectAtIndex:i] valueForKey:@"image"]]placeholderImage:[UIImage imageNamed:@"default_marketplace@2x.png"]];
                                
                            }

                        }
                    }
                    
                }
                if ([[tempDict objectForKeyNonNull:@"type"] isEqualToString:@"3" ])
                {
                    [imgBookmark setHidden:YES];
                    lblPrice.yOrigin=(lblCourse.yOrigin+10);
                     [imgView setImageWithURL:[NSURL URLWithString:[tempDict objectForKeyNonNull:@"mpImage"]] placeholderImage:[UIImage imageNamed:@"default_marketplace@2x.png"]];
                }
                
                
                btnEditMarketPlace.tag = (10000+2*indexPath.row+i);
                [btnEditMarketPlace addTarget:self action:@selector(btnEditMarketPlaceTapped:) forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                [viewBg setHidden:YES];
            }
            
        }

    }
    else
    {
        
        for (int i = 0; i < 2; i++)
        {
            UIView *viewBg = (UIView*)[cell.contentView viewWithTag:11+i];
            UIImageView *imgView = (UIImageView*)[cell.contentView viewWithTag:21+i];
            UILabel *lblContent = (UILabel*)[cell.contentView viewWithTag:31+i];
            UILabel *lblPrice = (UILabel*)[cell.contentView viewWithTag:41+i];
            UIImageView *imgBookmark = (UIImageView*)[cell.contentView viewWithTag:61+i];
            UILabel *lblCourse = (UILabel*)[cell.contentView viewWithTag:71+i];
             UILabel *lblDist = (UILabel*)[cell.contentView viewWithTag:81+i];
            UILabel *lblSBIN=(UILabel *)[cell.contentView viewWithTag:91+i];
            
            UIButton * btnEditMarketPlace = (UIButton *) [cell.contentView viewWithTag:51+i];
            if (2*indexPath.row+i < [arrayFilteredContentList count])
            {
                NSDictionary *tempDict = arrayFilteredContentList[2*indexPath.row+i];
               
                
                [imgView setImageWithURL:[NSURL URLWithString:[tempDict objectForKeyNonNull:@"mpImage"]] placeholderImage:[UIImage imageNamed:@"default_marketplace@2x.png"]];
                [lblContent setText:[tempDict objectForKeyNonNull:@"mpName"]];
                [lblPrice setText:[NSString stringWithFormat:@" $ %@ ",[tempDict objectForKeyNonNull:@"mpPrice"]]];
                lblPrice.layer.cornerRadius=3.0;
                lblPrice.clipsToBounds=YES;
                [lblPrice sizeToFit];
                if ([[tempDict objectForKeyNonNull:@"miles"] floatValue]<15)
                {
                    lblDist.text=[NSString stringWithFormat:@" %@ miles away ", [tempDict objectForKeyNonNull:@"miles"] ];
                    [lblDist sizeToFit];
                }
                else
                {
                    lblDist.text=[NSString stringWithFormat:@"%@", [tempDict objectForKeyNonNull:@"UserUniversityName"]];
                                    }
                
                if ([[tempDict objectForKeyNonNull:@"type"] isEqualToString:@"1" ])
                {
                    [imgBookmark setHidden:YES];
                    [lblCourse setHidden:NO];
                    [lblSBIN setHidden:NO];
                    lblCourse.xOrigin=47;
                    lblCourse.width=lblCourse.width-45;
                    [lblCourse setText:[NSString stringWithFormat:@"%@",[tempDict objectForKeyNonNull:@"isbn"]]];
                    [imgView setImageWithURL:[NSURL URLWithString:[tempDict objectForKeyNonNull:@"mpImage"]] placeholderImage:[UIImage imageNamed:@"default_marketplace@2x.png"]];
                }
                if ([[tempDict objectForKeyNonNull:@"type"] isEqualToString:@"2" ])
                {
                    
                    [lblCourse setHidden:NO];
                    [lblCourse setText:[tempDict objectForKeyNonNull:@"fkcourseId"]];
                    
                    if (!([[[tempDict objectForKeyNonNull:@"mpImage"] pathExtension] isEqualToString:@"jpg"] || [[[tempDict objectForKeyNonNull:@"mpImage"] pathExtension] isEqualToString:@"png"] || [[[tempDict objectForKeyNonNull:@"mpImage"] pathExtension] isEqualToString:@"jpeg"]))
                    {
                        [imgView setImage:[UIImage imageWithPDFURL:[NSURL URLWithString:[tempDict objectForKeyNonNull:@"mpImage"]] atSize:CGSizeMake( imgView.width, imgView.height ) atPage:1 ]];
                        //[doc addObject:[[[imeges objectAtIndex:i] valueForKey:@"image"] objectAtIndex:i]];
                    }
                    else
                    {
                        
                        [imgView setImageWithURL:[NSURL URLWithString:[tempDict objectForKeyNonNull:@"mpImage"]] placeholderImage:[UIImage imageNamed:@"default_marketplace@2x.png"]];
                        
                    }
                }
                if ([[tempDict objectForKeyNonNull:@"type"] isEqualToString:@"3" ])
                {
                    [imgBookmark setHidden:YES];
                    lblPrice.yOrigin=(lblCourse.yOrigin+10);
                     [imgView setImageWithURL:[NSURL URLWithString:[tempDict objectForKeyNonNull:@"mpImage"]] placeholderImage:[UIImage imageNamed:@"default_marketplace@2x.png"]];
                }
                
                
                btnEditMarketPlace.tag = (10000+2*indexPath.row+i);
                [btnEditMarketPlace addTarget:self action:@selector(btnEditMarketPlaceTapped:) forControlEvents:UIControlEventTouchUpInside];
                

                
            }
            else
            {
                [viewBg setHidden:YES];
            }
            
        }

    }
    
    
    
    
    return cell;
}

-(void) btnEditMarketPlaceTapped : (UIButton *) sender
{
   
    if (isSearching)
    {
        if (arrayMarketPlace.count != 0)
        {
            ListingDaetailsViewController * ListingDetailsView = [[ListingDaetailsViewController alloc]initWithNibName:@"ListingDaetailsViewController" bundle:nil];
            NSDictionary *tempDict = arrayMarketPlace[sender.tag-10000];
            ListingDetailsView.dictShowDetails = tempDict;
            [self.navigationController pushViewController:ListingDetailsView animated:YES];
 
        }
    }
    else
    {
        if (arrayFilteredContentList.count != 0)
        {
            ListingDaetailsViewController * ListingDetailsView = [[ListingDaetailsViewController alloc]initWithNibName:@"ListingDaetailsViewController" bundle:nil];
            NSDictionary *tempDict = arrayFilteredContentList[sender.tag-10000];
            ListingDetailsView.dictShowDetails = tempDict;
            [self.navigationController pushViewController:ListingDetailsView animated:YES];
        }
       
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - button action

- (IBAction)btnAddTapped:(id)sender
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
        CreateMarketPlaceViewController * createMarketView = [[CreateMarketPlaceViewController alloc]initWithNibName:@"CreateMarketPlaceViewController" bundle:nil];
        [self.navigationController pushViewController:createMarketView animated:YES];
    }
}

- (IBAction)btnSettingTapped:(id)sender
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
        [revealController rightRevealToggle:sender];

//        PreferenceSettingViewController *settingViewC = [[PreferenceSettingViewController alloc] initWithNibName:@"PreferenceSettingViewController" bundle:nil];
//        settingViewC.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:settingViewC animated:YES];
    }
    
}
- (IBAction)btnBackPapped:(id)sender
{
   // [self.tabBarController setSelectedIndex:2];
    ViewProfileViewController * viewProfile = [[ViewProfileViewController alloc]initWithNibName:@"ViewProfileViewController" bundle:nil];
    viewProfile.inviteButtonHidden = YES;
    viewProfile.editProfile = NO;
    [self.tabBarController.tabBar setHidden:YES];
    [viewProfile setHidesBottomBarWhenPushed:NO];
    [viewProfile setBuddyId:[defaults objectForKey:kUserId]];
    [self.navigationController pushViewController:viewProfile animated:YES];

    
}

- (IBAction)btnSearchTapped:(id)sender
{
    _searchBarMarketPlace.alpha=1.0f;
    [_searchBarMarketPlace becomeFirstResponder];
    
    [_tableView setFrame:CGRectMake(_tableView.frame.origin.x, 110, _tableView.frame.size.width, _tableView.frame.size.height-_searchBarMarketPlace.frame.size.height)];
    
}

@end
