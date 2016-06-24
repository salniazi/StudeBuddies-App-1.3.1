//
//  AddNewKidViewC.m
//  PickMyKidParent
//
//  Created by Ashish on 04/02/14.
//  Copyright (c) 2014 TechAhead. All rights reserved.
//

//FrameWork required
//SystemConfiguration framework
//CFNetwork framework

#import "Connection.h"
#import "AFNetworking.h"
#import "Reachability.h"
#import "TAAESCrypt.h"





#define kAuthentication     @"Authentication"                    //Header key of request  encrypt data
#define kEncryptionKey      @"tedbuddy"                    //Encryption key replace this with your projectname
#define kBundleVersion      @"BundleVersion"

@implementation Connection


//shared instance
+(Connection*)sharedInstance
{
    static Connection* sharedObj = nil;
    if (sharedObj == nil) {
        sharedObj = [[Connection alloc] init];
    }
    return sharedObj;
}

#pragma check internet connection
+(BOOL)isInternetAvailable
{
    BOOL isInternetAvailable = false;
    Reachability *internetReach = [Reachability reachabilityForInternetConnection];
    [internetReach startNotifier];
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    switch (netStatus)
    {
        case NotReachable:
            isInternetAvailable = FALSE;
            break;
        case ReachableViaWWAN:
            isInternetAvailable = TRUE;
            break;
        case ReachableViaWiFi:
            isInternetAvailable = TRUE;
            break;
    }
    [internetReach stopNotifier];
    return isInternetAvailable;
}

#pragma mark showInternetAlert -----------------------------------------------------


+(void)showInternetAlert
{
    [Utils stopLoader];
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Connection error" message:@"Please check your internet connection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark showServerErrorAlert
+(void)showServerErrorAlert
{
    [Utils stopLoader];
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Server error" message:@"Please try again" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - callServiceWithName

+ (void)callServiceWithName:(NSString *)serviceName postData:(NSDictionary*)postData callBackBlock:(void (^)(id response,NSError *error))responeBlock
{
    if (![Connection isInternetAvailable])
    {
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"Please check your internet connection." forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"internet error" code:-1 userInfo:dictionary];
        //responeBlock(nil,error);
        [Connection showInternetAlert];
        return;
        
    }
    NSString *urlString = [NSString stringWithFormat:@"%@%@",kBaseURL,serviceName];
    
    NSURL *baseUrl=[NSURL URLWithString:kBaseURL];
    
    DLog(@"Request for URL :%@  \n Parameters \n %@",urlString,[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:postData options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]);
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseUrl];
    
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setParameterEncoding:AFJSONParameterEncoding];
    
    NSString *bundleVersion=[NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
    NSMutableURLRequest *mutableRequest;
    if ([serviceName isEqualToString:kGetProfessorList]   )
    {
        serviceName=[NSString stringWithFormat:@"%@?id=%@",serviceName,[postData valueForKey:@"id"]];
       mutableRequest = [client requestWithMethod:@"GET" path:serviceName parameters:nil];
    }
    else if ([serviceName isEqualToString:kSendNoCourseNotificationForUniversity])
    {
        serviceName=[NSString stringWithFormat:@"%@?Universityid=%@",serviceName,[postData valueForKey:@"Universityid"]];
        mutableRequest = [client requestWithMethod:@"GET" path:serviceName parameters:nil];
    }
    else if ([serviceName isEqualToString:kGetBookDetailFromISBN])
    {
        serviceName=[NSString stringWithFormat:@"%@?%@=%@",serviceName,kISBN,[postData valueForKey:kISBN]];
        mutableRequest = [client requestWithMethod:@"GET" path:serviceName parameters:nil];
    }

    else
    {
        mutableRequest = [client requestWithMethod:@"POST" path:serviceName parameters:postData];
    }
   
      [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    if ([serviceName isEqualToString:kCheckUniversityCredentials])
    {
        
        [mutableRequest setValue:[Connection encryptRequestString:@"web60134"] forHTTPHeaderField:kAuthentication];
        [mutableRequest setTimeoutInterval:180];
    }
    else
    {
        [mutableRequest setValue:[Connection encryptRequestString:serviceName] forHTTPHeaderField:kAuthentication];

    }
   
    [mutableRequest setValue:bundleVersion forHTTPHeaderField:kBundleVersion];
    

    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:mutableRequest
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON){
                                             
                                             DLog(@"Response for %@ \n%@",serviceName,[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:JSON options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]);
                                             
                                             responeBlock(JSON,nil);
                                             
                                         }
                                         
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             DLog(@"Failed :  Reason->%@",error);
                                             responeBlock(nil,error);
                                             //[Connection showServerErrorAlert];
                                             
                                         }];
    
    
    [client enqueueHTTPRequestOperation:operation];
    
    
}

