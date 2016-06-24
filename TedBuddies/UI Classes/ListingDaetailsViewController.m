//
//  ListingDaetailsViewController.m
//  TedBuddies
//
//  Created by Sunil on 01/09/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import "ListingDaetailsViewController.h"
#import "CreateMarketPlaceViewController.h"
#import "ChatScreenViewController.h"
#import "UIImage+PDF.h"
#import <QuickLook/QuickLook.h>


@interface ListingDaetailsViewController ()<UIScrollViewDelegate,QLPreviewControllerDelegate,QLPreviewControllerDataSource>
{
    NSMutableArray *arryBlurPDF;
    NSInteger selectedImage;
}
@end

@implementation ListingDaetailsViewController

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
    
    arryBlurPDF=[[NSMutableArray alloc]init];
        [self setFont];
    
       // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Scrollview Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView==_scrollViewImage)
    {
        
        [_pageControlImages setNumberOfPages:scrollView.contentSize.width/280];
        [_pageControlImages setCurrentPage:scrollView.contentOffset.x/280];
        
    }
}


#pragma  mark - Others Methods

-(void) setFont
{
    [_lblDescription setTranslatesAutoresizingMaskIntoConstraints:YES];
    if ([[_dictShowDetails objectForKey:@"adminId"] isEqualToString:[defaults objectForKey:kUserId]])
    {
        [_btnEditMarketPlace setHidden:NO];
        [self.btnDeletemarketPlace setHidden:NO];
         [_btnContack setHidden:YES];
         [_lblContact setHidden:YES];
        
        
        [_lblDescription setTranslatesAutoresizingMaskIntoConstraints:YES];
        _lblDescription.yOrigin=_lblContact.yOrigin;
        
      
    }
    
//    [_btnContack.layer setBorderColor:kBlueColor.CGColor];
//    [_btnContack.layer setBorderWidth:kButtonBorderWidth];
//    [_btnContack.layer setCornerRadius:kButtonCornerRadius];
    
    [_btnClose.layer setCornerRadius:kButtonCornerRadius];
    [_btnClose.layer setBorderColor:[UIColor blackColor].CGColor];
    [_btnClose setBackgroundColor:[UIColor whiteColor]];
    [_btnClose.layer setBorderWidth:kButtonBorderWidth];
    [_btnClose setClipsToBounds:YES];

    [_btnCloseImage.layer setCornerRadius:kButtonCornerRadius];
    [_btnCloseImage.layer setBorderColor:[UIColor blackColor].CGColor];
    [_btnCloseImage setBackgroundColor:[UIColor whiteColor]];
    [_btnCloseImage.layer setBorderWidth:kButtonBorderWidth];
    [_btnCloseImage setClipsToBounds:YES];

    _lblName.text = [NSString stringWithFormat:@"%@",[_dictShowDetails objectForKeyNonNull:@"mpName"]];
    _lblNoOfPages.text=[NSString stringWithFormat:@"%@",[_dictShowDetails objectForKeyNonNull:@"numberOfPages"]];
      _lblPrice.text = [NSString stringWithFormat:@"$%@",[_dictShowDetails objectForKeyNonNull:@"mpPrice"]];
//    [_lblName sizeToFit];
//    [_lblName setFrame:CGRectMake(_lblName.frame.origin.x, _lblPrice.frame.origin.y, _lblName.frame.size.width, _lblPrice.frame.size.height)];
//    [_lblLine setFrame:CGRectMake(_lblName.frame.origin.x+_lblName.frame.size.width+5, _lblLine.frame.origin.y, _lblLine.frame.size.width, _lblLine.frame.size.height)];
//     [_lblPrice setFrame:CGRectMake(_lblLine.frame.origin.x+_lblLine.frame.size.width+5, _lblPrice.frame.origin.y, _lblPrice.frame.size.width, _lblPrice.frame.size.height)];
//    
    
    
    [_btnContack  setTitle:[_dictShowDetails objectForKeyNonNull:@"adminName"] forState:UIControlStateNormal];
    
    if ([[_dictShowDetails objectForKeyNonNull:@"type"] isEqualToString:@"1" ] || [[_dictShowDetails objectForKeyNonNull:@"type"] isEqualToString:@"3" ])
    {
        if ([[_dictShowDetails objectForKeyNonNull:@"type"] isEqualToString:@"1" ])
        {
            _lblCourse_ISBN_Title.text=@"ISBN#:";
            _course.xOrigin=_course.xOrigin-5;
            _course.text=[NSString stringWithFormat:@"%@",[_dictShowDetails objectForKeyNonNull:@"isbn"]];
            _lblAuthor.text=[NSString stringWithFormat:@"By %@",[_dictShowDetails objectForKeyNonNull:@"Author"]];
        }
        else
        {
            _lblCourse_ISBN_Title.text=@"Condition:";
            _lblCourse_ISBN_Title.width=_lblCourse_ISBN_Title.width+15;
            _course.xOrigin=_course.xOrigin+15;
            _course.text=[NSString stringWithFormat:@"%@",[_dictShowDetails objectForKeyNonNull:@"condition"]];
        }
        
        
         [_imgPost setImageWithURL:[NSURL URLWithString:[_dictShowDetails objectForKeyNonNull:@"mpImage"]] placeholderImage:[UIImage imageNamed:@"default_marketplace@2x.png"]];
        
        [_noOFPageTitle setHidden:YES];
        [_lblNoOfPages setHidden:YES];
        if (![[_dictShowDetails objectForKey:@"adminId"] isEqualToString:[defaults objectForKey:kUserId]])
        {
            _lblDescription.yOrigin=_lblContact.yOrigin;
            _lblContact.yOrigin=_noOFPageTitle.yOrigin;
            _btnContack.yOrigin=_noOFPageTitle.yOrigin;
            
        }
        else
        {
            _lblDescription.yOrigin=_noOFPageTitle.yOrigin;
        }
        
    }
    else if ([[_dictShowDetails objectForKeyNonNull:@"type"] isEqualToString:@"2" ])
    {
        _lblCourse_ISBN_Title.text=@"Course:";
        _course.text=[NSString stringWithFormat:@"%@",[_dictShowDetails objectForKeyNonNull:@"fkcourseId"]];
        NSMutableArray *imeges=[[NSMutableArray alloc] initWithArray:[_dictShowDetails objectForKeyNonNull:@"mpImages"]];
        
        if (imeges.count!=0)
        {
        
            _scrollViewImage.hidden=NO;
            _imgPost.hidden=YES;
            _btnImageFull.hidden=YES;
            
            
            for (int i=0; i<imeges.count; i++)
            {
                
                
                UIImageView *imgPostImage = [[UIImageView alloc] initWithFrame:CGRectMake(_scrollViewImage.contentSize.width+5, 0, 270, 190)];
                
                if (!([[[[imeges objectAtIndex:i] valueForKey:@"image"] pathExtension] isEqualToString:@"jpg"] || [[[[imeges objectAtIndex:i] valueForKey:@"image"] pathExtension] isEqualToString:@"png"] || [[[[imeges objectAtIndex:i] valueForKey:@"image"] pathExtension] isEqualToString:@"jpeg"]))
                {
                    NSString *url = [[imeges objectAtIndex:i] valueForKey:@"image"];
                    NSArray *arrComponents = [url componentsSeparatedByString:@"/"];
                    NSString *fileName = [arrComponents lastObject];
                    NSString *strPath = [Utils getPathForFolderPath:@"Shared_File" withFileName:fileName];
                    
                    NSString *PDFPath = [Utils getPathForFolderPath:@"Shared_File" withFileName:[NSString stringWithFormat:@"Blur_%@",fileName]];
                    
                    if ([[NSFileManager defaultManager] fileExistsAtPath:PDFPath])
                    {
                         [arryBlurPDF addObject:PDFPath];
                        
                    }
                    else
                    {
                        
                        [_indicator startAnimating];
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                            
                            
                            NSData *data=[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[[[imeges objectAtIndex:i] valueForKey:@"image"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                            if ([[NSFileManager defaultManager] createFileAtPath:strPath contents:data attributes:nil])
                            {
                               
                                CFURLRef url = CFURLCreateWithFileSystemPath (NULL, (__bridge CFStringRef)[NSString stringWithFormat:@"%@",strPath], kCFURLPOSIXPathStyle, 0);
                                CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL(url);
                                // CGPDFPageRef myPageRef = CGPDFDocumentGetPage(pdf, 1);
                                int  totalPages= CGPDFDocumentGetNumberOfPages(pdf);
                                
                                NSMutableArray *imgPDF=[[NSMutableArray alloc] init];
                                NSMutableArray *imgBlurPFD=[[NSMutableArray alloc] init];
                                
                                for (int j=1; j<=(totalPages>2?2:totalPages); j++)
                                {
                                    [imgPDF addObject:[UIImage imageWithPDFURL:[NSURL URLWithString:[[imeges objectAtIndex:i] valueForKey:@"image"]] atSize:CGSizeMake( imgPostImage.width, imgPostImage.height ) atPage:j]];
                                }
                                for (int j=0; j<imgPDF.count; j++)
                                {
                                    if (imgPDF.count==1)
                                    {
                                          [imgBlurPFD addObject:[self blurredImageWithImage:[imgPDF objectAtIndex:j] withRatio:3.0]];
                                    }
                                    else
                                        
                                    {
                                          [imgBlurPFD addObject:[self blurredImageWithImage:[imgPDF objectAtIndex:j] withRatio:2.0]];
                                    }
                                  
                                    
                                }
                                [self createPDFWithImagesArray:imgBlurPFD andFileName:fileName];
                                
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    
                                    [_indicator stopAnimating];
                                   
                                   
                                });
                                
                               
                                
                                
                            }
                            
                            
                            
                            
                        });
                        

                    }
                    
                    
                    
                    
                    
                    
                    
                    [imgPostImage setImage:[UIImage imageWithPDFURL:[NSURL URLWithString:[[imeges objectAtIndex:i] valueForKey:@"image"]] atSize:CGSizeMake( imgPostImage.width, imgPostImage.height ) atPage:1 ]];
                    //[doc addObject:[[[imeges objectAtIndex:i] valueForKey:@"image"] objectAtIndex:i]];
                }
                else
                {
                    [arryBlurPDF addObject:[[imeges objectAtIndex:i] valueForKey:@"image"]];
                   [imgPostImage setImageWithURL:[NSURL URLWithString:[[imeges objectAtIndex:i] valueForKey:@"image"]]placeholderImage:[UIImage imageNamed:@"default_marketplace@2x.png"]];
                    
                }

                
                
                [_scrollViewImage addSubview:imgPostImage];
                
                [imgPostImage setContentMode:UIViewContentModeScaleAspectFill];
                [imgPostImage setClipsToBounds:YES];
                
                
                UIButton *btnFullImage=[[UIButton alloc] initWithFrame:CGRectMake(_scrollViewImage.contentSize.width+5, 0, 270, 190)];
                [btnFullImage addTarget:self action:@selector(btnFullMainImageTapped:) forControlEvents:UIControlEventTouchUpInside];
                btnFullImage.tag=_scrollViewImage.contentSize.width/280;
                [_scrollViewImage addSubview:btnFullImage];
                
                [_scrollViewImage setContentSize:CGSizeMake(_scrollViewImage.contentSize.width+280, 190)];
                if ([[[imeges objectAtIndex:i] valueForKey:@"isActive"] boolValue])
                {
                    _scrollViewImage.contentOffset=CGPointMake(_scrollViewImage.contentSize.width-280,0);
                    _pageControlImages.hidden=NO;
                    [_pageControlImages setCurrentPageIndicatorTintColor:kBlueColor];
                    [_pageControlImages setPageIndicatorTintColor:[UIColor lightGrayColor]];
                    [_pageControlImages setNumberOfPages:imeges.count];
                    [_pageControlImages setCurrentPage:_scrollViewImage.contentOffset.x/280];
                }
                
                
            }

        }
        else
        {
            [_imgPost setImageWithURL:[NSURL URLWithString:[_dictShowDetails objectForKeyNonNull:@"mpImage"]] placeholderImage:[UIImage imageNamed:@"default_marketplace@2x.png"]];
        }
    }
    else
    {
         [_imgPost setImageWithURL:[NSURL URLWithString:[_dictShowDetails objectForKeyNonNull:@"mpImage"]] placeholderImage:[UIImage imageNamed:@"default_marketplace@2x.png"]];
    }
    
    if ([[_dictShowDetails objectForKeyNonNull:@"miles"] floatValue]<15)
    {
        _lblLocation.text=[NSString stringWithFormat:@"%@ miles away", [_dictShowDetails objectForKeyNonNull:@"miles"] ];
        
    }
    else
    {
        _lblLocation.text=[NSString stringWithFormat:@"%@", [_dictShowDetails objectForKeyNonNull:@"UserUniversityName"]];
       
    }

    
    
