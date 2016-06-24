//
//  GoogleDriveViewController.m
//  TedBuddies
//
//  Created by Mac on 29/03/16.
//  Copyright © 2016 Mayank Pahuja. All rights reserved.
//

#import "GoogleDriveViewController.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"
#import "NSDictionary+dictionaryWithObject.h"
#import "GoogleDriveTableViewCell.h"
#import "UIImage+animatedGIF.h"


static NSString *const kKeychainItemName = @"StudeBuddies";
static NSString *const kClientID = @"38779399105-5hvb1lci0r6pj2gohrk9jr469oopte05.apps.googleusercontent.com";


@interface GoogleDriveViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *fileDetails;
    NSMutableArray *folder;
    NSMutableArray *arryData;
    NSString *path;
    NSMutableArray *selectedFolder;
    
    NSURL *fileURL;
    
    NSInteger countSelect;
     NSInteger count;
   
}


@property (nonatomic, strong) GTLServiceDrive *service;
@property (nonatomic, strong) GTMOAuth2ViewControllerTouch *ViewControllerTouch;

@end

@implementation GoogleDriveViewController

@synthesize service = _service;
@synthesize ViewControllerTouch= _ViewControllerTouch;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize the Drive API service & load existing credentials from the keychain if available.
    path=[NSString stringWithFormat:@"'%@' IN parents", @"root"];
    self.service = [[GTLServiceDrive alloc] init];
   self.service.authorizer= [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                          clientID:kClientID
                                                      clientSecret:nil];
    
    
    if (!self.service.authorizer.canAuthorize) {
        // Not yet authorized, request authorization by pushing the login UI onto the UI stack.
        [self presentViewController:[self createAuthController] animated:YES completion:nil];
        
    }
    folder=[[NSMutableArray alloc]init];
    fileDetails=[[NSMutableArray alloc] init];
    arryData=[[NSMutableArray alloc]init];
    selectedFolder=[[NSMutableArray alloc]init];
    _tblView.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
    
    countSelect=0;
    count=0;
    SharedAppDelegate.responce=[[NSMutableArray alloc] init];
    SharedAppDelegate.cmResponce=[[NSMutableArray alloc] init];

}
- (void) configureButton:(MIBadgeButton *) button withBadge:(NSString *) badgeString {
    //[button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    // optional to change the default position of the badge
    [button setBadgeEdgeInsets:UIEdgeInsetsMake(8, 5, 0, 8)];
    button.badgeBackgroundColor = [UIColor redColor];
    [button setBadgeString:badgeString];
}

// When the view appears, ensure that the Drive API service is authorized, and perform API calls.
- (void)viewDidAppear:(BOOL)animated {
    if (self.service.authorizer.canAuthorize)
    {
        _btnSignOut.alpha=1.0;
        _tblView.alpha=1.0;
        _btnLink.alpha=0.0;
        _lblNote.alpha=0.0;
        [self startLoaderWithMessage:@""];
        [self fetchFiles];
        
    }
}

// Construct a query to get names and IDs of 10 files using the Google Drive API.
- (void)fetchFiles {
    
    GTLQueryDrive *query = [GTLQueryDrive queryForFilesList];
    query.q = path;
    
    [self.service executeQuery:query
                      delegate:self
             didFinishSelector:@selector(displayResultWithTicket:finishedWithObject:error:)];
    
    
}



