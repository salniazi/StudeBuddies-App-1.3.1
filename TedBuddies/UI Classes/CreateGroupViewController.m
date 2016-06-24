//
//  CreateGroupViewController.m
//  TedBuddies
//
//  Created by Mayank Pahuja on 24/09/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import "CreateGroupViewController.h"
#import "NewGroupTableViewCell.h"


@interface CreateGroupViewController ()
{
    BOOL isFirst;
}
@property (weak, nonatomic) IBOutlet UIButton *chatIndividualButton;
@property (nonatomic, strong) NSMutableArray *toRecipients;
@property (nonatomic, strong) JSTokenField *toField;


@end

@implementation CreateGroupViewController

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
    
    feedArray=[[NSMutableArray alloc]init];
    dataArray=[[NSMutableArray alloc]init];
    seldata=[[NSMutableArray alloc]init];
    searchBuddys=[[NSMutableArray alloc]init];
    
    self.toRecipients = [[NSMutableArray alloc] init];
    
    _btnCreate.enabled=NO;
    [_btnCreate setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
     self.tblViewGroupMembers.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
   
    self.toField = [[JSTokenField alloc] initWithFrame:CGRectMake(0, 0, _scrollView.frame.size.width, 30)];
    [[self.toField label] setText:@"To:"];
    _toField.backgroundColor=[UIColor clearColor];
    [_toField.textField setPlaceholder:@"Search..."];
    [self.toField setDelegate:self];
    [_scrollView addSubview:self.toField];
    
    
    
    

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
//    self.tblViewGroupMembers.allowsMultipleSelectionDuringEditing = YES;
//    // Do any additional setup after loading the view.
//    NSString *itemFormatString = NSLocalizedString(@"Item %d", @"Format string for item");
//    for (unsigned int itemNumber = 1; itemNumber <= feedArray.count; itemNumber++)
//    {
//        NSString *itemName = [NSString stringWithFormat:itemFormatString, itemNumber];
//        [dataArray addObject:itemName];
//    }
//    [self.tblViewGroupMembers setEditing:YES animated:YES];
    
    

    
    // Do any additional setup after loading the view from its nib.
}
- (void)keyboardWasShown:(NSNotification *)notification
{
    
   
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    int height = keyboardSize.height-49;
    
    if (!isFirst)
    {
        [_tblViewGroupMembers setFrame:CGRectMake(_tblViewGroupMembers.frame.origin.x, _tblViewGroupMembers.frame.origin.y
                                                  , _tblViewGroupMembers.frame.size.width, _tblViewGroupMembers.frame.size.height-height)];
        isFirst=true;
    }
    
   
   
}

- (void)viewWillAppear:(BOOL)animated
{
    [_toField.textField becomeFirstResponder];
    [self setFonts];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setFonts
{
    [self callAPIFindBuddies];
    
    
//    [_btnCreate.layer setCornerRadius:kButtonCornerRadius];
//    [_btnCreate.titleLabel setFont:FONT_REGULAR(kButtonTextSize)];
//    [_btnCreate.layer setBorderWidth:kButtonBorderWidth];
//    [_btnCreate.layer setBorderColor:[UIColor whiteColor].CGColor];
//    [_btnCreate.titleLabel setTextColor:[UIColor whiteColor]];
    
    [_imgViewMemberNameBg.layer setCornerRadius:5];
    [_imgViewMemberNameBg.layer setBorderWidth:1];
    [_imgViewMemberNameBg setClipsToBounds:YES];
    [_imgViewMemberNameBg.layer setBorderColor:[UIColor grayColor].CGColor];
    
    [_imgViewTextFieldBg.layer setCornerRadius:5];
    [_imgViewTextFieldBg setClipsToBounds:YES];
    [_imgViewTextFieldBg.layer setBorderWidth:1];
    [_imgViewTextFieldBg.layer setBorderColor:[UIColor grayColor].CGColor];
       
    
    arrGroupMembers = nil;
    arrGroupMembers = [[NSMutableArray alloc] init];
    searchBuddys = [[NSMutableArray alloc] init];
    
}
#pragma mark JSTokenFieldDelegate

- (void)tokenField:(JSTokenField *)tokenField didAddToken:(NSString *)title representedObject:(id)obj
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [_scrollView setContentSize:CGSizeMake(_scrollView.width, _toField.height)];
        if (_scrollView.height <_toField.height)
        {
           [_scrollView setContentSize:CGSizeMake(_scrollView.width, _toField.height)];
            [self.scrollView setContentOffset:CGPointMake(0, _toField.height-30)];

        }
        
            });
    
}