//    if (![[_dictShowDetails objectForKeyNonNull:@"mpContactEmail"] isEqualToString:@""])
//    {
//        _lblDescription.text = [_lblDescription.text stringByAppendingFormat:@"Email: %@",[_dictShowDetails objectForKeyNonNull:@"mpContactEmail"]];
//    }
//    if ([[_dictShowDetails objectForKeyNonNull:@"mpContactPhone"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length >0)
//    {
//        _lblDescription.text = [_lblDescription.text stringByAppendingFormat:@"\n\nPhone: %@",[_dictShowDetails objectForKeyNonNull:@"mpContactPhone"]];
//    }
    
    _lblDescription.text = [_dictShowDetails objectForKeyNonNull:@"mpDesc"];
    [_lblDescription sizeToFit];
    
//    _btnView.frame = CGRectMake(218,_lblDescription.frame.origin.y+_lblDescription.frame.size.height,95,25);
    
    if (![[_dictShowDetails objectForKeyNonNull:@"mpImage"] isEqualToString:@""])
    {
       
    }
    
    [_scrollViewPostImage setContentSize:CGSizeMake(self.view.width, _lblDescription.yOrigin+_lblDescription.height+5)];
}


- (UIImage *)blurredImageWithImage:(UIImage *)sourceImage withRatio:(float)ratio{
    
    //  Create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:sourceImage.CGImage];
    
    //  Setting up Gaussian Blur
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:ratio] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    /*  CIGaussianBlur has a tendency to shrink the image a little, this ensures it matches
     *  up exactly to the bounds of our original image */
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *retVal = [UIImage imageWithCGImage:cgImage];
    return retVal;
}
- (void)createPDFWithImagesArray:(NSMutableArray *)array andFileName:(NSString *)fileName
{

     NSString *PDFPath = [Utils getPathForFolderPath:@"Shared_File" withFileName:[NSString stringWithFormat:@"Blur_%@",fileName]];
    [arryBlurPDF addObject:PDFPath];
    
    UIGraphicsBeginPDFContextToFile(PDFPath, CGRectZero, nil);
    for (UIImage *image in array)
    {
        // Mark the beginning of a new page.
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 300, 400), nil);
        
        [image drawInRect:CGRectMake(0, 0, 300, 400)];
    }
    UIGraphicsEndPDFContext();
   

}


