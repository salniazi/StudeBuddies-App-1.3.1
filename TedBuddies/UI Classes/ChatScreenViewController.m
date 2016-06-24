//
//  ChatScreenViewController.m
//  TedBuddies
//
//  Created by Mayank Pahuja on 18/09/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import "ChatScreenViewController.h"
#import "MyWebSocket.h"
#import "Reachability.h"
#import "MessagesViewController.h"
#import "GoogleDriveViewController.h"
#import "DropBoxViewController.h"
#import <QuickLook/QuickLook.h>
#import "GifDisplayViewController.h"
#import "UIImage+animatedGIF.h"
#import "ViewProfileViewController.h"
#import "GroupMemberListViewController.h"



@interface ChatScreenViewController ()<QLPreviewControllerDataSource,QLPreviewControllerDelegate,UIAlertViewDelegate>
{
    NSMutableDictionary *dictSelected;
     UINavigationController *navController;
      BOOL isMultiSelect;
    int count;
    NSMutableArray *SeletedArry;
   }

@property (strong, nonatomic) id observerWillShow;
@property (strong, nonatomic) id observerWillHide;
@property (strong, nonatomic) id observerWillChat;
@property (strong, nonatomic) id observerWillDisappear;
@property (strong, nonatomic) id observerWillAppear;

@property (nonatomic) Reachability *internetReachability;
@end

@implementation ChatScreenViewController

#define TagImage        10
#define TagChatBubble   11
#define TagChatText     12
#define TagTime         13
#define TagPostedImage  14


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
    
    
    self.txtFieldUserInput.delegate = self;
    self.txtFieldUserInput.autoresizesVertically = YES;
    self.txtFieldUserInput.minimumHeight = 30.0f;
    self.txtFieldUserInput.maximumHeight = 100.0f;
    self.txtFieldUserInput.placeholder = @"";

    
    [self.tabBarController.tabBar setHidden:YES];
    
    dictSelected=[[NSMutableDictionary alloc] init];
    
    if (_isGroup)
    {
       
       
        SharedAppDelegate.isMuteGroup=[[_dictBuddyInfo  valueForKey:@"ismute"] boolValue];
        isLeft=[[_dictBuddyInfo  valueForKey:@"isleft"] boolValue];
        if ([[_dictBuddyInfo  valueForKey:@"isleft"] boolValue])
        {
            _viewChatBar.hidden=YES;
            _lblHideChat.hidden=NO;
            _lblLeftDate.text=[_dictBuddyInfo  valueForKey:@"leftDate"];
            
        }

    }
    
    newFormatter = [[NSDateFormatter alloc] init];
    [newFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [newFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    
    isServiceLoaded = NO;
    
    [self callAPIGetChatHistory:YES];
    
    [self addObservers];
    [[MyWebSocket sharedInstance] setGetChatData:^(id data)
     {
         if (isServiceLoaded)
         {
             
             
             NSMutableDictionary *dictAddToChat = [[NSMutableDictionary alloc] initWithDictionary:data];
             if ([[dictAddToChat objectForKey:kIsGroup] intValue] ==1)
             {
                 if ([[dictAddToChat objectForKey:kToId] isEqualToString:[_dictBuddyInfo objectForKey:kBuddyId]])
                 {
                     for (NSDictionary *dictRec in [_dictBuddyInfo objectForKey:kGroupMember])
                     {
                         if ([[dictAddToChat objectForKey:kUserId] isEqualToString:[dictRec objectForKey:kUserId]])
                         {
                             [dictAddToChat setObject:[dictRec objectForKey:kProfileImage] forKey:kProfileImage];
                         }
                     }
                     NSDate *dateNow = [Utils getUTCTime];
                     NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                     [formatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
                     NSString *strDate = [formatter stringFromDate:dateNow];
                     
                     NSString *timeAgo = [Utils timeAgo:strDate withFormat:@"MM/dd/yyyy hh:mm:ss a"];
                     [dictAddToChat setObject:strDate forKey:kCreatedDateChat];
                     [dictAddToChat setObject:timeAgo forKey:@"timeAgo"];
                     [arrChatHistory addObject:dictAddToChat];
                     
                     [_tblChat reloadData];
                     NSIndexPath *myIndexPath = [NSIndexPath indexPathForRow:arrChatHistory.count-1 inSection:0];
                     [self.tblChat selectRowAtIndexPath:myIndexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
                 }
             }
             else
             {
                 if ([[dictAddToChat objectForKey:kUserId] isEqualToString:[_dictBuddyInfo objectForKey:kBuddyId]])
                 {
                     [dictAddToChat setObject:[_dictBuddyInfo objectForKey:kBuddyImage] forKey:kProfileImage];
                     NSDate *dateNow = [Utils getUTCTime];
                     NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                     [formatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
                     NSString *strDate = [formatter stringFromDate:dateNow];
                     
                     NSString *timeAgo = [Utils timeAgo:strDate withFormat:@"MM/dd/yyyy hh:mm:ss a"];
                     [dictAddToChat setObject:strDate forKey:kCreatedDateChat];
                     [dictAddToChat setObject:timeAgo forKey:@"timeAgo"];
                     [arrChatHistory addObject:dictAddToChat];
                     
                     [_tblChat reloadData];
                     NSIndexPath *myIndexPath = [NSIndexPath indexPathForRow:arrChatHistory.count-1 inSection:0];
                     [self.tblChat selectRowAtIndexPath:myIndexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
                 }
                 
             }
         }
     }];
    
    
    [self setFonts];
    
    
//    
//    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
//                                          initWithTarget:self action:@selector(handleLongPress:)];
//    lpgr.minimumPressDuration = 1; //seconds
//    lpgr.delegate = self;
//    [self.tblChat addGestureRecognizer:lpgr];
//    isMultiSelect=NO;
//    count=0;
//      SeletedArry=[[NSMutableArray alloc] init];

    
    // Do any additional setup after loading the view from its nib.
}
#pragma mark EAMTextViewDelegate

- (void)textView:(EAMTextView *)textView willChangeFromHeight:(CGFloat)oldHeight toHeight:(CGFloat)newHeight
{
    CGRect frame = self.viewChatBar.frame;
    CGFloat difference = newHeight - oldHeight;
    frame.size.height += difference;
    frame.origin.y -= difference;
    self.viewChatBar.frame = frame;
    if (oldHeight<newHeight)
    {
        _tblChat.height=_tblChat.height-(newHeight-oldHeight);
        if ([arrChatHistory count]!=0)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[arrChatHistory count]-1 inSection:0];
            [_tblChat scrollToRowAtIndexPath:indexPath
                            atScrollPosition:UITableViewScrollPositionTop
                                    animated:NO];
   
        }
    }
    else
    {
        _tblChat.height=_tblChat.height+(oldHeight-newHeight);
    }

    
}

- (void)textView:(EAMTextView *)textView didChangeFromHeight:(CGFloat)oldHeight toHeight:(CGFloat)newHeight
{
    NSLog(@"Finished height change animation from height %f to height %f", oldHeight, newHeight);
    
  
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    CGPoint p = [gestureRecognizer locationInView:self.tblChat];
    
    NSIndexPath *indexPath = [self.tblChat indexPathForRowAtPoint:p];
    
    UITableViewCell *cell = [self.tblChat cellForRowAtIndexPath:indexPath];
    
    if (indexPath == nil)
    {
        NSLog(@"long press on table view but not on a row");
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        if (!isMultiSelect)
        {
            _deleteView.alpha=1.0;
            _navigationView.alpha=0.0;
            cell.backgroundColor=[UIColor colorWithRed:153/255.0f green:204/255.0f blue:255/255.0f alpha:0.5];
            isMultiSelect=YES;
            count=count+1;
            _lblCountDelete.text=[NSString stringWithFormat:@"%d",count];
            [SeletedArry addObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
        }
    }
    else
    {
        NSLog(@"gestureRecognizer.state = %ld", (long)gestureRecognizer.state);
    }
}

-(void)dealloc
{
    [self removeObservers];
    [[MyWebSocket sharedInstance] setGetChatData:nil];
    
}

- (void)addObservers
{
    //keyboard show notification
    
    _observerWillShow = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:Nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note)
    {
    
        float keyboardHeight = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
        [_viewChatBar setYOrigin:(self.view.bounds.size.height - _viewChatBar.height - keyboardHeight)];
        _tblChat.height = _viewChatBar.yOrigin - 64;
        if ([arrChatHistory count] > 0) {
            
            NSIndexPath *myIndexPath = [NSIndexPath indexPathForRow:arrChatHistory.count-1 inSection:0];
            
            [self.tblChat scrollToRowAtIndexPath:myIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            
        }
       
    }];
    
    
    //keyboard hide notification
    
    _observerWillHide = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:Nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note)
        {
            [_viewChatBar setYOrigin:(self.view.bounds.size.height - _viewChatBar.height)];
            _tblChat.height = _viewChatBar.yOrigin - 64;
            if ([arrChatHistory count]>0) {
                NSIndexPath *myIndexPath = [NSIndexPath indexPathForRow:arrChatHistory.count-1 inSection:0];
                [self.tblChat scrollToRowAtIndexPath:myIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }];
    
   
    _observerWillChat = [[NSNotificationCenter defaultCenter] addObserverForName:@"ChatReceived" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note)
     {
         isServiceLoaded = NO;
         [self callAPIGetChatHistory:NO];
     }];
    
    _observerWillDisappear = [[NSNotificationCenter defaultCenter] addObserverForName:@"ChatScreenDisappear" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note)
    {
         [[MyWebSocket sharedInstance] SendMessageJson:@{kFromId: [defaults objectForKey:kUserId],kToId:[_dictBuddyInfo objectForKey:kBuddyId],kIsGroup:_isGroup?@"True":@"False",kIsSessionStart:@"False"}];
    }];

    _observerWillAppear = [[NSNotificationCenter defaultCenter] addObserverForName:@"ChatScreenAppear" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note)
    {
        [self.navigationController popViewControllerAnimated:NO];
    }];
    
}