- (void)tokenField:(JSTokenField *)tokenField didRemoveToken:(NSString *)title representedObject:(id)obj
{
    NSInteger index=[arrayBuddies indexOfObject:obj];
    if (NSNotFound!=index)
    {
        [[arrayBuddies objectAtIndex:index] setValue:@"0" forKey:@"isChecked"];
        [_tblViewGroupMembers reloadData];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
         [_scrollView setContentSize:CGSizeMake(_scrollView.width, _toField.height)];
        if (_scrollView.height <_toField.height)
        {
           
            [self.scrollView setContentOffset:CGPointMake(0, _toField.height-30)];
        }
        
        
    });
    
    BOOL flag=false;
    for (int i=0; i<arrayBuddies.count; i++)
    {
        
        if ([[[arrayBuddies objectAtIndex:i] valueForKey:@"isChecked"]isEqualToString:@"1"])
        {
            flag=true;
            _toField.textField.placeholder=@"";
            break;
        }
    }
    if (!flag)
    {
        [_btnCreate setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        _btnCreate.enabled=NO;
        _toField.textField.placeholder=@"Search...";
    }

}
- (void)tokenFieldTextDidChange:(JSTokenField *)tokenField
{
    [searchBuddys removeAllObjects];
    if([tokenField.textField.text length] != 0) {
        isSearch = YES;
        [self searchTableList];
    }
    else {
        isSearch = NO;
    }
    [_tblViewGroupMembers reloadData];
}

- (void)tokenFieldDidEndEditing:(JSTokenField *)tokenField
{
    
}

- (BOOL)tokenFieldShouldReturn:(JSTokenField *)tokenField
{
    
    return YES;
}
- (void)searchTableList {
    NSString *searchString = self.toField.textField.text;
    [searchBuddys removeAllObjects];
    NSInteger i=0;
    for (NSMutableArray *arry in arrayBuddies) {
        
        NSString *tempStr=[[arrayBuddies objectAtIndex:i]objectForKey:@"buddyName"];
        NSComparisonResult result = [tempStr compare:searchString options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchString length])];
        i++;
        if (result == NSOrderedSame) {
            [searchBuddys addObject:arry];
        }
        NSLog(@"filter==%@",searchBuddys);
    }
    
    
}