#pragma mark - callServiceWithImages

+(void)callServiceWithImages:(NSMutableArray *)imagesArray params:(NSDictionary *)params  serviceIdentifier:(NSString*)serviceName callBackBlock:(void (^)(id response,NSError *error))responeBlock
{
    if (![Connection isInternetAvailable])
    {
        NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"Please check your internet connection." forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"internet error" code:-1 userInfo:dictionary];
        //responeBlock(nil,error);
        [Connection showInternetAlert];
        return;
    }
    
//    UIImage *imageToupload = [imagesArray objectAtIndex:0];
//    NSData *imageData = UIImageJPEGRepresentation(imageToupload, .5);
//    NSURL *baseURL = [NSURL URLWithString:@"http://studebuddies.com/ScheduleUploadWS.asmx?op=UploadScheduleImage"];
//    
//    NSString *soapBody = @"<?xml version=\"1.0\" encoding=\"utf-8\"?><soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"><soap:Body>    <UploadScheduleImage xmlns=\"http://studebuddies.com/scheduleuploadws\"/></soap:Body></soap:Envelope>";
//    NSString *dataLength = [NSString stringWithFormat:@"%lu",(unsigned long)[soapBody length]];
//    
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:baseURL];
//    [request setHTTPBody:[soapBody dataUsingEncoding:NSUTF8StringEncoding]];
//    [request addValue:@"studebuddies.com" forHTTPHeaderField:@"Host"];
//
//    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//    [request addValue:@"http://studebuddies.com/scheduleuploadws/UploadScheduleImage" forHTTPHeaderField:@"SOAPAction"];
//    [request addValue:dataLength forHTTPHeaderField:@"Content-Length"];
//
//    [request setHTTPMethod:@"POST"];
//    NSString *boundry = @"---------------AF7DAFCDEFAB809";
//    NSMutableData *data = [NSMutableData dataWithCapacity:300 * 1024];
//    
//    [data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n\r\n", @"field name"]
//                      dataUsingEncoding:NSUTF8StringEncoding]];
//    [data appendData:imageData];   // data upload
//    [data appendData:[@"\r\n"
//                      dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    [data appendData:[[NSString stringWithFormat:@"--%@\r--\n",boundry]
//                      dataUsingEncoding:NSUTF8StringEncoding]];
//    
//    request.HTTPBody = data;
//
//    //[request addValue:@"http://tempuri.org/GetAll" forHTTPHeaderField:@"SOAPAction"];
//    
//    //[request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
//    
//    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    
//    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        // do whatever you'd like here; for example, if you want to convert
//        // it to a string and log it, you might do something like:
//        
//        NSString *string = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"%@", string);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"%s: AFHTTPRequestOperation error: %@", __FUNCTION__, error);
//    }];
//    [operation start];
//    
////    UIImage *imageToupload = [imagesArray objectAtIndex:0];
////    NSData *imageData = UIImageJPEGRepresentation(imageToupload, 1);
////    NSURL *rlStr = [NSURL URLWithString:@"http://studebuddies.com/ScheduleUploadWS.asmx?op=UploadScheduleImage"];
////    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:rlStr];
////    
////    [request addValue:@"studebuddies.com" forHTTPHeaderField:@"Host"];
////    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
////    [request addValue:@"http://studebuddies.com/scheduleuploadws/UploadScheduleImage" forHTTPHeaderField:@"SOAPAction"];
////    [request addValue:@"length" forHTTPHeaderField:@"Content-Length"];
////    [request setHTTPMethod:@"POST"];
////    [request setHTTPBody:imageData];
////    
////    // Create url connection and fire request
////    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
////    [conn start];
//    /*
    
    NSURL *urlstring=[NSURL URLWithString:[kBaseURL stringByAppendingString:serviceName]];
    
    NSURL *baseUrl=[NSURL URLWithString:kBaseURL];
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseUrl];
    
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setParameterEncoding:AFJSONParameterEncoding];
    
    DLog(@"Request for URL :%@  \n Parameters \n %@",urlstring,[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]);
    
    
    NSMutableURLRequest *request = nil;
    
    request = [client multipartFormRequestWithMethod:@"POST" path:serviceName parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
       for(int i=0;i<[imagesArray count];i++)
       {
           NSString *fileName=[NSString stringWithFormat:@"image%d",i+1];
           NSString *imageName=[NSString stringWithFormat:@"image%d",i+1];
           UIImage *image = [imagesArray objectAtIndex:i];
           image = [image resizedImageByHeight:1200];
           
//           [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1.0) name:@"image" fileName:@"image.jpg" mimeType:@"image/jpeg"];
           DLog(@"image size = %d MB",[UIImageJPEGRepresentation(image, 1.0) length]/1024/1024);
           //DLog(@"imagebinary = %@",UIImageJPEGRepresentation(image, 1.0));
           [formData appendPartWithFileData:UIImageJPEGRepresentation(([imagesArray objectAtIndex:i]), .8) name:imageName fileName:fileName mimeType:@"image/jpeg"];
       }
    
        [formData appendPartWithFormData:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil] name:@"json"];

    }];
  
    [request setTimeoutInterval:100];
    //[request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *bundleVersion=[NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
    
    [request setValue:[Connection encryptRequestString:serviceName] forHTTPHeaderField:kAuthentication];
    [request setValue:bundleVersion forHTTPHeaderField:kBundleVersion];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON){
                                             
                                             DLog(@"Response for %@ \n%@",serviceName,[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:JSON options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]);

                                             responeBlock(JSON,nil);
                                             
                                         }
                                         
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             DLog(@"Failed :  Reason->%@",error);
                                             responeBlock(nil,error);
                                             [Connection showServerErrorAlert];
                                             
                                         }];
    
    
    [client enqueueHTTPRequestOperation:operation];
