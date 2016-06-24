//
//  InstagramUserMedia.h
//  TedBuddies
//
//  Created by Sourabh Shekhar Singh on 21/01/16.
//  Copyright © 2016 Mayank Pahuja. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InstagramUserMedia : NSObject

@property (nonatomic, strong) NSString* thumbnailUrl;
@property (nonatomic, strong) NSString* standardUrl;
@property (nonatomic, assign) NSUInteger likes;

+ (void)getUserMediaWithId:(NSString*)userId
           withAccessToken:(NSString*)accessToken
                     block:(void (^)(NSArray *records))block;


@end
