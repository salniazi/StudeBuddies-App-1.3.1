//
//  AddContactFriendsViewController.m
//  TedBuddies
//
//  Created by Mayank Pahuja on 17/11/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import "AddContactFriendsViewController.h"
#import "ViewProfileViewController.h"
#import "PendingRequestsViewController.h"
#import "ChatScreenViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "HMSegmentedControl.h"

@interface AddContactFriendsViewController ()<MFMessageComposeViewControllerDelegate>
{
    BOOL isRegisteredUser;
    NSMutableArray *arraySelectedIndexes;
     NSInteger selectedSegment;
}
@end

@implementation AddContactFriendsViewController

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
    // Do any additional setup after loading the view from its nib.
    
    arrayBuddies = [[NSMutableArray alloc] init];
    arrayTempBuddies = [[NSMutableArray alloc] init];
    arrayBuddiesResponse = [[NSMutableArray alloc] init];
    arraySelectedIndexes = [[NSMutableArray alloc] init];
   
    [self setFonts];
   //  [self callAPIFindBuddies];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tabBarController.tabBar setHidden:NO];
    //[self setFonts];
}

- (void)setFonts
{
    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"Registered User", @"New User"]];
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

    
    isRegisteredUser = YES;
    _btnNewUsers.selected = NO;
    _btnRegisteredUsers.selected = YES;
    [self callAPIFindBuddies];
    
    UISwipeGestureRecognizer *backSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backSwipeAction)];
    [backSwipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:backSwipe];
    
    [_lblNavBar setFont:FONT_REGULAR(kNavigationFontSize)];
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl
{
    
    selectedSegment=segmentedControl.selectedSegmentIndex;
    
    if (selectedSegment==0)
    {
        isRegisteredUser = YES;
        _btnNewUsers.selected = NO;
        _btnRegisteredUsers.selected = YES;
        [self callAPIFindBuddies];
        
    }
    else if (selectedSegment==1)
        
    {
        isRegisteredUser = NO;
        _btnNewUsers.selected = YES;
        _btnRegisteredUsers.selected = NO;
        [self callAPIFindBuddies];
    }
}

#pragma mark - gesture recognizer action

- (void)backSwipeAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - web service
//ContactInvite

- (void)callAPIContactInviteToBuddy:(NSString*)emailId
{
    
    NSDictionary *dictEmail = [NSDictionary dictionaryWithObjectsAndKeys:emailId,@"email",@"",kName, nil];
    
    NSArray *arrayEmail = [[NSArray alloc]initWithObjects:dictEmail, nil];
    
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
                              arrayEmail,@"listUser",
                              nil];
    
    [Utils startLoaderWithMessage:@""];
    
    [Connection callServiceWithName:kContactInvite postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         [Utils stopLoader];
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 //NSString *message=[NSString stringWithFormat:@"%@",[response objectForKeyNonNull:kMessage]];
                 
                 [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"Invitation Send Successfully." buttonArray:@[@"OK"] selectedButton:^(NSInteger selected, UIAlertView *aView)
                  {
                      [self callAPIFindBuddies];
                  }];
                 
             }
         }
     }];
    
}


- (void)callAPISendInviteToBuddy:(NSString*)buddyId
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
                              buddyId,kBuddyId,
                              nil];
    
    [Utils startLoaderWithMessage:@""];
    
    [Connection callServiceWithName:KSendInvitaion postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         [Utils stopLoader];
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 
                 
                 NSString *message=[NSString stringWithFormat:@"%@",[response objectForKeyNonNull:kMessage]];
                 [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:message buttonArray:@[@"OK"] selectedButton:^(NSInteger selected, UIAlertView *aView)
                  {
                      [self callAPIFindBuddies];
                      [_tableView reloadData];
                  }];
             }
         }
     }];
    
}


