//
//  ListingDaetailsViewController.h
//  TedBuddies
//
//  Created by Sunil on 01/09/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListingDaetailsViewController : UIViewController
{
    BOOL isTextField;
    NSInteger index;
    NSArray * arrImagesSwipe;

}
@property (strong, nonatomic) IBOutlet UIView *docsView;
@property (strong, nonatomic) IBOutlet UIView *viewFullImage;
@property (weak, nonatomic) IBOutlet UIImageView *imgDocsImages;
@property (strong, nonatomic) IBOutlet UIImageView *imgMainImage;
@property (strong, nonatomic) IBOutlet UIButton *btnClose;
@property (strong, nonatomic) IBOutlet UIButton *btnCloseImage;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewPostImage;

@property (strong, nonatomic) IBOutlet UIButton *btnView;
@property (weak, nonatomic) IBOutlet UIButton *btnDeletemarketPlace;
@property (weak, nonatomic) IBOutlet UIImageView *imgPost;
@property (weak, nonatomic) IBOutlet UIButton *btnEditMarketPlace;
@property (weak, nonatomic) IBOutlet UILabel *lblPrice;
@property (weak, nonatomic) IBOutlet UILabel *lblName;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControlImages;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewImage;
@property (weak, nonatomic) IBOutlet UIButton *btnImageFull;

@property(strong,nonatomic) NSDictionary * dictShowDetails;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;
@property (weak, nonatomic) IBOutlet UIButton *btnContack;
@property (weak, nonatomic) IBOutlet UILabel *lblContact;
@property (weak, nonatomic) IBOutlet UIImageView *imgLine;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblCondition;
@property (weak, nonatomic) IBOutlet UILabel *course;
@property (weak, nonatomic) IBOutlet UILabel *lblCourse_ISBN_Title;
@property (weak, nonatomic) IBOutlet UILabel *lblAuthor;
@property (weak, nonatomic) IBOutlet UILabel *lblTitleAuthor;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UILabel *noOFPageTitle;

@property (weak, nonatomic) IBOutlet UILabel *lblNoOfPages;


- (IBAction)btnBackTapped:(id)sender;
- (IBAction)btnEditMarketPlaceTapped:(id)sender;
- (IBAction)deleteMarketPlaceButtonClick:(UIButton *)sender;
- (IBAction)btnFullMainImageTapped:(UIButton *)sender;
- (IBAction)btnCloseTapped:(id)sender;
- (IBAction)btnCloseImageTapped:(UIButton *)sender;
- (IBAction)btnDocsTapped:(id)sender;
- (IBAction)btnContactTapped:(id)sender;


@end