#pragma mark - Tabel View Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if (isSearch)
    {
        return searchBuddys.count;
    }
    else
    {
        return arrayBuddies.count;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    NewGroupTableViewCell *cell = (NewGroupTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    if (cell == nil)
    {
        cell = (NewGroupTableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"NewGroupTableViewCell" owner:self options:nil] objectAtIndex:0];
        
    }
    
    if (isSearch)
    {
        
        cell.lblName.text=[[searchBuddys objectAtIndex:indexPath.row] valueForKey:@"buddyName"];
        NSString *imgUrl=[[searchBuddys objectAtIndex:indexPath.row] valueForKey:@"buddyImage"];
        cell.imgUser.layer.cornerRadius=19;
        cell.imgUser.clipsToBounds=YES;
        if ([[[searchBuddys objectAtIndex:indexPath.row] valueForKey:@"isChecked"]isEqualToString:@"1"])
        {
            [cell.imgSelect setImage:[UIImage imageNamed:@"Check"]];
            
            
        }
        else
        {
            [cell.imgSelect setImage:[UIImage imageNamed:@"UnCkeck"]];
        }
        
        [cell.imgUser setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"appicon.png"]];
        
    }
    else
    {
        cell.lblName.text=[[arrayBuddies objectAtIndex:indexPath.row] valueForKey:@"buddyName"];
        NSString *imgUrl=[[arrayBuddies objectAtIndex:indexPath.row] valueForKey:@"buddyImage"];
        cell.imgUser.layer.cornerRadius=19;
        cell.imgUser.clipsToBounds=YES;
        if ([[[arrayBuddies objectAtIndex:indexPath.row] valueForKey:@"isChecked"]isEqualToString:@"1"])
        {
            [cell.imgSelect setImage:[UIImage imageNamed:@"Check"]];
               
                
        }
        else
        {
            [cell.imgSelect setImage:[UIImage imageNamed:@"UnCkeck"]];
        }
        
        [cell.imgUser setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"appicon.png"]];
        

    }
       return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NewGroupTableViewCell *cell  = [_tblViewGroupMembers cellForRowAtIndexPath:indexPath];
    
    if (isSearch)
    {
        if ([[[searchBuddys objectAtIndex:indexPath.row] valueForKey:@"isChecked"]boolValue])
        {
            NSInteger index=[arrayBuddies indexOfObject:[searchBuddys objectAtIndex:indexPath.row]];
            if (NSNotFound!=index)
            {
                [[arrayBuddies objectAtIndex:index] setValue:@"0" forKey:@"isChecked"];
            }
            [[searchBuddys objectAtIndex:indexPath.row] setValue:@"0" forKey:@"isChecked"];
            [cell.imgSelect setImage:[UIImage imageNamed:@"UnCkeck"]];
            [_toField removeTokenWithRepresentedObject:[searchBuddys objectAtIndex:indexPath.row]];
            
            
        }
        else
        {
            NSInteger index=[arrayBuddies indexOfObject:[searchBuddys objectAtIndex:indexPath.row]];
            if (NSNotFound!=index)
            {
                [[arrayBuddies objectAtIndex:index] setValue:@"1" forKey:@"isChecked"];
            }
            [[searchBuddys objectAtIndex:indexPath.row] setValue:@"1" forKey:@"isChecked"];
            [cell.imgSelect setImage:[UIImage imageNamed:@"Check"]];
            [_btnCreate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _btnCreate.enabled=YES;
            
            [_toField addTokenWithTitle:[[searchBuddys objectAtIndex:indexPath.row] valueForKey:@"buddyName"] representedObject:[searchBuddys objectAtIndex:indexPath.row] ];
            
            
            
            
        }

        
    }
    else
    {
    
    if ([[[arrayBuddies objectAtIndex:indexPath.row] valueForKey:@"isChecked"]boolValue])
    {
        [[arrayBuddies objectAtIndex:indexPath.row] setValue:@"0" forKey:@"isChecked"];
        [cell.imgSelect setImage:[UIImage imageNamed:@"UnCkeck"]];
        [_toField removeTokenWithRepresentedObject:[arrayBuddies objectAtIndex:indexPath.row]];
        
        
    }
    else
    {
         [[arrayBuddies objectAtIndex:indexPath.row] setValue:@"1" forKey:@"isChecked"];
        [cell.imgSelect setImage:[UIImage imageNamed:@"Check"]];
         [_btnCreate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnCreate.enabled=YES;

        [_toField addTokenWithTitle:[[arrayBuddies objectAtIndex:indexPath.row] valueForKey:@"buddyName"] representedObject:[arrayBuddies objectAtIndex:indexPath.row] ];
        



    }
    }
    BOOL flag=false;
    for (int i=0; i<arrayBuddies.count; i++)
    {
        
        if ([[[arrayBuddies objectAtIndex:i] valueForKey:@"isChecked"]isEqualToString:@"1"])
        {
            flag=true;
            _toField.textField.placeholder=@"";
            break;
        }
    }
    if (!flag)
    {
        [_btnCreate setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        _btnCreate.enabled=NO;
        _toField.textField.placeholder=@"Search...";
    }
    [searchBuddys removeAllObjects];
    isSearch=NO;
    _toField.textField.text=@"";
    [_tblViewGroupMembers reloadData];

    NSLog(@"Is checked=======%@",[[arrayBuddies objectAtIndex:indexPath.row] valueForKey:@"isChecked"]);
    
    
//    if (isSearch) {
//        
//        [seldata addObject: [searchBuddys objectAtIndex:indexPath.row]];
//        NSLog(@"selid :: %@",seldata);
//        _btnCreate.enabled=YES;
//        [_btnCreate setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
//        
//    }
//    else
//    {
//        [seldata addObject: [arrayBuddies objectAtIndex:indexPath.row]];
//        NSLog(@"selid :: %@",seldata);
//        _btnCreate.enabled=YES;
//        [_btnCreate setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
//    }
    
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    if (isSearch) {
//        [seldata removeObject:[searchBuddys objectAtIndex:indexPath.row]];
//        
//        NSLog(@"selid :: %@",seldata);
//        if (seldata.count==0) {
//            _btnCreate.enabled=NO;
//            [_btnCreate setTitleColor:[UIColor colorWithRed:184/255.0 green:184/255.0 blue:184/255.0 alpha:1.0] forState:UIControlStateNormal];
//        }
//        
//    }
//    else
//    {
//        [seldata removeObject:[arrayBuddies objectAtIndex:indexPath.row]];
//        
//        NSLog(@"selid :: %@",seldata);
//        if (seldata.count==0) {
//            _btnCreate.enabled=NO;
//            [_btnCreate setTitleColor:[UIColor colorWithRed:184/255.0 green:184/255.0 blue:184/255.0 alpha:1.0] forState:UIControlStateNormal];
//        }
//    }
    
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
    
   
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

#pragma mark - web service
- (void)callAPIFindBuddies
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
                              nil];
    [Utils startLoaderWithMessage:@""];
    
    [Connection callServiceWithName:kGetMyBuddiesList postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         [Utils stopLoader];
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 arrayBuddies = nil;
                 arrayBuddies=[[NSMutableArray alloc] init];
                 NSMutableArray *tempArry = [[NSMutableArray alloc] initWithArray:[response objectForKeyNonNull:kResult]];
                 for (int i=0; i<tempArry.count; i++)
                 {
                     NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithDictionary:[tempArry objectAtIndex:i]];
                     
                     [dict setValue:@"0" forKey:@"isChecked"];
                     [arrayBuddies addObject:dict];
                 }
                 [_tblViewGroupMembers reloadData];
             }
         }
     }];
}

