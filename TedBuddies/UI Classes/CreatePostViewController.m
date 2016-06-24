//
//  CreatePostViewController.m
//  TedBuddies
//
//  Created by Sunil on 29/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import "CreatePostViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PHTextView.h"
#import "UIImage+Utility.h"

@interface CreatePostViewController ()
@property (nonatomic , strong) UIImage *selectedImage;
@end

@implementation CreatePostViewController

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
    _classId = [NSString stringWithFormat:@"0"];
    [self setFont];
    [self editPostBlog];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     //[self.tabBarController.tabBar setHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   // [self.tabBarController.tabBar setHidden:NO];
//    _classId = @"0";
}

#pragma  mark - other Method

-(void) setFont
{
    _lblAddImage.hidden = _isAlive;
    
    [_lblNavBar setFont:FONT_REGULAR(kNavigationFontSize)];
    _classId = [NSString stringWithFormat:@"0"];
    
    UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backSwipeAction)];
    [backSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    
    //NSAttributedString *strHeading = [[NSAttributedString alloc] initWithString:@"#" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
    
    [_txtFieldHeading setFont:FONT_REGULAR(14)];
    //[_txtFieldHeading setAttributedPlaceholder:strHeading];
    
  //NSAttributedString *strTitle = [[NSAttributedString alloc] initWithString:@"Title" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
    NSAttributedString *strTitle = [[NSAttributedString alloc] initWithString:@"Course" attributes:@{ NSForegroundColorAttributeName : [UIColor blackColor] }];
    [_txtFieldClass setFont:FONT_REGULAR(14)];
    [_txtFieldClass setAttributedPlaceholder:strTitle];
    [_txtFieldClass setTextColor:[UIColor blackColor]];
    
    [_txtViewDescription setTextColor:[UIColor blackColor]];
    [_txtViewDescription setText:@"Yap on..."];
    
   // NSAttributedString *strClass = [[NSAttributedString alloc] initWithString:@"Title" attributes:@{ NSForegroundColorAttributeName : [UIColor colorWithRed:15.0/255.0  green:117.0/255.0 blue:189.0/255.0 alpha:0.8] }];
    
    
    NSAttributedString *strClass = [[NSAttributedString alloc] initWithString:@"Course" attributes:@{ NSForegroundColorAttributeName : [UIColor blackColor]}];
    
    [_txtFieldClass setTextColor:[UIColor blackColor]];
    [_txtFieldClass setAttributedPlaceholder:strClass];
    
    [_tableView.layer setBorderColor:[UIColor grayColor].CGColor];
    [_tableView.layer setBorderWidth:0.5];
    
    [self.view addGestureRecognizer:backSwipe];
}

-(void) editPostBlog
{
    if(_isAlive)
    {
        BOOL isBlog = [[_dictEditPostBlob objectForKey:@"isBlog"]boolValue];
        
        if(isBlog == YES )
        {
            [_btnBlog setSelected:YES];
            [_btnPost setSelected:NO];
            [_viewClassList setHidden:NO];

            _txtFieldClass.text = [_dictEditPostBlob objectForKeyNonNull:@"className"];
            [ _txtFieldClass setTextColor:[UIColor blackColor]];
            
            
            NSString *strHeading  = [_dictEditPostBlob objectForKeyNonNull:@"postHeading"];
             strHeading = [strHeading stringByReplacingOccurrencesOfString:@"#" withString:@""];
            
            _txtFieldHeading.text = strHeading;//[_dictEditPostBlob objectForKeyNonNull:@"postHeading"];
            
            _txtViewDescription.text = [_dictEditPostBlob objectForKeyNonNull:@"postDesc"];
            [ _txtViewDescription setTextColor:[UIColor blackColor]];
            _classId = [_dictEditPostBlob objectForKeyNonNull:@"classId"];
            if (![[_dictEditPostBlob objectForKeyNonNull:@"postImage"] isEqualToString:@""])
            {
                NSString *imgname=[NSString stringWithFormat:@"%@",[_dictEditPostBlob objectForKeyNonNull:@"postImage"]];
                [_imgPostImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImageURl,imgname]]placeholderImage:[UIImage imageNamed:@"default_post@2x.png"]];

            }
            
        }
        else
        {
            NSString *strHeading  = [_dictEditPostBlob objectForKeyNonNull:@"postHeading"];
            strHeading = [strHeading stringByReplacingOccurrencesOfString:@"#" withString:@""];
            _txtFieldHeading.text = strHeading;//[_dictEditPostBlob objectForKeyNonNull:@"postHeading"];
            
            _txtViewDescription.text = [_dictEditPostBlob objectForKeyNonNull:@"postDesc"];
            
            [ _txtViewDescription setTextColor:[UIColor blackColor]];
            if (![[_dictEditPostBlob objectForKeyNonNull:@"postImage"] isEqualToString:@""])
            {
                NSString *imgname=[NSString stringWithFormat:@"%@",[_dictEditPostBlob objectForKeyNonNull:@"postImage"]];
                [_imgPostImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImageURl,imgname]]placeholderImage:[UIImage imageNamed:@"default_post@2x.png"]];
                
            }

        }
    }
}

