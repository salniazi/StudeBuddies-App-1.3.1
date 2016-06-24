//
//  DropBoxViewController.m
//  TedBuddies
//
//  Created by Mac on 30/03/16.
//  Copyright © 2016 Mayank Pahuja. All rights reserved.
//

#import "DropBoxViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "NSDictionary+dictionaryWithObject.h"
#import "DropBoxTableViewCell.h"
#import "UIImage+animatedGIF.h"



@interface DropBoxViewController ()<DBRestClientDelegate,UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *fileDetails;
    NSMutableArray *folder;
    NSMutableArray *arryData;
    NSString *path;
    NSMutableArray *arryTitle;
    NSInteger countSelect;
    NSInteger count;
   
}
@property (nonatomic, strong) DBRestClient *restClient;

@end

@implementation DropBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    path=@"/";
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }
    folder=[[NSMutableArray alloc]init];
    fileDetails=[[NSMutableArray alloc] init];
    arryData=[[NSMutableArray alloc]init];
    arryTitle=[[NSMutableArray alloc]init];
    _tblView.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
    
    count=0;
    countSelect=0;
    
    SharedAppDelegate.responce=[[NSMutableArray alloc] init];
    SharedAppDelegate.cmResponce=[[NSMutableArray alloc] init];
    
    
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    
    if ([[DBSession sharedSession] isLinked])
    {
     
        self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        self.restClient.delegate = self;
        _btnSignOut.alpha=1.0;
        _tblView.alpha=1.0;
        _btnLink.alpha=0.0;
        _lblNote.alpha=0.0;
        [self startLoaderWithMessage:@""];
        [self.restClient loadMetadata:path];

        
    }
    
}
- (void) configureButton:(MIBadgeButton *) button withBadge:(NSString *) badgeString {
    //[button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    // optional to change the default position of the badge
    [button setBadgeEdgeInsets:UIEdgeInsetsMake(8, 5, 0, 8)];
    button.badgeBackgroundColor = [UIColor redColor];
    [button setBadgeString:badgeString];
}
#pragma mark - Dropbox
- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    
    [folder removeAllObjects];
    [fileDetails removeAllObjects];
    [arryData removeAllObjects];
   
        for (DBMetadata *file in metadata.contents)
        {
            if (file.isDirectory)
            {
               NSDictionary *dictFolder = [NSDictionary dictionaryWithPropertiesOfObject:file];
                NSMutableDictionary *dictFolder1=[[NSMutableDictionary alloc] initWithDictionary:dictFolder];
                [dictFolder1 setValue:@"0" forKey:@"isChecked"];
                [folder addObject:dictFolder1];
                
            }
            else
            {
               NSDictionary *dictFileDetails = [NSDictionary dictionaryWithPropertiesOfObject:file];
                NSMutableDictionary *dictFileDetails1=[[NSMutableDictionary alloc] initWithDictionary:dictFileDetails];
                [dictFileDetails1 setValue:@"0" forKey:@"isChecked"];
                [fileDetails addObject:dictFileDetails1];
            }
        }
    
    for (int i=0; i<folder.count; i++)
    {
        [arryData addObject:[folder objectAtIndex:i]];
    }
    for (int i=0; i<fileDetails.count; i++)
    {
        [arryData addObject:[fileDetails objectAtIndex:i]];
    }
    [self stopLoader];
    _tblView.delegate=self;
    _tblView.dataSource=self;
    [_tblView reloadData];
    [_btnCancelAndImport setTitle:@"Cancel" forState:UIControlStateNormal];
    [self configureButton:_btnCancelAndImport withBadge:nil];
    if ([path isEqualToString:@"/"])
    {
        [_btnSignOut setTitle:@"Sign Out" forState:UIControlStateNormal];
        _lblNavTitle.text=@"DropBox";
        
    }
    else
    {
        [_btnSignOut setTitle:@" Back " forState:UIControlStateNormal];
        _lblNavTitle.text=[arryTitle lastObject];
    }
    
   
    NSLog(@"%@",arryData);
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error
{
    NSLog(@"Error loading metadata: %@", error);
     [self stopLoader];
    [self showAlert:@"Error" message:error.localizedDescription];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (arryData.count==0)
    {
        return 1;
    }
    return arryData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    DropBoxTableViewCell *cell = (DropBoxTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    if (cell == nil)
    {
        cell = (DropBoxTableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"DropBoxTableViewCell" owner:self options:nil] objectAtIndex:0];
        
    }
    
    if (arryData.count==0)
    {
        cell.lblName.text=@"File and Folder not found..!";
        [cell.lblName setTranslatesAutoresizingMaskIntoConstraints:YES];
        [cell.lblName setFrame:CGRectMake(cell.lblName.xOrigin, 13, cell.lblName.width, cell.lblName.height)];
        
        cell.imgFile.alpha=0.0;
        cell.lblAttribute.alpha=0.0;
        cell.imgSelect.alpha=0.0;
        
        return cell;
    }
    
    cell.lblName.text=[[arryData objectAtIndex:indexPath.row] valueForKey:@"filename"];
    cell.imgFile.image = [UIImage imageNamed:[[arryData objectAtIndex:indexPath.row] valueForKey:@"icon"]];
    
    // Setup Last Modified Date
    NSLocale *locale = [NSLocale currentLocale];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"E MMM d yyyy" options:0 locale:locale];
    [formatter setDateFormat:dateFormat];
    [formatter setLocale:locale];
    
    // Get File Details and Display
    if ([[[arryData objectAtIndex:indexPath.row] valueForKey:@"isDirectory"]boolValue]) {
        // Folder
        [cell.lblName setTranslatesAutoresizingMaskIntoConstraints:YES];
        [cell.lblName setFrame:CGRectMake(cell.lblName.xOrigin, 13, cell.lblName.width, cell.lblName.height)];
             } else {
        // File
        cell.lblAttribute.text = [NSString stringWithFormat:NSLocalizedString(@"%@, modified %@", @"DropboxBrowser: File detail label with the file size and modified date."),[[arryData objectAtIndex:indexPath.row] valueForKey:@"humanReadableSize"], [formatter stringFromDate:[[arryData objectAtIndex:indexPath.row] valueForKey:@"lastModifiedDate"]]];
        
    }

    
    if ([[[arryData objectAtIndex:indexPath.row] valueForKey:@"isDirectory"]boolValue])
    {
        cell.imgSelect.alpha=0.0;
    }
    else
    {
        if ([[[arryData objectAtIndex:indexPath.row] valueForKey:@"isChecked"]isEqualToString:@"1"])
        {
            [cell.imgSelect setImage:[UIImage imageNamed:@"Check"]];
            
            
        }
        else
        {
            [cell.imgSelect setImage:[UIImage imageNamed:@"UnCkeck"]];
        }

    }
    



        return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (arryData.count!=0)
    {
        if ([[[arryData objectAtIndex:indexPath.row] valueForKey:@"isDirectory"]boolValue])
        {
            path=[NSString stringWithFormat:@"%@%@/",path,[[arryData objectAtIndex:indexPath.row] valueForKey:@"filename"]];
            [arryTitle addObject:[[arryData objectAtIndex:indexPath.row] valueForKey:@"filename"]];
            [self startLoaderWithMessage:@""];
            [self.restClient loadMetadata:path];
        }
        else
        {
            DropBoxTableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
            
            if ([[[arryData objectAtIndex:indexPath.row] valueForKey:@"isChecked"]boolValue])
            {
                [[arryData objectAtIndex:indexPath.row] setValue:@"0" forKey:@"isChecked"];
                [cell.imgSelect setImage:[UIImage imageNamed:@"UnCkeck"]];
                
                
                
            }
            else
            {
                [[arryData objectAtIndex:indexPath.row] setValue:@"1" forKey:@"isChecked"];
                [cell.imgSelect setImage:[UIImage imageNamed:@"Check"]];
                
                
                
                
                
                
            }
            countSelect=0;

            BOOL flag=false;
           
            for (int i=0; i<arryData.count; i++)
            {
                
                if ([[[arryData objectAtIndex:i] valueForKey:@"isChecked"]isEqualToString:@"1"])
                {
                    countSelect=countSelect+1;
                    flag=true;
                    
                }
            }
            if (!flag)
            {
                [_btnCancelAndImport setTitle:@"Cancel" forState:UIControlStateNormal];
                [self configureButton:_btnCancelAndImport withBadge:nil];
            }
            else
            {
                if (_isCreateAds)
                {
                    [_btnCancelAndImport setTitle:@"Upload" forState:UIControlStateNormal];
                }
                else
                {
                    [_btnCancelAndImport setTitle:@"Send" forState:UIControlStateNormal];
                }
               
                [self configureButton:_btnCancelAndImport withBadge:[NSString stringWithFormat:@"%ld",(long)countSelect]];
            }
            
        }
        [_tblView reloadData];

    }
    

}
- (IBAction)btnSignOutClick:(id)sender
{
    
    if ([path isEqualToString:@"/"])
    {
        [[DBSession sharedSession] unlinkAll];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
       NSRange range= [path rangeOfString: @"/" options: NSBackwardsSearch];
        path= [path substringToIndex: range.location];
        range= [path rangeOfString: @"/" options: NSBackwardsSearch];
        path= [path substringToIndex: range.location];
        path=[NSString stringWithFormat:@"%@/",path];
        
        [arryTitle removeLastObject];
        [self startLoaderWithMessage:@""];
        [self.restClient loadMetadata:path];
       
       
    }
    
}