- (void)removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:_observerWillShow name:UIKeyboardWillShowNotification object:nil];
    _observerWillShow = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:_observerWillHide name:UIKeyboardWillHideNotification object:nil];
    _observerWillHide = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:_observerWillChat name:@"ChatReceived" object:nil];
    _observerWillChat = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:_observerWillDisappear name:@"ChatScreenDisappear" object:nil];
    _observerWillDisappear = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:_observerWillAppear name:@"ChatScreenAppear" object:nil];
    _observerWillDisappear = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[MyWebSocket sharedInstance] SendMessageJson:@{kFromId: [defaults objectForKey:kUserId],kToId:[_dictBuddyInfo objectForKey:kBuddyId],kIsGroup:_isGroup?@"True":@"False",kIsSessionStart:@"True"}];
    
    
    if (SharedAppDelegate.responce.count!=0)
    {
        
        
        for (int i=0; i<SharedAppDelegate.responce.count; i++)
        {
            NSMutableDictionary *resp=[[NSMutableDictionary alloc] init];
            resp=[SharedAppDelegate.responce objectAtIndex:i];
            if ([[resp objectForKeyNonNull:kSuccess] boolValue] == true)
            {
                NSLog(@"res:%@",SharedAppDelegate.responce);
                NSDictionary *dictSend = @{
                                           kFromId:[defaults objectForKey:kUserId],
                                           kToId:[_dictBuddyInfo objectForKey:kBuddyId],
                                           @"isGroup":(_isGroup?@"1":@"0"),
                                           @"messageType":@"2",
                                           @"deviceTimeStamp":[@([Utils getCurrentTimeStamp]) stringValue],
                                           @"message":[resp objectForKey:kResult]
                                           };
                [[MyWebSocket sharedInstance] SendMessage:dictSend];
                
                //    NSLog(@"tuime:%@",[Utils getLocalTimeFromUtc:[[arrChatHistory lastObject] objectForKey:kCreatedDate] inFormat:@"MM/dd/yyyy hh:mm:ss a"]);
                
                NSDate *dateNow = [Utils getUTCTime];
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                [formatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
                NSString *strDate = [formatter stringFromDate:dateNow];
                
                NSString *timeAgo = [Utils timeAgo:strDate withFormat:@"MM/dd/yyyy hh:mm:ss a"];
                
                NSString *profilePict = [[NSUserDefaults standardUserDefaults] objectForKey:@"profilePicture"];
                
                NSDictionary *dictAddToChat = @{kCreatedDateChat:strDate,
                                                @"profileImage":profilePict,
                                                kProfileImage:@"",
                                                kUserId:[defaults objectForKey:kUserId],
                                                kMessageSmall:[resp objectForKey:kResult],
                                                kChatId:@"",
                                                @"messageType":@"2",
                                                kUserName:@"amani",
                                                @"timeAgo":timeAgo,
                                                kIsGroup:_isGroup?@"1":@"0"
                                                };
                
                [arrChatHistory addObject:dictAddToChat];
                
                [_tblChat reloadData];
                NSIndexPath *myIndexPath = [NSIndexPath indexPathForRow:arrChatHistory.count-1 inSection:0];
                [self.tblChat selectRowAtIndexPath:myIndexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
                
            }
        }
        
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
        
        NSString *pathToFolder = [documentsDirectory stringByAppendingPathComponent:@"Shared_File"];
        
        NSArray *fileArray = [fileMgr contentsOfDirectoryAtPath:pathToFolder error:nil];
        for (NSString *filename in fileArray)  {
            
            [fileMgr removeItemAtPath:[pathToFolder stringByAppendingPathComponent:filename] error:NULL];
        }

        
    }
    [SharedAppDelegate.responce removeAllObjects];
    
    
    if (SharedAppDelegate.responceGIF.count!=0)
    {
        
       
                NSLog(@"res:%@",SharedAppDelegate.responceGIF);
                NSDictionary *dictSend = @{
                                           kFromId:[defaults objectForKey:kUserId],
                                           kToId:[_dictBuddyInfo objectForKey:kBuddyId],
                                           @"isGroup":(_isGroup?@"1":@"0"),
                                           @"messageType":@"2",
                                           @"deviceTimeStamp":[@([Utils getCurrentTimeStamp]) stringValue],
                                           @"message":[[[[SharedAppDelegate.responceGIF objectAtIndex:0] valueForKey:@"images"] valueForKey:@"fixed_width_downsampled"] valueForKey:@"url"]
                                           };
                [[MyWebSocket sharedInstance] SendMessage:dictSend];
                
                //    NSLog(@"tuime:%@",[Utils getLocalTimeFromUtc:[[arrChatHistory lastObject] objectForKey:kCreatedDate] inFormat:@"MM/dd/yyyy hh:mm:ss a"]);
                
                NSDate *dateNow = [Utils getUTCTime];
                NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                [formatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
                NSString *strDate = [formatter stringFromDate:dateNow];
                
                NSString *timeAgo = [Utils timeAgo:strDate withFormat:@"MM/dd/yyyy hh:mm:ss a"];
                
                NSString *profilePict = [[NSUserDefaults standardUserDefaults] objectForKey:@"profilePicture"];
                
                NSDictionary *dictAddToChat = @{kCreatedDateChat:strDate,
                                                @"profileImage":profilePict,
                                                kProfileImage:@"",
                                                kUserId:[defaults objectForKey:kUserId],
                                                kMessageSmall:[[[[SharedAppDelegate.responceGIF objectAtIndex:0] valueForKey:@"images"] valueForKey:@"fixed_width_downsampled"] valueForKey:@"url"],
                                                kChatId:@"",
                                                @"messageType":@"2",
                                                kUserName:@"amani",
                                                @"timeAgo":timeAgo,
                                                kIsGroup:_isGroup?@"1":@"0"
                                                };
                
                [arrChatHistory addObject:dictAddToChat];
                
                [_tblChat reloadData];
                NSIndexPath *myIndexPath = [NSIndexPath indexPathForRow:arrChatHistory.count-1 inSection:0];
                [self.tblChat selectRowAtIndexPath:myIndexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
                
        
        
    }
    [SharedAppDelegate.responceGIF  removeAllObjects];
    
    if (SharedAppDelegate.isLeftGroup)
    {
        _viewChatBar.hidden=YES;
        _lblHideChat.hidden=NO;
        isLeft=YES;
        NSDate *now = [NSDate date];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"hh:mm aa";
        [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        _lblLeftDate.text=[NSString stringWithFormat:@"Today at %@",[dateFormatter stringFromDate:now]];
        SharedAppDelegate.isLeftGroup=NO;
    }
    if(SharedAppDelegate.isJoinGroup)
    {
        _viewChatBar.hidden=NO;
        _lblHideChat.hidden=YES;
       isLeft=NO;
        SharedAppDelegate.isJoinGroup=NO;
    }
    isMute=SharedAppDelegate.isMuteGroup;

}

- (void)viewWillDisappear:(BOOL)animated
{
    [[MyWebSocket sharedInstance] SendMessageJson:@{kFromId: [defaults objectForKey:kUserId],kToId:[_dictBuddyInfo objectForKey:kBuddyId],kIsGroup:_isGroup?@"True":@"False",kIsSessionStart:@"False"}];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    
    // Dispose of any resources that can be recreated.
}
- (void)setFonts
{
    [_txtFieldUserInput.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [_txtFieldUserInput.layer setBorderWidth:kButtonBorderWidth];
    [_txtFieldUserInput.layer setCornerRadius:kButtonCornerRadius];
    
    
    
    [_lblNavBar setText:[_dictBuddyInfo objectForKey:kBuddyName]];
    
}

- (NSString *)timeAgo:(NSString *)time
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    
    NSInteger interval = [[Utils getUTCTime] timeIntervalSinceDate:[formatter dateFromString:time]];
    interval = abs(interval);
    
    if (interval < 60)
    {
        return [NSString stringWithFormat:@"%d sec ago",interval];
    }
    else if(interval>= 60 && interval < 60*60)
    {
        if (interval/60 == 1) {
            return [NSString stringWithFormat:@"%d min ago",interval/60];
        }
        return [NSString stringWithFormat:@"%d mins ago",interval/60];
    }
    else if(interval>= 60*60 && interval < 60*60*24)
    {
        if (interval/60/60 == 1) {
            return [NSString stringWithFormat:@"%d hour ago",interval/60/60];
        }
        return [NSString stringWithFormat:@"%d hours ago",interval/60/60];
    }
    else
    {
        if (interval/60/60/24 == 1) {
            return [NSString stringWithFormat:@"%d day ago",interval/60/60/24];
        }
        return [NSString stringWithFormat:@"%d days ago",interval/60/60/24];
    }
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrChatHistory count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dictRow = [arrChatHistory objectAtIndex:indexPath.row];
    
    if ([[dictRow objectForKey:kMessageType] isEqualToString:@"2"])
    {
        if (!([[[dictRow objectForKey:kMessageSmall] pathExtension] isEqualToString:@"jpg"] || [[[dictRow objectForKey:kMessageSmall] pathExtension] isEqualToString:@"png"]| [[[dictRow objectForKey:kMessageSmall] pathExtension] isEqualToString:@"gif"] ))
        {
            
            NSArray *arrComponents = [[dictRow objectForKey:kMessageSmall] componentsSeparatedByString:@"/"];
            NSString *fileName = [arrComponents lastObject];
            if (![[NSFileManager defaultManager] fileExistsAtPath:[Utils getPathForFolderPath:@"Attachment" withFileName:fileName]])
            {
                NSString *strPath = [Utils getPathForFolderPath:@"Attachment" withFileName:fileName];
                NSURL *url = [NSURL URLWithString:[[dictRow objectForKey:kMessageSmall] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                
               
                    if ([[UIApplication sharedApplication] canOpenURL:url] && (![[dictRow objectForKey:kMessageSmall] containsString:@"localhost"] ) )
                    {
                        NSData *data=[[NSData alloc]initWithContentsOfURL:url];
                        [[NSFileManager defaultManager] createFileAtPath:strPath contents:data attributes:nil];
                        
                    }
                
                
            }

            return 70;
        }
        else
        {
            UITableViewCell *cell = nil;
            if ([[defaults objectForKey:kUserId] isEqualToString:[dictRow objectForKey:kUserId]])
            {
                cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"ChatCell" owner:self options:nil] objectAtIndex:2];
            }
            else
            {
                cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"ChatCell" owner:self options:nil] objectAtIndex:3];
            }
            NSURL *url = [NSURL URLWithString:[[dictRow objectForKey:kMessageSmall] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            if ([[UIApplication sharedApplication] canOpenURL:url] && (![[dictRow objectForKey:kMessageSmall] containsString:@"localhost"] ) )
            {
                                    NSString *url = [dictRow objectForKey:kMessageSmall];
                    NSArray *arrComponents = [url componentsSeparatedByString:@"/"];
                    NSString *imageName = [arrComponents lastObject];
                    
                    if ([[[dictRow objectForKey:kMessageSmall] pathExtension] isEqualToString:@"gif"])
                    {
                        if ([[dictRow objectForKey:kMessageSmall] containsString:@"giphy.com"])
                        {
                            imageName=[NSString stringWithFormat:@"%@_%@",[arrComponents objectAtIndex:(arrComponents.count-2)],imageName];
                        }
                    }
                    
                    
                    
                    NSString *path = [Utils getPathForFolderPath:@"Attachment" withFileName:imageName];
                    UIImage *image = [UIImage imageWithContentsOfFile:path];
                    if (image)
                    {
                        
                        image = [image resizedImageByWidth:233];
                        return image.size.height + 40;
                    }

            
            
            }
            else
            {
                NSString *imgName;
                if ([[defaults objectForKey:kUserId] isEqualToString:[dictRow objectForKey:kUserId]])
                {
                    imgName=@"chatDefualt1.png";
                }
                else
                {
                    imgName=@"chatDefualt2.png";
                }
                
                UIImage *image=[UIImage imageNamed:imgName];
                
                 return image.size.height + 40;
            }
            return 65;

        }
        
    }
    else
    {
        UITableViewCell *cell = nil;
        if ([[defaults objectForKey:kUserId] isEqualToString:[dictRow objectForKey:kUserId]])
        {
            cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"ChatCell" owner:self options:nil] objectAtIndex:0];
        }
        else
        {
            cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"ChatCell" owner:self options:nil] objectAtIndex:1];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *lblChatText = (UILabel *)[cell.contentView viewWithTag:TagChatText];
        
        [lblChatText setText:[dictRow objectForKey:kMessageSmall]];
        [lblChatText sizeToFit];
        
        
        
        CGFloat heightCell = lblChatText.height + 40;
        cell = nil;
        return  heightCell>65?heightCell:65;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dictRow = [arrChatHistory objectAtIndex:indexPath.row];
    
    if ([[dictRow objectForKey:kMessageType] isEqualToString:@"2"])
    {
        
        if (!([[[dictRow objectForKey:kMessageSmall] pathExtension] isEqualToString:@"jpg"] || [[[dictRow objectForKey:kMessageSmall] pathExtension] isEqualToString:@"png"] | [[[dictRow objectForKey:kMessageSmall] pathExtension] isEqualToString:@"gif"]))
        {
            UITableViewCell *cell = nil;
            if ([[defaults objectForKey:kUserId] isEqualToString:[dictRow objectForKey:kUserId]])
            {
                cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"ChatCell" owner:self options:nil] objectAtIndex:5];
            }
            else
            {
                cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"ChatCell" owner:self options:nil] objectAtIndex:4];
            }
            
            
            if (isMultiSelect)
            {
                if ([SeletedArry containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]])
                {
                    cell.backgroundColor=[UIColor colorWithRed:153/255.0f green:204/255.0f blue:255/255.0f alpha:0.5];
                }
                else
                {
                    cell.backgroundColor=[UIColor whiteColor];
                }
            }
            else
            {
                cell.backgroundColor=[UIColor whiteColor];
            }

            
            UILabel *lblExtension = (UILabel *)[cell.contentView viewWithTag:21];
            lblExtension.layer.cornerRadius=5.0;
            lblExtension.clipsToBounds=YES;
            lblExtension.text=[[dictRow objectForKey:kMessageSmall] pathExtension];
            
            NSString *url = [dictRow objectForKey:kMessageSmall];
            NSArray *arrComponents = [url componentsSeparatedByString:@"/"];
            NSString *filename = [arrComponents lastObject];
            
            
            
            NSMutableArray *arrcom=[[NSMutableArray alloc] initWithArray:[filename componentsSeparatedByString:@"_"]];
            [arrcom removeLastObject];
            filename=[arrcom componentsJoinedByString:@"_"];
            
            NSString *path = [Utils getPathForFolderPath:@"Attachment" withFileName:[arrComponents lastObject]];
            
                        
           
            
           UILabel *lblFileName = (UILabel *)[cell.contentView viewWithTag:22];
            lblFileName.text=filename;
            
             UILabel *lblFilSize = (UILabel *)[cell.contentView viewWithTag:23];
            unsigned long long fileSize1 = [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
            lblFilSize.text=[self transformedValue:[NSString stringWithFormat:@"%llu",fileSize1]];
            
            UILabel *lblTime = (UILabel *)[cell.contentView viewWithTag:TagTime];
            
            [lblTime setText:[self timeAgo:[dictRow objectForKey:@"createdDate"]]];
            
            UIImageView *imgProfile = (UIImageView *)[cell.contentView viewWithTag:TagImage];

            if (![[defaults objectForKey:kUserId] isEqualToString:[dictRow objectForKey:kUserId]])
            {
                [imgProfile setImageWithURL:[NSURL URLWithString:[dictRow objectForKey:kProfileImage]] placeholderImage:[UIImage imageNamed:@"appicon.png"]];
                [imgProfile.layer setCornerRadius:20];
                [imgProfile setClipsToBounds:YES];
            }

            
            return cell;

        }
        else
        {
            UITableViewCell *cell = nil;
            if ([[defaults objectForKey:kUserId] isEqualToString:[dictRow objectForKey:kUserId]])
            {
                cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"ChatCell" owner:self options:nil] objectAtIndex:3];
            }
            else
            {
                cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"ChatCell" owner:self options:nil] objectAtIndex:2];
            }
            
            if (isMultiSelect)
            {
                if ([SeletedArry containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]])
                {
                    cell.backgroundColor=[UIColor colorWithRed:153/255.0f green:204/255.0f blue:255/255.0f alpha:0.5];
                }
                else
                {
                    cell.backgroundColor=[UIColor whiteColor];
                }
            }
            else
            {
                cell.backgroundColor=[UIColor whiteColor];
            }

            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UIImageView *imgBubble = (UIImageView *)[cell.contentView viewWithTag:TagChatBubble];
            
            UIActivityIndicatorView *actView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20,20)];
            actView.center = imgBubble.center;
            [actView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
            [cell.contentView addSubview:actView];
            [actView startAnimating];
            
            UIImageView *imgProfile = (UIImageView *)[cell.contentView viewWithTag:TagImage];
            
            UIImageView *imgChatImage = (UIImageView *)[cell.contentView viewWithTag:TagPostedImage];
            
            //[imgChatImage setImageWithURL:[NSURL URLWithString:[dictRow objectForKey:kMessageSmall]] placeholderImage:[UIImage imageNamed:@"appicon.png"]];
            NSURL *url = [NSURL URLWithString:[[dictRow objectForKey:kMessageSmall] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
             if ([[UIApplication sharedApplication] canOpenURL:url] && (![[dictRow objectForKey:kMessageSmall] containsString:@"localhost"] ) )
            {
                
                    [Utils getDownloadImageForURL:[dictRow objectForKey:kMessageSmall] completion:^(UIImage *image, BOOL alreadyDownloaded, NSString *filePath)
                     {
                         [actView startAnimating];
                         [actView removeFromSuperview];
                         NSLog(@"loaded");
                         image = [image resizedImageByWidth:233];
                         NSData *imageData = [NSData dataWithContentsOfFile:filePath];
                         [imgChatImage setImage:[UIImage animatedImageWithAnimatedGIFData:imageData]];
                         [imgBubble setHidden:NO];
                         [imgChatImage setHeight:image.size.height];
                         [imgBubble setHeight:imgChatImage.height+10];
                         [imgBubble setImage:[imgBubble.image resizableImageWithCapInsets:UIEdgeInsetsMake(30, 10, 10, 10) resizingMode:UIImageResizingModeStretch]];
                         
                         if ([[defaults objectForKey:kUserId] isEqualToString:[dictRow objectForKey:kUserId]])
                         {
                             imgChatImage.xOrigin = imgChatImage.xOrigin - 1;
                         }
                         else
                         {
                             imgChatImage.xOrigin = imgChatImage.xOrigin + 1;
                         }
                         if (!alreadyDownloaded)
                         {
                             [self.tblChat reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                         }
                         if ((arrChatHistory.count-1)==indexPath.row)
                         {
                             [self.tblChat selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
                         }
                     }];
 
                
                
            }
            else
            {
                [actView startAnimating];
                [actView removeFromSuperview];
                NSString *imgName;
                if ([[defaults objectForKey:kUserId] isEqualToString:[dictRow objectForKey:kUserId]])
                {
                    imgName=@"chatDefualt1.png";
                }
                else
                {
                    imgName=@"chatDefualt2.png";
                }
                
                UIImage *image=[UIImage imageNamed:imgName];
                [imgChatImage setImage:image];
                [imgBubble setHidden:NO];
                [imgChatImage setHeight:image.size.height];
                [imgBubble setHeight:imgChatImage.height+10];
                [imgBubble setImage:[imgBubble.image resizableImageWithCapInsets:UIEdgeInsetsMake(30, 10, 10, 10) resizingMode:UIImageResizingModeStretch]];
                
                if ([[defaults objectForKey:kUserId] isEqualToString:[dictRow objectForKey:kUserId]])
                {
                    imgChatImage.xOrigin = imgChatImage.xOrigin - 1;
                }
                else
                {
                    imgChatImage.xOrigin = imgChatImage.xOrigin + 1;
                }
 
            }
            
            
            
            
            UILabel *lblTime = (UILabel *)[cell.contentView viewWithTag:TagTime];
            
            lblTime.textColor=[UIColor grayColor];
            [lblTime setText:[self timeAgo:[dictRow objectForKey:@"createdDate"]]];
            
            [lblTime setYOrigin:imgBubble.yOrigin+imgBubble.height+2];
            
            if (![[defaults objectForKey:kUserId] isEqualToString:[dictRow objectForKey:kUserId]])
            {
                [imgProfile setImageWithURL:[NSURL URLWithString:[dictRow objectForKey:kProfileImage]] placeholderImage:[UIImage imageNamed:@"appicon.png"]];
                [imgProfile.layer setCornerRadius:20];
                [imgProfile setClipsToBounds:YES];
            }
            
            
            return cell;
 
        }
    }
    else
    {
        
        
        UITableViewCell *cell = nil;
        if ([[defaults objectForKey:kUserId] isEqualToString:[dictRow objectForKey:kUserId]])
        {
            cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"ChatCell" owner:self options:nil] objectAtIndex:1];
        }
        else
        {
            cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"ChatCell" owner:self options:nil] objectAtIndex:0];
        }
        
        if (isMultiSelect)
        {
            if ([SeletedArry containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]])
            {
                cell.backgroundColor=[UIColor colorWithRed:153/255.0f green:204/255.0f blue:255/255.0f alpha:0.5];
            }
            else
            {
                cell.backgroundColor=[UIColor whiteColor];
            }
        }
        else
        {
            cell.backgroundColor=[UIColor whiteColor];
        }

        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *imgBubble = (UIImageView *)[cell.contentView viewWithTag:TagChatBubble];
        
        UILabel *lblChatText = (UILabel *)[cell.contentView viewWithTag:TagChatText];
        
         UILabel *lblTime = (UILabel *)[cell.contentView viewWithTag:TagTime];
        
        [lblChatText setText:[dictRow objectForKey:kMessageSmall]];
        [lblChatText sizeToFit];
        
        [imgBubble setHeight:(lblChatText.height+10)>33?(lblChatText.height+10):33];
       
        
        if ([[defaults objectForKey:kUserId] isEqualToString:[dictRow objectForKey:kUserId]])
        {
            
            
            [imgBubble setWidth:lblChatText.width+24];
            [imgBubble setXOrigin:(cell.width-15)-imgBubble.frame.size.width];
            [lblChatText setXOrigin:imgBubble.frame.origin.x+12];
        }
        else
        {
            UIImageView *imgProfile = (UIImageView *)[cell.contentView viewWithTag:TagImage];
            [imgProfile setImageWithURL:[NSURL URLWithString:[dictRow objectForKey:kProfileImage]] placeholderImage:[UIImage imageNamed:@"appicon.png"]];
            [imgProfile.layer setCornerRadius:20];
            [imgProfile setClipsToBounds:YES];

            [imgBubble setWidth:lblChatText.width+24];
        }
      
        [imgBubble setImage:[imgBubble.image resizableImageWithCapInsets:UIEdgeInsetsMake(30, 10, 10, 10) resizingMode:UIImageResizingModeStretch]];
        
        
        lblTime.textColor=[UIColor grayColor];
        [lblTime setText:[self timeAgo:[dictRow objectForKey:@"createdDate"]]];
        [lblTime setYOrigin:imgBubble.yOrigin+imgBubble.height+2];
        NSLog(@"tim:%@",[self timeAgo:[dictRow objectForKey:@"createdDate"]]);
        
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isMultiSelect)
    {
        UITableViewCell *cell = [self.tblChat cellForRowAtIndexPath:indexPath];
        if ([SeletedArry containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]])
        {
            cell.backgroundColor=[UIColor whiteColor];
            [SeletedArry removeObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
            count=count-1;
            _lblCountDelete.text=[NSString stringWithFormat:@"%d",count];
            
            if (SeletedArry.count==0)
            {
                isMultiSelect=NO;
                _navigationView.alpha=1.0;
                _deleteView.alpha=0.0;
                count=0;
            }
        }
        else
        {
            
            cell.backgroundColor=[UIColor colorWithRed:153/255.0f green:204/255.0f blue:255/255.0f alpha:0.5];
            [SeletedArry addObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
            count=count+1;
            _lblCountDelete.text=[NSString stringWithFormat:@"%d",count];

        }
        
    }
    else
    {
        
        dictSelected= [arrChatHistory objectAtIndex:indexPath.row];
        
        if ([[dictSelected objectForKey:kMessageType] isEqualToString:@"2"])
        {
            NSURL *url = [NSURL URLWithString:[[dictSelected objectForKey:kMessageSmall] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
             if ([[UIApplication sharedApplication] canOpenURL:url] && (![[dictSelected objectForKey:kMessageSmall] containsString:@"localhost"] ) )
            {
               
                    QLPreviewController *previewController = [[QLPreviewController alloc] init];
                    
                    previewController.dataSource = self;
                    previewController.delegate = self;
                    
                    [self presentViewController:previewController animated:YES completion:nil];

                
            }
        }

    }
  
}

- (id)transformedValue:(id)value
{
    
    double convertedValue = [value doubleValue];
    int multiplyFactor = 0;
    
    NSArray *tokens = [NSArray arrayWithObjects:@"bytes",@"KB",@"MB",@"GB",@"TB",nil];
    
    while (convertedValue > 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    
    return [NSString stringWithFormat:@"%4.2f %@",convertedValue, [tokens objectAtIndex:multiplyFactor]];
}
- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller
{
    return 1;
}
- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    
    NSString *url = [dictSelected objectForKey:kMessageSmall];
    NSArray *arrComponents = [url componentsSeparatedByString:@"/"];
    NSString *imageName = [arrComponents lastObject];
    if ([[[dictSelected objectForKey:kMessageSmall] pathExtension] isEqualToString:@"gif"])
    {
        if ([[dictSelected objectForKey:kMessageSmall] containsString:@"giphy.com"])
        {
            imageName=[NSString stringWithFormat:@"%@_%@",[arrComponents objectAtIndex:(arrComponents.count-2)],imageName];
        }
    }

    NSString *path = [Utils getPathForFolderPath:@"Attachment" withFileName:imageName];

    
    return [NSURL fileURLWithPath:path];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"%f",scrollView.contentOffset.y);
}
#pragma mark - textfield

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    

}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}
- (void)resignTextFields
{
    if (!isTextField)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.4];
        [self.view setTransform:CGAffineTransformIdentity];
        [UIView commitAnimations];
    }
}