- (void)callAPIFindBuddies
{
    [self fetchAddressBook:^(NSMutableArray *array)
     {
         
         if (array.count > 0)
         {
             NSMutableArray *arrSendRequest = [[NSMutableArray alloc] init];
             
             for (int i=0; i<array.count; i++)
             {
                 if (![[[array objectAtIndex:i] valueForKey:@"email"] isEqualToString:@""])
                 {
                     [arrSendRequest addObject:@{@"facebookId":@"",@"emailId":[[array objectAtIndex:i] valueForKey:@"email"]}];
                 }
                 
             }
             
             [arrayTempBuddies removeAllObjects];
             [arrayTempBuddies addObjectsFromArray:arrSendRequest];
             
             
             NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [defaults objectForKey:kUserId],kUserId,
                                       arrSendRequest,kContactList,
                                       @"2",kSyncingType,
                                       nil];
             [Utils startLoaderWithMessage:@""];
             [Connection callServiceWithName:kGetContactSyncing postData:dictSend callBackBlock:^(id response, NSError *error)
              {
                  [Utils stopLoader];
                  if (response)
                  {
                      if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
                      {
                          
                          NSArray *arr = [[NSArray alloc]initWithArray:[response objectForKeyNonNull:kResult]];
                          [arrayBuddiesResponse removeAllObjects];
                          
                          [arrayBuddiesResponse addObjectsFromArray:arr];

                          if (isRegisteredUser)
                          {
                              
                              [arrayBuddies removeAllObjects];
                              for (NSDictionary *dictReceived in arr)
                              {
                                  if (([[dictReceived objectForKey:kIsBuddy] integerValue] == kStatusNotFriend) && (![[dictReceived objectForKey:kBuddyId] isEqualToString:[defaults objectForKey:kUserId]]))
                                  {
                                      [arrayBuddies addObject:dictReceived];
                                  }
                              }
                              
                              if ([arrayBuddies count] == 0) {
                                  [Utils showAlertViewWithMessage:@"No registered users Yet!!"];
                              }
                              
                        }
                          else
                          {
                              
                              [arrayBuddies removeAllObjects];
                              for (NSDictionary *dictFetchContact in array)
                              {
                                  if ([[dictFetchContact objectForKeyNonNull:@"email"] isEqualToString:@""])
                                  {
                                      if (_isText)
                                      {
                                          [arrayBuddies addObject:dictFetchContact];
                                      }
                                      
                                  }
                                  else
                                  {
                                      NSString *email  = [dictFetchContact objectForKeyNonNull:@"email"];
                                      // NSString *imgname = [[NSString alloc] init];
                                      NSPredicate *prdicate = [NSPredicate predicateWithFormat:@"buddyEmail = %@",email];
                                      NSArray *tempArray = [arrayBuddiesResponse filteredArrayUsingPredicate:prdicate];
                                      if (tempArray.count > 0)
                                      {
                                          
                                          NSDictionary *dict = [tempArray objectAtIndex:0];
                                          NSLog(@"Change here %@",dict);
                                          
                                      } else
                                      {
                                          //dictFetchContact
                                          if (_isText)
                                          {
                                              if (![[dictFetchContact objectForKeyNonNull:@"number"] isEqualToString:@""])
                                              {
                                                  [arrayBuddies addObject:dictFetchContact];
                                              }
                                              
                                          }
                                          else
                                          {
                                              [arrayBuddies addObject:dictFetchContact];
                                          }
                                          
                                          
                                      }

                                  }
                                  
                              }
                              if ([arrayBuddies count] == 0) {
                                  [Utils showAlertViewWithMessage:@"No new users Yet!!"];
                              }
                          }
                          
                          
                          [_tableView reloadData];
                      }
                  }
              }];
         }
         else
         {
             [Utils showAlertViewWithMessage:@"Kindly Allow contact permission to StudeBudiies from settings menu"];
         }
         
     }];
}
- (void)fetchAddressBook:(void(^)(NSMutableArray *array))completion
{
    CFErrorRef *error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    
    __block BOOL accessGranted = NO;
    if (ABAddressBookRequestAccessWithCompletion != NULL)
    { // we're on iOS 6
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error)
                                                 {
                                                     accessGranted = granted;
                                                     dispatch_semaphore_signal(sema);
                                                 });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    }
    else
    { // we're on iOS 5 or older
        accessGranted = YES;
    }
    
    if (accessGranted)
    {
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            //Do your background task here
            
            NSMutableArray *allContacts = [NSMutableArray array];
            
            DLog(@"Fetching contact info ----> ");
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
            CFArrayRef people  = ABAddressBookCopyArrayOfAllPeople(addressBook);
            for(int i = 0;i<ABAddressBookGetPersonCount(addressBook);i++)
            {
                ABRecordRef ref = CFArrayGetValueAtIndex(people, i);
                // collect email
                ABMultiValueRef email = ABRecordCopyValue(ref, kABPersonEmailProperty);
                ABMultiValueRef number= ABRecordCopyValue(ref, kABPersonPhoneProperty);
                ABMultiValueRef fName= ABRecordCopyValue(ref, kABPersonFirstNameProperty);
                ABMultiValueRef lName= ABRecordCopyValue(ref, kABPersonLastNameProperty);
                
                if (ABMultiValueGetCount(email) > 0 || ABMultiValueGetCount(number) > 0)
                {
                    NSMutableDictionary *dicContact=[[NSMutableDictionary alloc] init];
                    if (ABMultiValueGetCount(email) > 0)
                    {
                        NSString *emailAddress = (__bridge NSString *) ABMultiValueCopyValueAtIndex(email, 0);
                        [dicContact setObject:emailAddress forKey:@"email"];

                    }
                    else
                    {
                        [dicContact setObject:@"" forKey:@"email"];
                    }
                    if (ABMultiValueGetCount(number) > 0)
                    {
                        NSString *phoneNumber = (__bridge NSString *) ABMultiValueCopyValueAtIndex(number, 0);
                        [dicContact setObject:phoneNumber forKey:@"number"];
                        
                    }
                    else
                    {
                        [dicContact setObject:@"" forKey:@"number"];
                    }
                   
                    NSString *firstName = (__bridge NSString *) fName;
                    NSString *lastName = (__bridge NSString *)lName;
                    NSString *name=[NSString stringWithFormat:@"%@ %@",firstName?firstName:@"",lastName?lastName:@""];
                    if ([name isEqualToString:@" "])
                    {
                        [dicContact setObject:@"" forKey:@"name"];
                    }
                    else
                    {
                        [dicContact setObject:name forKey:@"name"];
                    }
                    
                        
                   

                    [allContacts addObject:dicContact];
                }
                
                CFRelease(email);
                
                // if you want to collect any other info that's stored in the address book, it follows the same pattern.
                // you just need the right kABPerson.... property.
            }
            
            CFRelease(addressBook);
            CFRelease(people);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                completion(allContacts);
                
            });
        });
    }
    else
    {
        DLog(@"Cannot fetch Contacts :( ");
        completion(NO);
    }
}