#pragma  mark - WebServises

-(void) callAPICreateBlog
{
    
    NSMutableDictionary *dictSend = [[NSMutableDictionary alloc] init];
    [dictSend setObject:[defaults objectForKey:kUserId] forKey:kUserId];
    [dictSend setObject:_isAlive?[_dictEditPostBlob objectForKey:@"postId"]:@"" forKey:kPostId];
    [dictSend setObject:_classId forKey:kClassId];
    [dictSend setObject:_txtFieldHeading.text forKey:kPostHeading];
    [dictSend setObject:[_txtViewDescription.text isEqualToString:@"Yap on..."]?@"":_txtViewDescription.text forKey:kPostDescription];
    [dictSend setObject:[_btnBlog isSelected]?@"True":@"False" forKey:kIsBlog];
    
    [Utils startLoaderWithMessage:@""];
    
    NSMutableArray * arrayImage = [[NSMutableArray alloc]init];
    if (_imgPostImage.image)
    {
        [arrayImage addObject:[_imgPostImage.image generatePhoto]];
    }
    
    [Connection callServiceWithImages:arrayImage params:dictSend serviceIdentifier:kCreateBlog callBackBlock:^(id response, NSError *error)
     {
         [Utils stopLoader];
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 SharedAppDelegate.isCreateYap=true;
                 [self.navigationController popViewControllerAnimated:YES];
             }
         }
         
     }];
}

- (void)callAPIGetScheduledClassList
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
                              nil];
    
    [Connection callServiceWithName:kGetScheduledClassList postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 arrClassTitle = nil;
                 arrClassTitle = [[NSArray alloc] initWithArray:[response objectForKeyNonNull:kResult]];
                 [_tableView reloadData];
                 [_tableView setHidden:NO];
             }
         }
     }
     ];
}

- (BOOL)isValid
{
    if ([_btnBlog isSelected])
    {
        if ([_txtFieldClass.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
        {
            msgString = @"Don't forget to enter Class Title";
            return NO;
        }
//        if ([_txtFieldHeading.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
//        {
//            msgString = @"Don't forget to enter a #Tag";
//            return NO;
//        }
        
    }
//    else
//    {
//        if ([_txtFieldHeading.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0)
//        {
//            msgString = @"Don't forget to enter a #Tag";
//            return NO;
//        }
//        
//    }
//    if ([_txtViewDescription.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0|| [_txtViewDescription.text isEqualToString:@"Yap on..."])
//    {
//        msgString = @"Don't forget to Enter a Yap on...";
//        return NO;
//    }
    
    return YES;
}

#pragma mark - gesture recognizer

- (void)backSwipeAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - action sheet

- (void)openActionSheet
{
    [[Utils sharedInstance] showActionSheetWithTitle:@"" buttonArray:@[@"Camera",@"Photo Library"]     selectedButton:^(NSInteger selected)
     {
         DLog(@"Selected Action sheet button = %ld",(long)selected);
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
         
     }];
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
    
    [self presentViewController:_imagePicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    _selectedImage = (UIImage*)[info objectForKeyNonNull:UIImagePickerControllerOriginalImage];

    if ([info valueForKey:UIImagePickerControllerReferenceURL])
    {
        ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
        [assetLibrary assetForURL:[info valueForKey:UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            Byte *buffer = (Byte*)malloc(rep.size);
            NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
            NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];//this is NSData may be what you want
            UIImage *image = [UIImage imageWithData:data];
            
            _imgPostImage.image = image;
             _lblAddImage.hidden = YES;
            ;//you can save image later
        } failureBlock:^(NSError *err)
         {
            NSLog(@"Error: %@",[err localizedDescription]);
        }];
    }
    else
    {
        _imgPostImage.image = _selectedImage;
    }
    if(_selectedImage != nil){
        
        RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:_selectedImage];
        imageCropVC.delegate = self;
        [self.tabBarController.tabBar setHidden:YES];
        [self.navigationController pushViewController:imageCropVC animated:NO];
        
        
//        ImageCropViewController *controller = [[ImageCropViewController alloc] initWithImage:_selectedImage];
//        self.navigationController.navigationBarHidden = NO;
//        
//        //[self.tabBarController.tabBar setHidden:YES];
//        //self.navigationController
//        controller.delegate = self;
//        controller.blurredBackground = YES;
//        //[self presentViewController:controller animated:YES completion:NULL];
//        [self.navigationController pushViewController:controller animated:NO];
    }
}
- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
    [self.tabBarController.tabBar setHidden:NO];

}

