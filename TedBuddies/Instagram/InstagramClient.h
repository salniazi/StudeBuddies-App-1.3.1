//
//  InstagramClient.h
//  TedBuddies
//
//  Created by Sourabh Shekhar Singh on 02/12/15.
//  Copyright © 2015 Mayank Pahuja. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPClient.h"

typedef enum LoginType
{
    kLoginTypeEmail = 1,
    kLoginTypeFacebook,
    kLoginTypeTwitter,
    kLoginTypeInstagram
}   loginTypes;


extern NSString* const kUserAccessTokenKey;
extern NSString * const kUserInstagramId;
extern NSString * const kUserInstagramFullname;
extern NSString * const kUserInstagramProfilePicture;
extern NSString * const kUserInstagramusername;


extern NSString * const kInstagramBaseURLString;
extern NSString * const kClientId;
extern NSString * const kRedirectUrl;

// Endpoints
extern NSString * const kUserInformation;
extern NSString * const kLocationsEndpoint;
extern NSString * const kLocationsMediaRecentEndpoint;
extern NSString * const kUserMediaRecentEndpoint;
extern NSString * const kAuthenticationEndpoint;


@interface InstagramClient : AFHTTPClient

+ (InstagramClient *)sharedClient;
- (id)initWithBaseURL:(NSURL *)url;


@end
