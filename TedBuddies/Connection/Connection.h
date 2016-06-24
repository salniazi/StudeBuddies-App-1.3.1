//
//  AddNewKidViewC.m
//  PickMyKidParent
//
//  Created by Ashish on 04/02/14.
//  Copyright (c) 2014 TechAhead. All rights reserved.
//


////FrameWork required
//SystemConfiguration framework
//CFNetwork framework


#import <Foundation/Foundation.h>


@interface Connection : NSObject<NSURLConnectionDelegate> {
    
    
    //Callback blocks
    void (^successCallback)(id response);
    void (^failCallback)(NSError *error);
}

+(Connection*)sharedInstance;
+(void)callServiceWithImagesAndDocsImage:(NSMutableArray *)imagesArray DocsImageArray:(NSMutableArray *)docsArray params:(NSDictionary *)params  serviceIdentifier:(NSString*)serviceName callBackBlock:(void (^)(id response,NSError *error))responeBlock;
+ (void)callServiceWithName:(NSString *)serviceName postData:(NSDictionary*)postData callBackBlock:(void (^)(id response,NSError *error))responeBlock;
+(void)callServiceWithImages:(NSMutableArray *)imagesArray params:(NSDictionary *)params  serviceIdentifier:(NSString*)serviceName callBackBlock:(void (^)(id response,NSError *error))responeBlock;
+(void)callServiceWithImages:(NSMutableArray *)imagesArray videos:(NSMutableArray *)videosArray params:(NSDictionary *)params  serviceIdentifier:(NSString*)serviceName callBackBlock:(void (^)(id response,NSError *error))responeBlock;
+(void)uploadImages:(NSMutableArray *)imageArray andVideos:(NSMutableArray *)videoArray params:(NSDictionary *)params  serviceIdentifier:(NSString*)serviceName callBackBlock:(void (^)(id response,NSError *error))responeBlock progress:(void(^)(float progress))progressBlock;

+(void)callServiceWithImagesTest:(NSMutableArray *)imagesArray params:(NSDictionary *)params  serviceIdentifier:(NSString*)serviceName callBackBlock:(void (^)(id response,NSError *error))responeBlock;
+(void)callServiceWithImages:(NSMutableArray *)imagesArray Documents:(NSMutableArray *)docsArray params:(NSDictionary *)params  serviceIdentifier:(NSString*)serviceName callBackBlock:(void (^)(id response,NSError *error))responeBlock;
+(void)uploadImage:(UIImage *)imageToUpload allBackBlock:(void (^)(id response,NSError *error))responeBlock;

+(void)callServiceWithDocument:(NSMutableArray *)docsArray params:(NSDictionary *)params  serviceIdentifier:(NSString*)serviceName callBackBlock:(void (^)(id response,NSError *error))responeBlock;
@end