- (IBAction)btnCancelAndImportClick:(id)sender
{
    if (countSelect==0)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        if (_isCreateAds)
        {
            bool isNotValid=false;
            for (int i=0; i<arryData.count; i++)
            {
                
                if ([[[arryData objectAtIndex:i] valueForKey:@"isChecked"]isEqualToString:@"1"])
                {
                    NSString *strLocalPath = [Utils getPathForFolderPath:@"Shared_File" withFileName:[[arryData objectAtIndex:i] valueForKey:@"filename"]];

            
                        if (!([[strLocalPath pathExtension] isEqualToString:@"jpg"] || [[strLocalPath pathExtension] isEqualToString:@"png"] || [[strLocalPath pathExtension] isEqualToString:@"pdf"]))
                        {
                            isNotValid=true;
                            
                        }
                }
            }
            if (isNotValid)
            {
                UIAlertView *alt=[[UIAlertView alloc] initWithTitle:@"Studebuddies" message:@"Select only image and PDF document file.!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alt show];
            }
            else
            {
                for (int i=0; i<arryData.count; i++)
                {
                    
                    if ([[[arryData objectAtIndex:i] valueForKey:@"isChecked"]isEqualToString:@"1"])
                    {
                        NSString *strLocalPath = [Utils getPathForFolderPath:@"Shared_File" withFileName:[[arryData objectAtIndex:i] valueForKey:@"filename"]];
                        
                        [self.restClient loadFile:[[arryData objectAtIndex:i] valueForKey:@"path"] intoPath:strLocalPath];
                        [self startLoaderWithMessage:@""];
                        
                    }
                    
                    
                }

            }
            

        }
        else
        {
            for (int i=0; i<arryData.count; i++)
            {
                
                if ([[[arryData objectAtIndex:i] valueForKey:@"isChecked"]isEqualToString:@"1"])
                {
                    NSString *strLocalPath = [Utils getPathForFolderPath:@"Shared_File" withFileName:[[arryData objectAtIndex:i] valueForKey:@"filename"]];
                    
                    [self.restClient loadFile:[[arryData objectAtIndex:i] valueForKey:@"path"] intoPath:strLocalPath];
                    [self startLoaderWithMessage:@""];
                    
                }
                
                
            }

        }
    }
    
    
}
- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)localPath
       contentType:(NSString *)contentType metadata:(DBMetadata *)metadata
{
    NSLog(@"File loaded into path: %@", localPath);
    
    if (_isCreateAds)
    {
        
        [SharedAppDelegate.cmResponce addObject:localPath];
          count++;
        if (count==countSelect)
        {
             NSLog(@"%@",SharedAppDelegate.cmResponce);
            [self stopLoader];
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }
    }
    else
    {
        NSMutableArray *arryPath=[[NSMutableArray alloc]init];
        [arryPath addObject:localPath];
        
        NSMutableDictionary *dictSend=[[NSMutableDictionary alloc] init];
        
        [Connection callServiceWithDocument:arryPath  params:dictSend serviceIdentifier:@"SaveFilesFromApp" callBackBlock:^(id response, NSError *error)
         {
             count++;
             
             [SharedAppDelegate.responce addObject:response];
             
             if (count==countSelect)
             {
                 NSLog(@"%@",SharedAppDelegate.responce);
                 
                 [self stopLoader];
                 [self dismissViewControllerAnimated:YES completion:nil];
                 
             }
         }];

    }
    
    
    
    
    
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error
{
    count++;
    if (count==countSelect)
    {
        [self stopLoader];
        [self dismissViewControllerAnimated:YES completion:nil];


    }
    [self showAlert:@"DropBox" message:[error.userInfo valueForKey:@"error"]];
    
}
- (IBAction)btnLinkClick:(id)sender
{
    [[DBSession sharedSession] linkFromController:self];
}
- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:title
                                       message:message
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
    [alert show];
}