- (void)tappedFullImage
{
    
        
    if ([[_dictShowDetails objectForKeyNonNull:@"mpDoc"] isEqualToString:@""])
    {
        [Utils showAlertViewWithMessage:@"No abstract available"];
    }
    else
    {
        [self.view addSubview:_docsView];
        if ([[_dictShowDetails objectForKeyNonNull:@"mpDoc"] rangeOfString:@".pdf"].location != NSNotFound || [[_dictShowDetails objectForKeyNonNull:@"mpDoc"] rangeOfString:@".doc"].location != NSNotFound ||[[_dictShowDetails objectForKeyNonNull:@"mpDoc"] rangeOfString:@".docx"].location != NSNotFound)
        {
            UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 20, 320, 500)];
            
            NSURL *targetURL = [NSURL URLWithString:[_dictShowDetails objectForKeyNonNull:@"mpDoc"]];
            NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
            [webView loadRequest:request];

            webView.scalesPageToFit = YES;
            webView.contentMode = UIViewContentModeScaleAspectFit;

            [webView setMultipleTouchEnabled:YES];

            [_docsView addSubview:webView];
            [_docsView bringSubviewToFront:_btnClose];
        }
        else
        {
            [_imgDocsImages setImageWithURL:[NSURL URLWithString:[_dictShowDetails objectForKeyNonNull:@"mpDoc"]]placeholderImage:[UIImage imageNamed:@"default_marketplace@2x.png"]];
        }
    }

}