#pragma mark - webservices

- (void)callAPIUploadImage:(UIImage*)imageToUpload
{
    NSDictionary *dictSend = [[NSDictionary alloc] init];
    
    [Utils startLoaderWithMessage:@""];
    
    [Connection callServiceWithImages:[[NSArray arrayWithObjects:imageToUpload, nil] mutableCopy] params:dictSend serviceIdentifier:kSaveChatImage callBackBlock:^(id response, NSError *error)
     {
         [Utils stopLoader];
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 NSLog(@"res:%@",response);
                 NSDictionary *dictSend = @{
                                            kFromId:[defaults objectForKey:kUserId],
                                            kToId:[_dictBuddyInfo objectForKey:kBuddyId],
                                            @"isGroup":(_isGroup?@"1":@"0"),
                                            @"messageType":@"2",
                                            @"deviceTimeStamp":[@([Utils getCurrentTimeStamp]) stringValue],
                                            @"message":[response objectForKey:kResult]
                                            };
                 [[MyWebSocket sharedInstance] SendMessage:dictSend];
                 
                 //    NSLog(@"tuime:%@",[Utils getLocalTimeFromUtc:[[arrChatHistory lastObject] objectForKey:kCreatedDate] inFormat:@"MM/dd/yyyy hh:mm:ss a"]);
                 
                 NSDate *dateNow = [Utils getUTCTime];
                 NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                 [formatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
                 NSString *strDate = [formatter stringFromDate:dateNow];
                 
                 NSString *timeAgo = [Utils timeAgo:strDate withFormat:@"MM/dd/yyyy hh:mm:ss a"];
                 
                 NSString *profilePict = [[NSUserDefaults standardUserDefaults] objectForKey:@"profilePicture"];
                 
                 NSDictionary *dictAddToChat = @{kCreatedDateChat:strDate,
                                                 @"profileImage":profilePict,
                                                 kProfileImage:@"",
                                                 kUserId:[defaults objectForKey:kUserId],
                                                 kMessageSmall:[response objectForKey:kResult],
                                                 kChatId:@"",
                                                 @"messageType":@"2",
                                                 kUserName:@"amani",
                                                 @"timeAgo":timeAgo,
                                                 kIsGroup:_isGroup?@"1":@"0"
                                                 };
                 
                 [arrChatHistory addObject:dictAddToChat];
                 
                 [_tblChat reloadData];
                 NSIndexPath *myIndexPath = [NSIndexPath indexPathForRow:arrChatHistory.count-1 inSection:0];
                 [self.tblChat selectRowAtIndexPath:myIndexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
                 
             }
         }
     }];
}

