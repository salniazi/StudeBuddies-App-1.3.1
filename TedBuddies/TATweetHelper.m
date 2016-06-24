//
//  TATweetHelper.m
//  TAFacebookHelperDemo
//
//  Created by Mayank Pahuja on 08/08/13.
//  Copyright (c) 2013 Mayank Pahuja. All rights reserved.
//

#import "TATweetHelper.h"

@interface TATweetHelper ()

@property (strong, nonatomic) ACAccountStore *twitterACAccountStore;

@end

@implementation TATweetHelper

//shared instance
//return singleton object of this class
+(TATweetHelper*)sharedInstance
{
  static TATweetHelper* sharedObj = nil;
  if (sharedObj == nil) {
    sharedObj = [[TATweetHelper alloc] init];
  }
  return sharedObj;
}

/*
 getListWithType should be used for getting friends or followers list.
 
 listType: pass the desired list type you want to get from ListType enum.
 pageNumber: The default pagenumber is -1. You will get 20 results per page, increment the pagenumber by 1 for successive pages.
 */
+ (void)getListWithType:(ListType)listType WithPageNumber:(NSInteger)pageNum completetionBlock:(void(^)(id response, NSError *error))responseBlock
{
    NSString *listTypeString = nil;
    switch (listType)
    {
        case ListTypeFollowers:
            listTypeString= @"followers";
            break;
        case ListTypeFollowing:
            listTypeString = @"friends";
            
        default:
            break;
    }
    ACAccountStore *twitterStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType = [twitterStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

    //  Request permission from the user to access the available Twitter accounts
    [twitterStore requestAccessToAccountsWithType:twitterAccountType options:nil completion:^(BOOL granted, NSError *error)
     {
         if (!granted)
         {
             responseBlock(nil,error);
         }
         else
         {
             NSArray *twitterAccounts =
             [twitterStore accountsWithAccountType:twitterAccountType];
             
             if ([twitterAccounts count] > 0)
             {
                 ACAccount *account = [twitterAccounts objectAtIndex:0];
                 NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                 [params setObject:account.accountDescription forKey:@"screen_name"];
                 //[params setObject:@"false" forKey:@"include_user_entities"];
                 [params setObject:[NSString stringWithFormat:@"%i",pageNum] forKey:@"cursor"];
                 
                 //  The endpoint that we wish to call
                 NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/%@/list.json",listTypeString]];
                 
                 //  Build the request with our parameter
                 SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                         requestMethod:SLRequestMethodPOST
                                                                   URL:url
                                                            parameters:params];
                 
                 
                 // Attach the account object to this request
                 [request setAccount:account];
                 
                 [request performRequestWithHandler:
                  ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                  {
                      if (!responseData)
                      {
                          responseBlock(nil,error);
                      }
                      else
                      {
                          
                          NSError *jsonError;
                          NSDictionary *timeline = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&jsonError];
                          if (timeline)
                          {
                              responseBlock(timeline,error);
                          }
                          else
                          {
                              responseBlock(timeline,error);
                          }
                      }
                  }];
             }
             else
             {
                 responseBlock(nil,error);
             }
         }
     }];

}
/*
 postStatus should be used for posting a simple text tweet. The limit per tweet is up to 140 characters.
 
 status: Enter the text for the tweet. There are some special commands in this field to be aware of(https://support.twitter.com/articles/14020-twitter-for-sms-basic-features). For instance, preceding a message with "D " or "M " and following it with a screen name can create a direct message to that user if the relationship allows for it.
 */
+ (void)postStatus:(NSString*)status completetionBlock:(void(^)(id response, NSError *error))responseBlock
{
    
    ACAccountStore *twitterStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType = [twitterStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    //  Request permission from the user to access the available Twitter accounts
    [twitterStore requestAccessToAccountsWithType:twitterAccountType options:nil completion:^(BOOL granted, NSError *error)
     {
         if (!granted)
         {
             responseBlock(nil,error);
         }
         else
         {
             NSArray *twitterAccounts =
             [twitterStore accountsWithAccountType:twitterAccountType];
             
             if ([twitterAccounts count] > 0)
             {
                 ACAccount *account = [twitterAccounts objectAtIndex:0];
                 NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                 [params setObject:status forKey:@"status"];
                 
                 //  The endpoint that we wish to call
                 NSURL *url =[NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
                 
                 //  Build the request with our parameter
                 SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                         requestMethod:SLRequestMethodPOST
                                                                   URL:url
                                                            parameters:params];
                 
                 // Attach the account object to this request
                 [request setAccount:account];
                 
                 [request performRequestWithHandler:
                  ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                  {
                      if (!responseData)
                      {
                          responseBlock(nil,error);
                      }
                      else
                      {
                          NSError *jsonError;
                          NSDictionary *timeline = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&jsonError];
                          if (timeline)
                          {
                              responseBlock(timeline,error);
                          }
                          else
                          {
                              responseBlock(timeline,error);
                          }
                      }
                  }];
             }
             else
             {
                 responseBlock(nil,error);
             }
         }
     }];
}