//    dispatch_after(3, dispatch_get_main_queue(), ^{
//        [Connection responseString:request];
//    });



}



+(void)callServiceWithDocument:(NSMutableArray *)docsArray params:(NSDictionary *)params  serviceIdentifier:(NSString*)serviceName callBackBlock:(void (^)(id response,NSError *error))responeBlock
{
    if (![Connection isInternetAvailable])
    {
        NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"Please check your internet connection." forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"internet error" code:-1 userInfo:dictionary];
        //responeBlock(nil,error);
        [Connection showInternetAlert];
        return;
    }
    
    
    NSURL *urlstring=[NSURL URLWithString:[kBaseURL stringByAppendingString:serviceName]];
    
    NSURL *baseUrl=[NSURL URLWithString:kBaseURL];
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseUrl];
    
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setParameterEncoding:AFJSONParameterEncoding];
    
    DLog(@"Request for URL :%@  \n Parameters \n %@",urlstring,[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]);
    
    
    NSMutableURLRequest *request = nil;
    
    request = [client multipartFormRequestWithMethod:@"POST" path:serviceName parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        for(int i=0;i<[docsArray count];i++)
        {
            if([[NSFileManager defaultManager] fileExistsAtPath:[docsArray objectAtIndex:i]])
            {
                NSError *err;
                
                NSURL *url = [NSURL fileURLWithPath:[docsArray objectAtIndex:i] ];
                
                NSArray *parts = [[docsArray objectAtIndex:i] componentsSeparatedByString:@"/"];
                NSString *filename = [parts lastObject];
                
                
                [formData appendPartWithFileURL:url name:filename error:&err];
                
            }

        }
        
        [formData appendPartWithFormData:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil] name:@"json"];
        
    }];
    
    [request setTimeoutInterval:100];
    //[request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *bundleVersion=[NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
    
    [request setValue:[Connection encryptRequestString:serviceName] forHTTPHeaderField:kAuthentication];
    [request setValue:bundleVersion forHTTPHeaderField:kBundleVersion];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON){
                                             
                                             DLog(@"Response for %@ \n%@",serviceName,[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:JSON options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]);
                                             
                                             responeBlock(JSON,nil);
                                             
                                         }
                                         
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             DLog(@"Failed :  Reason->%@",error);
                                             responeBlock(nil,error);
                                             [Connection showServerErrorAlert];
                                             
                                         }];
    
    
    [client enqueueHTTPRequestOperation:operation];
    //    dispatch_after(3, dispatch_get_main_queue(), ^{
    //        [Connection responseString:request];
    //    });
    
    
    
}

