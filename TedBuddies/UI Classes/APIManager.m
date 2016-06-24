//
//  APIManager.m
//  GiphyClient
//
//  Created by Jared Halpern on 9/11/15.
//  Copyright (c) 2015 byteMason. All rights reserved.
//

#import "Constants.h"
#import "APIManager.h"

@interface APIManager ()

@end

@implementation APIManager

+ (APIManager *)sharedManager
{
  static APIManager *_sharedManager;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    _sharedManager = [[APIManager alloc] init];
  });
  
  return _sharedManager;
}


- (void)searchTerms:(NSString *)terms withOffset:(NSInteger)offset andCompletion:(void (^)(NSArray *data, NSString *searchTerms, NSInteger offset))completion
{
    
    
    
    NSString *str = [NSString stringWithFormat:@"%@%@?q=%@&api_key=%@&offset=%@&limit=%@",kAPIHostURL,kEndpointSearch,terms,kGiphyPublicKey,@(offset),@(kWindowSize) ];
    
    str=[str stringByAddingPercentEscapesUsingEncoding:
         NSUTF8StringEncoding];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kAPIHostURL]];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                            path:str
                                                      parameters:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Print the response body in text
        NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        NSDictionary *dictionary=[NSJSONSerialization JSONObjectWithData:responseObject  options:kNilOptions error:nil];
        NSArray *data = [dictionary objectForKey:@"data"];
        NSInteger newOffset = [[dictionary objectForKey:@"pagination"][@"offset"] integerValue];
        
        if (completion) {
            completion(data, terms, newOffset);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (completion) {
            completion(nil, nil, 0);
        }
    }];
    [operation start];
    
  /*NSDictionary *parameters = @{@"api_key" : kGiphyPublicKey, @"q" : terms, @"offset" : @(offset), @"limit" : @(kWindowSize)};
  
  [self.requestOperationManager GET:kEndpointSearch parameters:parameters success:^(NSURLSessionTask *task , id responseObject) {
    NSArray *data = [responseObject objectForKey:@"data"];
    NSInteger newOffset = [[responseObject objectForKey:@"pagination"][@"offset"] integerValue];

    if (completion) {
      completion(data, terms, newOffset);
    }
  } failure:^(NSURLSessionTask *task, NSError *error) {
    
    NSLog(@"%s - error: %@", __PRETTY_FUNCTION__, error.description);
    if (completion) {
      completion(nil, nil, 0);
    }
  }];*/
}

- (void)getTrendingGifsWithOffset:(NSInteger)offset andCompletion:(void (^)(NSArray *data, NSInteger offset))completion
{
    
    NSString *str = [NSString stringWithFormat:@"%@%@?api_key=%@&offset=%@&limit=%@",kAPIHostURL,kEndpointTrending,kGiphyPublicKey,@(offset),@(kWindowSize) ];
    
    str=[str stringByAddingPercentEscapesUsingEncoding:
         NSUTF8StringEncoding];
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kAPIHostURL]];
    NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                            path:str
                                                      parameters:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Print the response body in text
        NSLog(@"Response: %@", [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
        NSDictionary *dictionary=[NSJSONSerialization JSONObjectWithData:responseObject  options:kNilOptions error:nil];
        NSArray *data = [dictionary objectForKey:@"data"];
        NSInteger newOffset = [[dictionary objectForKey:@"pagination"][@"offset"] integerValue];
        
        if (completion) {
            completion(data, newOffset);
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        if (completion) {
            completion(nil, 0);
        }
    }];
    [operation start];

    
    /*
  NSDictionary *parameters = @{@"api_key" : kGiphyPublicKey, @"offset" : @(offset), @"limit" : @(kWindowSize)};
  
  [self.requestOperationManager GET:kEndpointTrending parameters:parameters success:^(NSURLSessionTask *task, id responseObject) {
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
      NSArray *data = (NSArray *)[responseObject objectForKey:@"data"];
      NSInteger newOffset = [[responseObject objectForKey:@"pagination"][@"offset"] integerValue];
      //      NSLog(@"%s - data: %@", __PRETTY_FUNCTION__, data);
      if (completion) {
        completion(data, newOffset);
      }
    }
  } failure:^(NSURLSessionTask *task, NSError *error) {
    
    NSLog(@"%s - error: %@", __PRETTY_FUNCTION__, error.description);
    if (completion) {
      completion(nil, 0);
    }
  }];
     */
     }

@end