- (void)startLoaderWithMessage:(NSString *)message
{
    //    UIView *view = SharedAppDelegate.window.rootViewController.view;
    //    MBProgressHUD *_hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    //    _hud.dimBackground  = NO;
    //    _hud.labelText      = message;
    
    [Utils stopLoader];
    UIView *view = self.view;
    UIImageView *imgViewLoader = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"waitLoading" withExtension:@"gif"];
    imgViewLoader.image=[UIImage animatedImageWithAnimatedGIFURL:url];
    [imgViewLoader.layer setCornerRadius:10];
    [imgViewLoader setClipsToBounds:YES];
    //        innerPopUpView.backgroundColor=[UIColor whiteColor];
    //        [innerPopUpView.layer setShadowOpacity:0.9];
    //        [innerPopUpView.layer setShadowRadius:2.0];
    
    [view addSubview:imgViewLoader];
    imgViewLoader.center = view.center;
    imgViewLoader.tag = 30000;
    [view setUserInteractionEnabled:NO];
    
    
    //    [imgViewLoader setImage:[UIImage imageNamed:@"iconApp40.png"]];
    //    [imgViewLoader setContentMode:UIViewContentModeScaleAspectFill];
    //    [imgViewLoader.layer setCornerRadius:30];
    //    [imgViewLoader setClipsToBounds:YES];
    //    [view addSubview:imgViewLoader];
    //    imgViewLoader.center = view.center;
    //    CABasicAnimation *rotation;
    //    rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    //    rotation.fromValue = [NSNumber numberWithFloat:0];
    //    rotation.toValue = [NSNumber numberWithFloat:( 2 * M_PI)];
    //    rotation.duration = 1; // Speed
    //    rotation.repeatCount = HUGE_VALF; // Repeat forever. Can be a finite number.
    //    [imgViewLoader.layer addAnimation:rotation forKey:@"Spin"];
    //    imgViewLoader.tag = 30000;
    //    [view setUserInteractionEnabled:NO];
    
    // [Utils startActivityIndicatorInView:view withMessage:@""];
    
}

- (void)stopLoader
{
    //    UIView *view = SharedAppDelegate.window.rootViewController.view;
    //    [MBProgressHUD hideHUDForView:view animated:YES];
    
    UIView *view = self.view;
    UIImageView *imgViewLoader = (UIImageView*)[view viewWithTag:30000];
    [imgViewLoader removeFromSuperview];
    imgViewLoader = nil;
    [view setUserInteractionEnabled:YES];
    
    // [Utils stopActivityIndicatorInView:view];
}


 @end
