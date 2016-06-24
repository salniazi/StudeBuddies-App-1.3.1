//
//  TAFacebookHelperV2.h
//  TedBuddies
//
//  Created by Mayank Pahuja on 14/08/14.
//  Copyright (c) 2014 Mayank Pahuja. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TAFacebookHelperV2 : NSObject
+ (void)shareLinkOnWall:(NSString*)link withCompletionHandler:(void(^)(id response, NSError *error))handler;

@end
