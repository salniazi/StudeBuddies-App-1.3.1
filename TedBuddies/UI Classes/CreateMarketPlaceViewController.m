//
//  CreateMarketPlaceViewController.m
//  TedBuddies
//
//  Created by Sunil on 29/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import "CreateMarketPlaceViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "MarketPlaceViewController.h"
#import "UIImage+Utility.h"
#import "HMSegmentedControl.h"
#import "RSBarcodes.h"
#import <CoreLocation/CoreLocation.h>
#import "DropBoxViewController.h"
#import "GoogleDriveViewController.h"
#import "UIImage+PDF.h"
#import <QuickLook/QuickLook.h>

@interface CreateMarketPlaceViewController ()<CLLocationManagerDelegate,UIScrollViewDelegate,QLPreviewControllerDelegate,QLPreviewControllerDataSource>
{
     NSInteger selectedSegment;
    NSMutableArray *arryCondition;
    BOOL isCourseSelect;
    BOOL isConditionSelect;
    NSArray *arrayCoursePrefix;
    RSScannerViewController *scanner;
    AVMetadataMachineReadableCodeObject *code;
    
    HMSegmentedControl *segmentedControl;
    
    NSString *idCourse;
    
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    
    NSString *latitude;
    NSString *longitude;
    
    UINavigationController *navController;
    
    NSInteger selectedImage;
    NSMutableArray *doc;
    
    UIWebView *webView;

}
@end