#pragma mark - callServiceWithImagesAndDocsImage

+(void)callServiceWithImagesAndDocsImage:(NSMutableArray *)imagesArray DocsImageArray:(NSMutableArray *)docsArray params:(NSDictionary *)params  serviceIdentifier:(NSString*)serviceName callBackBlock:(void (^)(id response,NSError *error))responeBlock
{
    if (![Connection isInternetAvailable])
    {
        NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"Please check your internet connection." forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"internet error" code:-1 userInfo:dictionary];
        //responeBlock(nil,error);
        [Connection showInternetAlert];
        return;
    }
    

    NSURL *urlstring=[NSURL URLWithString:[kBaseURL stringByAppendingString:serviceName]];
    
    NSURL *baseUrl=[NSURL URLWithString:kBaseURL];
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseUrl];
    
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setParameterEncoding:AFJSONParameterEncoding];
    
    DLog(@"Request for URL :%@  \n Parameters \n %@",urlstring,[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]);
    
    
    NSMutableURLRequest *request = nil;
    
    request = [client multipartFormRequestWithMethod:@"POST" path:serviceName parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        for(int i=0;i<[imagesArray count];i++)
        {
            NSString *fileName=[NSString stringWithFormat:@"image%d",i+1];
            NSString *imageName=[NSString stringWithFormat:@"image%d",i+1];
            UIImage *image = [imagesArray objectAtIndex:i];
            image = [image resizedImageByHeight:1200];
            
            //           [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1.0) name:@"image" fileName:@"image.jpg" mimeType:@"image/jpeg"];
            DLog(@"image size = %d MB",[UIImageJPEGRepresentation(image, 1.0) length]/1024/1024);
            
            [formData appendPartWithFileData:UIImageJPEGRepresentation(([imagesArray objectAtIndex:i]), .8) name:imageName fileName:fileName mimeType:@"image/jpeg"];
        }
        for(int i=0;i<[docsArray count];i++)
        {
            NSString *fileName=[NSString stringWithFormat:@"doc%d",i+1];
            NSString *imageName=[NSString stringWithFormat:@"doc%d",i+1];
            UIImage *image = [imagesArray objectAtIndex:i];
            image = [image resizedImageByHeight:1200];
            
            //           [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1.0) name:@"image" fileName:@"image.jpg" mimeType:@"image/jpeg"];
            DLog(@"image size = %d MB",[UIImageJPEGRepresentation(image, 1.0) length]/1024/1024);
            
            [formData appendPartWithFileData:UIImageJPEGRepresentation(([imagesArray objectAtIndex:i]), .8) name:imageName fileName:fileName mimeType:@"image/jpeg"];
        }
        
        [formData appendPartWithFormData:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil] name:@"json"];
        
    }];
    
    [request setTimeoutInterval:100];
    //[request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSString *bundleVersion=[NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
    
    [request setValue:[Connection encryptRequestString:serviceName] forHTTPHeaderField:kAuthentication];
    [request setValue:bundleVersion forHTTPHeaderField:kBundleVersion];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON){
                                             
                                             DLog(@"Response for %@ \n%@",serviceName,[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:JSON options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]);
                                             
                                             responeBlock(JSON,nil);
                                             
                                         }
                                         
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             DLog(@"Failed :  Reason->%@",error);
                                             responeBlock(nil,error);
                                             [Connection showServerErrorAlert];
                                             
                                         }];
    
    
    [client enqueueHTTPRequestOperation:operation];
    //    dispatch_after(3, dispatch_get_main_queue(), ^{
    //        [Connection responseString:request];
    //    });
    

}