/*
 postStatus: withImage: should be used for posting a simple text tweet with Image.
 
 status: Enter the text for the tweet.
 imageToUpload: UIImage object for image to be uploaded
 */

+ (void)postStatus:(NSString*)status withImage:(UIImage*)imageToUpload completetionBlock:(void(^)(id response, NSError *error))responseBlock
{
    ACAccountStore *twitterStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterType =
    [twitterStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [twitterStore requestAccessToAccountsWithType:twitterType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted)
        {
            NSArray *accounts = [twitterStore accountsWithAccountType:twitterType];
            if(accounts.count==0)
            {
                responseBlock(nil,nil);
                
                NSLog(@"");
                return;
            }
            ACAccount *account=[accounts objectAtIndex:0];
            NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                          @"/1.1/statuses/update_with_media.json"];
            NSDictionary *params = @{@"status" : status};
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                    requestMethod:SLRequestMethodPOST
                                                              URL:url
                                                       parameters:params];
            NSData *imageData = UIImageJPEGRepresentation(imageToUpload, 1.0f);
            [request addMultipartData:imageData
                             withName:@"media[]"
                                 type:@"image/jpeg"
                             filename:@"image.jpg"];
            [request setAccount:account];
            
            [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
             {
                 if (error)
                 {
                     responseBlock(nil,error);
                 }
                 else
                 {
                     NSDictionary *postResponseData =
                     [NSJSONSerialization JSONObjectWithData:responseData
                                                     options:NSJSONReadingMutableContainers
                                                       error:NULL];
                     NSLog(@"response:%@",postResponseData);
                     responseBlock(postResponseData,error);
                 }
                 
             }];
        }
        else
        {
            NSLog(@"[ERROR] An error occurred while asking for user authorization: %@",
                  [error localizedDescription]);
            responseBlock(nil,error);
        }
    }];
}

/*
 getTimelineWithType should be used for getting all the objects on users timeline corresponding to the TimelineType you pass
 
 TimelineType: pass the desired timeline type you want to get from TimelineType enum. See enum for more description.
 */
+ (void)getTimelineWithType:(TimelineType)timelineType CompletetionBlock:(void(^)(id response, NSError *error))responseBlock
{
    NSString *timelineString = nil;
    switch (timelineType)
    {
        case TimelineTypeMentions:
        {
            timelineString = @"mentions_timeline";
        }
            break;
        case TimelineTypeUser:
        {
            timelineString = @"user_timeline";
        }
            break;
        case TimelineTypeHome:
        {
            timelineString = @"home_timeline";
        }
            break;
        case TimelineTypeRetweets:
        {
            timelineString = @"retweets_of_me";
        }
            break;
            
        default:
            break;
    }
    
    ACAccountStore *twitterStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType = [twitterStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    //  Request permission from the user to access the available Twitter accounts
    [twitterStore requestAccessToAccountsWithType:twitterAccountType options:nil completion:^(BOOL granted, NSError *error)
     {
         if (!granted)
         {
             responseBlock(nil,error);
         }
         else
         {
             NSArray *twitterAccounts =
             [twitterStore accountsWithAccountType:twitterAccountType];
             
             if ([twitterAccounts count] > 0)
             {
                 ACAccount *account = [twitterAccounts objectAtIndex:0];
                 
                 //  The endpoint that we wish to call
//                 NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/%@.json",timelineString]];
                 
                 NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/followers/list.json"]];

                 //  Build the request with our parameter
                 SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                         requestMethod:SLRequestMethodPOST
                                                                   URL:url
                                                            parameters:nil];
                 
                 // Attach the account object to this request
                 [request setAccount:account];
                 
                 [request performRequestWithHandler:
                  ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                  {
                      if (!responseData)
                      {
                          responseBlock(nil,error);
                      }
                      else
                      {
                          
                          NSError *jsonError;
                          NSDictionary *timeline = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&jsonError];
                          if (timeline)
                          {
                              responseBlock(timeline,error);
                          }
                          else
                          {
                              responseBlock(timeline,error);
                          }
                      }
                  }];
             }
             else
             {
                 responseBlock(nil,error);
             }
         }
     }];

}