// The original image has been cropped.
- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect
{
    _selectedImage = croppedImage;
    _imgPostImage.image = croppedImage;
    [self.tabBarController.tabBar setHidden:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)ImageCropViewController:(ImageCropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage{
    _selectedImage = croppedImage;
    _imgPostImage.image = croppedImage;
    self.navigationController.navigationBarHidden = YES;

    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)ImageCropViewControllerDidCancel:(ImageCropViewController *)controller{
    _imgPostImage.image = _selectedImage;
    self.navigationController.navigationBarHidden = YES;

    [[self navigationController] popViewControllerAnimated:YES];
    
}

- (void)thisImage:(UIImage *)image hasBeenSavedInPhotoAlbumWithError:(NSError *)error usingContextInfo:(void*)ctxInfo {
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Fail!"
                                                        message:[NSString stringWithFormat:@"Saved with error %@", error.description]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Succes!"
                                                        message:@"Saved to camera roll"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
}

- (IBAction)saveBarButtonClick:(id)sender {
    if (_selectedImage != nil){
        UIImageWriteToSavedPhotosAlbum(_selectedImage, self ,  @selector(thisImage:hasBeenSavedInPhotoAlbumWithError:usingContextInfo:), nil);
    }
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrClassTitle count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [[arrClassTitle objectAtIndex:indexPath.row] objectForKeyNonNull:kClassName];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView setHidden:YES];
    [_btnSetTitle setSelected:NO];
    _txtFieldClass.text = [[arrClassTitle objectAtIndex:indexPath.row] objectForKeyNonNull:@"className"];
    _txtFieldClass.textColor = [UIColor blackColor];
    _classId = [[arrClassTitle objectAtIndex:indexPath.row] objectForKeyNonNull:@"classId"];
}

#pragma mark - textfield

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [_scrlViewMain setHeight:360];
    [_scrlViewMain setContentSize:CGSizeMake(320, 520)];
    CGRect frame = textField.frame; //wherever you want to scroll
    [self.scrlViewMain scrollRectToVisible:frame animated:NO];
//    [_scrlViewMain setContentSize:CGSizeMake(320, _scrlViewMain.height+150)];
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.4];
//    if (textField.frame.origin.y+textField.frame.size.height > _scrlViewMain.frame.size.height-310)
//    {
//        isTextField = YES;
//        [_scrlViewMain setTransform:CGAffineTransformMakeTranslation(0, -(textField.frame.origin.y+textField.frame.size.height - _scrlViewMain.frame.size.height+310))];
//    }
//    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [_scrlViewMain setHeight:520];
//    [_scrlViewMain setContentSize:CGSizeMake(320, _scrlViewMain.height)];
//    isTextField = NO;
//    [self performSelector:@selector(resignTextFields) withObject:nil afterDelay:0.1];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)resignTextFields
{
    if (!isTextField)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.4];
        
        [_scrlViewMain setTransform:CGAffineTransformIdentity];
        [UIView commitAnimations];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@" "]){
        return NO;
    }
    else {
        return YES;
    }
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
    [_scrlViewMain setHeight:360];
    [_scrlViewMain setContentSize:CGSizeMake(320, 520)];
    CGRect frame = textView.frame; //wherever you want to scroll
    [self.scrlViewMain scrollRectToVisible:frame animated:NO];
//    [_scrlViewMain setContentSize:CGSizeMake(320, _scrlViewMain.height+150)];
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.4];
//    if (textView.frame.origin.y+textView.frame.size.height > _scrlViewMain.frame.size.height-310)
//    {
//        isTextField = YES;
//        [_scrlViewMain setTransform:CGAffineTransformMakeTranslation(0, -(textView.frame.origin.y+textView.frame.size.height - _scrlViewMain.frame.size.height+310))];
//    }
//    [UIView commitAnimations];
    
    if ([textView.text isEqualToString:@"Yap on..."])
    {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [_scrlViewMain setHeight:520];
//    [_scrlViewMain setContentSize:CGSizeMake(320, _scrlViewMain.height)];
//    isTextField = NO;
    if ([textView.text isEqualToString:@""])
    {
        textView.text = @"Yap on...";
        textView.textColor = [UIColor blackColor];
    }
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

#pragma mark - Button Action

- (IBAction)btnBlogTapped:(id)sender
{
    [_btnBlog setSelected:YES];
    [_btnPost setSelected:NO];
    [_viewClassList setHidden:NO];
}

- (IBAction)btnPostTapped:(UIButton *)sender
{
    _classId = @"0";
    [_viewClassList setHidden:YES];
    [_tableView setHidden:YES];
    [_btnBlog setSelected:NO];
    [_btnPost setSelected:YES];
    
}

- (IBAction)btnPostDataTapped:(UIButton *)sender
{
    [self.view endEditing:YES];
    if ([self isValid])
    {
        [self callAPICreateBlog];
    }
    else
    {
        [Utils showAlertViewWithMessage:msgString];
    }
}

- (IBAction)btnScheduleClassesTapped:(UIButton *)sender
{
    [self.view endEditing:YES];
    if ([sender isSelected])
    {
        [_tableView setHidden:YES];
        [sender setSelected:NO];
    }
    else
    {
        [sender setSelected:YES];
        [self callAPIGetScheduledClassList];
    }
    
}

- (IBAction)btnAddImageTapped:(UIButton *)sender
{
    [self.view endEditing:YES];

    [self performSelector:@selector(openActionSheet) withObject:nil afterDelay:0.2];
}

- (IBAction)btnBackTapped:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
