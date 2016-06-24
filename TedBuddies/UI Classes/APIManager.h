//
//  APIManager.h
//  GiphyClient
//
//  Created by Jared Halpern on 9/11/15.
//  Copyright (c) 2015 byteMason. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface APIManager : NSObject
+ (APIManager *)sharedManager;
- (void)searchTerms:(NSString *)terms withOffset:(NSInteger)offset andCompletion:(void (^)(NSArray *data, NSString *searchTerms, NSInteger offset))completion;
- (void)getTrendingGifsWithOffset:(NSInteger)offset andCompletion:(void (^)(NSArray *data, NSInteger offset))completion;
@end