#pragma mark - callServiceWith Images and Videos
+(void)callServiceWithImages:(NSMutableArray *)imagesArray videos:(NSMutableArray *)videosArray params:(NSDictionary *)params  serviceIdentifier:(NSString*)serviceName callBackBlock:(void (^)(id response,NSError *error))responeBlock
{
    if (![Connection isInternetAvailable])
    {
        NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"Please check your internet connection." forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"internet error" code:-1 userInfo:dictionary];
        //responeBlock(nil,error);
        [Connection showInternetAlert];
        return;
    }
    
    
    
    NSURL *urlstring=[NSURL URLWithString:[kBaseURL stringByAppendingString:serviceName]];
    
    NSURL *baseUrl=[NSURL URLWithString:kBaseURL];
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseUrl];
    
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setParameterEncoding:AFJSONParameterEncoding];
    
    DLog(@"Request for URL :%@  \n Parameters \n %@",urlstring,[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]);
    
    
    NSMutableURLRequest *request = nil;
    
    request = [client multipartFormRequestWithMethod:@"POST" path:serviceName parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [request setTimeoutInterval:600];
        [request setValue:@"multipart/form-data; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

        for(int i=0;i<[imagesArray count];i++)
        {
//            NSString *fileName=[NSString stringWithFormat:@"image%d.jpg",i+1];
//            NSString *imageName=[NSString stringWithFormat:@"image%d",i+1];
            
            UIImage *image = [imagesArray objectAtIndex:i];
            image = [image resizedImageByHeight:1200];
            
            [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1.0) name:@"image" fileName:@"image.jpg" mimeType:@"image/jpeg"];
            DLog(@"image size = %u MB",[UIImageJPEGRepresentation(image, 1.0) length]/1024/1024);
            
            //[formData appendPartWithFileData:UIImageJPEGRepresentation(([imagesArray objectAtIndex:i]), .8) name:@"image" fileName:@"image" mimeType:@"image/jpeg"];
        }
        
        for(int i=0;i<[videosArray count];i++)
        {
//            NSString *fileName=[NSString stringWithFormat:@"video%d",i+1];
//            NSString *videoName=[NSString stringWithFormat:@"video%d",i+1];
            
            [formData appendPartWithFileData:[videosArray objectAtIndex:i] name:@"video" fileName:@"video.mov" mimeType:@"video/mp4"];
            DLog(@"Video size = %.2f MB",(float)([[videosArray objectAtIndex:i] length])/1024/1024);

            //[formData appendPartWithFileData:[videosArray objectAtIndex:i] name:videoName fileName:fileName mimeType:@"video/mp4"];
        }

        
        [formData appendPartWithFormData:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil] name:@"json"];
        
    }];
    [request setTimeoutInterval:100];
    [request setValue:[Connection encryptRequestString:serviceName] forHTTPHeaderField:kAuthentication];
    NSString *bundleVersion=[NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
    [request setValue:bundleVersion forHTTPHeaderField:kBundleVersion];
    
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON){
                                             
                                             DLog(@"Response for %@ \n%@",serviceName,[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:JSON options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]);
                                             
                                             responeBlock(JSON,nil);
                                             
                                         }
                                         
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             DLog(@"Failed :  Reason->%@",error);
                                             responeBlock(nil,error);
                                             [Connection showServerErrorAlert];
                                             
                                         }];
    
    
    [client enqueueHTTPRequestOperation:operation];
     
    
    
}
#pragma mark - callServiceWith Images and Docs
+(void)callServiceWithImages:(NSMutableArray *)imagesArray Documents:(NSMutableArray *)docsArray params:(NSDictionary *)params  serviceIdentifier:(NSString*)serviceName callBackBlock:(void (^)(id response,NSError *error))responeBlock
{
    if (![Connection isInternetAvailable])
    {
        NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"Please check your internet connection." forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"internet error" code:-1 userInfo:dictionary];
        //responeBlock(nil,error);
        [Connection showInternetAlert];
        return;
    }
    NSURL *urlstring=[NSURL URLWithString:[kBaseURL stringByAppendingString:serviceName]];
    
    NSURL *baseUrl=[NSURL URLWithString:kBaseURL];
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseUrl];
    
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setParameterEncoding:AFJSONParameterEncoding];
    
    DLog(@"Request for URL :%@  \n Parameters \n %@",urlstring,[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]);
    
    
    NSMutableURLRequest *request = nil;
    
    request = [client multipartFormRequestWithMethod:@"POST" path:serviceName parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [request setTimeoutInterval:600];
        [request setValue:@"multipart/form-data; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        for(int i=0;i<[imagesArray count];i++)
        {
            NSString *fileName=[NSString stringWithFormat:@"image%d",i+1];
            NSString *imageName=[NSString stringWithFormat:@"image%d",i+1];
            UIImage *image = [imagesArray objectAtIndex:i];
            image = [image resizedImageByHeight:1200];
            
            //           [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1.0) name:@"image" fileName:@"image.jpg" mimeType:@"image/jpeg"];
            DLog(@"image size = %d MB",[UIImageJPEGRepresentation(image, 1.0) length]/1024/1024);
            
            [formData appendPartWithFileData:UIImageJPEGRepresentation(([imagesArray objectAtIndex:i]), .8) name:imageName fileName:fileName mimeType:@"image/jpeg"];
        }
        for(int i=0;i<[docsArray count];i++)
        {
            if([[NSFileManager defaultManager] fileExistsAtPath:[docsArray objectAtIndex:i]])
            {
                NSError *err;
                
                NSURL *url = [NSURL fileURLWithPath:[docsArray objectAtIndex:i] ];
                
                NSArray *parts = [[docsArray objectAtIndex:i] componentsSeparatedByString:@"/"];
                NSString *filename = [parts lastObject];
                
                
                [formData appendPartWithFileURL:url name:filename error:&err];
                
            }
        }
        
        
        [formData appendPartWithFormData:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil] name:@"json"];
        
    }];
    [request setTimeoutInterval:100];
    [request setValue:[Connection encryptRequestString:serviceName] forHTTPHeaderField:kAuthentication];
    NSString *bundleVersion=[NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
    [request setValue:bundleVersion forHTTPHeaderField:kBundleVersion];
    
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON){
                                             
                                             DLog(@"Response for %@ \n%@",serviceName,[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:JSON options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]);
                                             
                                             responeBlock(JSON,nil);
                                             
                                         }
                                         
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             DLog(@"Failed :  Reason->%@",error);
                                             responeBlock(nil,error);
                                             [Connection showServerErrorAlert];
                                             
                                         }];
    
    
    [client enqueueHTTPRequestOperation:operation];
    
}
#pragma mark Encrypt Request
+(NSString *)encryptRequestString:(NSString *)requestStr
{
    NSString *plainTextStr=[requestStr stringByAppendingString:[NSString stringWithFormat:@"_%f",[Connection getCurrentTimeStamp]]];
    NSString *encyptedStrng=[TAAESCrypt encrypt:plainTextStr password:kEncryptionKey];
    DLog(@"encyptedStrng %@",encyptedStrng);
    NSString *decryptedStrng=[TAAESCrypt decrypt:encyptedStrng password:kEncryptionKey];
    DLog(@"decryptedStrng %@",decryptedStrng);


    
    return encyptedStrng;
    
}