#pragma mark - button action

- (IBAction)btnBackTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnRegisteredUsersTapped:(UIButton *)sender {
    isRegisteredUser = YES;
    _btnNewUsers.selected = NO;
    _btnRegisteredUsers.selected = YES;
    [self callAPIFindBuddies];
    
}

- (IBAction)btnNewUsersTapped:(UIButton *)sender {
    
    isRegisteredUser = NO;
    _btnNewUsers.selected = YES;
    _btnRegisteredUsers.selected = NO;
    [self callAPIFindBuddies];
}

- (void)btnMessageFindTapped:(UIButton*)sender withEvent:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint: currentTouchPosition];
    NSDictionary *dictBuddyDetails = @{kBuddyId: [[arrayBuddies objectAtIndex:indexPath.row] objectForKey:kBuddyId],kBuddyName:[[arrayBuddies objectAtIndex:indexPath.row] objectForKey:kBuddyName],kBuddyImage:[[arrayBuddies objectAtIndex:indexPath.row] objectForKey:kBuddyImage]};
    ChatScreenViewController *chatScreenViewC = [[ChatScreenViewController alloc] initWithNibName:@"ChatScreenViewController" bundle:nil];
    [chatScreenViewC setDictBuddyInfo:dictBuddyDetails];
    [chatScreenViewC setHidesBottomBarWhenPushed:YES];
    [chatScreenViewC setIsGroup:NO];
    [self.navigationController pushViewController:chatScreenViewC animated:YES];
}

- (void)btnAddTapped:(UIButton*)sender withEvent:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint: currentTouchPosition];
    NSDictionary *tempDict = arrayBuddies[indexPath.row];
    [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"Add as friend?" buttonArray:[NSArray arrayWithObjects:@"Yes",@"Cancel",nil] selectedButton:^(NSInteger selected, UIAlertView *aView)
     {
         if ( selected == 0)
         {
             [self callAPISendInviteToBuddy:[tempDict objectForKeyNonNull:kBuddyId]];
         }
         else
         {
             
         }
     }];
}

