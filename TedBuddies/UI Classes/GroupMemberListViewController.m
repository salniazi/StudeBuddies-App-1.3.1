//
//  GroupMemberListViewController.m
//  TedBuddies
//
//  Created by Mac on 27/04/16.
//  Copyright © 2016 Mayank Pahuja. All rights reserved.
//

#import "GroupMemberListViewController.h"
#import "GroupMembersTableViewCell.h"
#import "ViewProfileViewController.h"

@interface GroupMemberListViewController ()
{
   

}

@end

@implementation GroupMemberListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
  //  NSLog(@"%lu",[[_dictMembers valueForKey:@"groupMember"] count]);
    
    if (!_isClass)
    {
        _lblTittle.text=[_dictMembers valueForKey:@"buddyName"];
    }
    
    _membersTableView.dataSource=self;
    _membersTableView.delegate=self;
    _membersTableView.tableFooterView=[[UIView alloc] initWithFrame:CGRectZero];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
   
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - TableView
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[_dictMembers valueForKey:@"groupMember"] count]==indexPath.row)
    {
        return 93;
    }
    return 44;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_dictMembers valueForKey:@"groupMember"] count]+1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[_dictMembers valueForKey:@"groupMember"] count]==indexPath.row)
    {
        static NSString *cellIdentifier = @"cell1";
        
        GroupMembersTableViewCell *cell = (GroupMembersTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        
        if (cell == nil)
        {
            cell = (GroupMembersTableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"GroupMembersTableViewCell" owner:self options:nil] objectAtIndex:1];
            _btnLeaveJoin=(UIButton*)[cell viewWithTag:2];
            if (_isLeft)
            {
                [_btnLeaveJoin setTitle:@"Join this conversation" forState:UIControlStateNormal];
            }

            [_btnLeaveJoin addTarget:self action:@selector(btnLeaveclick:) forControlEvents:UIControlEventTouchUpInside];
            
            
            _muteSwitch=(UISwitch*)[cell viewWithTag:1];
            [_muteSwitch setOn:_isMute animated:NO];
            [_muteSwitch addTarget:self action:@selector(MuteSwitchClick:) forControlEvents:UIControlEventValueChanged];
        }
        return cell;

    }
    static NSString *cellIdentifier = @"cell";
    
    GroupMembersTableViewCell *cell = (GroupMembersTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    if (cell == nil)
    {
        cell = (GroupMembersTableViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"GroupMembersTableViewCell" owner:self options:nil] objectAtIndex:0];
        
    }
    NSLog(@"%@",[[[_dictMembers valueForKey:@"groupMember"] objectAtIndex:indexPath.row] valueForKey:@"userName"]);
    cell.lblMemberName.text=[[[_dictMembers valueForKey:@"groupMember"] objectAtIndex:indexPath.row] valueForKey:@"userName"];
    
    NSString *imgUrl=[[[_dictMembers valueForKey:@"groupMember"] objectAtIndex:indexPath.row] valueForKey:@"profileImage"];
    cell.imgMemberProfile.layer.cornerRadius=19;
    cell.imgMemberProfile.clipsToBounds=YES;
    [cell.imgMemberProfile setImageWithURL:[NSURL URLWithString:imgUrl] placeholderImage:[UIImage imageNamed:@"appicon.png"]];
    
    return cell;

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([[_dictMembers valueForKey:@"groupMember"] count]!=indexPath.row)
    {
        ViewProfileViewController * viewProfile = [[ViewProfileViewController alloc]initWithNibName:@"ViewProfileViewController" bundle:nil];
        viewProfile.isViewProfile = YES;
        
        viewProfile.editProfile = YES;
        viewProfile.inviteButtonHidden = YES;
        [viewProfile setBuddyId:[[[_dictMembers valueForKey:@"groupMember"] objectAtIndex:indexPath.row] valueForKey:@"userId"]];
        [self.navigationController pushViewController:viewProfile animated:YES];

    }
    
}

- (IBAction)btnBackTapped:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)MuteSwitchClick:(id)sender
{
    [self SetMuteForClassUser:[sender isOn]];
}

- (IBAction)btnLeaveclick:(id)sender
{
    NSString *btnName;
    bool left;
    
    if (!_isLeft)
    {
        btnName=@"Leave this conversation";
        left=true;
    }
    else
    {
         btnName=@"Join this conversation";
        left=false;
    }
    
    [[Utils sharedInstance] showActionSheetWithTitle:@"" buttonArray:@[btnName]     selectedButton:^(NSInteger selected)
     {
         
         if (selected==0)
         {
            
                 [self LeftClassGroupUser:left];
         }
     }];
    
    
}

#pragma mark - web service
- (void)SetMuteForClassUser:(BOOL)isMute
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
                              [_dictMembers objectForKey:@"groupId"],@"classid",
                              isMute?@"True":@"False",@"isMute",
                              nil];
   
    [Utils startLoaderWithMessage:@""];
        
   
    
    [Connection callServiceWithName:kSetMuteForClassUser postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         
         [Utils stopLoader];
        
         
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 SharedAppDelegate.isMuteGroup=isMute;
             }
         }
         
     }];
}

- (void)LeftClassGroupUser:(BOOL)isLeft
{
    NSDictionary *dictSend = [NSDictionary dictionaryWithObjectsAndKeys:
                              [defaults objectForKey:kUserId],kUserId,
                              [_dictMembers objectForKey:@"groupId"],@"classid",
                              isLeft?@"True":@"False",@"isLeft",
                              nil];
    
    [Utils startLoaderWithMessage:@""];
    
    
    
    [Connection callServiceWithName:kLeftClassGroupUser postData:dictSend callBackBlock:^(id response, NSError *error)
     {
         
         [Utils stopLoader];
         
         
         if (response)
         {
             if ([[response objectForKeyNonNull:kSuccess] boolValue] == true)
             {
                 if (isLeft)
                 {
                     SharedAppDelegate.isLeftGroup=true;
                 }
                 else
                 {
                     SharedAppDelegate.isJoinGroup=true;
                 }
                 
                 [self.navigationController popViewControllerAnimated:YES];
             }
         }
         
     }];
}



@end
