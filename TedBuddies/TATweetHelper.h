//
//  TATweetHelper.h
//  TAFacebookHelperDemo
//
//  Created by Mayank Pahuja on 08/08/13.
//  Copyright (c) 2013 Mayank Pahuja. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <Twitter/TWRequest.h>
#import <Twitter/TWTweetComposeViewController.h>
#import <Accounts/Accounts.h>
/*
     BASIC SETUP GUIDELINES
     1. Add TATweetHelper.h and TATweetHelper.m
     2. Add Twitter.framework
     3. Add Social.framework
     4. Add Account.framework
 */


typedef enum Timeline
{
    TimelineTypeMentions,   //Returns the 20 most recent mentions (tweets containing a users's @screen_name)
    TimelineTypeUser,       //Returns a collection of the most recent Tweets posted by the user
    TimelineTypeHome,       //Returns a collection of the most recent Tweets and retweets posted by the authenticating user and the users they follow
    TimelineTypeRetweets    //Returns the most recent tweets authored by the authenticating user that have been retweeted by others. 
}TimelineType;


typedef enum List
{
    ListTypeFollowers,      //Returns a cursored collection of user objects for users following the specified user. Results are given in groups of 20 users.
    ListTypeFollowing       // Returns a cursored collection of user objects for every user the specified user is following. Results are given in groups of 20 users.
}ListType;

@interface TATweetHelper : NSObject
/*
 return singleton object of this class
 */
+(TATweetHelper*)sharedInstance;

/*
    getListWithType should be used for getting friends or followers list.
 
    listType: pass the desired list type you want to get from ListType enum.
    pageNumber: The default pagenumber is -1. You will get 20 results per page, increment the pagenumber by 1 for successive pages.
 */
+ (void)getListWithType:(ListType)listType WithPageNumber:(NSInteger)pageNum completetionBlock:(void(^)(id response, NSError *error))responseBlock;


/*
     postStatus should be used for posting a simple text tweet. The limit per tweet is up to 140 characters.
     
     status: Enter the text for the tweet. There are some special commands in this field to be aware of(https://support.twitter.com/articles/14020-twitter-for-sms-basic-features). For instance, preceding a message with "D " or "M " and following it with a screen name can create a direct message to that user if the relationship allows for it.
 */
+ (void)postStatus:(NSString*)status completetionBlock:(void(^)(id response, NSError *error))responseBlock;

/*
     postStatus: withImage: should be used for posting a simple text tweet with Image.
     
     status: Enter the text for the tweet. 
     imageToUpload: UIImage object for image to be uploaded
 */
+ (void)postStatus:(NSString*)status withImage:(UIImage*)imageToUpload completetionBlock:(void(^)(id response, NSError *error))responseBlock;

/*
    getTimelineWithType should be used for getting all the objects on users timeline corresponding to the TimelineType you pass
 
    TimelineType: pass the desired timeline type you want to get from TimelineType enum. See enum for more description.
 */
+ (void)getTimelineWithType:(TimelineType)timelineType CompletetionBlock:(void(^)(id response, NSError *error))responseBlock;
/*
  
 */
+ (void)getUserDetailsWithCompletetionBlock:(void(^)(id response, NSError *error))responseBlock;


+ (void)searchTweetsWithText:(NSString*)searchText completetionBlock:(void(^)(id response, NSError *error))responseBlock;
+ (void)storeAccountWithAccessToken:(NSString *)token secret:(NSString *)secret completion:(void(^)(NSError *error))complete;


+(void)connectToTwitter:(void(^)(NSError *error))complete;
+(void)getTwitterFollowersWithcompleteBlock:(void(^)(NSMutableArray *resultArray))complete;

- (void)loginWithTwitterWithCompletion:(void (^)(id response))block;

@end