- (void)callAPIGetChatHistory:(BOOL)isLoad
{
    NSDictionary *dictSend = @{kUserId:[defaults objectForKey:kUserId],kPage:@"0",kGroupId:[_dictBuddyInfo objectForKey:kBuddyId],kIsGroup:_isGroup?@"True":@"False"};
    
    [Utils startLoaderWithMessage:@""];
    
    [Connection callServiceWithName:kGetChatHistory postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         [Utils stopLoader];
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 isServiceLoaded = YES;
                 arrChatHistory = Nil;
                 arrChatHistory = [[NSMutableArray alloc] init];//WithArray:[response objectForKeyNonNull:kResult]];
                 for (NSInteger i = ([[response objectForKeyNonNull:kResult] count]-1); i>=0; i--)
                 {
                     [arrChatHistory addObject:[[response objectForKeyNonNull:kResult] objectAtIndex:i]];
                 }
                 [_tblChat reloadData];
                 if (arrChatHistory.count > 0)
                 {
                     NSIndexPath *myIndexPath = [NSIndexPath indexPathForRow:arrChatHistory.count-1 inSection:0];
                     [self.tblChat selectRowAtIndexPath:myIndexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
                     
                 }
                 if (isLoad)
                 {
                     if (_isGroup)
                     {
                         
                         if ([[_dictBuddyInfo  valueForKey:@"isleft"] boolValue])
                         {
                             UIAlertView *alrt=[[UIAlertView alloc] initWithTitle:@"Studebuddies" message:@"Welcome Back!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Join", nil];
                             [alrt show];
                             
                         }
                         
                     }

                     
                 }

             }
         }
     }];
}
- (void)LeftClassGroupUser
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
                              [_dictBuddyInfo objectForKey:@"groupId"],@"classid",
                              @"False",@"isLeft",
                              nil];
    
    [Utils startLoaderWithMessage:@""];
    
    
    
    [Connection callServiceWithName:kLeftClassGroupUser postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         
         [Utils stopLoader];
         
         
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 _viewChatBar.hidden=NO;
                 _lblHideChat.hidden=YES;
                 isLeft=NO;
             }
         }
         
     }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1)
    {
        [self LeftClassGroupUser];
    }
}
#pragma mark - button action
- (IBAction)btnBackTapped:(UIButton *)sender
{
    NSInteger flag = 0;
    for (UIViewController *viewC in self.navigationController.viewControllers)
    {
        if ([viewC isKindOfClass:[MessagesViewController class]])
        {
            flag = 1;
            [self.navigationController popToViewController:viewC animated:YES];
        }
    }
    if (flag == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)btnAddImageTapped:(UIButton *)sender
{
}

- (IBAction)btnSendTapped:(UIButton *)sender
{
    if (![self isInternetAvailable])
    {
        [Utils showAlertViewWithMessage:@"Check your internet connection"];
        return;
    }
    if (![_txtFieldUserInput.text isEqualToString:@""] && [_txtFieldUserInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
    {
        NSDictionary *dictSend = @{
                                   kFromId:[defaults objectForKey:kUserId],
                                   kToId:[_dictBuddyInfo objectForKey:kBuddyId],
                                   @"isGroup":(_isGroup?@"1":@"0"),
                                   @"messageType":@"1",
                                   @"deviceTimeStamp":[@([Utils getCurrentTimeStamp]) stringValue],
                                   @"message":_txtFieldUserInput.text
                                   };
        [[MyWebSocket sharedInstance] SendMessage:dictSend];
        
        //    NSLog(@"tuime:%@",[Utils getLocalTimeFromUtc:[[arrChatHistory lastObject] objectForKey:kCreatedDate] inFormat:@"MM/dd/yyyy hh:mm:ss a"]);
        
        
        NSDate *dateNow = [Utils getUTCTime];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
        NSString *strDate = [formatter stringFromDate:dateNow];
        
        NSString *timeAgo = [Utils timeAgo:strDate withFormat:@"MM/dd/yyyy hh:mm:ss a"];
        
        NSString *profilePict = [[NSUserDefaults standardUserDefaults] objectForKey:@"profilePicture"];
        NSDictionary *dictAddToChat = @{kCreatedDateChat:strDate,
                                        @"profileImage":profilePict,
                                        kProfileImage:@"",
                                        kUserId:[defaults objectForKey:kUserId],
                                        kMessageSmall:_txtFieldUserInput.text,
                                        kChatId:@"",
                                        @"messageType":@"1",
                                        kUserName:@"amani",
                                        @"timeAgo":timeAgo,
                                        kIsGroup:_isGroup?@"1":@"0"
                                        };
        
        [arrChatHistory addObject:dictAddToChat];
        
        _txtFieldUserInput.text = @"";
        
        [_tblChat reloadData];
        NSIndexPath *myIndexPath = [NSIndexPath indexPathForRow:arrChatHistory.count-1 inSection:0];
        [self.tblChat selectRowAtIndexPath:myIndexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
        
    }
    
    
}

- (IBAction)btnAttachmentTapped:(UIButton *)sender
{
    [self.view endEditing:YES];
    
    [self performSelector:@selector(openActionSheet) withObject:nil afterDelay:0.2];
    
}
- (IBAction)btnGIFTapped:(id)sender
{
    GifDisplayViewController *gifDisplayVC=[[GifDisplayViewController alloc] init];
    
    
//    _tblChat.height=self.view.height-(64+_viewGIF.height);
//    _viewChatBar.alpha=0.0;
//    _viewGIF.alpha=1;
//    [_viewGIF addSubview:gifDisplayVC.view];
  
    navController=[[UINavigationController alloc] initWithRootViewController:gifDisplayVC];
    navController.navigationBarHidden=YES;
    [self presentViewController:navController animated:YES completion:nil];

}

- (IBAction)btnChatNameTapped:(id)sender
{
    
   // NSLog(@"%@",_dictBuddyInfo);
    if ([[_dictBuddyInfo objectForKey:kIsGroup] boolValue] == NO)
    {
        ViewProfileViewController * viewProfile = [[ViewProfileViewController alloc]initWithNibName:@"ViewProfileViewController" bundle:nil];
        viewProfile.isViewProfile = YES;
        
        viewProfile.editProfile = YES;
        viewProfile.inviteButtonHidden = YES;
        [viewProfile setBuddyId:[_dictBuddyInfo objectForKeyNonNull:kBuddyId]];
        [self.navigationController pushViewController:viewProfile animated:YES];
    }
    else
    {
         GroupMemberListViewController * groupMemberListVC = [[GroupMemberListViewController alloc]initWithNibName:@"GroupMemberListViewController" bundle:nil];
        groupMemberListVC.dictMembers=[[NSMutableDictionary alloc] initWithDictionary:_dictBuddyInfo];
        [groupMemberListVC setIsLeft:isLeft];
        [groupMemberListVC setIsMute:isMute];
        [groupMemberListVC setIsClass:_isClass];
        [self.navigationController pushViewController:groupMemberListVC animated:YES];
    }
}

- (IBAction)btnCancelDeleteTapped:(id)sender
{
    isMultiSelect=NO;
    _navigationView.alpha=1.0;
    _deleteView.alpha=0.0;
    [SeletedArry removeAllObjects];
    count=0;
    [_tblChat reloadData];
 
}

- (IBAction)btnDeleteMessageTapped:(id)sender
{
    
}

- (IBAction)btnRejoinTapped:(id)sender
{
    [[Utils sharedInstance] showActionSheetWithTitle:@"" buttonArray:@[@"Rejoin"]     selectedButton:^(NSInteger selected)
     {
         
         if (selected==0)
         {
             
             [self LeftClassGroupUser];

         }
     }];

   
}

-(BOOL)isInternetAvailable
{
    self.internetReachability = [Reachability reachabilityForInternetConnection];
	[self.internetReachability startNotifier];
    
    NetworkStatus netStatus = [self.internetReachability currentReachabilityStatus];
    BOOL connectionRequired = [self.internetReachability connectionRequired];
    
    if (netStatus != NotReachable) {
        return YES;
    }
    
    return NO;
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
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    
    if ([info valueForKey:UIImagePickerControllerReferenceURL])
    {
        ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
        [assetLibrary assetForURL:[info valueForKey:UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            Byte *buffer = (Byte*)malloc(rep.size);
            NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
            NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];//this is NSData may be what you want
            UIImage *image = [UIImage imageWithData:data];
            
            
            [self callAPIUploadImage:image];
            
        }failureBlock:^(NSError *err)
         {
             NSLog(@"Error: %@",[err localizedDescription]);
         }];
    }
    
    else
    {
        UIImage *image = (UIImage*)[info objectForKeyNonNull:UIImagePickerControllerOriginalImage];
        
        [self callAPIUploadImage:image];
    }
    
}
- (void)openActionSheet
{
    [[Utils sharedInstance] showActionSheetWithTitle:@"" buttonArray:@[@"Camera",@"Photo Library",@"Dropbox",@"Google Drive"]     selectedButton:^(NSInteger selected)
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
             case 2:
             {
                 DropBoxViewController *vcDropBox = [[DropBoxViewController alloc] initWithNibName:@"DropBoxViewController" bundle:nil];
                 navController=[[UINavigationController alloc] initWithRootViewController:vcDropBox];
                 navController.navigationBarHidden=YES;
                 [self presentViewController:navController animated:YES completion:nil];
                              }
             case 3:
             {
                 GoogleDriveViewController *vcGoogleDrive = [[GoogleDriveViewController alloc] initWithNibName:@"GoogleDriveViewController" bundle:nil];
                 navController=[[UINavigationController alloc] initWithRootViewController:vcGoogleDrive];
                 navController.navigationBarHidden=YES;
                 [self presentViewController:navController animated:YES completion:nil];
             }
                 break;
             default:
                 break;
         }
     }];
}

@end