+(void)uploadImages:(NSMutableArray *)imageArray andVideos:(NSMutableArray *)videoArray params:(NSDictionary *)params  serviceIdentifier:(NSString*)serviceName callBackBlock:(void (^)(id response,NSError *error))responeBlock progress:(void(^)(float progress))progressBlock
{
    if (![Connection isInternetAvailable])
    {
        NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"Please check your internet connection." forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"internet error" code:-1 userInfo:dictionary];
        responeBlock(nil,error);
        return;
    }
    
    
    NSURL *urlstring=[NSURL URLWithString:[kBaseURL stringByAppendingString:serviceName]];
    
    NSURL *baseUrl=[NSURL URLWithString:kBaseURL];
    
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:baseUrl];
    
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    [client setParameterEncoding:AFJSONParameterEncoding];
    
    DLog(@"Request for URL :%@  \n Parameters \n %@",urlstring,[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]);
    
    
    NSMutableURLRequest *request = nil;
    
    request = [client multipartFormRequestWithMethod:@"POST" path:serviceName parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        
        //===================Appendind Image Data============================
        for(int i=0;i<[imageArray count];i++)
        {
            //            NSString *fileName=[NSString stringWithFormat:@"image%d.jpg",i+1];
            //            NSString *imageName=[NSString stringWithFormat:@"image%d",i+1];
            UIImage *image = [imageArray objectAtIndex:i];
            image = [image resizedImageByHeight:1200];
            
            [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1.0) name:@"image" fileName:@"image.jpg" mimeType:@"image/jpeg"];
            DLog(@"image size = %u MB",[UIImageJPEGRepresentation(image, 1.0) length]/1024/1024);
        }
        
        
        //===================Appendind Video Data============================
        for(int i=0;i<[videoArray count];i++)
        {
            //            NSString *fileName=[NSString stringWithFormat:@"video%d",i+1];
            //            NSString *videoName=[NSString stringWithFormat:@"video%d",i+1];
            [formData appendPartWithFileData:[videoArray objectAtIndex:i] name:@"video" fileName:@"video.mov" mimeType:@"video/mp4"];
            DLog(@"Video size = %.2f MB",(float)([[videoArray objectAtIndex:i] length])/1024/1024);
        }
        
        [formData appendPartWithFormData:[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil] name:@"json"];
    }];
    
    [request setTimeoutInterval:100];
    [request setValue:[Connection encryptRequestString:serviceName] forHTTPHeaderField:kAuthentication];
    NSString *bundleVersion=[NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
    [request setValue:bundleVersion forHTTPHeaderField:kBundleVersion];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation
                                         JSONRequestOperationWithRequest:request
                                         success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON){
                                             
                                             DLog(@"Response for %@ \n%@",serviceName,[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:JSON options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]);
                                             
                                             responeBlock(JSON,nil);
                                             
                                         }
                                         
                                         failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                                             DLog(@"Failed :  Reason->%@",error);
                                             responeBlock(nil,error);
                                             [Connection showServerErrorAlert];
                                             
                                         }];
    
    
    [client enqueueHTTPRequestOperation:operation];
    
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        
//        DLog(@"bytesWritten = %ld",(unsigned long)bytesWritten);
//        DLog(@"totalBytesWritten = %ld",(unsigned long)totalBytesWritten);
//        DLog(@"totalBytesExpectedToWrite = %ld",(unsigned long)totalBytesExpectedToWrite);
        float prgress = (float)totalBytesWritten/totalBytesExpectedToWrite;
        
        progressBlock (prgress);
    }];
    
    
}

+(void)uploadImage:(UIImage *)imageToUpload allBackBlock:(void (^)(id response,NSError *error))responeBlock
{
    if (![Connection isInternetAvailable])
    {
        NSDictionary *dictionary = [NSDictionary dictionaryWithObject:@"Please check your internet connection." forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"internet error" code:-1 userInfo:dictionary];
        responeBlock(nil,error);
        return;
    }
    
    
    
}



#pragma mark getCurrentTimeStamp
+(NSTimeInterval )getCurrentTimeStamp
{
    NSTimeInterval timeInterval=[[NSDate date] timeIntervalSince1970];
    return timeInterval;
}

//only use for php debugging purpose if they need the response string
+(void)responseString:(NSMutableURLRequest *)request
{
    NSURLResponse *responseString=nil;
    NSData *data=[NSURLConnection sendSynchronousRequest:request returningResponse:&responseString error:nil];
    NSString *debugStr=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Server error" message:debugStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    
}
@end