- (void)callAPICreateGroup
{
    NSMutableArray *arrFriendIds = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in arrGroupMembers)
    {
        [arrFriendIds addObject:@{kUserId:[dict objectForKey:kBuddyId]}];
    }
    
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"",kGroupId,
                              [defaults objectForKey:kUserId],kCreatedBy,
                              _txtFieldGroupName.text,kGroupName,
                              arrFriendIds,kGroupMember,
                              nil];
    [Utils startLoaderWithMessage:@""];
    
    [Connection callServiceWithName:kCreateGroup postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         [Utils stopLoader];
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 NSMutableArray *arrMembers = [[NSMutableArray alloc] init];
                 
                 // add all buddies to the dictionary
                 for (NSDictionary *dict in arrGroupMembers)
                 {
                     NSDictionary *dictFriend = @{kUserId: [dict objectForKey:kBuddyId],kUserName: [dict objectForKey:kBuddyName], kProfileImage:[dict objectForKey:kBuddyImage]};
                     [arrMembers addObject:dictFriend];
                     
                 }
                 
                 // add yourself to friends dictionary
                 NSDictionary *selfDict = @{kUserId: [defaults objectForKey:kUserId],kUserName: @"", kProfileImage:[defaults objectForKey:kProfilePicture]};
                 [arrMembers addObject:selfDict];
                 
                 NSDictionary *dictBuddyDetails = @{kBuddyId: [[response objectForKey:kResult] objectForKey:kGroupId],kBuddyName:_txtFieldGroupName.text,kGroupMember:arrMembers};
                 ChatScreenViewController *chatScreenViewC = [[ChatScreenViewController alloc] initWithNibName:@"ChatScreenViewController" bundle:nil];
                 [chatScreenViewC setDictBuddyInfo:dictBuddyDetails];
                 [chatScreenViewC setIsGroup:YES];
                 [chatScreenViewC setHidesBottomBarWhenPushed:YES];
                 [self.navigationController pushViewController:chatScreenViewC animated:YES];
             }
         }
    }];
}
#pragma mark - button action

- (IBAction)btnBackTapped:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)btnCreateTapped:(UIButton *)sender
{
    [arrGroupMembers removeAllObjects];
    for (int i=0; i<arrayBuddies.count; i++)
    {
        if ([[[arrayBuddies objectAtIndex:i] valueForKey:@"isChecked"]isEqualToString:@"1"])
        {
            [arrGroupMembers addObject:[arrayBuddies objectAtIndex:i]];
        }
    }
    
        if (arrGroupMembers.count > 0)
        {
            if (arrGroupMembers.count==1)
            {
                [_toField.textField resignFirstResponder];
                NSDictionary *dictBuddyDetails = @{kBuddyId:[[arrGroupMembers objectAtIndex:0]valueForKey:@"buddyId"],kBuddyName:[[arrGroupMembers objectAtIndex:0]valueForKey:@"buddyName"],kBuddyImage:[[arrGroupMembers objectAtIndex:0]valueForKey:@"buddyImage"]};
                ChatScreenViewController *chatScreenViewC = [[ChatScreenViewController alloc] initWithNibName:@"ChatScreenViewController" bundle:nil];
                [chatScreenViewC setDictBuddyInfo:dictBuddyDetails];
                [chatScreenViewC setHidesBottomBarWhenPushed:YES];
                [chatScreenViewC setIsGroup:NO];
                [self.navigationController pushViewController:chatScreenViewC animated:YES];

            }
            else
            {
                if (_txtFieldGroupName.text.length > 0)
                {
                    [_toField.textField resignFirstResponder];
                    [_txtFieldGroupName resignFirstResponder];
                    [_tblViewGroupMembers setFrame:CGRectMake(_tblViewGroupMembers.frame.origin.x, _tblViewGroupMembers.frame.origin.y
                                                              , _tblViewGroupMembers.frame.size.width, self.view.height-(_scrollView.xOrigin+_scrollView.height))];

                    [self callAPICreateGroup];
                }
                else
                {
                    [Utils showAlertViewWithMessage:@"Don't forget to fill Group Name field"];
                }

            }
        }
        else
        {
            [Utils showAlertViewWithMessage:@"Don't forget to fill users"];
        }
   
}



@end