+ (void)getUserDetailsWithCompletetionBlock:(void(^)(id response, NSError *error))responseBlock
{
    ACAccountStore *twitterStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType = [twitterStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    //  Request permission from the user to access the available Twitter accounts
    [twitterStore requestAccessToAccountsWithType:twitterAccountType options:nil completion:^(BOOL granted, NSError *error)
     {
         if (!granted)
         {
             responseBlock(nil,error);
         }
         else
         {
             NSArray *twitterAccounts =
             [twitterStore accountsWithAccountType:twitterAccountType];
             
             if ([twitterAccounts count] > 0)
             {
                 ACAccount *account = [twitterAccounts objectAtIndex:0];
                 
                 //  The endpoint that we wish to call
                 //                 NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/%@.json",timelineString]];
                 
                 NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/1.1/users/show.json"]];
                 NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
                 [params setObject:[NSString stringWithFormat:@"%@",((NSDictionary*)[account valueForKey:@"properties"])[@"user_id"]] forKey:@"user_id"];
                 //[params setObject:@"false" forKey:@"include_user_entities"];
                 [params setObject:account.username forKey:@"screen_name"];
                 //  Build the request with our parameter
                 SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                         requestMethod:SLRequestMethodGET
                                                                   URL:url
                                                            parameters:params];
                 
                 // Attach the account object to this request
                 [request setAccount:account];
                 
                 [request performRequestWithHandler:
                  ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                  {
                      if (!responseData)
                      {
                          responseBlock(nil,error);
                      }
                      else
                      {
                          
                          NSError *jsonError;
                          NSDictionary *timeline = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&jsonError];
                          if (timeline)
                          {
                              responseBlock(timeline,error);
                          }
                          else
                          {
                              responseBlock(timeline,error);
                          }
                      }
                  }];
             }
             else
             {
                 responseBlock(nil,error);
             }
         }
     }];
    
}



+ (void)searchTweetsWithText:(NSString*)searchText completetionBlock:(void(^)(id response, NSError *error))responseBlock
{
    ACAccountStore *twitterStore = [[ACAccountStore alloc] init];
    ACAccountType *twitterAccountType = [twitterStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [twitterStore requestAccessToAccountsWithType:twitterAccountType options:nil completion:^(BOOL granted, NSError *error)
     {
         if (!granted)
         {
             responseBlock(nil,error);
         }
         else
         {
             NSArray *twitterAccounts =
             [twitterStore accountsWithAccountType:twitterAccountType];
             
             if ([twitterAccounts count] > 0)
             {
                 ACAccount *account = [twitterAccounts objectAtIndex:0];
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
                 
                 NSDictionary *params = @{@"q": searchText,@"count":@"100"};
                 
                 //  Build the request with our parameter
                 SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                         requestMethod:SLRequestMethodPOST
                                                                   URL:url
                                                            parameters:params];

                 
                 // Attach the account object to this request
                 
                 [request setAccount:account];
                 
                 [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
                  {
                      if (!responseData)
                      {
                          responseBlock(nil,error);
                      }
                      else
                      {
                          
                          NSError *jsonError;
                          NSDictionary *timeline = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&jsonError];
                          if (timeline)
                          {
                              responseBlock(timeline,error);
                          }
                          else
                          {
                              responseBlock(timeline,error);
                          }
                      }
                  }];
             }
             else
             {
                 responseBlock(nil,error);
             }
         }
     }];
}


- (void)loginWithTwitterWithCompletion:(void (^)(id response))block
{
  self.twitterACAccountStore = [[ACAccountStore alloc] init];
  ACAccountType *twitterTypeAccount = [self.twitterACAccountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
  
  [self.twitterACAccountStore requestAccessToAccountsWithType:twitterTypeAccount
                                                      options:nil
                                                   completion:^(BOOL granted, NSError *error) {
                                                     if(granted){
                                                       NSArray *accounts = [self.twitterACAccountStore accountsWithAccountType:twitterTypeAccount];
                                                       if(accounts.count==0)
                                                       {
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                           block(nil);
                                                           //Show alert
//                                                           [Utils showAlertViewWithMessage:kTwitterPermissionOfLogin];
                                                         });
                                                         return ;
                                                       }
                                                       
                                                       ACAccount *twitterAccount=[accounts objectAtIndex:0];
                                                       NSLog(@"Success");
                                                       //NSURL *meurl = [NSURL URLWithString:@"http://api.twitter.com/1.1/users/show.json"];
                                                       NSURL *meurl = [NSURL URLWithString:@"https://api.twitter.com/1/account/verify_credentials.json"];
                                                       
                                                       //NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"",@"screen_name",nil];
                                                       
                                                       SLRequest *merequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                                                                 requestMethod:SLRequestMethodGET
                                                                                                           URL:meurl
                                                                                                    parameters:nil];
                                                       
                                                       merequest.account = twitterAccount;
                                                       
                                                       [merequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                                                         //NSString *meDataString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                                                         
                                                         //DLog(@"%@", meDataString);
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                           if(error)
                                                           {
                                                             block(nil);
                                                             //Show alert
                                                           }
                                                           else
                                                           {
                                                             NSDictionary *jsonDict=[NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                                                             block(jsonDict);
                                                             NSLog(@"twitter info :  %@",jsonDict);
                                                           }
                                                           
                                                         });
                                                       }];
                                                       
                                                       
                                                     }
                                                     else
                                                     {
                                                       // ouch
                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                         block(nil);
                                                         //Show alert
                                                       });
                                                       NSLog(@"Fail");
                                                       NSLog(@"Error: %@", error);
                                                     }
                                                   }];
  
}

@end
