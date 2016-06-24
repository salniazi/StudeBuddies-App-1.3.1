//
//  ModalProfilePic.m
//  TedBuddies
//
//  Created by Sourabh on 18/05/15.
//  Copyright (c) 2015 Mayank Pahuja. All rights reserved.
//

#import "ModalProfilePic.h"

@implementation ModalProfilePic

-(id) initWithDictionary:(NSDictionary*)imageDictionary
{
    if (self = [super init]) {
        
        if([imageDictionary valueForKey:@"image"] != (id)[NSNull null] )
            self.imageURL = [NSURL URLWithString:[[imageDictionary valueForKey:@"image"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        if([imageDictionary valueForKey:@"imageId"] != (id)[NSNull null] )
            self.imageId = [imageDictionary valueForKey:@"imageId"];
        if([imageDictionary valueForKey:@"isActive"] != (id)[NSNull null] )
            self.isActive = [[imageDictionary valueForKey:@"isActive"] boolValue];
    }
        return self;


}

@end
