//
//  InstagramClient.m
//  TedBuddies
//
//  Created by Sourabh Shekhar Singh on 02/12/15.
//  Copyright © 2015 Mayank Pahuja. All rights reserved.
//

#import "InstagramClient.h"

#import "AFJSONRequestOperation.h"

NSString* const kUserAccessTokenKey = @"kUserAccessTokenKey";
NSString* const kUserInstagramId = @"kUserInstagramId";
NSString * const kUserInstagramFullname = @"kUserInstagramFullname";
NSString * const kUserInstagramProfilePicture = @"kUserInstagramProfilePicture";
NSString * const kUserInstagramusername = @"kUserInstagramusername";

NSString * const kInstagramBaseURLString = @"https://api.instagram.com/v1/";
//#warning Include your client id from instagr.am
NSString * const kClientId = @"2b8a4586219d44579ef89fbbdb7c5f5f";

//#warning Include your redirect uri
NSString * const kRedirectUrl = @"http://www.studebuddies.com/";


// Endpoints
NSString * const kUserInformation = @"users/%@";
NSString * const kLocationsEndpoint = @"locations/search";
NSString * const kLocationsMediaRecentEndpoint = @"locations/%@/media/recent";
NSString * const kUserMediaRecentEndpoint = @"users/%@/media/recent";
NSString * const kAuthenticationEndpoint =
@"https://instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=token";




@implementation InstagramClient

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [self setDefaultHeader:@"Accept" value:@"application/json"];
    
    return self;
}

+ (InstagramClient *)sharedClient
{
    static InstagramClient * _sharedClient = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:kInstagramBaseURLString]];
    });
    
    return _sharedClient;
}


@end