- (IBAction)tappedFullMainImage:(id)sender
{
    if ([[_dictShowDetails objectForKeyNonNull:@"mpImage"] isEqualToString:@""])
    {
        [Utils showAlertViewWithMessage:@"No image available"];
    }
    else
    {
       
        if ([[_dictShowDetails objectForKeyNonNull:@"type"] isEqualToString:@"2" ])
        {
            NSMutableArray *imeges=[[NSMutableArray alloc] initWithArray:[_dictShowDetails objectForKeyNonNull:@"mpImages"]];
            if (imeges.count!=0)
            {
                for (int i=0; i<imeges.count; i++)
                {
                    if (i==[sender tag] )
                    {
                        
                        if (!([[[[imeges objectAtIndex:i] valueForKey:@"image"] pathExtension] isEqualToString:@"jpg"] || [[[[imeges objectAtIndex:i] valueForKey:@"image"] pathExtension] isEqualToString:@"png"] || [[[[imeges objectAtIndex:i] valueForKey:@"image"] pathExtension] isEqualToString:@"jpeg"]))
                        {
                            //  [_imgMainImage setImage:[UIImage imageWithPDFURL:[NSURL URLWithString:[[imeges objectAtIndex:i] valueForKey:@"image"]] atSize:CGSizeMake( _imgMainImage.width,_imgMainImage.height ) atPage:1 ]];
                            //[doc addObject:[[[imeges objectAtIndex:i] valueForKey:@"image"] objectAtIndex:i]];
                            
                            selectedImage=i;
                            
                            
                            if (arryBlurPDF.count >= selectedImage+1)
                            {
                                QLPreviewController *previewController = [[QLPreviewController alloc] init];
                                
                                previewController.dataSource = self;
                                previewController.delegate = self;
                                
                                [self presentViewController:previewController animated:YES completion:nil];
                            
                            }
                            
                        }
                        else
                        {
                             [self.view addSubview:_viewFullImage];
                            [_imgMainImage setImageWithURL:[NSURL URLWithString:[[imeges objectAtIndex:i] valueForKey:@"image"]]placeholderImage:[UIImage imageNamed:@"default_marketplace@2x.png"]];
                            
                        }

                    }
                }
 
            }
            else
            {
                [self.view addSubview:_viewFullImage];
                [_imgMainImage setImageWithURL:[NSURL URLWithString:[_dictShowDetails objectForKeyNonNull:@"mpImage"]]placeholderImage:[UIImage imageNamed:@"default_marketplace@2x.png"]];
            }
            
        }
        else
        {
            [self.view addSubview:_viewFullImage];
            [_imgMainImage setImageWithURL:[NSURL URLWithString:[_dictShowDetails objectForKeyNonNull:@"mpImage"]]placeholderImage:[UIImage imageNamed:@"default_marketplace@2x.png"]];
        }
    }
    
}

    
- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return 1;
}
- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
      return [NSURL fileURLWithPath:[arryBlurPDF objectAtIndex:selectedImage]];
 
}