// Process the response and display output./
- (void)displayResultWithTicket:(GTLServiceTicket *)ticket
             finishedWithObject:(GTLDriveFileList *)response
                          error:(NSError *)error {
    if (error == nil)
    {
        NSMutableArray *driveFiles = [[NSMutableArray alloc] init]; //
        [driveFiles addObjectsFromArray:response.items];
        
        [folder removeAllObjects];
        [fileDetails removeAllObjects];
        [arryData removeAllObjects];

        
        for (GTLDriveFile *file in driveFiles)
        {
            NSLog(@"%@",file.downloadUrl);
            if ([file.mimeType rangeOfString:@"folder"].location != NSNotFound)
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
        [self configureButton:_btnCancelAndImport withBadge:nil];
        [_btnCancelAndImport setTitle:@"Cancel" forState:UIControlStateNormal];
        _tblView.delegate=self;
        _tblView.dataSource=self;
        [_tblView reloadData];
        

        if ([path isEqualToString:[NSString stringWithFormat:@"'%@' IN parents", @"root"]])
        {
            [_btnSignOut setTitle:@"Sign Out" forState:UIControlStateNormal];
            _lblNavTitle.text=@"Google Drive";
            
        }
        else
        {
            [_btnSignOut setTitle:@" Back " forState:UIControlStateNormal];
            _lblNavTitle.text=[[selectedFolder lastObject]  valueForKey:@"title"];
        }
        
        NSLog(@"%@",arryData);
    }
    
    else
    {
        [self stopLoader];
        [self showAlert:@"Error" message:error.localizedDescription];
    }
}


// Creates the auth controller for authorizing access to Drive API.
- (GTMOAuth2ViewControllerTouch *)createAuthController {
    GTMOAuth2ViewControllerTouch *authController;
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    NSArray *scopes = [NSArray arrayWithObjects:kGTLAuthScopeDrive, nil];
    authController = [[GTMOAuth2ViewControllerTouch alloc]
                      initWithScope:[scopes componentsJoinedByString:@" "]
                      clientID:kClientID
                      clientSecret:nil
                      keychainItemName:kKeychainItemName
                      delegate:self
                      finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    return authController;
}

// Handle completion of the authorization process, and update the Drive API
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error {
    if (error != nil) {
        [self showAlert:@"Authentication Error" message:error.localizedDescription];
        self.service.authorizer = nil;
    }
    else {
        self.service.authorizer = authResult;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:title
                                       message:message
                                      delegate:nil
                             cancelButtonTitle:@"OK"
                             otherButtonTitles:nil];
    [alert show];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
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
    
    GoogleDriveTableViewCell *cell = (GoogleDriveTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    if (cell == nil)
    {
        cell = (GoogleDriveTableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"GoogleDriveTableViewCell" owner:self options:nil] objectAtIndex:0];
        
    }
    if (arryData.count==0)
    {
        cell.lblName.text=@"File and Folder not found..!";
        [cell.lblName setTranslatesAutoresizingMaskIntoConstraints:YES];
        [cell.lblName setFrame:CGRectMake(cell.lblName.xOrigin, 13, cell.lblName.width, cell.lblName.height)];
        
        cell.imgFile.alpha=0.0;
        cell.imgSelect.alpha=0.0;
        cell.lblAttribute.alpha=0.0;
        
        return cell;
    }
    
    cell.lblName.text=[[arryData objectAtIndex:indexPath.row] valueForKey:@"title"];
    
     [ cell.imgFile setImageWithURL:[NSURL URLWithString:[[arryData objectAtIndex:indexPath.row] valueForKey:@"iconLink"]] placeholderImage:[UIImage imageNamed:@"appicon.png"]];
    
    // Setup Last Modified Date
    NSLocale *locale = [NSLocale currentLocale];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"E MMM d yyyy" options:0 locale:locale];
    [formatter setDateFormat:dateFormat];
    [formatter setLocale:locale];
    
    // Get File Details and Display
    if ([[[arryData objectAtIndex:indexPath.row] valueForKey:@"mimeType"] rangeOfString:@"folder"].location != NSNotFound)
    {
        // Folder
        [cell.lblName setTranslatesAutoresizingMaskIntoConstraints:YES];
        [cell.lblName setFrame:CGRectMake(cell.lblName.xOrigin, 13, cell.lblName.width, cell.lblName.height)];
    }
    else
    {
        // File
        GTLDateTime *date=[[arryData objectAtIndex:indexPath.row] valueForKey:@"modifiedDate"];
        NSString *fileSize=[NSString stringWithFormat:@"%.2f MB",[[[arryData objectAtIndex:indexPath.row] valueForKey:@"quotaBytesUsed"] floatValue]/1024.0f/1024.0f];
        cell.lblAttribute.text = [NSString stringWithFormat:NSLocalizedString(@"%@, modified %@", @"DriveBrowser: File detail label with the file size and modified date."),fileSize, [formatter stringFromDate:date.date]];
        
    }
    
    
    if ([[[arryData objectAtIndex:indexPath.row] valueForKey:@"mimeType"] rangeOfString:@"folder"].location != NSNotFound)
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
        if ([[[arryData objectAtIndex:indexPath.row] valueForKey:@"mimeType"] rangeOfString:@"folder"].location != NSNotFound)
        {
            [selectedFolder addObject:[arryData objectAtIndex:indexPath.row]];
            path=[NSString stringWithFormat:@"'%@' IN parents", [[arryData objectAtIndex:indexPath.row] valueForKey:@"identifier"]];
            [self startLoaderWithMessage:@""];
            [self fetchFiles];
        }
        else
        {
            GoogleDriveTableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
            
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
            
            BOOL flag=false;
            countSelect=0;
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
    
    if ([path isEqualToString:[NSString stringWithFormat:@"'%@' IN parents", @"root"]])
    {
        [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:kKeychainItemName];
        self.service.authorizer = nil;
        [self dismissViewControllerAnimated:YES completion:nil];

    }
    else
    {
        if ([[[[[selectedFolder lastObject] valueForKey:@"parents"] objectAtIndex:0] valueForKey:@"isRoot"] boolValue])
        {
           path=[NSString stringWithFormat:@"'%@' IN parents", @"root"];
        }
        else
        {
            path=[NSString stringWithFormat:@"'%@' IN parents",[[[[selectedFolder lastObject]  valueForKey:@"parents"] objectAtIndex:0] valueForKey:@"identifier"]];
            [selectedFolder removeLastObject];
            
        }
        
        
        [self startLoaderWithMessage:@""];
        [self fetchFiles];
        
        
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
                    NSString *fileExtension = [[arryData objectAtIndex:i] valueForKey:@"fileExtension"];
                    
                    if (!([fileExtension isEqualToString:@"jpg"] || [fileExtension isEqualToString:@"png"] || [fileExtension isEqualToString:@"jpeg"] ||[fileExtension isEqualToString:@"pdf"]))
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
                        NSString *strURL = [[arryData objectAtIndex:i] valueForKey:@"downloadUrl"];
                        NSURL *url = [NSURL URLWithString:[strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                        GTMHTTPFetcher *fetcher = [self.service.fetcherService fetcherWithURL:url];
                        [self startLoaderWithMessage:@""];
                        [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
                            if (error == nil)
                            {
                                NSString *strPath = [Utils getPathForFolderPath:@"Shared_File" withFileName:[[arryData objectAtIndex:i] valueForKey:@"title"]];
                                if ([[NSFileManager defaultManager] createFileAtPath:strPath contents:data attributes:nil])
                                {
                                        count++;
                                         
                                         [SharedAppDelegate.cmResponce addObject:strPath];
                                    
                                         
                                         if (count==countSelect)
                                         {
                                               NSLog(@"%@",SharedAppDelegate.cmResponce);
                                              [self dismissViewControllerAnimated:YES completion:nil];
                                              [self stopLoader];
                                             
                                         }
                                 
                                    
                                    
                                }
                                else
                                {
                                    NSLog(@"error");
                                }
                                
                            }
                            else
                            {
                                count++;
                                if (count==countSelect)
                                {
                                    NSLog(@"%@",SharedAppDelegate.responce);
                                    [self stopLoader];
                                    [self dismissViewControllerAnimated:YES completion:nil];
                                    
                                }
                                [self showAlert:@"Google Drive" message:[error localizedDescription]];
                            }
                        }];
                        
                        
                        
                        
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
                    NSString *strURL = [[arryData objectAtIndex:i] valueForKey:@"downloadUrl"];
                    NSURL *url = [NSURL URLWithString:[strURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    GTMHTTPFetcher *fetcher = [self.service.fetcherService fetcherWithURL:url];
                    [self startLoaderWithMessage:@""];
                    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
                        if (error == nil)
                        {
                            NSString *strPath = [Utils getPathForFolderPath:@"Shared_File" withFileName:[[arryData objectAtIndex:i] valueForKey:@"title"]];
                            if ([[NSFileManager defaultManager] createFileAtPath:strPath contents:data attributes:nil])
                            {
                                NSLog(@"sucess");
                                NSMutableArray *arryPath=[[NSMutableArray alloc]init];
                                [arryPath addObject:strPath];
                                
                                NSMutableDictionary *dictSend=[[NSMutableDictionary alloc] init];
                                
                                
                                [Connection callServiceWithDocument:arryPath  params:dictSend serviceIdentifier:@"SaveFilesFromApp" callBackBlock:^(id response, NSError *error)
                                 {
                                     count++;
                                     
                                     [SharedAppDelegate.responce addObject:response];
                                     
                                     if (count==countSelect)
                                     {
                                         NSLog(@"%@",SharedAppDelegate.responce);
                                         [self dismissViewControllerAnimated:YES completion:nil];
                                         [self stopLoader];
                                         
                                     }
                                 }];
                                
                                
                            }
                            else
                            {
                                NSLog(@"error");
                            }
                            
                        }
                        else
                        {
                            count++;
                            if (count==countSelect)
                            {
                                NSLog(@"%@",SharedAppDelegate.responce);
                                [self stopLoader];
                                [self dismissViewControllerAnimated:YES completion:nil];
                                
                            }
                            [self showAlert:@"Google Drive" message:[error localizedDescription]];
                        }
                    }];
                    
                    
                    
                    
                }
                
                
                
            }
        }
        
    }

    
    
    
    
 
}

- (IBAction)btnLinkClick:(id)sender
{
    [self presentViewController:[self createAuthController] animated:YES completion:nil];
    
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
