//
//  TAFacebookHelper.h
//  PhotoAlbum
//
//  Created by Mayank Pahuja on 05/08/13.
//  Copyright (c) 2013 Mayank Pahuja. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import <FacebookSDK/FacebookSDK.h>

@interface TAFacebookHelper : NSObject
{
    
}


/*
                                BASIC SETUP GUIDELINES
 
    1. Add FacebookSDK 3.5
    2. Add FacebookAppID key in the plist and add your facebook appId corresponding to that. The bundle identifier should be same as entered in App settings on developer.facebook.com
    3. Add TAFacebookHelper.h and TAFacebookHelper.m
    4. Add Security.framework
    5. Add AdSupport.framework
    6. Add libsqlite3.0.dylib
    7. Add Social.framework
    8. Add Account.framework
 
    ADD THIS METHOD IN APP DELEGATE
     - (BOOL)application:(UIApplication *)application
     openURL:(NSURL *)url
     sourceApplication:(NSString *)sourceApplication
     annotation:(id)annotation 
    {
        return [FBSession.activeSession handleOpenURL:url];
    }

 
 */



/*
    fetchPersonalInfoWithParams is for fetching all the user details.
    fetchFriendListWithParams is for getting all the friends that user has.
 
    The params field should contain all the parameters which you require to query from the graph api. Use this link to get the list of all valid fields:
    https://developers.facebook.com/docs/reference/api/user/
 
    The permissions field should contain all required permissions coreespending to the fields you are querying
     example:
 
 
 permissionArray:
 NSArray *permissionsArray = [[NSArray alloc] initWithObjects:
 @"public_profile",
 @"email",
 @"user_friends",
 nil];
 
 
 params:
 @"id,picture,name,last_name,email,first_name"
 
     NSArray *permissionsArray = [[[NSArray alloc] initWithObjects:
     @"read_stream",
     @"user_birthday",
     @"email",
     nil] autorelease];
 
 */
+ (void)fetchPersonalInfoWithParams:(NSString*)params withPermissions:(NSArray*)permissions completionHandler:(void(^)(id response, NSError *e))completionBlock;

+ (void)fetchFriendListWithParams:(NSString*)params withPermissions:(NSArray*)permissions completionHandler:(void(^)(id response, NSError *e))completionBlock;
+ (void)fetchLatestPhotosWithParams:(NSString*)params withPermissions:(NSArray*)permissions completionHandler:(void(^)(id response, NSError *e))completionBlock;
/*
    uploadVideowithPath should be used for uploading videos to the facebook. All the required permissions have alredy been included.
    
    filePath should contain the path of the video in your bundle
 
    videoTitle could be any suitable title for the 
    videoDesc could be used if you require to give any aditional description
 */
+ (void)uploadVideowithPath:(NSString*)filePath withTitle:(NSString*)videoTitle andDescription:(NSString*)videoDesc completertionHandler:(void(^)(id response,NSError *e))completionBlock;

/*
    uploadPhotoToAlbum should be used for uploading photos to the facebook. All the required permissions have alredy been included. If an album with that name exists then the image is added to that album else a new album is created.
 
    albumName: Any suitable album name.
    imageSource: UIImage object for the image to be uploaded
 */

+ (void)uploadPhotoToAlbum:(NSString*)albumName withImage:(UIImage*)imageSource completertionHandler:(void(^)(id response,NSError *e))completionBlock;
+ (void)makeAlbumwitName:(NSString*)albumName forImage:(UIImage*)imageToUpload completertionHandler:(void(^)(id response,NSError *e))completionBlock;
/*
    makeAlbumwitName should be used to creae a new photo album
 */
+ (void)makeAlbumwitName:(NSString*)albumName completertionHandler:(void(^)(id response,NSError *e))completionBlock;

/*
    tagPhotoWithId should be used to tag photos on facebook.
 
    photo_id: id of the photo to be tagged
    uidArray: array containing the id of the people to be tagged
 */
+ (void)tagPhotoWithId:(NSString*)photo_id withPeople:(NSArray*)uidArray completertionHandler:(void(^)(id response,NSError *e))completionBlock;

/*
 
 */

+ (void)postText:(NSString*)text OnFriendsWall:(NSString*)friendId completetionHandler:(void(^)(id resultSend, NSError *e))handler;
+ (void)postText:(NSString*)text completetionHandler:(void(^)(id resultSend, NSError *e))handler;
+ (void)getVideoLikesWithId:(NSString*)videoId completertionHandler:(void(^)(id response,NSError *e))completionBlock;

+ (void)postAudio;
@end