#pragma mark - Buton Action

- (IBAction)btnBackTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];

}

- (IBAction)btnEditMarketPlaceTapped:(id)sender
{
    CreateMarketPlaceViewController * createMarketPlaceView = [[CreateMarketPlaceViewController alloc]initWithNibName:@"CreateMarketPlaceViewController" bundle:nil];
            createMarketPlaceView.isEditing = YES;
            createMarketPlaceView.dictEditMarketPlace = _dictShowDetails;
            [self.navigationController pushViewController:createMarketPlaceView animated:YES];
}

- (IBAction)deleteMarketPlaceButtonClick:(UIButton *)sender
{
    [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"Are you sure you to delete this ad?" leftButtonTitle:@"Yes" rightButtonTitle:@"No" selectedButton:^(NSInteger selected, UIAlertView *aView)
     {
         if(selected == 0)
         {
             [self callAPIDeleteMarketPlace];
         }
     }];
}

- (IBAction)btnFullMainImageTapped:(UIButton *)sender
{
    [self tappedFullMainImage:sender];
}



- (IBAction)btnDocsTapped:(id)sender
{
    [self tappedFullImage];
}

- (IBAction)btnContactTapped:(id)sender
{
   
    NSDictionary *dictBuddyDetails = @{kBuddyId: [_dictShowDetails objectForKeyNonNull:@"adminId"],kBuddyName:[_dictShowDetails objectForKeyNonNull:@"adminName"],kBuddyImage:[_dictShowDetails objectForKeyNonNull:@"adminImage"]};
    ChatScreenViewController *chatScreenViewC = [[ChatScreenViewController alloc] initWithNibName:@"ChatScreenViewController" bundle:nil];
    [chatScreenViewC setDictBuddyInfo:dictBuddyDetails];
    [chatScreenViewC setHidesBottomBarWhenPushed:YES];
    [chatScreenViewC setIsGroup:NO];
    [self.navigationController pushViewController:chatScreenViewC animated:YES];

}

- (IBAction)btnCloseTapped:(id)sender
{
     [_docsView removeFromSuperview];
}

- (IBAction)btnCloseImageTapped:(UIButton *)sender
{
    [_viewFullImage removeFromSuperview];
}

- (void)callAPIDeleteMarketPlace
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [_dictShowDetails objectForKeyNonNull:@"mpId"],@"id",
                              nil];
    
    [Utils startLoaderWithMessage:@""];
    
    [Connection callServiceWithName:kDeleteMarketPlace postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         
         [Utils stopLoader];
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 [self.navigationController popViewControllerAnimated:YES];
             }
         }
     }];
}

@end