- (void)btnInviteTapped:(UIButton*)sender withEvent:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:_tableView];
    NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint: currentTouchPosition];
    NSDictionary *tempDict = arrayBuddies[indexPath.row];
    
    [[Utils sharedInstance] showAlertWithTitle:kAPPNAME message:@"You want to send invitation?" buttonArray:[NSArray arrayWithObjects:@"Yes",@"Cancel",nil] selectedButton:^(NSInteger selected, UIAlertView *aView)
     {
         if ( selected == 0)
         {
             sender.selected = YES;
             
             if (_isText)
             {
                 
             }
             else
             {
                 [self callAPIContactInviteToBuddy:[tempDict objectForKeyNonNull:@"email"]];
             }
             
             if ([arraySelectedIndexes containsObject:indexPath])
             {
                 [arraySelectedIndexes removeObject:indexPath];
             }
             else
             {
                 [arraySelectedIndexes addObject:indexPath];
             }
             
           //  [arrayBuddies replaceObjectAtIndex:indexPath.row withObject:tempDict];
            [_tableView reloadData];
         }
         else
         {
             
         }
     }];
}

#pragma mark -MFMessageComposeViewController
- (void)sendSMS:(NSString *)bodyOfMessage recipientList:(NSArray *)recipients
{
    
    
    if ([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController* composeVC = [[MFMessageComposeViewController alloc] init];
        composeVC.messageComposeDelegate = self;
        composeVC.body = bodyOfMessage;
        composeVC.recipients = recipients;
        [self presentViewController:composeVC animated:YES completion:NULL];
    }
    else
    {
        [Utils showAlertViewWithMessage:@"This device can not send text message.!"];
    }
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MessageComposeResultCancelled)
    {
        NSLog(@"Message cancelled");
    }
    else if (result == MessageComposeResultSent)
    {
        NSLog(@"Message sent");
    }
    else
    {
        NSLog(@"Message failed") ;
    }
}


