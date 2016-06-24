//
//  ChatScreenViewController.h
//  TedBuddies
//
//  Created by Mayank Pahuja on 18/09/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALAssetsLibrary+CustomPhotoAlbum.h"
#import "EAMTextView.h"


@interface ChatScreenViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPopoverControllerDelegate,UIGestureRecognizerDelegate,EAMTextViewDelegate>
{
    BOOL isTextField;
    BOOL isServiceLoaded;
    NSMutableArray *arrChatHistory;
    NSDateFormatter *newFormatter;
    bool isLeft;
    bool isMute;
    
    
}
@property (strong, nonatomic) IBOutlet UIImageView *imgViewTextFieldBG;
@property (weak, nonatomic) IBOutlet EAMTextView *txtFieldUserInput;
@property (strong, nonatomic) IBOutlet UIButton *btnAddImage;
@property (strong, nonatomic) IBOutlet UIButton *btnSend;
@property (strong, nonatomic) IBOutlet UILabel *lblNavBar;
@property (strong, nonatomic) IBOutlet UITableView *tblChat;
@property (strong, nonatomic) IBOutlet UIView *viewChatBar;
@property (strong, nonatomic) NSDictionary *dictBuddyInfo;
@property (strong, nonatomic) IBOutlet UIButton *btnAttachmnt;
@property (assign, nonatomic) BOOL isGroup;
@property (assign, nonatomic) BOOL isClass;
@property (weak, nonatomic) IBOutlet UIView *lblHideChat;
@property (weak, nonatomic) IBOutlet UIButton *btnDetails;
@property (weak, nonatomic) IBOutlet UILabel *lblLeftDate;

@property (strong, nonatomic) UIImagePickerController *imagePicker;

@property (weak, nonatomic) IBOutlet UIView *navigationView;
@property (weak, nonatomic) IBOutlet UIView *deleteView;
@property (weak, nonatomic) IBOutlet UILabel *lblCountDelete;


- (IBAction)btnBackTapped:(UIButton *)sender;
- (IBAction)btnAddImageTapped:(UIButton *)sender;
- (IBAction)btnSendTapped:(UIButton *)sender;
- (IBAction)btnAttachmentTapped:(UIButton *)sender;
- (IBAction)btnGIFTapped:(id)sender;
- (IBAction)btnChatNameTapped:(id)sender;
- (IBAction)btnCancelDeleteTapped:(id)sender;
- (IBAction)btnDeleteMessageTapped:(id)sender;


@end
