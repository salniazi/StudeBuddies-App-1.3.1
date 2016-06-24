//
//  InstagramUserMedia.m
//  TedBuddies
//
//  Created by Sourabh Shekhar Singh on 21/01/16.
//  Copyright © 2016 Mayank Pahuja. All rights reserved.
//

#import "InstagramUserMedia.h"
#import "InstagramClient.h"

@implementation InstagramUserMedia

@synthesize thumbnailUrl = _thumbnailUrl;
@synthesize standardUrl = _standardUrl;
@synthesize likes = _likes;

- (id)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.thumbnailUrl = [[[attributes valueForKeyPath:@"images"] valueForKeyPath:@"thumbnail"] valueForKeyPath:@"url"];
    self.standardUrl = [[[attributes valueForKeyPath:@"images"] valueForKeyPath:@"standard_resolution"] valueForKeyPath:@"url"];
    self.likes = [[[attributes objectForKey:@"likes"] valueForKey:@"count"] integerValue];
    return self;
}

+ (void)getUserMediaWithId:(NSString*)userId
           withAccessToken:(NSString *)accessToken
                     block:(void (^)(NSArray *records))block
{
    NSDictionary* params = [NSDictionary dictionaryWithObject:accessToken forKey:@"access_token"];
    NSString* path = [NSString stringWithFormat:kUserMediaRecentEndpoint, userId];
    
    [[InstagramClient sharedClient] getPath:path
                             parameters:params
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    NSMutableArray *mutableRecords = [NSMutableArray array];
                                    NSArray* data = [responseObject objectForKey:@"data"];
                                    for (NSDictionary* obj in data) {
                                        InstagramUserMedia* media = [[InstagramUserMedia alloc] initWithAttributes:obj];
                                        [mutableRecords addObject:media];
                                    }
                                    if (block) {
                                        block([NSArray arrayWithArray:mutableRecords]);
                                    }
                                }
                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    NSLog(@"error: %@", error.localizedDescription);
                                    if (block) {
                                        block([NSArray array]);
                                    }
                                }];
}


@end