#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayBuddies count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[[[NSBundle mainBundle] loadNibNamed:@"FindBuddiesCell" owner:self options:nil] lastObject];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIImageView *imgProfile = (UIImageView *)[cell.contentView viewWithTag:10];
    UILabel *lblName = (UILabel *)[cell.contentView viewWithTag:11];
    
    UILabel *lblNo_Nail = (UILabel *)[cell.contentView viewWithTag:21];
    
    //btnadd
    UIButton *btnAdd = (UIButton*)[cell.contentView viewWithTag:15];
    [btnAdd.layer setBorderColor:kBlueColor.CGColor];
    [btnAdd.layer setBorderWidth:kButtonBorderWidth];
    [btnAdd.layer setCornerRadius:kButtonCornerRadius];
    [btnAdd addTarget:self action:@selector(btnAddTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];

    //btninvite
    UIButton *btnInvite = (UIButton*)[cell.contentView viewWithTag:14];
    [btnInvite setTitle:@"Invite" forState:UIControlStateNormal];
    [btnInvite addTarget:self action:@selector(btnInviteTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    //btninvitechecked
    UIButton *btnInviteChecked = (UIButton*)[cell.contentView viewWithTag:20];
    [btnInviteChecked setHidden:YES];
    //[btnInviteChecked setTitle:@"Invite" forState:UIControlStateNormal];
    //[btnInviteChecked addTarget:self action:@selector(btnInviteTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //btnmessage
    UIButton *btnMessage = (UIButton*)[cell.contentView viewWithTag:12];
    [btnMessage addTarget:self action:@selector(btnMessageFindTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    /******************/
    
    btnAdd.hidden = YES;
    btnInvite.hidden = YES;
    btnMessage.hidden = YES;
    
    /****************/
    
    
    
    NSDictionary *dictFetchContact;
    NSString *imgname = [[NSString alloc] init];
    
    if(isRegisteredUser)
    {
        
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"buddyEmail" ascending:YES];
        
        [arrayBuddies sortUsingDescriptors:[NSMutableArray arrayWithObject:sort]];
        
        dictFetchContact = arrayBuddies[indexPath.row];
        [lblName setText:[dictFetchContact objectForKeyNonNull:kBuddyName]];
        imgname=[NSString stringWithFormat:@"%@",[dictFetchContact objectForKeyNonNull:kBuddyImage]];
        
        btnAdd.hidden = NO;
        btnMessage.hidden = NO;

    }
    else
    {
        
        
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:kEmailId ascending:YES];
        
        [arrayBuddies sortUsingDescriptors:[NSMutableArray arrayWithObject:sort]];
        
        dictFetchContact = arrayBuddies[indexPath.row];
        NSString *email  = [dictFetchContact objectForKeyNonNull:@"email"];
        NSString *number=[dictFetchContact objectForKeyNonNull:@"number"];
        NSString *name= [dictFetchContact objectForKeyNonNull:@"name"];
       
            btnInvite.hidden = NO;
        if ([arraySelectedIndexes containsObject:indexPath])
        {
            [btnInviteChecked setHidden:NO];
            [btnInviteChecked setImage:[UIImage imageNamed:@"chekbox_invite"] forState:UIControlStateNormal];
            [btnInvite setHidden:YES];
        }
        else
        {   [btnInvite setHidden:NO];
            [btnInviteChecked setHidden:YES];
            [btnInvite setTitle:@"Invite" forState:UIControlStateNormal];
            [btnInvite.layer setBorderColor:kBlueColor.CGColor];
            [btnInvite.layer setBorderWidth:kButtonBorderWidth];
            [btnInvite.layer setCornerRadius:kButtonCornerRadius];
        }
        if ([name isEqualToString:@""])
        {
            if (_isText)
            {
                [lblName setText:number];
            }
            else
            {
                [lblName setText:email];
            }
            
        }
        else
        {
            [lblName setText:name];
        }
       
        if (_isText)
        {
            [lblNo_Nail setText:number];
        }
        else
        {
            [lblNo_Nail setText:email];
        }
    }
//    NSPredicate *prdicate = [NSPredicate predicateWithFormat:@"buddyEmail = %@",email];
//    NSArray *tempArray = [arrayBuddies filteredArrayUsingPredicate:prdicate];
//    if (tempArray.count > 0)
//    {
//        NSDictionary *dict = [tempArray objectAtIndex:0];
//        
//        NSLog(@"Change here %@",dict);
//        
//           }
//    else
//    {
//        //dictFetchContact
//
//       
//    }
    
    /***************/
    
    if (indexPath.row % 2 == 0)
    {
        [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    }
    else
    {
        [cell.contentView setBackgroundColor:kGrayGolor];
    }
   
    [imgProfile setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",kImageURl,imgname]]placeholderImage:[UIImage imageNamed:@"gaust_user.png"]];
    
    [lblName setFont:FONT_REGULAR(14)];
    
    [imgProfile.layer setCornerRadius:22];
    [imgProfile setClipsToBounds:YES];
    
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (!isRegisteredUser) {
        return;
    }
    
    NSDictionary *dictFetchContact = arrayBuddies[indexPath.row];
    NSString *email  = [dictFetchContact objectForKeyNonNull:@"emailId"];
   // NSString *imgname = [[NSString alloc] init];
    
    NSPredicate *prdicate = [NSPredicate predicateWithFormat:@"buddyEmail = %@",email];
    NSArray *tempArray = [arrayBuddies filteredArrayUsingPredicate:prdicate];
    if (tempArray.count > 0)
    {
        NSDictionary *dict = [tempArray objectAtIndex:0];
        
        NSLog(@"Change here %@",dict);
        
    }
    
    
    NSDictionary *tempDict = arrayBuddies[indexPath.row];
    ViewProfileViewController * viewProfile = [[ViewProfileViewController alloc]initWithNibName:@"ViewProfileViewController" bundle:nil];
    viewProfile.editProfile = YES;
    viewProfile.isViewProfile = YES;
    
    
    viewProfile.inviteButtonHidden = NO;
    [viewProfile setBuddyId:[tempDict objectForKeyNonNull:kBuddyId]];
    [self.navigationController pushViewController:viewProfile animated:YES];
}
@end
