//
//  ModalProfilePic.h
//  TedBuddies
//
//  Created by Sourabh on 18/05/15.
//  Copyright (c) 2015 Mayank Pahuja. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModalProfilePic : NSObject

@property (nonatomic , strong) NSURL *imageURL;
@property (nonatomic , strong) NSString *imageId;
@property (nonatomic , assign) BOOL isActive;

-(id) initWithDictionary:(NSDictionary*)imageDictionary;

@end