@implementation CreateMarketPlaceViewController

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
    locationManager.distanceFilter = kCLDistanceFilterNone;
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

    
    [_scrollViewImage setContentSize:CGSizeMake(0, 119)];
    selectedImage=0;
    [_pageControlImages setCurrentPageIndicatorTintColor:kBlueColor];
    [_pageControlImages setPageIndicatorTintColor:[UIColor lightGrayColor]];
    _pageControlImages.hidden=YES;
    
    [self setFont];
    arrayCoursePrefix=[[NSArray alloc]init];
    [self callAPICoursePrifix];
    
    arryCondition=[[NSMutableArray alloc] init];
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
    
    [dict setValue:@"As New" forKey:@"CustomObject"];
    [dict setValue:@"As New"  forKey:@"DisplayText"];
    [arryCondition addObject:dict];
    
    dict=[[NSMutableDictionary alloc]init];
    [dict setValue:@"Good" forKey:@"CustomObject"];
    [dict setValue:@"Good" forKey:@"DisplayText"];
    [arryCondition addObject:dict];
    
    dict=[[NSMutableDictionary alloc]init];
    [dict setValue:@"Fair" forKey:@"CustomObject"];
    [dict setValue:@"Fair" forKey:@"DisplayText"];
    [arryCondition addObject:dict];

    doc=[[NSMutableArray alloc] init];
    
    [_txtCondition setDelegate:self];
    [_txtCondition setBackgroundColor:[UIColor whiteColor]];
    [_txtCondition setPopoverSize:CGRectMake(17, _txtCondition.frame.origin.y+40, self.view.width-34, 135.0)];
    
    
    [_txtConditionOther setDelegate:self];
    [_txtConditionOther setBackgroundColor:[UIColor whiteColor]];
    [_txtConditionOther setPopoverSize:CGRectMake(17, _txtConditionOther.frame.origin.y+40, self.view.width-34, 135.0)];
    
    [_txtCourse setDelegate:self];
    [_txtCourse setBackgroundColor:[UIColor whiteColor]];
    [_txtCourse setPopoverSize:CGRectMake(17, _txtCourse.frame.origin.y+40, self.view.width-34, 135.0)];

    
    _txtViewContact.delegate = self;
    
    segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Textbooks", @"Notes", @"Other"]];
    segmentedControl.frame = CGRectMake(0, 0, self.viewSegment.frame.size.width-5, self.viewSegment.frame.size.height);
    segmentedControl.selectionIndicatorHeight = 3.0f;
    segmentedControl.backgroundColor = [UIColor clearColor];
    segmentedControl.selectedTitleTextAttributes =@{NSForegroundColorAttributeName : [UIColor colorWithRed:(119.0f/255.0f) green:(190.0f/255.0f) blue:(145.0f/255.0f) alpha:1]};
    segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 0, 0, 0);
    segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    segmentedControl.selectionIndicatorColor= [UIColor colorWithRed:(119.0f/255.0f) green:(190.0f/255.0f) blue:(145.0f/255.0f) alpha:1];
    [segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.viewSegment addSubview:segmentedControl];
    selectedSegment=0;
    
    scanner = [[RSScannerViewController alloc] initWithCornerView:YES
                                                      controlView:YES
                                                  barcodesHandler:^(NSArray *barcodeObjects) {
                                                      if (barcodeObjects.count > 0) {
                                                          [barcodeObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                              
                                                              code = obj;
                                                              
                                                                 
                                                            [scanner dismissViewControllerAnimated:true completion:nil];
                                                                  
                                                               
                                                            
                                                          }];
                                                      }
                                                      
                                                  }
               
                                          preferredCameraPosition:AVCaptureDevicePositionBack];
    
    [scanner setIsButtonBordersVisible:YES];
    [scanner setStopOnFirst:YES];
    [scanner.sidebarView setBackgroundColor:[UIColor colorWithRed:103.0/255.0  green:163.0/255.0 blue:201.0/255.0 alpha:1.0]];
   
    
   

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (code != nil)
    {
        _txtISBN.text=code.stringValue;
        if (![_txtISBN.text isEqualToString:@""])
        {
            [self callAPIBookInfoForISBN];
        }
        code=nil;
    }
    
    if (SharedAppDelegate.cmResponce.count!=0)
    {
       for (int i=0; i<SharedAppDelegate.cmResponce.count; i++)
        {
            UIImage *image;
            UIImageView *imgViewDocsImage = [[UIImageView alloc] initWithFrame:CGRectMake(_scrollViewImage.contentSize.width, 0, 146, 119)];
            
            if (!([[[SharedAppDelegate.cmResponce objectAtIndex:i] pathExtension] isEqualToString:@"jpg"] || [[[SharedAppDelegate.cmResponce objectAtIndex:i] pathExtension] isEqualToString:@"png"] || [[[SharedAppDelegate.cmResponce objectAtIndex:i] pathExtension] isEqualToString:@"jpeg"]))
            {
                 NSData *data=[[NSData alloc] initWithContentsOfFile:[SharedAppDelegate.cmResponce objectAtIndex:i]];
                 image = [UIImage imageWithPDFData:data atSize:CGSizeMake( imgViewDocsImage.width, imgViewDocsImage.height ) atPage:1 ];
                
                
                [doc addObject:[SharedAppDelegate.cmResponce objectAtIndex:i]];
            }
            else
            {
                
                 image = [UIImage imageWithContentsOfFile: [SharedAppDelegate.cmResponce objectAtIndex:i]];
                
                
              
                
                [doc addObject:[SharedAppDelegate.cmResponce objectAtIndex:i]];
            }
           
            imgViewDocsImage.image = image;
            [_scrollViewImage addSubview:imgViewDocsImage];
            [imgViewDocsImage setContentMode:UIViewContentModeScaleAspectFill];
            [imgViewDocsImage setClipsToBounds:YES];
            [_scrollViewImage setContentSize:CGSizeMake(_scrollViewImage.contentSize.width+146, 119)];
            
            UIButton *close=[[UIButton alloc] initWithFrame:CGRectMake(_scrollViewImage.contentSize.width-25, 5, 20, 20)];
            [close setImage:[UIImage imageNamed:@"cancelBtnWorkoutPartners.png"] forState:UIControlStateNormal];
            [close addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
            close.tag=_scrollViewImage.contentSize.width/146;
            [_scrollViewImage addSubview:close];
            _scrollViewImage.contentOffset=CGPointMake(_scrollViewImage.contentSize.width-146,0);
            if (_scrollViewImage.contentSize.width/146==0)
            {
                _scrollViewImage.backgroundColor=[UIColor clearColor];
            }
            else
            {
                _scrollViewImage.backgroundColor=[UIColor whiteColor];
            }
            
        }
        
        [_pageControlImages setNumberOfPages:_scrollViewImage.contentSize.width/146];
        [_pageControlImages setCurrentPage:_scrollViewImage.contentOffset.x/146];
        
        if (doc.count!=0)
        {
            _btnMoreUpload.hidden=NO;
        }

    }
    [SharedAppDelegate.cmResponce removeAllObjects];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl1
{
    
    selectedSegment=segmentedControl1.selectedSegmentIndex;
    _btnMoreUpload.hidden=true;
    [doc removeAllObjects];
    if (selectedSegment==0)
    {
        _lblAddImage.text=@"Add Images";
        _viewNoteBooks.alpha=1.0;
        _viewNotes.alpha=0.0;
        _viewOthers.alpha=0.0;
        [self.scrlViewMain setContentSize:CGSizeMake(self.scrlViewMain.width, self.viewNoteBooks.yOrigin+self.viewNoteBooks.height+10)];
        for (UIView *imgView in _scrollViewImage.subviews)
        {
            [imgView removeFromSuperview];
        }
        _scrollViewImage.contentSize=CGSizeMake(0, 119);
        _pageControlImages.hidden=YES;

    }
    else if (selectedSegment==1)
    {
        _lblAddImage.text=@"Scan OR Upload";
        _viewNotes.alpha=1.0;
        _viewNoteBooks.alpha=0.0;
        _viewOthers.alpha=0.0;
        _pageControlImages.hidden=NO;
        if (_isEditing)
        {
            NSMutableArray *imeges=[[NSMutableArray alloc] initWithArray:[_dictEditMarketPlace objectForKeyNonNull:@"mpImages"]];
            for (int i=0; i<imeges.count; i++)
            {
                
                
                
                UIImageView *imgPostImage = [[UIImageView alloc] initWithFrame:CGRectMake(_scrollViewImage.contentSize.width, 0, 146, 119)];
                
                [imgPostImage setImageWithURL:[NSURL URLWithString:[[imeges objectAtIndex:i] valueForKey:@"image"]]placeholderImage:[UIImage imageNamed:@"appicon.png"]];
                [_scrollViewImage addSubview:imgPostImage];
                
                [imgPostImage setContentMode:UIViewContentModeScaleAspectFill];
                [imgPostImage setClipsToBounds:YES];
                [_scrollViewImage setContentSize:CGSizeMake(_scrollViewImage.contentSize.width+146, 119)];
                
                
                UIButton *close=[[UIButton alloc] initWithFrame:CGRectMake(_scrollViewImage.contentSize.width-25, 5, 20, 20)];
                [close setImage:[UIImage imageNamed:@"cancelBtnWorkoutPartners.png"] forState:UIControlStateNormal];
                [close addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
                close.tag=_scrollViewImage.contentSize.width/146;
                [_scrollViewImage addSubview:close];
                
                
                if ([[[imeges objectAtIndex:i] valueForKey:@"isActive"] boolValue])
                {
                    _scrollViewImage.contentOffset=CGPointMake(_scrollViewImage.contentSize.width-146,0);
                    [_pageControlImages setNumberOfPages:imeges.count];
                    [_pageControlImages setCurrentPage:_scrollViewImage.contentOffset.x/146];
                }
            }
            

        }
        else
        {
            [self.scrlViewMain setContentSize:CGSizeMake(self.scrlViewMain.width, self.viewNotes.yOrigin+self.viewNotes.height+10)];
            for (UIView *imgView in _scrollViewImage.subviews)
            {
                [imgView removeFromSuperview];
            }
            _scrollViewImage.contentSize=CGSizeMake(0, 119);
            _pageControlImages.numberOfPages=0;
        }
        
        
    }
    else if (selectedSegment==2)
    {
        _lblAddImage.text=@"Add Images";
        _viewOthers.alpha=1.0;
        _viewNoteBooks.alpha=0.0;
        _viewNotes.alpha=0.0;
        [self.scrlViewMain setContentSize:CGSizeMake(self.scrlViewMain.width, self.viewOthers.yOrigin+self.viewOthers.height+10)];
        for (UIView *imgView in _scrollViewImage.subviews)
        {
            [imgView removeFromSuperview];
        }
        _scrollViewImage.contentSize=CGSizeMake(0, 119);
        _pageControlImages.hidden=YES;


    }
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MPGTextFieldDelegate

- (NSArray *)dataForPopoverInTextField:(MPGTextField *)textField
{
    if ([textField isEqual:_txtCondition] || [textField isEqual:_txtConditionOther]) {
        
        return arryCondition;
    }
    else if ([textField isEqual:_txtCourse])
    {
        if (arrayCoursePrefix.count==0)
        {
            
            [_txtCourse resignFirstResponder];
         
            UIAlertView *alt=[[UIAlertView alloc]initWithTitle:@"StudeBuddies" message:@"Uoload your class schedule.!" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alt show];
            return nil;
        }
        else
        {
            isCourseSelect=NO;
            return arrayCoursePrefix;
        }

    }
    else{
        return nil;
    }
}

- (BOOL)textFieldShouldSelect:(MPGTextField *)textField
{
    return YES;
}

- (void)textField:(MPGTextField *)textField didEndEditingWithSelection:(NSDictionary *)result
{
    //A selection was made - either by the user or by the textfield. Check if its a selection from the data provided or a NEW entry.
    
    if ([textField isEqual:_txtCondition] || [textField isEqual:_txtConditionOther])
    {
        if ([[result objectForKey:@"CustomObject"] isKindOfClass:[NSString class]] && [[result objectForKey:@"CustomObject"] isEqualToString:@"NEW"])
        {
            _txtCondition.text=@"";
            _txtConditionOther.text=@"";
            isConditionSelect=NO;
            [Utils showAlertViewWithMessage:@"Select condition.!"];
        }
        else
        {
            isConditionSelect=YES;
        }
    
    }
    else if ([textField isEqual:_txtCourse])
    {
        if ([[result objectForKey:@"CustomObject"] isKindOfClass:[NSString class]] && [[result objectForKey:@"CustomObject"] isEqualToString:@"NEW"])
        {
            _txtCourse.text=@"";
            isCourseSelect=NO;
            [Utils showAlertViewWithMessage:@"Select your Course.!"];
        }
        else
        {
            isCourseSelect=YES;
            idCourse=[[result objectForKeyNonNull:@"CustomObject"] objectForKeyNonNull:@"classId"];
            
        }

    }
    
    
}

-(void) editMarketPlace
{
    
    
    
    if(_isEditing)
    {
        for (int i=0; i < arrayCoursePrefix.count; i++)
        {
            if ([[_dictEditMarketPlace objectForKeyNonNull:@"fkcourseId"] isEqualToString:[[arrayCoursePrefix objectAtIndex:i] valueForKey:@"DisplayText"]])
            {
                idCourse=[[[arrayCoursePrefix objectAtIndex:i] valueForKey:@"CustomObject"] valueForKey:@"classId"];
            }
        }
        
        [_lblNavBar setText:@"Edit Marketplace"];
        
        if ([[_dictEditMarketPlace objectForKeyNonNull:@"type"] isEqualToString:@"1" ])
        {
            selectedSegment=0;
            segmentedControl.selectedSegmentIndex=0;
            _lblAddImage.text=@"Add Images";
            _viewNoteBooks.alpha=1.0;
            _viewNotes.alpha=0.0;
            _viewOthers.alpha=0.0;
            [self.scrlViewMain setContentSize:CGSizeMake(self.scrlViewMain.width, self.viewNoteBooks.yOrigin+self.viewNoteBooks.height+10)];
            
            _txtFieldName.text = [_dictEditMarketPlace objectForKeyNonNull:kMpName];
             _txtAuthor.text = [_dictEditMarketPlace objectForKeyNonNull:@"Author"];
            _txtFieldPrice.text = [_dictEditMarketPlace objectForKeyNonNull:kMpPrice];
            _txtViewContact.text = [_dictEditMarketPlace objectForKeyNonNull:kMpDesc];
            _txtISBN.text = [_dictEditMarketPlace objectForKeyNonNull:@"isbn"];
            _txtCondition.text = [_dictEditMarketPlace objectForKeyNonNull:@"condition"];
            
            if (![[_dictEditMarketPlace objectForKeyNonNull:@"mpImage"] isEqualToString:@""])
            {
                for (UIImageView *imgView in _scrollViewImage.subviews)
                {
                    [imgView removeFromSuperview];
                }
                
                
                NSString *url = [_dictEditMarketPlace objectForKeyNonNull:@"mpImage"];
                NSArray *arrComponents = [url componentsSeparatedByString:@"/"];
                NSString *imageName = [arrComponents lastObject];
                NSString *strPath = [Utils getPathForFolderPath:@"Shared_File" withFileName:imageName];
                NSData *data=[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[[_dictEditMarketPlace objectForKeyNonNull:@"mpImage"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                if ([[NSFileManager defaultManager] createFileAtPath:strPath contents:data attributes:nil])
                {
                    [doc addObject:strPath];
                    
                }

                
                NSString *imgName=[NSString stringWithFormat:@"%@",[_dictEditMarketPlace objectForKeyNonNull:@"mpImage"]];
                UIImageView *imgPostImage = [[UIImageView alloc] initWithFrame:CGRectMake(_scrollViewImage.contentSize.width, 0, 146, 119)];
                
                [imgPostImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",imgName]]placeholderImage:[UIImage imageNamed:@"appicon.png"]];
                [_scrollViewImage addSubview:imgPostImage];
                
                [imgPostImage setContentMode:UIViewContentModeScaleAspectFill];
                [imgPostImage setClipsToBounds:YES];
                [_scrollViewImage setContentSize:CGSizeMake(_scrollViewImage.contentSize.width+146, 119)];
                
                UIButton *close=[[UIButton alloc] initWithFrame:CGRectMake(_scrollViewImage.contentSize.width-25, 5, 20, 20)];
                [close setImage:[UIImage imageNamed:@"cancelBtnWorkoutPartners.png"] forState:UIControlStateNormal];
                [close addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
                close.tag=_scrollViewImage.contentSize.width/146;
                [_scrollViewImage addSubview:close];

            }
            _pageControlImages.hidden=YES;

            
        }
        if ([[_dictEditMarketPlace objectForKeyNonNull:@"type"] isEqualToString:@"2" ])
        {
            selectedSegment=1;
            segmentedControl.selectedSegmentIndex=1;
            _lblAddImage.text=@"Scan OR Upload";
            _viewNotes.alpha=1.0;
            _viewNoteBooks.alpha=0.0;
            _viewOthers.alpha=0.0;
            [self.scrlViewMain setContentSize:CGSizeMake(self.scrlViewMain.width, self.viewNotes.yOrigin+self.viewNotes.height+10)];
            
            _txtNameNote.text = [_dictEditMarketPlace objectForKeyNonNull:kMpName];
            _txtPriceNote.text = [_dictEditMarketPlace objectForKeyNonNull:kMpPrice];
            _txtViewContactNote.text = [_dictEditMarketPlace objectForKeyNonNull:kMpDesc];
            _txtCourse.text = [_dictEditMarketPlace objectForKeyNonNull:@"fkcourseId"];
            
             [_scrollViewImage setContentSize:CGSizeMake(0, 119)];
            
            for (UIImageView *imgView in _scrollViewImage.subviews)
            {
                [imgView removeFromSuperview];
            }
            
            NSMutableArray *imeges=[[NSMutableArray alloc] initWithArray:[_dictEditMarketPlace objectForKeyNonNull:@"mpImages"]];
            for (int i=0; i<imeges.count; i++)
            {
                
                
               
                UIImageView *imgPostImage = [[UIImageView alloc] initWithFrame:CGRectMake(_scrollViewImage.contentSize.width, 0, 146, 119)];
                
                NSString *url = [[imeges objectAtIndex:i] valueForKey:@"image"];
                NSArray *arrComponents = [url componentsSeparatedByString:@"/"];
                NSString *imageName = [arrComponents lastObject];
                NSString *strPath = [Utils getPathForFolderPath:@"Shared_File" withFileName:imageName];
                NSData *data=[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[[[imeges objectAtIndex:i] valueForKey:@"image"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                if ([[NSFileManager defaultManager] createFileAtPath:strPath contents:data attributes:nil])
                {
                    [doc addObject:strPath];
                    
                }

                
                if (!([[[[imeges objectAtIndex:i] valueForKey:@"image"] pathExtension] isEqualToString:@"jpg"] || [[[[imeges objectAtIndex:i] valueForKey:@"image"] pathExtension] isEqualToString:@"png"] || [[[[imeges objectAtIndex:i] valueForKey:@"image"] pathExtension] isEqualToString:@"jpeg"]))
                {
                    [imgPostImage setImage:[UIImage imageWithPDFURL:[NSURL URLWithString:[[imeges objectAtIndex:i] valueForKey:@"image"]] atSize:CGSizeMake( imgPostImage.width, imgPostImage.height ) atPage:1 ]];                    
                    
                    
                    
                }
                else
                {
                    
                    [imgPostImage setImageWithURL:[NSURL URLWithString:[[imeges objectAtIndex:i] valueForKey:@"image"]]placeholderImage:[UIImage imageNamed:@"default_marketplace@2x.png"]];
                    
                }
                
                
                

                [_scrollViewImage addSubview:imgPostImage];
                
                [imgPostImage setContentMode:UIViewContentModeScaleAspectFill];
                [imgPostImage setClipsToBounds:YES];
                [_scrollViewImage setContentSize:CGSizeMake(_scrollViewImage.contentSize.width+146, 119)];
                
                
                UIButton *close=[[UIButton alloc] initWithFrame:CGRectMake(_scrollViewImage.contentSize.width-25, 5, 20, 20)];
                [close setImage:[UIImage imageNamed:@"cancelBtnWorkoutPartners.png"] forState:UIControlStateNormal];
                [close addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
                close.tag=_scrollViewImage.contentSize.width/146;
                [_scrollViewImage addSubview:close];
                
                
                
                if (_scrollViewImage.contentSize.width/146==0)
                {
                    _scrollViewImage.backgroundColor=[UIColor clearColor];
                }
                else
                {
                    _scrollViewImage.backgroundColor=[UIColor whiteColor];
                }

                
                if ([[[imeges objectAtIndex:i] valueForKey:@"isActive"] boolValue])
                {
                      _scrollViewImage.contentOffset=CGPointMake(_scrollViewImage.contentSize.width-146,0);
                    _pageControlImages.hidden=NO;
                    [_pageControlImages setNumberOfPages:imeges.count];
                    [_pageControlImages setCurrentPage:_scrollViewImage.contentOffset.x/146];
                }
            }
            
            if (selectedSegment==1)
            {
                if (doc.count!=0)
                {
                    _btnMoreUpload.hidden=NO;
                }
            }

            


        }
        if ([[_dictEditMarketPlace objectForKeyNonNull:@"type"] isEqualToString:@"3" ])
        {
            selectedSegment=2;
            segmentedControl.selectedSegmentIndex=2;
            _lblAddImage.text=@"Add Images";
            _viewOthers.alpha=1.0;
            _viewNoteBooks.alpha=0.0;
            _viewNotes.alpha=0.0;
            [self.scrlViewMain setContentSize:CGSizeMake(self.scrlViewMain.width, self.viewOthers.yOrigin+self.viewOthers.height+10)];
            
            _txtNameOther.text = [_dictEditMarketPlace objectForKeyNonNull:kMpName];
            _txtPriceOther.text = [_dictEditMarketPlace objectForKeyNonNull:kMpPrice];
            _txtViewContectOther.text = [_dictEditMarketPlace objectForKeyNonNull:kMpDesc];
              _txtConditionOther.text = [_dictEditMarketPlace objectForKeyNonNull:@"condition"];
            
            if (![[_dictEditMarketPlace objectForKeyNonNull:@"mpImage"] isEqualToString:@""])
            {
                for (UIImageView *imgView in _scrollViewImage.subviews)
                {
                    [imgView removeFromSuperview];
                }
                
                NSString *url = [_dictEditMarketPlace objectForKeyNonNull:@"mpImage"];
                NSArray *arrComponents = [url componentsSeparatedByString:@"/"];
                NSString *imageName = [arrComponents lastObject];
                NSString *strPath = [Utils getPathForFolderPath:@"Shared_File" withFileName:imageName];
                NSData *data=[[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:[[_dictEditMarketPlace objectForKeyNonNull:@"mpImage"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                if ([[NSFileManager defaultManager] createFileAtPath:strPath contents:data attributes:nil])
                {
                    [doc addObject:strPath];
                    
                }
                
                NSString *imgName=[NSString stringWithFormat:@"%@",[_dictEditMarketPlace objectForKeyNonNull:@"mpImage"]];
                UIImageView *imgPostImage = [[UIImageView alloc] initWithFrame:CGRectMake(_scrollViewImage.contentSize.width, 0, 146, 119)];
                
                [imgPostImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",imgName]]placeholderImage:[UIImage imageNamed:@"appicon.png"]];
                [_scrollViewImage addSubview:imgPostImage];
                
                [imgPostImage setContentMode:UIViewContentModeScaleAspectFill];
                [imgPostImage setClipsToBounds:YES];
                [_scrollViewImage setContentSize:CGSizeMake(_scrollViewImage.contentSize.width+146, 119)];
                
                UIButton *close=[[UIButton alloc] initWithFrame:CGRectMake(_scrollViewImage.contentSize.width-25, 5, 20, 20)];
                [close setImage:[UIImage imageNamed:@"cancelBtnWorkoutPartners.png"] forState:UIControlStateNormal];
                [close addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
                close.tag=_scrollViewImage.contentSize.width/146;
                [_scrollViewImage addSubview:close];

            }

            _pageControlImages.hidden=YES;
        }

        
        
        
        
        
        if (_txtViewContact.text.length > 0 && ![_txtViewContact.text isEqualToString:@"Description    "])
        {
            [_txtViewContact setTextColor:[UIColor blackColor]];
        }
        if (_txtViewContactNote.text.length > 0 && ![_txtViewContactNote.text isEqualToString:@"Description    "])
        {
            [_txtViewContactNote setTextColor:[UIColor blackColor]];
        }
        if (_txtViewContectOther.text.length > 0 && ![_txtViewContectOther.text isEqualToString:@"Description    "])
        {
            [_txtViewContectOther setTextColor:[UIColor blackColor]];
        }
        
        
        
        //        [_imgPostImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",imgName]]placeholderImage:[UIImage imageNamed:@"appicon.png"]];
                [_scrollViewDocs setBackgroundColor:[UIColor clearColor]];
        if (![[_dictEditMarketPlace objectForKeyNonNull:@"mpDoc"] isEqualToString:@""])
        {
            for (UIImageView *imgView in _scrollViewDocs.subviews)
            {
                [imgView removeFromSuperview];
            }
            
            NSString *imgDocs=[NSString stringWithFormat:@"%@",[_dictEditMarketPlace objectForKeyNonNull:@"mpDoc"]];
            UIImageView *imgPostDoc = [[UIImageView alloc] initWithFrame:CGRectMake(_scrollViewDocs.contentSize.width, 0, 146, 119)];
            
            [imgPostDoc setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",imgDocs]]placeholderImage:[UIImage imageNamed:@"appicon.png"]];
            [_scrollViewDocs addSubview:imgPostDoc];
            [imgPostDoc setContentMode:UIViewContentModeScaleAspectFill];
            [imgPostDoc setClipsToBounds:YES];
            [_scrollViewDocs setContentSize:CGSizeMake(_scrollViewDocs.contentSize.width+146, 119)];
        }
        
        
        
        //        [_imgDocs setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",imgDocs]]placeholderImage:[UIImage imageNamed:@"appicon.png"]];
        
        
    }
}
-(void) setFont
{
    if (!_isEditing)
    {
        //[Utils showAlertViewWithMessage:@"To add the Abstract and or Introduction section of your research paper, kindly upload Image by tapping Add research paper"];
    }
    
    
//    _lblAddImage.hidden=_isEditing;
//    _lblDocs.hidden=_isEditing;
//    _imgIconImage1.hidden=_isEditing;
//    _imgIconImage2.hidden=_isEditing;
    [_lblNavBar setFont:FONT_REGULAR(kNavigationFontSize)];
    
    [_txtFieldName setFont:FONT_REGULAR(14)];
    [_txtFieldPrice setFont:FONT_REGULAR(14)];
    [_txtViewContact setFont:FONT_REGULAR(14)];
    [_txtFieldEmailId setFont:FONT_REGULAR(14)];
    [_txtFieldMobileNumber setFont:FONT_REGULAR(14)];
    

    
    [_lblAddImage setFont:FONT_REGULAR(14)];
    [_btnAddImage.layer setCornerRadius:5];
    [_btnAddImage setClipsToBounds:YES];
    
    NSAttributedString *strName = [[NSAttributedString alloc] initWithString:@"Marketplace Title" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
    self.txtFieldName.attributedPlaceholder = strName;
    
    NSAttributedString *strPrice = [[NSAttributedString alloc] initWithString:@"Price" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
    self.txtFieldPrice.attributedPlaceholder = strPrice;
    
    NSAttributedString *strEmailId = [[NSAttributedString alloc] initWithString:@"ISBN #" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
    self.txtISBN.attributedPlaceholder = strEmailId;
    
    NSAttributedString *strAuthor = [[NSAttributedString alloc] initWithString:@"Author" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
    self.txtAuthor.attributedPlaceholder = strAuthor;
    
    NSAttributedString *strcondition = [[NSAttributedString alloc] initWithString:@"Condition" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
    self.txtCondition.attributedPlaceholder = strcondition;
    
    
    NSAttributedString *strNameNote = [[NSAttributedString alloc] initWithString:@"Marketplace Title" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
    self.txtNameNote.attributedPlaceholder = strNameNote;
    
    NSAttributedString *strPriceNote = [[NSAttributedString alloc] initWithString:@"Price" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
    self.txtPriceNote.attributedPlaceholder = strPriceNote;
    
    NSAttributedString *strCourse = [[NSAttributedString alloc] initWithString:@"Course" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
    self.txtCourse.attributedPlaceholder = strCourse;
    
    NSAttributedString *strConditionOther = [[NSAttributedString alloc] initWithString:@"Condition" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
    self.txtConditionOther.attributedPlaceholder = strConditionOther;
    
    NSAttributedString *strNameOther = [[NSAttributedString alloc] initWithString:@"Marketplace Title" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
    self.txtNameOther.attributedPlaceholder = strNameOther;
    
    NSAttributedString *strPriceOther = [[NSAttributedString alloc] initWithString:@"Price" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
    self.txtPriceOther.attributedPlaceholder = strPriceOther;


    
    UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backSwipeAction)];
    [backSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    
    [self.view addGestureRecognizer:backSwipe];
    
    UITapGestureRecognizer *tapAddDocs = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnDocsTapped:)];
    [_scrollViewDocs addGestureRecognizer:tapAddDocs];
    
    
    [_imgDocs.layer setCornerRadius:5];
    [_imgDocs setClipsToBounds:YES];
    
    [_imgPostImage.layer setCornerRadius:5];
    [_imgPostImage setClipsToBounds:YES];
    
    [_scrollViewImage.layer setCornerRadius:5];
    [_scrollViewImage setClipsToBounds:YES];
    
    [_scrollViewDocs.layer setCornerRadius:5];
    [_scrollViewDocs setClipsToBounds:YES];
    
    
    UITapGestureRecognizer *tapAddImages = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(btnAddImageTapped:)];
    [_scrollViewImage addGestureRecognizer:tapAddImages];
    
    [_txtViewContact setTextColor:[UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8]];
    [_txtViewContact setText:@"Description    "];
    
    [_txtViewContactNote setTextColor:[UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8]];
    [_txtViewContactNote setText:@"Description    "];
    
    [_txtViewContectOther setTextColor:[UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8]];
    [_txtViewContectOther setText:@"Description    "];
    
    [self.scrlViewMain setContentSize:CGSizeMake(self.scrlViewMain.width, self.viewNoteBooks.yOrigin+self.viewNoteBooks.height+10)];
}
#pragma mark - Scrollview Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView==_scrollViewImage)
    {
        selectedImage = scrollView.contentOffset.x/146;
        
        [_pageControlImages setNumberOfPages:scrollView.contentSize.width/146];
        [_pageControlImages setCurrentPage:scrollView.contentOffset.x/146];
        

    }
}
#pragma mark - validation

- (BOOL)isValid
{
    msgString = nil;
    
   //    if([_txtFieldEmailId.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
//    {
//        msgString = @"Please fill the valid email Id";
//        return NO;
//    }
//    if(_txtFieldMobileNumber.text > 0)  // for mobile validation
//    {
//        
//        int length = [self getLength:self.txtFieldMobileNumber.text];
//        if(length != 10)
//        {
//            msgString = @"Enter the valid phone number.";
//            return NO;
// 
//        }
//    }
    
//    if (![Utils NSStringIsValidEmail:_txtFieldEmailId.text])
//    {
//        msgString = @"Don't forget to fill a valid email id";
//        return NO;
//    }
    
    
    if (selectedSegment==0)
    {
        if([_txtISBN.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
        {
            msgString = @"Don't forget to fill the ISBN";
            return NO;
        }

        if([_txtFieldName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
        {
            msgString = @"Don't forget to fill Marketplace Title";
            return NO;
        }
        if([_txtAuthor.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
        {
            msgString = @"Don't forget to fill Author Name";
            return NO;
        }

        if([_txtCondition.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
        {
            msgString = @"Don't forget to select condition";
            return NO;
        }

        if([_txtFieldPrice.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
        {
            msgString = @"Don't forget to fill the price";
            return NO;
        }
        
        if([_txtViewContact.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0 || [_txtViewContact.text isEqualToString:@"Description    "])
        {
            msgString = @"Don't forget to fill the description";
            return NO;
        }
    }
    else if (selectedSegment==1)
    {
        if([_txtCourse.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
        {
            msgString = @"Don't forget to select course";
            return NO;
        }
        if([_txtNameNote.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0 )
        {
            msgString = @"Don't forget to fill Marketplace Title";
            return NO;
        }
        if([_txtPriceNote.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0 )
        {
            msgString = @"Don't forget to fill price";
            return NO;
        }
        if([_txtViewContactNote.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0 || [_txtViewContactNote.text isEqualToString:@"Description    "])
        {
            msgString = @"Don't forget to fill the description";
            return NO;
        }
    }
    else if (selectedSegment==2)
    {
        
        if([_txtNameOther.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
        {
            msgString = @"Don't forget to fill Marketplace Title";
            return NO;
        }
        
        if([_txtConditionOther.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
        {
            msgString = @"Don't forget to select condition";
            return NO;
        }
        
        if([_txtPriceOther.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
        {
            msgString = @"Don't forget to fill the price";
            return NO;
        }
        
        if([_txtViewContectOther.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0 || [_txtViewContectOther.text isEqualToString:@"Description    "])
        {
            msgString = @"Don't forget to fill the description";
            return NO;
        }
    }

    
    
    
    return YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
    //    [self.navigationController popViewControllerAnimated:YES];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    currentLocation = [locations objectAtIndex:0];
    // [locationManager stopUpdatingLocation];
    NSLog(@"Detected Location : %f, %f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
    latitude=[NSString stringWithFormat:@"%f",currentLocation.coordinate.latitude];
    longitude=[NSString stringWithFormat:@"%f",currentLocation.coordinate.longitude];
    
}
#pragma mark - Web Service
- (void)callAPICoursePrifix
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
                              nil];
    [Utils startLoaderWithMessage:@""];
    [Connection callServiceWithName:kGetScheduledClassList postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         [Utils stopLoader];
         
         if (response)
         {
             
             arrayCoursePrefix = nil;
             NSArray *arry=[[NSArray alloc] initWithArray:[response valueForKey:@"Result"]];
             NSMutableArray *Dumy=[[NSMutableArray alloc] init];
             for (int i=0; i<[arry count]; i++)
             {
                 NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
                 [dict setValue:[arry objectAtIndex:i] forKey:@"CustomObject"];
                 [dict setValue:[[arry objectAtIndex:i] valueForKey:@"className"] forKey:@"DisplayText"];
                 [Dumy addObject:dict];
             }
             arrayCoursePrefix=[NSArray arrayWithArray:Dumy];
             
             
             
             // [_tblViewProfessorName reloadData];
             // [_tblViewCoursePrifix setHidden:NO];
             
         }
         [self editMarketPlace];
     }];
}

- (void)callAPIBookInfoForISBN
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              self.txtISBN.text,kISBN,
                              nil];
    [Utils startLoaderWithMessage:@""];
    [Connection callServiceWithName:kGetBookDetailFromISBN postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         [Utils stopLoader];
         if ([[response valueForKey:@"Success"] boolValue])
         {
             if (response)
             {
                 NSMutableArray *arryBookInfo=[[NSMutableArray alloc]init];
                 [arryBookInfo addObject:[response valueForKey:@"Result"]];
                 _txtFieldName.text=[[arryBookInfo objectAtIndex:0] valueForKey:@"mpName"];
                 _txtAuthor.text=[[arryBookInfo objectAtIndex:0] valueForKey:@"Author"];
                 _txtViewContact.text=[[arryBookInfo objectAtIndex:0] valueForKey:@"mpDesc"];
                 
                 if (_txtViewContact.text.length > 0 && ![_txtViewContact.text isEqualToString:@"Description    "])
                 {
                     [_txtViewContact setTextColor:[UIColor blackColor]];
                 }
                 
             }
         }
         else
         {
             [Utils showAlertViewWithMessage:@"ISBN is not found!"];
             _txtISBN.text=@"";
         }
         
         
     }];
}


- (void)callAPICreateMarketPlace
{
    //    public string userId { get; set; }
    //    public string mpId { get; set; }
    //    public List<ProfileImages> mpImages { get; set; }
    //    public List<MpDoc> mpDoc { get; set; }
    //    public string mpName { get; set; }
    //    public string mpPrice { get; set; }
    //    public string mpContactEmail { get; set; }
    //    public string mpContactPhone { get; set; }
    //    public string mpDesc { get; set; }
    
    
    //    NSString * priceFormate1 =[NSString stringWithFormat:@"$ %.2f",[priceFormate doubleValue]];
    //    NSLog(@"%@",priceFormate1);
    //    _txtFieldPrice.text = priceFormate1;
    
    NSString *mpName;
    NSString *author;
    NSString *price;
    NSString *desc;
    NSString *courseId;
    NSString *type;
    NSString *condition;
    NSString *isbn;
   
    
    if (selectedSegment==0)
    {
        mpName=_txtFieldName.text;
        author=_txtAuthor.text;
        price=_txtFieldPrice.text;
        desc=_txtViewContact.text;
        courseId=@"0";
        type=@"1";
        condition=_txtCondition.text;
        isbn=_txtISBN.text;
        
        
    }
    else if (selectedSegment==1)
    {
        mpName=_txtNameNote.text;
        price=_txtPriceNote.text;
        desc=_txtViewContactNote.text;
        courseId=idCourse;
        type=@"2";
        condition=@"";
        isbn=@"";
        author=@"";
    }
    else if (selectedSegment==2)
    {
        mpName=_txtNameOther.text;
        price=_txtPriceOther.text;
        desc=_txtViewContectOther.text;
        courseId=@"0";
        type=@"3";
        condition=_txtConditionOther.text;
        isbn=@"";
        author=@"";
    }
    NSString * priceFormate = price;
    priceFormate = [priceFormate stringByReplacingOccurrencesOfString:@"$" withString:@""];
    priceFormate = [priceFormate stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
                              _isEditing?[_dictEditMarketPlace objectForKeyNonNull:@"mpId"]:@"0",kMarketPlaceId,
                              mpName,kMpName,
                              author,@"Author",
                              priceFormate,kMpPrice,
                              @"",kMpContactEmail,
                              @"",kMpContactPhone,
                              desc,kMpDesc,
                              courseId?courseId:@"",@"fkcourseId",
                              type,@"type",
                              condition,@"condition",
                              isbn,@"isbn",
                              latitude?latitude:@"0.0000",@"latitude",
                              longitude?longitude:@"0.0000",@"longitude",
                              nil];
    
    [Utils startLoaderWithMessage:@""];
    NSMutableArray * arrayImage = [[NSMutableArray alloc]init];
    
    int a=0;
    for (UIImageView *imgView in _scrollViewImage.subviews)
    {
        if ([imgView isKindOfClass:[UIImageView class]])
        {
            
            if (a<doc.count)
            {
                if ([[[doc objectAtIndex:a] pathExtension] isEqualToString:@"jpg"] || [[[doc objectAtIndex:a] pathExtension] isEqualToString:@"png"] || [[[doc objectAtIndex:a] pathExtension] isEqualToString:@"jpeg"])
                {
                    
                    
                    
                    if (imgView.image.size.width >10)
                    {
                        NSLog(@"wid:%f",imgView.image.size.width);
                        [arrayImage addObject:[imgView.image generatePhoto]];
                    }
                }

            }
            a++;
        }
        
    }
//    if (arrayImage.count>1)
//    {
//        [arrayImage exchangeObjectAtIndex:0 withObjectAtIndex:selectedImage];
//    }
    
        NSMutableArray * arrayDocs = [[NSMutableArray alloc]init];
//    
//    for (UIImageView *imgViewDocs in _scrollViewDocs.subviews)
//    {
//        if(imgViewDocs.image.size.width >10)
//        {
//            NSLog(@"wid:%f",imgViewDocs.image.size.width);
//            [arrayDocs addObject:imgViewDocs.image];
//        }
//    }
    
    for (int i=0; i<doc.count; i++)
    {
        if (!([[[doc objectAtIndex:i] pathExtension] isEqualToString:@"jpg"] || [[[doc objectAtIndex:i] pathExtension] isEqualToString:@"png"] || [[[doc objectAtIndex:i] pathExtension] isEqualToString:@"jpeg"]))
        {
            [arrayDocs addObject:[doc objectAtIndex:i]];
        }
    }
    
    
    [Connection callServiceWithImages:arrayImage Documents:arrayDocs params:dictSend serviceIdentifier:kCreateMarketPlace callBackBlock:^(id response, NSError *error)
     {
         [Utils stopLoader];
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 NSLog(@"Created Market Place");
                 _txtFieldEmailId.text = @" ";
                 _txtFieldMobileNumber.text = @" ";
                 _txtFieldName.text = @" ";
                 _txtFieldPrice.text = @" ";
                 _txtViewContact.text = @" ";
                 _txtISBN.text=@" ";
                 _txtCondition.text=@"";
                 _txtCourse.text=@"";
                 _txtNameNote.text=@"";
                 _txtPriceNote.text=@"";
                 _txtViewContactNote.text=@"";
                 _txtNameOther.text=@"";
                 _txtConditionOther.text=@"";
                 _txtPriceOther.text=@"";
                 _txtViewContectOther.text=@"";
                 
                 for (UIViewController *viewC in self.navigationController.viewControllers)
                 {
                     if ([viewC isKindOfClass:[MarketPlaceViewController class]])
                     {
                         [self.navigationController popToViewController:viewC animated:YES];
                     }
                 }
                 
                 
             }
         }
         
     }];
    
}

#pragma mark - gesture recognizer action

- (void)backSwipeAction
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - textfield


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField==_txtISBN)
    {
        if (![_txtISBN.text isEqualToString:@""])
        {
            [self callAPIBookInfoForISBN];
        }
    }
    return YES;
}


#pragma mark - textview Delegates

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
   
//    [_scrlViewMain setHeight:360];
//    [self.scrlViewMain setContentSize:CGSizeMake(self.scrlViewMain.width, self.viewNoteBooks.yOrigin+self.viewNoteBooks.height+10)];
//    CGRect frame = textView.frame; //wherever you want to scroll
//    [self.scrlViewMain scrollRectToVisible:frame animated:NO];
//    _scrlViewMain.contentSize = CGSizeMake(320, _scrlViewMain.height+200);
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.4];
//    if (textView.frame.origin.y+textView.frame.size.height > _scrlViewMain.frame.size.height-310)
//    {
//        isTextField = YES;
//        [_scrlViewMain setTransform:CGAffineTransformMakeTranslation(0, -(textView.frame.origin.y+textView.frame.size.height - _scrlViewMain.frame.size.height+220))];
//    }
//    [UIView commitAnimations];
    
    if ([textView.text isEqualToString:@"Description    "])
    {
        textView.text = @"";
        [textView setTextColor:[UIColor blackColor]];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
//    [_scrlViewMain setHeight:520];
    isTextField = NO;
    if ([textView.text isEqualToString:@""])
    {
        textView.text = @"Description    ";
        [textView setTextColor:[UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8]];
    }
//    _scrlViewMain.contentSize = CGSizeMake(320, _scrlViewMain.height);
//    [self performSelector:@selector(resignTextFields) withObject:nil afterDelay:0.1];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
    }
    return YES;
}

#pragma mark - UIImagePicker Functions and Delegate

- (void)openPhotoLibrary
{
    _imagePicker = nil;
    _imagePicker = [[UIImagePickerController alloc] init];
    _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _imagePicker.delegate = self;
    
    [self presentViewController:_imagePicker animated:YES completion:NULL];
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
    
    [self presentViewController:_imagePicker animated:YES completion:^{
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:^
     {
         if ([info valueForKey:UIImagePickerControllerReferenceURL])
         {
             ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
             [assetLibrary assetForURL:[info valueForKey:UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
                 ALAssetRepresentation *rep = [asset defaultRepresentation];
                 Byte *buffer = (Byte*)malloc(rep.size);
                 NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
                 NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
                 
                 NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
                 [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                 NSString *imageName=[NSString stringWithFormat:@"%@.png",[dateFormatter stringFromDate:[NSDate date]]];
                 
                 NSString *strPath = [Utils getPathForFolderPath:@"Shared_File" withFileName:imageName];

                 if ([[NSFileManager defaultManager] createFileAtPath:strPath contents:data attributes:nil])
                 {
                     [doc addObject:strPath];
                     
                 }

                 
                 UIImage *image = [UIImage imageWithData:data];
                 
                 if(isImageSelect)
                 {
                     if (selectedSegment==0 || selectedSegment==2)
                     {
                         for (UIView *imgView in _scrollViewImage.subviews)
                         {
                             if ([imgView isKindOfClass:[UIImageView class]])
                             {
                                 [imgView removeFromSuperview];
                             }
                         }
                         _scrollViewImage.contentSize=CGSizeMake(0, 119);
                     }
                     
                     UIImageView *imgViewDocsImage = [[UIImageView alloc] initWithFrame:CGRectMake(_scrollViewImage.contentSize.width, 0, 146, 119)];
                     imgViewDocsImage.image = image;
                     [_scrollViewImage addSubview:imgViewDocsImage];
                     [imgViewDocsImage setContentMode:UIViewContentModeScaleAspectFill];
                     [imgViewDocsImage setClipsToBounds:YES];
                     [_scrollViewImage setContentSize:CGSizeMake(_scrollViewImage.contentSize.width+146, 119)];
                     
                         UIButton *close=[[UIButton alloc] initWithFrame:CGRectMake(_scrollViewImage.contentSize.width-25, 5, 20, 20)];
                         [close setImage:[UIImage imageNamed:@"cancelBtnWorkoutPartners.png"] forState:UIControlStateNormal];
                         [close addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
                         close.tag=_scrollViewImage.contentSize.width/146;
                         [_scrollViewImage addSubview:close];
                     
                     _scrollViewImage.contentOffset=CGPointMake(_scrollViewImage.contentSize.width-146,0);
                     [_pageControlImages setNumberOfPages:_scrollViewImage.contentSize.width/146];
                     [_pageControlImages setCurrentPage:_scrollViewImage.contentOffset.x/146];
                     if (selectedSegment==1)
                     {
                         if (doc.count!=0)
                         {
                             _btnMoreUpload.hidden=NO;
                         }
                     }
                     
                     
                 }
                 else
                 {
                     for (UIView *imgView in _scrollViewDocs.subviews)// so that it contains only one image at a time
                     {
                         if ([imgView isKindOfClass:[UIImageView class]])
                         {
                             [imgView removeFromSuperview];
                         }
                     }
                     UIImageView *imgPostImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 146, 119)];
                     imgPostImage.image = image;
                     [_scrollViewDocs addSubview:imgPostImage];
                     
                     [imgPostImage setContentMode:UIViewContentModeScaleAspectFill];
                     [imgPostImage setClipsToBounds:YES];
                     [_scrollViewDocs setContentSize:CGSizeMake(146, 119)];
                 }
                 
                 
             } failureBlock:^(NSError *err) {
                 NSLog(@"Error: %@",[err localizedDescription]);
             }];
         }
         else
         {
             UIImage *image = (UIImage*)[info objectForKeyNonNull:UIImagePickerControllerOriginalImage];
             NSData *data= UIImagePNGRepresentation(image);
             NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
             [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
             NSString *imageName=[NSString stringWithFormat:@"%@.png",[dateFormatter stringFromDate:[NSDate date]]];
             
             NSString *strPath = [Utils getPathForFolderPath:@"Shared_File" withFileName:imageName];
             
             if ([[NSFileManager defaultManager] createFileAtPath:strPath contents:data attributes:nil])
             {
                 [doc addObject:strPath];
                 
             }

             
             if(isImageSelect)
             {
                 
                 if (selectedSegment==0 || selectedSegment==2)
                 {
                     for (UIView *imgView in _scrollViewImage.subviews)
                     {
                         if ([imgView isKindOfClass:[UIImageView class]])
                         {
                             [imgView removeFromSuperview];
                         }
                     }
                     _scrollViewImage.contentSize=CGSizeMake(0, 119);
                 }
                 
                 UIImageView *imgViewDocsImage = [[UIImageView alloc] initWithFrame:CGRectMake(_scrollViewImage.contentSize.width, 0, 146, 119)];
                 imgViewDocsImage.image = image;
                 [_scrollViewImage addSubview:imgViewDocsImage];
                 [imgViewDocsImage setContentMode:UIViewContentModeScaleAspectFill];
                 [imgViewDocsImage setClipsToBounds:YES];
                 [_scrollViewImage setContentSize:CGSizeMake(_scrollViewImage.contentSize.width+146, 119)];
                 
                 UIButton *close=[[UIButton alloc] initWithFrame:CGRectMake(_scrollViewImage.contentSize.width-25, 5, 20, 20)];
                 [close setImage:[UIImage imageNamed:@"cancelBtnWorkoutPartners.png"] forState:UIControlStateNormal];
                 [close addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
                 close.tag=_scrollViewImage.contentSize.width/146;
                 [_scrollViewImage addSubview:close];
                 
                 _scrollViewImage.contentOffset=CGPointMake(_scrollViewImage.contentSize.width-146,0);
                 [_pageControlImages setNumberOfPages:_scrollViewImage.contentSize.width/146];
                 [_pageControlImages setCurrentPage:_scrollViewImage.contentOffset.x/146];
                 if (selectedSegment==1)
                 {
                     if (doc.count!=0)
                     {
                         _btnMoreUpload.hidden=NO;
                     }
                 }
                 
                 
             }
             else
             {
                 for (UIView *imgView in _scrollViewDocs.subviews)
                 {
                     if ([imgView isKindOfClass:[UIImageView class]])
                     {
                         [imgView removeFromSuperview];
                     }
                 }
                 UIImage *image = (UIImage*)[info objectForKeyNonNull:UIImagePickerControllerOriginalImage];
                 //_imgPostImage.image = image;
                 UIImageView *imgViewMarketPlaceImageDocs = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 146, 119)];
                 imgViewMarketPlaceImageDocs.image = image;
                 [_scrollViewDocs addSubview:imgViewMarketPlaceImageDocs];
                 [imgViewMarketPlaceImageDocs setContentMode:UIViewContentModeScaleAspectFill];
                 [_scrollViewDocs setContentSize:CGSizeMake(146, 119)];
                 
             }
             
         }
     }];
}
-(IBAction)deleteImage:(id)sender
{
    NSInteger tg=0;
    BOOL dlt=false;
    for (UIView *imgView in _scrollViewImage.subviews)
    {
        if ([imgView isKindOfClass:[UIImageView class]])
        {
            tg++;
            if (tg==[sender tag])
            {
                
                [imgView removeFromSuperview];
                [sender removeFromSuperview];
                dlt=true;
                [doc removeObjectAtIndex:tg-1];
                
            }
            if (dlt)
            {
                
                imgView.xOrigin=imgView.xOrigin-146;
                UIButton *btnClose = (UIButton *)[_scrollViewImage viewWithTag:tg];
                btnClose.xOrigin=btnClose.xOrigin-146;
                btnClose.tag=btnClose.tag-1;
                
                
            }

        }
    }
    _scrollViewImage.contentSize=CGSizeMake(_scrollViewImage.contentSize.width-146, 119);
    _scrollViewImage.contentOffset=CGPointMake(_scrollViewImage.contentSize.width-146,0);
    [_pageControlImages setNumberOfPages:_scrollViewImage.contentSize.width/146];
    [_pageControlImages setCurrentPage:_scrollViewImage.contentOffset.x/146];
    
    if (doc.count==0)
    {
        _btnMoreUpload.hidden=true;
        _scrollViewImage.backgroundColor=[UIColor clearColor];

    }


}
#pragma mark - action sheet

- (IBAction)openActionSheet:(id)sender
{
    [self.view endEditing:YES];
    isImageSelect = YES;
    
    NSArray *buttonArray;
    if (selectedSegment==0 || selectedSegment==2)
    {
        buttonArray=[[NSArray alloc] initWithObjects:@"Camera",@"Photo Library", nil];
    }
    else if (selectedSegment==1)
    {
        buttonArray=[[NSArray alloc] initWithObjects:@"Camera",@"Photo Library",@"Google Drive",@"Dropbox", nil];
    }
    
    [[Utils sharedInstance] showActionSheetWithTitle:@"" buttonArray:buttonArray     selectedButton:^(NSInteger selected)
     {
         DLog(@"Selected Action sheet button = %ld",(long)selected);
         if (selectedSegment==0 || selectedSegment==2)
         {
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
                     break;
                     
                 default:
                     break;
             }

         }
         else if (selectedSegment==1)
         {
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
                 case 2:
                 {
                     GoogleDriveViewController *vcGoogleDrive = [[GoogleDriveViewController alloc] initWithNibName:@"GoogleDriveViewController" bundle:nil];
                     vcGoogleDrive.isCreateAds=YES;
                     navController=[[UINavigationController alloc] initWithRootViewController:vcGoogleDrive];
                     navController.navigationBarHidden=YES;
                     [self presentViewController:navController animated:YES completion:nil];
                     
                     
                 }
                     break;
                     
                 case 3:
                 {
                     DropBoxViewController *vcDropBox = [[DropBoxViewController alloc] initWithNibName:@"DropBoxViewController" bundle:nil];
                     vcDropBox.isCreateAds=YES;
                     navController=[[UINavigationController alloc] initWithRootViewController:vcDropBox];
                     navController.navigationBarHidden=YES;
                     [self presentViewController:navController animated:YES completion:nil];
                     
                 }
                     break;
                     
                 default:
                     break;
             }
        }

        
         
     }];
}

#pragma mark - button action

- (IBAction)btnPostTapped:(id)sender
{
    if ([self isValid])
    {
        [self callAPICreateMarketPlace];
    }
    else
    {
        [Utils showAlertViewWithMessage:msgString];
    }
    
}

- (void)btnAddImageTapped:(UITapGestureRecognizer *)sender
{
    if (doc.count!=0)
    {
        
        QLPreviewController *previewController = [[QLPreviewController alloc] init];
        
        previewController.dataSource = self;
        previewController.delegate = self;

        [self presentViewController:previewController animated:YES completion:nil];

        
    }
    else
    {
        [self openActionSheet:sender];
        
    }
    
   
}
- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return 1;
}
- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return [NSURL fileURLWithPath:[doc objectAtIndex:selectedImage]];
}

- (IBAction)btnBackTapped:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)btnDocsTapped:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
    isImageSelect = NO;
   
}

- (IBAction)startStopReading:(id)sender
{
    [self presentViewController:scanner animated:YES completion:nil];
}

-(int)getLength:(NSString*)mobileNumber
{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    int length = [mobileNumber length];
    
    return length;
    
    
}

@end
