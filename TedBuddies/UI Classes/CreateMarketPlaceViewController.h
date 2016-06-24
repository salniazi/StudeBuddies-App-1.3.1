//
//  CreateMarketPlaceViewController.h
//  TedBuddies
//
//  Created by Sunil on 29/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CMTime.h>
#import "MPGTextField.h"

@interface CreateMarketPlaceViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate,MPGTextFieldDelegate>
{
    BOOL isTextField;
    NSString * msgString;
    BOOL isImageSelect;
    BOOL isMatched;
    
}


@property (strong, nonatomic) IBOutlet UIScrollView *scrlViewMain;
@property (weak, nonatomic) IBOutlet UIView *viewNoteBooks;
@property (weak, nonatomic) IBOutlet UIView *viewNotes;
@property (weak, nonatomic) IBOutlet UIView *viewOthers;



@property (weak, nonatomic) IBOutlet UIButton *btnDocs;
@property (nonatomic) BOOL isEditing;
@property (weak, nonatomic) IBOutlet UIButton *btnAddImage;

@property (weak, nonatomic) IBOutlet UITextField *txtISBN;
@property (weak, nonatomic) IBOutlet MPGTextField *txtCondition;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldName;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldPrice;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldEmailId;
@property (weak, nonatomic) IBOutlet UITextView *txtViewContact;
@property (weak, nonatomic) IBOutlet UITextField *txtAuthor;

@property (weak, nonatomic) IBOutlet MPGTextField *txtCourse;
@property (weak, nonatomic) IBOutlet UITextField *txtNameNote;
@property (weak, nonatomic) IBOutlet UITextField *txtPriceNote;
@property (weak, nonatomic) IBOutlet UITextView *txtViewContactNote;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControlImages;


@property (weak, nonatomic) IBOutlet UITextField *txtNameOther;
@property (weak, nonatomic) IBOutlet MPGTextField *txtConditionOther;
@property (weak, nonatomic) IBOutlet UITextField *txtPriceOther;
@property (weak, nonatomic) IBOutlet UITextView *txtViewContectOther;

@property (weak, nonatomic) IBOutlet UIButton *btnMoreUpload;




@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldMobileNumber;
@property (strong, nonatomic) IBOutlet UILabel *lblNavBar;
@property (weak, nonatomic) IBOutlet UIImageView *imgPostImage;
@property (weak, nonatomic) IBOutlet UILabel *lblAddImage;
@property (strong,nonatomic) NSDictionary * dictEditMarketPlace;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewDocs;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewImage;
@property (weak, nonatomic) IBOutlet UIImageView *imgDocs;
@property (weak, nonatomic) IBOutlet UIImageView *imgIconImage1;
@property (weak, nonatomic) IBOutlet UIImageView *imgIconImage2;
@property (weak, nonatomic) IBOutlet UILabel *lblDocs;
@property (weak, nonatomic) IBOutlet UIView *viewSegment;

- (IBAction)btnPostTapped:(id)sender;
- (IBAction)btnAddImageTapped:(UIButton *)sender;
- (IBAction)btnBackTapped:(UIButton *)sender;
- (IBAction)btnDocsTapped:(id)sender;
- (IBAction)startStopReading:(id)sender;

@end
